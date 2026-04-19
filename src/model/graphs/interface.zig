//! GraphBuilder interface: dispatch to the appropriate inference graph per architecture.

const std = @import("std");
const c = @import("../../llama.zig").c;
const loader = @import("../loader.zig");

pub const GraphOps = struct {
    prefill: *const fn (*loader.ModelState, []const c.llama_token) anyerror!void,
    decodeOne: *const fn (*loader.ModelState, c.llama_token) anyerror!void,
    sample: *const fn (*loader.ModelState) c.llama_token,
    accept: *const fn (*loader.ModelState, c.llama_token) void,
};

/// Select the GraphOps for the given architecture name.
/// Returns the fallback (llama_decode) for all architectures.
/// Custom graph builders register here when implemented.
pub fn select(arch_name: []const u8) GraphOps {
    _ = arch_name;
    return @import("fallback.zig").ops;
}
