const std = @import("std");

pub const c = @cImport({
    @cInclude("llama.h");
});

pub const Model = c.llama_model;
pub const Context = c.llama_context;
pub const Sampler = c.llama_sampler;
pub const Batch = c.llama_batch;
pub const Token = c.llama_token;
pub const Vocab = c.llama_vocab;
