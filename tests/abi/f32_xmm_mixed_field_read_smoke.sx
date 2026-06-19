/**
 * SysV mixed 实参 + AoS 字段回读烟测（SHUX_ABI_F32_XMM=1）：
 * write3 经 *T(gp) + 三 f32(xmm) 写入；main 读 t.x/y/z 求和 → exit=6。
 */
struct F32Tri {
  x: f32
  y: f32
  z: f32
}

/** 写入三元组（形参 f32 须从 xmm 读取；caller 侧验证 AoS 0/4/8 布局）。 */
function write3(v: *F32Tri, x: f32, y: f32, z: f32): f32 {
  v.x = x;
  v.y = y;
  v.z = z;
  return 0.0;
}

function main(): i32 {
  let t: F32Tri = F32Tri { x: 0.0, y: 0.0, z: 0.0 };
  write3(&t, 1.0, 2.0, 3.0);
  let s: f32 = t.x + t.y + t.z;
  return s as i32;
}
