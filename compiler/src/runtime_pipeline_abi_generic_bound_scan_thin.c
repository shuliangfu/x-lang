/* Host-gcc twin of typool parser_asm_generic_bound_scan_into_c
 * (pthin_skip_tl.x). typool first-wins W (fromsrc_s100 0x1404bddbc)
 * typool-wrongs the outer `while (1) { kind = peek; if (kind ==
 * TOKEN_EOF) break; }` as `mov $1,%eax; test %eax,%eax; je exit`
 * (dead) and `if (kind == 0) jmp loop_head` at typool writer RIP
 * 0x1404be702. Live Win32 HW-BP on fromsrc_s100_noaslr check
 * examples/hello.x (repo cwd): FINISH_OK (parse already collected
 * main); then 900+ peek_kind returns from typool
 * parser_asm_generic_bound_scan_into_c+0x91d (ret typool 0x1404be6d9)
 * and typool step_kind from typool +0x2ad4, spinning at EOF (lexpos
 * 232) because the EOF break jumps back to the while-head typool
 * 0x1404be6b5. Same typool typool-wrong class as typool skip_ws /
 * typool skip_comment / typool normalize (break compiled as
 * jmp-to-head). Host-gcc twin keeps `if (kind == TOKEN_EOF) break`.
 * typool tip / typool body_into / typool lexer_next_impl wholesale /
 * typool skip_function / typool append_i32 / typool fputc /
 * typool try_keyword_c / typool rec are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_EOF = 0,
  TOKEN_FUNCTION = 1,
  TOKEN_FOR = 8,
  TOKEN_STRUCT = 19,
  TOKEN_ENUM = 47,
  TOKEN_IMPL = 50,
  TOKEN_EXTERN = 54,
  TOKEN_IDENT = 59,
  TOKEN_LPAREN = 82,
  TOKEN_RPAREN = 83,
  TOKEN_LBRACE = 84,
  TOKEN_RBRACE = 85,
  TOKEN_COMMA = 90,
  TOKEN_COLON = 91,
  TOKEN_DOT = 92,
  TOKEN_SEMICOLON = 95,
  TOKEN_PLUS = 96,
  TOKEN_ASSIGN = 117,
  TOKEN_LT = 120,
  TOKEN_GT = 121,
  FN_BOUND_MAX = 16,
  GENERIC_CALL_MAX = 32,
  GENERIC_CALL_MAX_ARGS = 4,
  FN_GP_MAX = 32,
  BOUND_NAME_CAP = 64
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern size_t parser_asm_lex_source_length_c(void *source);
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *data, int32_t slen,
    size_t ts, int32_t nlen, uint8_t *dst);
extern int32_t parser_asm_skip_tl_peek_impl_for_type(void *lex_inout, void *source,
    uint8_t *last_nm);
extern int32_t parser_asm_lex_line_c(void *lex_inout);
extern int32_t parser_asm_lex_col_c(void *lex_inout);

int32_t parser_asm_generic_bound_scan_into_c(
    uint8_t *lex_inout, uint8_t *source, uint8_t *last_nm,
    uint8_t *bound_name, int32_t *bound_name_len,
    uint8_t *bound_trait, int32_t *bound_trait_len,
    int32_t *bound_pos, int32_t *bound_n,
    uint8_t *call_callee, int32_t *call_callee_len,
    uint8_t *call_typearg, int32_t *call_typearg_len,
    uint8_t *call_typeargs, int32_t *call_typearg_lens,
    int32_t *call_nargs, int32_t *call_line, int32_t *call_col,
    int32_t *call_n,
    uint8_t *gp_fname, int32_t *gp_fname_len,
    uint8_t *gp_names, int32_t *gp_lens, int32_t *gp_nargs,
    int32_t *gp_n) {

  int32_t kind = 0;
  int32_t nk = 0;
  int32_t pl = 0;
  int32_t tl = 0;
  size_t ts = 0;
  uint8_t * data = 0;
  size_t slen_us = 0;
  int32_t slen = 0;
  int32_t zi = 0;
  int32_t last_nlen = 0;
  int32_t last_is_fn = 0;
  int32_t last_is_struct = 0;
  int32_t last_is_impl = 0;
  int32_t prev_function = 0;
  int32_t prev_struct = 0;
  int32_t prev_impl = 0;
  int32_t angle_depth = 0;
  int32_t expect_trait = 0;
  int32_t expect_tp = 0;
  int32_t after_bound = 0;
  int32_t pos = 0;
  int32_t gp_slot = 0;
  int32_t bn = 0;
  int32_t cn = 0;
  int32_t gn = 0;
  int32_t pi = 0;
  int32_t k = 0;
  int32_t arg_slot = 0;
  int32_t simple = 0;
  int32_t nargs = 0;
  int32_t expect_arg = 0;
  size_t slot_off = 0;
  uint8_t * row = 0;
  if (lex_inout == 0 || source == 0 || last_nm == 0 || bound_name == 0 || bound_name_len == 0 || bound_trait == 0 || bound_trait_len == 0 || bound_pos == 0 || bound_n == 0 || call_callee == 0 || call_callee_len == 0 || call_typearg == 0 || call_typearg_len == 0 || call_typeargs == 0 || call_typearg_lens == 0 || call_nargs == 0 || call_line == 0 || call_col == 0 || call_n == 0 || gp_fname == 0 || gp_fname_len == 0 || gp_names == 0 || gp_lens == 0 || gp_nargs == 0 || gp_n == 0) {
    return 0;
  }
  {
    bound_n[0] = 0;
    call_n[0] = 0;
    gp_n[0] = 0;
    last_nlen = 0;
    last_is_fn = 0;
    last_is_struct = 0;
    last_is_impl = 0;
    prev_function = 0;
    prev_struct = 0;
    prev_impl = 0;
    zi = 0;
    while (zi < BOUND_NAME_CAP) {
      last_nm[zi] = 0;
      zi = zi + 1;
    }
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    if (slen_us > 2147483647) {
      slen = 2147483647;
    } else {
      slen = slen_us;
    }
    while (1) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_EOF) {
        break;
      }
      if (kind == TOKEN_FUNCTION) {
        prev_function = 1;
        prev_struct = 0;
        prev_impl = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_STRUCT) {
        prev_struct = 1;
        prev_function = 0;
        prev_impl = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_IMPL) {
        prev_impl = 1;
        prev_function = 0;
        prev_struct = 0;
        last_nlen = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_IDENT) {
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl > 63) {
          pl = 63;
        }
        last_nlen = pl;
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        zi = 0;
        while (zi < BOUND_NAME_CAP) {
          last_nm[zi] = 0;
          zi = zi + 1;
        }
        if (pl > 0 && data != 0) {
          parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, last_nm);
        }
        last_is_fn = prev_function;
        last_is_struct = prev_struct;
        last_is_impl = prev_impl;
        prev_function = 0;
        prev_struct = 0;
        prev_impl = 0;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_LT && (last_nlen > 0 || prev_impl != 0)) {
        if (prev_impl != 0 && last_nlen == 0) {
          pl = parser_asm_skip_tl_peek_impl_for_type(lex_inout, source, last_nm);
          if (pl > 0) {
            last_nlen = pl;
            last_is_impl = 1;
          }
          prev_impl = 0;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (last_nlen > 0 && (last_is_fn != 0 || last_is_struct != 0 || last_is_impl != 0)) {
          angle_depth = 1;
          expect_trait = 0;
          expect_tp = 1;
          after_bound = 0;
          pos = 0;
          gp_slot = -1;
          gn = gp_n[0];
          if (gn < FN_GP_MAX) {
            gp_slot = gn;
            slot_off = (gn) * (BOUND_NAME_CAP);
            zi = 0;
            while (zi < BOUND_NAME_CAP) {
              gp_fname[slot_off + zi] = 0;
              zi = zi + 1;
            }
            zi = 0;
            while (zi < last_nlen) {
              gp_fname[slot_off + zi] = last_nm[zi];
              zi = zi + 1;
            }
            gp_fname_len[gn] = last_nlen;
            gp_nargs[gn] = 0;
            k = 0;
            while (k < GENERIC_CALL_MAX_ARGS) {
              gp_lens[(gn) * (GENERIC_CALL_MAX_ARGS) + k] = 0;
              k = k + 1;
            }
            gp_n[0] = gn + 1;
          }
          while (angle_depth > 0) {
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_EOF) {
              break;
            }
            if (kind == TOKEN_LT) {
              angle_depth = angle_depth + 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_GT) {
              angle_depth = angle_depth - 1;
              if (angle_depth == 0) {
                break;
              }
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COLON && angle_depth == 1) {
              expect_trait = 1;
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_PLUS && angle_depth == 1 && after_bound != 0) {
              expect_trait = 1;
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_trait != 0) {
              bn = bound_n[0];
              if (bn < FN_BOUND_MAX) {
                slot_off = (bn) * (BOUND_NAME_CAP);
                // Split clears: tip emitter can leave rbx holding store1's
                // address across a same-index dual store (P12g BM4 family),
                // so bound_trait[slot+zi]=0 wrote base+addr → SEGV. One
                // store per loop forces zi reload. PLATFORM: SHARED.
                zi = 0;
                while (zi < BOUND_NAME_CAP) {
                  bound_name[slot_off + zi] = 0;
                  zi = zi + 1;
                }
                zi = 0;
                while (zi < BOUND_NAME_CAP) {
                  bound_trait[slot_off + zi] = 0;
                  zi = zi + 1;
                }
                zi = 0;
                while (zi < last_nlen) {
                  bound_name[slot_off + zi] = last_nm[zi];
                  zi = zi + 1;
                }
                bound_name_len[bn] = last_nlen;
                tl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
                if (tl > 63) {
                  tl = 63;
                }
                ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
                if (ts == 0) {
                  ts = parser_asm_lex_pos_c(lex_inout);
                }
                if (tl > 0 && data != 0) {
                  parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, tl, bound_trait + slot_off);
                }
                bound_trait_len[bn] = tl;
                bound_pos[bn] = pos;
                bound_n[0] = bn + 1;
              }
              expect_trait = 0;
              after_bound = 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_tp != 0 && expect_trait == 0) {
              if (gp_slot >= 0 && gp_nargs[gp_slot] < GENERIC_CALL_MAX_ARGS) {
                pi = gp_nargs[gp_slot];
                pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
                if (pl > 63) {
                  pl = 63;
                }
                ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
                if (ts == 0) {
                  ts = parser_asm_lex_pos_c(lex_inout);
                }
                // Same staged index as call_typeargs (wave660 family).
                // PLATFORM: SHARED.
                arg_slot = gp_slot;
                arg_slot = arg_slot * GENERIC_CALL_MAX_ARGS;
                arg_slot = arg_slot + pi;
                slot_off = (arg_slot) * (BOUND_NAME_CAP);
                zi = 0;
                while (zi < BOUND_NAME_CAP) {
                  gp_names[slot_off + zi] = 0;
                  zi = zi + 1;
                }
                if (pl > 0 && data != 0) {
                  parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, gp_names + slot_off);
                }
                gp_lens[arg_slot] = pl;
                gp_nargs[gp_slot] = pi + 1;
              }
              expect_tp = 0;
              after_bound = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COMMA && angle_depth == 1) {
              expect_trait = 0;
              expect_tp = 1;
              after_bound = 0;
              pos = pos + 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
          parser_asm_lex_step_kind_c(lex_inout, source);
        } else if (last_is_fn == 0 && last_nlen > 0 && call_n[0] < GENERIC_CALL_MAX) {
          cn = call_n[0];
          angle_depth = 1;
          simple = 1;
          nargs = 0;
          expect_arg = 1;
          k = 0;
          while (k < GENERIC_CALL_MAX_ARGS) {
            call_typearg_lens[(cn) * (GENERIC_CALL_MAX_ARGS) + k] = 0;
            k = k + 1;
          }
          while (angle_depth > 0) {
            kind = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (kind == TOKEN_EOF) {
              break;
            }
            if (kind == TOKEN_LT) {
              angle_depth = angle_depth + 1;
              simple = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_GT) {
              angle_depth = angle_depth - 1;
              if (angle_depth == 0) {
                break;
              }
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_IDENT && angle_depth == 1 && expect_arg != 0 && nargs < GENERIC_CALL_MAX_ARGS) {
              pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
              if (pl > 63) {
                pl = 63;
              }
              ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
              if (ts == 0) {
                ts = parser_asm_lex_pos_c(lex_inout);
              }
              // Stage (cn*MAX_ARGS)+nargs: tip commutative park can emit
              // (cn*MAX)+MAX for cast-wrapped nargs (wave660 / bound_method
              // T001 — lens/typeargs land at slot MAX). Linear temps force
              // left-first. PLATFORM: SHARED.
              arg_slot = cn;
              arg_slot = arg_slot * GENERIC_CALL_MAX_ARGS;
              arg_slot = arg_slot + nargs;
              slot_off = (arg_slot) * (BOUND_NAME_CAP);
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_typeargs[slot_off + zi] = 0;
                zi = zi + 1;
              }
              if (pl > 0 && data != 0) {
                parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, call_typeargs + slot_off);
              }
              call_typearg_lens[arg_slot] = pl;
              nargs = nargs + 1;
              expect_arg = 0;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (kind == TOKEN_COMMA && angle_depth == 1) {
              expect_arg = 1;
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
          if (nargs > 0 && simple != 0) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            nk = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (nk == TOKEN_LPAREN || nk == TOKEN_LBRACE || nk == TOKEN_ASSIGN || nk == TOKEN_SEMICOLON || nk == TOKEN_COMMA || nk == TOKEN_RPAREN) {
              slot_off = (cn) * (BOUND_NAME_CAP);
              // Same split as bound_name/bound_trait clear above.
              // PLATFORM: SHARED.
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_callee[slot_off + zi] = 0;
                zi = zi + 1;
              }
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_typearg[slot_off + zi] = 0;
                zi = zi + 1;
              }
              zi = 0;
              while (zi < last_nlen) {
                call_callee[slot_off + zi] = last_nm[zi];
                zi = zi + 1;
              }
              call_callee_len[cn] = last_nlen;
              row = call_typeargs + ((cn) * (GENERIC_CALL_MAX_ARGS) * (BOUND_NAME_CAP));
              zi = 0;
              while (zi < BOUND_NAME_CAP) {
                call_typearg[slot_off + zi] = row[zi];
                zi = zi + 1;
              }
              call_typearg_len[cn] = call_typearg_lens[(cn) * (GENERIC_CALL_MAX_ARGS)];
              call_nargs[cn] = nargs;
              call_line[cn] = parser_asm_lex_line_c(lex_inout);
              call_col[cn] = parser_asm_lex_col_c(lex_inout);
              call_n[0] = cn + 1;
            }
            parser_asm_lex_step_kind_c(lex_inout, source);
          } else {
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
        }
        last_nlen = 0;
        last_is_fn = 0;
        last_is_struct = 0;
        last_is_impl = 0;
        prev_function = 0;
        prev_struct = 0;
        prev_impl = 0;
        continue;
      }
      prev_function = 0;
      prev_struct = 0;
      prev_impl = 0;
      if (kind != TOKEN_DOT && kind != TOKEN_COLON) {
        last_nlen = 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}
