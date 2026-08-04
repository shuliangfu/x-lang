// r08_regex_match_naive_stub.zig — naive backtracking regex stub (matches r08_regex_match_naive_stub.c)
// Pure scalar backtracking regex match (no first-byte jump, no literal_only fast path).
const std = @import("std");

fn consume_atom(pat: []const u8, p: *usize) bool {
    if (p.* >= pat.len) return false;
    if (pat[p.*] == '\\') {
        if (p.* + 1 >= pat.len) return false;
        p.* += 2;
        return true;
    }
    if (pat[p.*] == '*' or pat[p.*] == '?') return false;
    p.* += 1;
    return true;
}

fn match_atom_char(atom: []const u8, str: []const u8, s: *usize) bool {
    if (s.* >= str.len or atom.len == 0) return false;
    const ch = str[s.*];
    if (atom[0] == '\\') {
        if (atom.len < 2) return false;
        if (ch != atom[1]) return false;
    } else if (ch != atom[0]) {
        return false;
    }
    s.* += 1;
    return true;
}

fn match_here(pat: []const u8, p: *usize, str: []const u8, s: *usize) bool {
    while (p.* < pat.len) {
        const atom_start = p.*;
        if (!consume_atom(pat, p)) return false;
        const atom_end = p.*;
        if (p.* < pat.len and pat[p.*] == '*') {
            p.* += 1;
            while (true) {
                if (match_here(pat, p, str, s)) return true;
                var s2 = s.*;
                if (!match_atom_char(pat[atom_start..atom_end], str, &s2)) break;
                s.* = s2;
            }
            return false;
        }
        if (!match_atom_char(pat[atom_start..atom_end], str, s)) return false;
    }
    return true;
}

fn search_slow(pat: []const u8, str: []const u8) i32 {
    var i: usize = 0;
    while (i <= str.len) : (i += 1) {
        var p: usize = 0;
        var s: usize = i;
        if (match_here(pat, &p, str[0..], &s)) return 0;
    }
    return -1;
}

pub fn main() !void {
    const loops: usize = 500_000;
    var acc: i32 = 0;
    const pat_lit = "needle";
    var hay_lit: [256]u8 = undefined;
    @memset(&hay_lit, 'x');
    @memcpy(hay_lit[249..255], "needle");
    var i: usize = 0;
    while (i < loops) : (i += 1) {
        acc += search_slow(pat_lit, hay_lit[0..]);
    }

    const pat_star = "a*b";
    var hay_star: [65]u8 = undefined;
    @memset(hay_star[0..64], 'a');
    hay_star[64] = 'b';
    i = 0;
    while (i < loops) : (i += 1) {
        acc += search_slow(pat_star, hay_star[0..]);
    }

    std.process.exit(@intCast(acc & 0xFF));
}
