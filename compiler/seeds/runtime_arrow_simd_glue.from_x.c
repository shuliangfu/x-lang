/* seeds/runtime_arrow_simd_glue.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
/**
 * runtime_arrow_simd_glue.c — F-ZC：自 std/db 胶层迁入
 *
 * SSE2 / NEON 内核暂留 C；列/batch 生命周期见 std/db/arrow/arrow.x。
 */

#include <stddef.h>
#include <stdint.h>

#if defined(__SSE2__) || (defined(__x86_64__) && !defined(_MSC_VER))
#include <emmintrin.h>
#define ARROW_HAVE_SSE2 1
#endif
#if defined(__ARM_NEON) || defined(__aarch64__)
#include <arm_neon.h>
#define ARROW_HAVE_NEON 1
#endif

/** 列内存布局（与 arrow.x ArrowColumnMem ABI 一致）。 */
typedef struct {
    int32_t type_id;
    int32_t length;
    int32_t capacity;
    void *data;
    uint8_t *null_bitmap;
    int32_t data_owned;
} arrow_column_t;

#define ARROW_TYPE_I32 1
#define ARROW_TYPE_F32 2

#if defined(ARROW_HAVE_SSE2)
/** SSE2：水平求和 4×f32。 */
static float arrow_hsum_ps(__m128 v) {
    __m128 shuf = _mm_shuffle_ps(v, v, _MM_SHUFFLE(2, 3, 0, 1));
    __m128 sums = _mm_add_ps(v, shuf);
    shuf = _mm_movehl_ps(shuf, sums);
    sums = _mm_add_ss(sums, shuf);
    return _mm_cvtss_f32(sums);
}
#endif

/** f32 列前 n 元素求和（SIMD 内核，无 null 检查）。 */
static float arrow_f32_sum_kernel(const float *data, int32_t n) {
    int32_t i = 0;
    float sum = 0.0f;
#if defined(ARROW_HAVE_SSE2)
    __m128 acc = _mm_setzero_ps();
    for (; i + 4 <= n; i += 4) {
        __m128 v = _mm_loadu_ps(data + i);
        acc = _mm_add_ps(acc, v);
    }
    sum = arrow_hsum_ps(acc);
#elif defined(ARROW_HAVE_NEON)
    float32x4_t acc = vdupq_n_f32(0.0f);
    for (; i + 4 <= n; i += 4) {
        float32x4_t v = vld1q_f32(data + i);
        acc = vaddq_f32(acc, v);
    }
    sum = vgetq_lane_f32(acc, 0) + vgetq_lane_f32(acc, 1) + vgetq_lane_f32(acc, 2) + vgetq_lane_f32(acc, 3);
#endif
    for (; i < n; i++)
        sum += data[i];
    return sum;
}

/** f32 两列点积（SIMD 内核）。 */
static float arrow_f32_dot_kernel(const float *a, const float *b, int32_t n) {
    int32_t i = 0;
    float sum = 0.0f;
#if defined(ARROW_HAVE_SSE2)
    __m128 acc = _mm_setzero_ps();
    for (; i + 4 <= n; i += 4) {
        __m128 va = _mm_loadu_ps(a + i);
        __m128 vb = _mm_loadu_ps(b + i);
        acc = _mm_add_ps(acc, _mm_mul_ps(va, vb));
    }
    sum = arrow_hsum_ps(acc);
#elif defined(ARROW_HAVE_NEON)
    float32x4_t acc = vdupq_n_f32(0.0f);
    for (; i + 4 <= n; i += 4) {
        float32x4_t va = vld1q_f32(a + i);
        float32x4_t vb = vld1q_f32(b + i);
        acc = vaddq_f32(acc, vmulq_f32(va, vb));
    }
    sum = vgetq_lane_f32(acc, 0) + vgetq_lane_f32(acc, 1) + vgetq_lane_f32(acc, 2) + vgetq_lane_f32(acc, 3);
#endif
    for (; i < n; i++)
        sum += a[i] * b[i];
    return sum;
}

