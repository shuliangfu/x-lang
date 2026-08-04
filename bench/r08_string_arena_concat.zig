// r08_string_arena_concat.zig — string arena concat benchmark (matches r08_string_arena_concat.x)
// Concatenates a single byte 128 times using arena allocator.
const std = @import("std");

pub fn main() !void {
    const n: usize = 128;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var cur: std.ArrayList(u8) = .empty;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        cur.append(alloc, 'x') catch return std.process.exit(1);
    }
    if (cur.items.len != n) return std.process.exit(2);
    var j: usize = 0;
    while (j < n) : (j += 1) {
        if (cur.items[j] != 120) return std.process.exit(3);
    }
    std.process.exit(@intCast(n));
}
