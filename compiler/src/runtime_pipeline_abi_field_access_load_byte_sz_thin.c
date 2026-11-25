/*
 * Host-gcc twin of pipeline_expr_field_access_load_byte_sz.
 * Root (s45 SI build 139 after funcs=1): typool first-wins T at 0x14006845c
 *   (frame 0xd08, typool u8[256] field_name; typool W 0x1401b1e38 already JMP T)
 *   is entered from pipeline_asm_emit_var_field_access_elf_c (low gcc) while
 *   emitting `res.value` (expr 24, EK_FIELD). typool smashes its saved rbp
 *   and return address (expr_ref slot at -0x20 starts as 24 then is read as 0
 *   on the resolved_type_ref path). The typool default-8 epilogue then
 *   `pop rbp; ret` with both slots zero: first-chance DEP execute at RIP=0
 *   (ExceptionInformation[0]=8), RBP=0, RAX=8, RSP restored to the caller
 *   frame. That RIP=0 is the typool epilogue, not post-SEH unwind.
 * Class: typool u8[N] scale-8 / typool shallow lea + memset of u8[256].
 * Fold allowlist: pipeline_expr_field_access_load_byte_sz only (T and W).
 * Do not fold typool pend BSS or typool cousins.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_expr_field_access_base_ref(uint8_t *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_name_len(uint8_t *a, int32_t expr_ref);
void pipeline_expr_field_access_name_into(uint8_t *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_resolved_type_ref(uint8_t *a, int32_t expr_ref);
int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t type_ref);
int32_t pipeline_type_elem_ref_at(uint8_t *arena, int32_t type_ref);
int32_t glue_field_access_load_bytes_for_type_ref(uint8_t *a, int32_t ty_ref);
int32_t field_load_sz_layout_match(uint8_t *a, uint8_t *m, int32_t base_tr,
                                   uint8_t *field_name, int32_t flen);

static int32_t lbsz_bytes_eq(const uint8_t *a, const uint8_t *b, int32_t n) {
  int32_t i;
  if (n <= 0) {
    return 1;
  }
  if (a == 0 || b == 0) {
    return 0;
  }
  i = 0;
  while (i < n) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

int32_t pipeline_expr_field_access_load_byte_sz(uint8_t *a, uint8_t *m, int32_t expr_ref) {
  int32_t tr;
  int32_t base_tr;
  int32_t base_ref;
  int32_t flen;
  uint8_t field_name[256];
  int32_t kind_ord;
  const uint8_t nm_is_some[7] = {105, 115, 95, 115, 111, 109, 101};
  const uint8_t nm_is_none[7] = {105, 115, 95, 110, 111, 110, 101};
  int32_t hit;
  int32_t elem_tr_lbs;

  if (a == 0 || expr_ref <= 0) {
    return 8;
  }
  base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
  flen = pipeline_expr_field_access_name_len(a, expr_ref);
  if (base_ref <= 0 || flen <= 0 || flen > 255) {
    return 8;
  }
  memset(field_name, 0, sizeof(field_name));
  pipeline_expr_field_access_name_into(a, expr_ref, field_name);

  tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, tr);
    if (kind_ord == 8) {
      hit = glue_field_access_load_bytes_for_type_ref(a, tr);
      if (hit == 1 || hit == 2 || hit == 4) {
        return hit;
      }
    } else if (kind_ord != 10 && kind_ord != 11 && kind_ord != 12) {
      return glue_field_access_load_bytes_for_type_ref(a, tr);
    }
  }

  base_tr = pipeline_expr_resolved_type_ref(a, base_ref);
  if (base_tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, base_tr);
    if (kind_ord == 9) {
      elem_tr_lbs = pipeline_type_elem_ref_at(a, base_tr);
      if (elem_tr_lbs > 0) {
        base_tr = elem_tr_lbs;
        kind_ord = pipeline_type_kind_ord_at(a, base_tr);
      }
    }
    if (kind_ord == 8) {
      hit = field_load_sz_layout_match(a, m, base_tr, field_name, flen);
      if (hit != 0) {
        return hit;
      }
    }
  }

  if (flen == 7 && lbsz_bytes_eq(field_name, nm_is_some, 7) != 0) {
    return 1;
  }
  if (flen == 7 && lbsz_bytes_eq(field_name, nm_is_none, 7) != 0) {
    return 1;
  }
  return 8;
}
