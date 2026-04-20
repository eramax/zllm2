const std = @import("std");

pub const Config = struct {
    model: []const u8 = "",
    dtype: []const u8 = "f16",
    ctx: u32 = 32768,
    gen: i32 = -1,
    temp: f64 = 0.7,
    top_p: f64 = 0.9,
    top_k: i32 = 40,
    repeat_penalty: f64 = 1.1,
    flash_attn: bool = true,
    kv_type: []const u8 = "f16",
    sliding_window: ?u32 = null,
    offload: i32 = -1,
    threads: u32 = 8,

    moe_expert_dtype: ?[]const u8 = null,
    moe_experts_offload: bool = false,
    moe_experts_on_gpu: i32 = -1,

    draft: ?[]const u8 = null,
    dflash: bool = false,
    dflash_budget: u32 = 22,
    draft_dtype: []const u8 = "bf16",

    serve: bool = false,
    serve_port: u16 = 8080,
    system_prompt: []const u8 = "You are a helpful assistant.",
    tools: []const []const u8 = &.{},
    save_on_load: ?[]const u8 = null,
    arch_override: ?[]const u8 = null,
    bench: ?[]const u8 = null,
    prompt: ?[]const u8 = null,
};

pub fn parseFromFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8) !Config {
    const contents = try std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(1 << 20));
    defer allocator.free(contents);
    return parseFromString(allocator, contents);
}

pub fn parseFromString(allocator: std.mem.Allocator, json_str: []const u8) !Config {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_str, .{});
    defer parsed.deinit();
    const root = parsed.value;

    var cfg = Config{};

    if (root.object.get("model")) |v| cfg.model = try allocator.dupe(u8, v.string);
    if (root.object.get("dtype")) |v| cfg.dtype = try allocator.dupe(u8, v.string);
    if (root.object.get("ctx")) |v| cfg.ctx = @intCast(v.integer);
    if (root.object.get("gen")) |v| cfg.gen = @intCast(v.integer);
    if (root.object.get("temp")) |v| cfg.temp = v.float;
    if (root.object.get("top_p")) |v| cfg.top_p = v.float;
    if (root.object.get("top_k")) |v| cfg.top_k = @intCast(v.integer);
    if (root.object.get("repeat_penalty")) |v| cfg.repeat_penalty = v.float;
    if (root.object.get("flash_attn")) |v| cfg.flash_attn = v.bool;
    if (root.object.get("kv_type")) |v| cfg.kv_type = try allocator.dupe(u8, v.string);
    if (root.object.get("offload")) |v| cfg.offload = @intCast(v.integer);
    if (root.object.get("threads")) |v| cfg.threads = @intCast(v.integer);
    if (root.object.get("serve")) |v| cfg.serve = v.bool;
    if (root.object.get("serve_port")) |v| cfg.serve_port = @intCast(v.integer);
    if (root.object.get("system_prompt")) |v| cfg.system_prompt = try allocator.dupe(u8, v.string);
    if (root.object.get("dflash")) |v| cfg.dflash = v.bool;
    if (root.object.get("dflash_budget")) |v| cfg.dflash_budget = @intCast(v.integer);
    if (root.object.get("draft_dtype")) |v| cfg.draft_dtype = try allocator.dupe(u8, v.string);
    if (root.object.get("moe_experts_offload")) |v| cfg.moe_experts_offload = v.bool;
    if (root.object.get("moe_experts_on_gpu")) |v| cfg.moe_experts_on_gpu = @intCast(v.integer);
    if (root.object.get("save_on_load")) |v| cfg.save_on_load = try allocator.dupe(u8, v.string);
    if (root.object.get("arch_override")) |v| cfg.arch_override = try allocator.dupe(u8, v.string);
    if (root.object.get("bench")) |v| cfg.bench = try allocator.dupe(u8, v.string);

    if (root.object.get("sliding_window")) |v| {
        if (v != .null) cfg.sliding_window = @intCast(v.integer);
    }
    if (root.object.get("moe_expert_dtype")) |v| {
        if (v != .null) cfg.moe_expert_dtype = try allocator.dupe(u8, v.string);
    }
    if (root.object.get("draft")) |v| {
        if (v != .null) cfg.draft = try allocator.dupe(u8, v.string);
    }
    if (root.object.get("prompt")) |v| {
        if (v != .null) cfg.prompt = try allocator.dupe(u8, v.string);
    }
    if (root.object.get("tools")) |v| {
        var tools = std.ArrayList([]const u8).empty;
        for (v.array.items) |item| {
            try tools.append(allocator, try allocator.dupe(u8, item.string));
        }
        cfg.tools = try tools.toOwnedSlice(allocator);
    }

    return cfg;
}
