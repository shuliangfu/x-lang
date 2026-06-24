/**
 * DOD-S1 L1 bench：SoA 列主序遍历 arr[i].x（4096 粒子）。
 * 正确性：每 x=1 → sum=4096；main 返回 sum/256（=16，规避 shell exit 8-bit 截断）。
 */
struct Particle soa {
  x: i32
  y: i32
  z: i32
}

function main(): i32 {
  let n: i32 = 4096;
  let arr: Particle[4096] = [];
  let i: i32 = 0;
  while (i < n) {
    arr[i].x = 1;
    arr[i].y = 2;
    arr[i].z = 3;
    i = i + 1;
  }
  let s: i32 = 0;
  i = 0;
  while (i < n) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s / 256;
}
