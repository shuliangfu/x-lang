// lib_export.x — 导出与私有函数
export function public_add(a: i32, b: i32): i32 {
  return a + b;
}

function private_mul(a: i32, b: i32): i32 {
  return a * b;
}

export function public_via_private(x: i32): i32 {
  return private_mul(x, 2);
}
