/* simd_shuffle_select_stub.c — STD-061 桩基线：纯标量 lane shuffle/select（无 SIMD intrinsic）。 */
#include <stdint.h>
#include <stdio.h>

/** Vec4f 标量 shuffle：r[i]=v[mask[i]]。 */
static void shuffle4f(const float *v, const int mask[4], float r[4]) {
  int i;
  for (i = 0; i < 4; i++) {
    r[i] = v[mask[i]];
  }
}

/** Vec8i 标量 shuffle。 */
static void shuffle8i(const int32_t *v, const int mask[8], int32_t r[8]) {
  int i;
  for (i = 0; i < 8; i++) {
    r[i] = v[mask[i]];
  }
}

/** Vec4f 标量 select：mask[i]!=0 取 a，否则 b。 */
static void select4f(const float mask[4], const float a[4], const float b[4], float r[4]) {
  int i;
  for (i = 0; i < 4; i++) {
    r[i] = (mask[i] != 0.0f) ? a[i] : b[i];
  }
}

/** Vec8i 标量 select。 */
static void select8i(const int32_t mask[8], const int32_t a[8], const int32_t b[8], int32_t r[8]) {
  int i;
  for (i = 0; i < 8; i++) {
    r[i] = (mask[i] != 0) ? a[i] : b[i];
  }
}

int main(void) {
  enum { limit = 2000000 };
  int32_t acc = 0;
  int i;
  const float v4[4] = {1.0f, 2.0f, 3.0f, 4.0f};
  const int32_t v8[8] = {0, 1, 2, 3, 4, 5, 6, 7};
  const float mask4[4] = {1.0f, 0.0f, 1.0f, 0.0f};
  const float a4[4] = {2.0f, 2.0f, 2.0f, 2.0f};
  const float b4[4] = {0.5f, 0.5f, 0.5f, 0.5f};
  const int m4[4] = {3, 2, 1, 0};
  const int m8[8] = {3, 2, 1, 0, 7, 6, 5, 4};
  float r4[4];
  float s4[4];
  int32_t r8[8];
  int32_t s8[8];
  int32_t z8[8] = {0, 0, 0, 0, 0, 0, 0, 0};

  for (i = 0; i < limit; i++) {
    shuffle4f(v4, m4, r4);
    select4f(mask4, a4, b4, s4);
    shuffle8i(v8, m8, r8);
    select8i(m8, r8, z8, s8);
    acc += r8[0] + s8[1] + (int32_t)r4[0] + (int32_t)s4[0];
  }
  printf("%d\n", (int)acc);
  return 0;
}
