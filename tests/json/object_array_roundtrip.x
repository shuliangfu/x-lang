// STD-035：object/array 序列化 round-trip 烟测
//
// 构建 {"name":"alice","age":30,"tags":["a","b"]} 并用 STD-034 游标解析校验。
const json = import("std.json");

/** 逐字节比较 key_buf[0..key_len) 与期望 ASCII；匹配 1，否则 0。 */
function key_eq(key_buf: *u8, key_len: i32, b0: u8, b1: u8, b2: u8, b3: u8, need: i32): i32 {
  if (key_len != need) { return 0; }
  if (need > 0 && key_buf[0] != b0) { return 0; }
  if (need > 1 && key_buf[1] != b1) { return 0; }
  if (need > 2 && key_buf[2] != b2) { return 0; }
  if (need > 3 && key_buf[3] != b3) { return 0; }
  return 1;
}

function main(): i32 {
  let buf: u8[128] = [];
  let off: i32 = 0;
  let n: i32 = 0;
  let k_name: u8[4] = [110, 97, 109, 101];
  let k_age: u8[3] = [97, 103, 101];
  let k_tags: u8[4] = [116, 97, 103, 115];
  let v_alice: u8[5] = [97, 108, 105, 99, 101];
  let v_a: u8[1] = [97];
  let v_b: u8[1] = [98];

  n = json.append_object(&buf[0], 128, off);
  if (n < 0) { return 1; }
  off = off + n;
  n = json.append_key(&buf[0], 128, off, &k_name[0], 4);
  if (n < 0) { return 2; }
  off = off + n;
  n = json.append_string_value(&buf[0], 128, off, &v_alice[0], 5);
  if (n < 0) { return 3; }
  off = off + n;
  n = json.append_comma(&buf[0], 128, off);
  if (n < 0) { return 4; }
  off = off + n;
  n = json.append_key(&buf[0], 128, off, &k_age[0], 3);
  if (n < 0) { return 5; }
  off = off + n;
  n = json.append_number_at(&buf[0], 128, off, 30.0);
  if (n != 2) { return 6; }
  off = off + n;
  n = json.append_comma(&buf[0], 128, off);
  if (n < 0) { return 7; }
  off = off + n;
  n = json.append_key(&buf[0], 128, off, &k_tags[0], 4);
  if (n < 0) { return 8; }
  off = off + n;
  n = json.append_array(&buf[0], 128, off);
  if (n < 0) { return 9; }
  off = off + n;
  n = json.append_string_value(&buf[0], 128, off, &v_a[0], 1);
  if (n < 0) { return 10; }
  off = off + n;
  n = json.append_comma(&buf[0], 128, off);
  if (n < 0) { return 11; }
  off = off + n;
  n = json.append_string_value(&buf[0], 128, off, &v_b[0], 1);
  if (n < 0) { return 12; }
  off = off + n;
  n = json.append_array_end(&buf[0], 128, off);
  if (n < 0) { return 13; }
  off = off + n;
  n = json.append_object_end(&buf[0], 128, off);
  if (n < 0) { return 14; }
  off = off + n;

  let consumed: i32 = 0;
  if (json.skip_value(&buf[0], off, &consumed) != 0) { return 15; }
  if (consumed != off) { return 16; }

  let cur: json.JsonCursor = json.cursor_init(&buf[0], off);
  let key: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let key_len: i32 = 0;
  let nr: i32 = 0;
  let out_val: f64 = 0.0;
  let vlen: i32 = 0;
  let vcon: i32 = 0;
  let vp: *u8 = 0 as *u8;
  let tag_count: i32 = 0;
  let has_elem: i32 = 0;

  if (json.cursor_enter_object(&cur) != 0) { return 17; }
  while (true) {
    nr = json.cursor_object_next(&cur, &key[0], 16, &key_len);
    if (nr == 0) { break; }
    if (nr < 0) { return 18; }
    if (key_eq(&key[0], key_len, 110, 97, 109, 101, 4) != 0) {
      vp = json.parse_string_view(&cur.ptr[cur.off], cur.len - cur.off, &vlen, &vcon);
      if (vp == 0 as *u8) { return 19; }
      if (vlen != 5) { return 20; }
      if (json.cursor_skip_value(&cur) != 0) { return 21; }
      continue;
    }
    if (key_eq(&key[0], key_len, 97, 103, 101, 0, 3) != 0) {
      if (json.parse_number(&cur.ptr[cur.off], cur.len - cur.off, &out_val, &vcon) != 0) { return 22; }
      if (out_val != 30.0) { return 23; }
      if (json.cursor_skip_value(&cur) != 0) { return 24; }
      continue;
    }
    if (key_eq(&key[0], key_len, 116, 97, 103, 115, 4) != 0) {
      if (json.cursor_enter_array(&cur) != 0) { return 25; }
      has_elem = json.cursor_array_has_elem(&cur);
      while (has_elem == 1) {
        vp = json.parse_string_view(&cur.ptr[cur.off], cur.len - cur.off, &vlen, &vcon);
        if (vp == 0 as *u8) { return 26; }
        if (vlen != 1) { return 27; }
        if (json.cursor_skip_value(&cur) != 0) { return 28; }
        tag_count = tag_count + 1;
        has_elem = json.cursor_array_has_elem(&cur);
      }
      if (tag_count != 2) { return 29; }
      continue;
    }
    if (json.cursor_skip_value(&cur) != 0) { return 30; }
  }
  return 0;
}
