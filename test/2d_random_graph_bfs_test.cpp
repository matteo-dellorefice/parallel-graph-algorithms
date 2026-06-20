
#include <pgra/pgra.hpp>
#include <ctime>
#include <iostream>
#include <chrono>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>
#include <chrono>

int main(void)
{

    auto t1 = std::chrono::high_resolution_clock::now();
    // pgra::device_graph_csr d_graph = pgra::device_graph_csr::create_random(time(NULL), 1000000, .0001);
    pgra::device_graph_coo d_graph = pgra::device_graph_coo::create_random(time(NULL), 1000000, 0.0005);
    auto t2 = std::chrono::high_resolution_clock::now();
    std::chrono::milliseconds last_exec_time_ = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);

    std::cout << "time: " << last_exec_time_.count() << std::endl;

    // pgra::host_graph_coo h_graph = d_graph;
    // h_graph.to_csv("test.csv");

    
    // std::cout << "vertices size: " << d_graph.vertices_.size_ << std::endl;
    // std::cout << "adj size: " << d_graph.adj_.size_ << std::endl;
    // pgra::host_graph_csr h_graph = d_graph;

    // std::cout << "vertices: " << h_graph.vertices_ << std::endl;
    // std::cout << "adj:" << h_graph.adj_ << std::endl;
}