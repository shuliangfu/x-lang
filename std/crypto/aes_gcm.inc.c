/**
 * aes_gcm.inc.c — STD-049：AES-128-GCM（NIST SP 800-38D 子集）
 *
 * 由 crypto.c #include；无外部依赖。v1 仅 AES-128、12 字节 IV、16 字节 tag。
 */

/* ---------- AES-128（加密） ---------- */
static const uint8_t shu_aes_sbox[256] = {
  0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
  0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
  0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
  0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
  0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
  0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
  0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
  0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
  0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
  0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
  0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
  0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
  0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
  0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
  0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
  0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16
};

static const uint8_t shu_aes_rcon[10] = {
  0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1b,0x36
};

static uint8_t shu_aes_xtime(uint8_t x) {
  return (uint8_t)((x << 1) ^ ((x & 0x80) ? 0x1b : 0));
}

static void shu_aes_sub_bytes(uint8_t *s) {
  int i;
  for (i = 0; i < 16; i++) s[i] = shu_aes_sbox[s[i]];
}

static void shu_aes_shift_rows(uint8_t *s) {
  uint8_t t;
  t = s[1]; s[1] = s[5]; s[5] = s[9]; s[9] = s[13]; s[13] = t;
  t = s[2]; s[2] = s[10]; s[10] = t; t = s[6]; s[6] = s[14]; s[14] = t;
  t = s[15]; s[15] = s[11]; s[11] = s[7]; s[7] = s[3]; s[3] = t;
}

static void shu_aes_mix_columns(uint8_t *s) {
  int i;
  for (i = 0; i < 16; i += 4) {
    uint8_t a = s[i], b = s[i + 1], c = s[i + 2], d = s[i + 3];
    uint8_t e = a ^ b ^ c ^ d;
    s[i] ^= e ^ shu_aes_xtime(a ^ b);
    s[i + 1] ^= e ^ shu_aes_xtime(b ^ c);
    s[i + 2] ^= e ^ shu_aes_xtime(c ^ d);
    s[i + 3] ^= e ^ shu_aes_xtime(d ^ a);
  }
}

static void shu_aes_add_round_key(uint8_t *s, const uint8_t *rk) {
  int i;
  for (i = 0; i < 16; i++) s[i] ^= rk[i];
}

static void shu_aes_key_expand(const uint8_t key[16], uint8_t rk[176]) {
  int i;
  memcpy(rk, key, 16);
  for (i = 16; i < 176; i += 4) {
    uint8_t t[4];
    memcpy(t, rk + i - 4, 4);
    if ((i % 16) == 0) {
      uint8_t tmp = t[0];
      t[0] = shu_aes_sbox[t[1]] ^ shu_aes_rcon[(i / 16) - 1];
      t[1] = shu_aes_sbox[t[2]];
      t[2] = shu_aes_sbox[t[3]];
      t[3] = shu_aes_sbox[tmp];
    }
    rk[i] = rk[i - 16] ^ t[0];
    rk[i + 1] = rk[i - 15] ^ t[1];
    rk[i + 2] = rk[i - 14] ^ t[2];
    rk[i + 3] = rk[i - 13] ^ t[3];
  }
}

static void shu_aes_encrypt_block(const uint8_t rk[176], const uint8_t in[16], uint8_t out[16]) {
  int r;
  memcpy(out, in, 16);
  shu_aes_add_round_key(out, rk);
  for (r = 1; r < 10; r++) {
    shu_aes_sub_bytes(out);
    shu_aes_shift_rows(out);
    shu_aes_mix_columns(out);
    shu_aes_add_round_key(out, rk + r * 16);
  }
  shu_aes_sub_bytes(out);
  shu_aes_shift_rows(out);
  shu_aes_add_round_key(out, rk + 160);
}

/* ---------- GCM GHASH / GCTR ---------- */
static void shu_gcm_xor16(uint8_t *x, const uint8_t *y) {
  int i;
  for (i = 0; i < 16; i++) x[i] ^= y[i];
}

static void shu_gcm_mult(uint8_t *x, const uint8_t *y) {
  uint8_t z[16] = {0};
  uint8_t v[16];
  int i, j;
  memcpy(v, y, 16);
  for (i = 0; i < 16; i++) {
    for (j = 7; j >= 0; j--) {
      if (x[i] & (1u << j)) shu_gcm_xor16(z, v);
      if (v[15] & 1) {
        int k;
        for (k = 15; k > 0; k--) v[k] = (uint8_t)((v[k] >> 1) | (v[k - 1] << 7));
        v[0] >>= 1;
        v[0] ^= 0xe1;
      } else {
        int k;
        for (k = 15; k > 0; k--) v[k] = (uint8_t)((v[k] >> 1) | (v[k - 1] << 7));
        v[0] >>= 1;
      }
    }
  }
  memcpy(x, z, 16);
}

