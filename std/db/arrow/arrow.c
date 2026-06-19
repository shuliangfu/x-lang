/**
 * std/db/arrow/arrow.c — Apache Arrow 风格列式内存 v2
 *
 * 【布局】64B 对齐 data + null_bitmap（bit=1 有效）+ length/capacity
 * 【零拷贝】adopt_* 接管外部指针（网卡 buffer），destroy 不释放外部内存
 * 【SIMD】i32/f32 归约内核（SSE2 / NEON，标量回退）
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(__SSE2__) || (defined(__x86_64__) && !defined(_MSC_VER))
#include <emmintrin.h>
#define ARROW_HAVE_SSE2 1
#endif
#if defined(__ARM_NEON) || defined(__aarch64__)
#include <arm_neon.h>
#define ARROW_HAVE_NEON 1
#endif

#define ARROW_ALIGN 64u
#define ARROW_TYPE_I32 1
#define ARROW_TYPE_F32 2
#define ARROW_TYPE_F64 3

typedef struct {
    int32_t type_id;
    int32_t length;
    int32_t capacity;
    void *data;
    uint8_t *null_bitmap;
    int32_t data_owned;
} arrow_column_t;

typedef struct {
    int32_t n_cols;
    int32_t cap_cols;
    arrow_column_t **cols;
} arrow_batch_t;

static void *arrow_aligned_alloc(size_t size) {
    void *p = NULL;
#if defined(_POSIX_C_SOURCE) || defined(__APPLE__)
    if (posix_memalign(&p, ARROW_ALIGN, size) != 0) {
        return NULL;
    }
    return p;
#else
    p = malloc(size + ARROW_ALIGN);
    if (!p) {
        return NULL;
    }
    return (void *)(((uintptr_t)p + ARROW_ALIGN - 1) & ~(uintptr_t)(ARROW_ALIGN - 1));
#endif
}

static void arrow_aligned_free(void *p) {
    free(p);
}

static uint8_t *arrow_null_bitmap_alloc(int32_t capacity) {
    size_t n = ((size_t)capacity + 7u) / 8u;
    uint8_t *bm = (uint8_t *)calloc(n, 1);
    if (!bm) {
        return NULL;
    }
    memset(bm, 0xFF, n);
    return bm;
}

static void arrow_null_bitmap_set(arrow_column_t *c, int32_t index, int32_t is_valid) {
    size_t byte_i;
    uint8_t mask;
    if (!c || !c->null_bitmap || index < 0 || index >= c->capacity) {
        return;
    }
    byte_i = (size_t)index / 8u;
    mask = (uint8_t)(1u << (index % 8));
    if (is_valid) {
        c->null_bitmap[byte_i] |= mask;
    } else {
        c->null_bitmap[byte_i] &= (uint8_t)~mask;
    }
}

static arrow_column_t *arrow_column_create_typed(int32_t type_id, int32_t capacity, size_t elem_size) {
    arrow_column_t *c;
    if (capacity <= 0) {
        return NULL;
    }
    c = (arrow_column_t *)calloc(1, sizeof(*c));
    if (!c) {
        return NULL;
    }
    c->type_id = type_id;
    c->capacity = capacity;
    c->data_owned = 1;
    c->null_bitmap = arrow_null_bitmap_alloc(capacity);
    if (!c->null_bitmap) {
        free(c);
        return NULL;
    }
    c->data = arrow_aligned_alloc((size_t)capacity * elem_size);
    if (!c->data) {
        free(c->null_bitmap);
        free(c);
        return NULL;
    }
    return c;
}

int64_t arrow_column_i32_create_c(int32_t capacity) {
    arrow_column_t *c = arrow_column_create_typed(ARROW_TYPE_I32, capacity, sizeof(int32_t));
    return c ? (int64_t)(uintptr_t)c : 0;
}

int64_t arrow_column_f32_create_c(int32_t capacity) {
    arrow_column_t *c = arrow_column_create_typed(ARROW_TYPE_F32, capacity, sizeof(float));
    return c ? (int64_t)(uintptr_t)c : 0;
}

int64_t arrow_column_f64_create_c(int32_t capacity) {
    arrow_column_t *c = arrow_column_create_typed(ARROW_TYPE_F64, capacity, sizeof(double));
    return c ? (int64_t)(uintptr_t)c : 0;
}

/** 零拷贝：接管外部 F32 列（网卡 DMA buffer）；destroy 不 free data。 */
int64_t arrow_column_adopt_f32_c(float *ptr, int32_t len, int32_t capacity) {
    arrow_column_t *c;
    if (!ptr || len < 0 || capacity <= 0 || len > capacity) {
        return 0;
    }
    c = (arrow_column_t *)calloc(1, sizeof(*c));
    if (!c) {
        return 0;
    }
    c->type_id = ARROW_TYPE_F32;
    c->length = len;
    c->capacity = capacity;
    c->data = ptr;
    c->data_owned = 0;
    c->null_bitmap = arrow_null_bitmap_alloc(capacity);
    if (!c->null_bitmap) {
        free(c);
        return 0;
    }
    return (int64_t)(uintptr_t)c;
}

