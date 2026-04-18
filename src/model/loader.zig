const std = @import("std");
const c = @import("../llama.zig").c;
const config = @import("../config/schema.zig");

pub const ModelState = struct {
    model: *c.llama_model,
    ctx: *c.llama_context,
    sampler: *c.llama_sampler,
    vocab: *const c.llama_vocab,
};

pub fn isGGUF(path: []const u8) bool {
    return std.mem.endsWith(u8, path, ".gguf");
}

pub fn loadModel(allocator: std.mem.Allocator, cfg: config.Config) !*ModelState {
    _ = allocator;

    var model_params = c.llama_model_default_params();
    model_params.n_gpu_layers = cfg.offload;

    const model_path = cfg.model;
    const model = c.llama_model_load_from_file(model_path.ptr, model_params) orelse {
        std.debug.print("Error: failed to load model: {s}\n", .{model_path});
        return error.ModelLoadFailed;
    };

    var ctx_params = c.llama_context_default_params();
    ctx_params.n_ctx = cfg.ctx;
    ctx_params.n_batch = cfg.ctx;
    ctx_params.n_threads = @intCast(cfg.threads);
    ctx_params.n_threads_batch = @intCast(cfg.threads);
    ctx_params.flash_attn_type = if (cfg.flash_attn) c.LLAMA_FLASH_ATTN_TYPE_ENABLED else c.LLAMA_FLASH_ATTN_TYPE_DISABLED;

    const ctx = c.llama_init_from_model(model, ctx_params) orelse {
        std.debug.print("Error: failed to create context\n", .{});
        c.llama_model_free(model);
        return error.ContextCreateFailed;
    };

    // Build sampler chain
    const chain_params = c.llama_sampler_chain_default_params();
    const sampler = c.llama_sampler_chain_init(chain_params);

    if (cfg.repeat_penalty != 1.0) {
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_penalties(64, @floatCast(cfg.repeat_penalty), 0.0, 0.0));
    }
    if (cfg.top_k > 0) {
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_top_k(cfg.top_k));
    }
    if (cfg.top_p < 1.0) {
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_top_p(@floatCast(cfg.top_p), 1));
    }
    if (cfg.temp > 0.0) {
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_temp(@floatCast(cfg.temp)));
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_dist(c.LLAMA_DEFAULT_SEED));
    } else {
        c.llama_sampler_chain_add(sampler, c.llama_sampler_init_greedy());
    }

    const vocab = c.llama_model_get_vocab(model);

    const state = std.heap.page_allocator.create(ModelState) catch unreachable;
    state.* = .{
        .model = model,
        .ctx = ctx,
        .sampler = sampler,
        .vocab = vocab.?,
    };
    return state;
}

pub fn freeModel(state: *ModelState) void {
    c.llama_sampler_free(state.sampler);
    c.llama_free(state.ctx);
    c.llama_model_free(state.model);
    std.heap.page_allocator.destroy(state);
}
