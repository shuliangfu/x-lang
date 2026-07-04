// csv_import_alias.x — import binding -o 链接桩（从 .c 转换）
function std_csv_escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (buf == 0 as *u8 || buf_cap < 2) { return -1; }
  buf[i] = 34;
  i = i + 1;
  if (i + len + 1 >= buf_cap) { return -1; }
  while (j < len) {
    buf[i] = ptr[j];
    i = i + 1;
    j = j + 1;
  }
  if (i >= buf_cap - 1) { return -1; }
  buf[i] = 34;
  i = i + 1;
  return i;
}
