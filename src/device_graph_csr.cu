#include <iostream>
#include "pgra/device_graph_csr.hpp"
#include "pgra/device_graph_matrix.hpp"

#include <thrust/execution_policy.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/transform_iterator.h>
#include <thrust/iterator/discard_iterator.h>

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

namespace pgra
{
    device_graph_csr::device_graph_csr(unsigned int n_vertices, unsigned int n_edges) :
        vertices_(n_vertices), adj_(2 * n_edges)
    { }

    device_graph_csr device_graph_csr::from_matrix(device_graph_matrix &adjmatrix)
    {
        unsigned int n_vertices = adjmatrix.n_vertices_;
        unsigned int n_edges = adjmatrix.get_num_edges();
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
};