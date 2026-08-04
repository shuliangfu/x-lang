// r06_sort.zig — Quicksort benchmark (matches r06_sort.c / .x)
// Uses the same Lomuto-partition quicksort (last-element pivot) as C/xlang.
const std = @import("std");

fn partition(arr: []i32, lo: i32, hi: i32) i32 {
    const pivot = arr[@intCast(hi)];
    var i: i32 = lo - 1;
    var j: i32 = lo;
    while (j < hi) : (j += 1) {
        if (arr[@intCast(j)] <= pivot) {
            i += 1;
            const tmp = arr[@intCast(i)];
            arr[@intCast(i)] = arr[@intCast(j)];
            arr[@intCast(j)] = tmp;
        }
    }
    const tmp = arr[@intCast(i + 1)];
    arr[@intCast(i + 1)] = arr[@intCast(hi)];
    arr[@intCast(hi)] = tmp;
    return i + 1;
}

fn quicksort(arr: []i32, lo: i32, hi: i32) void {
    if (lo < hi) {
        const p = partition(arr, lo, hi);
        quicksort(arr, lo, p - 1);
        quicksort(arr, p + 1, hi);
    }
}

pub fn main() !void {
    const n: i32 = 10000;
    var arr: [10000]i32 = undefined;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        arr[@intCast(i)] = (i *% 1103515245 +% 12345) & 0xFFFF;
    }
    quicksort(&arr, 0, n - 1);
    const result: i32 = arr[0] + arr[@intCast(n - 1)];
    std.process.exit(@intCast(result & 0xFF));
}
