// TYPE-003 正例：两个独立 Linear 绑定各自 move，不应误报冲突
function take(v: Linear(i32)): i32 { return v; }

function main(): i32 {
  let a: Linear(i32) = 1;
  let b: Linear(i32) = 2;
  let x: i32 = take(a);
  let y: i32 = take(b);
  return x + y;
}
