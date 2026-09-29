struct S { ptr: *u8; n: i64; }
function main(): i32 { let s: *u8 = "ABC"; let v: S = { ptr: s, n: 1 }; let q: *S = &v; if (q.ptr[0] != 65) { return 5; } return 0; }
