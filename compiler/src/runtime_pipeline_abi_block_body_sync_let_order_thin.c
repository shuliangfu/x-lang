/*
 * Host-gcc twin of runtime_pipeline_abi_block_body_sync_let_order_thin.x.
 * Root (w1009/w1010): tip PREFER_ASM on PE produces large frames; more
 *   importantly mega_body same-TU REL32 keeps leftover body_sync even when
 *   this twin first-wins. g05 post-link win_patch_body_sync_jmp.py patches
 *   leftover entry to jmp here. Darwin/Linux keep the tip .x object.
 * G.7: same two-pass semantics as the .x thin (pass0 pure lets; pass1
 *   deferred at stmt_order k==1; k==2 emits RETURN).
 * Build: gcc -c -O2 → build_asm/selfhost_pabi/body_sync_let_order.o
 *   (Windows g05_relink_env first-wins after weaken egg pabi).
 * PLATFORM: WINDOWS — PE same-TU leftover bypass; LINUX/MACOS use .x tip object.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern void pipeline_asm_fill_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t asm_ctx_block_slot_get(void *ctx, int32_t block_ref);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t ei);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_for_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_block_let_name_len(void *arena, int32_t block_ref, int32_t li);
extern void pipeline_block_let_name_copy64(void *arena, int32_t block_ref, int32_t li, uint8_t *out);
extern int32_t glue_lazy_append_block_let_local(void *arena, void *ctx, int32_t block_ref, int32_t li,
                                               uint8_t *nm, int32_t nlen);
extern int32_t glue_block_body_emit_let_init(void *arena, void *elf_ctx, int32_t block_ref, int32_t idx,
                                             int32_t init_ref, int32_t slot, void *ctx, int32_t ta,
                                             uint8_t *lnb, int32_t llen);
extern void glue_block_compute_pass1_deferred_lets(void *arena, void *ctx, int32_t block_ref,
                                                   int32_t slot_base, int32_t nconst, int32_t nlet,
                                                   uint8_t *deferred);
extern int32_t ast_pipeline_block_const_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t backend_asm_ctx_slot_offset(void *ctx, int32_t slot_idx);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t backend_emit_while_loop_elf_sync(void *arena, void *elf_ctx, int32_t block_ref,
                                               int32_t wi, void *ctx, int32_t ta);
extern int32_t backend_emit_for_loop_elf_sync(void *arena, void *elf_ctx, int32_t block_ref, int32_t fi,
                                             void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_block_if_stmt_elf(void *arena, void *elf_ctx, int32_t cur_block,
                                                  int32_t if_idx, void *ctx, int32_t ta, int32_t stmt_i);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_region_with_arena_cap_ref(void *arena, int32_t block_ref, int32_t i);
extern void backend_ensure_block_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t glue_wa_scope_alloc_off_c(void *ctx);
extern void glue_wa_scope_push_c(int32_t wa_off);
extern void glue_wa_scope_pop_c(void);
extern int32_t glue_emit_with_arena_init_elf(void *arena, void *elf_ctx, void *ctx, int32_t wa_off,
                                            int32_t cap_ref, int32_t ta);
extern int32_t glue_emit_with_arena_deinit_elf(void *elf_ctx, int32_t wa_off, int32_t ta);
extern int32_t pipeline_block_num_labeled_stmts(void *arena, int32_t block_ref);
extern int32_t pipeline_block_labeled_is_goto(void *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_block_labeled_label_len(void *arena, int32_t block_ref, int32_t li);
extern void pipeline_block_labeled_label_copy32(void *arena, int32_t block_ref, int32_t li, uint8_t *dst);
extern int32_t pipeline_block_labeled_goto_target_len(void *arena, int32_t block_ref, int32_t li);
extern void pipeline_block_labeled_goto_target_copy32(void *arena, int32_t block_ref, int32_t li,
                                                     uint8_t *dst);
extern int32_t pipeline_block_labeled_return_expr_ref(void *arena, int32_t block_ref, int32_t li);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global,
                                     int32_t ta);
extern uint8_t *pipeline_asm_ctx_layout(void *ctx);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_module_func_return_type_at(void *module, int32_t func_index);
extern int32_t glue_float_promote_src_ty_ref_c(void *arena, int32_t expr_ref);
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(void *arena, void *elf_ctx, int32_t dest_ty,
                                                      int32_t src_ty, int32_t ta);
extern int32_t glue_index_scratch_spills_cleanup_all_elf_c(void *elf_ctx, int32_t ta);
extern int32_t glue_emit_block_final_expr_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx,
                                              int32_t ta);
extern void glue_block_body_bind_module_dep_from_ctx(void *ctx);
extern void glue_asm_block_diverged_set(int32_t v);
extern int32_t pipe_load_i32_le(uint8_t *base, int32_t off);

static uint8_t g_w1010_let_defer[512];
static uint8_t g_w1010_name_buf[256];
static uint8_t g_w1010_lnb[256];

/**
 * Emit one let init (pass0 pure or pass1 deferred).
 * @return 0 ok; -1 fail
 * PLATFORM: WINDOWS — host-gcc twin of w1009_emit_let.
 */
