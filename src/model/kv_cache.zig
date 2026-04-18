const std = @import("std");
const c = @import("../llama.zig").c;

pub const KvCache = struct {
    n_ctx: u32,
    n_layers: u32,
    kv_type: []const u8,

    pub fn init(ctx: *c.llama_context, model: *const c.llama_model, kv_type: []const u8) KvCache {
        return .{
            .n_ctx = c.llama_n_ctx(ctx),
            .n_layers = @intCast(c.llama_model_n_layer(model)),
            .kv_type = kv_type,
        };
    }
};

