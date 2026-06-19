
#include "pgra/graph_csr.hpp"

namespace pgra
{
    host_graph_csr::host_graph_csr(unsigned int n_vertices, unsigned int n_edges) :
        vertices_(n_vertices),
        adj_(2 * n_edges)
    { }

    host_graph_csr::host_graph_csr(const device_graph_csr& other) :
        vertices_(other.vertices_.size_),
        adj_(other.adj_.size_)
    {
        cudaMemcpy(&(vertices_.buffer_)[0], other.vertices_.buffer_, 
            other.vertices_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&(adj_.buffer_)[0], other.adj_.buffer_, 
            other.adj_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    }
};