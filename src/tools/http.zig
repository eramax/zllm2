const std = @import("std");

/// Perform an HTTP GET request using curl and return the response body.
/// Caller owns the returned slice.
pub fn get(allocator: std.mem.Allocator, io: std.Io, url: []const u8, max_bytes: usize) ![]const u8 {
    const result = try std.process.run(allocator, io, .{
        .argv = &.{ "curl", "-sL", "--max-filesize", "262144", url },
        .stdout_limit = std.Io.Limit.limited(max_bytes),
        .stderr_limit = std.Io.Limit.limited(4096),
    });
    defer allocator.free(result.stderr);
    return result.stdout;
}
