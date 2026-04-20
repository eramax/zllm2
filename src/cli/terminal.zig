//! Raw terminal control: raw mode, size, ANSI helpers, render buffer.

const std = @import("std");
const posix = std.posix;

pub const STDIN = posix.STDIN_FILENO;
pub const STDOUT = posix.STDOUT_FILENO;

// ── ANSI escape constants ────────────────────────────────────────────────────
pub const ESC = "\x1b";
pub const CSI = "\x1b[";
pub const RESET = "\x1b[0m";
pub const BOLD = "\x1b[1m";
pub const DIM = "\x1b[2m";
pub const ITALIC = "\x1b[3m";
pub const UNDERLINE = "\x1b[4m";
pub const REVERSE = "\x1b[7m";
pub const STRIKETHROUGH = "\x1b[9m";

pub const FG_BLACK = "\x1b[30m";
pub const FG_RED = "\x1b[31m";
pub const FG_GREEN = "\x1b[32m";
pub const FG_YELLOW = "\x1b[33m";
pub const FG_BLUE = "\x1b[34m";
pub const FG_MAGENTA = "\x1b[35m";
pub const FG_CYAN = "\x1b[36m";
pub const FG_WHITE = "\x1b[37m";
pub const FG_BRIGHT_BLACK = "\x1b[90m";
pub const FG_BRIGHT_RED = "\x1b[91m";
pub const FG_BRIGHT_GREEN = "\x1b[92m";
pub const FG_BRIGHT_YELLOW = "\x1b[93m";
pub const FG_BRIGHT_BLUE = "\x1b[94m";
pub const FG_BRIGHT_MAGENTA = "\x1b[95m";
pub const FG_BRIGHT_CYAN = "\x1b[96m";
pub const FG_BRIGHT_WHITE = "\x1b[97m";

pub const BG_BLACK = "\x1b[40m";
pub const BG_RED = "\x1b[41m";
pub const BG_GREEN = "\x1b[42m";
pub const BG_YELLOW = "\x1b[43m";
pub const BG_BLUE = "\x1b[44m";
pub const BG_MAGENTA = "\x1b[45m";
pub const BG_CYAN = "\x1b[46m";
pub const BG_WHITE = "\x1b[47m";

pub const CURSOR_HIDE = "\x1b[?25l";
pub const CURSOR_SHOW = "\x1b[?25h";
pub const ALT_SCREEN_ENTER = "\x1b[?1049h";
pub const ALT_SCREEN_EXIT = "\x1b[?1049l";
pub const SCREEN_CLEAR = "\x1b[2J";
pub const CURSOR_HOME = "\x1b[H";
pub const LINE_CLEAR = "\x1b[2K";
pub const SYNC_START = "\x1b[?2026h";
pub const SYNC_END = "\x1b[?2026l";

// ── Terminal size ────────────────────────────────────────────────────────────
pub const Size = struct { rows: u16, cols: u16 };

const WinSize = extern struct {
    ws_row: u16,
    ws_col: u16,
    ws_xpixel: u16,
    ws_ypixel: u16,
};

pub fn getSize() Size {
    var ws = WinSize{ .ws_row = 24, .ws_col = 80, .ws_xpixel = 0, .ws_ypixel = 0 };
    const rc = posix.system.ioctl(STDOUT, posix.T.IOCGWINSZ, @intFromPtr(&ws));
    if (rc != 0) return .{ .rows = 24, .cols = 80 };
    const rows = if (ws.ws_row == 0) 24 else ws.ws_row;
    const cols = if (ws.ws_col == 0) 80 else ws.ws_col;
    return .{ .rows = rows, .cols = cols };
}

// ── Raw mode ─────────────────────────────────────────────────────────────────
var saved_termios: posix.termios = undefined;
var in_raw_mode = false;

pub fn isTty() bool {
    return std.c.isatty(STDIN) != 0;
}

pub fn enterRawMode() !void {
    if (!isTty()) return; // non-TTY: skip raw mode (e.g. in CI/scripts)
    saved_termios = try posix.tcgetattr(STDIN);
    var t = saved_termios;
    t.iflag.BRKINT = false;
    t.iflag.ICRNL = false;
    t.iflag.INPCK = false;
    t.iflag.ISTRIP = false;
    t.iflag.IXON = false;
    t.oflag.OPOST = false;
    t.lflag.ECHO = false;
    t.lflag.ICANON = false;
    t.lflag.IEXTEN = false;
    t.lflag.ISIG = false;
    // VMIN=0, VTIME=1: non-blocking with 100ms timeout per read
    t.cc[@intFromEnum(posix.V.MIN)] = 0;
    t.cc[@intFromEnum(posix.V.TIME)] = 1;
    try posix.tcsetattr(STDIN, .FLUSH, t);
    in_raw_mode = true;
}

