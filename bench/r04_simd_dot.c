/* simd_dot.c — Vec4f 点积累加 bench 参照（SSE mulps + 水平求和）。 */
#include <immintrin.h>
#include <stdint.h>
#include <stdio.h>

/** 水平求和 xmm 内 4 个 f32。 */
static float hsum_ps(__m128 v) {
  __m128 shuf = _mm_shuffle_ps(v, v, _MM_SHUFFLE(2, 3, 0, 1));
  __m128 sums = _mm_add_ps(v, shuf);
  shuf = _mm_movehl_ps(shuf, sums);
  sums = _mm_add_ss(sums, shuf);
  return _mm_cvtss_f32(sums);
}

int main(void) {
  enum { limit = 2000000 };
  float sum = 0.0f;
  int i;
  for (i = 0; i < limit; i++) {
    float t = (float)(i % 256);
    __m128 a = _mm_set_ps(t + 3.0f, t + 2.0f, t + 1.0f, t);
    __m128 b = _mm_set_ps(0.0625f, 0.125f, 0.25f, 0.5f);
    __m128 p = _mm_mul_ps(a, b);
    sum += hsum_ps(p);
  }
  printf("%f\n", sum);
  return 0;
}
