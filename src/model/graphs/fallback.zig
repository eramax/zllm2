const std = @import("std");
const c = @import("../../llama.zig").c;

pub fn prefill(ctx: *c.llama_context, tokens: []const c.llama_token) !void {
    const batch = c.llama_batch_get_one(@constCast(tokens.ptr), @intCast(tokens.len));
    const result = c.llama_decode(ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

pub fn decodeOne(ctx: *c.llama_context, token: c.llama_token) !void {
    var t = token;
    const batch = c.llama_batch_get_one(&t, 1);
    const result = c.llama_decode(ctx, batch);
    if (result < 0) return error.DecodeFailed;
}

pub fn sample(sampler: *c.llama_sampler, ctx: *c.llama_context) c.llama_token {
    return c.llama_sampler_sample(sampler, ctx, -1);
}

pub fn accept(sampler: *c.llama_sampler, token: c.llama_token) void {
    c.llama_sampler_accept(sampler, token);
}