static int32_t w1010_emit_let(void *arena, void *elf_ctx, int32_t block_ref, int32_t idx,
                              int32_t slot_base, int32_t nconst, void *ctx, int32_t ta) {
  int32_t init_ref;
  int32_t slot;
  int32_t llen;
  int32_t rc;

  init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
  if (init_ref <= 0) {
    return 0;
  }
  slot = slot_base + nconst + idx;
  llen = pipeline_block_let_name_len(arena, block_ref, idx);
  rc = 0;
  if (llen > 0) {
    pipeline_block_let_name_copy64(arena, block_ref, idx, g_w1010_lnb);
    rc = glue_lazy_append_block_let_local(arena, ctx, block_ref, idx, g_w1010_lnb, llen);
  }
  if (rc != 0) {
    fprintf(stderr, "BS lazy_append fail idx=%d rc=%d\n", idx, rc);
    return -1;
  }
  fprintf(stderr, "BS emit_let idx=%d init=%d slot=%d\n", idx, init_ref, slot);
  rc = glue_block_body_emit_let_init(arena, elf_ctx, block_ref, idx, init_ref, slot, ctx, ta,
                                     g_w1010_lnb, llen);
  fprintf(stderr, "BS emit_let rc=%d\n", rc);
  return rc;
}

/**
 * Two-pass block body ELF emit with pass1-deferred lets.
 * @return 0 ok; -1 fail
 * PLATFORM: WINDOWS — host-gcc twin of pipeline_asm_emit_block_body_sync_elf.
 */
