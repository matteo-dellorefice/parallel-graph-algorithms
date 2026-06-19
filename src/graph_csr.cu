
#include "pgra/graph_csr.hpp"
#include "pgra/graph_matrix.hpp"

#include <curand.h>
#include <thrust/execution_policy.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>
#include <thrust/sort.h>
#include <thrust/unique.h>
#include <thrust/transform_scan.h>
#include <thrust/iterator/constant_iterator.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/transform_iterator.h>
#include <thrust/iterator/discard_iterator.h>
#include <thrust/iterator/shuffle_iterator.h>

#include <random>
#include <iostream>

struct mod_functor
{
    int m_;
    mod_functor(int m) : m_(m) { };

    __host__ __device__
    int operator()(int x) const
    {
        return x % m_;
    }
};

struct div_functor
{
    int m_;
    div_functor(int m) : m_(m) { };

    __host__ __device__
    int operator()(int x) const
    {
        return x / m_;
    }
};

struct is_nonzero
{
    __host__ __device__
    int operator()(int x) const
    {
        return x != 0;
    }
};

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
    device_graph_csr::device_graph_csr(unsigned int n_vertices, unsigned int n_edges) :
        vertices_(n_vertices), 
        adj_(2 * n_edges),
        weights_(2 * n_edges)
    { }

    device_graph_csr::device_graph_csr(device_buffer<unsigned int>&& vertices, device_buffer<unsigned int>&& adj, device_buffer<float>&& weights) :
        vertices_(std::move(vertices)),
        adj_(std::move(adj)),
        weights_(std::move(weights))
    { }

    device_graph_csr device_graph_csr::from_matrix(device_graph_matrix &adjmatrix)
    {
        unsigned int n_vertices = adjmatrix.n_vertices_;
        unsigned int n_edges = adjmatrix.n_edges_;
        device_graph_csr result(n_vertices, n_edges);
        
        auto col_begin = thrust::make_transform_iterator(
            thrust::make_counting_iterator(0), 
            mod_functor(n_vertices));
        auto col_end = col_begin + (n_vertices * n_vertices);
        auto stencil_ptr = thrust::device_pointer_cast(adjmatrix.adj_.buffer_);
        auto result_adj_ptr = thrust::device_pointer_cast(result.adj_.buffer_);

        thrust::copy_if(col_begin, col_end, stencil_ptr, result_adj_ptr, is_nonzero());
        
        auto row_begin = thrust::make_transform_iterator(
            thrust::make_counting_iterator(0),
            div_functor(n_vertices));
        auto row_end = row_begin + (n_vertices * n_vertices);
        auto values_ptr = thrust::device_pointer_cast(adjmatrix.adj_.buffer_);
        auto result_vertices_ptr = thrust::device_pointer_cast(result.vertices_.buffer_);

        thrust::reduce_by_key(thrust::device, row_begin, row_end, values_ptr, 
            thrust::make_discard_iterator(), result_vertices_ptr);

        thrust::exclusive_scan(result_vertices_ptr, result_vertices_ptr + n_vertices, 
            result_vertices_ptr);

        return result;
    }

    device_graph_csr device_graph_csr::create_random(unsigned int seed,  unsigned long n_vertices, float edge_probability) 
    {
        double max_edges = n_vertices * (n_vertices - 1) * 0.5;
        
        std::random_device rd;
        std::mt19937 gen(rd());
        std::binomial_distribution<unsigned long> dist((unsigned long) max_edges, edge_probability);

        unsigned long n_edges = dist(gen);

        device_buffer<unsigned int> edge_first(n_edges);
        device_buffer<unsigned int> edge_second(n_edges);

        auto edge_first_ptr = thrust::device_pointer_cast(edge_first.buffer_);
        auto edge_second_ptr = thrust::device_pointer_cast(edge_second.buffer_);

        auto shuffle_iter = thrust::make_shuffle_iterator<unsigned int>(max_edges, thrust::default_random_engine(seed));

        auto edge_first_iter = thrust::make_transform_iterator(shuffle_iter,edge_gen_first());
        auto edge_second_iter = thrust::make_transform_iterator(shuffle_iter, edge_gen_second());

        thrust::copy_n(edge_first_iter, n_edges, edge_first_ptr);
        thrust::copy_n(edge_second_iter, n_edges, edge_second_ptr);

        thrust::stable_sort_by_key(edge_first_ptr, edge_first_ptr + n_edges, edge_second_ptr);

        device_buffer<unsigned int> temp(n_vertices);
        auto temp_ptr = thrust::device_pointer_cast(temp.buffer_);

        auto ends_iter = thrust::reduce_by_key(edge_first_ptr, edge_first_ptr + n_edges, thrust::make_constant_iterator(1), thrust::make_discard_iterator(), temp_ptr);

        device_buffer<unsigned int> vertices(ends_iter.second - temp_ptr);
        auto vertices_ptr = thrust::device_pointer_cast(vertices.buffer_);
        thrust::exclusive_scan(temp_ptr, ends_iter.second, vertices_ptr);

        device_buffer<float> weights(edge_second.size_);
        curandGenerator_t cu_gen;
        curandCreateGenerator(&cu_gen, CURAND_RNG_PSEUDO_DEFAULT);
        curandSetPseudoRandomGeneratorSeed(cu_gen, seed);
        curandGenerateUniform(cu_gen, (float *) weights.buffer_, weights.size_);

        return device_graph_csr(std::move(vertices), std::move(edge_second), std::move(weights));
    }
};
