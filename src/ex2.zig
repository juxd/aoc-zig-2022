const std = @import("std");
const file_reader = @import("file_reader.zig");

const RockPaperScissors = struct {
    const Choice = enum(i8) {
        rock = 0,
        paper = 1,
        scissors = 2,

        const Self = @This();

        fn toScore(self: Self) i32 {
            return switch (self) {
                Self.rock => 1,
                Self.paper => 2,
                Self.scissors => 3,
            };
        }

        fn fromOrdinal(ord: i8) !Self {
            return switch(ord) {
                0 => Self.rock,
                1 => Self.paper,
                2 => Self.scissors,
                else => error.UnrecognizedOrdinal
            };
        }
    };

    const Outcome = enum(i8) {
        win = 1,
        draw = 0,
        lose = 2,

        const Self = @This();

        fn toScore(self: Self) i32 {
           return switch (self) {
                Self.win => 6,
                Self.lose => 0,
                Self.draw => 3,
            };
        }
    };

    fn outcomeForB(a: Choice, b: Choice) Outcome {
        return switch (@mod(@enumToInt(b) - @enumToInt(a), 3)) {
            0 => Outcome.draw,
            1 => Outcome.win,
            2 => Outcome.lose,
            else => unreachable,
        };
    }

    fn fromElf(char: u8) Choice {
        return switch (char) {
            'A' => Choice.rock,
            'B' => Choice.paper,
            'C' => Choice.scissors,
            else => unreachable
        };
    }

    fn fromYou(char: u8) Choice {
        return switch (char) {
            'X' => Choice.rock,
            'Y' => Choice.paper,
            'Z' => Choice.scissors,
            else => unreachable
        };
    }

    fn outcomeNeeded(char: u8) Outcome {
        return switch (char) {
            'X' => Outcome.lose,
            'Y' => Outcome.draw,
            'Z' => Outcome.win,
            else => unreachable
        };
    }

    fn choiceNeeded(elf: Choice, targetOutcome: Outcome) Choice {
        return Choice.fromOrdinal(@mod((@enumToInt(elf) + @enumToInt(targetOutcome)), 3)) catch unreachable;
    }

    fn score(elf: u8, you: u8) i32 {
        const yourChoice = fromYou(you);
        const choiceScore: i32 = yourChoice.toScore();
        const outcomeScore: i32 = outcomeForB(fromElf(elf), yourChoice).toScore();
        return choiceScore + outcomeScore;
    }

    fn score2(elf: u8, you: u8) i32 {
        const targetOutcome = outcomeNeeded(you);
        const yourChoice = choiceNeeded(fromElf(elf), targetOutcome);
        const choiceScore = yourChoice.toScore();
        const outcomeScore = targetOutcome.toScore();
        return choiceScore + outcomeScore;
    }
};

test "outcome for two" {
    const Choice = RockPaperScissors.Choice;
    const Outcome = RockPaperScissors.Outcome;

    const expectEqual = std.testing.expectEqual;

    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.paper), Outcome.win);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.rock), Outcome.draw);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.rock, Choice.scissors), Outcome.lose);
    try expectEqual(RockPaperScissors.outcomeForB(Choice.scissors, Choice.rock), Outcome.win);
}

test "outcome from target" {
    const Choice = RockPaperScissors.Choice;
    const Outcome = RockPaperScissors.Outcome;

    const expectEqual = std.testing.expectEqual;

    try expectEqual(RockPaperScissors.choiceNeeded(Choice.scissors, Outcome.win), Choice.rock);
    try expectEqual(RockPaperScissors.choiceNeeded(Choice.scissors, Outcome.draw), Choice.scissors);
    try expectEqual(RockPaperScissors.choiceNeeded(Choice.scissors, Outcome.lose), Choice.paper);
}

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var score: i32 = 0;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
        const line_score = RockPaperScissors.score(line[0], line[2]);
        std.debug.print("scoring: {s} = {d}\n", .{ line, line_score });
        score += line_score;
    }

    std.debug.print("answer is {d}\n", .{ score });
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var score: i32 = 0;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
        const line_score = RockPaperScissors.score2(line[0], line[2]);
        std.debug.print("scoring: {s} = {d}\n", .{ line, line_score });
        score += line_score;
    }

    std.debug.print("answer is {d}\n", .{ score });
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
