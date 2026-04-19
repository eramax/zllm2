//! Interactive TUI: fixed input box at bottom, status bar, scrolling chat,
//! markdown rendering, slash commands, replay mode, conversation logging.

const std = @import("std");
const posix = std.posix;
const term = @import("terminal.zig");
const md = @import("markdown.zig");
const cmds = @import("commands.zig");
const c = @import("../llama.zig").c;
const config = @import("../config/schema.zig");
const loader = @import("../model/loader.zig");
const fallback = @import("../model/graphs/fallback.zig");
const graph_interface = @import("../model/graphs/interface.zig");
const diagram_mod = @import("diagram.zig");
const arch_yaml = @import("../model/arch_yaml.zig");

// ── Types ────────────────────────────────────────────────────────────────────

pub const Role = enum { user, assistant, system_msg };

pub const Message = struct {
    role: Role,
    content: std.ArrayList(u8),
    generating: bool = false,

    pub fn init(allocator: std.mem.Allocator, role: Role, text: []const u8) !Message {
        var content: std.ArrayList(u8) = .empty;
        try content.appendSlice(allocator, text);
        return .{ .role = role, .content = content };
    }

    pub fn deinit(self: *Message, allocator: std.mem.Allocator) void {
        self.content.deinit(allocator);
    }
};

pub const Stats = struct {
    prefill_tps: f64 = 0,
    gen_tps: f64 = 0,
    n_ctx_used: u32 = 0,
    n_ctx_total: u32 = 0,
    model_name: []const u8 = "none",
};

pub const GpuStats = struct {
    util_pct: u32 = 0,
    vram_used_mb: u64 = 0,
    vram_total_mb: u64 = 0,
    valid: bool = false,
};

const INPUT_MAX = 4096;
const STATUS_ROWS: u16 = 3; // status1 + status2 + input-separator

pub const TuiState = struct {
    allocator: std.mem.Allocator,
    messages: std.ArrayList(Message),
    input: [INPUT_MAX]u8,
    input_len: usize,
    scroll: i32, // extra lines to keep above bottom (0 = stick to bottom)
    stats: Stats,
    cfg: config.Config,
    model_state: ?*loader.ModelState,
    io: std.Io,
    size: term.Size,
    save_file: ?std.Io.File,
    generating: bool,
    model_path_buf: ?[]u8, // owned copy of model path for /load
    gpu: GpuStats,
    gpu_last_ms: i64,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, cfg: config.Config, ms: ?*loader.ModelState) TuiState {
        return .{
            .allocator = allocator,
            .messages = .empty,
            .input = undefined,
            .input_len = 0,
            .scroll = 0,
            .stats = .{},
            .cfg = cfg,
            .model_state = ms,
            .io = io,
            .size = term.getSize(),
            .save_file = null,
            .generating = false,
            .model_path_buf = null,
            .gpu = .{},
            .gpu_last_ms = 0,
        };
    }

    pub fn deinit(self: *TuiState) void {
        for (self.messages.items) |*msg| msg.deinit(self.allocator);
        self.messages.deinit(self.allocator);
        if (self.save_file) |f| f.close(self.io);
        if (self.model_path_buf) |p| self.allocator.free(p);
    }

    pub fn addMessage(self: *TuiState, role: Role, text: []const u8) !*Message {
        const msg = try Message.init(self.allocator, role, text);
        try self.messages.append(self.allocator, msg);
        return &self.messages.items[self.messages.items.len - 1];
    }

    pub fn addSystemMsg(self: *TuiState, text: []const u8) !void {
        _ = try self.addMessage(.system_msg, text);
    }
};

// ── File helpers ─────────────────────────────────────────────────────────────

fn writeToFile(file: std.Io.File, data: []const u8) void {
    _ = std.os.linux.write(@intCast(file.handle), data.ptr, data.len);
}

fn milliTimestamp() i64 {
    var ts = std.os.linux.timespec{ .sec = 0, .nsec = 0 };
    _ = std.os.linux.clock_gettime(.MONOTONIC, &ts);
    return @as(i64, @intCast(ts.sec)) * 1000 + @divTrunc(@as(i64, @intCast(ts.nsec)), 1_000_000);
}

fn sleepMs(ms: u64) void {
    const ts = std.os.linux.timespec{ .sec = @intCast(ms / 1000), .nsec = @intCast((ms % 1000) * 1_000_000) };
    _ = std.os.linux.nanosleep(&ts, null);
}

fn writeSave(state: *TuiState, data: []const u8) void {
    if (state.save_file) |f| writeToFile(f, data);
}

// ── Rendering ────────────────────────────────────────────────────────────────