/** i32 列前 n 个有效元素累加（null bitmap）。 */
static int32_t arrow_i32_sum_valid_kernel(const int32_t *data, const uint8_t *bm, int32_t n) {
    int32_t i = 0;
    int32_t sum = 0;
    if (!data)
        return 0;
    while (i < n) {
        uint8_t mask_byte;
        if (!bm) {
            sum += data[i];
            i++;
            continue;
        }
        mask_byte = (uint8_t)(bm[i / 8] >> (i % 8));
#if defined(ARROW_HAVE_SSE2)
        if ((i % 4) == 0 && (i + 4) <= n && (mask_byte & 0xFu) == 0xFu) {
            __m128i v = _mm_loadu_si128((const __m128i *)(const void *)(data + i));
            __m128i s = _mm_add_epi32(v, _mm_shuffle_epi32(v, _MM_SHUFFLE(1, 0, 3, 2)));
            s = _mm_add_epi32(s, _mm_shuffle_epi32(s, _MM_SHUFFLE(2, 3, 0, 1)));
            sum += _mm_cvtsi128_si32(s);
            i += 4;
            continue;
        }
#elif defined(ARROW_HAVE_NEON)
        if ((i % 4) == 0 && (i + 4) <= n && (mask_byte & 0xFu) == 0xFu) {
            int32x4_t v = vld1q_s32(data + i);
            int32x2_t p = vadd_s32(vget_low_s32(v), vget_high_s32(v));
            sum += vget_lane_s32(p, 0) + vget_lane_s32(p, 1);
            i += 4;
            continue;
        }
#endif
        if ((mask_byte & 1u) != 0)
            sum += data[i];
        i++;
    }
    return sum;
}

/** f32 列前 n 个有效元素求和（null bitmap）。 */
static float arrow_f32_sum_valid_kernel(const float *data, const uint8_t *bm, int32_t n) {
    int32_t i = 0;
    float sum = 0.0f;
    if (!data)
        return 0.0f;
    while (i < n) {
        uint8_t mask_byte;
        if (!bm) {
            sum += data[i];
            i++;
            continue;
        }
        mask_byte = (uint8_t)(bm[i / 8] >> (i % 8));
#if defined(ARROW_HAVE_SSE2)
        if ((i % 4) == 0 && (i + 4) <= n && (mask_byte & 0xFu) == 0xFu) {
            __m128 v = _mm_loadu_ps(data + i);
            sum += arrow_hsum_ps(v);
            i += 4;
            continue;
        }
        if ((i % 4) == 0 && (i + 4) <= n && mask_byte == 0) {
            i += 4;
            continue;
        }
#elif defined(ARROW_HAVE_NEON)
        if ((i % 4) == 0 && (i + 4) <= n && (mask_byte & 0xFu) == 0xFu) {
            float32x4_t v = vld1q_f32(data + i);
            sum += vgetq_lane_f32(v, 0) + vgetq_lane_f32(v, 1) + vgetq_lane_f32(v, 2) + vgetq_lane_f32(v, 3);
            i += 4;
            continue;
        }
        if ((i % 4) == 0 && (i + 4) <= n && mask_byte == 0) {
            i += 4;
            continue;
        }
#endif
        if ((mask_byte & 1u) != 0)
            sum += data[i];
        i++;
    }
    return sum;
}

static arrow_column_t *arrow_col_ptr(int64_t handle) {
    return (arrow_column_t *)(uintptr_t)handle;
}

/** i32 列有效元素累加（SIMD 胶层）。 */
int32_t arrow_column_i32_sum_valid_c(int64_t handle, int32_t n) {
    arrow_column_t *c = arrow_col_ptr(handle);
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_I32 || !c->data)
        return 0;
    len = c->length;
    if (n < len)
        len = n;
    return arrow_i32_sum_valid_kernel((const int32_t *)c->data, c->null_bitmap, len);
}

/** f32 列求和（SIMD 胶层）。 */
float arrow_column_f32_sum_c(int64_t handle, int32_t n) {
    arrow_column_t *c = arrow_col_ptr(handle);
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_F32 || !c->data)
        return 0.0f;
    len = c->length;
    if (n < len)
        len = n;
    return arrow_f32_sum_kernel((const float *)c->data, len);
}

/** f32 列有效元素求和（SIMD 胶层）。 */
float arrow_column_f32_sum_valid_c(int64_t handle, int32_t n) {
    arrow_column_t *c = arrow_col_ptr(handle);
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_F32 || !c->data)
        return 0.0f;
    len = c->length;
    if (n < len)
        len = n;
    return arrow_f32_sum_valid_kernel((const float *)c->data, c->null_bitmap, len);
}

/** f32 两列点积（SIMD 胶层）。 */
float arrow_column_f32_dot_c(int64_t handle_a, int64_t handle_b, int32_t n) {
    arrow_column_t *a = arrow_col_ptr(handle_a);
    arrow_column_t *b = arrow_col_ptr(handle_b);
    int32_t len;
    if (!a || !b || a->type_id != ARROW_TYPE_F32 || b->type_id != ARROW_TYPE_F32 || !a->data || !b->data)
        return 0.0f;
    len = a->length < b->length ? a->length : b->length;
    if (n < len)
        len = n;
    return arrow_f32_dot_kernel((const float *)a->data, (const float *)b->data, len);
}
