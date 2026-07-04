// tests/json/object_array_parse.x — STD-034：object/array 游标解析金样
// 输入：{"name":"alice","age":30,"tags":["a","b"]}
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
  /** {"name":"alice","age":30,"tags":["a","b"]} */
  let doc: u8[44] =
  [123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 108, 105, 99, 101, 34, 44, 34, 97, 103, 101, 34,
  58, 51, 48, 44, 34, 116, 97, 103, 115, 34, 58, 91, 34, 97, 34, 44, 34, 98, 34, 93, 125, 0];
  let doc_len: i32 = 42;
  let consumed: i32 = 0;
  let cur: json.JsonCursor = json.cursor_init(&doc[0], doc_len);
  let key: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let key_len: i32 = 0;
  let nr: i32 = 0;
  let out_val: f64 = 0.0;
  let vlen: i32 = 0;
  let vcon: i32 = 0;
  let vp: *u8 = 0 as *u8;
  let tag_count: i32 = 0;
  let has_elem: i32 = 0;

  if (json.skip_value(&doc[0], doc_len, &consumed) != 0) { return 1; }
  if (consumed != doc_len) { return 2; }

  cur = json.cursor_init(&doc[0], doc_len);
  if (json.cursor_enter_object(&cur) != 0) { return 3; }
  while (true) {
    nr = json.cursor_object_next(&cur, &key[0], 16, &key_len);
    if (nr == 0) { break; }
    if (nr < 0) { return 4; }
    if (key_eq(&key[0], key_len, 110, 97, 109, 101, 4) != 0) {
      vp = json.parse_string_view(&cur.ptr[cur.off], cur.len - cur.off, &vlen, &vcon);
      if (vp == 0 as *u8) { return 5; }
      if (vlen != 5) { return 6; }
      if (json.cursor_skip_value(&cur) != 0) { return 7; }
      continue;
    }
    if (key_eq(&key[0], key_len, 97, 103, 101, 0, 3) != 0) {
      if (json.parse_number(&cur.ptr[cur.off], cur.len - cur.off, &out_val, &vcon) != 0) { return 8; }
      if (vcon != 2) { return 9; }
      if (json.cursor_skip_value(&cur) != 0) { return 10; }
      continue;
    }
    if (key_eq(&key[0], key_len, 116, 97, 103, 115, 4) != 0) {
      if (json.cursor_enter_array(&cur) != 0) { return 11; }
      has_elem = json.cursor_array_has_elem(&cur);
      while (has_elem == 1) {
        vp = json.parse_string_view(&cur.ptr[cur.off], cur.len - cur.off, &vlen, &vcon);
        if (vp == 0 as *u8) { return 12; }
        if (vlen != 1) { return 13; }
        if (json.cursor_skip_value(&cur) != 0) { return 14; }
        tag_count = tag_count + 1;
        has_elem = json.cursor_array_has_elem(&cur);
      }
      if (tag_count != 2) { return 15; }
      continue;
    }
    if (json.cursor_skip_value(&cur) != 0) { return 16; }
  }
  return 0;
}
