const std = @import("std");
const clap = @import("clap");

const ExerciseImplementation = struct {
    f: *const fn (part: usize, filename: []const u8) anyerror!void
};

const exercises = [_]ExerciseImplementation{
    ExerciseImplementation{ .f = @import("ex1.zig").f },
};

pub fn main() anyerror!void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help            Display this help and exit.
        \\-d, --day <usize>     An option parameter, which takes the day.
        \\-p, --part <usize>    An option parameter, which takes the part.
        \\<str>...
        \\
    );

    // Initalize our diagnostics, which can be used for reporting useful errors.
    // This is optional. You can also pass `.{}` to `clap.parse` if you don't
    // care about the extra information `Diagnostics` provides.
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        // Report useful error and exit
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help) {
        std.debug.print("--help\n", .{});
        return;
    }

    const day = res.args.day orelse return error.DayMustBeProvided;
    const part = res.args.part orelse return error.PartMustBeProvided;

    if (res.positionals.len > 1)
        return error.OnlyOnePositionalExpected;

    try exercises[day - 1].f(part, res.positionals[0]);
}
