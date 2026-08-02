// m02_with_arena_vec_push.zig — arena vec push benchmark (matches m02_with_arena_vec_push.x)
// Tests arena allocator + vec push pattern. Zig uses std.heap.ArenaAllocator.
const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var list: std.ArrayList(u8) = .empty;
    list.append(alloc, 1) catch return std.process.exit(1);
    list.append(alloc, 2) catch return std.process.exit(2);
    list.append(alloc, 3) catch return std.process.exit(3);
    if (list.items.len != 3) return std.process.exit(4);
    if (list.items[0] != 1 or list.items[1] != 2 or list.items[2] != 3) {
        return std.process.exit(5);
    }
}
