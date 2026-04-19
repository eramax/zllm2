//! ANSI markdown renderer for terminal output.
//! Supports: **bold**, *italic*, `inline code`, # headers,
//!           ``` code blocks ```, - bullet lists, > blockquotes.

const std = @import("std");
const term = @import("terminal.zig");

pub const RenderBuf = term.RenderBuf;

/// Render markdown text to a RenderBuf, using ANSI escapes for styling.
pub fn render(buf: *RenderBuf, text: []const u8, max_col: u16) !void {
    var lines = std.mem.splitScalar(u8, text, '\n');
    var in_code_block = false;

    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "```")) {
            if (in_code_block) {
                // End code block
                try buf.append(term.FG_BRIGHT_BLACK);
                try buf.append("└");
                var i: u16 = 1;
                while (i < max_col - 2) : (i += 1) try buf.append("─");
                try buf.append("┘");
                try buf.append(term.RESET);
                try buf.append("\r\n");
                in_code_block = false;
            } else {
                // Start code block (language hint in line[3..] is informational)
                try buf.append(term.FG_BRIGHT_BLACK);
                try buf.append("┌");
                var i: u16 = 1;
                while (i < max_col - 2) : (i += 1) try buf.append("─");
                try buf.append("┐");
                try buf.append(term.RESET);
                try buf.append("\r\n");
                in_code_block = true;
            }
            continue;
        }

        if (in_code_block) {
            try buf.append(term.FG_BRIGHT_BLACK);
            try buf.append("│ ");
            try buf.append(term.RESET);
            try buf.append(term.FG_BRIGHT_CYAN);
            try renderCodeLine(buf, line);
            try buf.append(term.RESET);
            try buf.append("\r\n");
            continue;
        }

        // Blank line
        if (line.len == 0 or std.mem.eql(u8, std.mem.trim(u8, line, " \t"), "")) {
            try buf.append("\r\n");
            continue;
        }

        // Horizontal rule
        if (std.mem.eql(u8, std.mem.trim(u8, line, " \t-"), "") and
            std.mem.count(u8, line, "-") >= 3)
        {
            try buf.append(term.FG_BRIGHT_BLACK);
            var i: u16 = 0;
            while (i < max_col) : (i += 1) try buf.append("─");
            try buf.append(term.RESET);
            try buf.append("\r\n");
            continue;
        }

        // Heading
        if (std.mem.startsWith(u8, line, "### ")) {
            try buf.append(term.BOLD ++ term.FG_YELLOW);
            try renderInline(buf, line[4..]);
            try buf.append(term.RESET);
            try buf.append("\r\n");
            continue;
        }
        if (std.mem.startsWith(u8, line, "## ")) {
            try buf.append(term.BOLD ++ term.FG_BRIGHT_YELLOW);
            try renderInline(buf, line[3..]);
            try buf.append(term.RESET);
            try buf.append("\r\n");
            continue;
        }
        if (std.mem.startsWith(u8, line, "# ")) {
            try buf.append(term.BOLD ++ term.UNDERLINE ++ term.FG_BRIGHT_WHITE);
            try renderInline(buf, line[2..]);
            try buf.append(term.RESET);
            try buf.append("\r\n");
            continue;
        }

        // Blockquote
        if (std.mem.startsWith(u8, line, "> ")) {
            try buf.append(term.FG_BRIGHT_BLACK ++ "│ " ++ term.RESET);
            try buf.append(term.ITALIC ++ term.FG_WHITE);
            try renderWrapped(buf, line[2..], if (max_col > 2) max_col - 2 else max_col);
            try buf.append(term.RESET);
            continue;
        }

        // Unordered list item
        if (std.mem.startsWith(u8, line, "- ") or
            std.mem.startsWith(u8, line, "* ") or
            std.mem.startsWith(u8, line, "+ "))
        {
            try buf.append(term.FG_BRIGHT_BLUE ++ "  • " ++ term.RESET);
            try renderWrapped(buf, line[2..], if (max_col > 4) max_col - 4 else max_col);
            continue;
        }
        if (std.mem.startsWith(u8, line, "  - ") or std.mem.startsWith(u8, line, "  * ")) {
            try buf.append(term.FG_BLUE ++ "    ◦ " ++ term.RESET);
            try renderWrapped(buf, line[4..], if (max_col > 6) max_col - 6 else max_col);
            continue;
        }

        // Numbered list item (simple: starts with digit + ". ")
        if (line.len >= 3 and std.ascii.isDigit(line[0]) and line[1] == '.' and line[2] == ' ') {
            try buf.append(term.FG_BRIGHT_BLUE);
            try buf.append(line[0..3]);
            try buf.append(term.RESET);
            try renderWrapped(buf, line[3..], if (max_col > 3) max_col - 3 else max_col);
            continue;
        }

        // Normal paragraph line — wrap at max_col
        try renderWrapped(buf, line, max_col);
    }

    // Close unclosed code block (generation hit token limit mid-block)
    if (in_code_block) {
        try buf.append(term.FG_BRIGHT_BLACK);
        try buf.append("└");
        var i: u16 = 1;
        while (i < max_col - 2) : (i += 1) try buf.append("─");
        try buf.append("┘");
        try buf.append(term.RESET);
        try buf.append("\r\n");
    }
}

