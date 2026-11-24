/* Source-faithful glue_asm_fill_c_prefix_from_module_import twin
 * (compiler/src/asm/backend_call_dispatch.x HEAD 9018dea9f export at
 * lines 702-718; dirty tree must not be used as typool authority).
 * s170 hello-build residual: typool T 0x14040b7ac (only T; no _impl on
 * the s170 no-ASLR face) was called from the landed
 * w1521_emit_method_body thin ([rsp]=0x14000bb17). typool compiled
 * `while (pre_len < 128) { if (pre[pre_len] == 0) { break; } pre_len =
 * pre_len + 1; }` as a jump back to the loop head on a NUL without
 * incrementing pre_len (typool break-as-jmp-to-head). Live samples
 * stayed around 0x14040b8c7 with the same rsp/rbp for 180s and wrote no
 * hello output. typool also lowered `let path_bytes: u8[128] = [];`
 * with a shallow lea; this twin uses memset for that =[] slot. Same
 * typool break-as-jmp-to-head family as
 * glue_asm_overload_param_sig_count_c (s167) and
 * glue_codegen_import_path_to_c_prefix_into. This is not a fold of
 * typool w1521_body, sret_wrap, pipeline_asm_cmp_enum_rhs_tag_c, or
 * kind_ord_at. docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

void parser_get_module_import_path(uint8_t *module, int32_t idx, uint8_t *path_buf);
void glue_codegen_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap);

int32_t glue_asm_fill_c_prefix_from_module_import(uint8_t *mod, int32_t ix, uint8_t *pre) {
  uint8_t path_bytes[128];
  int32_t pre_len;

  if (mod == 0) { return 0 - 1; }
  if (pre == 0) { return 0 - 1; }
  memset(path_bytes, 0, sizeof(path_bytes));
  parser_get_module_import_path(mod, ix, &path_bytes[0]);
  if (path_bytes[0] == 0) { return 0 - 1; }
  glue_codegen_import_path_to_c_prefix_into(&path_bytes[0], pre, 128);
  pre_len = 0;
  while (pre_len < 128) {
    if (pre[pre_len] == 0) { break; }
    pre_len = pre_len + 1;
  }
  if (pre_len > 0) { return pre_len; }
  return 0 - 1;
}
