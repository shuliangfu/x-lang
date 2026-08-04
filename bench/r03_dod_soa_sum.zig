// r03_dod_soa_sum.zig — DOD SoA sum (i32) benchmark (matches r03_dod_soa_sum.x)
// Struct-of-Arrays layout: sum field x over 4096 particles.
const std = @import("std");

const n: usize = 4096;
var xs: [n]i32 = undefined;
var ys: [n]i32 = undefined;
var zs: [n]i32 = undefined;

pub fn main() !void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        xs[i] = 1;
        ys[i] = 2;
        zs[i] = 3;
    }
    var s: i32 = 0;
    i = 0;
    while (i < n) : (i += 1) {
        s += xs[i];
    }
    std.process.exit(@intCast(@divTrunc(s, 256)));
}
