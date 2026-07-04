// STD-073：std.codec hex/base64/gzip/json/csv/bytes round-trip 烟测
const codec = import("std.codec");
const bytes = import("std.bytes");

/** 比较两段字节是否相等；1 相等，0 不等。 */
function bytes_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) { return 0; }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

function main(): i32 {
  let src: u8[3] = [1, 2, 3];
  let enc: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let dec: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let dn: i32 = 0;

  n = codec.adapter_hex_encode(&src[0], 3, &enc[0], 64);
  if (n != 6) { return 1; }
  dn = codec.adapter_hex_decode(&enc[0], n, &dec[0], 64);
  if (dn != 3) { return 2; }
  if (bytes_eq(&src[0], 3, &dec[0], dn) == 0) { return 3; }

  n = codec.adapter_base64_encode(&src[0], 3, &enc[0], 64);
  if (n <= 0) { return 4; }
  dn = codec.adapter_base64_decode(&enc[0], n, &dec[0], 64);
  if (dn != 3) { return 5; }
  if (bytes_eq(&src[0], 3, &dec[0], dn) == 0) { return 6; }

  let hello: u8[5] = [104, 101, 108, 108, 111];
  n = codec.adapter_gzip_encode(&hello[0], 5, &enc[0], 64);
  if (n > 0) {
    dn = codec.adapter_gzip_decode(&enc[0], n, &dec[0], 64);
    if (dn != 5) { return 7; }
    if (bytes_eq(&hello[0], 5, &dec[0], dn) == 0) { return 8; }
  }

  let raw_json: u8[3] = [97, 34, 98];
  n = codec.adapter_json_escape(&raw_json[0], 3, &enc[0], 64);
  if (n <= 0) { return 9; }

  let raw_csv: u8[3] = [97, 44, 98];
  n = codec.adapter_csv_escape(&raw_csv[0], 3, &enc[0], 64);
  if (n <= 0) { return 10; }

  let b: Bytes = bytes.new();
  let e: Encoder = codec.encoder_new(codec.kind_hex());
  if (codec.encode_into_bytes(e, &src[0], 3, &b) != 6) {
    bytes.deinit(&b);
    return 11;
  }
  let d: Decoder = codec.decoder_new(codec.kind_hex());
  let out: Bytes = bytes.new();
  if (codec.decode_from_bytes(d, b, &out) != 3) {
    bytes.deinit(&b);
    bytes.deinit(&out);
    return 12;
  }
  if (bytes.len(out) != 3) {
    bytes.deinit(&b);
    bytes.deinit(&out);
    return 13;
  }
  bytes.deinit(&b);
  bytes.deinit(&out);
  return 0;
}
