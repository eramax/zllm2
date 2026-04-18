const std = @import("std");
const Io = std.Io;
const c = @import("llama.zig").c;
const config = @import("config/schema.zig");
const backend_mod = @import("backend.zig");
const loader = @import("model/loader.zig");
const fallback_graph = @import("model/graphs/fallback.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var iter = std.process.Args.Iterator.init(init.minimal.args);
    _ = iter.next(); // skip executable name

    var cfg_path: ?[]const u8 = null;
    var model_path: ?[]const u8 = null;
    var prompt: ?[]const u8 = null;
    var no_tui = false;

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

    const allocator = std.heap.page_allocator;
    var cfg = config.Config{};

    if (cfg_path) |path| {
        cfg = try config.parseFromFile(io, allocator, path);
    }

    if (model_path) |path| cfg.model = path;
    if (prompt) |p| cfg.prompt = p;

    if (cfg.model.len == 0) {
        std.debug.print("Error: no model specified. Use -m <path> or -c <config.json>\n", .{});
        return error.NoModel;
    }

    if (cfg.prompt == null and !cfg.serve) {
        std.debug.print("Error: no prompt specified. Use -p <text> or set prompt in config\n", .{});
        return error.NoPrompt;
    }

    c.llama_backend_init();
    defer c.llama_backend_free();

    try backend_mod.loadAll(allocator);

    std.debug.print("Loading model: {s}\n", .{cfg.model});
    const state = try loader.loadModel(io, allocator, cfg);
    defer loader.freeModel(state);

    std.debug.print("Model loaded.\n", .{});

    if (cfg.prompt) |p| {
        try generateToStdout(state, p, cfg.gen);
        return;
    }

    std.debug.print("No mode specified. Use -p for prompt or --serve for server.\n", .{});
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

    // Prefill
    fallback_graph.prefill(state.ctx, tokens.items) catch |err| {
        std.debug.print("Error: prefill failed ({s})\n", .{@errorName(err)});
        return error.DecodeFailed;
    };

    var n_generated: u32 = 0;

    var new_token: c.llama_token = fallback_graph.sample(state.sampler, state.ctx);

    while (n_generated < max_tokens) : (n_generated += 1) {
        var buf: [64]u8 = undefined;
        const n = c.llama_token_to_piece(state.vocab, new_token, &buf, buf.len, 0, true);
        if (n > 0) {
            const piece = buf[0..@as(usize, @intCast(n))];
            stdout.writeAll(piece) catch {};
        }

        if (c.llama_vocab_is_eog(state.vocab, new_token)) break;

        fallback_graph.accept(state.sampler, new_token);

        fallback_graph.decodeOne(state.ctx, new_token) catch |err| {
            std.debug.print("\nError: decode failed ({s})\n", .{@errorName(err)});
            break;
        };

        new_token = fallback_graph.sample(state.sampler, state.ctx);
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
        \\      --serve             Start HTTP server
        \\      --port   <n>        HTTP port (default 8080)
        \\      --bench  <name>     Run benchmark and exit
        \\      --save   <path>     Save GGUF after loading
        \\      --version           Print version
        \\      --help              Print this help
        \\
    , .{});
}
