/*
 * Host-gcc twin of glue_asm_try_emit_fmt_string_lit_import_call_elf_c
 * (export + body; language in compiler/src/asm/backend_call_dispatch.x).
 *
 * Root (s52 unofficial hello build 139 after funcs=1, execute-at-0):
 * typool try_emit_import_method (unnamed typool .wcfg1 0x14a3acb98) calls
 * typool .wcfg1 fmt_string wrapper 0x14a3962b4, which calls typool body
 * 0x14a3966c4 (frame 0x1b18, typool of glue_asm_try_emit_fmt_string_lit
 * import_call body). typool of `let sbuf: u8[4096] = []` (and a second
 * typool u8[256] at -0x40) unrolls 256 stores from shallow lea -0x30(%rbp)
 * (dest rbx = rbp-0x30). Hardware watch: typool 0x14a3966c4 saved rbp at
 * [rbp+0] zeroed at typool writer RIP 0x14a396992..0x14a3969a4; first
 * retaddr-byte store at typool writer RIP 0x14a3969c2 writes 0 onto
 * typool 0x14a3966c4 [rbp+8] (saved ret 0x14a3964a8, typool wrapper
 * after the typool body call). Later typool stores at off 0x39.. zero
 * the rest of the retaddr and ~0xC0 bytes past CONTEXT.Rsp, matching
 * the first-chance dump (ER 0xC0000005, info0=8, info1=0, Rip=0).
 *
 * typool first-wins named export 0x1404031e4 has the same typool smash
 * (lea -0x30, unroll 256). typool try_emit calls typool 0x14a3962b4 /
 * typool 0x14a3966c4 by VA, so pe_fold by name alone misses the live
 * typool .wcfg1 faces — JMP those VAs onto this thin as well.
 *
 * Class: typool u8[N] shallow-lea smash.
 * Fold allowlist: glue_asm_try_emit_fmt_string_lit_import_call_elf_c
 * plus JMP typool 0x14a3962b4 and typool 0x14a3966c4 by VA.
 * Do not fold typool try_emit, typool bind_eq, typool pend BSS, typool
 * mid_ret, typool fmt_any, or typool w1545_pend_rcx_emit.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_method_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_method_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t index);
int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t index);
int32_t glue_asm_string_lit_len(uint8_t *arena, int32_t er);
void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_var_name_len_for_string_lit_c(uint8_t *arena, int32_t expr_ref);
int32_t pipeline_expr_int_val_at(uint8_t *arena, int32_t expr_ref);
int32_t glue_asm_build_import_binding_call_sym(uint8_t *pre, int32_t plen,
                                              uint8_t *field, int32_t flen,
                                              uint8_t *out);
int32_t glue_asm_emit_jmp_skip_string_then_lea(uint8_t *ctx_bytes, int32_t ta,
                                              int32_t reg_k, uint8_t *sbuf,
                                              int32_t slen);
int32_t backend_enc_mov_imm32_to_rbx_arch(uint8_t *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_mov_imm32_to_w0_arch(uint8_t *elf_ctx, int32_t imm, int32_t ta);
int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t *elf_ctx, int32_t arg_k, int32_t ta);
int32_t glue_asm_enc_call_redirected(uint8_t *elf_ctx, uint8_t *name,
                                     int32_t name_len, int32_t ta);

static int32_t prefix_is_fmt_or_debug(const uint8_t *pre, int32_t pre_len) {
  if (pre == 0) {
    return 0;
  }
  if (pre_len >= 8) {
    if (pre[0] == 115 && pre[1] == 116 && pre[2] == 100 && pre[3] == 95 &&
        pre[4] == 102 && pre[5] == 109 && pre[6] == 116 && pre[7] == 95) {
      return 1;
    }
  }
  if (pre_len >= 10) {
    if (pre[0] == 115 && pre[1] == 116 && pre[2] == 100 && pre[3] == 95 &&
        pre[4] == 100 && pre[5] == 101 && pre[6] == 98 && pre[7] == 117 &&
        pre[8] == 103 && pre[9] == 95) {
      return 1;
    }
  }
  return 0;
}

static int32_t is_fmt_print_field(const uint8_t *pre_buf, int32_t pre_len,
                                  const uint8_t *field_name, int32_t field_len) {
  if (pre_buf == 0 || field_name == 0) {
    return 0;
  }
  if (prefix_is_fmt_or_debug(pre_buf, pre_len) == 0) {
    return 0;
  }
  if (field_len == 7) {
    if (field_name[0] == 112 && field_name[1] == 114 && field_name[2] == 105 &&
        field_name[3] == 110 && field_name[4] == 116 && field_name[5] == 108 &&
        field_name[6] == 110) {
      return 1;
    }
    return 0;
  }
  if (field_len == 5) {
    if (field_name[0] == 112 && field_name[1] == 114 && field_name[2] == 105 &&
        field_name[3] == 110 && field_name[4] == 116) {
      return 1;
    }
    return 0;
  }
  return 0;
}

static int32_t glue_asm_try_emit_fmt_string_lit_import_call_body(
    uint8_t *arena, uint8_t *elf_ctx, int32_t call_expr_ref, uint8_t *ctx,
    int32_t ta, uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name,
    int32_t field_len) {
  int32_t expr_ko;
  int32_t nargs;
  int32_t arg_ref;
  int32_t slen;
  uint8_t sbuf[4096];
  int32_t copied;
  int32_t cur;
  uint8_t chunk[256];
  int32_t n;
  int32_t i;
  uint8_t sym_flat[256];
  int32_t sym_len;
  int32_t is_ln;

  if (arena == 0) {
    return 0;
  }
  if (elf_ctx == 0) {
    return 0;
  }
  if (ctx == 0) {
    return 0;
  }
  if (call_expr_ref <= 0) {
    return 0;
  }
  if (ta != 0) {
    if (ta != 1) {
      return 0;
    }
  }
  if (prefix_is_fmt_or_debug(pre_buf, pre_len) == 0) {
    return 0;
  }
  is_ln = 0;
  if (field_len == 7) {
    if (field_name[0] == 112 && field_name[1] == 114 && field_name[2] == 105 &&
        field_name[3] == 110 && field_name[4] == 116 && field_name[5] == 108 &&
        field_name[6] == 110) {
      is_ln = 1;
    } else {
      return 0;
    }
  } else if (field_len == 5) {
    if (field_name[0] == 112 && field_name[1] == 114 && field_name[2] == 105 &&
        field_name[3] == 110 && field_name[4] == 116) {
      is_ln = 0;
    } else {
      return 0;
    }
  } else {
    return 0;
  }

  expr_ko = pipeline_expr_kind_ord_at(arena, call_expr_ref);
  nargs = 0;
  arg_ref = 0;
  if (expr_ko == 49) {
    nargs = pipeline_expr_method_call_num_args_at(arena, call_expr_ref);
    if (nargs == 1) {
      arg_ref = pipeline_expr_method_call_arg_ref(arena, call_expr_ref, 0);
    }
  } else {
    nargs = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    if (nargs == 1) {
      arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, 0);
    }
  }
  if (nargs != 1) {
    return 0;
  }
  if (arg_ref <= 0) {
    return 0;
  }
  if (pipeline_expr_kind_ord_at(arena, arg_ref) != 59) {
    return 0;
  }
  slen = glue_asm_string_lit_len(arena, arg_ref);
  if (slen < 0) {
    return 0 - 1;
  }
  if (slen > 4095) {
    return 0 - 1;
  }
  memset(sbuf, 0, sizeof(sbuf));
  copied = 0;
  cur = arg_ref;
  while (copied < slen && cur > 0) {
    memset(chunk, 0, sizeof(chunk));
    n = 0;
    i = 0;
    pipeline_expr_var_name_into(arena, cur, chunk);
    if (cur == arg_ref) {
      n = slen;
      if (n > 127) {
        n = 127;
      }
    } else {
      n = pipeline_expr_var_name_len_for_string_lit_c(arena, cur);
    }
    if (n < 0) {
      n = 0;
    }
    if (n > slen - copied) {
      n = slen - copied;
    }
    while (i < n) {
      sbuf[copied + i] = chunk[i];
      i = i + 1;
    }
    copied = copied + n;
    cur = pipeline_expr_int_val_at(arena, cur);
  }
  if (copied != slen) {
    return 0 - 1;
  }
  memset(sym_flat, 0, sizeof(sym_flat));
  sym_len = glue_asm_build_import_binding_call_sym(pre_buf, pre_len, field_name,
                                                   field_len, sym_flat);
  if (sym_len <= 0) {
    return 0 - 1;
  }
  (void)is_ln;
  if (glue_asm_emit_jmp_skip_string_then_lea(elf_ctx, ta, 0, sbuf, slen) != 0) {
    return 0 - 1;
  }
  if (ta == 1) {
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, slen, ta) != 0) {
      return 0 - 1;
    }
  } else {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, slen, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0) {
      return 0 - 1;
    }
  }
  if (glue_asm_enc_call_redirected(elf_ctx, sym_flat, sym_len, ta) != 0) {
    return 0 - 1;
  }
  return 1;
}

int32_t glue_asm_try_emit_fmt_string_lit_import_call_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t call_expr_ref, uint8_t *ctx,
    int32_t ta, uint8_t *pre_buf, int32_t pre_len, uint8_t *field_name,
    int32_t field_len) {
  if (arena == 0) {
    return 0;
  }
  if (elf_ctx == 0) {
    return 0;
  }
  if (ctx == 0) {
    return 0;
  }
  if (call_expr_ref <= 0) {
    return 0;
  }
  if (ta != 0) {
    if (ta != 1) {
      return 0;
    }
  }
  if (is_fmt_print_field(pre_buf, pre_len, field_name, field_len) == 0) {
    return 0;
  }
  return glue_asm_try_emit_fmt_string_lit_import_call_body(
      arena, elf_ctx, call_expr_ref, ctx, ta, pre_buf, pre_len, field_name,
      field_len);
}