static void shu_gcm_ghash(const uint8_t h[16], const uint8_t *aad, int32_t aad_len,
                          const uint8_t *ct, int32_t ct_len, uint8_t out[16]) {
  uint8_t y[16] = {0};
  uint8_t blk[16];
  int32_t i;
  const uint8_t *p;
  int32_t n;

  p = aad;
  n = aad_len;
  while (n > 0) {
    int32_t chunk = (n >= 16) ? 16 : n;
    memset(blk, 0, 16);
    memcpy(blk, p, (size_t)chunk);
    shu_gcm_xor16(y, blk);
    shu_gcm_mult(y, h);
    p += chunk;
    n -= chunk;
  }
  p = ct;
  n = ct_len;
  while (n > 0) {
    int32_t chunk = (n >= 16) ? 16 : n;
    memset(blk, 0, 16);
    memcpy(blk, p, (size_t)chunk);
    shu_gcm_xor16(y, blk);
    shu_gcm_mult(y, h);
    p += chunk;
    n -= chunk;
  }
  memset(blk, 0, 16);
  {
    uint64_t al = (uint64_t)(aad_len < 0 ? 0 : aad_len) * 8;
    uint64_t cl = (uint64_t)(ct_len < 0 ? 0 : ct_len) * 8;
    int j;
    for (j = 0; j < 8; j++) blk[7 - j] = (uint8_t)(al >> (j * 8));
    for (j = 0; j < 8; j++) blk[15 - j] = (uint8_t)(cl >> (j * 8));
  }
  shu_gcm_xor16(y, blk);
  shu_gcm_mult(y, h);
  memcpy(out, y, 16);
}

static void shu_gcm_inc32(uint8_t *ctr) {
  uint32_t n = ((uint32_t)ctr[12] << 24) | ((uint32_t)ctr[13] << 16) |
               ((uint32_t)ctr[14] << 8) | (uint32_t)ctr[15];
  n++;
  ctr[12] = (uint8_t)(n >> 24);
  ctr[13] = (uint8_t)(n >> 16);
  ctr[14] = (uint8_t)(n >> 8);
  ctr[15] = (uint8_t)n;
}

static void shu_gcm_gctr(const uint8_t rk[176], const uint8_t *icb, const uint8_t *in,
                         int32_t in_len, uint8_t *out) {
  uint8_t ctr[16];
  uint8_t ecb[16];
  int32_t off = 0;
  memcpy(ctr, icb, 16);
  while (off < in_len) {
    int32_t i;
  int32_t chunk = in_len - off;
    if (chunk > 16) chunk = 16;
    shu_aes_encrypt_block(rk, ctr, ecb);
    for (i = 0; i < chunk; i++) out[off + i] = in[off + i] ^ ecb[i];
    off += chunk;
    shu_gcm_inc32(ctr);
  }
}

/** 内部：AES-128-GCM seal；key_len=16, iv_len=12, tag_len=16。 */
static int32_t shu_aes_gcm_seal_impl(const uint8_t *key, const uint8_t *iv, const uint8_t *aad,
                                     int32_t aad_len, const uint8_t *pt, int32_t pt_len,
                                     uint8_t *ct, uint8_t *tag) {
  uint8_t rk[176];
  uint8_t h[16], j0[16], tag_mask[16], ghash_out[16];
  const uint8_t zero[16] = {0};

  shu_aes_key_expand(key, rk);
  shu_aes_encrypt_block(rk, zero, h);
  memset(j0, 0, 16);
  memcpy(j0, iv, 12);
  j0[15] = 1;
  shu_gcm_inc32(j0);
  shu_gcm_gctr(rk, j0, pt, pt_len, ct);
  shu_gcm_ghash(h, aad, aad_len, ct, pt_len, ghash_out);
  memset(j0, 0, 16);
  memcpy(j0, iv, 12);
  j0[15] = 1;
  shu_aes_encrypt_block(rk, j0, tag_mask);
  {
    int i;
    for (i = 0; i < 16; i++) tag[i] = ghash_out[i] ^ tag_mask[i];
  }
  return 0;
}

int32_t crypto_aes_gcm_seal_c(const uint8_t *key, int32_t key_len, const uint8_t *iv,
                              int32_t iv_len, const uint8_t *aad, int32_t aad_len,
                              const uint8_t *pt, int32_t pt_len, uint8_t *ct, uint8_t *tag) {
  if (!key || !iv || !tag || key_len != 16 || iv_len != 12) return -1;
  if (pt_len > 0 && (!pt || !ct)) return -1;
  if (aad_len > 0 && !aad) return -1;
  return shu_aes_gcm_seal_impl(key, iv, aad, aad_len, pt, pt_len, ct, tag);
}

int32_t crypto_aes_gcm_open_c(const uint8_t *key, int32_t key_len, const uint8_t *iv,
                              int32_t iv_len, const uint8_t *aad, int32_t aad_len,
                              const uint8_t *ct, int32_t ct_len, const uint8_t *tag,
                              uint8_t *pt) {
  uint8_t rk[176];
  uint8_t h[16], j0[16], tag_mask[16], ghash_out[16], calc[16];
  const uint8_t zero[16] = {0};
  int32_t i;

  if (!key || !iv || !tag || key_len != 16 || iv_len != 12) return -1;
  if (ct_len > 0 && (!ct || !pt)) return -1;
  if (aad_len > 0 && !aad) return -1;

  shu_aes_key_expand(key, rk);
  shu_aes_encrypt_block(rk, zero, h);
  memset(j0, 0, 16);
  memcpy(j0, iv, 12);
  j0[15] = 1;
  shu_gcm_ghash(h, aad, aad_len, ct, ct_len, ghash_out);
  memset(j0, 0, 16);
  memcpy(j0, iv, 12);
  j0[15] = 1;
  shu_aes_encrypt_block(rk, j0, tag_mask);
  for (i = 0; i < 16; i++) calc[i] = ghash_out[i] ^ tag_mask[i];
  for (i = 0; i < 16; i++) {
    if (calc[i] != tag[i]) return -1;
  }
  shu_gcm_inc32(j0);
  shu_gcm_gctr(rk, j0, ct, ct_len, pt);
  return 0;
}
