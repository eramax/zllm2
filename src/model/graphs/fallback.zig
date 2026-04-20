//! Default inference graph using llama_decode (works for all architectures).

const std = @import("std");
const c = @import("../../llama.zig").c;
const loader = @import("../loader.zig");
const interface = @import("interface.zig");

pub fn prefill(ms: *loader.ModelState, tokens: []const c.llama_token) !void {
    const batch = c.llama_batch_get_one(@constCast(tokens.ptr), @intCast(tokens.len));
    const result = c.llama_decode(ms.ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

pub fn decodeOne(ms: *loader.ModelState, token: c.llama_token) !void {
    var t = token;
    const batch = c.llama_batch_get_one(&t, 1);
    const result = c.llama_decode(ms.ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

pub fn sample(ms: *loader.ModelState) c.llama_token {
    return c.llama_sampler_sample(ms.sampler, ms.ctx, -1);
}

pub fn accept(ms: *loader.ModelState, token: c.llama_token) void {
    c.llama_sampler_accept(ms.sampler, token);
}

pub const ops: interface.GraphOps = .{
    .prefill = prefill,
    .decodeOne = decodeOne,
    .sample = sample,
    .accept = accept,
};
