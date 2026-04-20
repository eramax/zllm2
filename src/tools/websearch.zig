const std = @import("std");
const http = @import("http.zig");

/// Search using DuckDuckGo Instant Answer API, falling back to Wikipedia search.
/// Caller owns the returned slice.
pub fn search(allocator: std.mem.Allocator, io: std.Io, query: []const u8) ![]const u8 {
    const encoded = try urlEncode(allocator, query);
    defer allocator.free(encoded);

    // ── 1. Try DuckDuckGo Instant Answer API ─────────────────────────
    const ddg_url = try std.fmt.allocPrint(
        allocator,
        "https://api.duckduckgo.com/?q={s}&format=json&no_html=1&skip_disambig=1",
        .{encoded},
    );
    defer allocator.free(ddg_url);

    const ddg_body = http.get(allocator, io, ddg_url, 256 * 1024) catch null;
    defer if (ddg_body) |b| allocator.free(b);

    if (ddg_body) |body| {
        const ddg_result = parseDdgResults(allocator, body) catch null;
        if (ddg_result) |r| {
            if (r.len > 0) return r;
            allocator.free(r);
        }
    }

    // ── 2. Try priv.au (SearXNG) ─────────────────────────────────────
    const searx_url = try std.fmt.allocPrint(
        allocator,
        "https://priv.au/search?q={s}&format=json&categories=general",
        .{encoded},
    );
    defer allocator.free(searx_url);

    const searx_body = http.get(allocator, io, searx_url, 512 * 1024) catch null;
    defer if (searx_body) |b| allocator.free(b);

    if (searx_body) |body| {
        const searx_result = parseSearxResults(allocator, body) catch null;
        if (searx_result) |r| {
            if (r.len > 0) return r;
            allocator.free(r);
        }
    }

    // ── 3. Fall back to Wikipedia search API ─────────────────────────
    const wiki_result = searchWikipedia(allocator, io, encoded) catch null;
    if (wiki_result) |r| return r;

    return try allocator.dupe(u8, "No results found. Try using the bash tool with curl to fetch specific URLs.");
}

fn searchWikipedia(allocator: std.mem.Allocator, io: std.Io, encoded_query: []const u8) ![]const u8 {
    // Step 1: find relevant article title
    const search_url = try std.fmt.allocPrint(
        allocator,
        "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={s}&srlimit=1&format=json",
        .{encoded_query},
    );
    defer allocator.free(search_url);

    const search_body = try http.get(allocator, io, search_url, 128 * 1024);
    defer allocator.free(search_body);

    const parsed = std.json.parseFromSlice(std.json.Value, allocator, search_body, .{}) catch
        return error.ParseFailed;
    defer parsed.deinit();

    const query_obj = parsed.value.object.get("query") orelse return error.NoResults;
    const results = query_obj.object.get("search") orelse return error.NoResults;
    if (results.array.items.len == 0) return error.NoResults;
    const first = results.array.items[0];
    const title = first.object.get("title") orelse return error.NoResults;
    if (title != .string) return error.NoResults;

    // Step 2: get article summary
    const title_encoded = try urlEncode(allocator, title.string);
    defer allocator.free(title_encoded);

    const summary_url = try std.fmt.allocPrint(
        allocator,
        "https://en.wikipedia.org/api/rest_v1/page/summary/{s}",
        .{title_encoded},
    );
    defer allocator.free(summary_url);

    const summary_body = try http.get(allocator, io, summary_url, 128 * 1024);
    defer allocator.free(summary_body);

    const summary_parsed = std.json.parseFromSlice(std.json.Value, allocator, summary_body, .{}) catch
        return error.ParseFailed;
    defer summary_parsed.deinit();

    const extract = summary_parsed.value.object.get("extract") orelse return error.NoResults;
    if (extract != .string or extract.string.len == 0) return error.NoResults;

    // Truncate to ~800 chars
    const max = 800;
    const text = if (extract.string.len > max) extract.string[0..max] else extract.string;
    const source_url = blk: {
        if (summary_parsed.value.object.get("content_urls")) |urls| {
            if (urls.object.get("desktop")) |desktop| {
                if (desktop.object.get("page")) |page| {
                    if (page == .string) break :blk page.string;
                }
            }
        }
        break :blk "";
    };

    if (source_url.len > 0) {
        return try std.fmt.allocPrint(allocator, "[Wikipedia: {s}]\n{s}...\nSource: {s}", .{ title.string, text, source_url });
    }
    return try std.fmt.allocPrint(allocator, "[Wikipedia: {s}]\n{s}...", .{ title.string, text });
}

