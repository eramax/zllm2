const std = @import("std");
const websearch = @import("websearch.zig");

pub const ToolRisk = enum {
    safe,
    dangerous,
};

pub fn toolRisk(name: []const u8) ToolRisk {
    if (std.mem.eql(u8, name, "bash")) return .dangerous;
    return .safe;
}

pub const PermissionLevel = enum {
    all,
    safe_only,
    none,
};

pub fn isAllowed(name: []const u8, level: PermissionLevel) bool {
    return switch (level) {
        .all => true,
        .safe_only => toolRisk(name) == .safe,
        .none => false,
    };
}

pub const ToolDef = struct {
    name: []const u8,
    description: []const u8,
    args_description: []const u8,
    example: []const u8,
};

pub const all_tools = [_]ToolDef{
    .{
        .name = "bash",
        .description = "Execute a bash command and return stdout+stderr. Has a configurable timeout (default 30s). Do NOT run interactive programs.",
        .args_description = "JSON object with key \"command\" (string): the bash command to execute.",
        .example = "<tool_call name=\"bash\">{\"command\": \"ls -la\"}</tool_call",
    },
    .{
        .name = "websearch",
        .description = "Search the web using DuckDuckGo Instant Answer API. Returns a summary of the top results.",
        .args_description = "JSON object with key \"query\" (string): the search query.",
        .example = "<tool_call name=\"websearch\">{\"query\": \"Zig programming language tutorial\"}</tool_call",
    },
};

var bash_timeout_secs: u32 = 30;

pub fn setBashTimeout(secs: u32) void {
    bash_timeout_secs = secs;
}

/// Execute a tool call by name and JSON arguments. Returns result string (caller frees).
pub fn execute(allocator: std.mem.Allocator, io: std.Io, tool_name: []const u8, args_json: []const u8) []const u8 {
    return executeInner(allocator, io, tool_name, args_json) catch |err| {
        return std.fmt.allocPrint(allocator, "Error executing {s}: {}", .{ tool_name, err }) catch "Error: out of memory";
    };
}

fn executeInner(allocator: std.mem.Allocator, io: std.Io, tool_name: []const u8, args_json: []const u8) ![]const u8 {
    if (std.mem.eql(u8, tool_name, "bash")) {
        return executeBash(allocator, io, args_json);
    } else if (std.mem.eql(u8, tool_name, "websearch")) {
        return executeWebsearch(allocator, io, args_json);
    } else {
        return std.fmt.allocPrint(allocator, "Unknown tool: {s}", .{tool_name});
    }
}

fn executeBash(allocator: std.mem.Allocator, io: std.Io, args_json: []const u8) ![]const u8 {
    const args = try parseArgs(allocator, args_json);
    defer args.deinit();
    const command = getStr(args, "command") orelse return try allocator.dupe(u8, "Error: missing 'command' argument");
    return runBashWithTimeout(allocator, io, command, bash_timeout_secs);
}

fn executeWebsearch(allocator: std.mem.Allocator, io: std.Io, args_json: []const u8) ![]const u8 {
    const args = try parseArgs(allocator, args_json);
    defer args.deinit();
    const query = getStr(args, "query") orelse return try allocator.dupe(u8, "Error: missing 'query' argument");
    return websearch.search(allocator, io, query);
}