/** 零拷贝：接管外部 I32 列。 */
int64_t arrow_column_adopt_i32_c(int32_t *ptr, int32_t len, int32_t capacity) {
    arrow_column_t *c;
    if (!ptr || len < 0 || capacity <= 0 || len > capacity) {
        return 0;
    }
    c = (arrow_column_t *)calloc(1, sizeof(*c));
    if (!c) {
        return 0;
    }
    c->type_id = ARROW_TYPE_I32;
    c->length = len;
    c->capacity = capacity;
    c->data = ptr;
    c->data_owned = 0;
    c->null_bitmap = arrow_null_bitmap_alloc(capacity);
    if (!c->null_bitmap) {
        free(c);
        return 0;
    }
    return (int64_t)(uintptr_t)c;
}

int32_t arrow_column_type_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    return c ? c->type_id : 0;
}

int32_t arrow_column_len_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    return c ? c->length : 0;
}

int32_t arrow_column_capacity_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    return c ? c->capacity : 0;
}

int32_t arrow_column_data_owned_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    return c ? c->data_owned : 0;
}

uint8_t *arrow_column_null_bitmap_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    return c ? c->null_bitmap : NULL;
}

int32_t arrow_column_is_valid_c(int64_t handle, int32_t index) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    size_t byte_i;
    if (!c || !c->null_bitmap || index < 0 || index >= c->length) {
        return 0;
    }
    byte_i = (size_t)index / 8u;
    return (c->null_bitmap[byte_i] >> (index % 8)) & 1;
}

int32_t *arrow_column_i32_data_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    if (!c || c->type_id != ARROW_TYPE_I32) {
        return NULL;
    }
    return (int32_t *)c->data;
}

float *arrow_column_f32_data_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    if (!c || c->type_id != ARROW_TYPE_F32) {
        return NULL;
    }
    return (float *)c->data;
}

double *arrow_column_f64_data_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    if (!c || c->type_id != ARROW_TYPE_F64) {
        return NULL;
    }
    return (double *)c->data;
}

int32_t arrow_column_i32_append_c(int64_t handle, int32_t val) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    int32_t *d;
    if (!c || c->type_id != ARROW_TYPE_I32 || c->length >= c->capacity) {
        return -1;
    }
    d = (int32_t *)c->data;
    d[c->length] = val;
    arrow_null_bitmap_set(c, c->length, 1);
    c->length++;
    return 0;
}

int32_t arrow_column_i32_append_null_c(int64_t handle, int32_t val, int32_t is_valid) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    int32_t *d;
    if (!c || c->type_id != ARROW_TYPE_I32 || c->length >= c->capacity) {
        return -1;
    }
    d = (int32_t *)c->data;
    d[c->length] = val;
    arrow_null_bitmap_set(c, c->length, is_valid);
    c->length++;
    return 0;
}

int32_t arrow_column_f32_append_c(int64_t handle, float val) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    float *d;
    if (!c || c->type_id != ARROW_TYPE_F32 || c->length >= c->capacity) {
        return -1;
    }
    d = (float *)c->data;
    d[c->length] = val;
    arrow_null_bitmap_set(c, c->length, 1);
    c->length++;
    return 0;
}

int32_t arrow_column_f64_append_c(int64_t handle, double val) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    double *d;
    if (!c || c->type_id != ARROW_TYPE_F64 || c->length >= c->capacity) {
        return -1;
    }
    d = (double *)c->data;
    d[c->length] = val;
    arrow_null_bitmap_set(c, c->length, 1);
    c->length++;
    return 0;
}

void arrow_column_destroy_c(int64_t handle) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    if (!c) {
        return;
    }
    if (c->data && c->data_owned) {
        arrow_aligned_free(c->data);
    }
    free(c->null_bitmap);
    free(c);
}

