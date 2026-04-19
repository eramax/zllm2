const std = @import("std");
const Io = std.Io;
const c = @import("llama.zig").c;
const config = @import("config/schema.zig");
const backend_mod = @import("backend.zig");
const loader = @import("model/loader.zig");
const fallback_graph = @import("model/graphs/fallback.zig");
const graph_interface = @import("model/graphs/interface.zig");
const tui = @import("cli/tui.zig");
const arch_yaml = @import("model/arch_yaml.zig");
const diagram_mod = @import("cli/diagram.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var iter = std.process.Args.Iterator.init(init.minimal.args);
    _ = iter.next(); // skip executable name

    var cfg_path: ?[]const u8 = null;
    var model_path: ?[]const u8 = null;
    var prompt: ?[]const u8 = null;
    var no_tui = false;
    var inspect_yaml = false;
    var replay_file: ?[]const u8 = null;
    var savefile: ?[]const u8 = null;
    var tui_smoke = false;

    while (iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--config")) {
            cfg_path = iter.next() orelse {
                std.debug.print("Error: -c requires a path\n", .{});
                return error.MissingValue;
            };
        } else if (std.mem.eql(u8, arg, "-m") or std.mem.eql(u8, arg, "--model")) {
            model_path = iter.next() orelse {
                std.debug.print("Error: -m requires a path\n", .{});
                return error.MissingValue;
            };
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--prompt")) {
            prompt = iter.next() orelse {
                std.debug.print("Error: -p requires text\n", .{});
                return error.MissingValue;
            };
        } else if (std.mem.eql(u8, arg, "--no-tui")) {
            no_tui = true;
        } else if (std.mem.eql(u8, arg, "--inspect-yaml")) {
            inspect_yaml = true;
        } else if (std.mem.eql(u8, arg, "--replay")) {
            replay_file = iter.next() orelse {
                std.debug.print("Error: --replay requires a file path\n", .{});
                return error.MissingValue;
            };
        } else if (std.mem.eql(u8, arg, "--savefile")) {
            savefile = iter.next() orelse {
                std.debug.print("Error: --savefile requires a file path\n", .{});
                return error.MissingValue;
            };
        } else if (std.mem.eql(u8, arg, "--tui-smoke")) {
            tui_smoke = true;
        } else if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            printUsage();
            return;
        } else if (std.mem.eql(u8, arg, "--version")) {
            std.debug.print("zllm2 0.1.0\n", .{});
            return;
        } else {
            std.debug.print("Unknown flag: {s}\n", .{arg});
            printUsage();
            return error.UnknownFlag;
        }
    }

    const allocator = std.heap.c_allocator;
    var cfg = config.Config{};

    if (cfg_path) |path| {
        cfg = try config.parseFromFile(io, allocator, path);
    }

    if (model_path) |path| cfg.model = path;
    if (prompt) |p| cfg.prompt = p;

    // Non-interactive mode (--prompt or --no-tui or --inspect-yaml): model is required
    const need_model_for_prompt = (cfg.prompt != null or no_tui or inspect_yaml) and cfg.model.len == 0;
    if (need_model_for_prompt) {
        std.debug.print("Error: no model specified. Use -m <path> or -c <config.json>\n", .{});
        return error.NoModel;
    }

    // TUI smoke test with no model is allowed (shows the UI without generation)
    const want_tui = !no_tui and !inspect_yaml and cfg.prompt == null and !cfg.serve;

    // In TUI mode redirect stderr → /dev/null before any backend init so that
    // ggml backend loader messages and llama.cpp logs never reach the terminal.
    var saved_stderr: i32 = -1;
    if (want_tui or tui_smoke) {
        c.llama_log_set(null, null);
        const linux = std.os.linux;
        const dup_ret = linux.dup(2);
        if (dup_ret < @as(usize, std.math.maxInt(u16))) {
            saved_stderr = @intCast(dup_ret);
            const null_fd = linux.open("/dev/null", .{ .ACCMODE = .WRONLY }, 0);
            if (null_fd < @as(usize, std.math.maxInt(u16))) {
                _ = linux.dup2(@intCast(null_fd), 2);
                _ = linux.close(@intCast(null_fd));
            } else {
                _ = linux.close(@intCast(saved_stderr));
                saved_stderr = -1;
            }
        }
    }
    defer if (saved_stderr >= 0) {
        const linux = std.os.linux;
        _ = linux.dup2(@intCast(saved_stderr), 2);
        _ = linux.close(@intCast(saved_stderr));
    };

    c.llama_backend_init();
    defer c.llama_backend_free();

    try backend_mod.loadAll(allocator);

    // Only load model if a path was provided (TUI can run without it for /load later)
    var model_state: ?*loader.ModelState = null;
    if (cfg.model.len > 0) {
        if (!want_tui) std.debug.print("Loading model: {s}\n", .{cfg.model});
        model_state = try loader.loadModel(io, allocator, cfg);
        if (!want_tui) std.debug.print("Model loaded.\n", .{});
    }
    defer if (model_state) |ms| loader.freeModel(ms);

    if (inspect_yaml) {
        const ms = model_state orelse {
            std.debug.print("Error: model required for --inspect-yaml\n", .{});
            return error.NoModel;
        };
        const diag = try diagram_mod.render(allocator, ms.model);
        defer allocator.free(diag);
        const yaml = try arch_yaml.serialize(allocator, ms.model);
        defer allocator.free(yaml);
        var buf: [0x100]u8 = undefined;
        var w = Io.File.stdout().writer(std.Options.debug_io, &buf);
        const out = &w.interface;
        try out.writeAll("----- inspect diagram -----\n");
        try out.writeAll(diag);
        try out.writeAll("----- inspect yaml -----\n");
        try out.writeAll(yaml);
        try out.flush();
        return;
    }

    if (cfg.prompt) |p| {
        const ms = model_state orelse {
            std.debug.print("Error: model required for --prompt mode\n", .{});
            return error.NoModel;
        };
        try generateToStdout(ms, p, cfg.gen);
        return;
    }

    if (want_tui) {
        try tui.run(allocator, io, cfg, model_state, .{
            .replay_file = replay_file,
            .savefile = savefile,
            .tui_smoke = tui_smoke,
        });
        return;
    }

    if (cfg.serve) {
        std.debug.print("HTTP server mode not yet implemented.\n", .{});
        return;
    }

    std.debug.print("No mode specified. Use -p for prompt, TUI (default), or --serve.\n", .{});
}

