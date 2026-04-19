/*
 * tensor_access.cpp — C++ bridge giving Zig access to llama model weight tensors.
 *
 * llama_internal_get_tensor_map (in llama-model.h) returns a vector of
 * (name, ggml_tensor*) pairs for every weight in the loaded model.
 * We wrap it in a plain-C API usable from Zig via @cImport.
 */
#include "llama.h"
#include "ggml.h"

/* Internal symbol declared in llama-model.h — resolved from libllama */
#include <vector>
#include <string>
#include <utility>

/* Use exact mangled name to match libllama.so (C++11 ABI) */
extern const std::vector<std::pair<std::string, ggml_tensor *>> &
    llama_internal_get_tensor_map(const llama_model * model)
    __asm__("_Z29llama_internal_get_tensor_mapB5cxx11PK11llama_model");

extern "C" {

/*
 * zllm_count_tensors — returns the total number of weight tensors in the model.
 */
int zllm_count_tensors(const struct llama_model * model) {
    try {
        return (int)llama_internal_get_tensor_map(model).size();
    } catch (...) {
        return 0;
    }
}

/*
 * zllm_get_tensor_name — returns the name of tensor at index i, or NULL.
 */
const char * zllm_get_tensor_name(const struct llama_model * model, int i) {
    try {
        const auto & map = llama_internal_get_tensor_map(model);
        if (i < 0 || (size_t)i >= map.size()) return nullptr;
        return map[i].first.c_str();
    } catch (...) {
        return nullptr;
    }
}

/*
 * zllm_get_tensor_by_name — look up a weight tensor by exact name.
 * Returns NULL if not found.
 */
struct ggml_tensor * zllm_get_tensor_by_name(
    const struct llama_model * model,
    const char               * name)
{
    try {
        for (const auto & p : llama_internal_get_tensor_map(model)) {
            if (p.first == name) return p.second;
        }
        return nullptr;
    } catch (...) {
        return nullptr;
    }
}

/*
 * zllm_get_tensor_by_index — get tensor pointer by index.
 */
struct ggml_tensor * zllm_get_tensor_by_index(
    const struct llama_model * model,
    int                        i)
{
    try {
        const auto & map = llama_internal_get_tensor_map(model);
        if (i < 0 || (size_t)i >= map.size()) return nullptr;
        return map[i].second;
    } catch (...) {
        return nullptr;
    }
}

} /* extern "C" */
