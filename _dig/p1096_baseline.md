# P1096 Soft Cap Prefer field_assign／return_sret baseline (Asia/Shanghai 2026-11-03 ~16:06)

Hosts (SHA12 confirmed this turn):
- tip alone Soft Cap Prefer HOLD PROD **74d0bd9c9fbf** size=8082432
- dig plant call_arg **3f6ad9910c48** size=8089600
- dig plant nested_let **09fe181dbd0e** size=8091136
- CapSoft Prefer w1521 **1f78def393fc** size=8182784 (contrast)

Fixtures (`C:\xlang_tmp\p1096\` from p1094):
```
// field_assign.x — oracle sum=6 if p.a=1 store works
struct Point { a: i64; b: i64; c: i64 }
function main(): i32 {
  let p: Point = Point{a: 0, b: 2, c: 3};
  p.a = 1;
  return (p.a + p.b + p.c) as i32;
}

// return_sret.x — oracle sum=6 if sret mk fills Point{1,2,3}
struct Point { a: i64; b: i64; c: i64 }
function mk(): Point { return Point{a: 1, b: 2, c: 3}; }
function main(): i32 {
  let p: Point = mk();
  return (p.a + p.b + p.c) as i32;
}
```

| host | field_assign Prefer.o/run | return_sret Prefer.o/run | softcap_lit protect |
|---|---|---|---|
| tip alone 74d0 | 271 / **6** | 356 / **6** | 463 / **0** |
| dig 3f6ad | 271 / **6** | 356 / **6** | 463 / **0** |
| dig 09fe | 271 / **6** | 356 / **6** | 463 / **0** |
| CapSoft 1f78 | 271 / **6** | 356 / **6** | 463 / **0** |

Soft Cap Prefer tip alone Prefer `return_sret_thin.x` → Prefer.o=**0** hollow (dig SoftCap Prefer tip-module hollow HOLD / **banned** primary).

HOLD Soft Cap / nail / tiphead Prefer-M2 9ecd / Cap tip Prefer-M2b 10470224 NOT raised this baseline.
