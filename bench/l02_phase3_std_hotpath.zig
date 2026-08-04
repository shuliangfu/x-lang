// l02_phase3_std_hotpath.zig — phase3 std hotpath loop (matches l02_phase3_std_hotpath.x)
// Exercises datetime/compress/net stdlib calls in a tight loop.
// Zig uses stub equivalents (no xlang stdlib binding).
const std = @import("std");

const TimeZone = struct {
    offset_min: i32,
    iana_id: i32,
};

const TcpConnPool = struct {
    handle: i64,
};

// Stubs: emulate xlang stdlib calls with minimal work.
fn timezone_iana(name: []const u8, tz: *TimeZone) void {
    _ = name;
    tz.offset_min = 0;
    tz.iana_id = -1;
}

fn format_brotli() i32 { return 0; }
fn format_zstd() i32 { return 0; }
fn compress_state_bytes_for(fmt: i32) i32 { _ = fmt; return 0; }
fn tcp_pool_new(ip: u32, port: i32, size: i32) TcpConnPool {
    _ = ip; _ = port; _ = size;
    return .{ .handle = 0 };
}
fn tcp_pool_drain(p: *TcpConnPool) void { _ = p; }
fn tcp_pool_destroy(p: *TcpConnPool) void { _ = p; }

pub fn main() !void {
    const utc_name = [_]u8{ 'U', 'T', 'C', 0 };
    var tz: TimeZone = .{ .offset_min = 0, .iana_id = -1 };
    const zero: i64 = 0;
    var i: i32 = 0;
    while (i < 50_000) : (i += 1) {
        timezone_iana(utc_name[0..3], &tz);
        _ = format_brotli();
        _ = compress_state_bytes_for(format_zstd());
        var pool = tcp_pool_new(0x7f000001, 9, 1);
        if (pool.handle != zero) {
            tcp_pool_drain(&pool);
            tcp_pool_destroy(&pool);
        }
    }
}
