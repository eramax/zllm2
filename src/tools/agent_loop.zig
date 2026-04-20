const std = @import("std");
const executor = @import("executor.zig");

pub const LOOP_DETECTION_WINDOW = 10;
pub const MAX_ITERATIONS = 25;

/// Trim a string to just the JSON object part (first '{' to last '}').
/// If no braces found, returns the original slice.
fn extractJson(s: []const u8) []const u8 {
    const start = std.mem.indexOfScalar(u8, s, '{') orelse return s;
    var depth: usize = 0;
    var last_close: usize = s.len;
    for (s[start..], start..) |c, i| {
        if (c == '{') depth += 1;
        if (c == '}') {
            if (depth > 0) depth -= 1;
            last_close = i + 1;
            if (depth == 0) break;
        }
    }
    return std.mem.trim(u8, s[start..last_close], " \t\n\r");
}

/// A parsed tool call extracted from model output.
pub const ParsedToolCall = struct {
    name: []const u8,
    arguments: []const u8,
};

/// Parse <tool_call name="...">...</tool_call tags from model output.
/// Returns a list of parsed tool calls. The name and arguments slices point into `text`.
pub fn parseToolCalls(allocator: std.mem.Allocator, text: []const u8) ![]ParsedToolCall {
    var calls: std.ArrayList(ParsedToolCall) = .empty;
    errdefer calls.deinit(allocator);

    var pos: usize = 0;
    while (pos < text.len) {
        // Find next <tool_call
        const open_tag = "<tool_call";
        const start = std.mem.indexOfPos(u8, text, pos, open_tag) orelse break;

        // Extract name="..." attribute
        const name_start = std.mem.indexOfPos(u8, text, start, "name=\"") orelse {
            pos = start + open_tag.len;
            continue;
        };
        const name_val_start = name_start + 6; // skip 'name="'
        const name_end = std.mem.indexOfPos(u8, text, name_val_start, "\"") orelse {
            pos = start + open_tag.len;
            continue;
        };
        const name = text[name_val_start..name_end];

        // Find closing > of opening tag
        const tag_close = std.mem.indexOfPos(u8, text, name_end, ">") orelse {
            pos = start + open_tag.len;
            continue;
        };

        // Find closing tag — accept </tool_call or </tool_result (model confusion), or end-of-string
        const args_start = tag_close + 1;
        const end1 = std.mem.indexOfPos(u8, text, args_start, "</tool_call");
        const end2 = std.mem.indexOfPos(u8, text, args_start, "</tool_result");
        const args_end = if (end1 != null and end2 != null)
            @min(end1.?, end2.?)
        else
            end1 orelse end2 orelse text.len;
        const close_len: usize = if (args_end < text.len)
            if (text[args_end..].len >= "</tool_result".len and
                std.mem.startsWith(u8, text[args_end..], "</tool_result"))
                "</tool_result".len
            else
                "</tool_call".len
        else
            0;

        // Strip trailing non-JSON content from arguments (e.g. stray newlines before closing tag)
        const raw_args = std.mem.trim(u8, text[args_start..args_end], " \t\n\r");
        // Find the outermost JSON object or string boundary
        const args = extractJson(raw_args);

        try calls.append(allocator, .{
            .name = name,
            .arguments = args,
        });

        pos = if (args_end < text.len) args_end + close_len else text.len;
    }

    return calls.toOwnedSlice(allocator);
}

