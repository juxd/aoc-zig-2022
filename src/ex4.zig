const std = @import("std");
const file_reader = @import("file_reader.zig");

const Interval = struct {
    left: i32,
    right: i32,

    const Self = @This();

    fn parseString(string: []const u8) !Self {
        const sepIdx = try for (string) |char, idx| {
            switch (char) {
                '-' => {
                    break idx;
                },
                else => {},
            }
        } else error.NoHyphen;

        return Self{
            .left = try std.fmt.parseInt(i32, string[0..sepIdx], 10),
            .right = try std.fmt.parseInt(i32, string[sepIdx + 1 .. string.len], 10),
        };
    }

    fn contains(self: Self, other: Self) bool {
        return self.left <= other.left and self.right >= other.right;
    }

    fn overlaps(self: Self, other: Self) bool {
        return self.left <= other.right and self.right >= other.left;
    }
};

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var score: i32 = 0;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
        std.debug.print("parsing: {s}\n", .{line});
        const commaIdx = try for (line) |char, idx| {
            switch (char) {
                ',' => {
                    break idx;
                },
                else => {},
            }
        } else error.NoComma;

        const fst = try Interval.parseString(line[0..commaIdx]);
        const snd = try Interval.parseString(line[commaIdx + 1 .. line.len]);

        const contains = fst.contains(snd) or snd.contains(fst);

        std.debug.print(" {d}-{d} -- {d}-{d} : {any}\n", .{ fst.left, fst.right, snd.left, snd.right, contains });

        if (contains) {
            score += 1;
        }
    }

    std.debug.print("score: {d}\n", .{score});
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var score: i32 = 0;
    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);

        std.debug.print("parsing: {s}\n", .{line});
        const commaIdx = try for (line) |char, idx| {
            switch (char) {
                ',' => {
                    break idx;
                },
                else => {},
            }
        } else error.NoComma;

        const fst = try Interval.parseString(line[0..commaIdx]);
        const snd = try Interval.parseString(line[commaIdx + 1 .. line.len]);

        const overlaps = fst.overlaps(snd);

        std.debug.print(" {d}-{d} -- {d}-{d} : {any}\n", .{ fst.left, fst.right, snd.left, snd.right, overlaps });

        if (overlaps) {
            score += 1;
        }
    }

    std.debug.print("score: {d}\n", .{score});
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
