// zero_copy_splice.zig — I07：splice(2) 文件→socket 零拷贝（Zig 0.16 -OReleaseFast 对照，Linux only）
//
// Mirrors bench/i07_zero_copy_splice.x: open 16 MiB fixture, connect to sink
// TCP server on 127.0.0.1:<port>, then loop splice(fd_in, fd_out, count) of
// 1 MiB chunks until 16 MiB forwarded. Linux splice(2) only — on macOS we
// exit 99 so the harness can SKIP the comparison cleanly.
const std = @import("std");
const builtin = @import("builtin");

const PATH = "bench/.io_mmap_bench_tmp";
const BENCH_BYTES: u64 = 16 * 1024 * 1024;
const CHUNK: usize = 1024 * 1024;
const SINK_PORT_DEFAULT: u16 = 38459;

extern "c" fn socket(domain: c_uint, sock_type: c_uint, protocol: c_uint) c_int;
extern "c" fn connect(fd: c_int, addr: *const std.posix.sockaddr, len: c_uint) c_int;
extern "c" fn close(fd: c_int) c_int;
// Linux: ssize_t splice(int fd_in, loff_t *off_in, int fd_out, loff_t *off_out, size_t len, unsigned int flags);
extern "c" fn splice(fd_in: c_int, off_in: ?*i64, fd_out: c_int, off_out: ?*i64, len: usize, flags: c_uint) isize;

const AF_INET: c_uint = 2;
const SOCK_STREAM: c_uint = 1;

pub fn main(init: std.process.Init) !void {
    if (builtin.os.tag != .linux) {
        // splice(2) is Linux-only; no macOS equivalent. SKIP cleanly.
        std.process.exit(99);
    }

    var port: u16 = SINK_PORT_DEFAULT;
    var args_it = init.minimal.args.iterate();
    _ = args_it.next();
    if (args_it.next()) |p| {
        port = std.fmt.parseInt(u16, p, 10) catch SINK_PORT_DEFAULT;
    }

    const file = try std.posix.openat(std.posix.AT.FDCWD, PATH, .{ .ACCMODE = .RDONLY }, 0);
    defer _ = close(file);
    const sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) return error.Socket;
    var addr: std.posix.sockaddr.in = .{
        .family = @intCast(AF_INET),
        .port = std.mem.nativeToBig(u16, port),
        .addr = std.mem.nativeToBig(u32, 0x7f000001),
        .zero = [_]u8{0} ** 8,
    };
    if (connect(sock, @ptrCast(&addr), @sizeOf(@TypeOf(addr))) < 0) {
        _ = close(file);
        _ = close(sock);
        return error.Connect;
    }
    defer _ = close(sock);

    var sent: u64 = 0;
    while (sent < BENCH_BYTES) {
        const left = BENCH_BYTES - sent;
        const ask: usize = if (left > CHUNK) CHUNK else left;
        // splice(fd_in, off_in=NULL, fd_out, off_out=NULL, len, flags=0)
        const n = splice(file, null, sock, null, ask, 0);
        if (n <= 0) std.process.exit(3);
        sent += @as(u64, @intCast(n));
    }
    std.process.exit(@intCast(sent & 255));
}
