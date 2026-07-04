// STD-HTTP-HTTPS：std.http HTTPS 烟测（桩 TLS 时验证 -1221；有 TLS 时走 C 烟测）
const http = import("std.http");

function main(): i32 {
  let url: u8[19] = [
    104, 116, 116, 112, 115, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109
  ];
  let out: u8[64] = [];
  let r: i32 = 0;
  if (http.https_is_available()) {
    return http.https_smoke();
  }
  r = http.get(&url[0], 19, &out[0], 64);
  if (r != http.err_tls_not_impl()) {
    return 1;
  }
  return 0;
}
