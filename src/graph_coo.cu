
#include "pgra/graph_coo.hpp"

#include <random>

#include <curand.h>
#include <cuda/std/cmath>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/sort.h>
#include <thrust/iterator/shuffle_iterator.h>
#include <thrust/iterator/transform_iterator.h>

struct edge_gen_first
{
    __host__ __device__
    inline unsigned int operator()(unsigned int z) const
    {
        unsigned int c = (unsigned int) cuda::std::floorf(0.5 * (3 + cuda::std::sqrtf(8 * z + 1))) - 1;
        return (unsigned int) (z - 0.5 * c * (c - 1));
    }
};

struct edge_gen_second
{
    __host__ __device__
    inline unsigned int operator()(unsigned int z) const 
    {
        unsigned int c = (unsigned int) cuda::std::floorf(0.5 * (3 + cuda::std::sqrtf(8 * z + 1))) - 1;
        return c;
    }
};

namespace pgra
{
    device_graph_coo::device_graph_coo(unsigned int n_edges) :
        first_(n_edges),
        second_(n_edges),
        weights_(n_edges)
    { }

    device_graph_coo device_graph_coo::create_random(unsigned int seed, unsigned long n_vertices, float edge_probability)
    {
        double max_edges = n_vertices * (n_vertices - 1) * 0.5;
        
        std::random_device rd;
        std::mt19937 gen(rd());
        std::binomial_distribution<unsigned long> dist((unsigned long) max_edges, edge_probability);

        unsigned long n_edges = dist(gen);
        device_graph_coo result(n_edges);

        auto edge_first_ptr = thrust::device_pointer_cast(result.first_.buffer_);
        auto edge_second_ptr = thrust::device_pointer_cast(result.second_.buffer_);

        auto shuffle_iter = thrust::make_shuffle_iterator<unsigned int>(max_edges, thrust::default_random_engine(seed));

        auto edge_first_iter = thrust::make_transform_iterator(shuffle_iter,edge_gen_first());
        auto edge_second_iter = thrust::make_transform_iterator(shuffle_iter, edge_gen_second());

        thrust::copy_n(edge_first_iter, n_edges, edge_first_ptr);
        thrust::copy_n(edge_second_iter, n_edges, edge_second_ptr);

        thrust::stable_sort_by_key(edge_first_ptr, edge_first_ptr + n_edges, edge_second_ptr);

        curandGenerator_t cu_gen;
        curandCreateGenerator(&cu_gen, CURAND_RNG_PSEUDO_DEFAULT);
        curandSetPseudoRandomGeneratorSeed(cu_gen, seed);
        curandGenerateUniform(cu_gen, (float *) result.weights_.buffer_, result.weights_.size_);

        return std::move(result);
    }
};