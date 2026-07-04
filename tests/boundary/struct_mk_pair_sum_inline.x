// struct_mk_pair_sum_inline.x — add_pair(mk(i,2)) 嵌套 CALL 内联：struct 按值返回 + 字段求和
struct Pair {
  a: i32
  b: i32
}

/** 由形参构造小 struct 按值返回。 */
function mk(a: i32, b: i32): Pair {
  return Pair { a: a, b: b };
}

/** 按值累加 struct 两 i32 字段。 */
function add_pair(p: Pair): i32 {
  return p.a + p.b;
}

function main(): i32 {
  let n: i32 = 5;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s + add_pair(mk(i, 2));
    i = i + 1;
  }
  return s;
}
