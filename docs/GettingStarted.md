# Getting Started

`zipkin-cpp` is a library used to capture and report latency information about distributed operations to `Zipkin`.

This module includes tracer creates and joins spans that model the latency of potentially distributed work. It also includes libraries to propagate the trace context over network boundaries, for example, via http headers.

## Setup

Most importantly, you need a Tracer, configured to report to Zipkin.

Here's an example setup that sends trace data (spans) to Zipkin over Kafka (as opposed to HTTP).

```c++
#include <zipkin/zipkin.hpp>

zipkin::KafkaConf conf("kafka://localhost/zipkin");
std::shared_ptr<zipkin::KafkaCollector> collector(conf.create());
std::unique_ptr<zipkin::Tracer> tracer(zipkin::Tracer::create(collector.get()));
```
---
```c
#include <zipkin/zipkin.h>

zipkin_kafka_conf_t conf = zipkin_kafka_conf_new("localhost", "zipkin");
zipkin_collector_t collector = zipkin_kafka_collector_new(conf);
zipkin_tracer_t tracer = zipkin_tracer_new(collector);
```

The spans will be send to the Kafka broker at `localhost[:2181]` with `zipkin` topic.

`zipkin-cpp` supports the `Kafka`, `Http`, `Scribe` and `AWS X-Ray` collectors.

## Tracing

The tracer creates and joins spans that model the latency of potentially distributed work. It can employ sampling to reduce overhead in process or to reduce the amount of data sent to Zipkin.

Spans returned by a tracer report data to Zipkin when finished, or do nothing if unsampled. After starting a span, you can annotate events of interest or add tags containing details or lookup keys.

Spans have a context which includes trace identifiers that place it at the correct spot in the tree representing the distributed operation.

### Local Tracing

When tracing local code, just run it inside a span scope.

```c++
zipkin::Span& span = *tracer->span("encode");
zipkin::Span::Scope scope(span);

doSomethingExpensive();
```
---
```c
zipkin_span_t span = zipkin_span_new(tracer, "encode", NULL);

doSomethingExpensive();

zipkin_span_submit(span);
```

In the above example, the span is the root of the trace. In many cases, you will be a part of an existing trace. When this is the case, call `Span::span` instead of `Tracer::span`.

```c++
zipkin::Span& child_span = *root_span.span("encode");
zipkin::Span::Scope scope(child_span);

doSomethingExpensive();
```
---
```c
zipkin_span_t child_span = zipkin_span_new_child(root_span, "encode", NULL);

doSomethingExpensive();

zipkin_span_submit(child_span);
```

Once you have a span, you can add tags to it, which can be used as lookup keys or details. For example, you might add a tag with your runtime version:

```c++
span << std::make_pair("clnt/zipkin-cpp.version", "0.3.0");
```
---
```c
ANNOTATE_STR(span, "clnt/zipkin-cpp.version", "0.3.0", -1, NULL);
```

### RPC tracing

RPC tracing is often done automatically by interceptors. Under the scenes, they add tags and events that relate to their role in an RPC operation.

Here's an example of a client span:

```c++
// before you send a request, add metadata that describes the operation
zipkin::Span& span = *tracer->span("get");

span << std::make_pair("clnt/zipkin-cpp.version", "0.3.0")
     << std::make_pair(zipkin::TraceKeys::HTTP_PATH, "/api")
     << zipkin::Endpoint("backend", "127.0.0.1", 8080);

// if you have callbacks for when data is on the wire, note those events
span << zipkin::TraceKeys::WIRE_SEND;
span << zipkin::TraceKeys::WIRE_RECV;

// when the response is complete, finish the span
span.submit();
```
---
```c
// before you send a request, add metadata that describes the operation
zipkin_span_t span = zipkin_span_new(tracer, "get", NULL);
zipkin_endpoint_t endpoint = zipkin_endpoint_new("backend", &addr);

ANNOTATE_STR(span, "clnt/zipkin-cpp.version", "0.3.0", -1, NULL);
ANNOTATE_STR(span, HTTP_PATH, "/api", -1, endpoint);

// if you have callbacks for when data is on the wire, note those events
ANNOTATE(span, WIRE_SEND, -1);
ANNOTATE(span, WIRE_RECV, -1);

// when the response is complete, finish the span
zipkin_span_submit(span);
zipkin_endpoint_free(endpoint);
```

## Sampling

Sampling may be employed to reduce the data collected and reported out of process. When a span isn't sampled, it adds no overhead (noop).

Sampling is an up-front decision, meaning that the decision to report data is made at the first operation in a trace, and that decision is propagated downstream.

### Custom sampling

You may want to apply different policies depending on what the operation is. For example, you might not want to trace requests to static resources such as images, or you might want to trace all requests to a new api.

Most users will use a framework interceptor which automates this sort of policy. Here's how they might work internally.

```c++
zipkin::Span *newTrace(Request& input) {
    zipkin::Span *span = tracer->span("get");

    if (input.url().startsWith("/experimental")) {
        span->with_sampled(true);
    } else if (input.url().startsWith("/static")) {
        span->with_sampled(false);
    }
    return span;
}
```

## Propagation

## Performance
`zipkin-cpp` has been built with performance in mind. Using the core Span api, you can record spans in sub-microseconds. When a span is sampled, there's effectively no overhead (as it is a noop).