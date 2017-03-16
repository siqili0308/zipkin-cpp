ExternalProject_Add(double_conversion
    DOWNLOAD_NAME   double_conversion-${DOUBLE_CONVERSION_VERSION}.tar.gz
    URL             https://github.com/google/double-conversion/archive/v${DOUBLE_CONVERSION_VERSION}.tar.gz
    URL_MD5         ${DOUBLE_CONVERSION_URL_MD5}
    CMAKE_ARGS      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

ExternalProject_Get_Property(double_conversion INSTALL_DIR)

set (DOUBLE_CONVERSION_ROOT_DIR     ${INSTALL_DIR})
set (DOUBLE_CONVERSION_INCLUDE_DIR  ${DOUBLE_CONVERSION_ROOT_DIR}/include)
set (DOUBLE_CONVERSION_LIBRARY_DIR  ${DOUBLE_CONVERSION_ROOT_DIR}/lib)
set (DOUBLE_CONVERSION_LIBRARY      ${DOUBLE_CONVERSION_LIBRARY_DIR}/libdouble-conversion.a)
set (DOUBLE_CONVERSION_FOUND        YES)

add_library(DOUBLE_CONVERSION_LIBRARY STATIC IMPORTED)
add_dependencies(DOUBLE_CONVERSION_LIBRARY double_conversion)
mark_as_advanced(DOUBLE_CONVERSION_LIBRARY DOUBLE_CONVERSION_INCLUDE_DIR)