/// Full frame render. Clears screen and redraws everything.
pub fn render(state: *TuiState, buf: *term.RenderBuf) !void {
    state.size = term.getSize();
    const sz = state.size;

    try buf.append(term.SYNC_START);
    try buf.append(term.CURSOR_HIDE);
    try buf.append(term.CURSOR_HOME);

    // ── Chat area ──────────────────────────────────────────────────────────
    const chat_height: u16 = if (sz.rows > STATUS_ROWS + 2) sz.rows - STATUS_ROWS - 1 else 1;

    // Collect all rendered lines from messages
    var all_lines = std.ArrayList([]const u8).empty;
    defer {
        for (all_lines.items) |line| state.allocator.free(line);
        all_lines.deinit(state.allocator);
    }

    for (state.messages.items) |*msg| {
        try collectMessageLines(state.allocator, msg, sz.cols, &all_lines);
    }

    // Calculate scroll: skip lines from top to show bottom
    const total_lines = all_lines.items.len;
    const visible_h: usize = @intCast(chat_height);
    const start_idx: usize = if (total_lines > visible_h) blk: {
        const max_scroll: i32 = @intCast(total_lines - visible_h);
        const scroll_offset = @max(0, max_scroll - state.scroll);
        break :blk @intCast(scroll_offset);
    } else 0;

    // Render chat lines — leave 2-column right margin
    const chat_cols = if (sz.cols > 4) sz.cols - 2 else sz.cols;
    var row: u16 = 1;
    var line_i = start_idx;
    while (row <= chat_height and line_i < total_lines) : ({
        row += 1;
        line_i += 1;
    }) {
        try buf.writeRow(row, all_lines.items[line_i], chat_cols);
    }
    while (row <= chat_height) : (row += 1) {
        try buf.moveTo(row, 1);
        try buf.append("\x1b[K");
    }

    // ── Status bars ────────────────────────────────────────────────────────
    const stat1_row: u16 = chat_height + 1;
    const stat2_row: u16 = chat_height + 2;
    const sep_row: u16 = chat_height + 3;
    const input_row: u16 = chat_height + 4;

    // Status line 1: model + generation stats.
    // BG_BLUE + \x1b[K fills the whole line with blue before we write text —
    // this avoids byte-vs-column miscounts from multi-byte UTF-8 in the text.
    try buf.moveTo(stat1_row, 1);
    try buf.append(term.BG_BLUE ++ term.FG_BRIGHT_WHITE ++ term.BOLD ++ "\x1b[K");
    {
        const model_name = if (state.stats.model_name.len > 36)
            state.stats.model_name[state.stats.model_name.len - 36 ..]
        else
            state.stats.model_name;
        var tmp: [256]u8 = undefined;
        const s = std.fmt.bufPrint(&tmp, " {s} | Ctx: {d}/{d} | Prefill: {d:.0} t/s | Gen: {d:.0} t/s", .{
            model_name,
            state.stats.n_ctx_used,
            state.stats.n_ctx_total,
            state.stats.prefill_tps,
            state.stats.gen_tps,
        }) catch " [status] ";
        try buf.append(s);
    }
    try buf.append(term.RESET);

    // Status line 2: CPU + RAM + GPU + config
    try buf.moveTo(stat2_row, 1);
    try buf.append(term.BG_BLACK ++ term.FG_BRIGHT_BLACK ++ "\x1b[K");
    {
        const now_ms = milliTimestamp();
        if (now_ms - state.gpu_last_ms > 2000) {
            state.gpu = readGpuStats(state.allocator, state.io);
            state.gpu_last_ms = now_ms;
        }
        const cpu = readCpuPercent(state.io);
        const ram = readRamGB(state.io);
        var tmp: [512]u8 = undefined;
        var s: []const u8 = undefined;
        if (state.gpu.valid) {
            const vram_used_gb = @as(f64, @floatFromInt(state.gpu.vram_used_mb)) / 1024.0;
            const vram_total_gb = @as(f64, @floatFromInt(state.gpu.vram_total_mb)) / 1024.0;
            s = std.fmt.bufPrint(&tmp, " CPU: {d:.0}%  RAM: {d:.1}G  GPU: {d}%  VRAM: {d:.1}/{d:.1}G  temp={d:.2}  top_p={d:.2}  gen={d}", .{
                cpu, ram, state.gpu.util_pct, vram_used_gb, vram_total_gb, state.cfg.temp, state.cfg.top_p, state.cfg.gen,
            }) catch " [sys] ";
        } else {
            s = std.fmt.bufPrint(&tmp, " CPU: {d:.0}%  RAM: {d:.1}G  temp={d:.2}  top_p={d:.2}  gen={d}", .{
                cpu, ram, state.cfg.temp, state.cfg.top_p, state.cfg.gen,
            }) catch " [sys] ";
        }
        try buf.append(s);
    }
    try buf.append(term.RESET);

    // Separator — clear with default bg first, then draw line
    try buf.moveTo(sep_row, 1);
    try buf.append(term.RESET ++ "\x1b[K" ++ term.FG_BRIGHT_BLACK);
    var ci: u16 = 0;
    while (ci < sz.cols) : (ci += 1) try buf.append("─");
    try buf.append(term.RESET);

    // ── Input row ──────────────────────────────────────────────────────────
    if (input_row <= sz.rows) {
        try buf.moveTo(input_row, 1);
        try buf.append("\x1b[K");
        if (state.generating) {
            try buf.append(term.FG_YELLOW ++ term.BOLD ++ " ⟳ generating..." ++ term.RESET);
        } else {
            try buf.append(term.FG_BRIGHT_GREEN ++ term.BOLD ++ "> " ++ term.RESET);
            try buf.append(state.input[0..state.input_len]);
            try buf.append(term.REVERSE ++ " " ++ term.RESET); // cursor block
        }
    }

    try buf.append(term.CURSOR_SHOW);
    try buf.append(term.SYNC_END);
    buf.flush();
}

