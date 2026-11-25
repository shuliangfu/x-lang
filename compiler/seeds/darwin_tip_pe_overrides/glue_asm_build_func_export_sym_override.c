/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only — tip_l4_tip_pe_cg002_asm_codegen.
 *
 * Tip PE selfhost-emitted glue_asm_build_func_export_sym_c (backend_call_dispatch.o)
 * drops the non-bare else that calls glue_asm_build_dep_export_sym_c (and the bare
 * copy loop omits pos++/cj++). Cap retains both. For entry `function main` ,
 * bare_nomangle returns 0 → tip leaves pos=0 → returns -1 → mega_body +872 →
 * CG002 → tip_after.o 0B / no `_main`. Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin Cap-aligned with src/asm/backend_call_dispatch.x.
 * g05_relink_env prepends this .o and weakens the broken tip T so the twin wins.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_asm_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t glue_asm_func_link_is_bare_nomangle_c(void *m, int32_t func_ix);
extern int32_t glue_asm_build_dep_export_sym_c(uint8_t *name, int32_t name_len, uint8_t *out,
                                              int32_t out_cap);
extern int32_t glue_module_func_overload_count_c(void *m, uint8_t *name, int32_t nlen);
extern int32_t glue_asm_std_c_wrapper_fname_needs_export_c_suffix(uint8_t *fname, int32_t fname_len);
extern int32_t glue_asm_append_export_c_suffix(uint8_t *out, int32_t pos, int32_t out_cap);
extern int32_t pipeline_module_func_num_params_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_at(void *m, int32_t fi, int32_t pi);
extern int32_t glue_asm_type_ref_to_suffix_c(void *a, int32_t ty, uint8_t *suf, int32_t cap);
extern int32_t glue_asm_overload_param_sig_count_c(void *a, void *m, int32_t func_ix);
extern int32_t pipeline_module_func_return_type_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_owner_copy(void *m, int32_t fi, uint8_t *dst, int32_t cap);

int32_t glue_asm_build_func_export_sym_c(void *m, void *a, int32_t func_ix, uint8_t *out,
                                        int32_t out_cap) {
  int32_t fname_len;
  uint8_t fname[256];
  int32_t bare_nomangle;
  int32_t pos;
  int32_t cj;
  int32_t np;
  int32_t pi;
  int32_t pty;
  uint8_t suf[64];
  int32_t sl;
  int32_t si;
  int32_t sig_count;
  int32_t ret_ref;
  uint8_t rsuf[64];
  int32_t rsl;
  int32_t ri;
  uint8_t own[64];
  int32_t olen;
  int32_t oi;

  if (!m || !a || func_ix < 0 || !out || out_cap <= 0)
    return -1;
  fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
  if (fname_len <= 0 || fname_len > 255)
    return -1;
  memset(fname, 0, sizeof fname);
  pipeline_asm_module_func_name_copy64(m, func_ix, fname);

  bare_nomangle = glue_asm_func_link_is_bare_nomangle_c(m, func_ix);
  pos = 0;
  if (bare_nomangle != 0) {
    cj = 0;
    while (cj < fname_len) {
      if (pos >= out_cap - 1)
        break;
      out[pos] = fname[cj];
      pos = pos + 1;
      cj = cj + 1;
    }
  } else {
    /* Cap-aligned else tip selfhost dropped — entry main lands here. */
    pos = glue_asm_build_dep_export_sym_c(fname, fname_len, out, out_cap);
  }
  if (pos <= 0)
    return -1;

  if (glue_module_func_overload_count_c(m, fname, fname_len) <= 1) {
    if (glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname, fname_len) != 0)
      pos = glue_asm_append_export_c_suffix(out, pos, out_cap);
    if (pos > 0)
      return pos;
    return -1;
  }

  np = pipeline_module_func_num_params_at(m, func_ix);
  pi = 0;
  while (pi < np) {
    if (pos >= out_cap - 2)
      break;
    pty = pipeline_module_func_param_type_ref_at(m, func_ix, pi);
    if (pty > 0) {
      memset(suf, 0, sizeof suf);
      sl = glue_asm_type_ref_to_suffix_c(a, pty, suf, 64);
      if (sl <= 0) {
        pi = pi + 1;
        continue;
      }
      if (pos >= out_cap - 1)
        break;
      out[pos] = 95;
      pos = pos + 1;
      if (pos + sl >= out_cap)
        return -1;
      si = 0;
      while (si < sl) {
        out[pos] = suf[si];
        pos = pos + 1;
        si = si + 1;
      }
    }
    pi = pi + 1;
  }

  sig_count = glue_asm_overload_param_sig_count_c(a, m, func_ix);
  if (sig_count > 1) {
    ret_ref = pipeline_module_func_return_type_at(m, func_ix);
    memset(rsuf, 0, sizeof rsuf);
    rsl = glue_asm_type_ref_to_suffix_c(a, ret_ref, rsuf, 64);
    if (rsl > 0) {
      if (pos + 4 + rsl >= out_cap)
        return -1;
      out[pos] = 95;
      out[pos + 1] = 114;
      out[pos + 2] = 101;
      out[pos + 3] = 116;
      pos = pos + 4;
      ri = 0;
      while (ri < rsl) {
        out[pos] = rsuf[ri];
        pos = pos + 1;
        ri = ri + 1;
      }
    }
  }

  if (glue_asm_std_c_wrapper_fname_needs_export_c_suffix(fname, fname_len) != 0)
    pos = glue_asm_append_export_c_suffix(out, pos, out_cap);

  memset(own, 0, sizeof own);
  olen = pipeline_module_func_owner_copy(m, func_ix, own, 63);
  if (olen > 0) {
    if (pos + 1 + olen >= out_cap)
      return -1;
    out[pos] = 95;
    pos = pos + 1;
    oi = 0;
    while (oi < olen) {
      out[pos] = own[oi];
      pos = pos + 1;
      oi = oi + 1;
    }
  }
  if (pos > 0)
    return pos;
  return -1;
}
