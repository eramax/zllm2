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
    if (std.mem.eql(u8, dtype, "q4_k_m") or std.mem.eql(u8, dtype, "q_4km")) {
        return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q4_K_M };
    }
    if (std.mem.eql(u8, dtype, "q3_k_m") or std.mem.eql(u8, dtype, "q_3km")) {
        return .{ .quantized = c.LLAMA_FTYPE_MOSTLY_Q3_K_M };
    }
    return error.UnsupportedLoadDType;
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
