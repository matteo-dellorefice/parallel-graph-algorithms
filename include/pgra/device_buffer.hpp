#ifndef PGRA_DEVICE_BUFFER_HPP
#define PGRA_DEVICE_BUFFER_HPP

#include <cuda_runtime.h>

namespace pgra
{
    template <typename T>
    struct device_buffer
    {
        unsigned int size_;
        T *buffer_;

        device_buffer(unsigned int size) : size_(size)
        {
            cudaMalloc((void **)&buffer_, size * sizeof(T));
        }

        device_buffer(const device_buffer& other) = delete;
        device_buffer(device_buffer&& other) = default;

        device_buffer& operator=(const device_buffer& other) = delete;
        device_buffer& operator=(device_buffer&& other) = default;

        ~device_buffer()
        {
            cudaFree(buffer_);
        }
    };
};

#endif