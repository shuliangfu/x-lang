// STD-113：ChaCha20-Poly1305 往返烟测
const crypto = import("std.crypto");

function main(): i32 {
  let key: u8[32] = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32];
  let nonce: u8[12] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2];
  let aad: u8[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let pt: u8[24] = [
    104, 101, 108, 108, 111, 32, 99, 104, 97, 99, 104, 97, 32, 116, 101, 115,
    116, 33, 33, 33, 0, 0, 0, 0];
  let ct: u8[24] = [];
  let tag: u8[16] = [];
  let out: u8[24] = [];
  if (chacha20_poly1305_seal(&key[0], 32, &nonce[0], 12, &aad[0], 8, &pt[0], 20, &ct[0], &tag[0]) != 0) {
    return 1;
  }
  if (chacha20_poly1305_open(&key[0], 32, &nonce[0], 12, &aad[0], 8, &ct[0], 20, &tag[0], &out[0]) != 0) {
    return 2;
  }
  let i: i32 = 0;
  while (i < 20) {
    if (out[i] != pt[i]) {
      return 3;
    }
    i = i + 1;
  }
  tag[0] = tag[0] ^ 1;
  if (chacha20_poly1305_open(&key[0], 32, &nonce[0], 12, &aad[0], 8, &ct[0], 20, &tag[0], &out[0]) != -1) {
    return 4;
  }
  if (chacha20_poly1305_smoke() != 0) {
    return 5;
  }
  return 0;
}
