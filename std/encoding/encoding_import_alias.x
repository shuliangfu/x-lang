// encoding_import_alias.x — import binding -o 链接桩（从 .c 转换）
extern function encoding_utf8_encode_rune_c(r: u32, out: *u8): i32;
extern function encoding_utf8_decode_rune_c(p: *u8, len: i32, out_r: *u32): i32;
extern function encoding_ascii_is_alpha_c(c: u8): i32;
extern function encoding_ascii_is_digit_c(c: u8): i32;
extern function encoding_ascii_is_alnum_c(c: u8): i32;
extern function encoding_ascii_is_lower_c(c: u8): i32;
extern function encoding_ascii_is_upper_c(c: u8): i32;
extern function encoding_ascii_to_lower_c(c: u8): u8;
extern function encoding_ascii_to_upper_c(c: u8): u8;
extern function encoding_hex_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_hex_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_hex_encoded_len_c(src_len: i32): i32;

function encoding_hotfix_utf8_first_byte_len(b: u32): u32 {
  if (b <= 127) { return 1; }
  if (b >= 128 && b <= 191) { return 255; }
  if (b >= 192 && b <= 223) { return 2; }
  if (b >= 224 && b <= 239) { return 3; }
  if (b >= 240 && b <= 247) { return 4; }
  return 255;
}

function std_encoding_utf8_valid(p: *u8, len: i32): i32 {
  let pi: i32 = 0;
  let n: u32 = 0;
  let j: i32 = 0;
  if (p == 0 as *u8 || len < 0) { return 0; }
  while (pi < len) {
    n = encoding_hotfix_utf8_first_byte_len(p[pi] as u32);
    if (n == 255) { return 0; }
    if (n > 1) {
      if (pi + n as i32 > len) { return 0; }
      j = 1;
      while (j < n as i32) {
        if ((p[pi + j] as u32 & 0xC0) != 0x80) { return 0; }
        j = j + 1;
      }
      if (n == 2 && p[pi] < 194) { return 0; }
      if (n == 3 && p[pi] == 224 && p[pi + 1] < 160) { return 0; }
      if (n == 3 && p[pi] == 237 && p[pi + 1] > 159) { return 0; }
      if (n == 4 && p[pi] == 240 && p[pi + 1] < 144) { return 0; }
      if (n == 4 && p[pi] == 244 && p[pi + 1] > 143) { return 0; }
      pi = pi + n as i32;
    } else {
      pi = pi + 1;
    }
  }
  return 1;
}

function std_encoding_utf8_len_chars(p: *u8, len: i32): i32 {
  let count: i32 = 0;
  let pi: i32 = 0;
  let n: u32 = 0;
  if (p == 0 as *u8 || len <= 0) { return 0; }
  while (pi < len) {
    n = encoding_hotfix_utf8_first_byte_len(p[pi] as u32);
    if (n == 255) { return -1; }
    if (n as i32 > len - pi) { return -1; }
    pi = pi + n as i32;
    count = count + 1;
  }
  return count;
}

function std_encoding_utf8_encode_rune(r: u32, out: *u8): i32 { return encoding_utf8_encode_rune_c(r, out); }
function std_encoding_utf8_decode_rune(p: *u8, len: i32, out_r: *u32): i32 { return encoding_utf8_decode_rune_c(p, len, out_r); }
function std_encoding_ascii_is_alpha(c: u8): i32 { return encoding_ascii_is_alpha_c(c); }
function std_encoding_ascii_is_digit(c: u8): i32 { return encoding_ascii_is_digit_c(c); }
function std_encoding_ascii_is_alnum(c: u8): i32 { return encoding_ascii_is_alnum_c(c); }
function std_encoding_ascii_is_lower(c: u8): i32 { return encoding_ascii_is_lower_c(c); }
function std_encoding_ascii_is_upper(c: u8): i32 { return encoding_ascii_is_upper_c(c); }
function std_encoding_ascii_to_lower(c: u8): u8 { return encoding_ascii_to_lower_c(c); }
function std_encoding_ascii_to_upper(c: u8): u8 {
  if (c >= 97 && c <= 122) { return (c - 32) as u8; }
  return c;
}
function std_encoding_hex_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  return encoding_hex_encode_c(src, src_len, out, out_cap);
}
function std_encoding_hex_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  return encoding_hex_decode_c(src, src_len, out, out_cap);
}
function std_encoding_hex_encoded_len(src_len: i32): i32 { return encoding_hex_encoded_len_c(src_len); }
