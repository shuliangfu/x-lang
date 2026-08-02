// zero_copy_readwrite.zig — I07：用户态 read+write 文件→socket（Zig 0.16 -OReleaseFast 对照）
//
// Mirrors bench/i07_zero_copy_readwrite.x: open 16 MiB fixture, connect to a
// sink TCP server on 127.0.0.1:<port>, then loop std.posix.read 64 KiB chunks
// and stream them to the socket via libc send until 16 MiB forwarded.
// Exit sent & 255.
const std = @import("std");

const PATH = "bench/.io_mmap_bench_tmp";
const BENCH_BYTES: u64 = 16 * 1024 * 1024;
const CHUNK: usize = 64 * 1024;
const SINK_PORT_DEFAULT: u16 = 38461;

extern "c" fn socket(domain: c_uint, sock_type: c_uint, protocol: c_uint) c_int;
extern "c" fn connect(fd: c_int, addr: *const std.posix.sockaddr, len: c_uint) c_int;
extern "c" fn send(fd: c_int, buf: [*]const u8, n: usize, flags: c_uint) isize;
extern "c" fn close(fd: c_int) c_int;

const AF_INET: c_uint = 2;
const SOCK_STREAM: c_uint = 1;

pub fn main(init: std.process.Init) !void {
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

    var buf: [CHUNK]u8 = undefined;
    var sent: u64 = 0;
    while (sent < BENCH_BYTES) {
        const left = BENCH_BYTES - sent;
        const ask: usize = @intCast(if (left > CHUNK) CHUNK else left);
        const nr = try std.posix.read(file, buf[0..ask]);
        if (nr == 0) std.process.exit(3);
        var off: usize = 0;
        while (off < nr) {
            const nw = send(sock, buf[off..].ptr, nr - off, 0);
            if (nw <= 0) std.process.exit(4);
            off += @intCast(nw);
        }
        sent += nr;
    }
    std.process.exit(@intCast(sent & 255));
}
