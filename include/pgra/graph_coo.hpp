#ifndef PGRA_GRAPH_COO_HPP
#define PGRA_GRAPH_COO_HPP

#include "pgra/buffer.hpp"

namespace pgra
{
    struct device_graph_coo
    {
        device_buffer<unsigned int> first_;
        device_buffer<unsigned int> second_;
        device_buffer<float> weights_;

        device_graph_coo(unsigned int n_edges);

        static device_graph_coo create_random(unsigned int seed, unsigned long n_vertices, float edge_probability);
    };

    struct host_graph_coo
    {
        host_buffer<unsigned int> first_;
        host_buffer<unsigned int> second_;
        host_buffer<float> weights_;

        host_graph_coo(unsigned int n_edges);
        host_graph_coo(const device_graph_coo& other);

        void to_csv(std::string filename);
    };
};

#endif