/// Strip tool_call XML tags from text, leaving only the non-tool content.
/// Returns a new allocated slice.
pub fn stripToolCalls(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    errdefer buf.deinit(allocator);

    var pos: usize = 0;
    while (pos < text.len) {
        const open_tag = "<tool_call";
        const start = std.mem.indexOfPos(u8, text, pos, open_tag) orelse {
            // Rest of text is plain content
            try buf.appendSlice(allocator, text[pos..]);
            break;
        };

        // Write content before this tool call
        if (start > pos) {
            try buf.appendSlice(allocator, text[pos..start]);
        }

        // Skip past the closing tag
        const close_tag = "</tool_call";
        const close_pos = std.mem.indexOfPos(u8, text, start, close_tag) orelse {
            // Malformed — skip rest
            break;
        };
        pos = close_pos + close_tag.len;

        // Skip past trailing > if present
        if (pos < text.len and text[pos] == '>') pos += 1;
    }

    const result = try buf.toOwnedSlice(allocator);
    // Trim trailing whitespace
    const trimmed = std.mem.trim(u8, result, " \t\n\r");
    if (trimmed.len == 0) {
        allocator.free(result);
        return try allocator.dupe(u8, "");
    }
    // If trimming changed things, realloc
    if (trimmed.len < result.len) {
        const final = try allocator.dupe(u8, trimmed);
        allocator.free(result);
        return final;
    }
    return result;
}

/// Format tool schemas as a system prompt section to inject into the conversation.
/// Returns a string suitable for appending to the system prompt.
pub fn formatToolPrompt(allocator: std.mem.Allocator, enabled_tools: []const []const u8) ![]const u8 {
    if (enabled_tools.len == 0) return try allocator.dupe(u8, "");

    var buf: std.ArrayList(u8) = .empty;
    errdefer buf.deinit(allocator);

    try buf.appendSlice(allocator,
        \\
        \\You have access to the following tools. To use a tool, output a <tool_call name="toolname">JSON args</tool_call tag exactly as shown. You will receive the result in the conversation. You may make multiple tool calls in one response.
        \\
        \\Available tools:
        \\
    );

    for (enabled_tools) |tool_name| {
        for (&executor.all_tools) |*tool| {
            if (std.mem.eql(u8, tool.name, tool_name)) {
                try buf.print(allocator, "- {s}: {s}\n", .{ tool.name, tool.description });
                try buf.print(allocator, "  Args: {s}\n", .{tool.args_description});
                try buf.print(allocator, "  Example: {s}\n\n", .{tool.example});
                break;
            }
        }
    }

    try buf.appendSlice(allocator,
        \\After receiving a <tool_result> tag, use the information to continue your response. You can call tools multiple times if needed.
        \\
    );

    return buf.toOwnedSlice(allocator);
}

/// Hash a tool call signature for loop detection.
pub fn hashToolSignature(name: []const u8, args: []const u8) u64 {
    var hasher = std.hash.Wyhash.init(0);
    hasher.update(name);
    hasher.update("|");
    hasher.update(args);
    return hasher.final();
}

/// Detect repeating patterns in tool call hashes.
pub fn detectLoop(ring: []const u64, count: usize) bool {
    const window = @min(count, LOOP_DETECTION_WINDOW);
    if (window < 4) return false;

    const ring_len = ring.len;

    var recent: [LOOP_DETECTION_WINDOW]u64 = undefined;
    var i: usize = 0;
    while (i < window) : (i += 1) {
        const idx = (count - window + i) % ring_len;
        recent[i] = ring[idx];
    }

    for ([_]usize{ 1, 2, 3 }) |pattern_len| {
        if (window % pattern_len != 0) continue;
        if (window / pattern_len < 2) continue;

        const pattern = recent[0..pattern_len];
        var all_match = true;
        var chunk: usize = pattern_len;
        while (chunk < window) : (chunk += pattern_len) {
            for (0..pattern_len) |k| {
                if (recent[chunk + k] != pattern[k]) {
                    all_match = false;
                    break;
                }
            }
            if (!all_match) break;
        }
        if (all_match) return true;
    }
    return false;
}

// ── Tests ──────────────────────────────────────────────────────────

test "parseToolCalls: single bash call" {
    const allocator = std.testing.allocator;
    const text = "I'll check the files.\n<tool_call name=\"bash\">{\"command\": \"ls\"}</tool_call\nDone.";
    const calls = try parseToolCalls(allocator, text);
    defer allocator.free(calls);
    try std.testing.expectEqual(@as(usize, 1), calls.len);
    try std.testing.expectEqualStrings("bash", calls[0].name);
    try std.testing.expectEqualStrings("{\"command\": \"ls\"}", calls[0].arguments);
}

