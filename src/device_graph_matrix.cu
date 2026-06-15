
#include "pgra/device_graph_matrix.hpp"

#include <curand.h>
#include <thrust/device_ptr.h>
#include <thrust/reduce.h>

__global__ void create_erdos_renyi_kernel(
    const pgra::device_buffer<unsigned int>& dbuf, 
    size_t n_vertices, float edge_probability);

namespace pgra
{
    device_graph_matrix::device_graph_matrix(unsigned int n_vertices) :
        n_vertices_(n_vertices),
        adj_(n_vertices * n_vertices)
    { }

    unsigned int device_graph_matrix::get_num_edges()
    {
        if (n_edges_) return *n_edges_;

        thrust::device_ptr d_ptr = thrust::device_pointer_cast(adj_.buffer_);
        n_edges_ = thrust::reduce(d_ptr, d_ptr + adj_.size_) >> 1;

        return *n_edges_;
    }

    /**
     * Computes a random binary hollow symmetric matrix with entry probability
     * equal to edge_probability.
     */
    device_graph_matrix device_graph_matrix::create_erdos_renyi(
        unsigned int seed, unsigned int n_vertices, float edge_probability)
    {
        device_graph_matrix result(n_vertices);
        curandGenerator_t gen;

        curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
        curandSetPseudoRandomGeneratorSeed(gen, seed);
        curandGenerateUniform(gen, 
            (float *) result.adj_.buffer_, 
            result.adj_.size_);

        dim3 block(32, 32);
        dim3 grid((n_vertices + block.x - 1) / block.x, 
            (n_vertices + block.y - 1) / block.y);
        
        create_erdos_renyi_kernel<<<grid, block>>>(result.adj_, n_vertices, edge_probability);

        return result;
    }
};

__global__ void create_erdos_renyi_kernel(
    const pgra::device_buffer<unsigned int>& dbuf, 
    size_t n_vertices, float edge_probability)
{
    int r = threadIdx.y + blockIdx.y * blockDim.y;
    int c = threadIdx.x + blockIdx.x * blockDim.x;
    if (r > n_vertices - 1 || c > n_vertices - 1 || r > c) return;

    float value = ((float *) dbuf.buffer_)[c + r * n_vertices];
    unsigned int result = (r != c) && (value <= edge_probability);
    dbuf.buffer_[c + r * n_vertices] = result;
    dbuf.buffer_[r + c * n_vertices] = result;
}