/**
 * f32 AoS struct 字段读/写布局烟测：F32Tri 三 f32 字段须 0/4/8 偏移（勿 fi*8）。
 * 字面量 init + 字段读求和 → exit=6。
 */
struct F32Tri {
  x: f32
  y: f32
  z: f32
}

function main(): i32 {
  let t: F32Tri = F32Tri { x: 1.0, y: 2.0, z: 3.0 };
  let s: f32 = t.x + t.y + t.z;
  return s as i32;
}
