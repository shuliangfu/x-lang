// LANG-006：一元取负与按位取反（CTFE 求值 260；进程 exit 仅 8 位故 return & 255 → 4）
function main(): i32 {
  const v: i32 = -(-5) + (~0 & 255);
  return v & 255;
}