test "parseToolCalls: multiple calls" {
    const allocator = std.testing.allocator;
    const text =
        \\<tool_call name="bash">{"command": "ls"}</tool_call
        \\<tool_call name="websearch">{"query": "zig lang"}</tool_call
    ;
    const calls = try parseToolCalls(allocator, text);
    defer allocator.free(calls);
    try std.testing.expectEqual(@as(usize, 2), calls.len);
    try std.testing.expectEqualStrings("bash", calls[0].name);
    try std.testing.expectEqualStrings("websearch", calls[1].name);
}

test "parseToolCalls: no calls" {
    const allocator = std.testing.allocator;
    const text = "Just a regular response with no tool calls.";
    const calls = try parseToolCalls(allocator, text);
    defer allocator.free(calls);
    try std.testing.expectEqual(@as(usize, 0), calls.len);
}

test "parseToolCalls: malformed tag skipped" {
    const allocator = std.testing.allocator;
    const text = "<tool_call broken<tool_call name=\"bash\">{\"command\": \"echo\"}</tool_call";
    const calls = try parseToolCalls(allocator, text);
    defer allocator.free(calls);
    try std.testing.expectEqual(@as(usize, 1), calls.len);
}

test "stripToolCalls: removes tags" {
    const allocator = std.testing.allocator;
    const text = "Before<tool_call name=\"bash\">{\"command\": \"ls\"}</tool_callAfter";
    const stripped = try stripToolCalls(allocator, text);
    defer allocator.free(stripped);
    try std.testing.expectEqualStrings("BeforeAfter", stripped);
}

test "stripToolCalls: no tags" {
    const allocator = std.testing.allocator;
    const text = "Just text";
    const stripped = try stripToolCalls(allocator, text);
    defer allocator.free(stripped);
    try std.testing.expectEqualStrings("Just text", stripped);
}

test "formatToolPrompt: generates prompt section" {
    const allocator = std.testing.allocator;
    const tools = &[_][]const u8{ "bash", "websearch" };
    const prompt = try formatToolPrompt(allocator, tools);
    defer allocator.free(prompt);
    try std.testing.expect(std.mem.indexOf(u8, prompt, "bash") != null);
    try std.testing.expect(std.mem.indexOf(u8, prompt, "websearch") != null);
    try std.testing.expect(std.mem.indexOf(u8, prompt, "<tool_call") != null);
}

test "formatToolPrompt: empty tools" {
    const allocator = std.testing.allocator;
    const tools = &[_][]const u8{};
    const prompt = try formatToolPrompt(allocator, tools);
    defer allocator.free(prompt);
    try std.testing.expectEqualStrings("", prompt);
}

test "detectLoop: no loop with few calls" {
    var ring: [LOOP_DETECTION_WINDOW]u64 = undefined;
    @memset(&ring, 0);
    try std.testing.expect(!detectLoop(&ring, 0));
    try std.testing.expect(!detectLoop(&ring, 3));
}

test "detectLoop: detects repeating pattern" {
    var ring: [LOOP_DETECTION_WINDOW]u64 = undefined;
    @memset(&ring, 42);
    try std.testing.expect(detectLoop(&ring, 10));
}

test "detectLoop: varied calls no loop" {
    var ring: [LOOP_DETECTION_WINDOW]u64 = undefined;
    var i: usize = 0;
    while (i < LOOP_DETECTION_WINDOW) : (i += 1) {
        ring[i] = i * 7 + 13;
    }
    try std.testing.expect(!detectLoop(&ring, 10));
}

test "hashToolSignature: deterministic" {
    const h1 = hashToolSignature("bash", "{\"command\":\"ls\"}");
    const h2 = hashToolSignature("bash", "{\"command\":\"ls\"}");
    const h3 = hashToolSignature("bash", "{\"command\":\"pwd\"}");
    try std.testing.expectEqual(h1, h2);
    try std.testing.expect(h1 != h3);
}
