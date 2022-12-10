const std = @import("std");

pub const FileReader = struct {
    file: std.fs.File,
    reader: std.io.Reader(std.fs.File, std.os.ReadError, std.fs.File.read),

    const Self = @This();

    pub fn init(filename: []const u8) std.fs.File.OpenError!Self {
        const file = try std.fs.cwd().openFile(filename, .{ .mode = std.fs.File.OpenMode.read_only });
        return Self{
            .file = file,
            .reader = file.reader(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.file.close();
    }

    pub fn getNextLine(self: *Self, allocator: std.mem.Allocator, limit: usize) !?[]u8 {
        return self.reader.readUntilDelimiterOrEofAlloc(allocator, '\n', limit);
    }
};
