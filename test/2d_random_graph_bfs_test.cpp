
#include <pgra/pgra.hpp>
#include <ctime>
#include <iostream>
#include <chrono>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>

int main(void)
{
    pgra::device_graph_matrix graph = pgra::device_graph_matrix::create_erdos_renyi(time(NULL), 5, 0.5);
    unsigned int *h_buf = (unsigned int *) calloc(graph.adj_.size_, sizeof(unsigned int));
    cudaMemcpy(h_buf, graph.adj_.buffer_, graph.adj_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    
    std::cout << "graph matrix: " << std::endl;
    for (size_t r = 0; r < graph.n_vertices_; r++) {
        for (size_t c = 0; c < graph.n_vertices_; c++) {
            std::cout << h_buf[c + r * graph.n_vertices_] << " ";    
        }
        std::cout << std::endl;
    }

    pgra::device_graph_csr csr = pgra::device_graph_csr::from_matrix(graph);

    unsigned int *h_vertices = (unsigned int *) calloc(csr.vertices_.size_, sizeof(unsigned int));
    unsigned int *h_adj = (unsigned int *) calloc(csr.adj_.size_, sizeof(unsigned int));

    cudaMemcpy(h_vertices, csr.vertices_.buffer_, csr.vertices_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    cudaMemcpy(h_adj, csr.adj_.buffer_, csr.adj_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    std::cout << "csr vertices: ";
    for (size_t i = 0; i < csr.vertices_.size_; i++) {
        std::cout << h_vertices[i] << " ";
    }
    std::cout << std::endl;

    std::cout << "csr adj: ";
    for (size_t i = 0; i < csr.adj_.size_; i++) {
        std::cout << h_adj[i] << " ";
    }
    std::cout << std::endl;

    // stbi_write_png("test.png", graph.n_vertices_, graph.n_vertices_, 4, 
    //     h_buf, graph.n_vertices_ * sizeof(unsigned int));
    // auto t1 = std::chrono::high_resolution_clock::now();
    // pgra::graph g = pgra::graph::create_erdos_renyi(std::time(NULL), 100000, 1. / 10);
    // auto t2 = std::chrono::high_resolution_clock::now();
    // auto ms_int = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);
    // std::cout << "Execution time: " << ms_int.count() << "ms" << std::endl;
}