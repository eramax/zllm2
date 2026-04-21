const std = @import("std");

pub const c = @cImport({
    @cInclude("llama.h");
    @cInclude("ggml.h");
    @cInclude("ggml-cpu.h");
    @cInclude("ggml-backend.h");
    @cInclude("gguf.h");
});

pub const Model = c.llama_model;
pub const Context = c.llama_context;
pub const Sampler = c.llama_sampler;
pub const Batch = c.llama_batch;
pub const Token = c.llama_token;
pub const Vocab = c.llama_vocab;
