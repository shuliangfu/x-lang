// STD-056：SipHash / aHash 切换烟测（金样 u64 由 C 烟测校验；此处避免大 hex 字面量截断）
const hash = import("std.hash");

function main(): i32 {
  let buf: u8[3] = [97, 98, 99];
  let hs: *u8 = hash.start_algo(0);
  let ha: *u8 = hash.start_algo(1);
  if (hs == 0 || ha == 0) {
    return 1;
  }
  hash.write_bytes_algo(hs, &buf[0], 3);
  hash.write_bytes_algo(ha, &buf[0], 3);
  let rs: u64 = hash.finish_algo(hs);
  let ra: u64 = hash.finish_algo(ha);
  hash.free_algo(hs);
  hash.free_algo(ha);
  if (rs == 0 || ra == 0) {
    return 2;
  }
  if (rs == ra) {
    return 3;
  }
  if (hash.default_hasher() != 0) {
    return 4;
  }
  return 0;
}
