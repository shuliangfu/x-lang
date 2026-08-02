// r05_matmul.zig — 64x64 integer matrix multiply (matches r05_matmul.c / .x)
// Uses 1D arrays to simulate 2D: index = i*64 + j.
const std = @import("std");

pub fn main() !void {
    var a: [4096]i32 = undefined;
    var b: [4096]i32 = undefined;
    var c: [4096]i32 = undefined;

    var i: usize = 0;
    while (i < 64) : (i += 1) {
        var j: usize = 0;
        while (j < 64) : (j += 1) {
            a[i * 64 + j] = @intCast(i + j);
            b[i * 64 + j] = @intCast(i * j);
            c[i * 64 + j] = 0;
        }
    }

    i = 0;
    while (i < 64) : (i += 1) {
        var j: usize = 0;
        while (j < 64) : (j += 1) {
            var s: i32 = 0;
            var k: usize = 0;
            while (k < 64) : (k += 1) {
                s += a[i * 64 + k] * b[k * 64 + j];
            }
            c[i * 64 + j] = s;
        }
    }

    const result: i32 = c[0] + c[63 * 64 + 63];
    std.process.exit(@intCast(result & 0xFF));
}
