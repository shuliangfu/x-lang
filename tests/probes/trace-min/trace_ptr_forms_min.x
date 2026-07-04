function cond_only(pos: *i32, out_cap: i32): i32 {
  if (*pos < 0 || *pos >= out_cap) { return 1; }
  return 0;
}

function index_only(out: *u8, pos: *i32, b: u8): void {
  out[*pos] = b;
}

function deref_assign_only(pos: *i32): void {
  *pos = *pos + 1;
}