fn collectMessageLines(allocator: std.mem.Allocator, msg: *const Message, cols: u16, lines: *std.ArrayList([]const u8)) !void {
    const content = msg.content.items;

    // Header
    const header: []const u8 = switch (msg.role) {
        .user => term.FG_BRIGHT_GREEN ++ term.BOLD ++ "You: " ++ term.RESET,
        .assistant => term.FG_BRIGHT_BLUE ++ term.BOLD ++ "Assistant: " ++ term.RESET,
        .system_msg => term.FG_BRIGHT_BLACK ++ term.ITALIC ++ "  [system] " ++ term.RESET,
    };
    try lines.append(allocator, try allocator.dupe(u8, header));

    if (content.len == 0) {
        if (msg.generating) {
            try lines.append(allocator, try allocator.dupe(u8, term.FG_YELLOW ++ "  ▌" ++ term.RESET));
        }
        try lines.append(allocator, try allocator.dupe(u8, ""));
        return;
    }

    if (msg.role == .system_msg) {
        var it = std.mem.splitScalar(u8, content, '\n');
        while (it.next()) |line| {
            const full = try std.fmt.allocPrint(allocator, "{s}{s}" ++ term.RESET, .{ term.FG_BRIGHT_BLACK ++ "  ", line });
            try lines.append(allocator, full);
        }
    } else {
        // Render markdown
        var render_buf = term.RenderBuf.init(allocator);
        defer render_buf.deinit();
        md.render(&render_buf, content, if (cols > 6) cols - 4 else cols) catch {};

        var it = std.mem.splitSequence(u8, render_buf.buf.items, "\r\n");
        while (it.next()) |line| {
            if (line.len == 0) {
                try lines.append(allocator, try allocator.dupe(u8, ""));
            } else {
                try lines.append(allocator, try std.fmt.allocPrint(allocator, "  {s}", .{line}));
            }
        }
    }

    try lines.append(allocator, try allocator.dupe(u8, "")); // trailing blank
}

// ── Input handling ───────────────────────────────────────────────────────────

pub const KeyResult = enum { none, dirty, exit };

pub fn handleKey(state: *TuiState, buf: []const u8) !KeyResult {
    if (buf.len == 0) return .none;
    var result: KeyResult = .none;
    var i: usize = 0;

    while (i < buf.len) {
        const b = buf[i];

        if (b == 0x03 or b == 0x04) return .exit; // Ctrl+C / Ctrl+D

        if (b == '\r' or b == '\n') {
            const line = std.mem.trim(u8, state.input[0..state.input_len], " \t");
            if (line.len > 0) {
                const line_copy = try state.allocator.dupe(u8, line);
                defer state.allocator.free(line_copy);
                state.input_len = 0;
                if (cmds.parse(line_copy)) |cmd| {
                    const should_exit = try executeCommand(state, cmd);
                    if (should_exit) return .exit;
                } else {
                    try generateResponse(state, line_copy);
                }
            }
            result = .dirty;
            i += 1;
            continue;
        }

        if (b == 0x7f or b == 0x08) { // Backspace
            if (state.input_len > 0) state.input_len -= 1;
            result = .dirty;
            i += 1;
            continue;
        }

        // ESC sequences (arrow keys, page up/down)
        if (b == 0x1b and i + 2 < buf.len and buf[i + 1] == '[') {
            switch (buf[i + 2]) {
                'A' => { state.scroll += 3; result = .dirty; },
                'B' => { if (state.scroll > 0) state.scroll -= 3; result = .dirty; },
                '5' => { state.scroll += @as(i32, @intCast(state.size.rows)) - STATUS_ROWS - 2; result = .dirty; },
                '6' => {
                    state.scroll -= @as(i32, @intCast(state.size.rows)) - STATUS_ROWS - 2;
                    if (state.scroll < 0) state.scroll = 0;
                    result = .dirty;
                },
                else => {},
            }
            i += 3;
            continue;
        }

        // Printable bytes — includes multi-byte UTF-8 for paste support
        if (b >= 0x20 and b != 0x7f) {
            if (state.input_len < INPUT_MAX - 1) {
                state.input[state.input_len] = b;
                state.input_len += 1;
            }
            result = .dirty;
        }

        i += 1;
    }

    return result;
}

