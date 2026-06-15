
#include "pgra/host_graph_adjlist.hpp"

#include <cstdlib>

namespace pgra
{
    host_graph_adjlist host_graph_adjlist::create_erdos_renyi(unsigned int seed, unsigned int n_vertices, double edge_probability)
    {
        srand(seed);
        host_graph_adjlist result;

        for (size_t i = 0; i < n_vertices; i++) {
            std::vector<unsigned int> list;

            for (size_t j = 0; j < n_vertices; j++) {
                if (i == j) continue;
                if ((double) rand() / (RAND_MAX) <= edge_probability) {
                    list.push_back(j);
                }
            }
            
            result.adjlists.insert({ i, list });
        }

        return result;
    }
};
