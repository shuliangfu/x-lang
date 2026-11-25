/* Source-faithful glue_asm_overload_param_sig_count_c twin
 * (compiler/src/asm/backend_call_dispatch.x HEAD at the export; dirty
 * tree must not be used as typool authority for this function).
 * s166 hello-build residual: uninstrumented compile_timeout=true in
 * 25.122s, no output file. first-chance / DEBUG_ONLY_THIS_PROCESS for
 * 40s saw no AV (not an SEH unwind). Suspended RIP snapshots from
 * t=1.088s through t=39.155s stayed in typool
 * glue_asm_overload_param_sig_count_c (T 0x140448318) around
 * +0xd59..+0xdb1 (0x140449071-0x1404490c9), same rbp 0x103f71a0,
 * rsp 0x103f6800/0x103f67f8/0x103f67f0. typool inner loop is source
 * `while (k < na) { if (sa[k] != sb[k]) { same = 0; break; } k = k + 1; }`.
 * typool compiled the mismatch `break` as `same=0; jmp 0x14044905e`
 * (the while-head: cmp k,na / setl / je exit) without incrementing k
 * (typool break-as-jmp-to-head). The equal path at 0x1404490df does
 * k++ then jmp 0x14044905e, so only a mismatch parks the loop. sa[k]
 * / sb[k] used scale-1 lea of the local u8[64] slots (not scale-8).
 * typool `if (na != nb) { same=0; break; }` correctly jmps to the
 * outer pi-loop at 0x140448bcf and is not the spinner. This is not
 * already-folded glue_module_func_index_by_name, glue_asm_build_call_export_sym_c,
 * glue_asm_build_dep_export_sym_c, for_call_args, or enc_* cousins.
 * Later arms in this same function are included only because they live
 * in the proven typool symbol, not as a batch fold of cousins.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_asm_module_func_name_len_at(uint8_t *m, int32_t func_ix);
void pipeline_asm_module_func_name_copy64(uint8_t *m, int32_t func_ix, uint8_t *out);
int32_t pipeline_module_func_num_params_at(uint8_t *m, int32_t func_ix);
int32_t pipeline_module_num_funcs(uint8_t *m);
int32_t pipeline_asm_module_func_is_extern_at(uint8_t *m, int32_t i);
int32_t pipeline_module_func_name_equal_at(uint8_t *m, int32_t i, uint8_t *name, int32_t len);
int32_t pipeline_module_func_param_type_ref_at(uint8_t *m, int32_t fi, int32_t pi);
int32_t glue_asm_type_ref_to_suffix_c(uint8_t *a, int32_t type_ref, uint8_t *out, int32_t out_cap);

int32_t glue_asm_overload_param_sig_count_c(uint8_t *a, uint8_t *m, int32_t func_ix) {
  int32_t fname_len;
  uint8_t fname[256];
  int32_t np0;
  int32_t c;
  int32_t nfunc;
  int32_t i;
  int32_t npi;
  int32_t same;
  int32_t pi;
  uint8_t sa[64];
  uint8_t sb[64];
  int32_t na;
  int32_t nb;
  int32_t k;

  if (a == 0) { return 0; }
  if (m == 0) { return 0; }
  if (func_ix < 0) { return 0; }
  fname_len = pipeline_asm_module_func_name_len_at(m, func_ix);
  if (fname_len <= 0) { return 0; }
  if (fname_len > 255) { return 0; }
  memset(fname, 0, sizeof(fname));
  pipeline_asm_module_func_name_copy64(m, func_ix, &fname[0]);
  np0 = pipeline_module_func_num_params_at(m, func_ix);
  c = 0;
  nfunc = pipeline_module_num_funcs(m);
  i = 0;
  while (i < nfunc) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0) {
      if (pipeline_module_func_name_equal_at(m, i, &fname[0], fname_len) != 0) {
        npi = pipeline_module_func_num_params_at(m, i);
        if (npi == np0) {
          same = 1;
          pi = 0;
          while (pi < np0) {
            memset(sa, 0, sizeof(sa));
            memset(sb, 0, sizeof(sb));
            na = glue_asm_type_ref_to_suffix_c(
              a, pipeline_module_func_param_type_ref_at(m, func_ix, pi), &sa[0], 64
            );
            nb = glue_asm_type_ref_to_suffix_c(
              a, pipeline_module_func_param_type_ref_at(m, i, pi), &sb[0], 64
            );
            if (na != nb) {
              same = 0;
              break;
            }
            k = 0;
            while (k < na) {
              if (sa[k] != sb[k]) {
                same = 0;
                break;
              }
              k = k + 1;
            }
            if (same == 0) { break; }
            pi = pi + 1;
          }
          if (same != 0) {
            c = c + 1;
          }
        }
      }
    }
    i = i + 1;
  }
  return c;
}