// ── Commands ─────────────────────────────────────────────────────────────────

fn executeCommand(state: *TuiState, cmd: cmds.ParsedCommand) !bool {
    switch (cmd.kind) {
        .quit => return true,
        .help => {
            try state.addSystemMsg(cmds.HELP_TEXT);
        },
        .clear => {
            for (state.messages.items) |*msg| msg.deinit(state.allocator);
            state.messages.clearRetainingCapacity();
            try state.addSystemMsg("Conversation cleared.");
        },
        .load => {
            if (cmd.args.len == 0) {
                try state.addSystemMsg("Usage: /load <model-path>");
            } else {
                try reloadModel(state, cmd.args);
            }
        },
        .set => try executeSet(state, cmd.args),
        .save => {
            if (cmd.args.len == 0) {
                try state.addSystemMsg("Usage: /save <path>");
            } else {
                try saveConversation(state, cmd.args);
            }
        },
        .template => {
            if (state.model_state) |ms| {
                const tmpl = c.llama_model_chat_template(ms.model, null);
                if (tmpl != null) {
                    const s = std.mem.sliceTo(tmpl.?, 0);
                    const msg = try std.fmt.allocPrint(state.allocator, "Chat template:\n```\n{s}\n```", .{s});
                    defer state.allocator.free(msg);
                    try state.addSystemMsg(msg);
                } else {
                    try state.addSystemMsg("No chat template available.");
                }
            } else {
                try state.addSystemMsg("No model loaded.");
            }
        },
        .model => {
            if (state.model_state) |ms| {
                const n_params = c.llama_model_n_params(ms.model);
                const n_ctx = c.llama_n_ctx(ms.ctx);
                const msg = try std.fmt.allocPrint(state.allocator, "Model: {s}\nParameters: {d:.1}B\nContext: {d}\nDtype: {s}", .{
                    state.cfg.model,
                    @as(f64, @floatFromInt(n_params)) / 1e9,
                    n_ctx,
                    state.cfg.dtype,
                });
                defer state.allocator.free(msg);
                try state.addSystemMsg(msg);
            } else {
                try state.addSystemMsg("No model loaded. Use /load <path>.");
            }
        },
        .showmodel => {
            if (state.model_state) |ms| {
                if (std.mem.indexOf(u8, cmd.args, "--yaml") != null) {
                    const yaml = arch_yaml.serialize(state.allocator, ms.model) catch "Failed to serialize model metadata.";
                    defer state.allocator.free(yaml);
                    try state.addSystemMsg(yaml);
                } else {
                    const diag = diagram_mod.render(state.allocator, ms.model) catch "Failed to render diagram.";
                    defer state.allocator.free(diag);
                    try state.addSystemMsg(diag);
                }
            } else {
                try state.addSystemMsg("No model loaded. Use /load <path> first.");
            }
        },
        .config => {
            const msg = try std.fmt.allocPrint(state.allocator,
                \\model: {s}
                \\dtype: {s}
                \\ctx: {d}
                \\gen: {d}
                \\temp: {d:.3}
                \\top_p: {d:.3}
                \\top_k: {d}
                \\repeat_penalty: {d:.3}
                \\flash_attn: {}
                \\kv_type: {s}
                \\offload: {d}
                \\threads: {d}
                \\system_prompt: {s}
            , .{
                state.cfg.model,
                state.cfg.dtype,
                state.cfg.ctx,
                state.cfg.gen,
                state.cfg.temp,
                state.cfg.top_p,
                state.cfg.top_k,
                state.cfg.repeat_penalty,
                state.cfg.flash_attn,
                state.cfg.kv_type,
                state.cfg.offload,
                state.cfg.threads,
                if (state.cfg.system_prompt.len > 0) state.cfg.system_prompt else "(default)",
            });
            defer state.allocator.free(msg);
            try state.addSystemMsg(msg);
        },
        .reload => {
            if (state.model_path_buf == null and state.cfg.model.len == 0) {
                try state.addSystemMsg("No model path set. Use /load <path> first.");
            } else {
                const path = if (state.model_path_buf) |p| p else state.cfg.model;
                try reloadModel(state, path);
            }
        },
        .unknown => {
            try state.addSystemMsg("Unknown command. Type /help for available commands.");
        },
    }
    return false;
}

