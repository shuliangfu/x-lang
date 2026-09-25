// Thin overlay: block body_sync with pass1-deferred let order (wave1009).
// Root: wave703 leftover body_sync calls emit_block_inits (all lets) then
//   skips stmt_order k==1 → `let a=1; a=7; let x=a` hoists x=a before a=7.
// G.7: pass0 consts + pure lets; pass1 deferred at stmt_order.
// BSS buffers avoid tip asm smash on u8[512] stack frames (wave703 class).
// Darwin/Linux: tip-compile this .x → body_sync_let_order.o (first-wins).
// Windows (w1010): host-gcc twin .c first-wins; mega same-TU still calls
//   leftover — g05 post-link win_patch_body_sync_jmp redirects leftover
//   entry to the twin (`jmp` rel32).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS|DARWIN · WINDOWS.

export extern function pipeline_asm_fill_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void;
export extern function asm_ctx_block_slot_get(ctx: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_let_init_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_let_name_len(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, li: i32, out: *u8): void;
export extern function glue_lazy_append_block_let_local(arena: *u8, ctx: *u8, block_ref: i32, li: i32, nm: *u8, nlen: i32): i32;
export extern function glue_block_body_emit_let_init(arena: *u8, elf_ctx: *u8, block_ref: i32, idx: i32, init_ref: i32, slot: i32, ctx: *u8, ta: i32, lnb: *u8, llen: i32): i32;
export extern function glue_block_compute_pass1_deferred_lets(arena: *u8, ctx: *u8, block_ref: i32, slot_base: i32, nconst: i32, nlet: i32, deferred: *u8): void;
export extern function ast_pipeline_block_const_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function backend_asm_ctx_slot_offset(ctx: *u8, slot_idx: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_emit_while_loop_elf_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, wi: i32, ctx: *u8, ta: i32): i32;
export extern function backend_emit_for_loop_elf_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, fi: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_block_if_stmt_elf(arena: *u8, elf_ctx: *u8, cur_block: i32, if_idx: i32, ctx: *u8, ta: i32, stmt_i: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_region_with_arena_cap_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void;
export extern function glue_wa_scope_alloc_off_c(ctx: *u8): i32;
export extern function glue_wa_scope_push_c(wa_off: i32): void;
export extern function glue_wa_scope_pop_c(): void;
export extern function glue_emit_with_arena_init_elf(arena: *u8, elf_ctx: *u8, ctx: *u8, wa_off: i32, cap_ref: i32, ta: i32): i32;
export extern function glue_emit_with_arena_deinit_elf(elf_ctx: *u8, wa_off: i32, ta: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_label_len(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_label_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_labeled_goto_target_len(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_goto_target_copy32(arena: *u8, block_ref: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_return_type_at(module: *u8, func_index: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, dest_ty: i32, src_ty: i32, ta: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_block_final_expr_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_block_body_bind_module_dep_from_ctx(ctx: *u8): void;
export extern function glue_asm_block_diverged_set(v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

// File-level BSS — tip asm smash on large stack arrays (wave703 class).
// PLATFORM: SHARED — wave1009 Cap residual thin local storage.
let g_w1009_let_defer: u8[512] = [];
let g_w1009_name_buf: u8[256] = [];
let g_w1009_lnb: u8[256] = [];

/**
 * Emit one let init (pass0 pure or pass1 deferred).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED — wave1009 helper.
 */
function w1009_emit_let(
  arena: *u8, elf_ctx: *u8, block_ref: i32, idx: i32,
  slot_base: i32, nconst: i32, ctx: *u8, ta: i32
): i32 {
  let init_ref: i32 = 0;
  let slot: i32 = 0;
  let llen: i32 = 0;
  let rc: i32 = 0;
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
    if (init_ref <= 0) {
      return 0;
    }
    slot = slot_base + nconst + idx;
    llen = pipeline_block_let_name_len(arena, block_ref, idx);
    if (llen > 0) {
      pipeline_block_let_name_copy64(arena, block_ref, idx, &g_w1009_lnb[0]);
      rc = glue_lazy_append_block_let_local(arena, ctx, block_ref, idx, &g_w1009_lnb[0], llen);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return glue_block_body_emit_let_init(
      arena, elf_ctx, block_ref, idx, init_ref, slot, ctx, ta, &g_w1009_lnb[0], llen
    );
  }
}

/**
 * Two-pass block body ELF emit with pass1-deferred lets (wave1009).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED — G.7 twin of pre-wave703 mega body_sync (+ leftover walk).
 */
#[no_mangle]
export function pipeline_asm_emit_block_body_sync_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32 {
  let slot_base: i32 = 0;
  let nconst: i32 = 0;
  let nlet: i32 = 0;
  let nso: i32 = 0;
  let si: i32 = 0;
  let k: i32 = 0;
  let idx: i32 = 0;
  let er: i32 = 0;
  let ncfg: i32 = 0;
  let inner: i32 = 0;
  let wa_cap: i32 = 0;
  let wa_off: i32 = 0;
  let is_g: i32 = 0;
  let nlen: i32 = 0;
  let ret_ref: i32 = 0;
  let tj_len: i32 = 0;
  let fi: i32 = 0;
  let rty: i32 = 0;
  let sty: i32 = 0;
  let use_defer: i32 = 0;
  let defer_bit: i32 = 0;
  let li: i32 = 0;
  let ci: i32 = 0;
  let init_ref: i32 = 0;
  let slot_off: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let ly: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || block_ref <= 0) {
    return 0 - 1;
  }
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
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
      glue_block_compute_pass1_deferred_lets(
        arena, ctx, block_ref, slot_base, nconst, nlet, &g_w1009_let_defer[0]
      );
    }
    // Pass0 consts (scalar store path).
    ci = 0;
    while (ci < nconst) {
      init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, ci);
      slot_off = backend_asm_ctx_slot_offset(ctx, slot_base + ci);
      if (init_ref > 0) {
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0) {
          return 0 - 1;
        }
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta) != 0) {
          return 0 - 1;
        }
      }
      ci = ci + 1;
    }
    // Pass0 pure (non-deferred) lets.
    li = 0;
    while (li < nlet) {
      defer_bit = 0;
      if (use_defer != 0) {
        if (g_w1009_let_defer[li] != (0 as u8)) {
          defer_bit = 1;
        }
      }
      if (defer_bit == 0) {
        if (w1009_emit_let(arena, elf_ctx, block_ref, li, slot_base, nconst, ctx, ta) != 0) {
          return 0 - 1;
        }
      }
      li = li + 1;
    }
    nso = ast_ast_block_num_stmt_order(arena, block_ref);
    si = 0;
    while (si < nso) {
      k = ast_ast_block_stmt_order_kind(arena, block_ref, si);
      idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
      if (k == 1) {
        if (use_defer != 0 && idx >= 0 && idx < nlet) {
          defer_bit = 0;
          if (g_w1009_let_defer[idx] != (0 as u8)) {
            defer_bit = 1;
          }
          if (defer_bit != 0) {
            if (w1009_emit_let(arena, elf_ctx, block_ref, idx, slot_base, nconst, ctx, ta) != 0) {
              return 0 - 1;
            }
          }
        }
        si = si + 1;
        continue;
      }
      if (k == 2) {
        ncfg = ast_ast_block_num_expr_stmts(arena, block_ref);
        if (idx < 0 || idx >= ncfg) {
          si = si + 1;
          continue;
        }
        er = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
        if (er <= 0) {
          si = si + 1;
          continue;
        }
        // Emit RETURN here too — glue_emit_block_final_expr alone missed
        // bare `return 42` under this thin (L2 rv). if-arm returns still
        // go through if emit. PLATFORM: SHARED wave1009.
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, er, ctx, ta) != 0) {
          return 0 - 1;
        }
        si = si + 1;
        continue;
      }
      if (k == 3) {
        ncfg = ast_ast_block_num_loops(arena, block_ref);
        if (idx >= 0 && idx < ncfg) {
          if (backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0) {
            return 0 - 1;
          }
        }
        si = si + 1;
        continue;
      }
      if (k == 4) {
        ncfg = ast_ast_block_num_for_loops(arena, block_ref);
        if (idx >= 0 && idx < ncfg) {
          if (backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0) {
            return 0 - 1;
          }
        }
        si = si + 1;
        continue;
      }
      if (k == 5) {
        ncfg = ast_ast_block_num_if_stmts(arena, block_ref);
        if (idx >= 0 && idx < ncfg) {
          if (pipeline_asm_emit_block_if_stmt_elf(arena, elf_ctx, block_ref, idx, ctx, ta, si) != 0) {
            return 0 - 1;
          }
        }
        si = si + 1;
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
                return 0 - 1;
              }
              glue_wa_scope_push_c(wa_off);
            }
            if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, inner, ctx, ta) != 0) {
              return 0 - 1;
            }
            if (wa_cap > 0) {
              er = glue_emit_with_arena_deinit_elf(elf_ctx, wa_off, ta);
              glue_wa_scope_pop_c();
              if (er != 0) {
                return 0 - 1;
              }
            }
          }
        }
        si = si + 1;
        continue;
      }
      if (k == 7) {
        ncfg = pipeline_block_num_labeled_stmts(arena, block_ref);
        if (idx >= 0 && idx < ncfg) {
          is_g = pipeline_block_labeled_is_goto(arena, block_ref, idx);
          if (is_g != 0) {
            pipeline_block_labeled_goto_target_copy32(arena, block_ref, idx, &g_w1009_name_buf[0]);
            nlen = pipeline_block_labeled_goto_target_len(arena, block_ref, idx);
            if (nlen > 0 && nlen <= 255) {
              if (backend_enc_jmp_arch(elf_ctx, &g_w1009_name_buf[0], nlen, ta) != 0) {
                return 0 - 1;
              }
            }
          } else {
            pipeline_block_labeled_label_copy32(arena, block_ref, idx, &g_w1009_name_buf[0]);
            nlen = pipeline_block_labeled_label_len(arena, block_ref, idx);
            if (nlen > 0 && nlen <= 255) {
              if (backend_enc_label_arch(elf_ctx, &g_w1009_name_buf[0], nlen, 0, ta) != 0) {
                return 0 - 1;
              }
            }
            ret_ref = pipeline_block_labeled_return_expr_ref(arena, block_ref, idx);
            if (ret_ref > 0) {
              if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_ref, ctx, ta) != 0) {
                return 0 - 1;
              }
              mod = pipeline_asm_emit_module_ref_c();
              fi = pipeline_asm_emit_func_index_c();
              if (mod != (0 as *u8) && fi >= 0) {
                rty = pipeline_module_func_return_type_at(mod, fi);
                sty = glue_float_promote_src_ty_ref_c(arena, ret_ref);
                if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0) {
                  return 0 - 1;
                }
              }
              if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
              ly = pipeline_asm_ctx_layout(ctx);
              if (ly == (0 as *u8)) {
                return 0 - 1;
              }
              tj_len = pipe_load_i32_le(ly, 1520);
              if (tj_len > 0 && tj_len <= 255) {
                if (backend_enc_jmp_arch(elf_ctx, ly + 1392, tj_len, ta) != 0) {
                  return 0 - 1;
                }
              }
            }
          }
        }
        si = si + 1;
        continue;
      }
      si = si + 1;
    }
    if (glue_emit_block_final_expr_elf(arena, elf_ctx, block_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}

/**
 * backend.x entry: bind module/dep then body_sync.
 * @return i32 — body_sync rc
 * PLATFORM: SHARED — wave1009 twin of pre-wave703 wrapper.
 */
#[no_mangle]
export function backend_emit_block_body_sync_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    glue_asm_block_diverged_set(0);
    glue_block_body_bind_module_dep_from_ctx(ctx);
    return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
  }
}
