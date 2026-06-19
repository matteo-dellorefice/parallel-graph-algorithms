#ifndef PGRA_BUFFER_HPP
#define PGRA_BUFFER_HPP

#include <cuda_runtime.h>
#include <vector>
#include <ostream>

namespace pgra
{
    template<typename T>
    struct host_buffer;

    template<typename T>
    struct device_buffer
    {
        unsigned int size_;
        T *buffer_;

        device_buffer(unsigned int size) : size_(size)
        {
            cudaMalloc((void **)&buffer_, size * sizeof(T));
        }

        device_buffer(const host_buffer<T>& other) :
            device_buffer(other.size_)
        {
            cudaMemcpy(buffer_, &(other.buffer_[0]), size_ * sizeof(T), cudaMemcpyHostToDevice);   
        }

        device_buffer(const device_buffer& other) = delete;
        
        device_buffer(device_buffer&& other) : 
            size_(other.size_),
            buffer_(other.buffer_)
        {
            other.buffer_ = nullptr;
        }

        device_buffer& operator=(const device_buffer& other) = delete;
        device_buffer& operator=(device_buffer&& other) = default;

        ~device_buffer()
        {
            if (buffer_ != nullptr)
                cudaFree(buffer_);
        }
    };

    template<typename T>
    struct host_buffer
    {
        unsigned int size_;
        std::vector<T> buffer_;

        host_buffer(unsigned int size) :
            size_(size),
            buffer_(size)
        { }

        host_buffer(const device_buffer<T>& other) :
            host_buffer(other.size_)
        {
            cudaMemcpy(&buffer_[0], other.buffer_, size_ * sizeof(T), cudaMemcpyDeviceToHost);
        }

        host_buffer& operator=(const device_buffer<T>& other) 
        {
            cudaMemcpy(&buffer_[0], other.buffer_, size_ * sizeof(T), cudaMemcpyDeviceToHost);

            return *this;
        } 

        friend std::ostream& operator<<(std::ostream &os, const host_buffer<T>& b)
        {
            for (int i = 0; i < b.size_; i++) {
                os << b.buffer_[i] << " ";
            }

            return os;
        }
    };
};

#endif