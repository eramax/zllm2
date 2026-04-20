/*
 * tensor_access.cpp — C++ bridge giving Zig access to llama model weight tensors.
 *
 * IMPORTANT: Zig compiles this with Clang + LLVM libc++ (sizeof std::string=24),
 * but libllama.so was built with GCC + libstdc++ (sizeof std::string=32).
 * To avoid ABI mismatch we access the vector's raw memory using the known
 * GCC pair layout: [string(32) | ggml_tensor*(8)] = 40 bytes per entry.
 * The std::string _M_p field (at offset 0) gives the char* for c_str() in
 * both SSO and heap modes.
 */
#include "llama.h"
#include "ggml.h"
#include <cstring>
#include <cstdio>
#include <cstdint>
#include <vector>
#include <string>
#include <utility>

extern const std::vector<std::pair<std::string, ggml_tensor *>> &
    llama_internal_get_tensor_map(const llama_model * model)
    __asm__("_Z29llama_internal_get_tensor_mapB5cxx11PK11llama_model");

/* GCC libstdc++ std::string layout (C++11 ABI, 64-bit):
 *   offset  0: char* _M_p           — pointer to data (SSO or heap)
 *   offset  8: size_t _M_length
 *   offset 16: char[16] _M_local_buf or size_t _M_capacity
 *   total: 32 bytes
 * std::pair<string, ggml_tensor*>:
 *   offset  0: string  (32 bytes)
 *   offset 32: ggml_tensor*  (8 bytes)
 *   total: 40 bytes
 */
static const size_t GCC_STRING_SIZE = 32;
static const size_t GCC_PAIR_SIZE   = 40; // 32 + 8

static inline const char * gcc_string_cstr(const char * str_base) {
    /* _M_p is at offset 0, it always points to the char data */
    return *(const char * const *)str_base;
}

static inline struct ggml_tensor * gcc_pair_tensor(const char * pair_base) {
    return *(struct ggml_tensor * const *)(pair_base + GCC_STRING_SIZE);
}

extern "C" {

int zllm_count_tensors(const struct llama_model * model) {
    try {
        return (int)llama_internal_get_tensor_map(model).size();
    } catch (...) {
        return 0;
    }
}

const char * zllm_get_tensor_name(const struct llama_model * model, int i) {
    try {
        const auto & map = llama_internal_get_tensor_map(model);
        if (i < 0 || (size_t)i >= map.size()) return nullptr;
        const char * base = (const char *)map.data() + (size_t)i * GCC_PAIR_SIZE;
        struct ggml_tensor * t = gcc_pair_tensor(base);
        return t ? ggml_get_name(t) : nullptr;
    } catch (...) {
        return nullptr;
    }
}

struct ggml_tensor * zllm_get_tensor_by_name(
    const struct llama_model * model,
    const char               * name)
{
    try {
        const auto & map = llama_internal_get_tensor_map(model);
        const char * data = (const char *)map.data();
        const size_t n = map.size();
        for (size_t i = 0; i < n; i++) {
            struct ggml_tensor * t = gcc_pair_tensor(data + i * GCC_PAIR_SIZE);
            if (!t) continue;
            const char * tname = ggml_get_name(t);
            if (tname && std::strcmp(tname, name) == 0) return t;
        }
        return nullptr;
    } catch (...) {
        return nullptr;
    }
}

struct ggml_tensor * zllm_get_tensor_by_index(
    const struct llama_model * model,
    int                        i)
{
    try {
        const auto & map = llama_internal_get_tensor_map(model);
        if (i < 0 || (size_t)i >= map.size()) return nullptr;
        const char * base = (const char *)map.data() + (size_t)i * GCC_PAIR_SIZE;
        return gcc_pair_tensor(base);
    } catch (...) {
        return nullptr;
    }
}

void zllm_set_graph_post_build_callback(
    struct llama_context * ctx,
    void (* fn)(struct ggml_cgraph *, void *),
    void * userdata)
{
    llama_set_graph_post_build_callback(ctx, fn, userdata);
}

} /* extern "C" */
