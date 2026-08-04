// r08_regex_match_bench.zig — regex match bench (matches r08_regex_match_bench.c)
// Uses Zig std.regex for comparison. If std.regex API differs, uses naive stub.
const std = @import("std");

pub fn main() !void {
    const loops: usize = 500_000;
    var acc: i32 = 0;

    // Literal: "needle" in 256B haystack at offset 249.
    var hay_lit: [256]u8 = undefined;
    @memset(&hay_lit, 'x');
    @memcpy(hay_lit[249..255], "needle");

    // Star: "a*b" in 64×a + b.
    var hay_star: [65]u8 = undefined;
    @memset(hay_star[0..64], 'a');
    hay_star[64] = 'b';

    // Zig 0.16: use std.mem.indexOf for literal, naive for star.
    var i: usize = 0;
    while (i < loops) : (i += 1) {
        if (std.mem.indexOf(u8, hay_lit[0..], "needle") != null) acc += 0 else acc -= 1;
    }
    i = 0;
    while (i < loops) : (i += 1) {
        // Naive "a*b" match: scan for 'b' after some 'a's.
        var found: i32 = -1;
        var j: usize = 0;
        while (j < hay_star.len) : (j += 1) {
            if (hay_star[j] == 'b') {
                // Check all preceding are 'a' (or empty).
                var k: usize = 0;
                var ok = true;
                while (k < j) : (k += 1) {
                    if (hay_star[k] != 'a') { ok = false; break; }
                }
                if (ok) { found = 0; break; }
            }
        }
        acc += found;
    }

    std.process.exit(@intCast(acc & 0xFF));
}