int64_t arrow_batch_create_c(int32_t max_cols) {
    arrow_batch_t *b;
    if (max_cols <= 0) {
        return 0;
    }
    b = (arrow_batch_t *)calloc(1, sizeof(*b));
    if (!b) {
        return 0;
    }
    b->cap_cols = max_cols;
    b->cols = (arrow_column_t **)calloc((size_t)max_cols, sizeof(arrow_column_t *));
    if (!b->cols) {
        free(b);
        return 0;
    }
    return (int64_t)(uintptr_t)b;
}

int32_t arrow_batch_add_column_c(int64_t batch, int64_t col) {
    arrow_batch_t *b = (arrow_batch_t *)(uintptr_t)batch;
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)col;
    if (!b || !c || b->n_cols >= b->cap_cols) {
        return -1;
    }
    b->cols[b->n_cols] = c;
    b->n_cols++;
    return 0;
}

int64_t arrow_batch_column_c(int64_t batch, int32_t index) {
    arrow_batch_t *b = (arrow_batch_t *)(uintptr_t)batch;
    if (!b || index < 0 || index >= b->n_cols) {
        return 0;
    }
    return (int64_t)(uintptr_t)b->cols[index];
}

int32_t arrow_batch_len_c(int64_t batch) {
    arrow_batch_t *b = (arrow_batch_t *)(uintptr_t)batch;
    return b ? b->n_cols : 0;
}

void arrow_batch_destroy_c(int64_t batch) {
    arrow_batch_t *b = (arrow_batch_t *)(uintptr_t)batch;
    int32_t i;
    if (!b) {
        return;
    }
    for (i = 0; i < b->n_cols; i++) {
        if (b->cols[i]) {
            arrow_column_destroy_c((int64_t)(uintptr_t)b->cols[i]);
        }
    }
    free(b->cols);
    free(b);
}

/** SSE2：水平求和 4×f32。 */
#if defined(ARROW_HAVE_SSE2)
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
    for (; i < n; i++) {
        sum += data[i];
    }
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
    for (; i < n; i++) {
        sum += a[i] * b[i];
    }
    return sum;
}

/** i32 列前 n 个有效元素累加（null bitmap；8/4 连续有效 lane 走 SIMD）。 */
static int32_t arrow_i32_sum_valid_kernel(const int32_t *data, const uint8_t *bm, int32_t n) {
    int32_t i = 0;
    int32_t sum = 0;
    if (!data) {
        return 0;
    }
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
        if ((mask_byte & 1u) != 0) {
            sum += data[i];
        }
        i++;
    }
    return sum;
}

/** f32 列前 n 个有效元素求和（null bitmap；4 连续有效 lane 走 SIMD）。 */
static float arrow_f32_sum_valid_kernel(const float *data, const uint8_t *bm, int32_t n) {
    int32_t i = 0;
    float sum = 0.0f;
    if (!data) {
        return 0.0f;
    }
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
        if ((mask_byte & 1u) != 0) {
            sum += data[i];
        }
        i++;
    }
    return sum;
}

int32_t arrow_column_i32_sum_valid_c(int64_t handle, int32_t n) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_I32 || !c->data) {
        return 0;
    }
    len = c->length;
    if (n < len) {
        len = n;
    }
    return arrow_i32_sum_valid_kernel((const int32_t *)c->data, c->null_bitmap, len);
}

float arrow_column_f32_sum_c(int64_t handle, int32_t n) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_F32 || !c->data) {
        return 0.0f;
    }
    len = c->length;
    if (n < len) {
        len = n;
    }
    return arrow_f32_sum_kernel((const float *)c->data, len);
}

float arrow_column_f32_sum_valid_c(int64_t handle, int32_t n) {
    arrow_column_t *c = (arrow_column_t *)(uintptr_t)handle;
    int32_t len;
    if (!c || c->type_id != ARROW_TYPE_F32 || !c->data) {
        return 0.0f;
    }
    len = c->length;
    if (n < len) {
        len = n;
    }
    return arrow_f32_sum_valid_kernel((const float *)c->data, c->null_bitmap, len);
}

float arrow_column_f32_dot_c(int64_t handle_a, int64_t handle_b, int32_t n) {
    arrow_column_t *a = (arrow_column_t *)(uintptr_t)handle_a;
    arrow_column_t *b = (arrow_column_t *)(uintptr_t)handle_b;
    int32_t len;
    if (!a || !b || a->type_id != ARROW_TYPE_F32 || b->type_id != ARROW_TYPE_F32 || !a->data || !b->data) {
        return 0.0f;
    }
    len = a->length < b->length ? a->length : b->length;
    if (n < len) {
        len = n;
    }
    return arrow_f32_dot_kernel((const float *)a->data, (const float *)b->data, len);
}

