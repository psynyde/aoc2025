const std = @import("std");

pub const Data = struct {
    content: []u8,
    iterator: @TypeOf(std.mem.splitScalar(u8, "", '\n')),
    allocator: std.mem.Allocator,

    pub fn deinit(self: Data) void {
        self.allocator.free(self.content);
    }
};

pub fn gen_iterator(allocator: std.mem.Allocator, path: []const u8, delimiter: u8) !Data {
    const content = try std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024); // max size 1mb
    const iterator = std.mem.splitScalar(u8, content, delimiter);

    return Data{ .content = content, .iterator = iterator, .allocator = allocator };
}
