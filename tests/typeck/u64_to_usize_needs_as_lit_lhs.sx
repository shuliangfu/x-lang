/** 负例：字面量在左时也禁止把 u64 算术结果隐式塞进 usize。 */
allow(padding) struct Entry { off: u64; }
allow(padding) struct Store { mt: Entry[4]; }

function bad_offset(s: *Store, i: u32): usize {
  return 24 + s.mt[i].off;
}

function main(): i32 { return 0; }
