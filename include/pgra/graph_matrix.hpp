#ifndef PGRA_GRAPH_MATRIX_HPP
#define PGRA_GRAPH_MATRIX_HPP

#include "pgra/buffer.hpp"

#include <vector>

namespace pgra
{
    struct device_graph_matrix
    {
        unsigned int n_vertices_;
        unsigned int n_edges_;
        device_buffer<unsigned int> adj_;

        device_graph_matrix(unsigned int n_vertices);

        static device_graph_matrix create_erdos_renyi(unsigned int seed, 
            unsigned int n_vertices, float edge_probability);
    };

    struct host_graph_matrix
    {
        unsigned int n_vertices_;
        std::vector<unsigned int> adj_;

        host_graph_matrix(unsigned int n_vertices);
        host_graph_matrix(const device_graph_matrix& other);

    };
};

#endif