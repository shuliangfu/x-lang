allow(padding) struct V { ptr: *u8; length: i32; gen: u64; }
function mk(p: *u8, n: i32, g: u64): V { let q: *u8 = p; return { ptr: q, length: n, gen: g }; }
function main(): i32 { let v: V = mk(64 as *u8, 5, 7 as u64); if (v.length != 5) { return 1; } if (v.gen != 7) { return 2; } if (v.ptr != 64 as *u8) { return 3; } return 0; }
