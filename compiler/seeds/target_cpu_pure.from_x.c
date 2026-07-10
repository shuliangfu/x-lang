/* target_cpu_pure.from_x.c — G-02f-2/3/4/5 product pure half of target_cpu.o
 *
 * Source of truth: src/driver/target_cpu_pure.x (+ print is stdio C co-located; f-5)
 * Hand-synced when full shux-c -E hangs on multi-helper TUs.
 * Product: ld -r pure.o + target_cpu_detect.o → target_cpu.o
 *
 * Exports: pending, resolve, simd spelling, print.
 * U: shu_target_cpu_detect_host, shu_target_cpu_generic_for_host (detect.o).
 */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

static uint32_t g_driver_pending_target_cpu_features;

void driver_set_pending_target_cpu_features(uint32_t features) {
  g_driver_pending_target_cpu_features = features;
}

uint32_t driver_get_pending_target_cpu_features(void) {
  return g_driver_pending_target_cpu_features;
}

extern uint32_t shu_target_cpu_detect_host(void);
extern uint32_t shu_target_cpu_generic_for_host(void);

static uint8_t tcp_tolower(uint8_t c) {
  if (c >= 65 && c <= 90)
    return (uint8_t)(c + 32);
  return c;
}

/** Compare name[base..base+n) case-insensitively to lowercase lit[0..n). */
static int32_t tcp_eq_at(const uint8_t *name, size_t base, size_t n, const uint8_t *lit) {
  size_t i;
  for (i = 0; i < n; i++) {
    if (tcp_tolower(name[base + i]) != lit[i])
      return 0;
  }
  return 1;
}

static int32_t tcp_parse_named(const uint8_t *spec, size_t base, size_t end, uint32_t *out) {
  size_t n;
  if (!out || end < base)
    return -1;
  n = end - base;
  if (n == 6 && tcp_eq_at(spec, base, 6, (const uint8_t *)"native") != 0) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  if (n == 7 && tcp_eq_at(spec, base, 7, (const uint8_t *)"generic") != 0) {
    *out = shu_target_cpu_generic_for_host();
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"sse2") != 0) {
    *out = 1u; /* SSE2 */
    return 0;
  }
  if (n == 6 && (tcp_eq_at(spec, base, 6, (const uint8_t *)"sse4.1") != 0 ||
                 tcp_eq_at(spec, base, 6, (const uint8_t *)"sse4_1") != 0)) {
    *out = 1u | 2u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"avx") != 0) {
    *out = 1u | 2u | 4u;
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"avx2") != 0) {
    *out = 1u | 2u | 4u | 8u;
    return 0;
  }
  if (n == 6 && tcp_eq_at(spec, base, 6, (const uint8_t *)"avx512") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u;
    return 0;
  }
  if (n == 7 && tcp_eq_at(spec, base, 7, (const uint8_t *)"avx512f") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v2") != 0) {
    *out = 1u | 2u | 32u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v3") != 0) {
    *out = 1u | 2u | 4u | 8u | 32u | 64u;
    return 0;
  }
  if (n == 9 && tcp_eq_at(spec, base, 9, (const uint8_t *)"x86-64-v4") != 0) {
    *out = 1u | 2u | 4u | 8u | 16u | 32u | 64u;
    return 0;
  }
  if (n == 4 && tcp_eq_at(spec, base, 4, (const uint8_t *)"neon") != 0) {
    *out = 256u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"sve") != 0) {
    *out = 256u | 512u;
    return 0;
  }
  if (n == 3 && tcp_eq_at(spec, base, 3, (const uint8_t *)"rvv") != 0) {
    *out = 65536u;
    return 0;
  }
  return -1;
}

int shu_target_cpu_resolve(const char *spec, size_t spec_len, uint32_t *out) {
  const uint8_t *s = (const uint8_t *)spec;
  size_t start = 0;
  size_t end;
  if (!out)
    return -1;
  if (!spec || spec_len == 0) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  end = spec_len;
  while (start < end && (s[start] == ' ' || s[start] == '\t'))
    start++;
  while (end > start && (s[end - 1] == ' ' || s[end - 1] == '\t'))
    end--;
  if (end <= start) {
    *out = shu_target_cpu_detect_host();
    return 0;
  }
  return tcp_parse_named(s, start, end, out);
}

