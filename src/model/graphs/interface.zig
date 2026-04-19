//! GraphBuilder interface: dispatch to the appropriate inference graph.
//! When a custom blueprint is loaded (via --arch), dispatches to custom ops.

const std = @import("std");
const c = @import("../../llama.zig").c;
const loader = @import("../loader.zig");
const custom = @import("custom.zig");

pub const GraphOps = struct {
    prefill: *const fn (*loader.ModelState, []const c.llama_token) anyerror!void,
    decodeOne: *const fn (*loader.ModelState, c.llama_token) anyerror!void,
    sample: *const fn (*loader.ModelState) c.llama_token,
    accept: *const fn (*loader.ModelState, c.llama_token) void,
};

/// Select GraphOps. Returns custom ops if a blueprint is loaded, else fallback.
pub fn select(arch_name: []const u8) GraphOps {
    _ = arch_name;
    if (custom.g_custom_graph != null) return custom.ops;
    return @import("fallback.zig").ops;
}
