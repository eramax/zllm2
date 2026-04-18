const std = @import("std");
const c = @import("../llama.zig").c;

pub const LayerWeights = struct {
    index: u32,
    attn_norm: []const u8,
    attn_q: []const u8,
    attn_k: []const u8,
    attn_v: []const u8,
    attn_output: []const u8,
    ffn_norm: []const u8,
    ffn_gate: []const u8,
    ffn_up: []const u8,
    ffn_down: []const u8,

    pub fn deinit(self: *LayerWeights, allocator: std.mem.Allocator) void {
        allocator.free(self.attn_norm);
        allocator.free(self.attn_q);
        allocator.free(self.attn_k);
        allocator.free(self.attn_v);
        allocator.free(self.attn_output);
        allocator.free(self.ffn_norm);
        allocator.free(self.ffn_gate);
        allocator.free(self.ffn_up);
        allocator.free(self.ffn_down);
    }
};

pub const ModelWeights = struct {
    allocator: std.mem.Allocator,
    arch: []const u8,
    n_layers: u32,
    token_embd: []const u8,
    output_norm: []const u8,
    layers: []LayerWeights,

    pub fn deinit(self: *ModelWeights) void {
        for (self.layers) |*layer| layer.deinit(self.allocator);
        self.allocator.free(self.layers);
        self.allocator.free(self.arch);
        self.allocator.free(self.token_embd);
        self.allocator.free(self.output_norm);
    }
};

pub fn init(allocator: std.mem.Allocator, model: *c.llama_model) !ModelWeights {
    const n_layers: u32 = @intCast(c.llama_model_n_layer(model));
    const arch = try readArch(allocator, model);
    errdefer allocator.free(arch);

    const token_embd = try allocator.dupe(u8, "token_embd.weight");
    errdefer allocator.free(token_embd);

    const output_norm = try allocator.dupe(u8, "output_norm.weight");
    errdefer allocator.free(output_norm);

    var layers = try allocator.alloc(LayerWeights, n_layers);
    errdefer allocator.free(layers);

    var i: u32 = 0;
    while (i < n_layers) : (i += 1) {
        layers[i] = .{
            .index = i,
            .attn_norm = try std.fmt.allocPrint(allocator, "blk.{}.attn_norm.weight", .{i}),
            .attn_q = try std.fmt.allocPrint(allocator, "blk.{}.attn_q.weight", .{i}),
            .attn_k = try std.fmt.allocPrint(allocator, "blk.{}.attn_k.weight", .{i}),
            .attn_v = try std.fmt.allocPrint(allocator, "blk.{}.attn_v.weight", .{i}),
            .attn_output = try std.fmt.allocPrint(allocator, "blk.{}.attn_output.weight", .{i}),
            .ffn_norm = try std.fmt.allocPrint(allocator, "blk.{}.ffn_norm.weight", .{i}),
            .ffn_gate = try std.fmt.allocPrint(allocator, "blk.{}.ffn_gate.weight", .{i}),
            .ffn_up = try std.fmt.allocPrint(allocator, "blk.{}.ffn_up.weight", .{i}),
            .ffn_down = try std.fmt.allocPrint(allocator, "blk.{}.ffn_down.weight", .{i}),
        };
    }

    return .{
        .allocator = allocator,
        .arch = arch,
        .n_layers = n_layers,
        .token_embd = token_embd,
        .output_norm = output_norm,
        .layers = layers,
    };
}

fn readArch(allocator: std.mem.Allocator, model: *c.llama_model) ![]const u8 {
    var buf: [64]u8 = undefined;
    const n = c.llama_model_meta_val_str(model, "general.architecture", &buf, buf.len);
    if (n > 0) {
        return allocator.dupe(u8, buf[0..@intCast(n)]);
    }
    return allocator.dupe(u8, "llama");
}