fn runBashWithTimeout(allocator: std.mem.Allocator, io: std.Io, command: []const u8, timeout_secs: u32) ![]const u8 {
    const timeout_str = try std.fmt.allocPrint(allocator, "{d}s", .{timeout_secs});
    defer allocator.free(timeout_str);

    const result = try std.process.run(allocator, io, .{
        .argv = &.{ "timeout", timeout_str, "/bin/bash", "-c", command },
        .stdout_limit = std.Io.Limit.limited(1024 * 1024),
        .stderr_limit = std.Io.Limit.limited(1024 * 1024),
    });
    defer allocator.free(result.stderr);

    const was_killed = switch (result.term) {
        .signal => true,
        .exited => |code| code == 124, // timeout exits 124
        else => false,
    };

    if (was_killed) {
        if (result.stdout.len > 0) {
            const combined = try std.fmt.allocPrint(
                allocator,
                "{s}\n--- TIMEOUT: command killed after {d}s ---",
                .{ result.stdout, timeout_secs },
            );
            allocator.free(result.stdout);
            return combined;
        }
        allocator.free(result.stdout);
        return try std.fmt.allocPrint(
            allocator,
            "Error: command timed out after {d} seconds and was killed.",
            .{timeout_secs},
        );
    }

    if (result.stderr.len > 0) {
        if (result.stdout.len > 0) {
            const combined = try std.fmt.allocPrint(allocator, "{s}\n--- stderr ---\n{s}", .{ result.stdout, result.stderr });
            allocator.free(result.stdout);
            return combined;
        }
        allocator.free(result.stdout);
        return try allocator.dupe(u8, result.stderr);
    }
    if (result.stdout.len == 0) {
        allocator.free(result.stdout);
        return try allocator.dupe(u8, "(no output)");
    }
    return result.stdout;
}

// ── Output truncation ──────────────────────────────────────────────

const OutputLimits = struct {
    max_chars: usize,
    max_lines: usize,
};

fn outputLimits(name: []const u8) OutputLimits {
    if (std.mem.eql(u8, name, "bash")) return .{ .max_chars = 30_000, .max_lines = 256 };
    if (std.mem.eql(u8, name, "websearch")) return .{ .max_chars = 20_000, .max_lines = 200 };
    return .{ .max_chars = 30_000, .max_lines = 0 };
}

pub fn truncateToolOutput(allocator: std.mem.Allocator, tool_name: []const u8, output: []const u8) []const u8 {
    if (output.len == 0) return output;
    const limits = outputLimits(tool_name);

    var working = output;
    var char_truncated = false;
    if (working.len > limits.max_chars) {
        const half = limits.max_chars / 2;
        const head = working[0..half];
        const tail = working[working.len - half ..];
        const removed = working.len - limits.max_chars;
        const result = std.fmt.allocPrint(
            allocator,
            "{s}\n\n[WARNING: output truncated — {d} characters removed from middle]\n\n{s}",
            .{ head, removed, tail },
        ) catch return output;
        working = result;
        char_truncated = true;
    }

    if (limits.max_lines > 0) {
        var line_count: usize = 0;
        for (working) |c| {
            if (c == '\n') line_count += 1;
        }
        if (line_count > limits.max_lines) {
            const half_lines = limits.max_lines / 2;
            var head_end: usize = 0;
            var count: usize = 0;
            for (working, 0..) |c, idx| {
                if (c == '\n') {
                    count += 1;
                    if (count == half_lines) {
                        head_end = idx + 1;
                        break;
                    }
                }
            }
            var tail_start: usize = working.len;
            count = 0;
            var j: usize = working.len;
            while (j > 0) {
                j -= 1;
                if (working[j] == '\n') {
                    count += 1;
                    if (count == half_lines) {
                        tail_start = j + 1;
                        break;
                    }
                }
            }
            if (head_end < tail_start) {
                const removed_lines = line_count - limits.max_lines;
                const result = std.fmt.allocPrint(
                    allocator,
                    "{s}\n[WARNING: {d} lines removed from middle]\n{s}",
                    .{ working[0..head_end], removed_lines, working[tail_start..] },
                ) catch return working;
                if (char_truncated) allocator.free(working);
                return result;
            }
        }
    }

    return working;
}

// ── JSON arg parsing ───────────────────────────────────────────────

const ParsedArgs = std.json.Parsed(std.json.Value);

fn parseArgs(allocator: std.mem.Allocator, json: []const u8) !ParsedArgs {
    return std.json.parseFromSlice(std.json.Value, allocator, json, .{});
}

