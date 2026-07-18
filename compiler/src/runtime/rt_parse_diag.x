// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-307/448 / P2 runtime rest：已知精确 parse 失败诊断 note。
// R2 full（2026-07-14）：.x 吃满 runtime_report_precise_parse_failure_if_known；
// 产品 PREFER_X_O：full .x + rest 在 FROM_X 下仅 marker（业务 H=0）。
// 🔒 fail_tok 经 parser_diag_fail_at_token_kind_buf；报告经 diag_report_with_code（无 va）。
// TOKEN_STRING = 130 与 include/token.h 枚举序对齐（硬编码，忌 thin 假迁）。

export extern "C" function parser_diag_fail_at_token_kind_buf(data: *u8, len: i32): i32;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** 与 include/token.h TokenKind::TOKEN_STRING 一致。 */
export const RT_PARSE_TOKEN_STRING: i32 = 130;

/** TOKEN_STRING 失败时发 P001；否则 0。 */
#[no_mangle]
export function runtime_report_precise_parse_failure_if_known(
  input_path: *u8, src: *u8, src_len: usize): i32 {
  let fail_tok: i32 = 0;
  let n: i32 = 0;
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[140] = [];
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len == 0 as usize) {
    return 0;
  }
  /* src_len 合理源长 ≪ i32 上界；_buf API 取 i32。 */
  n = src_len as i32;
  if (n <= 0) {
    return 0;
  }
  unsafe {
    fail_tok = parser_diag_fail_at_token_kind_buf(src, n);
  }
  if (fail_tok != RT_PARSE_TOKEN_STRING) {
    return 0;
  }
  /* "parse error" */
  kind[0] = 112;
  kind[1] = 97;
  kind[2] = 114;
  kind[3] = 115;
  kind[4] = 101;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  /* "P001" */
  code[0] = 80;
  code[1] = 48;
  code[2] = 48;
  code[3] = 49;
  code[4] = 0;
  /* expected integer literal, float literal, identifier, 'true', 'false', 'if',
     'break', 'continue', 'return', 'panic', 'match', or '(' */
  msg[0] = 101;
  msg[1] = 120;
  msg[2] = 112;
  msg[3] = 101;
  msg[4] = 99;
  msg[5] = 116;
  msg[6] = 101;
  msg[7] = 100;
  msg[8] = 32;
  msg[9] = 105;
  msg[10] = 110;
  msg[11] = 116;
  msg[12] = 101;
  msg[13] = 103;
  msg[14] = 101;
  msg[15] = 114;
  msg[16] = 32;
  msg[17] = 108;
  msg[18] = 105;
  msg[19] = 116;
  msg[20] = 101;
  msg[21] = 114;
  msg[22] = 97;
  msg[23] = 108;
  msg[24] = 44;
  msg[25] = 32;
  msg[26] = 102;
  msg[27] = 108;
  msg[28] = 111;
  msg[29] = 97;
  msg[30] = 116;
  msg[31] = 32;
  msg[32] = 108;
  msg[33] = 105;
  msg[34] = 116;
  msg[35] = 101;
  msg[36] = 114;
  msg[37] = 97;
  msg[38] = 108;
  msg[39] = 44;
  msg[40] = 32;
  msg[41] = 105;
  msg[42] = 100;
  msg[43] = 101;
  msg[44] = 110;
  msg[45] = 116;
  msg[46] = 105;
  msg[47] = 102;
  msg[48] = 105;
  msg[49] = 101;
  msg[50] = 114;
  msg[51] = 44;
  msg[52] = 32;
  msg[53] = 39;
  msg[54] = 116;
  msg[55] = 114;
  msg[56] = 117;
  msg[57] = 101;
  msg[58] = 39;
  msg[59] = 44;
  msg[60] = 32;
  msg[61] = 39;
  msg[62] = 102;
  msg[63] = 97;
  msg[64] = 108;
  msg[65] = 115;
  msg[66] = 101;
  msg[67] = 39;
  msg[68] = 44;
  msg[69] = 32;
  msg[70] = 39;
  msg[71] = 105;
  msg[72] = 102;
  msg[73] = 39;
  msg[74] = 44;
  msg[75] = 32;
  msg[76] = 39;
  msg[77] = 98;
  msg[78] = 114;
  msg[79] = 101;
  msg[80] = 97;
  msg[81] = 107;
  msg[82] = 39;
  msg[83] = 44;
  msg[84] = 32;
  msg[85] = 39;
  msg[86] = 99;
  msg[87] = 111;
  msg[88] = 110;
  msg[89] = 116;
  msg[90] = 105;
  msg[91] = 110;
  msg[92] = 117;
  msg[93] = 101;
  msg[94] = 39;
  msg[95] = 44;
  msg[96] = 32;
  msg[97] = 39;
  msg[98] = 114;
  msg[99] = 101;
  msg[100] = 116;
  msg[101] = 117;
  msg[102] = 114;
  msg[103] = 110;
  msg[104] = 39;
  msg[105] = 44;
  msg[106] = 32;
  msg[107] = 39;
  msg[108] = 112;
  msg[109] = 97;
  msg[110] = 110;
  msg[111] = 105;
  msg[112] = 99;
  msg[113] = 39;
  msg[114] = 44;
  msg[115] = 32;
  msg[116] = 39;
  msg[117] = 109;
  msg[118] = 97;
  msg[119] = 116;
  msg[120] = 99;
  msg[121] = 104;
  msg[122] = 39;
  msg[123] = 44;
  msg[124] = 32;
  msg[125] = 111;
  msg[126] = 114;
  msg[127] = 32;
  msg[128] = 39;
  msg[129] = 40;
  msg[130] = 39;
  msg[131] = 0;
  unsafe {
    diag_report_with_code(input_path, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
  return 1;
}
