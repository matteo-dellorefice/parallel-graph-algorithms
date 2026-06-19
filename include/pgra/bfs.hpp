#ifndef PGRA_BFS_HPP
#define PGRA_BFS_HPP

#include "pgra/buffer.hpp"

#include <chrono>

namespace pgra
{
    struct device_graph_csr;

    struct bfs 
    {
        unsigned int n_vertices_;
        device_buffer<bool> visited_;
        device_buffer<bool> frontier_;
        std::chrono::milliseconds last_exec_time_;

        bfs(unsigned int n_vertices);

        device_buffer<unsigned int> run(const device_graph_csr& graph, unsigned int source);
    };
};

#endif