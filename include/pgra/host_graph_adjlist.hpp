
#ifndef PGRA_HOST_GRAPH_ADJLIST_HPP
#define PGRA_HOST_GRAPH_ADJLIST_HPP

#include <map>
#include <vector>

namespace pgra
{
    struct host_graph_adjlist
    {
        std::map<unsigned int, std::vector<unsigned int>> adjlists;

        static host_graph_adjlist create_erdos_renyi(unsigned int seed, unsigned int n_vertices, double edge_probability);
    };
};

#endif