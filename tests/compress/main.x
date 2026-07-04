// tests/compress/main.x — std.compress gzip / zstd / Brotli round-trip 测试
// 未链接 zlib 时 gzip_* 返回 -1 则跳过；未链接 zstd 时 zstd_* 返回 -1 则跳过；
// 未链接 Brotli 时 brotli_* 返回 -1 则跳过。

const compress = import("std.compress");

function main(): i32 {
  // 测试用短串
  let raw: u8[14] = [72, 101, 108, 108, 111, 44, 32, 98, 114, 47, 103, 122, 33, 0];
  let out_buf: u8[256] = [];
  let dec_buf: u8[256] = [];
  
  // gzip 往返：压缩再解压，对比原内容
  let n_gz: i32 = compress.gzip_compress(&raw[0], 13, &out_buf[0], 256);
  if (n_gz > 0) {
    let m_gz: i32 = compress.gzip_decompress(&out_buf[0], n_gz, &dec_buf[0], 256);
    if (m_gz != 13) { return 1; }
    let i: i32 = 0;
    while (i < 13) {
      if (dec_buf[i] != raw[i]) { return 2; }
      i = i + 1;
    }
  }
  
  // zstd 往返
  let n_zst: i32 = compress.zstd_compress(&raw[0], 13, &out_buf[0], 256);
  if (n_zst > 0) {
    let m_zst: i32 = compress.zstd_decompress(&out_buf[0], n_zst, &dec_buf[0], 256);
    if (m_zst != 13) { return 5; }
    let k: i32 = 0;
    while (k < 13) {
      if (dec_buf[k] != raw[k]) { return 6; }
      k = k + 1;
    }
  }
  
  // brotli 往返：压缩再解压，对比原内容
  let n_br: i32 = compress.brotli_compress(&raw[0], 13, &out_buf[0], 256);
  if (n_br > 0) {
    let m_br: i32 = compress.brotli_decompress(&out_buf[0], n_br, &dec_buf[0], 256);
    if (m_br != 13) { return 3; }
    let j: i32 = 0;
    while (j < 13) {
      if (dec_buf[j] != raw[j]) { return 4; }
      j = j + 1;
    }
  }
  
  return 0;
}
