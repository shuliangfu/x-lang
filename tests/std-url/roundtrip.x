// STD-076：std.url parse/build/query/resolve round-trip 烟测
const url = import("std.url");

function main(): i32 {
  let raw: u8[36] = [
    104, 116, 116, 112, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99,
    111, 109, 58, 56, 48, 56, 48, 47, 112, 97, 116, 104, 63, 113, 61, 49,
    35, 102, 114, 97, 103
  ];
  let u: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let out: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let buf: u8[128] = [];
  let enc: u8[16] = [];
  let dec: u8[16] = [];
  let base_raw: u8[20] = [
    104, 116, 116, 112, 58, 47, 47, 97, 46, 99, 111, 109, 47, 102, 111, 111,
    47, 98, 97, 114
  ];
  let rel: u8[6] = [46, 46, 47, 98, 97, 122];
  let ipv6: u8[18] = [
    104, 116, 116, 112, 58, 47, 47, 91, 58, 58, 49, 93, 58, 56, 48, 56, 48, 47
  ];
  let q1: u8[1] = [49];
  let n: i32 = 0;

  if (url.parse(&raw[0], 37, &u) != 0) { return 1; }
  if (u.scheme_len != 4 || u.host_len != 11 || u.port_len != 4) { return 2; }
  if (url.build(u, &buf[0], 128) <= 0) { return 3; }

  if (url.parse(&ipv6[0], 18, &u) != 0) { return 4; }
  if (u.host_len != 3) { return 5; }

  n = url.query_encode(&q1[0], 1, &enc[0], 16);
  if (n != 1) { return 6; }
  n = url.query_decode(&enc[0], n, &dec[0], 16);
  if (n != 1 || dec[0] != 49) { return 7; }

  if (url.parse(&base_raw[0], 20, &u) != 0) { return 8; }
  if (url.resolve(u, &rel[0], 6, &out) != 0) { return 9; }
  if (out.path_len < 8) { return 10; }

  return 0;
}
