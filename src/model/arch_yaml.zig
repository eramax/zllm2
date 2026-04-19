//! Serialize GGUF model metadata to YAML; parse dotted-key overrides.

const std = @import("std");
const c = @import("../llama.zig").c;

/// Serialize all model metadata to a YAML string.
pub fn serialize(allocator: std.mem.Allocator, model: *const c.llama_model) ![]u8 {
    const n_kv = c.llama_model_meta_count(model);
    if (n_kv <= 0) return allocator.dupe(u8, "# no metadata\n");

    // Collect all key-value pairs
    const KvEntry = struct { key: []const u8, val: []const u8 };
    var entries = std.ArrayList(KvEntry).empty;
    defer {
        for (entries.items) |e| {
            allocator.free(e.key);
            allocator.free(e.val);
        }
        entries.deinit(allocator);
    }

    var key_buf: [512]u8 = undefined;
    var val_buf: [512]u8 = undefined;
    var i: i32 = 0;
    while (i < n_kv) : (i += 1) {
        const kn = c.llama_model_meta_key_by_index(model, i, &key_buf, key_buf.len);
        const vn = c.llama_model_meta_val_str_by_index(model, i, &val_buf, val_buf.len);
        if (kn > 0 and vn >= 0) {
            const key = try allocator.dupe(u8, key_buf[0..@intCast(kn)]);
            errdefer allocator.free(key);
            const val_len = @min(@as(usize, @intCast(vn)), val_buf.len);
            const val = try allocator.dupe(u8, val_buf[0..val_len]);
            errdefer allocator.free(val);
            try entries.append(allocator, .{ .key = key, .val = val });
        }
    }

    // Sort by key for deterministic output
    std.mem.sort(KvEntry, entries.items, {}, struct {
        fn lessThan(_: void, a: KvEntry, b: KvEntry) bool {
            return std.mem.lessThan(u8, a.key, b.key);
        }
    }.lessThan);

    // Group by first segment of dotted key into nested YAML
    var out = std.ArrayList(u8).empty;
    errdefer out.deinit(allocator);

    var current_prefix: ?[]const u8 = null;
    for (entries.items) |entry| {
        // Skip tokenizer array entries (huge, not useful for arch editing)
        if (std.mem.startsWith(u8, entry.key, "tokenizer.ggml.tokens") or
            std.mem.startsWith(u8, entry.key, "tokenizer.ggml.scores") or
            std.mem.startsWith(u8, entry.key, "tokenizer.ggml.token_type") or
            std.mem.startsWith(u8, entry.key, "tokenizer.ggml.merges"))
            continue;

        const dot_pos = std.mem.indexOfScalar(u8, entry.key, '.');
        const prefix = if (dot_pos) |dp| entry.key[0..dp] else null;

        if (prefix == null or (current_prefix != null and !std.mem.eql(u8, prefix.?, current_prefix.?))) {
            if (current_prefix != null) {
                try out.appendSlice(allocator, "\n");
            }
        }

        if (dot_pos) |dp| {
            const rest = entry.key[dp + 1 ..];
            const dot2 = std.mem.indexOfScalar(u8, rest, '.');
            if (dot2) |d2| {
                const sub = rest[0..d2];
                const leaf = rest[d2 + 1 ..];
                var tmp: [2048]u8 = undefined;
                const line = std.fmt.bufPrint(&tmp, "{s}.{s}.{s}: {s}\n", .{ entry.key[0..dp], sub, leaf, entry.val }) catch continue;
                try out.appendSlice(allocator, line);
            } else {
                var tmp: [2048]u8 = undefined;
                const line = std.fmt.bufPrint(&tmp, "{s}.{s}: {s}\n", .{ entry.key[0..dp], rest, entry.val }) catch continue;
                try out.appendSlice(allocator, line);
            }
        } else {
            var tmp: [2048]u8 = undefined;
            const line = std.fmt.bufPrint(&tmp, "{s}: {s}\n", .{ entry.key, entry.val }) catch continue;
            try out.appendSlice(allocator, line);
        }
        current_prefix = prefix;
    }

    return out.toOwnedSlice(allocator);
}

/// Parse a simple dotted-key YAML text into a flat key→value map.
/// Only handles `key: value` and `key.subkey: value` lines.
/// Comments (#) and blank lines are skipped.
pub fn parseOverrides(allocator: std.mem.Allocator, text: []const u8) !std.StringHashMap([]const u8) {
    var map = std.StringHashMap([]const u8).init(allocator);
    errdefer {
        var it = map.iterator();
        while (it.next()) |e| allocator.free(e.key_ptr.*);
        map.deinit();
    }

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        // Find "key: value"
        const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse continue;
        const key = std.mem.trim(u8, trimmed[0..colon], " \t");
        const val = std.mem.trim(u8, trimmed[colon + 1 ..], " \t");
        if (key.len == 0) continue;

        const key_copy = try allocator.dupe(u8, key);
        // We store the value as a slice into the original text — no need to dupe
        map.put(key_copy, val) catch {
            allocator.free(key_copy);
        };
    }

    return map;
}
