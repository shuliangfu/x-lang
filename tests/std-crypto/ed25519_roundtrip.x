// STD-126：Ed25519 签名/验签往返烟测（RFC 8032 §7.1 TEST 1 + 短消息）
const crypto = import("std.crypto");

function main(): i32 {
  // RFC 8032 TEST 1 seed
  let seed: u8[32] = [
    0x9d, 0x61, 0xb1, 0x9d, 0xef, 0xfd, 0x5a, 0x60, 0xba, 0x84, 0x4a, 0xf4, 0x92, 0xec, 0x2c, 0xc4,
    0x44, 0x49, 0xc5, 0x69, 0x7b, 0x32, 0x69, 0x19, 0x70, 0x3b, 0xac, 0x03, 0x1c, 0xae, 0x7f, 0x60];
  let expect_pub: u8[32] = [
    0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9, 0x64, 0x07, 0x3a,
    0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02, 0x1a, 0x68, 0xf7, 0x07, 0x51, 0x1a];
  let pub: u8[32] = [];
  let sig: u8[64] = [];
  ed25519_public_from_seed(&seed[0], &pub[0]);
  let i: i32 = 0;
  while (i < 32) {
    if (pub[i] != expect_pub[i]) {
      return 1;
    }
    i = i + 1;
  }
  if (ed25519_sign(&seed[0], 0 as *u8, 0, &sig[0]) != 0) {
    return 2;
  }
  if (ed25519_verify(&pub[0], 0 as *u8, 0, &sig[0]) != 0) {
    return 3;
  }
  let msg: u8[16] = [104, 101, 108, 108, 111, 32, 101, 100, 50, 53, 53, 49, 57, 33, 33, 33];
  if (ed25519_sign(&seed[0], &msg[0], 13, &sig[0]) != 0) {
    return 4;
  }
  if (ed25519_verify(&pub[0], &msg[0], 13, &sig[0]) != 0) {
    return 5;
  }
  sig[0] = sig[0] ^ 1;
  if (ed25519_verify(&pub[0], &msg[0], 13, &sig[0]) != -1) {
    return 6;
  }
  if (ed25519_smoke() != 0) {
    return 7;
  }
  return 0;
}
