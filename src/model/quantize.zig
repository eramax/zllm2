const std = @import("std");
const c = @import("../llama.zig").c;

pub const Phase1DType = enum {
    f16,
    f32,
};

pub const LoadDType = union(enum) {
    plain: Phase1DType,
    quantized: c.llama_ftype,
};

pub fn parsePhase1DType(dtype: []const u8) !Phase1DType {
    if (std.mem.eql(u8, dtype, "f16")) return .f16;
    if (std.mem.eql(u8, dtype, "f32")) return .f32;
    return error.UnsupportedDTypeInPhase1;
}

pub fn parseLoadDType(dtype: []const u8) !LoadDType {
    if (std.mem.eql(u8, dtype, "f16")) return .{ .plain = .f16 };
    if (std.mem.eql(u8, dtype, "f32")) return .{ .plain = .f32 };
    if (std.mem.eql(u8, dtype, "q8_0")) return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q8_0 };
    if (std.mem.eql(u8, dtype, "q5_k_m")) return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q5_K_M };
    if (std.mem.eql(u8, dtype, "q4_k_m") or std.mem.eql(u8, dtype, "q_4km")) {
        return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q4_K_M };
    }
    if (std.mem.eql(u8, dtype, "q3_k_m") or std.mem.eql(u8, dtype, "q_3km")) {
        return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q3_K_M };
    }
    if (std.mem.eql(u8, dtype, "q2_k")) return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q2_K };
    return error.UnsupportedLoadDType;
}

pub fn resolveLoadDType(dtype: []const u8, quant: ?[]const u8) !LoadDType {
    if (quant) |quant_name| {
        const parsed = try parseLoadDType(quant_name);
        if (parsed != .quantized) return error.QuantFlagRequiresQuantizedType;
        return parsed;
    }

    const parsed = try parseLoadDType(dtype);
    if (parsed == .quantized) return error.QuantizationRequiresExplicitQuantFlag;
    return parsed;
}

pub fn metadataFileType(load_dtype: LoadDType) u32 {
    return switch (load_dtype) {
        .plain => |plain| switch (plain) {
            .f16 => c.LLAMA_FTYPE_MOSTLY_F16,
            .f32 => c.LLAMA_FTYPE_ALL_F32,
        },
        .quantized => |ftype| @intCast(ftype),
    };
}

pub fn chooseTensorType(load_dtype: LoadDType, tensor_name: []const u8, shape: []const u64, n_layers: u32) c.ggml_type {
    if (shape.len <= 1) return c.GGML_TYPE_F32;
    if (!std.mem.endsWith(u8, tensor_name, ".weight")) return c.GGML_TYPE_F32;
    if (requiresF32OperatorWeight(tensor_name)) return c.GGML_TYPE_F32;

    const wanted: c.ggml_type = switch (load_dtype) {
        .plain => |plain| switch (plain) {
            .f16 => @intCast(c.GGML_TYPE_F16),
            .f32 => @intCast(c.GGML_TYPE_F32),
        },
        .quantized => |ftype| chooseQuantizedTensorType(ftype, tensor_name, n_layers),
    };

    return applyShapeFallback(wanted, shape[0]);
}

