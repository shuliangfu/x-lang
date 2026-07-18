// See implementation.
// See implementation.
#[repr(C)]
struct Point { x: i32; y: i32; }
#[repr(C)]
struct Mixed { a: u8; b: u32; c: u8; }
struct PackedMixed packed { a: u8; b: u32; c: u8; }
#[repr(C)]
struct Nested { p: Point; z: i32; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: u32 = 0;

  let pt: Point = Point { x: 0x11223344, y: 0x55667788 };
  acc = acc ^ (pt.x as u32) ^ (pt.y as u32);

  let m: Mixed = Mixed { a: 0xAA, b: 0x11223344, c: 0xBB };
  acc = acc ^ (m.a as u32) ^ m.b ^ (m.c as u32);

  let pm: PackedMixed = PackedMixed { a: 0xAA, b: 0x11223344, c: 0xBB };
  acc = acc ^ (pm.a as u32) ^ pm.b ^ (pm.c as u32);

  let n: Nested = Nested { p: Point { x: 1, y: 2 }, z: -3 };
  acc = acc ^ (n.p.x as u32) ^ (n.p.y as u32) ^ (n.z as u32);

  return (acc & 0xFF) as i32;
}