fn executeSet(state: *TuiState, args: []const u8) !void {
    const trimmed = std.mem.trim(u8, args, " \t");
    var split: usize = 0;
    while (split < trimmed.len and trimmed[split] != ' ' and trimmed[split] != '\t') : (split += 1) {}
    if (split == 0 or split >= trimmed.len) {
        try state.addSystemMsg("Usage: /set <key> <value>\nKeys: temp, top_p, top_k, gen, repeat_penalty");
        return;
    }
    const key = trimmed[0..split];
    const val_str = std.mem.trim(u8, trimmed[split..], " \t");

    if (std.ascii.eqlIgnoreCase(key, "temp") or std.ascii.eqlIgnoreCase(key, "temperature")) {
        state.cfg.temp = std.fmt.parseFloat(f64, val_str) catch {
            try state.addSystemMsg("Invalid value for temp (expected float).");
            return;
        };
        const msg = try std.fmt.allocPrint(state.allocator, "temp = {d:.3}", .{state.cfg.temp});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    } else if (std.ascii.eqlIgnoreCase(key, "top_p")) {
        state.cfg.top_p = std.fmt.parseFloat(f64, val_str) catch {
            try state.addSystemMsg("Invalid value for top_p.");
            return;
        };
        const msg = try std.fmt.allocPrint(state.allocator, "top_p = {d:.3}", .{state.cfg.top_p});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    } else if (std.ascii.eqlIgnoreCase(key, "top_k")) {
        state.cfg.top_k = std.fmt.parseInt(i32, val_str, 10) catch {
            try state.addSystemMsg("Invalid value for top_k.");
            return;
        };
        const msg = try std.fmt.allocPrint(state.allocator, "top_k = {d}", .{state.cfg.top_k});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    } else if (std.ascii.eqlIgnoreCase(key, "gen") or std.ascii.eqlIgnoreCase(key, "max_tokens")) {
        state.cfg.gen = std.fmt.parseInt(i32, val_str, 10) catch {
            try state.addSystemMsg("Invalid value for gen.");
            return;
        };
        const msg = try std.fmt.allocPrint(state.allocator, "gen = {d}", .{state.cfg.gen});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    } else if (std.ascii.eqlIgnoreCase(key, "repeat_penalty")) {
        state.cfg.repeat_penalty = std.fmt.parseFloat(f64, val_str) catch {
            try state.addSystemMsg("Invalid value for repeat_penalty.");
            return;
        };
        const msg = try std.fmt.allocPrint(state.allocator, "repeat_penalty = {d:.3}", .{state.cfg.repeat_penalty});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    } else {
        const msg = try std.fmt.allocPrint(state.allocator, "Unknown key '{s}'. Keys: temp, top_p, top_k, gen, repeat_penalty", .{key});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    }
}

fn reloadModel(state: *TuiState, path: []const u8) !void {
    {
        const msg = try std.fmt.allocPrint(state.allocator, "Loading model: {s} ...", .{path});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    }
    if (state.model_state) |ms| {
        loader.freeModel(ms);
        state.model_state = null;
    }
    var new_cfg = state.cfg;
    new_cfg.model = path;
    const ms = loader.loadModel(state.io, state.allocator, new_cfg) catch |err| {
        const msg = try std.fmt.allocPrint(state.allocator, "Failed to load model: {s}", .{@errorName(err)});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
        return;
    };
    state.model_state = ms;
    // Dupe path so it outlives the input line_copy that cmd.args points into
    if (state.model_path_buf) |old| state.allocator.free(old);
    state.model_path_buf = try state.allocator.dupe(u8, path);
    state.cfg.model = state.model_path_buf.?;
    updateStats(state);
    {
        const msg = try std.fmt.allocPrint(state.allocator, "Model loaded: {s}", .{path});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    }
}

fn saveConversation(state: *TuiState, path: []const u8) !void {
    const file = std.Io.Dir.cwd().createFile(state.io, path, .{}) catch |err| {
        const msg = try std.fmt.allocPrint(state.allocator, "Failed to open {s}: {s}", .{ path, @errorName(err) });
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
        return;
    };
    defer file.close(state.io);
    for (state.messages.items) |*msg| {
        const prefix: []const u8 = switch (msg.role) {
            .user => "[user]: ",
            .assistant => "[assistant]: ",
            .system_msg => "[system]: ",
        };
        writeToFile(file, prefix);
        writeToFile(file, msg.content.items);
        writeToFile(file, "\n\n");
    }
    {
        const msg = try std.fmt.allocPrint(state.allocator, "Conversation saved to: {s}", .{path});
        defer state.allocator.free(msg);
        try state.addSystemMsg(msg);
    }
}