fn chooseQuantizedTensorType(ftype: c.llama_ftype, tensor_name: []const u8, n_layers: u32) c.ggml_type {
    const layer = parseLayerIndex(tensor_name);
    const role = classifyTensor(tensor_name);

    return switch (ftype) {
        c.LLAMA_FTYPE_MOSTLY_Q8_0 => c.GGML_TYPE_Q8_0,
        c.LLAMA_FTYPE_MOSTLY_Q5_K_M => switch (role) {
            .output, .attention_v => c.GGML_TYPE_Q6_K,
            .attention_qkv => c.GGML_TYPE_Q6_K,
            .ffn_down => if (layer) |idx|
                if (useMoreBits(idx, n_layers)) c.GGML_TYPE_Q6_K else c.GGML_TYPE_Q5_K
            else
                c.GGML_TYPE_Q5_K,
            else => c.GGML_TYPE_Q5_K,
        },
        c.LLAMA_FTYPE_MOSTLY_Q4_K_M => switch (role) {
            .output, .token_embd, .attention_v => c.GGML_TYPE_Q6_K,
            .attention_qkv => c.GGML_TYPE_Q5_K,
            .ffn_down => if (layer) |idx|
                if (useMoreBits(idx, n_layers)) c.GGML_TYPE_Q6_K else c.GGML_TYPE_Q4_K
            else
                c.GGML_TYPE_Q4_K,
            else => c.GGML_TYPE_Q4_K,
        },
        c.LLAMA_FTYPE_MOSTLY_Q3_K_M => switch (role) {
            .output => c.GGML_TYPE_Q6_K,
            .attention_v => c.GGML_TYPE_Q5_K,
            .attention_qkv, .attention_output => c.GGML_TYPE_Q4_K,
            .ffn_down => if (layer) |idx|
                if (idx < max(1, n_layers / 16)) c.GGML_TYPE_Q5_K else c.GGML_TYPE_Q4_K
            else
                c.GGML_TYPE_Q4_K,
            else => c.GGML_TYPE_Q3_K,
        },
        c.LLAMA_FTYPE_MOSTLY_Q2_K => switch (role) {
            .output, .attention_v, .attention_output => c.GGML_TYPE_Q3_K,
            else => c.GGML_TYPE_Q2_K,
        },
        else => c.GGML_TYPE_F16,
    };
}

fn applyShapeFallback(target: c.ggml_type, row_elems: u64) c.ggml_type {
    const block = c.ggml_blck_size(target);
    if (block <= 1 or row_elems % @as(u64, @intCast(block)) == 0) return target;

    const fallback: c.ggml_type = switch (target) {
        c.GGML_TYPE_Q2_K, c.GGML_TYPE_Q3_K => @intCast(c.GGML_TYPE_Q4_0),
        c.GGML_TYPE_Q4_K => @intCast(c.GGML_TYPE_Q5_0),
        c.GGML_TYPE_Q5_K => @intCast(c.GGML_TYPE_Q5_1),
        c.GGML_TYPE_Q6_K => @intCast(c.GGML_TYPE_Q8_0),
        else => @intCast(c.GGML_TYPE_F16),
    };
    const fallback_block = c.ggml_blck_size(fallback);
    if (fallback_block <= 1 or row_elems % @as(u64, @intCast(fallback_block)) == 0) return fallback;
    return c.GGML_TYPE_F16;
}

const TensorRole = enum {
    token_embd,
    output,
    attention_v,
    attention_output,
    attention_qkv,
    ffn_down,
    other,
};

fn classifyTensor(tensor_name: []const u8) TensorRole {
    if (std.mem.eql(u8, tensor_name, "token_embd.weight")) return .token_embd;
    if (std.mem.eql(u8, tensor_name, "output.weight")) return .output;
    if (std.mem.indexOf(u8, tensor_name, ".attn_v.") != null or
        std.mem.indexOf(u8, tensor_name, ".attn_v_b.") != null)
    {
        return .attention_v;
    }
    if (std.mem.indexOf(u8, tensor_name, ".attn_output.") != null) return .attention_output;
    if (std.mem.indexOf(u8, tensor_name, ".attn_qkv.") != null) return .attention_qkv;
    if (std.mem.indexOf(u8, tensor_name, ".ffn_down.") != null or
        std.mem.indexOf(u8, tensor_name, ".ffn_down_exps.") != null or
        std.mem.indexOf(u8, tensor_name, ".ffn_down_shexp.") != null)
    {
        return .ffn_down;
    }
    return .other;
}

fn parseLayerIndex(tensor_name: []const u8) ?u32 {
    const prefix = "blk.";
    if (!std.mem.startsWith(u8, tensor_name, prefix)) return null;
    const rest = tensor_name[prefix.len..];
    const dot = std.mem.indexOfScalar(u8, rest, '.') orelse return null;
    return std.fmt.parseInt(u32, rest[0..dot], 10) catch null;
}

