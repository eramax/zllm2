const std = @import("std");
const c = @import("llama.zig").c;

const dev_dirs = [_][]const u8{
    "/mnt/data1/projects/llm/llama.cpp/build/bin",
};

pub fn loadAll(allocator: std.mem.Allocator) !void {
    for (dev_dirs) |dir| {
        if (try tryDir(allocator, dir)) return;
    }
    std.debug.print("warning: no backend directory found, GPU acceleration unavailable\n", .{});
}

fn tryDir(allocator: std.mem.Allocator, dir: []const u8) !bool {
    const dir_z = try allocator.dupeZ(u8, dir);
    defer allocator.free(dir_z);

    if (!hasSo(dir_z)) return false;

    c.ggml_backend_load_all_from_path(dir_z.ptr);
    return true;
}

fn hasSo(dir_z: [:0]const u8) bool {
    const d = std.c.opendir(dir_z.ptr) orelse return false;
    defer _ = std.c.closedir(d);

    while (std.c.readdir(d)) |entry| {
        const name = std.mem.sliceTo(&entry.name, 0);
        if (std.mem.startsWith(u8, name, "libggml-") and
            std.mem.endsWith(u8, name, ".so"))
        {
            return true;
        }
    }
    return false;
}
