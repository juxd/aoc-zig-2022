const std = @import("std");
const file_reader = @import("file_reader.zig");

const RockPaperScissors = struct {
    const Choice = enum(i8) { rock = 0, paper = 1, scissors = 2 };
    const Outcome = enum { win, draw, lose };

    pub fn outcomeForB(a: Choice, b: Choice) Outcome {
        switch (@mod(@enumToInt(b) - @enumToInt(a), 3)) {
            0 => return Outcome.draw,
            1 => return Outcome.win,
            2 => return Outcome.lose,
            else => unreachable,
        }
    }
};

test {
    const Choice = RockPaperScissors.Choice;
    const Outcome = RockPaperScissors.Outcome;

    const expectEqual = std.testing.expectEqual;

    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.paper), Outcome.win);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.rock), Outcome.draw);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.scissors), Outcome.lose);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.scissors, Choice.rock), Outcome.win);
}

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
    }

    std.debug.print("answer is {d}\n", .{ 0 });
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);

    }

    std.debug.print("answer is {d}\n", .{ 0 });
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