static int32_t tcp_eq5(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
  uint8_t lit[5];
  lit[0] = a0;
  lit[1] = a1;
  lit[2] = a2;
  lit[3] = a3;
  lit[4] = a4;
  return tcp_eq_at(name, 0, 5, lit);
}

static int32_t tcp_eq6(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4,
                       uint8_t a5) {
  uint8_t lit[6];
  lit[0] = a0;
  lit[1] = a1;
  lit[2] = a2;
  lit[3] = a3;
  lit[4] = a4;
  lit[5] = a5;
  return tcp_eq_at(name, 0, 6, lit);
}

int shu_simd_is_vector_type_spelling(const char *name, size_t name_len) {
  const uint8_t *n = (const uint8_t *)name;
  if (!name || name_len == 0)
    return 0;
  if (name_len == 5) {
    if (tcp_eq5(n, 105, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 105, 51, 50, 120, 56) != 0)
      return 1;
    if (tcp_eq5(n, 117, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 117, 51, 50, 120, 56) != 0)
      return 1;
    if (tcp_eq5(n, 102, 51, 50, 120, 52) != 0)
      return 1;
    if (tcp_eq5(n, 118, 101, 99, 52, 102) != 0)
      return 1;
    if (tcp_eq5(n, 118, 101, 99, 56, 105) != 0)
      return 1;
  }
  if (name_len == 6) {
    if (tcp_eq6(n, 105, 51, 50, 120, 49, 54) != 0)
      return 1;
    if (tcp_eq6(n, 117, 51, 50, 120, 49, 54) != 0)
      return 1;
  }
  return 0;
}

int shu_simd_vector_lanes_esz_from_spelling(const char *name, size_t name_len, int32_t *out_lanes,
                                            int32_t *out_esz) {
  const uint8_t *n = (const uint8_t *)name;
  int32_t lanes = 4;
  int32_t esz = 4;
  if (!out_lanes || !out_esz)
    return -1;
  if (!shu_simd_is_vector_type_spelling(name, name_len))
    return -1;
  if (name_len == 5 && name[4] == '8')
    lanes = 8;
  if (name_len == 6 && name[4] == '1' && name[5] == '6')
    lanes = 16;
  if (name_len == 5 && tcp_eq5(n, 118, 101, 99, 56, 105) != 0)
    lanes = 8;
  *out_lanes = lanes;
  *out_esz = esz;
  return 0;
}

/* --- G-02f-5：print（stdio / FILE* 语言限制，逻辑与原 target_cpu.inc 一致）--- */

static void append_feat_name(char *buf, size_t cap, size_t *pos, const char *name) {
  size_t nlen;
  if (!buf || !pos || !name || *pos >= cap)
    return;
  if (*pos > 0 && *pos + 1 < cap)
    buf[(*pos)++] = ',';
  nlen = strlen(name);
  if (*pos + nlen >= cap)
    return;
  memcpy(buf + *pos, name, nlen);
  *pos += nlen;
  buf[*pos] = '\0';
}

void shu_target_cpu_print(FILE *out, uint32_t features) {
  char list[256];
  size_t pos = 0;

  if (!out)
    return;
  list[0] = '\0';
  if (features & 1u) /* SSE2 */
    append_feat_name(list, sizeof(list), &pos, "sse2");
  if (features & 2u) /* SSE41 */
    append_feat_name(list, sizeof(list), &pos, "sse4.1");
  if (features & 4u) /* AVX */
    append_feat_name(list, sizeof(list), &pos, "avx");
  if (features & 8u) /* AVX2 */
    append_feat_name(list, sizeof(list), &pos, "avx2");
  if (features & 16u) /* AVX512F */
    append_feat_name(list, sizeof(list), &pos, "avx512f");
  if (features & 32u) /* POPCNT */
    append_feat_name(list, sizeof(list), &pos, "popcnt");
  if (features & 64u) /* BMI2 */
    append_feat_name(list, sizeof(list), &pos, "bmi2");
  if (features & 256u) /* NEON */
    append_feat_name(list, sizeof(list), &pos, "neon");
  if (features & 512u) /* SVE */
    append_feat_name(list, sizeof(list), &pos, "sve");
  if (features & 65536u) /* RVV */
    append_feat_name(list, sizeof(list), &pos, "rvv");
  fprintf(out, "target_cpu_features=0x%08x\n", features);
  fprintf(out, "target_cpu_features_list=%s\n", list[0] ? list : "(none)");
  fprintf(out, "target_cpu_host_features=0x%08x\n", shu_target_cpu_detect_host());
}
