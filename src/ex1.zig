const std = @import("std");
const file_reader = @import("file_reader.zig");

fn part1(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    std.debug.print("{s}\n", .{filename});

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var max_so_far: i32 = 0;
    var curr: i32 = 0;

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
        const just_int = line[0 .. line.len - 1];
        if (just_int.len == 0) {
            std.debug.print("empty_line, resetting count {d} curr {d}\n", .{ max_so_far, curr });
            if (curr > max_so_far)
                max_so_far = curr;
            curr = 0;
            continue;
        }
        const num = try std.fmt.parseInt(i32, just_int, 10);
        curr += num;
    }

    std.debug.print("answer is {d}\n", .{max_so_far});
}

fn part2(filename: []const u8) anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const Lt = comptime struct {
        fn f(context: void, a: i32, b: i32) std.math.Order {
            _ = context;
            return std.math.order(a, b);
        }
    };

    var reader = try file_reader.FileReader.init(filename);
    defer reader.deinit();

    var curr: i32 = 0;
    var pqueue = std.PriorityQueue(i32, void, Lt.f).init(allocator, {});
    defer pqueue.deinit();

    while (try reader.getNextLine(allocator, 1000)) |line| {
        defer allocator.free(line);
        const just_int = line[0 .. line.len - 1];
        if (just_int.len == 0) {
            std.debug.print("empty_line, resetting count curr {d}\n", .{curr});
            try pqueue.add(curr);
            while (pqueue.len > 3) {
                _ = pqueue.remove();
            }
            std.debug.print("len {d} {any}\n", .{ pqueue.len, pqueue.items });
            curr = 0;
            continue;
        }
        const num = try std.fmt.parseInt(i32, just_int, 10);
        curr += num;
    }

    var top_3_sum: i32 = 0;

    for (pqueue.items[0..pqueue.len]) |top| {
        top_3_sum += top;
    }

    std.debug.print("answer is {d}\n", .{top_3_sum});
}

pub fn f(part: usize, filename: []const u8) anyerror!void {
    try switch (part) {
        1 => part1(filename),
        2 => part2(filename),
        else => error.OneOrTwoRequired,
    };
}