/// Render a paragraph line, wrapping at max_col visible columns.
fn renderWrapped(buf: *RenderBuf, line: []const u8, max_col: u16) !void {
    if (max_col == 0) {
        try renderInline(buf, line);
        try buf.append("\r\n");
        return;
    }
    var col: usize = 0;
    var words = std.mem.splitScalar(u8, line, ' ');
    var first = true;
    while (words.next()) |word| {
        if (word.len == 0) {
            if (!first) {
                col += 1;
                try buf.append(" ");
            }
            continue;
        }
        // Measure the rendered word's visible width (strip inline markup estimate)
        // Simple: count non-backslash printable chars for width estimate
        const word_vis = visibleWordLen(word);
        const need = if (first) word_vis else word_vis + 1; // +1 for space
        if (!first and col + need > max_col) {
            try buf.append("\r\n");
            col = 0;
            first = true;
        }
        if (!first) {
            try buf.append(" ");
            col += 1;
        }
        try renderInline(buf, word);
        col += word_vis;
        first = false;
    }
    try buf.append("\r\n");
}

/// Estimate the visible column width of a word that may contain markdown markup.
/// This is approximate: it strips * _ ` ~ markers but counts other chars.
fn visibleWordLen(word: []const u8) usize {
    var len: usize = 0;
    var i: usize = 0;
    while (i < word.len) {
        const b = word[i];
        if (b == '*' or b == '_' or b == '~' or b == '`') {
            i += 1;
            continue;
        }
        if (b & 0xC0 == 0x80) { // UTF-8 continuation byte — same codepoint
            i += 1;
            continue;
        }
        len += 1;
        i += 1;
    }
    return len;
}

/// Render a single line with syntax highlighting for code blocks.
fn renderCodeLine(buf: *RenderBuf, line: []const u8) !void {
    // Simple: highlight keywords in a basic way
    // For now, just output the line as-is (cyan coloring is done by caller)
    try buf.append(line);
}

