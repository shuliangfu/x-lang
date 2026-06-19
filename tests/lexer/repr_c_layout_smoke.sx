// B-03 v1：#[repr(C)] 允许 C 式隐式 padding（u8 后 u32 对齐到 offset 4）。
#[repr(C)]
struct Header {
  tag: u8
  len: u32
}

function main(): i32 {
  let h: Header = Header { tag: 1, len: 42 };
  return h.tag + h.len;
}
