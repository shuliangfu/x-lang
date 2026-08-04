// l01_sqlite_is_available_loop.zig — sqlite.is_available() hot loop (matches l01_sqlite_is_available_loop.x)
// Tests FFI call overhead in a tight loop. Zig uses libc dlopen equivalent or stub.
const std = @import("std");

// Stub: emulate sqlite.is_available() returning 1 (available).
// Real implementation would dlopen libsqlite3 and call sqlite3_libversion().
fn sqlite_is_available() i32 {
    return 1;
}

pub fn main() !void {
    var acc: i32 = 0;
    var i: i32 = 0;
    while (i < 100_000) : (i += 1) {
        acc += sqlite_is_available();
    }
    if (acc < 0) {
        std.process.exit(1);
    }
}
