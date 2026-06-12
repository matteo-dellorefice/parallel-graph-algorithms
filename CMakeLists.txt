cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(parallel-graph-algorithms LANGUAGES CXX CUDA)

find_package(CUDA REQUIRED)

include(CTest)

set(TARGET pga)

set(SRC_FILES
    src/main.cpp
)

add_executable(${TARGET} ${SRC_FILES})

target_include_directories(${TARGET} PRIVATE
    ${CUDA_INCLUDE_DIRS}
    src)

target_link_libraries(${TARGET} 
    ${CMAKE_DL_LIBS})

set_target_properties(pga
    PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