// ── Generation ───────────────────────────────────────────────────────────────

fn generateResponse(state: *TuiState, prompt: []const u8) !void {
    writeSave(state, "[user]: ");
    writeSave(state, prompt);
    writeSave(state, "\n");

    _ = try state.addMessage(.user, prompt);

    if (state.model_state == null) {
        try state.addSystemMsg("No model loaded. Use /load <path> first.");
        return;
    }
    const ms = state.model_state.?;

    const asst_msg = try state.addMessage(.assistant, "");
    asst_msg.generating = true;
    state.generating = true;

    const n_ctx = c.llama_n_ctx(ms.ctx);
    var tokens: std.ArrayList(c.llama_token) = .empty;
    defer tokens.deinit(state.allocator);
    try tokens.ensureTotalCapacity(state.allocator, @intCast(n_ctx));

    // Build full conversation history for chat template (enables multi-turn context).
    // Collect duped C-strings that must outlive llama_chat_apply_template.
    var chat_strs = std.ArrayList([:0]u8).empty;
    defer {
        for (chat_strs.items) |s| state.allocator.free(s);
        chat_strs.deinit(state.allocator);
    }
    var chat_msgs = std.ArrayList(c.llama_chat_message).empty;
    defer chat_msgs.deinit(state.allocator);

    var full_prompt: []const u8 = prompt;
    var prompt_buf: ?[]u8 = null;
    defer if (prompt_buf) |pb| state.allocator.free(pb);

    const tmpl = c.llama_model_chat_template(ms.model, null);
    if (tmpl != null) {
        // System prompt
        if (state.cfg.system_prompt.len > 0) {
            const z = try state.allocator.dupeZ(u8, state.cfg.system_prompt);
            try chat_strs.append(state.allocator, z);
            try chat_msgs.append(state.allocator, .{ .role = "system", .content = z.ptr });
        }

        // All previous user/assistant turns (skip system_msg and the current generating pair).
        // state.messages tail: [..., user(current), assistant(generating)] — skip last 2.
        const history_end = if (state.messages.items.len >= 2) state.messages.items.len - 2 else 0;
        for (state.messages.items[0..history_end]) |*m| {
            if (m.role == .system_msg) continue;
            const role: [*:0]const u8 = if (m.role == .user) "user" else "assistant";
            const z = try state.allocator.dupeZ(u8, m.content.items);
            try chat_strs.append(state.allocator, z);
            try chat_msgs.append(state.allocator, .{ .role = role, .content = z.ptr });
        }

        // Current user message
        const user_z = try state.allocator.dupeZ(u8, prompt);
        try chat_strs.append(state.allocator, user_z);
        try chat_msgs.append(state.allocator, .{ .role = "user", .content = user_z.ptr });

        // Allow up to 32 KB for the formatted prompt
        var tbuf = try state.allocator.alloc(u8, 32768);
        const n = c.llama_chat_apply_template(
            tmpl.?, chat_msgs.items.ptr, chat_msgs.items.len, true,
            tbuf.ptr, @intCast(tbuf.len),
        );
        if (n > 0 and @as(usize, @intCast(n)) <= tbuf.len) {
            prompt_buf = tbuf;
            full_prompt = tbuf[0..@intCast(n)];
        } else {
            state.allocator.free(tbuf);
        }
    }

    // add_special=false: chat template already includes BOS.
    // parse_special=true: tokenize <|im_start|> etc. as single tokens.
    const n_tokenized = c.llama_tokenize(
        ms.vocab, full_prompt.ptr, @intCast(full_prompt.len),
        tokens.items.ptr, @intCast(tokens.capacity), false, true,
    );
    if (n_tokenized < 0) {
        asst_msg.generating = false;
        state.generating = false;
        try state.addSystemMsg("Error: prompt too long for context window.");
        return;
    }
    tokens.items.len = @intCast(n_tokenized);

    // Clear KV cache and reset sampler state before each turn
    const mem = c.llama_get_memory(ms.ctx);
    if (mem != null) c.llama_memory_clear(mem, false);
    c.llama_sampler_reset(ms.sampler);

    const graph = graph_interface.select(ms.arch_name);

    const t_prefill_start = milliTimestamp();
    graph.prefill(ms, tokens.items) catch {
        asst_msg.generating = false;
        state.generating = false;
        try state.addSystemMsg("Error: prefill failed.");
        return;
    };
    const t_prefill_ms = milliTimestamp() - t_prefill_start;
    if (t_prefill_ms > 0) {
        state.stats.prefill_tps = @as(f64, @floatFromInt(tokens.items.len)) / @as(f64, @floatFromInt(t_prefill_ms)) * 1000.0;
    }
    state.stats.n_ctx_used = @intCast(tokens.items.len);
    state.stats.n_ctx_total = n_ctx;

    var new_token = graph.sample(ms);
    const max_tokens = state.cfg.gen;
    var n_generated: u32 = 0;
    const t_gen_start = milliTimestamp();
    var last_render_ms = t_gen_start;

    var rbuf = term.RenderBuf.init(state.allocator);
    defer rbuf.deinit();

    while (max_tokens < 0 or n_generated < @as(u32, @intCast(max_tokens))) : (n_generated += 1) {
        if (c.llama_vocab_is_eog(ms.vocab, new_token)) break;

        var piece_buf: [128]u8 = undefined;
        const n_piece = c.llama_token_to_piece(ms.vocab, new_token, &piece_buf, piece_buf.len, 0, true);
        if (n_piece > 0) {
            try asst_msg.content.appendSlice(state.allocator, piece_buf[0..@intCast(n_piece)]);
        }

        graph.accept(ms, new_token);
        graph.decodeOne(ms, new_token) catch break;
        new_token = graph.sample(ms);

        // Rate-limit redraws to ~12 fps to avoid flicker
        const now = milliTimestamp();
        if (now - last_render_ms >= 80) {
            const elapsed = now - t_gen_start;
            if (elapsed > 0 and n_generated > 0) {
                state.stats.gen_tps = @as(f64, @floatFromInt(n_generated)) / @as(f64, @floatFromInt(elapsed)) * 1000.0;
            }
            state.stats.n_ctx_used = @intCast(tokens.items.len + n_generated);
            try render(state, &rbuf);
            last_render_ms = now;
        }
    }

    const t_total = milliTimestamp() - t_gen_start;
    if (t_total > 0 and n_generated > 0) {
        state.stats.gen_tps = @as(f64, @floatFromInt(n_generated)) / @as(f64, @floatFromInt(t_total)) * 1000.0;
    }

    asst_msg.generating = false;
    state.generating = false;

    writeSave(state, "[assistant]: ");
    writeSave(state, asst_msg.content.items);
    writeSave(state, "\n\n");
}

