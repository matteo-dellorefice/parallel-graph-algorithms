
#include "pgra/graph_csr.hpp"

#include <iostream>
#include <fstream>

namespace pgra
{
    host_graph_csr::host_graph_csr(unsigned int n_vertices, unsigned int n_edges) :
        vertices_(n_vertices),
        adj_(2 * n_edges),
        weights_(2 * n_edges)
    { }

    host_graph_csr::host_graph_csr(const device_graph_csr& other) :
        vertices_(other.vertices_.size_),
        adj_(other.adj_.size_),
        weights_(other.weights_.size_)
    {
        cudaMemcpy(&(vertices_.buffer_)[0], other.vertices_.buffer_, vertices_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&(adj_.buffer_)[0], other.adj_.buffer_, adj_.size_ * sizeof(unsigned int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&(weights_.buffer_)[0], other.weights_.buffer_, weights_.size_ * sizeof(float), cudaMemcpyDeviceToHost);
    }

    void host_graph_csr::to_csv(std::string filename)
    {
        // std::ofstream out;
        // out.open(filename);
        // out << "source, target, weight";

    }
};