/// Render inline markdown: **bold**, *italic*, `code`, ~~strike~~.
fn renderInline(buf: *RenderBuf, text: []const u8) !void {
    var i: usize = 0;
    while (i < text.len) {
        // Bold + italic: ***text***
        if (i + 2 < text.len and text[i] == '*' and text[i + 1] == '*' and text[i + 2] == '*') {
            if (std.mem.indexOf(u8, text[i + 3 ..], "***")) |end| {
                try buf.append(term.BOLD ++ term.ITALIC);
                try renderInline(buf, text[i + 3 .. i + 3 + end]);
                try buf.append(term.RESET);
                i += 3 + end + 3;
                continue;
            }
        }
        // Bold: **text**
        if (i + 1 < text.len and text[i] == '*' and text[i + 1] == '*') {
            if (std.mem.indexOf(u8, text[i + 2 ..], "**")) |end| {
                try buf.append(term.BOLD);
                try renderInline(buf, text[i + 2 .. i + 2 + end]);
                try buf.append(term.RESET);
                i += 2 + end + 2;
                continue;
            }
        }
        // Bold: __text__
        if (i + 1 < text.len and text[i] == '_' and text[i + 1] == '_') {
            if (std.mem.indexOf(u8, text[i + 2 ..], "__")) |end| {
                try buf.append(term.BOLD);
                try renderInline(buf, text[i + 2 .. i + 2 + end]);
                try buf.append(term.RESET);
                i += 2 + end + 2;
                continue;
            }
        }
        // Italic: *text*
        if (text[i] == '*') {
            if (std.mem.indexOf(u8, text[i + 1 ..], "*")) |end| {
                try buf.append(term.ITALIC);
                try renderInline(buf, text[i + 1 .. i + 1 + end]);
                try buf.append(term.RESET);
                i += 1 + end + 1;
                continue;
            }
        }
        // Italic: _text_
        if (text[i] == '_') {
            if (std.mem.indexOf(u8, text[i + 1 ..], "_")) |end| {
                try buf.append(term.ITALIC);
                try renderInline(buf, text[i + 1 .. i + 1 + end]);
                try buf.append(term.RESET);
                i += 1 + end + 1;
                continue;
            }
        }
        // Strikethrough: ~~text~~
        if (i + 1 < text.len and text[i] == '~' and text[i + 1] == '~') {
            if (std.mem.indexOf(u8, text[i + 2 ..], "~~")) |end| {
                try buf.append(term.STRIKETHROUGH ++ term.DIM);
                try renderInline(buf, text[i + 2 .. i + 2 + end]);
                try buf.append(term.RESET);
                i += 2 + end + 2;
                continue;
            }
        }
        // Inline code: `text`
        if (text[i] == '`') {
            if (std.mem.indexOf(u8, text[i + 1 ..], "`")) |end| {
                try buf.append(term.BG_BLACK ++ term.FG_BRIGHT_CYAN);
                try buf.append(text[i + 1 .. i + 1 + end]);
                try buf.append(term.RESET);
                i += 1 + end + 1;
                continue;
            }
        }
        // Plain character
        var char_buf: [4]u8 = undefined;
        char_buf[0] = text[i];
        try buf.append(char_buf[0..1]);
        i += 1;
    }
}

/// Wrap a line into multiple lines of at most `width` visible chars.
/// Returns a list of string slices (not copies).
pub fn wrapLine(allocator: std.mem.Allocator, line: []const u8, width: usize) ![][]const u8 {
    if (width == 0 or line.len == 0) {
        var result = try allocator.alloc([]const u8, 1);
        result[0] = line;
        return result;
    }
    var lines = std.ArrayList([]const u8).empty;
    var start: usize = 0;
    var col: usize = 0;
    var last_space: usize = 0;
    var last_space_col: usize = 0;

    var i: usize = 0;
    while (i < line.len) {
        // Skip ANSI escape sequences (they don't consume columns)
        if (line[i] == '\x1b') {
            i += 1;
            if (i < line.len and line[i] == '[') {
                i += 1;
                while (i < line.len) {
                    const ch = line[i];
                    i += 1;
                    if (ch == 'm' or ch == 'H' or ch == 'J' or ch == 'K' or
                        ch == 'A' or ch == 'B' or ch == 'C' or ch == 'D') break;
                }
            }
            continue;
        }
        if (line[i] == ' ') {
            last_space = i;
            last_space_col = col;
        }
        col += 1;
        if (col >= width) {
            // Break at last space if possible
            const break_at = if (last_space > start) last_space else i;
            try lines.append(allocator, line[start..break_at]);
            start = if (last_space > start and last_space + 1 <= line.len) last_space + 1 else break_at;
            col = col - last_space_col;
            if (last_space <= start) {
                col = 0;
                last_space = start;
                last_space_col = 0;
            } else {
                last_space_col = 0;
                last_space = start;
            }
        }
        i += 1;
    }
    if (start < line.len) {
        try lines.append(allocator, line[start..]);
    }
    if (lines.items.len == 0) {
        try lines.append(allocator, line);
    }
    return lines.toOwnedSlice(allocator);
}