fn useMoreBits(layer: u32, n_layers: u32) bool {
    if (n_layers == 0) return false;
    const first_band = max(1, n_layers / 8);
    const last_start = if (n_layers > first_band) n_layers - first_band else 0;
    return layer < first_band or layer >= last_start or
        (layer >= first_band and ((layer - first_band) % 3 == 2));
}

fn requiresF32OperatorWeight(tensor_name: []const u8) bool {
    return std.mem.indexOf(u8, tensor_name, ".shortconv.conv.") != null or
        std.mem.indexOf(u8, tensor_name, ".ssm_conv1d.") != null;
}

fn max(a: u32, b: u32) u32 {
    return if (a > b) a else b;
}

test "phase1 dtype parser rejects quantized formats" {
    try std.testing.expectError(error.UnsupportedDTypeInPhase1, parsePhase1DType("q4_k_m"));
}

test "load dtype parser accepts q_4km alias" {
    const parsed = try parseLoadDType("q_4km");
    try std.testing.expect(parsed == .quantized);
    try std.testing.expectEqual(c.LLAMA_FTYPE_MOSTLY_Q4_K_M, parsed.quantized);
}

test "load dtype parser accepts q_3km alias" {
    const parsed = try parseLoadDType("q_3km");
    try std.testing.expect(parsed == .quantized);
    try std.testing.expectEqual(c.LLAMA_FTYPE_MOSTLY_Q3_K_M, parsed.quantized);
}

test "resolveLoadDType keeps default plain dtype when no quant flag is set" {
    const parsed = try resolveLoadDType("f16", null);
    try std.testing.expect(parsed == .plain);
    try std.testing.expectEqual(Phase1DType.f16, parsed.plain);
}

test "resolveLoadDType uses explicit quant flag" {
    const parsed = try resolveLoadDType("f16", "q_4km");
    try std.testing.expect(parsed == .quantized);
    try std.testing.expectEqual(c.LLAMA_FTYPE_MOSTLY_Q4_K_M, parsed.quantized);
}

test "resolveLoadDType rejects quantized dtype without explicit quant flag" {
    try std.testing.expectError(error.QuantizationRequiresExplicitQuantFlag, resolveLoadDType("q_4km", null));
}

test "resolveLoadDType rejects plain dtype in quant flag" {
    try std.testing.expectError(error.QuantFlagRequiresQuantizedType, resolveLoadDType("f16", "f32"));
}

test "1d tensors stay f32 under quantized load" {
    const parsed = try parseLoadDType("q_4km");
    const ty = chooseTensorType(parsed, "blk.0.attn_norm.weight", &.{ 4096 }, 32);
    try std.testing.expectEqual(c.GGML_TYPE_F32, ty);
}

test "q4km promotes output tensor to q6_k" {
    const parsed = try parseLoadDType("q_4km");
    const ty = chooseTensorType(parsed, "output.weight", &.{ 4096, 32000 }, 32);
    try std.testing.expectEqual(c.GGML_TYPE_Q6_K, ty);
}

test "q3km promotes early ffn_down to q5_k" {
    const parsed = try parseLoadDType("q_3km");
    const ty = chooseTensorType(parsed, "blk.0.ffn_down.weight", &.{ 4096, 14336 }, 32);
    try std.testing.expectEqual(c.GGML_TYPE_Q5_K, ty);
}

test "incompatible q4_k shape falls back to f16" {
    const parsed = try parseLoadDType("q_4km");
    const ty = chooseTensorType(parsed, "blk.0.ffn_gate.weight", &.{ 4100, 14336 }, 32);
    try std.testing.expectEqual(c.GGML_TYPE_F16, ty);
}

test "shortconv weights stay f32 under plain f16 load" {
    const parsed = try parseLoadDType("f16");
    const ty = chooseTensorType(parsed, "blk.0.shortconv.conv.weight", &.{ 3, 1024 }, 16);
    try std.testing.expectEqual(c.GGML_TYPE_F32, ty);
}

test "ssm conv weights stay f32 under quantized load" {
    const parsed = try parseLoadDType("q_4km");
    const ty = chooseTensorType(parsed, "blk.0.ssm_conv1d.weight", &.{ 4, 2048 }, 32);
    try std.testing.expectEqual(c.GGML_TYPE_F32, ty);
}
