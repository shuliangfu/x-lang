/* target_cpu_pure.from_x.c — G-02f-2/3 product pure half of target_cpu.o
 *
 * Source of truth: src/driver/target_cpu_pure.x
 * Regen pending-only: ./shux-c src/driver/target_cpu_pure.x -E  (may hang if SIMD helpers present)
 * Full body below is hand-synced to .x (bytewise SIMD compare) when -E is stuck.
 * Product: ld -r pure.o + target_cpu_detect.o → target_cpu.o
 */
#include <stdint.h>
#include <stddef.h>

static uint32_t g_driver_pending_target_cpu_features;

void driver_set_pending_target_cpu_features(uint32_t features) {
  g_driver_pending_target_cpu_features = features;
}

uint32_t driver_get_pending_target_cpu_features(void) {
  return g_driver_pending_target_cpu_features;
}

static uint8_t tcp_tolower(uint8_t c) {
  if (c >= 65 && c <= 90)
    return (uint8_t)(c + 32);
  return c;
}

static int32_t tcp_eq5(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
  if (tcp_tolower(name[0]) != a0)
    return 0;
  if (tcp_tolower(name[1]) != a1)
    return 0;
  if (tcp_tolower(name[2]) != a2)
    return 0;
  if (tcp_tolower(name[3]) != a3)
    return 0;
  if (tcp_tolower(name[4]) != a4)
    return 0;
  return 1;
}

static int32_t tcp_eq6(const uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4,
                       uint8_t a5) {
  if (tcp_tolower(name[0]) != a0)
    return 0;
  if (tcp_tolower(name[1]) != a1)
    return 0;
  if (tcp_tolower(name[2]) != a2)
    return 0;
  if (tcp_tolower(name[3]) != a3)
    return 0;
  if (tcp_tolower(name[4]) != a4)
    return 0;
  if (tcp_tolower(name[5]) != a5)
    return 0;
  return 1;
}

int shu_simd_is_vector_type_spelling(const char *name, size_t name_len) {
  const uint8_t *n = (const uint8_t *)name;
  if (!name || name_len == 0)
    return 0;
  if (name_len == 5) {
    if (tcp_eq5(n, 105, 51, 50, 120, 52) != 0)
      return 1; /* i32x4 */
    if (tcp_eq5(n, 105, 51, 50, 120, 56) != 0)
      return 1; /* i32x8 */
    if (tcp_eq5(n, 117, 51, 50, 120, 52) != 0)
      return 1; /* u32x4 */
    if (tcp_eq5(n, 117, 51, 50, 120, 56) != 0)
      return 1; /* u32x8 */
    if (tcp_eq5(n, 102, 51, 50, 120, 52) != 0)
      return 1; /* f32x4 */
    if (tcp_eq5(n, 118, 101, 99, 52, 102) != 0)
      return 1; /* Vec4f */
    if (tcp_eq5(n, 118, 101, 99, 56, 105) != 0)
      return 1; /* Vec8i */
  }
  if (name_len == 6) {
    if (tcp_eq6(n, 105, 51, 50, 120, 49, 54) != 0)
      return 1; /* i32x16 */
    if (tcp_eq6(n, 117, 51, 50, 120, 49, 54) != 0)
      return 1; /* u32x16 */
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
    lanes = 8; /* Vec8i */
  *out_lanes = lanes;
  *out_esz = esz;
  return 0;
}
