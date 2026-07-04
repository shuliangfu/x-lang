// MEM-C1 AL-06 负例：with_arena + region 内 slice 作为未标注返回值逃逸。
extern function slice_src(): u8[];

function leak(): u8[] {
  with_arena(4096) {
    region ra {
      let s: u8[] = slice_src();
      return s;
    }
  }
  return slice_src();
}

function main(): i32 {
  return 0;
}
