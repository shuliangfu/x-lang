/* Host-gcc twin of glue_asm_emit_string_lit_ptr_rax_elf_c
 * (backend_call_dispatch.x). typool first-wins T 0x14040f6d8 typool of
 * `let copied: i32 = 0` / `let cur: i32 = str_expr_ref` never stored
 * those inits into the slots later read as [rbp-0x1040] / [rbp-0x1048]
 * (adjacent to typool u8[4096] sbuf + typool u8[256] chunk). typool-rebuild
 * of runtime_asm_io_stubs.x CG002 in rais_json_emit_val (func 68/121):
 * CALL expr 1271 rais_puts, STRING_LIT arg 1272. typool rec dispatched
 * kind 59 into this typool face; slen=4, garbage copied (1856164000),
 * the copy loop was skipped, and `copied != slen` returned -1 before
 * already-folded glue_asm_emit_jmp_skip_string_then_lea. This C keeps
 * real 4096/256-byte slots and initializes copied/cur. Do not idx8 the
 * documentation .x twin. */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t glue_asm_string_lit_len(uint8_t *arena, int32_t er);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t ref, uint8_t *out);
extern int32_t pipeline_expr_var_name_len_for_string_lit_c(uint8_t *arena, int32_t er);
extern int32_t pipeline_expr_int_val_at(uint8_t *arena, int32_t er);
extern int32_t glue_asm_emit_jmp_skip_string_then_lea(
    uint8_t *ctx_bytes, int32_t ta, int32_t reg_k, uint8_t *sbuf, int32_t slen);

int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t str_expr_ref, int32_t ta) {
  int32_t slen, copied, cur, n, i;
  uint8_t sbuf[4096];
  uint8_t chunk[256];

  if (arena == 0)
    return -1;
  if (elf_ctx == 0)
    return -1;
  if (str_expr_ref <= 0)
    return -1;
  if (ta != 0) {
    if (ta != 1)
      return -1;
  }
  if (pipeline_expr_kind_ord_at(arena, str_expr_ref) != 59)
    return -1;
  slen = glue_asm_string_lit_len(arena, str_expr_ref);
  if (slen < 0)
    return -1;
  if (slen > 4095)
    return -1;
  for (i = 0; i < 4096; i++)
    sbuf[i] = 0;
  copied = 0;
  cur = str_expr_ref;
  while (copied < slen && cur > 0) {
    for (i = 0; i < 256; i++)
      chunk[i] = 0;
    pipeline_expr_var_name_into(arena, cur, &chunk[0]);
    if (cur == str_expr_ref) {
      n = slen;
      if (n > 127)
        n = 127;
    } else {
      n = pipeline_expr_var_name_len_for_string_lit_c(arena, cur);
    }
    if (n < 0)
      n = 0;
    if (n > slen - copied)
      n = slen - copied;
    for (i = 0; i < n; i++)
      sbuf[copied + i] = chunk[i];
    copied = copied + n;
    cur = pipeline_expr_int_val_at(arena, cur);
  }
  if (copied != slen)
    return -1;
  return glue_asm_emit_jmp_skip_string_then_lea(elf_ctx, ta, 1, &sbuf[0], slen);
}
