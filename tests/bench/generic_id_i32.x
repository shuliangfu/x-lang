// generic_id_i32.x — LANG-003 benchmark prototype：循环调用单态化 id<i32>
function id<T>(x: T): T { return x; }

function main(): i32 {
  let n: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s ^ id<i32>(i);
    i = i + 1;
  }
  return s;
}
