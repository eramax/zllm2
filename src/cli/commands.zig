//! Slash command parsing and dispatch for the TUI.

const std = @import("std");

pub const CommandKind = enum {
    help,
    load,
    set,
    clear,
    quit,
    save,
    template,
    model,
    unknown,
};

pub const ParsedCommand = struct {
    kind: CommandKind,
    args: []const u8, // rest of line after command name
};

/// Parse a line starting with '/'. Returns null if not a command.
pub fn parse(line: []const u8) ?ParsedCommand {
    const trimmed = std.mem.trim(u8, line, " \t");
    if (trimmed.len == 0 or trimmed[0] != '/') return null;
    const rest = trimmed[1..];
    // Find end of command word
    var end: usize = 0;
    while (end < rest.len and rest[end] != ' ' and rest[end] != '\t') : (end += 1) {}
    const cmd_name = rest[0..end];
    const args = if (end < rest.len) std.mem.trim(u8, rest[end..], " \t") else "";

    const kind: CommandKind = blk: {
        if (std.ascii.eqlIgnoreCase(cmd_name, "help") or std.ascii.eqlIgnoreCase(cmd_name, "?")) break :blk .help;
        if (std.ascii.eqlIgnoreCase(cmd_name, "load")) break :blk .load;
        if (std.ascii.eqlIgnoreCase(cmd_name, "set")) break :blk .set;
        if (std.ascii.eqlIgnoreCase(cmd_name, "clear")) break :blk .clear;
        if (std.ascii.eqlIgnoreCase(cmd_name, "quit") or std.ascii.eqlIgnoreCase(cmd_name, "exit") or std.ascii.eqlIgnoreCase(cmd_name, "q")) break :blk .quit;
        if (std.ascii.eqlIgnoreCase(cmd_name, "save")) break :blk .save;
        if (std.ascii.eqlIgnoreCase(cmd_name, "template")) break :blk .template;
        if (std.ascii.eqlIgnoreCase(cmd_name, "model") or std.ascii.eqlIgnoreCase(cmd_name, "info")) break :blk .model;
        break :blk .unknown;
    };

    return .{ .kind = kind, .args = args };
}

pub const HELP_TEXT =
    \\Available commands:
    \\  /help          Show this help
    \\  /load <path>   Load a new model (GGUF or HF dir)
    \\  /set <k> <v>   Set config: temp, top_p, top_k, gen, ctx, repeat_penalty
    \\  /clear         Clear conversation history
    \\  /save <path>   Save conversation log to file
    \\  /template      Show current chat template
    \\  /model         Show loaded model info
    \\  /quit          Exit zllm2
    \\
;
