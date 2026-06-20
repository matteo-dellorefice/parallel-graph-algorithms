
#include "pgra/graph_coo.hpp"

#include <iostream>
#include <fstream>

namespace pgra
{
    host_graph_coo::host_graph_coo(unsigned int n_edges) :
        first_(n_edges),
        second_(n_edges),
        weights_(n_edges)
    { }

    host_graph_coo::host_graph_coo(const device_graph_coo& other) :
        first_(other.first_.size_),
        second_(other.second_.size_),
        weights_(other.weights_.size_)
    {
        unsigned int n_edges = other.first_.size_;

        cudaMemcpy(&(first_.buffer_)[0], other.first_.buffer_, n_edges * sizeof(unsigned int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&(second_.buffer_)[0], other.second_.buffer_, n_edges * sizeof(unsigned int), cudaMemcpyDeviceToHost);
        cudaMemcpy(&(weights_.buffer_)[0], other.weights_.buffer_, n_edges * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    }

    void host_graph_coo::to_csv(std::string filename)
    {
        std::ofstream out;
        out.open(filename);
        out << "source, target, weight" << std::endl;
        for (int i = 0; i < first_.size_; i++) {
            out << first_.buffer_[i] << ", " << second_.buffer_[i] << ", " << weights_.buffer_[i] << std::endl;
        }
        out.close();
    }
};