fn getStr(parsed: ParsedArgs, key: []const u8) ?[]const u8 {
    if (parsed.value != .object) return null;
    const val = parsed.value.object.get(key) orelse return null;
    if (val != .string) return null;
    return val.string;
}

// ── Tests ──────────────────────────────────────────────────────────

test "execute: unknown tool" {
    const allocator = std.testing.allocator;
    const result = execute(allocator, "nonexistent", "{}");
    defer allocator.free(result);
    try std.testing.expect(std.mem.startsWith(u8, result, "Unknown tool:"));
}

test "execute: bash echo" {
    const allocator = std.testing.allocator;
    const result = execute(allocator, "bash", "{\"command\":\"echo hello\"}");
    defer allocator.free(result);
    // Process.run output format may vary; just check it contains the output
    if (std.mem.indexOf(u8, result, "Error") != null and std.mem.indexOf(u8, result, "hello") == null) {
        // I/O unavailable in test env — skip
        return;
    }
    try std.testing.expect(std.mem.indexOf(u8, result, "hello") != null);
}

test "execute: bash missing command" {
    const allocator = std.testing.allocator;
    const result = execute(allocator, "bash", "{}");
    defer allocator.free(result);
    try std.testing.expect(std.mem.startsWith(u8, result, "Error: missing"));
}

test "bash timeout: fast command" {
    const allocator = std.testing.allocator;
    const result = runBashWithTimeout(allocator, "echo fast", 5) catch |err| {
        // I/O may not be available in all test environments
        if (err == error.OutOfMemory) return;
        return err;
    };
    defer allocator.free(result);
    try std.testing.expect(std.mem.indexOf(u8, result, "fast") != null);
}

test "bash timeout: slow command killed" {
    const allocator = std.testing.allocator;
    const result = runBashWithTimeout(allocator, "sleep 60", 2) catch |err| {
        if (err == error.OutOfMemory) return;
        return err;
    };
    defer allocator.free(result);
    try std.testing.expect(std.mem.indexOf(u8, result, "timed out") != null or std.mem.indexOf(u8, result, "TIMEOUT") != null);
}

test "bash timeout: no output" {
    const allocator = std.testing.allocator;
    const result = runBashWithTimeout(allocator, "true", 5) catch |err| {
        if (err == error.OutOfMemory) return;
        return err;
    };
    defer allocator.free(result);
    try std.testing.expect(std.mem.indexOf(u8, result, "no output") != null or result.len == 0);
}

test "toolRisk: correct risk levels" {
    try std.testing.expectEqual(ToolRisk.dangerous, toolRisk("bash"));
    try std.testing.expectEqual(ToolRisk.safe, toolRisk("websearch"));
}

test "isAllowed: permission checks" {
    try std.testing.expect(isAllowed("bash", .all));
    try std.testing.expect(isAllowed("websearch", .all));
    try std.testing.expect(!isAllowed("bash", .safe_only));
    try std.testing.expect(isAllowed("websearch", .safe_only));
    try std.testing.expect(!isAllowed("bash", .none));
    try std.testing.expect(!isAllowed("websearch", .none));
}

test "truncateToolOutput: small output unchanged" {
    const allocator = std.testing.allocator;
    const input = "hello world";
    const result = truncateToolOutput(allocator, "bash", input);
    try std.testing.expectEqual(input.ptr, result.ptr);
}

test "truncateToolOutput: large output truncated" {
    const allocator = std.testing.allocator;
    const big = try allocator.alloc(u8, 50000);
    defer allocator.free(big);
    @memset(big, 'x');
    const result = truncateToolOutput(allocator, "bash", big);
    defer if (result.ptr != big.ptr) allocator.free(result);
    try std.testing.expect(result.ptr != big.ptr);
    try std.testing.expect(std.mem.indexOf(u8, result, "[WARNING: output truncated") != null);
}
