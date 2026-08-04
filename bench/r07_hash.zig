// r07_hash.zig — FNV-1a 64-bit hash benchmark (matches r07_hash.c / .x)
// Uses u64 with wrapping arithmetic (*%= and +%=) for well-defined overflow.
const std = @import("std");

const N: usize = 10_000_000;
const R: usize = 10;
var buf: [N]u8 = undefined;

pub fn main() !void {
    var i: usize = 0;
    while (i < N) : (i += 1) {
        buf[i] = @truncate(i & 0xFF);
    }

    const offset: u64 = 14695981039346656037; // FNV-1a 64-bit offset basis
    const prime: u64 = 1099511628211; // FNV-1a 64-bit prime

    var hash: u64 = 0;
    var r: usize = 0;
    while (r < R) : (r += 1) {
        var h: u64 = offset;
        i = 0;
        while (i < N) : (i += 1) {
            h ^= @as(u64, buf[i]);
            h *%= prime;
        }
        hash +%= h;
    }

    const low32: u32 = @truncate(hash);
    const result: i32 = @bitCast(low32);
    std.process.exit(@intCast(result & 0xFF));
}
