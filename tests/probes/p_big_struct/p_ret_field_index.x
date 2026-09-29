allow(padding) struct V { ptr: *u8; length: i32; gen: u64; }
function mk(p: *u8): V { return { ptr: p, length: 1, gen: 2 }; }
function main(): i32 { let s: *u8 = "ABC"; let v: V = mk(s); if (v.ptr[0] != 65) { return 5; } return 0; }
