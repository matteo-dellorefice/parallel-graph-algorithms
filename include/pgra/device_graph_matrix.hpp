#ifndef PGRA_DEVICE_GRAPH_MATRIX_HPP
#define PGRA_DEVICE_GRAPH_MATRIX_HPP

#include "pgra/device_buffer.hpp"
#include <optional>

namespace pgra
{
    struct device_graph_matrix
    {
        unsigned int n_vertices_;
        std::optional<unsigned int> n_edges_;
        device_buffer<unsigned int> adj_;

        device_graph_matrix(unsigned int n_vertices);

        unsigned int get_num_edges();

        static device_graph_matrix create_erdos_renyi(
            unsigned int seed, unsigned int n_vertices, float edge_probability);
    };
};

#endif