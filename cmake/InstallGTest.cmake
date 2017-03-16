ExternalProject_Add(google-test
    DOWNLOAD_NAME       google-test-${GTEST_VERSION}.tar.gz
    URL                 https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz
    URL_MD5             ${GTEST_URL_MD5}
    CMAKE_ARGS          -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

ExternalProject_Get_Property(google-test INSTALL_DIR)

set (GTEST_ROOT                 ${INSTALL_DIR})
set (GTEST_INCLUDE_DIRS         ${GTEST_ROOT}/include)
set (GTEST_LIBRARY_DIRS         ${GTEST_ROOT}/lib)

set (GTEST_LIBRARIES            gtest)
set (GTEST_MAIN_LIBRARIES       gtest-main)
set (GTEST_BOTH_LIBRARIES       ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES})
set (GMOCK_LIBRARIES            gmock)
set (GMOCK_MAIN_LIBRARIES       gmock-main)
set (GMOCK_BOTH_LIBRARIES       ${GMOCK_LIBRARIES} ${GMOCK_MAIN_LIBRARIES})

set (GTEST_LIBRARY_PATH         ${GTEST_LIBRARY_DIRS}/libgtest.a)
set (GTEST_MAIN_LIBRARY_PATH    ${GTEST_LIBRARY_DIRS}/libgtest-main.a)
set (GMOCK_LIBRARY_PATH         ${GTEST_LIBRARY_DIRS}/libgmock.a)
set (GMOCK_MAIN_LIBRARY_PATH    ${GTEST_LIBRARY_DIRS}/libgmock-main.a)

set (GTEST_FOUND                YES)

foreach (lib GTEST_LIBRARIES GTEST_MAIN_LIBRARIES GMOCK_LIBRARIES GMOCK_MAIN_LIBRARIES)
    add_library(${lib} SHARED IMPORTED)
    add_dependencies(${lib} google-test)
endforeach ()

foreach (lib GTEST_LIBRARY_PATH GTEST_MAIN_LIBRARY_PATH GMOCK_LIBRARY_PATH GMOCK_MAIN_LIBRARY_PATH)
    add_library(${lib} STATIC IMPORTED)
    add_dependencies(${lib} google-test)
endforeach ()

mark_as_advanced(GTEST_LIBRARIES GTEST_MAIN_LIBRARIES GMOCK_LIBRARIES GMOCK_MAIN_LIBRARIES GTEST_INCLUDE_DIRS)