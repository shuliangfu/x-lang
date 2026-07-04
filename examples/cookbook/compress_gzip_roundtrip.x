/**
 * Cookbook CMP-01：gzip 压缩/解压往返（STD-007 / STD-039；未链接 zlib 时跳过）。
 */
const compress = import("std.compress");

function main(): i32 {
  let raw: u8[14] = [72, 101, 108, 108, 111, 44, 32, 98, 114, 47, 103, 122, 33, 0];
  let out_buf: u8[256] = [];
  let dec_buf: u8[256] = [];
  let n_gz: i32 = compress.gzip_compress(&raw[0], 13, &out_buf[0], 256);
  if (n_gz <= 0) { return 0; }
  let m_gz: i32 = compress.gzip_decompress(&out_buf[0], n_gz, &dec_buf[0], 256);
  if (m_gz != 13) { return 1; }
  return 0;
}
