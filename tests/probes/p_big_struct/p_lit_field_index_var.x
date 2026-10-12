struct S { ptr: *u8; n: i64; }
function main(): i32 { let s: *u8 = "ABC"; let v: S = { ptr: s, n: 1 }; let i: i32 = 1; if (v.ptr[i] != 66) { return 5; } return 0; }
