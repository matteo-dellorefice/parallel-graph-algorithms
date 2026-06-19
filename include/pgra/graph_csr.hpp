#ifndef PGRA_GRAPH_CSR_HPP
#define PGRA_GRAPH_CSR_HPP

#include "buffer.hpp"

#include <vector>

namespace pgra
{
    struct device_graph_matrix;

    struct device_graph_csr
    {
        device_buffer<unsigned int> vertices_;
        device_buffer<unsigned int> adj_;

        device_graph_csr(unsigned int n_vertices, unsigned int n_edges);
        device_graph_csr(device_buffer<unsigned int>&& vertices, device_buffer<unsigned int>&& adj);

        static device_graph_csr from_matrix(device_graph_matrix &matrix);
        static device_graph_csr create_erdos_renyi(unsigned int seed, 
            unsigned long n_vertices, float edge_probability);
    };

    struct host_graph_csr
    {
        host_buffer<unsigned int> vertices_;
        host_buffer<unsigned int> adj_;

        host_graph_csr(unsigned int n_vertices, unsigned int n_edges);
        host_graph_csr(const device_graph_csr& other);
    };
};

#endif