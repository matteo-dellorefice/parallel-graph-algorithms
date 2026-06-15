cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(pgra LANGUAGES CXX CUDA)

# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CUDA_STANDARD 17)
# set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
# set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

include(CTest)

find_package(CUDAToolkit REQUIRED)

set(CCCL_DIR "/usr/local/cuda/lib64/cmake/cccl/") # TODO not portable, sort this out
find_package(CCCL REQUIRED)

# get_cmake_property(_variableNames VARIABLES)
# list (SORT _variableNames)
# foreach (_variableName ${_variableNames})
#     message(STATUS "${_variableName}=${${_variableName}}")
# endforeach()

set(pgra_HEADERS
    include/pgra/pgra.hpp
    include/pgra/device_graph_matrix.hpp
    include/pgra/device_graph_csr.hpp
)

set(pgra_SOURCES
    src/device_graph_matrix.cu
    src/device_graph_csr.cu
)

add_library(pgra SHARED ${pgra_HEADERS} ${pgra_SOURCES})
set_property(TARGET pgra PROPERTY CUDA_ARCHITECTURES native)
target_link_libraries(pgra PUBLIC CCCL::CCCL)
target_link_libraries(pgra PUBLIC CUDA::curand)
target_include_directories(pgra PUBLIC include/)

# tests
set(TEST_TARGET 2d_random_graph_bfs_test)
add_executable(${TEST_TARGET} test/2d_random_graph_bfs_test.cpp)
set_property(TARGET ${TEST_TARGET} PROPERTY CUDA_ARCHITECTURES native)
target_link_libraries(${TEST_TARGET} PRIVATE pgra)
target_link_libraries(${TEST_TARGET} PRIVATE ${CUDA_CUDART})
target_include_directories(${TEST_TARGET} PRIVATE include/)
target_include_directories(${TEST_TARGET} PRIVATE ${CUDAToolkit_INCLUDE_DIRS}) # for gcc
