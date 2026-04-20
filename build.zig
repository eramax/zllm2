const std = @import("std");

fn addLlamaCppDeps(module: *std.Build.Module, b: *std.Build) void {
    module.addIncludePath(b.path("../llama.cpp/include"));
    module.addIncludePath(b.path("../llama.cpp/ggml/include"));
    module.addIncludePath(b.path("../llama.cpp/src")); // for llama-model.h (internal)
    module.addLibraryPath(b.path("../llama.cpp/build/bin"));
    module.linkSystemLibrary("ggml-base", .{});
    module.linkSystemLibrary("llama", .{});
    module.linkSystemLibrary("ggml", .{});
    module.linkSystemLibrary("m", .{});
    module.linkSystemLibrary("dl", .{});
    module.linkSystemLibrary("pthread", .{});
    module.addRPathSpecial("$ORIGIN/../../../llama.cpp/build/bin");
    // C++ bridge: exposes llama_internal_get_tensor_map to Zig
    module.addCSourceFile(.{
        .file = b.path("src/model/graphs/tensor_access.cpp"),
        .flags = &.{ "-std=c++17", "-D_GLIBCXX_USE_CXX11_ABI=1" },
    });
    module.linkSystemLibrary("stdc++", .{});
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zllm2",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    addLlamaCppDeps(exe.root_module, b);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run zllm2");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    addLlamaCppDeps(unit_tests.root_module, b);
    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
