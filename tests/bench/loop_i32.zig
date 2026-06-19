// loop_i32.zig — 与 tests/bench/loop_i32.sx / loop_i32.c 等价的 Zig 参照（run-perf-baseline.sh --bench）
const std = @import("std");

pub fn main() !void {
    const n: i32 = 1_000_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        s += 1;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{s});
}
