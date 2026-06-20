cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(pgra LANGUAGES CXX CUDA)

include(CTest)

find_package(CUDAToolkit REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)
find_package(OpenGL REQUIRED COMPONENTS OpenGL)
find_package(GLUT REQUIRED)
find_package(GLEW REQUIRED)

set(CCCL_DIR "/usr/local/cuda/lib64/cmake/cccl/") # TODO not portable?
find_package(CCCL REQUIRED)
find_package(mathdx REQUIRED COMPONENTS curanddx CONFIG PATHS "${CMAKE_SOURCE_DIR}/nvidia/mathdx/26.03/")

# get_cmake_property(_variableNames VARIABLES)
# list (SORT _variableNames)
# foreach (_variableName ${_variableNames})
#     message(STATUS "${_variableName}=${${_variableName}}")
# endforeach()

set(pgra_HEADERS
    include/pgra/pgra.hpp
    include/pgra/graph_matrix.hpp
    include/pgra/graph_csr.hpp
    include/pgra/graph_coo.hpp
    include/pgra/bfs.hpp
)

set(pgra_SOURCES
    src/graph_matrix.cpp
    src/graph_matrix.cu
    src/graph_csr.cpp
    src/graph_csr.cu
    src/graph_coo.cpp
    src/graph_coo.cu
    src/bfs.cu
)

add_library(pgra SHARED ${pgra_HEADERS} ${pgra_SOURCES})
set_property(TARGET pgra PROPERTY CUDA_ARCHITECTURES native)
target_link_libraries(pgra PUBLIC CCCL::CCCL)
target_link_libraries(pgra PUBLIC CUDA::curand)
target_link_libraries(pgra PUBLIC mathdx::curanddx)
target_include_directories(pgra PUBLIC include/)

# tests
set(TEST_TARGET 2d_random_graph_bfs_test)
add_executable(${TEST_TARGET} test/2d_random_graph_bfs_test.cpp)
set_property(TARGET ${TEST_TARGET} PROPERTY CUDA_ARCHITECTURES native)
target_link_libraries(${TEST_TARGET} PRIVATE pgra ${CUDA_CUDART})
target_include_directories(${TEST_TARGET} PRIVATE include/)
target_include_directories(${TEST_TARGET} PRIVATE ${CUDAToolkit_INCLUDE_DIRS})

# tests
set(TEST_TARGET visualize_graph)
add_executable(${TEST_TARGET} test/visualize_graph.cu)
set_property(TARGET ${TEST_TARGET} PROPERTY CUDA_ARCHITECTURES native)
target_link_libraries(${TEST_TARGET} PRIVATE 
    ${CMAKE_DL_LIBS}
    ${CUDA_CUDART}
    ${GLEW_LIBRARIES}
    OpenGL::OpenGL 
    OpenGL::GLU 
    GLUT::GLUT
    Eigen3::Eigen
    pgra)
target_include_directories(${TEST_TARGET} PRIVATE include/)
target_include_directories(${TEST_TARGET} PRIVATE ${CUDAToolkit_INCLUDE_DIRS})
