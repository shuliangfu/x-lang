// net_mixed_conns_requests.zig — PERF-003 混合 client（Zig -O2 对照）
const std = @import("std");

const MIXED_PORT_DEFAULT: u16 = 38459;
const MIXED_CONNS: i32 = 256;
const MIXED_ROUNDS: i32 = 16;
const MIXED_PAYLOAD: usize = 512;
const MAX_SAMPLES: usize = 256 * 16;

var lat_us: [MAX_SAMPLES]u64 = undefined;
var n_samples: usize = 0;

fn benchNowUs() u64 {
    return @as(u64, @intCast(std.time.nanoTimestamp())) / 1000;
}

fn cmpU64(_: void, a: u64, b: u64) bool {
    return a < b;
}

fn benchP99Us() u64 {
    if (n_samples == 0) return 0;
    var tmp: [MAX_SAMPLES]u64 = undefined;
    @memcpy(tmp[0..n_samples], lat_us[0..n_samples]);
    std.mem.sort(u64, tmp[0..n_samples], {}, cmpU64);
    var idx: usize = (n_samples * 99) / 100;
    if (idx >= n_samples) idx = n_samples - 1;
    return tmp[idx];
}

fn writeAll(stream: std.net.Stream, buf: []const u8) !void {
    var off: usize = 0;
    while (off < buf.len) {
        const nw = try stream.write(buf[off..]);
        if (nw == 0) return error.Write;
        off += nw;
    }
}

fn readAll(stream: std.net.Stream, buf: []u8) !void {
    var off: usize = 0;
    while (off < buf.len) {
        const nr = try stream.read(buf[off..]);
        if (nr == 0) return error.Read;
        off += @intCast(nr);
    }
}

pub fn main() !void {
    var port: u16 = MIXED_PORT_DEFAULT;
    var args = std.process.args();
    _ = args.next();
    if (args.next()) |p| {
        port = @intCast(std.fmt.parseInt(u16, p, 10) catch MIXED_PORT_DEFAULT);
    }
    const addr = std.net.Address.parseIp4("127.0.0.1", port) catch return error.Connect;
    var buf: [MIXED_PAYLOAD]u8 = undefined;
    var sum: i32 = 0;
    var ci: i32 = 0;
    n_samples = 0;
    while (ci < MIXED_CONNS) : (ci += 1) {
        const stream = std.net.tcpConnectToAddress(addr) catch return error.Connect;
        defer stream.close();
        var round: i32 = 0;
        while (round < MIXED_ROUNDS) : (round += 1) {
            var bi: usize = 0;
            while (bi < MIXED_PAYLOAD) : (bi += 1) {
                buf[bi] = @intCast((ci + round + @as(i32, @intCast(bi))) & 255);
            }
            const t0 = benchNowUs();
            try writeAll(stream, &buf);
            try readAll(stream, &buf);
            const t1 = benchNowUs();
            if (n_samples < MAX_SAMPLES) {
                lat_us[n_samples] = if (t1 > t0) t1 - t0 else 1;
                n_samples += 1;
            }
            for (buf) |b| sum +%= @as(i32, @intCast(b));
        }
    }
    const p99 = benchP99Us();
    try std.io.getStdErr().writer().print("BENCH_P99_US={d}\n", .{p99});
    std.process.exit(@intCast(sum & 255));
}
