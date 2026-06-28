// STD-116：std.json 类型化 decode 烟测
const json = import("std.json");

function main(): i32 {
  let doc: u8[36] = [
    123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 108, 105, 99, 101, 34, 44,
    34, 97, 103, 101, 34, 58, 51, 48, 44, 34, 111, 107, 34, 58, 116, 114,
    117, 101, 125, 0];
  let doc_len: i32 = 35;
  let cur: json.JsonCursor = json.cursor_init(&doc[0], doc_len);
  let age: i32 = 0;
  let ok: bool = false;
  let name: u8[16] = [];
  let name_len: i32 = 0;
  let key_age: u8[3] = [97, 103, 101];
  let key_ok: u8[2] = [111, 107];
  let key_name: u8[4] = [110, 97, 109, 101];
  let key_miss: u8[3] = [120, 120, 120];

  if (json.object_decode(&cur, &key_age[0], 3, &age) != 0) {
    return 1;
  }
  if (age != 30) {
    return 2;
  }
  cur = json.cursor_init(&doc[0], doc_len);
  if (json.object_decode(&cur, &key_ok[0], 2, &ok) != 0) {
    return 3;
  }
  if (ok != true) {
    return 4;
  }
  cur = json.cursor_init(&doc[0], doc_len);
  if (json.object_decode_string(&cur, &key_name[0], 4, &name[0], 16, &name_len) != 0) {
    return 5;
  }
  if (name_len != 5) {
    return 6;
  }
  cur = json.cursor_init(&doc[0], doc_len);
  if (json.object_decode(&cur, &key_miss[0], 3, &age) != json.decode_missing()) {
    return 7;
  }
  if (json.typed_decode_smoke() != 0) {
    return 8;
  }
  let nested: u8[19] = [
    123, 34, 117, 115, 101, 114, 34, 58, 123, 34, 97, 103, 101, 34, 58, 50, 49, 125, 125
  ];
  let path_age: u8[8] = [117, 115, 101, 114, 46, 97, 103, 101];
  cur = json.cursor_init(&nested[0], 19);
  age = 0;
  if (json.object_decode_dotted(&cur, &path_age[0], 8, &age) != 0) {
    return 9;
  }
  if (age != 21) {
    return 10;
  }
  let arr_doc: u8[20] = [
    123, 34, 105, 116, 101, 109, 115, 34, 58, 91, 49, 48, 44, 50, 48, 44, 51, 48, 93, 125
  ];
  let path_item0: u8[7] = [105, 116, 101, 109, 115, 46, 48];
  cur = json.cursor_init(&arr_doc[0], 20);
  age = 0;
  if (json.object_decode_dotted(&cur, &path_item0[0], 7, &age) != 0) {
    return 11;
  }
  if (age != 10) {
    return 12;
  }
  let bool_doc: u8[22] = [
    123, 34, 102, 108, 97, 103, 115, 34, 58, 91, 116, 114, 117, 101, 44, 102, 97, 108, 115, 101, 93, 125
  ];
  let path_flag0: u8[7] = [102, 108, 97, 103, 115, 46, 48];
  cur = json.cursor_init(&bool_doc[0], 22);
  ok = false;
  if (json.object_decode_dotted(&cur, &path_flag0[0], 7, &ok) != 0) {
    return 13;
  }
  if (ok != true) {
    return 14;
  }
  let f64_doc: u8[44] = [
    123, 34, 109, 101, 116, 114, 105, 99, 115, 34, 58, 123, 34, 99, 112, 117,
    34, 58, 48, 46, 55, 53, 125, 44, 34, 118, 97, 108, 117, 101, 115, 34, 58,
    91, 49, 46, 53, 44, 50, 46, 53, 93, 125
  ];
  let path_cpu: u8[11] = [109, 101, 116, 114, 105, 99, 115, 46, 99, 112, 117];
  let path_val1: u8[8] = [118, 97, 108, 117, 101, 115, 46, 49];
  let dv: f64 = 0.0;
  cur = json.cursor_init(&f64_doc[0], 44);
  if (json.object_decode_dotted(&cur, &path_cpu[0], 11, &dv) != 0) {
    return 15;
  }
  if (dv < 0.74 || dv > 0.76) {
    return 16;
  }
  cur = json.cursor_init(&f64_doc[0], 44);
  dv = 0.0;
  if (json.object_decode_dotted(&cur, &path_val1[0], 8, &dv) != 0) {
    return 17;
  }
  if (dv < 2.49 || dv > 2.51) {
    return 18;
  }
  return 0;
}
