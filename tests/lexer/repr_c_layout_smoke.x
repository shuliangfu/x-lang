// B-03 v1：#[repr(C)] 允许 C 式隐式 padding（u8 后 u32 对齐到 offset 4）。
#[repr(C)]
struct Header {
  tag: u8
  len: u32
}

function main(): i32 {
  let h: Header = Header { tag: 1, len: 42 };
  /** 布局烟测：u8+u32 字段和须显式拓宽到 i32（禁隐式 u32→i32）。 */
  return (h.tag as i32) + (h.len as i32);
}
