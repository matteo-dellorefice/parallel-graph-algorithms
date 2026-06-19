
#include "pgra/bfs.hpp"
#include "pgra/graph_csr.hpp"

#include <limits>
#include <thrust/device_ptr.h>
#include <thrust/fill.h>
#include <thrust/reduce.h>

__global__ void bfs_kernel(unsigned int *vertices, unsigned int n_vertices,unsigned int *adj, unsigned int n_adj, bool *frontier, bool *visited,unsigned int *costs, unsigned int source);

namespace pgra
{
    bfs::bfs(unsigned int n_vertices) : 
        n_vertices_(n_vertices), 
        visited_(n_vertices_),
        frontier_(n_vertices),
        last_exec_time_(0)
    { }

    device_buffer<unsigned int> bfs::run(const device_graph_csr &graph, unsigned int source)
    {
        device_buffer<unsigned int> costs(n_vertices_);

        auto frontier_ptr = thrust::device_pointer_cast(frontier_.buffer_);
        auto costs_ptr = thrust::device_pointer_cast(costs.buffer_);

        thrust::fill(costs_ptr, costs_ptr + n_vertices_, std::numeric_limits<unsigned int>::max());
        frontier_ptr[source] = true;
        costs_ptr[source] = 0;

        dim3 block(1024);
        dim3 grid((n_vertices_ + block.x - 1) / block.x);
        // TODO check this out: cudaOccupancyMaxPotentialBlockSize()

        auto t1 = std::chrono::high_resolution_clock::now();
        bool frontier_not_empty = true;
        while (frontier_not_empty)
        {
            bfs_kernel<<<grid, block>>>(graph.vertices_.buffer_, n_vertices_, graph.adj_.buffer_, graph.adj_.size_, frontier_.buffer_, visited_.buffer_, costs.buffer_, source);

            frontier_not_empty = thrust::reduce(frontier_ptr, frontier_ptr + n_vertices_, false, thrust::logical_or<bool>());
        }

        cudaDeviceSynchronize();

        auto t2 = std::chrono::high_resolution_clock::now();
        last_exec_time_ = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);

        return costs;
    }
};

__global__ void bfs_kernel(unsigned int *vertices, unsigned int n_vertices, unsigned int *adj, unsigned int n_adj, bool *frontier, bool *visited, unsigned int *costs, unsigned int source)
{
    int v = threadIdx.x + blockDim.x * blockIdx.x;

    if (v >= n_vertices)
        return;

    if (frontier[v])
    {
        frontier[v] = false;
        visited[v] = true;
        int start_adj_index = vertices[v];
        int end_adj_index = v == n_vertices - 1 ? n_adj : vertices[v + 1];
        for (int i = start_adj_index; i < end_adj_index; i++)
        {
            int w = adj[i];
            if (!visited[w])
            {
                costs[w] = 1 + costs[v];
                frontier[w] = true;
            }
        }
    }
}