fn generateToStdout(state: *loader.ModelState, prompt_text: []const u8, max_tokens: u32) !void {
    var stdout_buf: [0x100]u8 = undefined;
    var stdout_writer = Io.File.stdout().writer(std.Options.debug_io, &stdout_buf);
    const stdout = &stdout_writer.interface;

    const n_ctx = c.llama_n_ctx(state.ctx);
    var tokens: std.ArrayList(c.llama_token) = .empty;
    defer tokens.deinit(std.heap.page_allocator);
    try tokens.ensureTotalCapacity(std.heap.page_allocator, @intCast(n_ctx));

    const n_tokenized = c.llama_tokenize(
        state.vocab,
        prompt_text.ptr,
        @intCast(prompt_text.len),
        tokens.items.ptr,
        @intCast(tokens.capacity),
        true,
        false,
    );
    if (n_tokenized < 0) {
        std.debug.print("Error: prompt too long for context (need {}, have {})\n", .{ -n_tokenized, n_ctx });
        return error.PromptTooLong;
    }
    tokens.items.len = @intCast(n_tokenized);

    const graph = graph_interface.select(state.arch_name);

    graph.prefill(state, tokens.items) catch |err| {
        std.debug.print("Error: prefill failed ({s})\n", .{@errorName(err)});
        return error.DecodeFailed;
    };

    var n_generated: u32 = 0;
    var new_token: c.llama_token = graph.sample(state);

    while (n_generated < max_tokens) : (n_generated += 1) {
        var buf: [64]u8 = undefined;
        const n = c.llama_token_to_piece(state.vocab, new_token, &buf, buf.len, 0, true);
        if (n > 0) {
            const piece = buf[0..@as(usize, @intCast(n))];
            stdout.writeAll(piece) catch {};
        }

        if (c.llama_vocab_is_eog(state.vocab, new_token)) break;

        graph.accept(state, new_token);

        graph.decodeOne(state, new_token) catch |err| {
            std.debug.print("\nError: decode failed ({s})\n", .{@errorName(err)});
            break;
        };

        new_token = graph.sample(state);
    }

    stdout.writeAll("\n") catch {};
    stdout.flush() catch {};

    c.llama_perf_context_print(state.ctx);
}

fn printUsage() void {
    std.debug.print(
        \\zllm2 — local LLM inference runtime
        \\
        \\Usage: zllm2 [flags]
        \\
        \\  -c, --config <path>     Load config JSON
        \\  -m, --model  <path>     Model path (overrides config)
        \\  -p, --prompt <text>     Run single prompt and exit (non-interactive)
        \\      --no-tui            Print tokens to stdout, no TUI
        \\      --inspect-yaml      Print arch diagram + YAML and exit
        \\      --replay <file>     Replay inputs from file (one per line)
        \\      --savefile <path>   Log all conversation to file
        \\      --tui-smoke         Draw one TUI frame and exit (CI smoke test)
        \\      --serve             Start HTTP server (not yet implemented)
        \\      --version           Print version
        \\      --help              Print this help
        \\
    , .{});
}