int32_t arrow_simd_smoke_c(void) {
    int64_t ci, cf, cf2;
    int32_t sum_i;
    float sum_f;
    float dot;
    ci = arrow_column_i32_create_c(16);
    cf = arrow_column_f32_create_c(16);
    cf2 = arrow_column_f32_create_c(16);
    if (ci == 0 || cf == 0 || cf2 == 0) {
        return -1;
    }
    if (arrow_column_i32_append_null_c(ci, 10, 1) != 0 || arrow_column_i32_append_null_c(ci, 0, 0) != 0
        || arrow_column_i32_append_null_c(ci, 20, 1) != 0) {
        return -2;
    }
    if (arrow_column_f32_append_c(cf, 1.0f) != 0 || arrow_column_f32_append_c(cf, 2.0f) != 0
        || arrow_column_f32_append_c(cf, 3.0f) != 0 || arrow_column_f32_append_c(cf, 4.0f) != 0) {
        return -3;
    }
    if (arrow_column_f32_append_c(cf2, 0.5f) != 0 || arrow_column_f32_append_c(cf2, 0.5f) != 0
        || arrow_column_f32_append_c(cf2, 0.5f) != 0 || arrow_column_f32_append_c(cf2, 0.5f) != 0) {
        return -4;
    }
    sum_i = arrow_column_i32_sum_valid_c(ci, 3);
    sum_f = arrow_column_f32_sum_c(cf, 4);
    dot = arrow_column_f32_dot_c(cf, cf2, 4);
    if (arrow_column_f32_sum_valid_c(cf, 4) < 9.99f || arrow_column_f32_sum_valid_c(cf, 4) > 10.01f) {
        arrow_column_destroy_c(ci);
        arrow_column_destroy_c(cf);
        arrow_column_destroy_c(cf2);
        return -8;
    }
    arrow_column_destroy_c(ci);
    arrow_column_destroy_c(cf);
    arrow_column_destroy_c(cf2);
    if (sum_i != 30) {
        return -5;
    }
    if (sum_f < 9.99f || sum_f > 10.01f) {
        return -6;
    }
    if (dot < 4.99f || dot > 5.01f) {
        return -7;
    }
    return 0;
}

/** 烟测：i32/f32/f64 + null bitmap + adopt f32 + SIMD 归约。 */
int32_t arrow_smoke_c(void) {
    int64_t ci, cf, cf64, batch;
    int32_t *pi;
    float *pf;
    float nic_buf[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    int64_t adopted;
    ci = arrow_column_i32_create_c(1024);
    cf = arrow_column_f32_create_c(1024);
    cf64 = arrow_column_f64_create_c(1024);
    if (ci == 0 || cf == 0 || cf64 == 0) {
        return -1;
    }
    if (arrow_column_i32_append_null_c(ci, 42, 1) != 0 || arrow_column_f32_append_c(cf, 3.14f) != 0
        || arrow_column_f64_append_c(cf64, 2.718) != 0) {
        return -2;
    }
    if (arrow_column_is_valid_c(ci, 0) != 1) {
        return -3;
    }
    pi = arrow_column_i32_data_c(ci);
    pf = arrow_column_f32_data_c(cf);
    if (!pi || !pf || pi[0] != 42) {
        return -4;
    }
    adopted = arrow_column_adopt_f32_c(nic_buf, 4, 4);
    if (adopted == 0 || arrow_column_data_owned_c(adopted) != 0) {
        return -5;
    }
    if (arrow_column_f32_data_c(adopted)[2] != 3.0f) {
        return -6;
    }
    batch = arrow_batch_create_c(8);
    if (batch == 0) {
        arrow_column_destroy_c(adopted);
        return -7;
    }
    if (arrow_batch_add_column_c(batch, ci) != 0 || arrow_batch_add_column_c(batch, cf) != 0
        || arrow_batch_add_column_c(batch, adopted) != 0) {
        arrow_batch_destroy_c(batch);
        return -8;
    }
    if (arrow_batch_len_c(batch) != 3) {
        arrow_batch_destroy_c(batch);
        return -9;
    }
    arrow_batch_destroy_c(batch);
    arrow_column_destroy_c(cf64);
    if (arrow_simd_smoke_c() != 0) {
        return -10;
    }
    return 0;
}
