/*
 * tensor_access.c — C shim to expose llama_internal_get_tensor_map to Zig.
 *
 * llama_internal_get_tensor_map is declared in llama-model.h (internal header)
 * and gives a flat list of (name, ggml_tensor*) pairs for all loaded weights.
 * We wrap it in a simple C API usable from Zig's @cImport.
 */
#include "llama.h"
#include "ggml.h"

/* Forward-declare the internal symbol — defined in llama-model.cpp */
struct TensorEntry {
    const char * name;
    struct ggml_tensor * tensor;
};

/* We call the internal function and copy entries into a caller-supplied buffer.
 * Returns the number of entries written (or needed if buf==NULL). */
int zllm_get_tensor_map(
    const struct llama_model * model,
    struct TensorEntry       * buf,
    int                        buf_len)
{
    /* llama_internal_get_tensor_map is a C++ symbol — we use a trick:
     * iterate llama_model_meta_count / name_by_index won't help for tensors.
     * Instead, we use ggml_get_tensor on the model's context.
     * Since we can't call C++ from C, we expose a pure C wrapper here
     * that calls the llama public API where possible, and falls back to
     * iterating gguf tensor names. */

    /* Strategy: open the GGUF file (path from llama_model_meta_val_str on
     * "general.source" — not reliable).  Instead we use the symbol directly.
     * We rely on the linker resolving llama_internal_get_tensor_map from
     * llama-model.cpp which is already compiled into libllama. */
    (void)model; (void)buf; (void)buf_len;
    return 0; /* placeholder — real impl in zllm_tensor_bridge.cpp */
}

/* Simpler: expose ggml_get_tensor so Zig can call it without the C++ mangling */
struct ggml_tensor * zllm_ggml_get_tensor(struct ggml_context * ctx, const char * name) {
    return ggml_get_tensor(ctx, name);
}
