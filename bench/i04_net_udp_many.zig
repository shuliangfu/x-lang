// net_udp_many.zig — I04 UDP many server (Zig 0.16 -OReleaseFast 对照)
//
// Mirrors bench/i04_net_udp_many_server.c: bind UDP socket on 127.0.0.1:<port>,
// receive UDP_PKTS packets in batches of UDP_BATCH. On Linux uses recvmmsg
// for batch receive (same as C server's glibc path); on other platforms
// (macOS) falls back to recvfrom loop (same as C server's fallback path).
// Uses libc socket/bind/recvfrom/close/setsockopt.
//
// Fairness note: X std uses net.udp_recv_many_buf (recvmmsg wrapper); C and
// Zig both use the same platform-conditional libc strategy (recvmmsg on
// Linux, recvfrom on macOS), ensuring a fair three-way comparison.
const std = @import("std");
const builtin = @import("builtin");

const UDP_PORT_DEFAULT: u16 = 38458;
const UDP_PKTS_DEFAULT: i32 = 4096;
const UDP_BATCH: usize = 8;
const UDP_PKT_LEN: usize = 64;

extern "c" fn socket(domain: c_uint, sock_type: c_uint, protocol: c_uint) c_int;
extern "c" fn setsockopt(fd: c_int, level: c_int, name: c_int, val: *const anyopaque, len: c_uint) c_int;
extern "c" fn bind(fd: c_int, addr: *const std.posix.sockaddr, len: c_uint) c_int;
extern "c" fn close(fd: c_int) c_int;
extern "c" fn recvfrom(fd: c_int, buf: [*]u8, len: usize, flags: c_uint, addr: ?*std.posix.sockaddr, addrlen: ?*c_uint) isize;

const AF_INET: c_uint = 2;
const SOCK_DGRAM: c_uint = 2;
const SOL_SOCKET: c_int = 0xffff;
const SO_REUSEADDR: c_int = 0x0004;
// SO_RCVTIMEO: Linux=0x14 (20), macOS/BSD=0x1006 (4102).
const SO_RCVTIMEO: c_int = if (builtin.os.tag == .linux) 0x14 else 0x1006;

/// BSD struct timeval { long tv_sec; long tv_usec; } — used for SO_RCVTIMEO.
const Timeval = extern struct {
    tv_sec: i64,
    tv_usec: i32,
};

// Linux glibc mmsghdr for recvmmsg/sendmmsg.
const Mmsghdr = extern struct {
    msg_hdr: Msghdr,
    msg_len: u32,
};

const Msghdr = extern struct {
    msg_name: ?*anyopaque,
    msg_namelen: c_uint,
    msg_iov: ?*Iovec,
    msg_iovlen: c_uint,
    msg_control: ?*anyopaque,
    msg_controllen: c_uint,
    msg_flags: c_int,
};

const Iovec = extern struct {
    iov_base: *anyopaque,
    iov_len: usize,
};

/// Linux only: recvmmsg syscall wrapper. Declared at top level but only
/// referenced inside a `builtin.os.tag == .linux` comptime branch, so
/// macOS/Windows linking does not pull in the symbol.
extern "c" fn recvmmsg(fd: c_int, msgvec: [*]Mmsghdr, vlen: c_uint, flags: c_uint, timeout: ?*std.posix.timespec) c_int;

pub fn main(init: std.process.Init) !void {
    var port: u16 = UDP_PORT_DEFAULT;
    var target: i32 = UDP_PKTS_DEFAULT;
    var args_it = init.minimal.args.iterate();
    _ = args_it.next();
    if (args_it.next()) |p| {
        port = std.fmt.parseInt(u16, p, 10) catch UDP_PORT_DEFAULT;
    }
    if (args_it.next()) |n| {
        const parsed = std.fmt.parseInt(i32, n, 10) catch UDP_PKTS_DEFAULT;
        if (parsed > 0) target = parsed;
    }

    const fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) return error.Socket;

    const opt: i32 = 1;
    _ = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, @sizeOf(i32));

    var sin: std.posix.sockaddr.in = .{
        .family = @intCast(AF_INET),
        .port = std.mem.nativeToBig(u16, port),
        .addr = std.mem.nativeToBig(u32, 0x7f000001),
        .zero = [_]u8{0} ** 8,
    };
    if (bind(fd, @ptrCast(&sin), @sizeOf(@TypeOf(sin))) != 0) {
        _ = close(fd);
        return error.Bind;
    }

    // 2s recv timeout so the server does not block forever if the client is
    // not ready (matches C server's SO_RCVTIMEO guard).
    const tv: Timeval = .{ .tv_sec = 2, .tv_usec = 0 };
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, @sizeOf(Timeval));

    var bufs: [UDP_BATCH][UDP_PKT_LEN]u8 = undefined;
    var total: i32 = 0;
    var sum: i32 = 0;

    while (total < target) {
        if (builtin.os.tag == .linux) {
            // Linux: batch receive via recvmmsg (up to UDP_BATCH at once).
            var iov: [UDP_BATCH]Iovec = undefined;
            var addrs: [UDP_BATCH]std.posix.sockaddr.in = undefined;
            var msgvec: [UDP_BATCH]Mmsghdr = undefined;
            var i: usize = 0;
            while (i < UDP_BATCH) : (i += 1) {
                iov[i] = .{
                    .iov_base = &bufs[i],
                    .iov_len = UDP_PKT_LEN,
                };
                msgvec[i] = .{
                    .msg_hdr = .{
                        .msg_name = &addrs[i],
                        .msg_namelen = @sizeOf(std.posix.sockaddr.in),
                        .msg_iov = &iov[i],
                        .msg_iovlen = 1,
                        .msg_control = null,
                        .msg_controllen = 0,
                        .msg_flags = 0,
                    },
                    .msg_len = 0,
                };
            }
            const n = recvmmsg(fd, &msgvec, UDP_BATCH, 0, null);
            if (n <= 0) {
                _ = close(fd);
                return error.Recvmmsg;
            }
            var j: usize = 0;
            while (j < @as(usize, @intCast(n))) : (j += 1) {
                sum += @intCast(msgvec[j].msg_len);
            }
            total += @intCast(n);
        } else {
            // macOS/other: single-packet recvfrom fallback (same as C server).
            var peer: std.posix.sockaddr.in = undefined;
            var peer_len: c_uint = @sizeOf(std.posix.sockaddr.in);
            const got = recvfrom(fd, &bufs[0], UDP_PKT_LEN, 0, @ptrCast(&peer), &peer_len);
            if (got < 0) {
                // EAGAIN/EWOULDBLOCK under SO_RCVTIMEO — retry.
                continue;
            }
            if (got == 0) continue;
            sum += @intCast(got);
            total += 1;
        }
    }

    if (close(fd) != 0) return error.Close;
    std.process.exit(@intCast(sum & 255));
}
