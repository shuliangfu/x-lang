// net_echo_throughput.zig — N2 echo client（Zig -O2 对照，PERF-003）
const std = @import("std");

const ECHO_PORT_DEFAULT: u16 = 38457;
const ECHO_SEG: usize = 4096;
const ECHO_ROUNDS: i32 = 1024;

pub fn main() !void {
    var port: u16 = ECHO_PORT_DEFAULT;
    var args = std.process.args();
    _ = args.next();
    if (args.next()) |p| {
        port = @intCast(std.fmt.parseInt(u16, p, 10) catch ECHO_PORT_DEFAULT);
    }
    const addr = std.net.Address.parseIp4("127.0.0.1", port) catch return error.Connect;
    const stream = std.net.tcpConnectToAddress(addr) catch return error.Connect;
    defer stream.close();
    var b0: [ECHO_SEG]u8 = undefined;
    var b1: [ECHO_SEG]u8 = undefined;
    var b2: [ECHO_SEG]u8 = undefined;
    var b3: [ECHO_SEG]u8 = undefined;
    var sum: i32 = 0;
    var round: i32 = 0;
    while (round < ECHO_ROUNDS) : (round += 1) {
        var bi: usize = 0;
        while (bi < ECHO_SEG) : (bi += 1) {
            b0[bi] = @intCast((round + @as(i32, @intCast(bi))) & 255);
            b1[bi] = @intCast((round + @as(i32, @intCast(bi)) + 1) & 255);
            b2[bi] = @intCast((round + @as(i32, @intCast(bi)) + 2) & 255);
            b3[bi] = @intCast((round + @as(i32, @intCast(bi)) + 3) & 255);
        }
        var iov = [_]std.os.iovec{
            .{ .iov_base = &b0, .iov_len = ECHO_SEG },
            .{ .iov_base = &b1, .iov_len = ECHO_SEG },
            .{ .iov_base = &b2, .iov_len = ECHO_SEG },
            .{ .iov_base = &b3, .iov_len = ECHO_SEG },
        };
        const need: usize = ECHO_SEG * 4;
        const nw = std.os.writev(stream.handle, &iov) catch return error.Write;
        if (nw != need) return error.Write;
        const nr = std.os.readv(stream.handle, &iov) catch return error.Read;
        if (nr != need) return error.Read;
        for (b0) |b| sum +%= @as(i32, @intCast(b));
        for (b1) |b| sum +%= @as(i32, @intCast(b));
        for (b2) |b| sum +%= @as(i32, @intCast(b));
        for (b3) |b| sum +%= @as(i32, @intCast(b));
    }
    std.process.exit(@intCast(sum & 255));
}
