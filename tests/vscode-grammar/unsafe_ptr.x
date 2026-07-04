// TOOL-009 golden：unsafe 块与指针类型
function read_u8(p: *u8): u8 {
  unsafe {
    return *p;
  }
}
