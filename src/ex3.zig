const std = @import("std");
const file_reader = @import("file_reader.zig");

const LetterBitSet = struct {
    lower: std.DynamicBitSet,
    upper: std.DynamicBitSet,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .lower = try std.DynamicBitSet.initEmpty(allocator, 32),
            .upper = try std.DynamicBitSet.initEmpty(allocator, 32),
        };
    }

    fn deinit(self: *Self) void {
        self.lower.deinit();
        self.upper.deinit();
    }

    fn set(self: *Self, char: u8) void {
        switch (char) {
            'A'...'Z' => |c| self.upper.set(c - 'A' + 1),
            'a'...'z' => |c| self.lower.set(c - 'a' + 1),
            else => unreachable,
        }
    }

    fn findIntersection(self_: std.DynamicBitSet, other: std.DynamicBitSet, allocator: std.mem.Allocator) !?i32 {
        var intersection = try self_.clone(allocator);
        defer intersection.deinit();
        intersection.setIntersection(other);
        const intersectPoint = intersection.findFirstSet();

        if (intersectPoint) |point| {
            return @intCast(i32, point);
        }
        return null;
    }

    fn findIntersectionLower(self_: Self, other: Self, allocator: std.mem.Allocator) !?i32 {
        if (try findIntersection(self_.lower, other.lower, allocator)) |int| {
            return int;
        }
        return null;
    }

    fn findIntersectionUpper(self_: Self, other: Self, allocator: std.mem.Allocator) !?i32 {
        if (try findIntersection(self_.upper, other.upper, allocator)) |int| {
            return int + 26;
        }
        return null;
    }

    fn findIntersectionScore(self_: Self, other: Self, allocator: std.mem.Allocator) !?i32 {
        if (try findIntersectionLower(self_, other, allocator)) |int| {
            return int;
        }

        if (try findIntersectionUpper(self_, other, allocator)) |int| {
            return int;
        }

        unreachable;
    }
};

test {
    const expectEqual = std.testing.expectEqual;
    const allocator = std.testing.allocator;

    var a = try LetterBitSet.init(allocator);
    defer a.deinit();
    var b = try LetterBitSet.init(allocator);
    defer b.deinit();

    a.set('a');
    a.set('b');
    a.set('c');
    b.set('c');
    b.set('d');
    b.set('e');
    const lowerIntersect: ?i32 = try LetterBitSet.findIntersectionLower(a, b, allocator);
    const upperIntersect: ?i32 = try LetterBitSet.findIntersectionUpper(a, b, allocator);
    try expectEqual(lowerIntersect, 3);
    try expectEqual(upperIntersect, null);

    var c = try LetterBitSet.init(allocator);
    defer c.deinit();
    var d = try LetterBitSet.init(allocator);
    defer d.deinit();

    c.set('V');
    c.set('W');
    c.set('X');
    d.set('X');
    d.set('Y');
    d.set('Z');

    const lowerIntersect2: ?i32 = try LetterBitSet.findIntersectionLower(c, d, allocator);
    const upperIntersect2: ?i32 = try LetterBitSet.findIntersectionUpper(c, d, allocator);
    try expectEqual(lowerIntersect2, null);
    try expectEqual(upperIntersect2, 50);
}

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
    }
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
    }
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
