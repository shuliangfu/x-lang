/*
 * Thin pure: wave270 type pool Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave270 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule).
 * Type LE: kind@0 name[256]@4 name_len@260 elem@264 array_size@268
 *   region_label[256]@272 region_label_len@528 size=532
 * Cap residual: pipeline_arena_type_ptr / alloc (extern).
 *
 * Faces: named/region accessors + find_or_alloc_* + kind/elem/array
 *   + ensure/init_* helpers.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding type pool Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern void *pipeline_arena_type_ptr(void *arena, int32_t ref);
extern int32_t pipeline_arena_type_alloc(void *arena);
extern int32_t pipeline_arena_num_types(void *arena);

enum {
  W270_TY_NAMED = 8,
  W270_TY_PTR = 9,
  W270_TY_SLICE = 11,
  W270_TY_SIZE = 532
};

static int32_t ty_kind_from_ord(int32_t ord) {
  if (ord < 0 || ord > 16)
    return 0;
  return ord;
}

static void ty_zero_slot(uint8_t *t) {
  int32_t i;
  if (!t)
    return;
  for (i = 0; i < W270_TY_SIZE; i++)
    t[i] = 0;
}

static void ty_store_i32(uint8_t *b, int32_t off, int32_t v) {
  b[off] = (uint8_t)(v & 255);
  b[off + 1] = (uint8_t)((v >> 8) & 255);
  b[off + 2] = (uint8_t)((v >> 16) & 255);
  b[off + 3] = (uint8_t)((v >> 24) & 255);
}

static int32_t ty_load_i32(uint8_t *b, int32_t off) {
  return (int32_t)((uint32_t)b[off] | ((uint32_t)b[off + 1] << 8) | ((uint32_t)b[off + 2] << 16) |
                   ((uint32_t)b[off + 3] << 24));
}

static int32_t ty_bytes_eq(uint8_t *a, uint8_t *b, int32_t n) {
  int32_t i;
  if (n <= 0)
    return 1;
  if (!a || !b)
    return 0;
  for (i = 0; i < n; i++)
    if (a[i] != b[i])
      return 0;
  return 1;
}

static uint8_t *ty_slot_at(void *arena, int32_t ref) {
  int32_t nt;
  if (!arena || ref <= 0)
    return NULL;
  nt = pipeline_arena_num_types(arena);
  if (ref > nt)
    return NULL;
  return (uint8_t *)pipeline_arena_type_ptr(arena, ref);
}

int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64) {
  uint8_t *t;
  int32_t n, cn, i;
  if (!out64)
    return 0;
  t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  n = ty_load_i32(t, 132);
  cn = n > 64 ? 64 : n;
  for (i = 0; i < cn; i++)
    out64[i] = t[4 + i];
  return n;
}

int32_t pipeline_type_region_label_into(void *arena, int32_t ref, uint8_t *out64) {
  uint8_t *t;
  int32_t n, cn, i;
  if (!out64)
    return 0;
  t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  n = ty_load_i32(t, 272);
  if (n <= 0)
    return 0;
  cn = n > 64 ? 64 : n;
  for (i = 0; i < cn; i++)
    out64[i] = t[144 + i];
  return n;
}

int32_t pipeline_type_region_label_len_at(void *arena, int32_t ref) {
  uint8_t *t = ty_slot_at(arena, ref);
  int32_t n;
  if (!t)
    return 0;
  n = ty_load_i32(t, 272);
  return n > 0 ? n : 0;
}

int32_t pipeline_type_set_region_label_at(void *arena, int32_t ref, uint8_t *label, int32_t label_len) {
  uint8_t *t;
  int32_t kind, i;
  if (!label || label_len <= 0 || label_len > 255)
    return 0;
  t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  kind = ty_load_i32(t, 0);
  if (kind != W270_TY_SLICE && kind != W270_TY_PTR)
    return 0;
  for (i = 0; i < 128; i++)
    t[144 + i] = 0;
  for (i = 0; i < label_len; i++)
    t[144 + i] = label[i];
  ty_store_i32(t, 272, label_len);
  return 1;
}

int32_t pipeline_type_find_or_alloc_slice(void *a, int32_t elem_ref, uint8_t *region, int32_t region_len) {
  int32_t nt, k;
  uint8_t *t;
  if (!a || region_len < 0 || region_len > 255)
    return 0;
  if (region_len > 0 && !region)
    return 0;
  nt = pipeline_arena_num_types(a);
  for (k = 1; k <= nt; k++) {
    t = (uint8_t *)pipeline_arena_type_ptr(a, k);
    if (!t)
      continue;
    if (ty_load_i32(t, 0) == W270_TY_SLICE && ty_load_i32(t, 136) == elem_ref &&
        ty_load_i32(t, 140) == 0 && ty_load_i32(t, 132) == 0 &&
        ty_load_i32(t, 272) == region_len &&
        (region_len == 0 || ty_bytes_eq(t + 144, region, region_len)))
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, W270_TY_SLICE);
  ty_store_i32(t, 136, elem_ref);
  if (region_len > 0 && region) {
    int32_t i;
    for (i = 0; i < region_len; i++)
      t[144 + i] = region[i];
    ty_store_i32(t, 272, region_len);
  }
  return k;
}

int32_t pipeline_type_find_or_alloc_ptr(void *a, int32_t elem_ref, uint8_t *region, int32_t region_len) {
  int32_t nt, k;
  uint8_t *t;
  if (!a || elem_ref <= 0 || region_len < 0 || region_len > 255)
    return 0;
  if (region_len > 0 && !region)
    return 0;
  nt = pipeline_arena_num_types(a);
  for (k = 1; k <= nt; k++) {
    t = (uint8_t *)pipeline_arena_type_ptr(a, k);
    if (!t)
      continue;
    if (ty_load_i32(t, 0) == W270_TY_PTR && ty_load_i32(t, 136) == elem_ref &&
        ty_load_i32(t, 140) == 0 && ty_load_i32(t, 132) == 0 &&
        ty_load_i32(t, 272) == region_len &&
        (region_len == 0 || ty_bytes_eq(t + 144, region, region_len)))
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, W270_TY_PTR);
  ty_store_i32(t, 136, elem_ref);
  if (region_len > 0 && region) {
    int32_t i;
    for (i = 0; i < region_len; i++)
      t[144 + i] = region[i];
    ty_store_i32(t, 272, region_len);
  }
  return k;
}

int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref) {
  uint8_t *t = ty_slot_at(arena, ref);
  if (!t)
    return -1;
  return ty_load_i32(t, 0);
}

int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref) {
  uint8_t *t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  return ty_load_i32(t, 136);
}

int32_t pipeline_type_set_elem_array_size_at(void *arena, int32_t ref, int32_t elem_ref, int32_t array_size) {
  uint8_t *t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  ty_store_i32(t, 136, elem_ref);
  ty_store_i32(t, 140, array_size);
  return 1;
}

int32_t pipeline_type_array_size_at(void *arena, int32_t ref) {
  uint8_t *t = ty_slot_at(arena, ref);
  if (!t)
    return 0;
  return ty_load_i32(t, 140);
}

int32_t pipeline_type_ensure_by_kind_ord(void *a, int32_t kind_ord) {
  int32_t nt, k, kind;
  uint8_t *t;
  if (!a || kind_ord < 0 || kind_ord > 16)
    return 0;
  kind = ty_kind_from_ord(kind_ord);
  nt = pipeline_arena_num_types(a);
  for (k = 1; k <= nt; k++) {
    t = (uint8_t *)pipeline_arena_type_ptr(a, k);
    if (t && ty_load_i32(t, 0) == kind && ty_load_i32(t, 132) == 0 &&
        ty_load_i32(t, 136) == 0 && ty_load_i32(t, 140) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, kind);
  return k;
}

int32_t pipeline_type_init_primitive_kind_at(void *a, int32_t ref, int32_t kind_ord) {
  uint8_t *t;
  if (!a || ref <= 0 || kind_ord < 0 || kind_ord > 16)
    return 0;
  if (ref > pipeline_arena_num_types(a))
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, ty_kind_from_ord(kind_ord));
  return 1;
}

int32_t pipeline_type_init_named_at(void *a, int32_t ref, uint8_t *name, int32_t name_len) {
  uint8_t *t;
  int32_t i;
  if (!a || ref <= 0 || !name || name_len <= 0 || name_len > 255)
    return 0;
  if (ref > pipeline_arena_num_types(a))
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, W270_TY_NAMED);
  ty_store_i32(t, 132, name_len);
  for (i = 0; i < name_len; i++)
    t[4 + i] = name[i];
  return 1;
}

int32_t pipeline_type_init_compound_kind_at(void *a, int32_t ref, int32_t kind_ord, int32_t elem_ref,
                                            int32_t array_size) {
  uint8_t *t;
  if (!a || ref <= 0 || kind_ord < 0 || kind_ord > 15)
    return 0;
  if (ref > pipeline_arena_num_types(a))
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, ty_kind_from_ord(kind_ord));
  ty_store_i32(t, 136, elem_ref);
  ty_store_i32(t, 140, array_size);
  return 1;
}

int32_t pipeline_type_find_or_alloc_named(void *a, uint8_t *name, int32_t name_len) {
  int32_t nt, k, i;
  uint8_t *t;
  if (!a || !name || name_len <= 0 || name_len > 255)
    return 0;
  nt = pipeline_arena_num_types(a);
  for (k = 1; k <= nt; k++) {
    t = (uint8_t *)pipeline_arena_type_ptr(a, k);
    if (t && ty_load_i32(t, 0) == W270_TY_NAMED && ty_load_i32(t, 132) == name_len &&
        ty_bytes_eq(t + 4, name, name_len))
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, W270_TY_NAMED);
  ty_store_i32(t, 132, name_len);
  for (i = 0; i < name_len; i++)
    t[4 + i] = name[i];
  return k;
}

int32_t pipeline_type_find_or_alloc_compound(void *a, int32_t kind_ord, int32_t elem_ref, int32_t array_size) {
  int32_t nt, k, kind;
  uint8_t *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = ty_kind_from_ord(kind_ord);
  nt = pipeline_arena_num_types(a);
  for (k = 1; k <= nt; k++) {
    t = (uint8_t *)pipeline_arena_type_ptr(a, k);
    if (t && ty_load_i32(t, 0) == kind && ty_load_i32(t, 136) == elem_ref &&
        ty_load_i32(t, 140) == array_size && ty_load_i32(t, 132) == 0 &&
        ty_load_i32(t, 272) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = (uint8_t *)pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  ty_zero_slot(t);
  ty_store_i32(t, 0, kind);
  ty_store_i32(t, 136, elem_ref);
  ty_store_i32(t, 140, array_size);
  return k;
}

