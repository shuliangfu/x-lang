// STD-049：AES-128-GCM NIST SP 800-38D Test Case 2 金样 + round-trip
const crypto = import("std.crypto");

function main(): i32 {
  let key: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let iv: u8[12] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let pt: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let ct: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let tag: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let out: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let exp_ct: u8[16] = [
    3, 136, 218, 206, 96, 182, 163, 146, 243, 40, 194, 185, 113, 178, 254, 120];
  let exp_tag: u8[16] = [
    171, 110, 71, 212, 44, 236, 19, 189, 245, 58, 103, 178, 18, 87, 189, 223];
  if (aes_gcm_seal(&key[0], 16, &iv[0], 12, 0 as *u8, 0, &pt[0], 16, &ct[0], &tag[0]) != 0) {
    return 1;
  }
  if (crypto.mem_eq(&ct[0], &exp_ct[0], 16) != 1) { return 2; }
  if (crypto.mem_eq(&tag[0], &exp_tag[0], 16) != 1) { return 3; }
  if (aes_gcm_open(&key[0], 16, &iv[0], 12, 0 as *u8, 0, &ct[0], 16, &tag[0], &out[0]) != 0) {
    return 4;
  }
  if (crypto.mem_eq(&out[0], &pt[0], 16) != 1) { return 5; }
  tag[0] = tag[0] ^ 1;
  if (aes_gcm_open(&key[0], 16, &iv[0], 12, 0 as *u8, 0, &ct[0], 16, &tag[0], &out[0]) != -1) {
    return 6;
  }
  return 0;
}