pub fn exitRawMode() void {
    if (!in_raw_mode or !isTty()) return;
    posix.tcsetattr(STDIN, .FLUSH, saved_termios) catch {};
    in_raw_mode = false;
}

// ── I/O ──────────────────────────────────────────────────────────────────────

/// Read bytes from stdin. Returns 0 on 100ms timeout (VMIN=0 VTIME=1).
pub fn readBytes(buf: []u8) usize {
    return posix.read(STDIN, buf) catch 0;
}

pub fn writeAll(data: []const u8) void {
    _ = std.os.linux.write(STDOUT, data.ptr, data.len);
}

// ── RenderBuf ────────────────────────────────────────────────────────────────
/// Accumulate terminal output into a buffer, flush all at once to avoid tearing.
pub const RenderBuf = struct {
    buf: std.ArrayList(u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) RenderBuf {
        return .{ .buf = .empty, .allocator = allocator };
    }

    pub fn deinit(self: *RenderBuf) void {
        self.buf.deinit(self.allocator);
    }

    pub fn append(self: *RenderBuf, s: []const u8) !void {
        try self.buf.appendSlice(self.allocator, s);
    }

    pub fn print(self: *RenderBuf, comptime fmt: []const u8, args: anytype) !void {
        var tmp: [4096]u8 = undefined;
        if (std.fmt.bufPrint(&tmp, fmt, args)) |s| {
            try self.buf.appendSlice(self.allocator, s);
        } else |_| {
            // fallback: allocate for very long strings
            const heap = try std.fmt.allocPrint(self.allocator, fmt, args);
            defer self.allocator.free(heap);
            try self.buf.appendSlice(self.allocator, heap);
        }
    }

    /// Move cursor to 1-indexed (row, col).
    pub fn moveTo(self: *RenderBuf, row: u16, col: u16) !void {
        try self.print("\x1b[{d};{d}H", .{ row, col });
    }

    /// Clear current line from cursor to end.
    pub fn clearLine(self: *RenderBuf) !void {
        try self.append("\x1b[K");
    }

    /// Write one display row at a given position, truncated to cols.
    pub fn writeRow(self: *RenderBuf, row: u16, text: []const u8, cols: u16) !void {
        try self.moveTo(row, 1);
        try self.append("\x1b[K"); // clear line
        if (text.len == 0) return;
        // Truncate visible length to cols (ANSI sequences don't count)
        const visible = visibleLen(text);
        if (visible <= cols) {
            try self.append(text);
        } else {
            // Truncate at cols visible columns, stepping back to codepoint boundary
            var end = text.len;
            while (end > 0 and visibleLen(text[0..end]) > cols) {
                end -= 1;
                // Step back over UTF-8 continuation bytes to land on a codepoint start
                while (end > 0 and text[end] & 0xC0 == 0x80) end -= 1;
            }
            try self.append(text[0..end]);
        }
    }

    pub fn flush(self: *RenderBuf) void {
        writeAll(self.buf.items);
        self.buf.clearRetainingCapacity();
    }
};

/// Count visible columns (non-ANSI, counting UTF-8 codepoints not bytes).
pub fn visibleLen(s: []const u8) usize {
    var len: usize = 0;
    var i: usize = 0;
    while (i < s.len) {
        if (s[i] == '\x1b') {
            // Skip ANSI escape sequence
            i += 1;
            if (i < s.len and s[i] == '[') {
                i += 1;
                while (i < s.len and s[i] != 'm' and s[i] != 'H' and s[i] != 'J' and s[i] != 'K' and s[i] != 'A' and s[i] != 'B' and s[i] != 'C' and s[i] != 'D') {
                    i += 1;
                }
                if (i < s.len) i += 1;
            } else {
                if (i < s.len) i += 1;
            }
        } else if (s[i] & 0xC0 == 0x80) {
            // UTF-8 continuation byte — part of a multi-byte codepoint, no new column
            i += 1;
        } else {
            len += 1;
            i += 1;
        }
    }
    return len;
}
