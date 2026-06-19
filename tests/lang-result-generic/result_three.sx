/**
 * LANG-010 烟测：Result<T,E> 模板 + Result<i32,i32> / Result<u8,i32> / Result<bool,i32> 三组合金样。
 */
allow(padding) struct Result<T, E> {
  value: T;
  err: E;
}

function main(): i32 {
  let a: Result<i32, i32> = Result<i32, i32> { value: 10, err: 0 };
  let b: Result<u8, i32> = Result<u8, i32> { value: 5, err: 0 };
  let c: Result<bool, i32> = Result<bool, i32> { value: true, err: 0 };
  let d: Result<i32, i32> = Result<i32, i32> { value: 0, err: 7 };

  if (a.err != 0 || a.value != 10) { return 1; }
  if (b.err != 0 || b.value != 5) { return 2; }
  if (c.err != 0 || !c.value) { return 3; }
  if (d.err != 7 || d.value != 0) { return 4; }

  return 0;
}