// ── System info ──────────────────────────────────────────────────────────────

fn readCpuPercent(io: std.Io) f64 {
    const file = std.Io.Dir.cwd().openFile(io, "/proc/stat", .{}) catch return 0;
    defer file.close(io);
    var buf: [256]u8 = undefined;
    const n = posix.read(file.handle, &buf) catch return 0;
    const data = buf[0..n];
    if (std.mem.startsWith(u8, data, "cpu ")) {
        var it = std.mem.tokenizeScalar(u8, data[4..], ' ');
        const user = std.fmt.parseInt(u64, it.next() orelse "0", 10) catch 0;
        _ = it.next(); // nice
        const sys = std.fmt.parseInt(u64, it.next() orelse "0", 10) catch 0;
        const idle = std.fmt.parseInt(u64, it.next() orelse "0", 10) catch 0;
        const total = user + sys + idle;
        if (total == 0) return 0;
        return @as(f64, @floatFromInt(user + sys)) / @as(f64, @floatFromInt(total)) * 100.0;
    }
    return 0;
}

fn readRamGB(io: std.Io) f64 {
    const file = std.Io.Dir.cwd().openFile(io, "/proc/meminfo", .{}) catch return 0;
    defer file.close(io);
    var buf: [2048]u8 = undefined;
    const n = posix.read(file.handle, &buf) catch return 0;
    const data = buf[0..n];
    var total_kb: u64 = 0;
    var avail_kb: u64 = 0;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "MemTotal:")) {
            var it = std.mem.tokenizeScalar(u8, line[9..], ' ');
            total_kb = std.fmt.parseInt(u64, it.next() orelse "0", 10) catch 0;
        } else if (std.mem.startsWith(u8, line, "MemAvailable:")) {
            var it = std.mem.tokenizeScalar(u8, line[13..], ' ');
            avail_kb = std.fmt.parseInt(u64, it.next() orelse "0", 10) catch 0;
        }
    }
    const used_kb: u64 = if (total_kb > avail_kb) total_kb - avail_kb else 0;
    return @as(f64, @floatFromInt(used_kb)) / (1024.0 * 1024.0);
}

