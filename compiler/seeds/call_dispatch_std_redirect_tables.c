/* seeds/call_dispatch_std_redirect_tables.c — Class BM
 * Table form of glue_try_std_heap_redirect_sym_local (was ~26KB char-ladder).
 * Included from backend_call_dispatch.from_x.c. PLATFORM: SHARED.
 */
#include <stddef.h>
#include <stdint.h>

typedef struct CallDispatchStdRedirectRow {
  const char *from;
  int32_t from_len;
  const char *to;
  int32_t to_len;
} CallDispatchStdRedirectRow;

static int32_t call_dispatch_std_redirect_lookup(
    const CallDispatchStdRedirectRow *rows, int32_t nrows,
    const uint8_t *name, int32_t nlen, uint8_t *out, int32_t cap) {
  int32_t i, j;
  if (!name || nlen <= 0 || !out || cap <= 0) return 0;
  for (i = 0; i < nrows; i++) {
    if (rows[i].from_len != nlen) continue;
    for (j = 0; j < nlen; j++) {
      if ((uint8_t)rows[i].from[j] != name[j]) break;
    }
    if (j != nlen) continue;
    if (rows[i].to_len + 1 > cap) return 0;
    for (j = 0; j < rows[i].to_len; j++) out[j] = (uint8_t)rows[i].to[j];
    return rows[i].to_len;
  }
  return 0;
}

static const CallDispatchStdRedirectRow call_dispatch_std_heap_redirect_rows[] = {
  { "alloc", 5, "heap_alloc_c", 12 },
  { "alloc_i32", 9, "heap_alloc_i32_c", 16 },
  { "alloc_i32_ret_i32_ptr", 21, "heap_alloc_i32_c", 16 },
  { "alloc_i32_ret_u8_ptr", 20, "heap_alloc_u8_c", 15 },
  { "alloc_i32_ret_u64_ptr", 21, "heap_alloc_u64_c", 16 },
  { "alloc_i32_ret_f64_ptr", 21, "heap_alloc_f64_c", 16 },
  { "alloc_i32_ret_f32_ptr", 21, "heap_alloc_f32_c", 16 },
  { "realloc_i32", 11, "heap_realloc_i32_c", 18 },
  { "realloc_i32_ret_i32_ptr", 23, "heap_realloc_i32_c", 18 },
  { "realloc_u64_ret_u64_ptr", 23, "heap_realloc_u64_c", 18 },
  { "realloc_f64_ret_f64_ptr", 23, "heap_realloc_f64_c", 18 },
  { "realloc_f32_ret_f32_ptr", 23, "heap_realloc_f32_c", 18 },
  { "realloc_u8_ret_u8_ptr", 21, "heap_realloc_u8_c", 17 },
  { "free_i32", 8, "heap_free_i32_c", 15 },
  { "free_i32_ptr", 12, "heap_free_i32_c", 15 },
  { "free_u64_ptr", 12, "heap_free_u64_c", 15 },
  { "free_f64_ptr", 12, "heap_free_f64_c", 15 },
  { "free_f32_ptr", 12, "heap_free_f32_c", 15 },
  { "alloc_u8", 8, "heap_alloc_u8_c", 15 },
  { "realloc_u8", 10, "heap_realloc_u8_c", 17 },
  { "free_u8", 7, "heap_free_u8_c", 14 },
  { "alloc_f32", 9, "heap_alloc_f32_c", 16 },
  { "realloc_f32", 11, "heap_realloc_f32_c", 18 },
  { "free_f32", 8, "heap_free_f32_c", 15 },
  { "copy_i32_at", 11, "heap_copy_i32_at_c", 18 },
  { "copy_u8_at", 10, "heap_copy_u8_at_c", 17 },
  { "copy_f32_at", 11, "heap_copy_f32_at_c", 18 },
  { "copy_u64_at", 11, "heap_copy_u64_at_c", 18 },
  { "copy_f64_at", 11, "heap_copy_f64_at_c", 18 },
  { "copy_i32_ptr_i32_i32_ptr_i32", 28, "heap_copy_i32_at_c", 18 },
  { "copy_u8_ptr_i32_u8_ptr_i32", 26, "heap_copy_u8_at_c", 17 },
  { "copy_f32_ptr_i32_f32_ptr_i32", 28, "heap_copy_f32_at_c", 18 },
  { "copy_u64_ptr_i32_u64_ptr_i32", 28, "heap_copy_u64_at_c", 18 },
  { "copy_f64_ptr_i32_f64_ptr_i32", 28, "heap_copy_f64_at_c", 18 },
  { "arena64_init", 12, "heap_arena64_init_c", 19 },
  { "arena64_alloc", 13, "heap_arena64_alloc_c", 20 },
  { "arena64_deinit", 14, "heap_arena64_deinit_c", 21 },
  { "ptr_mod", 7, "heap_ptr_mod_c", 14 },
};
static const int32_t call_dispatch_std_heap_redirect_nrows =
    (int32_t)(sizeof(call_dispatch_std_heap_redirect_rows) /
              sizeof(call_dispatch_std_heap_redirect_rows[0]));

/* The public name lives in backend_call_dispatch_thin.x and forwards here.
 * This body must be the table. Calling the public name back recurses:
 * wrapper -> impl -> wrapper, and hello dies in glue_try_std_heap_redirect_sym_local.
 * PLATFORM: SHARED. */
int32_t glue_try_std_heap_redirect_sym_local_impl(const uint8_t *name, int32_t nlen,
                                                 uint8_t *out, int32_t cap) {
  return call_dispatch_std_redirect_lookup(
      call_dispatch_std_heap_redirect_rows, call_dispatch_std_heap_redirect_nrows,
      name, nlen, out, cap);
}

