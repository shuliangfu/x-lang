// a03_trait_monomorphization.zig — monomorphization vs dynamic dispatch
// Compares "compile-time monomorphization (comptime)" vs "runtime dynamic dispatch (fn ptr)".
// Matches bench/a03_trait_monomorphization.c / .x algorithm.
// N=100000000 iterations, alternating op_add and op_mul.
// Monomorphization uses comptime function parameter (forces separate inline copies).
// Dynamic dispatch uses function pointer array.
const std = @import("std");

const N: i32 = 100_000_000;

fn op_add(x: i32, y: i32) i32 { return x +% y; }
fn op_mul(x: i32, y: i32) i32 { return x *% y; }

fn apply_op(comptime op: fn (i32, i32) i32, x: i32, y: i32) i32 {
    return op(x, y);
}

fn bench_monomorphization() i32 {
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        if (@rem(i, 2) == 0) {
            sum +%= apply_op(op_add, sum, i);
        } else {
            sum +%= apply_op(op_mul, sum, i);
        }
    }
    return sum;
}

fn bench_dynamic() i32 {
    const OpFn = *const fn (i32, i32) i32;
    const ops: [2]OpFn = .{ &op_add, &op_mul };
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        const sel: usize = @intCast(i & 1);
        sum +%= ops[sel](sum, i);
    }
    return sum;
}

pub fn main(init: std.process.Init) !void {
    const ts0 = std.Io.Timestamp.now(init.io, .awake);
    const s1 = bench_monomorphization();
    const ts1 = std.Io.Timestamp.now(init.io, .awake);
    const s2 = bench_dynamic();
    const ts2 = std.Io.Timestamp.now(init.io, .awake);

    const ns1: i64 = @intCast(ts0.durationTo(ts1).nanoseconds);
    const ns2: i64 = @intCast(ts1.durationTo(ts2).nanoseconds);

    const ms1 = @as(f64, @floatFromInt(ns1)) / 1_000_000.0;
    const ms2 = @as(f64, @floatFromInt(ns2)) / 1_000_000.0;

    std.debug.print("monomorphization: {d:.2} ms  sum={d}\n", .{ ms1, s1 });
    std.debug.print("dynamic_dispatch: {d:.2} ms  sum={d}\n", .{ ms2, s2 });
}
