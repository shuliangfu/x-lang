// l01_generic_id_i32.zig — generic id<i32> monomorphization loop (matches l01_generic_id_i32.x)
// Tests comptime generic instantiation with i32 identity function.
const std = @import("std");

fn id(comptime T: type, x: T) T {
    return x;
}

pub fn main() !void {
    const n: i32 = 10_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        s ^= id(i32, i);
    }
    std.process.exit(@intCast(s));
}
