#ifndef PGRA_DEVICE_GRAPH_CSR_HPP
#define PGRA_DEVICE_GRAPH_CSR_HPP

#include "device_buffer.hpp"

namespace pgra
{
    struct device_graph_matrix;

    struct device_graph_csr
    {
        device_buffer<unsigned int> vertices_;
        device_buffer<unsigned int> adj_;

        device_graph_csr(unsigned int n_vertices, unsigned int n_edges);

        static device_graph_csr from_matrix(device_graph_matrix &matrix);
    };
};

#endif