// r09_recursion_vs_iter.zig — fib(35) recursive vs iterative (matches r09_recursion_vs_iter.c / .x)
// Tests: recursive function call overhead vs tight iterative loop.
// Returns rec ^ iter (should be 0, verifying both produce fib(35)=9227465).
const std = @import("std");

fn fibRec(n: i32) i32 {
    if (n < 2) return n;
    return fibRec(n - 1) + fibRec(n - 2);
}

fn fibIter(n: i32) i32 {
    if (n < 2) return n;
    var a: i32 = 0;
    var b: i32 = 1;
    var i: i32 = 2;
    while (i <= n) : (i += 1) {
        const c = a + b;
        a = b;
        b = c;
    }
    return b;
}

pub fn main() !void {
    const n: i32 = 35;
    const rec = fibRec(n);
    const iter = fibIter(n);
    const result: i32 = rec ^ iter;
    std.process.exit(@intCast(result & 0xFF));
}
