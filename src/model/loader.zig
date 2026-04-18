const std = @import("std");
const c = @import("../llama.zig").c;
const config = @import("../config/schema.zig");
const hf_bridge = @import("hf_bridge.zig");
const weights = @import("weights.zig");
const kv_cache = @import("kv_cache.zig");
const quantize = @import("quantize.zig");

pub const ModelState = struct {
    allocator: std.mem.Allocator,
    model: *c.llama_model,
    ctx: *c.llama_context,
    sampler: *c.llama_sampler,
    vocab: *const c.llama_vocab,
    model_weights: weights.ModelWeights,
    kv_cache: kv_cache.KvCache,
};

pub fn isGGUF(path: []const u8) bool {
    return std.mem.endsWith(u8, path, ".gguf");
}

pub fn loadModel(io: std.Io, allocator: std.mem.Allocator, cfg: config.Config) !*ModelState {
    _ = try quantize.parsePhase1DType(cfg.dtype);

    var model_params = c.llama_model_default_params();
    model_params.n_gpu_layers = cfg.offload;

    const model_path = cfg.model;

    const model = if (isGGUF(model_path))
        c.llama_model_load_from_file(model_path.ptr, model_params) orelse {
            std.debug.print("Error: failed to load model: {s}\n", .{model_path});
            return error.ModelLoadFailed;
        }
    else if (hf_bridge.isHfCheckpointDir(io, model_path))
        blk: {
            if (tryLoadNearbyGguf(allocator, model_path, model_params)) |fallback_model| {
                std.debug.print("Using nearby GGUF for HF path: {s}\n", .{model_path});
                break :blk fallback_model;
            }
            break :blk hf_bridge.loadHfModel(io, allocator, model_path, model_params) catch |err| {
                std.debug.print("Error: failed to load HF model: {s} ({s})\n", .{ model_path, @errorName(err) });
                return err;
            };
        }
    else blk: {
        // Try as GGUF anyway
        break :blk c.llama_model_load_from_file(model_path.ptr, model_params) orelse {
            std.debug.print("Error: failed to load model: {s}\n", .{model_path});
            return error.ModelLoadFailed;
        };
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
    var model_weights = try weights.init(allocator, model);
    errdefer model_weights.deinit();
    const cache = kv_cache.KvCache.init(ctx, model, cfg.kv_type);

    const state = std.heap.page_allocator.create(ModelState) catch unreachable;
    state.* = .{
        .allocator = allocator,
        .model = model,
        .ctx = ctx,
        .sampler = sampler,
        .vocab = vocab.?,
        .model_weights = model_weights,
        .kv_cache = cache,
    };
    return state;
}

pub fn freeModel(state: *ModelState) void {
    state.model_weights.deinit();
    c.llama_sampler_free(state.sampler);
    c.llama_free(state.ctx);
    c.llama_model_free(state.model);
    std.heap.page_allocator.destroy(state);
}

fn tryLoadNearbyGguf(
    allocator: std.mem.Allocator,
    model_dir: []const u8,
    model_params: c.llama_model_params,
) ?*c.llama_model {
    const parent = std.fs.path.dirname(model_dir) orelse return null;
    const target_base = std.fs.path.basename(model_dir);

    const parent_z = allocator.dupeZ(u8, parent) catch return null;
    defer allocator.free(parent_z);

    const d = std.c.opendir(parent_z.ptr) orelse return null;
    defer _ = std.c.closedir(d);

    var best_name: ?[]u8 = null;
    var best_score: usize = std.math.maxInt(usize);
    defer if (best_name) |name| allocator.free(name);

    while (std.c.readdir(d)) |entry| {
        const name = std.mem.sliceTo(&entry.name, 0);
        if (!std.mem.endsWith(u8, name, ".gguf")) continue;

        var score: usize = name.len;
        if (std.mem.indexOf(u8, name, target_base) != null) {
            score = score / 2;
        }
        if (score < best_score) {
            if (best_name) |old| allocator.free(old);
            best_name = allocator.dupe(u8, name) catch return null;
            best_score = score;
        }
    }

    const chosen = best_name orelse return null;
    const full_path = std.fmt.allocPrint(allocator, "{s}/{s}", .{ parent, chosen }) catch return null;
    defer allocator.free(full_path);

    return c.llama_model_load_from_file(full_path.ptr, model_params);
}
