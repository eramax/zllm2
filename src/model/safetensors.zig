const std = @import("std");
const Io = std.Io;

pub const TensorDType = enum {
    f32,
    f16,
    bf16,
    i8,
    u8,
    unknown,
};

pub const TensorInfo = struct {
    name: []const u8,
    dtype: TensorDType,
    shape: []const u64,
    offset_start: u64,
    offset_end: u64,
};

pub const ShardInfo = struct {
    tensors: []const TensorInfo,
    data_offset: u64,
};

pub const SafetensorsIndex = struct {
    total_size: u64,
    weight_map: std.StringHashMap([]const u8),
    shards: []const []const u8,

    pub fn deinit(self: *SafetensorsIndex, allocator: std.mem.Allocator) void {
        var it = self.weight_map.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.*);
        }
        self.weight_map.deinit();
        for (self.shards) |name| allocator.free(name);
        allocator.free(self.shards);
    }
};

pub fn loadSafetensorsIndex(allocator: std.mem.Allocator, text: []const u8) !SafetensorsIndex {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, text, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    const metadata = switch (parsed.value) {
        .object => |obj| obj,
        else => return error.InvalidSafetensorsIndex,
    };

    const total_size: u64 = if (metadata.get("__metadata__")) |meta| blk: {
        if (meta == .object) {
            if (meta.object.get("total_size")) |ts| {
                break :blk switch (ts) {
                    .integer => |i| @intCast(i),
                    else => 0,
                };
            }
        }
        break :blk 0;
    } else 0;

    // Single-shard: no weight_map, just tensor entries at top level
    // Multi-shard: has weight_map key
    const weight_map_obj = metadata.get("weight_map") orelse {
        // Single shard model - return empty weight map
        return .{
            .total_size = total_size,
            .weight_map = std.StringHashMap([]const u8).init(allocator),
            .shards = &.{},
        };
    };

    const wm = switch (weight_map_obj) {
        .object => |obj| obj,
        else => return error.InvalidSafetensorsIndex,
    };

    var weight_map = std.StringHashMap([]const u8).init(allocator);
    errdefer {
        var w_it = weight_map.iterator();
        while (w_it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.*);
        }
        weight_map.deinit();
    }

    var shards: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (shards.items) |item| allocator.free(item);
        shards.deinit(allocator);
    }

    var it = wm.iterator();
    while (it.next()) |entry| {
        const shard_name = switch (entry.value_ptr.*) {
            .string => |s| s,
            else => return error.InvalidSafetensorsIndex,
        };
        const key_copy = try allocator.dupe(u8, entry.key_ptr.*);
        errdefer allocator.free(key_copy);
        const shard_copy = try allocator.dupe(u8, shard_name);
        errdefer allocator.free(shard_copy);
        try weight_map.put(key_copy, shard_copy);
        if (!containsString(shards.items, shard_name)) {
            const copied = try allocator.dupe(u8, shard_name);
            errdefer allocator.free(copied);
            try shards.append(allocator, copied);
        }
    }

    return .{
        .total_size = total_size,
        .weight_map = weight_map,
        .shards = try shards.toOwnedSlice(allocator),
    };
}

pub fn loadShardFromMemory(data: []const u8, allocator: std.mem.Allocator) !ShardInfo {
    if (data.len < 8) return error.InvalidSafetensorsShard;
    const header_len = std.mem.readInt(u64, data[0..8], .little);
    if (data.len < 8 + header_len) return error.InvalidSafetensorsShard;
    const header = data[8..][0..@as(usize, @intCast(header_len))];
    var shard = try parseShardHeader(allocator, header);
    shard.data_offset = 8 + header_len;
    return shard;
}

pub fn loadSafetensorsShard(io: Io, allocator: std.mem.Allocator, path: []const u8) !ShardInfo {
    var file = try Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var reader = file.reader(io, &.{});

    var len_buf: [8]u8 = undefined;
    try readExact(&reader.interface, len_buf[0..]);
    const header_len = std.mem.readInt(u64, len_buf[0..], .little);

    const header = try allocator.alloc(u8, @intCast(header_len));
    errdefer allocator.free(header);
    try readExact(&reader.interface, header);

    var shard = try parseShardHeader(allocator, header);
    shard.data_offset = 8 + header_len;
    return shard;
}

fn parseShardHeader(allocator: std.mem.Allocator, header: []const u8) !ShardInfo {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, header, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
    defer parsed.deinit();

    const root = switch (parsed.value) {
        .object => |object| object,
        else => return error.InvalidSafetensorsShard,
    };

    var tensors: std.ArrayList(TensorInfo) = .empty;
    errdefer {
        for (tensors.items) |tensor| {
            allocator.free(tensor.name);
            allocator.free(tensor.shape);
        }
        tensors.deinit(allocator);
    }

    var it = root.iterator();
    while (it.next()) |entry| {
        if (std.mem.eql(u8, entry.key_ptr.*, "__metadata__")) continue;

        const tensor_obj = switch (entry.value_ptr.*) {
            .object => |object| object,
            else => return error.InvalidSafetensorsShard,
        };

        const dtype = try getStringField(tensor_obj, "dtype");
        const shape = try getU64SliceField(allocator, tensor_obj, "shape");
        const offsets = try getU64SliceField(allocator, tensor_obj, "data_offsets");
        if (offsets.len != 2) return error.InvalidSafetensorsShard;

        try tensors.append(allocator, .{
            .name = try allocator.dupe(u8, entry.key_ptr.*),
            .dtype = parseDType(dtype),
            .shape = shape,
            .offset_start = offsets[0],
            .offset_end = offsets[1],
        });
    }

    return .{
        .tensors = try tensors.toOwnedSlice(allocator),
        .data_offset = 0,
    };
}

fn readExact(reader: *Io.Reader, data: []u8) !void {
    var filled: usize = 0;
    while (filled < data.len) {
        var vecs: [1][]u8 = .{data[filled..]};
        const n = try reader.readVec(&vecs);
        if (n == 0) return error.EndOfStream;
        filled += n;
    }
}

fn getStringField(object: std.json.ObjectMap, key: []const u8) ![]const u8 {
    const value = object.get(key) orelse return error.InvalidSafetensorsShard;
    return switch (value) {
        .string => |s| s,
        else => return error.InvalidSafetensorsShard,
    };
}

fn getU64SliceField(allocator: std.mem.Allocator, object: std.json.ObjectMap, key: []const u8) ![]const u64 {
    const value = object.get(key) orelse return error.InvalidSafetensorsShard;
    const array = switch (value) {
        .array => |arr| arr.items,
        else => return error.InvalidSafetensorsShard,
    };

    const out = try allocator.alloc(u64, array.len);
    errdefer allocator.free(out);
    for (array, 0..) |item, idx| {
        out[idx] = switch (item) {
            .integer => |i| @intCast(i),
            .float => |f| @intFromFloat(f),
            else => return error.InvalidSafetensorsShard,
        };
    }
    return out;
}

fn parseDType(dtype: []const u8) TensorDType {
    if (std.mem.eql(u8, dtype, "F32")) return .f32;
    if (std.mem.eql(u8, dtype, "F16")) return .f16;
    if (std.mem.eql(u8, dtype, "BF16")) return .bf16;
    if (std.mem.eql(u8, dtype, "I8")) return .i8;
    if (std.mem.eql(u8, dtype, "U8")) return .u8;
    return .unknown;
}

fn containsString(items: []const []const u8, needle: []const u8) bool {
    for (items) |item| {
        if (std.mem.eql(u8, item, needle)) return true;
    }
    return false;
}
