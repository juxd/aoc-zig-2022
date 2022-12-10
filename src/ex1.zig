const std = @import("std");

pub fn f(filename: []const u8) anyerror!void {
    std.debug.print("{s}\n", .{filename});
}
