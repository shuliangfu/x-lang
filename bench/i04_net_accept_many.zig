// net_accept_many.zig — I04 accept many server (Zig 0.16 -OReleaseFast 对照)
//
// Mirrors bench/i04_net_accept_many_server.c: listen on 127.0.0.1:<port>,
// accept NET_BENCH_CONNS sequential TCP connections, close each immediately
// with SO_LINGER=0 to mitigate TIME_WAIT accumulation. Uses libc
// socket/bind/listen/accept/close/setsockopt.
//
// Fairness note: X std uses net.accept_many (io_uring multishot accept on
// Linux); C and Zig both use plain accept loop (same syscall strategy), so
// the three-way comparison is X-batch-vs-C/Zig-plain, not X-vs-Zig-unfair.
const std = @import("std");

const NET_BENCH_PORT_DEFAULT: u16 = 38456;
const NET_BENCH_CONNS_DEFAULT: i32 = 4096;

extern "c" fn socket(domain: c_uint, sock_type: c_uint, protocol: c_uint) c_int;
extern "c" fn setsockopt(fd: c_int, level: c_int, name: c_int, val: *const anyopaque, len: c_uint) c_int;
extern "c" fn bind(fd: c_int, addr: *const std.posix.sockaddr, len: c_uint) c_int;
extern "c" fn listen(fd: c_int, backlog: c_int) c_int;
extern "c" fn accept(fd: c_int, addr: ?*std.posix.sockaddr, len: ?*c_uint) c_int;
extern "c" fn close(fd: c_int) c_int;

const AF_INET: c_uint = 2;
const SOCK_STREAM: c_uint = 1;
const SOL_SOCKET: c_int = 0xffff;
const SO_REUSEADDR: c_int = 0x0004;
const SO_LINGER: c_int = 0x0080;

/// POSIX struct linger: { int l_onoff; int l_linger; }
const Linger = extern struct {
    l_onoff: i32,
    l_linger: i32,
};

pub fn main(init: std.process.Init) !void {
    var port: u16 = NET_BENCH_PORT_DEFAULT;
    var target: i32 = NET_BENCH_CONNS_DEFAULT;
    var args_it = init.minimal.args.iterate();
    _ = args_it.next();
    if (args_it.next()) |p| {
        port = std.fmt.parseInt(u16, p, 10) catch NET_BENCH_PORT_DEFAULT;
    }
    if (args_it.next()) |n| {
        const parsed = std.fmt.parseInt(i32, n, 10) catch NET_BENCH_CONNS_DEFAULT;
        if (parsed > 0) target = parsed;
    }

    const listener = socket(AF_INET, SOCK_STREAM, 0);
    if (listener < 0) return error.Socket;

    const opt: i32 = 1;
    _ = setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &opt, @sizeOf(i32));

    var sin: std.posix.sockaddr.in = .{
        .family = @intCast(AF_INET),
        .port = std.mem.nativeToBig(u16, port),
        .addr = std.mem.nativeToBig(u32, 0x7f000001),
        .zero = [_]u8{0} ** 8,
    };
    if (bind(listener, @ptrCast(&sin), @sizeOf(@TypeOf(sin))) != 0) {
        _ = close(listener);
        return error.Bind;
    }
    if (listen(listener, 256) != 0) {
        _ = close(listener);
        return error.Listen;
    }

    var total: i32 = 0;
    while (total < target) {
        const fd = accept(listener, null, null);
        if (fd < 0) {
            _ = close(listener);
            return error.Accept;
        }
        // SO_LINGER=0 to mitigate TIME_WAIT accumulation under heavy bench.
        const ling: Linger = .{ .l_onoff = 1, .l_linger = 0 };
        _ = setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, @sizeOf(Linger));
        _ = close(fd);
        total += 1;
    }

    if (close(listener) != 0) return error.CloseListener;
    std.process.exit(0);
}
