/** 负例：u64 算术结果赋给 usize 须显式 as usize，禁止 u64→usize 隐式转换。 */
allow(padding) struct Entry { off: u64; }
allow(padding) struct Store { mt: Entry[4]; }

function bad_offset(s: *Store, i: u32): usize {
  return s.mt[i].off + 24;
}

function main(): i32 { return 0; }