fn readGpuStats(allocator: std.mem.Allocator, io: std.Io) GpuStats {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const a = arena.allocator();

    const result = std.process.run(a, io, .{
        .argv = &.{
            "nvidia-smi",
            "--query-gpu=utilization.gpu,memory.used,memory.total",
            "--format=csv,noheader,nounits",
        },
        .stderr_limit = .nothing,
        .stdout_limit = std.Io.Limit.limited(256),
    }) catch return .{};

    // Parse "util, used_mb, total_mb"
    var it = std.mem.tokenizeAny(u8, std.mem.trim(u8, result.stdout, " \n\r"), ", ");
    const util = std.fmt.parseInt(u32, it.next() orelse return .{}, 10) catch return .{};
    const used = std.fmt.parseInt(u64, it.next() orelse return .{}, 10) catch return .{};
    const total = std.fmt.parseInt(u64, it.next() orelse return .{}, 10) catch return .{};
    return .{ .util_pct = util, .vram_used_mb = used, .vram_total_mb = total, .valid = true };
}

fn updateStats(state: *TuiState) void {
    if (state.model_state) |ms| {
        state.stats.n_ctx_total = c.llama_n_ctx(ms.ctx);
        state.stats.model_name = state.cfg.model;
    }
}

// ── Main entry point ─────────────────────────────────────────────────────────

pub const RunOpts = struct {
    replay_file: ?[]const u8 = null,
    savefile: ?[]const u8 = null,
    tui_smoke: bool = false,
};

pub fn run(
    allocator: std.mem.Allocator,
    io: std.Io,
    cfg: config.Config,
    model_state: ?*loader.ModelState,
    opts: RunOpts,
) !void {
    var state = TuiState.init(allocator, io, cfg, model_state);
    defer state.deinit();

    if (model_state != null) {
        updateStats(&state);
        state.stats.model_name = cfg.model;
    }

    // Open savefile
    if (opts.savefile) |sf| {
        state.save_file = std.Io.Dir.cwd().createFile(io, sf, .{}) catch |err| blk: {
            std.debug.print("Warning: could not open savefile {s}: {s}\n", .{ sf, @errorName(err) });
            break :blk null;
        };
    }

    // Load replay lines
    var replay_lines: ?[][]const u8 = null;
    var replay_idx: usize = 0;
    if (opts.replay_file) |rf| {
        replay_lines = loadReplayFile(allocator, rf) catch |err| blk: {
            std.debug.print("Warning: could not load replay file {s}: {s}\n", .{ rf, @errorName(err) });
            break :blk null;
        };
    }
    defer if (replay_lines) |rl| {
        for (rl) |line| allocator.free(line);
        allocator.free(rl);
    };

    const is_tty = term.isTty();
    try term.enterRawMode();
    defer term.exitRawMode();

    if (is_tty) {
        term.writeAll(term.ALT_SCREEN_ENTER);
        term.writeAll(term.CURSOR_HIDE);
    }
    defer if (is_tty) {
        term.writeAll(term.ALT_SCREEN_EXIT);
        term.writeAll(term.CURSOR_SHOW);
    };

    try state.addSystemMsg("zllm2 — type a message and press Enter │ /help for commands │ Ctrl+C to exit");
    if (model_state == null) {
        try state.addSystemMsg("No model loaded. Use /load <path> to load a model.");
    }

    var rbuf = term.RenderBuf.init(allocator);
    defer rbuf.deinit();

    // Smoke test: render one frame and exit
    if (opts.tui_smoke) {
        try render(&state, &rbuf);
        return;
    }

    var input_buf: [4096]u8 = undefined;

    while (true) {
        try render(&state, &rbuf);

        // Inject replay input when TUI is idle
        if (!state.generating) {
            if (replay_lines) |rl| {
                if (replay_idx < rl.len) {
                    const line = rl[replay_idx];
                    replay_idx += 1;
                    sleepMs(150); // visual pacing
                    const trimmed = std.mem.trim(u8, line, " \t\r\n");
                    if (trimmed.len > 0) {
                        if (cmds.parse(trimmed)) |cmd| {
                            const should_exit = try executeCommand(&state, cmd);
                            if (should_exit) break;
                        } else {
                            try generateResponse(&state, trimmed);
                        }
                        try render(&state, &rbuf);
                    }
                    continue;
                } else {
                    sleepMs(500);
                    break;
                }
            }
        }

        const n = term.readBytes(&input_buf);
        if (n == 0) continue; // 100ms timeout, loop

        const result = try handleKey(&state, input_buf[0..n]);
        if (result == .exit) break;
    }
}

fn loadReplayFile(allocator: std.mem.Allocator, path: []const u8) ![][]const u8 {
    const io = std.Io.Threaded.global_single_threaded.io();
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var buf: [65536]u8 = undefined;
    const n = try posix.read(file.handle, &buf);
    const content = buf[0..n];

    var result = std.ArrayList([]const u8).empty;
    var it = std.mem.splitScalar(u8, content, '\n');
    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;
        try result.append(allocator, try allocator.dupe(u8, trimmed));
    }
    return result.toOwnedSlice(allocator);
}
