// zero_copy_sendfile.zig — Z1：sendfile 文件→socket（Zig -O2 对照，Linux/macOS）
const std = @import("std");
const builtin = @import("builtin");

const path = "tests/bench/.io_mmap_bench_tmp";
const bench_bytes: u64 = 16777216;
const chunk: usize = 1048576;
const sink_port_default: u16 = 38459;

fn sendfile_once(out_fd: std.posix.fd_t, in_fd: std.posix.fd_t, count: usize) !usize {
    if (builtin.os.tag == .linux) {
        const n = try std.os.linux.sendfile(out_fd, in_fd, null, count);
        return @intCast(n);
    }
    if (builtin.os.tag == .macos) {
        var len: std.os.off_t = @intCast(count);
        const rc = std.os.system.sendfile(in_fd, out_fd, 0, &len, null, 0);
        if (rc < 0)
            return error.SendfileFailed;
        return @intCast(len);
    }
    return error.UnsupportedOs;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);
    var port: u16 = sink_port_default;
    if (args.len >= 2)
        port = @intCast(std.fmt.parseInt(u16, args[1], 10) catch sink_port_default);

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const addr = try std.net.Address.parseIp4("127.0.0.1", port);
    const sock = try std.net.tcpConnectToAddress(addr);
    defer sock.close();

    var sent: u64 = 0;
    while (sent < bench_bytes) {
        const left = bench_bytes - sent;
        const ask: usize = @intCast(if (left > chunk) chunk else left);
        const n = try sendfile_once(sock.handle, file.handle, ask);
        if (n == 0)
            return error.ShortWrite;
        sent += n;
    }
    std.process.exit(@intCast(sent & 255));
}