fn parseSearxResults(allocator: std.mem.Allocator, body: []const u8) ![]const u8 {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, body, .{});
    defer parsed.deinit();

    const results = parsed.value.object.get("results") orelse return try allocator.dupe(u8, "");
    if (results != .array or results.array.items.len == 0) return try allocator.dupe(u8, "");

    var buf: std.ArrayList(u8) = .empty;
    errdefer buf.deinit(allocator);

    var count: usize = 0;
    for (results.array.items) |item| {
        if (count >= 5) break;
        if (item != .object) continue;

        const title = item.object.get("title");
        const content = item.object.get("content");
        const url = item.object.get("url");

        const has_title = title != null and title.? == .string and title.?.string.len > 0;
        const has_content = content != null and content.? == .string and content.?.string.len > 0;

        if (!has_title and !has_content) continue;

        if (count > 0) try buf.appendSlice(allocator, "\n");
        if (has_title) {
            try buf.print(allocator, "{s}\n", .{title.?.string});
        }
        if (has_content) {
            // Truncate long snippets
            const text = content.?.string;
            const max = 300;
            if (text.len > max) {
                try buf.print(allocator, "{s}...\n", .{text[0..max]});
            } else {
                try buf.print(allocator, "{s}\n", .{text});
            }
        }
        if (url != null and url.? == .string and url.?.string.len > 0) {
            try buf.print(allocator, "URL: {s}\n", .{url.?.string});
        }
        count += 1;
    }

    return buf.toOwnedSlice(allocator);
}

fn parseDdgResults(allocator: std.mem.Allocator, body: []const u8) ![]const u8 {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, body, .{});
    defer parsed.deinit();
    const root = parsed.value;

    var buf: std.ArrayList(u8) = .empty;
    errdefer buf.deinit(allocator);

    if (root.object.get("AbstractText")) |abstract| {
        if (abstract == .string and abstract.string.len > 0) {
            try buf.appendSlice(allocator, abstract.string);
            try buf.appendSlice(allocator, "\n\n");
            if (root.object.get("AbstractURL")) |url| {
                if (url == .string and url.string.len > 0) {
                    try buf.appendSlice(allocator, "Source: ");
                    try buf.appendSlice(allocator, url.string);
                    try buf.appendSlice(allocator, "\n\n");
                }
            }
        }
    }

    if (root.object.get("Answer")) |answer| {
        if (answer == .string and answer.string.len > 0) {
            try buf.appendSlice(allocator, "Answer: ");
            try buf.appendSlice(allocator, answer.string);
            try buf.appendSlice(allocator, "\n");
        }
    }

    if (root.object.get("Definition")) |def| {
        if (def == .string and def.string.len > 0) {
            try buf.appendSlice(allocator, def.string);
            try buf.appendSlice(allocator, "\n");
        }
    }

    if (root.object.get("RelatedTopics")) |topics| {
        if (topics == .array and topics.array.items.len > 0) {
            try buf.appendSlice(allocator, "Related:\n");
            var count: usize = 0;
            for (topics.array.items) |topic| {
                if (count >= 5) break;
                if (topic == .object) {
                    if (topic.object.get("Text")) |text| {
                        if (text == .string and text.string.len > 0) {
                            try buf.print(allocator, "  - {s}\n", .{text.string});
                            count += 1;
                        }
                    }
                }
            }
        }
    }

    return buf.toOwnedSlice(allocator);
}

fn urlEncode(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var buf: std.ArrayList(u8) = .empty;
    errdefer buf.deinit(allocator);

    for (input) |c| {
        switch (c) {
            'A'...'Z', 'a'...'z', '0'...'9', '-', '_', '.', '~' => {
                try buf.append(allocator, c);
            },
            ' ' => {
                try buf.appendSlice(allocator, "+");
            },
            else => {
                try buf.print(allocator, "%{X:0>2}", .{c});
            },
        }
    }
    return buf.toOwnedSlice(allocator);
}

test "urlEncode: basic" {
    const allocator = std.testing.allocator;
    const result = try urlEncode(allocator, "hello world");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("hello+world", result);
}

test "urlEncode: special chars" {
    const allocator = std.testing.allocator;
    const result = try urlEncode(allocator, "a&b=c");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("a%26b%3Dc", result);
}

test "parseDdgResults: empty json returns empty" {
    const allocator = std.testing.allocator;
    const result = try parseDdgResults(allocator, "{}");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("", result);
}

test "parseDdgResults: abstract extracted" {
    const allocator = std.testing.allocator;
    const json =
        \\{"AbstractText":"Zig is a language","AbstractURL":"https://ziglang.org","RelatedTopics":[]}
    ;
    const result = try parseDdgResults(allocator, json);
    defer allocator.free(result);
    try std.testing.expect(std.mem.indexOf(u8, result, "Zig is a language") != null);
}
