// 测试 std.path：path_extension、path_stem、path_is_absolute、path_sep、path_clean
// 对标 Rust/Go/Zig 的 extension、stem、IsAbs、sep、Clean。
const path = import("std.path");

// POSIX sep()=47 ('/')；Windows sep()=92 ('\\') — path.sep() 返回 OS 原生分隔符
#[cfg(target_os = "windows")]
function expected_sep(): u8 { return 92 as u8; }
#[cfg(not(target_os = "windows"))]
function expected_sep(): u8 { return 47 as u8; }

function main(): i32 {
  if (path.sep() != expected_sep()) { return 1; }
  let p_abs: u8[4] = [47, 97, 98, 0];
  if (path.is_absolute(&p_abs[0], 3) != 1) { return 2; }
  let p_rel: u8[3] = [97, 98, 0];
  if (path.is_absolute(&p_rel[0], 2) != 0) { return 3; }
  let file_txt: u8[13] = [100, 105, 114, 47, 102, 105, 108, 101, 46, 116, 120, 116, 0];
  let ext_buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let ext_len: i32 = path.extension(&file_txt[0], 12, &ext_buf[0], 8);
  if (ext_len != 4) { return 4; }
  if (ext_buf[0] != 46 || ext_buf[1] != 116 || ext_buf[2] != 120 || ext_buf[3] != 116) { return 5; }
  let stem_buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let stem_len: i32 = path.stem(&file_txt[0], 12, &stem_buf[0], 8);
  if (stem_len != 4) { return 6; }
  if (stem_buf[0] != 102 || stem_buf[1] != 105 || stem_buf[2] != 108 || stem_buf[3] != 101) {
    return 7; }
  let simple: u8[5] = [47, 97, 47, 98, 0];
  let clean_buf: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let clean_len: i32 = path.clean(&simple[0], 4, &clean_buf[0], 16);
  if (clean_len != 4) { return 8; }
  if (clean_buf[0] != 47 || clean_buf[1] != 97 || clean_buf[2] != 47 || clean_buf[3] != 98) {
    return 9; }
  let dotdot: u8[15] = [
    47, 102, 111, 111, 47, 98, 97, 114, 47, 46, 46, 47, 113, 117, 120
  ];
  clean_len = path.clean(&dotdot[0], 15, &clean_buf[0], 16);
  if (clean_len != 8) { return 10; }
  if (clean_buf[0] != 47 || clean_buf[7] != 120) { return 11; }
  return 0;
}
