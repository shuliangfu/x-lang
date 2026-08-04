// http_get_bench.zig — I08：HTTP GET 循环 P99 延迟基准（Zig 0.16 -OReleaseFast 对照）
//
// Mirrors bench/i08_http_get_bench.x: connect to http://127.0.0.1:<port>/,
// issue 64 sequential GET requests, capture per-request latency (us) and
// total elapsed (ns). Print BENCH_ELAPSED_NS and BENCH_P99_US to stderr.
// Uses libc socket/connect/send/recv/close + std.Io.Timestamp. std.http was
// removed in 0.16, so HTTP/1.0 GET is hand-rolled over a raw TCP socket.
const std = @import("std");

const HTTP_PORT_DEFAULT: u16 = 38460;
const N_REQ: usize = 64;
const MAX_SAMPLES: usize = 64;

extern "c" fn socket(domain: c_uint, sock_type: c_uint, protocol: c_uint) c_int;
extern "c" fn connect(fd: c_int, addr: *const std.posix.sockaddr, len: c_uint) c_int;
extern "c" fn send(fd: c_int, buf: [*]const u8, n: usize, flags: c_uint) isize;
extern "c" fn recv(fd: c_int, buf: [*]u8, n: usize, flags: c_uint) isize;
extern "c" fn close(fd: c_int) c_int;

const AF_INET: c_uint = 2;
const SOCK_STREAM: c_uint = 1;

var lat_us: [MAX_SAMPLES]i64 = undefined;

fn benchNowNs(io: std.Io) i128 {
    return @intCast(std.Io.Timestamp.now(io, .awake).nanoseconds);
}

fn cmpI64(_: void, a: i64, b: i64) bool {
    return a < b;
}

fn benchP99Us(n: usize) i64 {
    if (n == 0) return 0;
    var tmp: [MAX_SAMPLES]i64 = undefined;
    @memcpy(tmp[0..n], lat_us[0..n]);
    std.mem.sort(i64, tmp[0..n], {}, cmpI64);
    var idx: usize = (n * 99) / 100;
    if (idx >= n) idx = n - 1;
    return tmp[idx];
}

pub fn main(init: std.process.Init) !void {
    var port: u16 = HTTP_PORT_DEFAULT;
    var args_it = init.minimal.args.iterate();
    _ = args_it.next();
    if (args_it.next()) |p| {
        port = std.fmt.parseInt(u16, p, 10) catch HTTP_PORT_DEFAULT;
    }

    var addr: std.posix.sockaddr.in = .{
        .family = @intCast(AF_INET),
        .port = std.mem.nativeToBig(u16, port),
        .addr = std.mem.nativeToBig(u32, 0x7f000001),
        .zero = [_]u8{0} ** 8,
    };

    const req = "GET / HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n";
    var out: [256]u8 = undefined;
    var n_samples: usize = 0;
    const t_all0 = benchNowNs(init.io);
    var i: usize = 0;
    while (i < N_REQ) : (i += 1) {
        const t0 = benchNowNs(init.io);
        const fd = socket(AF_INET, SOCK_STREAM, 0);
        if (fd < 0) return error.Socket;
        if (connect(fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr))) < 0) {
            _ = close(fd);
            return error.Connect;
        }
        // Send HTTP/1.0 GET request.
        var off: usize = 0;
        while (off < req.len) {
            const nw = send(fd, req.ptr + off, req.len - off, 0);
            if (nw <= 0) {
                _ = close(fd);
                std.process.exit(1);
            }
            off += @intCast(nw);
        }
        // Receive response — need at least 4 bytes to verify "HTTP" prefix.
        var total: usize = 0;
        while (total < 4) {
            const nr = recv(fd, out[total..].ptr, out.len - total, 0);
            if (nr <= 0) break;
            total += @intCast(nr);
        }
        _ = close(fd);
        const t1 = benchNowNs(init.io);
        if (total < 4) std.process.exit(1);
        if (!(out[0] == 'H' and out[1] == 'T' and out[2] == 'T' and out[3] == 'P')) std.process.exit(2);
        const dt_ns: i64 = @intCast(t1 - t0);
        lat_us[n_samples] = @divTrunc(dt_ns, 1000);
        n_samples += 1;
    }
    const t_all1 = benchNowNs(init.io);
    const elapsed_ns: i64 = @intCast(t_all1 - t_all0);
    const p99: i64 = benchP99Us(n_samples);
    var stderr_buf: [128]u8 = undefined;
    var stderr = std.Io.File.stderr().writer(init.io, &stderr_buf);
    try stderr.interface.print("BENCH_ELAPSED_NS={d}\nBENCH_P99_US={d}\n", .{ elapsed_ns, p99 });
    try stderr.interface.flush();
    std.process.exit(0);
}
