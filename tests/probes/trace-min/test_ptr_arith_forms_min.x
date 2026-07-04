function test_io_append_byte(out: *u8, pos: i32, cap: i32, b: u8): i32 {
  return pos;
}

function ptr_add_index_load(s: *u8, i: i32): u8 {
  return (s + i)[0];
}

function ptr_add_only(s: *u8, i: i32): *u8 {
  return s + i;
}

function ptr_add_index_call(out: *u8, pos: i32, cap: i32, s: *u8, i: i32): i32 {
  return test_io_append_byte(out, pos, cap, (s + i)[0]);
}

function deref_store_u32(state: *u32, s: u32): void {
  *state = s;
}
