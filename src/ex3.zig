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

    fn findIntersectionDyn(self_: *std.DynamicBitSet, other: std.DynamicBitSet) !?i32 {
        self_.setIntersection(other);
        const intersectPoint = self_.findFirstSet();

        if (intersectPoint) |point| {
            return @intCast(i32, point);
        }
        return null;
    }

    fn findIntersectionDynLower(self: *Self, other: Self) !?i32 {
        if (try findIntersectionDyn(&self.lower, other.lower)) |int| {
            return int;
        }
        return null;
    }

    fn findIntersectionDynUpper(self: *Self, other: Self) !?i32 {
        if (try findIntersectionDyn(&self.upper, other.upper)) |int| {
            return int;
        }
        return null;
    }

    fn findIntersection3Score(x: *Self, y: Self, z: Self) !?i32 {
        _ = try x.findIntersectionDynLower(y);
        if (try x.findIntersectionDynLower(z)) |int| {
            return int;
        }

        _ = try x.findIntersectionDynUpper(y);
        if (try x.findIntersectionDynUpper(z)) |int| {
            return int + 26;
        }

        unreachable;
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
        return try findIntersection(self_.lower, other.lower, allocator);
    }

    fn findIntersectionUpper(self_: Self, other: Self, allocator: std.mem.Allocator) !?i32 {
        return try findIntersection(self_.upper, other.upper, allocator);
    }

    fn findIntersectionScore(self_: Self, other: Self, allocator: std.mem.Allocator) !?i32 {
        if (try findIntersectionLower(self_, other, allocator)) |int| {
            return int;
        }

        if (try findIntersectionUpper(self_, other, allocator)) |int| {
            return int + 26;
        }

        unreachable;
    }
};

test "1" {
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
    try expectEqual(upperIntersect2, 24);
}

test "2" {
    const expectEqual = std.testing.expectEqual;
    const allocator = std.testing.allocator;

    var a = try LetterBitSet.init(allocator);
    defer a.deinit();
    var b = try LetterBitSet.init(allocator);
    defer b.deinit();
    var c = try LetterBitSet.init(allocator);
    defer c.deinit();

    a.set('a');
    a.set('b');
    a.set('c');
    b.set('b');
    b.set('c');
    b.set('d');
    c.set('c');
    c.set('d');
    c.set('e');

    const pointsIntersect: ?i32 = try LetterBitSet.findIntersection3Score(&a, b, c);
    try expectEqual(pointsIntersect, 3);
}

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var accum: i32 = 0;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);

        const line_len_mid = line.len / 2;
        const fst = line[0..line_len_mid];
        const snd = line[line_len_mid..line.len];

        var fstBitSet = try LetterBitSet.init(allocator);
        defer fstBitSet.deinit();
        var sndBitSet = try LetterBitSet.init(allocator);
        defer sndBitSet.deinit();

        for (fst) |c| {
            fstBitSet.set(c);
        }

        for (snd) |c| {
            sndBitSet.set(c);
        }

        const ans: ?i32 = try LetterBitSet.findIntersectionScore(fstBitSet, sndBitSet, allocator);

        if (ans) |int| {
            accum += int;
        }
        std.debug.print("{s}, score: {?}, accum: {d}\n", .{ line, ans, accum });
    }
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var line_no: u2 = 0;
    var accum: i32 = 0;
    var fst: []const u8 = undefined;
    var snd: []const u8 = undefined;
    var trd: []const u8 = undefined;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        switch (line_no) {
            0 => {
                fst = line;
            },
            1 => {
                snd = line;
            },
            2 => {
                trd = line;

                defer allocator.free(fst);
                defer allocator.free(snd);
                defer allocator.free(trd);

                var fstBitSet = try LetterBitSet.init(allocator);
                defer fstBitSet.deinit();
                var sndBitSet = try LetterBitSet.init(allocator);
                defer sndBitSet.deinit();
                var trdBitSet = try LetterBitSet.init(allocator);
                defer trdBitSet.deinit();

                for (fst) |c| {
                    fstBitSet.set(c);
                }

                for (snd) |c| {
                    sndBitSet.set(c);
                }

                for (trd) |c| {
                    trdBitSet.set(c);
                }

                const score: ?i32 =
                    try LetterBitSet.findIntersection3Score(&fstBitSet, sndBitSet, trdBitSet);

                if (score) |int| {
                    accum += int;
                }
                std.debug.print("{s}\n{s}\n{s}\n", .{ fst, snd, trd });
                std.debug.print("score: {?}, accum: {d}\n", .{ score, accum });
            },
            3 => unreachable,
        }

        line_no += 1;
        line_no %= 3;
    }
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
