const std = @import("std");

pub const Phase1DType = enum {
    f16,
    f32,
};

pub fn parsePhase1DType(dtype: []const u8) !Phase1DType {
    if (std.mem.eql(u8, dtype, "f16")) return .f16;
    if (std.mem.eql(u8, dtype, "f32")) return .f32;
    return error.UnsupportedDTypeInPhase1;
}

test "phase1 dtype parser rejects quantized formats" {
    try std.testing.expectError(error.UnsupportedDTypeInPhase1, parsePhase1DType("q4_k_m"));
}

