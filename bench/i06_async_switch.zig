// async_switch.zig — B-ASYNC：状态机 ping-pong 协程切换基线（Zig -O2 对照）
//
// Mirrors bench/i06_async_switch.x: drive two CoopFrame state machines
// (ping/pong) for 1_000_000 rounds; each step flips phase and bumps ops.
// Final ops must equal 2_000_000.
const std = @import("std");

const CoopFrame = extern struct {
    phase: i32,
    ops: i64,
};

inline fn coopFrameStep(f: *CoopFrame) i32 {
    if (f.phase == 0) {
        f.ops += 1;
        f.phase = 1;
        return 0;
    }
    f.ops += 1;
    f.phase = 0;
    return 0;
}

pub fn main() !void {
    const rounds: i64 = 1_000_000;
    var ping: CoopFrame = .{ .phase = 0, .ops = 0 };
    var pong: CoopFrame = .{ .phase = 0, .ops = 0 };
    var i: i64 = 0;
    while (i < rounds) : (i += 1) {
        _ = coopFrameStep(&ping);
        _ = coopFrameStep(&pong);
    }
    const total: i64 = ping.ops + pong.ops;
    if (total != 2_000_000) std.process.exit(5);
    std.process.exit(0);
}
