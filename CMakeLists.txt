cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(pgra LANGUAGES CXX CUDA)

include(CTest)

set(pgra_HEADERS
    include/pgra/pgra.hpp
)

set(pgra_SOURCES
    src/pgra.cpp
)

add_library(pgra SHARED ${pgra_HEADERS} ${pgra_SOURCES})

target_include_directories(pgra PRIVATE include/)

# tests
set(TEST_TARGET 2d_random_graph_bfs_test)
add_executable(${TEST_TARGET} test/2d_random_graph_bfs_test.cpp)
target_link_libraries(${TEST_TARGET} pgra)
target_include_directories(${TEST_TARGET} PRIVATE include/)

set(TEST_TARGET something_else)