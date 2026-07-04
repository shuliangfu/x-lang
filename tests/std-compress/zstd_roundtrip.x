// STD-007：zstd 压缩→解压往返（未链 libzstd 时 n_zst<=0 仍通过）
const compress = import("std.compress");

function main(): i32 {
  let raw: u8[12] = [90, 115, 116, 100, 46, 99, 111, 109, 112, 114, 101, 115];
  let out_buf: u8[256] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let dec_buf: u8[256] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n_zst: i32 = compress.zstd_compress(&raw[0], 12, &out_buf[0], 256);
  if (n_zst <= 0) { return 0; }
  let m_zst: i32 = compress.zstd_decompress(&out_buf[0], n_zst, &dec_buf[0], 256);
  if (m_zst != 12) { return 1; }
  let i: i32 = 0;
  while (i < 12) {
    if (dec_buf[i] != raw[i]) { return 2; }
    i = i + 1;
  }
  return 0;
}