int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx,
                                              int32_t ta) {
  int32_t slot_base;
  int32_t nconst;
  int32_t nlet;
  int32_t nso;
  int32_t si;
  int32_t k;
  int32_t idx;
  int32_t er;
  int32_t ncfg;
  int32_t inner;
  int32_t wa_cap;
  int32_t wa_off;
  int32_t is_g;
  int32_t nlen;
  int32_t ret_ref;
  int32_t tj_len;
  int32_t fi;
  int32_t rty;
  int32_t sty;
  int32_t use_defer;
  int32_t defer_bit;
  int32_t li;
  int32_t ci;
  int32_t init_ref;
  int32_t slot_off;
  void *mod;
  uint8_t *ly;

  if (arena == 0 || elf_ctx == 0 || ctx == 0 || block_ref <= 0) {
    return -1;
  }
  pipeline_asm_fill_local_slots(ctx, arena, block_ref);
  slot_base = asm_ctx_block_slot_get(ctx, block_ref);
  if (slot_base < 0) {
    slot_base = 0;
  }
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  use_defer = 0;
  if (nlet > 0 && nlet <= 512) {
    use_defer = 1;
    memset(g_w1010_let_defer, 0, (size_t)nlet);
    glue_block_compute_pass1_deferred_lets(arena, ctx, block_ref, slot_base, nconst, nlet,
                                           g_w1010_let_defer);
  }
  for (ci = 0; ci < nconst; ci++) {
    init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, ci);
    slot_off = backend_asm_ctx_slot_offset(ctx, slot_base + ci);
    if (init_ref > 0) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0) {
        return -1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta) != 0) {
        return -1;
      }
    }
  }
  for (li = 0; li < nlet; li++) {
    defer_bit = 0;
    if (use_defer != 0 && g_w1010_let_defer[li] != 0) {
      defer_bit = 1;
    }
    if (defer_bit == 0) {
      if (w1010_emit_let(arena, elf_ctx, block_ref, li, slot_base, nconst, ctx, ta) != 0) {
        return -1;
      }
    }
  }
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (si = 0; si < nso; si++) {
    k = ast_ast_block_stmt_order_kind(arena, block_ref, si);
    idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
    if (k == 1) {
      if (use_defer != 0 && idx >= 0 && idx < nlet && g_w1010_let_defer[idx] != 0) {
        if (w1010_emit_let(arena, elf_ctx, block_ref, idx, slot_base, nconst, ctx, ta) != 0) {
          return -1;
        }
      }
      continue;
    }
    if (k == 2) {
      ncfg = ast_ast_block_num_expr_stmts(arena, block_ref);
      if (idx < 0 || idx >= ncfg) {
        continue;
      }
      er = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
      if (er <= 0) {
        continue;
      }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, er, ctx, ta) != 0) {
        return -1;
      }
      continue;
    }
    if (k == 3) {
      ncfg = ast_ast_block_num_loops(arena, block_ref);
      if (idx >= 0 && idx < ncfg) {
        if (backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0) {
          return -1;
        }
      }
      continue;
    }
    if (k == 4) {
      ncfg = ast_ast_block_num_for_loops(arena, block_ref);
      if (idx >= 0 && idx < ncfg) {
        if (backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0) {
          return -1;
        }
      }
      continue;
    }
    if (k == 5) {
      ncfg = ast_ast_block_num_if_stmts(arena, block_ref);
      if (idx >= 0 && idx < ncfg) {
        if (pipeline_asm_emit_block_if_stmt_elf(arena, elf_ctx, block_ref, idx, ctx, ta, si) != 0) {
          return -1;
        }
      }
      continue;
    }
    if (k == 6) {
      ncfg = ast_ast_block_num_regions(arena, block_ref);
      if (idx >= 0 && idx < ncfg) {
        inner = pipeline_block_region_body_ref(arena, block_ref, idx);
        wa_cap = pipeline_block_region_with_arena_cap_ref(arena, block_ref, idx);
        if (inner > 0) {
          backend_ensure_block_local_slots(ctx, arena, inner);
          if (wa_cap > 0) {
            wa_off = glue_wa_scope_alloc_off_c(ctx);
            if (glue_emit_with_arena_init_elf(arena, elf_ctx, ctx, wa_off, wa_cap, ta) != 0) {
              return -1;
            }
            glue_wa_scope_push_c(wa_off);
          }
          if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, inner, ctx, ta) != 0) {
            return -1;
          }
          if (wa_cap > 0) {
            er = glue_emit_with_arena_deinit_elf(elf_ctx, wa_off, ta);
            glue_wa_scope_pop_c();
            if (er != 0) {
              return -1;
            }
          }
        }
      }
      continue;
    }
    if (k == 7) {
      ncfg = pipeline_block_num_labeled_stmts(arena, block_ref);
      if (idx >= 0 && idx < ncfg) {
        is_g = pipeline_block_labeled_is_goto(arena, block_ref, idx);
        if (is_g != 0) {
          pipeline_block_labeled_goto_target_copy32(arena, block_ref, idx, g_w1010_name_buf);
          nlen = pipeline_block_labeled_goto_target_len(arena, block_ref, idx);
          if (nlen > 0 && nlen <= 255) {
            if (backend_enc_jmp_arch(elf_ctx, g_w1010_name_buf, nlen, ta) != 0) {
              return -1;
            }
          }
        } else {
          pipeline_block_labeled_label_copy32(arena, block_ref, idx, g_w1010_name_buf);
          nlen = pipeline_block_labeled_label_len(arena, block_ref, idx);
          if (nlen > 0 && nlen <= 255) {
            if (backend_enc_label_arch(elf_ctx, g_w1010_name_buf, nlen, 0, ta) != 0) {
              return -1;
            }
          }
          ret_ref = pipeline_block_labeled_return_expr_ref(arena, block_ref, idx);
          if (ret_ref > 0) {
            if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_ref, ctx, ta) != 0) {
              return -1;
            }
            mod = pipeline_asm_emit_module_ref_c();
            fi = pipeline_asm_emit_func_index_c();
            if (mod != 0 && fi >= 0) {
              rty = pipeline_module_func_return_type_at(mod, fi);
              sty = glue_float_promote_src_ty_ref_c(arena, ret_ref);
              if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0) {
                return -1;
              }
            }
            if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0) {
              return -1;
            }
            ly = pipeline_asm_ctx_layout(ctx);
            if (ly == 0) {
              return -1;
            }
            tj_len = pipe_load_i32_le(ly, 1520);
            if (tj_len > 0 && tj_len <= 255) {
              if (backend_enc_jmp_arch(elf_ctx, ly + 1392, tj_len, ta) != 0) {
                return -1;
              }
            }
          }
        }
      }
      continue;
    }
  }
  if (glue_emit_block_final_expr_elf(arena, elf_ctx, block_ref, ctx, ta) != 0) {
    return -1;
  }
  return 0;
}

/**
 * backend.x entry: bind module/dep then body_sync.
 * @return body_sync rc
 * PLATFORM: WINDOWS — host-gcc twin of backend_emit_block_body_sync_elf.
 */
int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx,
                                         int32_t ta) {
  glue_asm_block_diverged_set(0);
  glue_block_body_bind_module_dep_from_ctx(ctx);
  return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
}
