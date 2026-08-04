// http_chunked_decode_bench.zig — I08：HTTP chunked body 解码循环（Zig -O2 对照）
//
// Mirrors bench/i08_http_chunked_decode_bench.x: parse a fixed 86-byte chunked
// HTTP response 1000 times, decoding the body into an 8-byte output buffer.
// Each call must yield exactly 5 bytes ("hello"); return total bytes decoded.
const std = @import("std");

const RESP: [86]u8 = .{
    'H', 'T', 'T', 'P', '/', '1', '.', '1', ' ', '2', '0', '0', ' ', 'O', 'K', '\r',
    '\n',
    'T', 'r', 'a', 'n', 's', 'f', 'e', 'r', '-', 'E', 'n', 'c', 'o', 'd', 'i', 'n',
    'g', ':', ' ', 'c', 'h', 'u', 'n', 'k', 'e', 'd', '\r', '\n',
    'C', 'o', 'n', 'n', 'e', 'c', 't', 'i', 'o', 'n', ':', ' ', 'k', 'e', 'e', 'p',
    '-', 'a', 'l', 'i', 'v', 'e', '\r', '\n',
    '\r', '\n',
    '5', '\r', '\n', 'h', 'e', 'l', 'l', 'o', '\r', '\n',
    '0', '\r', '\n', '\r', '\n',
};
const HDR_END: usize = 71;

/// Decode a chunked body starting at hdr_end into out; returns byte count
/// written, or -1 on malformed input. Mirrors http.decode_chunked_body.
fn decodeChunkedBody(resp: []const u8, hdr_end: usize, out: []u8) i32 {
    var i: usize = hdr_end;
    var ow: usize = 0;
    while (i < resp.len) {
        // Parse hex chunk size up to '\r'
        var size: usize = 0;
        var got_digit: bool = false;
        while (i < resp.len) {
            const c = resp[i];
            if (c == '\r') {
                i += 1;
                break;
            }
            const d: u8 = switch (c) {
                '0'...'9' => c - '0',
                'a'...'f' => c - 'a' + 10,
                'A'...'F' => c - 'A' + 10,
                else => return -1,
            };
            size = size * 16 + d;
            got_digit = true;
            i += 1;
        }
        if (!got_digit) return -1;
        // Expect '\n' after '\r'
        if (i >= resp.len or resp[i] != '\n') return -1;
        i += 1;
        if (size == 0) break; // terminal chunk
        // Copy chunk data
        if (i + size > resp.len) return -1;
        if (ow + size > out.len) return -1;
        @memcpy(out[ow .. ow + size], resp[i .. i + size]);
        ow += size;
        i += size;
        // Trailing CRLF after chunk data
        if (i + 2 > resp.len) return -1;
        if (resp[i] != '\r' or resp[i + 1] != '\n') return -1;
        i += 2;
    }
    return @intCast(ow);
}

pub fn main() !void {
    var body: [8]u8 = undefined;
    var total: i32 = 0;
    var i: i32 = 0;
    while (i < 1000) : (i += 1) {
        const n = decodeChunkedBody(&RESP, HDR_END, &body);
        if (n != 5) std.process.exit(1);
        total += n;
    }
    // .x main returns i32 total; exit code is low 8 bits (5000 & 0xff == 136).
    std.process.exit(@intCast(total & 0xff));
}
