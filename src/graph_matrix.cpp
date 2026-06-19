
#include "pgra/graph_matrix.hpp"

namespace pgra
{
    host_graph_matrix::host_graph_matrix(unsigned int n_vertices) :
        n_vertices_(n_vertices),
        adj_(n_vertices * n_vertices)
    { }

    host_graph_matrix::host_graph_matrix(const device_graph_matrix& other):
        host_graph_matrix(other.n_vertices_)
    {
        cudaMemcpy(&adj_[0], other.adj_.buffer_, 
            other.adj_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    }
};