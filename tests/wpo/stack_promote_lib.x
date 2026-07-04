// stack_promote_lib.x — WPO-S3 跨模块：struct helper 定义在独立编译单元
/** 两字段 POD。 */
struct Pair {
  a: i32
  b: i32
}

/** 按值构造并返回 struct（跨模块 call 候选）。 */
function make_pair(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

/** 按值读字段求和。 */
function sum_pair(p: Pair): i32 {
  return p.a + p.b;
}

/** 经 *Pair 读字段求和（跨模块 call 传 &local 逃逸烟测）。 */
function read_pair_ptr(p: *Pair): i32 {
  return p.a + p.b;
}
