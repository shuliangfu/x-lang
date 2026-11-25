// Thin overlay: block body_sync with pass1-deferred let order (wave1009).
// Root: wave703 leftover body_sync calls emit_block_inits (all lets) then
//   skips stmt_order k==1 → `let a=1; a=7; let x=a` hoists x=a before a=7.
// G.7: pass0 consts + pure lets; pass1 deferred at stmt_order.
// BSS buffers avoid tip asm smash on u8[512] stack frames (wave703 class).
// Darwin/Linux/Windows: tip-compile this .x → body_sync_let_order.o
// (first-wins). The Windows host-gcc .c twin is not a build input.
// Mega same-TU still calls the leftover; g05 post-link
// win_patch_body_sync_jmp redirects that entry here.
// Windows backend_emit clears the VAR-slot cache (egg forwarder does not).
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
export extern function pipeline_block_const_type_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_init_is_empty_array_lit(arena: *u8, init_ref: i32): i32;
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
export extern function glue_emit_run_language_defers_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_block_final_expr_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_block_body_bind_module_dep_from_ctx(ctx: *u8): void;
export extern function glue_asm_block_diverged_set(v: i32): void;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function link_abi_host_is_windows(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

// File-level BSS — tip asm smash on large stack arrays (wave703 class).
// PLATFORM: SHARED — wave1009 Cap residual thin local storage.
// w1505 / 10.36: the defer mask and let-name buffer are per nesting level.
// One shared mask was overwritten by the inner block (if/while/region body
// re-enters body_sync), so an outer pass1-deferred let (`let m2 = msg;`
// after `if (..) { let q = ..; }`) read the inner mask, was skipped in both
// passes, and its slot kept stack garbage. 64 levels x 512 lets.
let g_w1009_let_defer: u8[32768] = [];
let g_w1009_name_buf: u8[256] = [];
let g_w1009_lnb: u8[16384] = [];
let g_w1009_depth: i32 = 0;

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
  let lv: i32 = 0;
  let lnb: *u8 = 0 as *u8;
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
    if (init_ref <= 0) {
      return 0;
    }
    // w1505: name buffer of this nesting level (init may re-enter body_sync).
    lv = g_w1009_depth - 1;
    if (lv < 0) {
      lv = 0;
    }
    if (lv > 63) {
      lv = 63;
    }
    lnb = &g_w1009_lnb[lv * 256];
    slot = slot_base + nconst + idx;
    llen = pipeline_block_let_name_len(arena, block_ref, idx);
    if (llen > 0) {
      pipeline_block_let_name_copy64(arena, block_ref, idx, lnb);
      rc = glue_lazy_append_block_let_local(arena, ctx, block_ref, idx, lnb, llen);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return glue_block_body_emit_let_init(
      arena, elf_ctx, block_ref, idx, init_ref, slot, ctx, ta, lnb, llen
    );
  }
}

/**
 * Two-pass block body ELF emit with pass1-deferred lets (wave1009).
 * Pass0 consts of slice or fixed-array type call the same let-init writers
 * as the mega const loop. Other consts store rax into the slot.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit buffer. Null returns -1.
 * @param block_ref i32 — block node, not the EXPR_BLOCK expr. Not positive returns -1.
 * @param ctx *u8 — asm function context. Null returns -1.
 * @param ta i32 — 1 arm64, else x86.
 * @param dm *u8 — this level's pass1-let mask (0: no deferral). Not the language defer pool.
 * @param skip_final i32 — 0 emits the value expr. Non-zero stops after
 *   consts, lets, statements, and language defers. The caller emits the
 *   value once. Same slots either way.
 * @return i32 — 0 ok; -1 fail
 * Language `defer { }` is not a statement-order kind. It is emitted, LIFO,
 * before the final expression. A trailing return is that final expression,
 * so the defer body runs before the return load.
 * PLATFORM: SHARED — G.7 twin of pre-wave703 mega body_sync (+ leftover walk).
 */
function w1009_body_sync_level(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32, dm: *u8,
  skip_final: i32
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
  let type_ref: i32 = 0;
  let slice_st: i32 = 0;
  let arr_st: i32 = 0;
  let done: i32 = 0;
  let empty: i32 = 0;
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
    if (nlet > 0 && nlet <= 512 && dm != (0 as *u8)) {
      use_defer = 1;
      glue_block_compute_pass1_deferred_lets(
        arena, ctx, block_ref, slot_base, nconst, nlet, dm
      );
    }
    /* Pass0 consts. The mega const loop writes a slice or a fixed array
     * into the const slot. This thin used to emit_expr and store rax, so
     * the slot held the address of a temp. INDEX then read that pointer
     * as the array (SIGSEGV on [2][]i32, wrong sum on [2]i32). Slice kind
     * 11 and fixed-array kind 10 reuse the let writers. Anything else,
     * including a scalar i32, still stores rax. An empty ARRAY_LIT that
     * neither writer accepts stores nothing, matching the mega.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64. */
    ci = 0;
    while (ci < nconst) {
      init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, ci);
      slot_off = backend_asm_ctx_slot_offset(ctx, slot_base + ci);
      done = 0;
      type_ref = 0;
      empty = 0;
      if (init_ref > 0) {
        type_ref = pipeline_block_const_type_ref(arena, block_ref, ci);
        empty = glue_init_is_empty_array_lit(arena, init_ref);
      }
      if (init_ref > 0 && type_ref > 0) {
        slice_st = glue_emit_slice_from_array_let_init_elf_c(
            arena, elf_ctx, block_ref, ci, init_ref, type_ref, ctx, ta, slot_off);
        if (slice_st == 1) {
          done = 1;
        } else {
          if (slice_st < 0) {
            return 0 - 1;
          }
        }
      }
      if (done == 0 && init_ref > 0 && type_ref > 0) {
        arr_st = glue_emit_fixed_array_type_let_init_elf_c(
            arena, elf_ctx, init_ref, ctx, ta, type_ref, slot_off);
        if (arr_st == 0) {
          done = 1;
        } else {
          if (arr_st == (0 - 1)) {
            return 0 - 1;
          }
        }
      }
      if (done == 0 && init_ref > 0 && empty == 0) {
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
        if (dm[li] != (0 as u8)) {
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
          if (dm[idx] != (0 as u8)) {
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
    // PLATFORM: SHARED — language defer pool, before the final expression.
    // Same order as codegen emit_run_defers. The runner reads
    // pipeline_block_defer_body_ref and emits each body through this function.
    if (glue_emit_run_language_defers_elf(arena, elf_ctx, block_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    // skip_final leaves the value expr for the caller (a field rvalue
    // emits that struct literal once). Defers already ran, matching
    // the full path's order. PLATFORM: SHARED.
    if (skip_final == 0) {
      if (glue_emit_block_final_expr_elf(arena, elf_ctx, block_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
    }
    return 0;
  }
}

/**
 * Two-pass block body ELF emit: push one nesting level, run, pop.
 * w1505 / 10.36: nested blocks (if/while/for/region bodies) re-enter here and
 * each level owns its defer mask, so the outer pass1 lets are still emitted.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED — G.7 entry (Windows host-gcc twin mirrors it).
 */
#[no_mangle]
export function pipeline_asm_emit_block_body_sync_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32 {
  let d: i32 = 0;
  let rc: i32 = 0;
  let dm: *u8 = 0 as *u8;
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    d = g_w1009_depth;
    if (d >= 0 && d < 64) {
      dm = &g_w1009_let_defer[d * 512];
    }
    g_w1009_depth = d + 1;
    rc = w1009_body_sync_level(arena, elf_ctx, block_ref, ctx, ta, dm, 0);
    g_w1009_depth = d;
  }
  return rc;
}

/**
 * Emit a block's consts, lets, and statements, and not its value expr.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit buffer. Null returns -1.
 * @param block_ref i32 — block node, not the EXPR_BLOCK expr. Not positive returns -1.
 * @param ctx *u8 — asm function context. Null returns -1.
 * @param ta i32 — 1 arm64, else x86.
 * @return i32 — 0 when the prefix is emitted, -1 on failure.
 * This is w1009_body_sync_level with the value step skipped, so the
 * lets occupy the same slots as pipeline_asm_emit_block_body_sync_elf.
 * A field rvalue retargets onto that value and emits it once. Calling
 * this and the full body_sync on the same block emits the lets twice.
 * #[no_mangle] keeps the link name equal to this declaration.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_block_prefix_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32 {
  let d: i32 = 0;
  let rc: i32 = 0;
  let dm: *u8 = 0 as *u8;
  // PLATFORM: SHARED — same nesting level as body_sync, so the let-name
  // buffer and the pass1 mask are not the caller's level.
  unsafe {
    d = g_w1009_depth;
    if (d >= 0) {
      if (d < 64) {
        dm = &g_w1009_let_defer[d * 512];
      }
    }
    g_w1009_depth = d + 1;
    rc = w1009_body_sync_level(arena, elf_ctx, block_ref, ctx, ta, dm, 1);
    g_w1009_depth = d;
  }
  return rc;
}

/**
 * backend.x entry: on Windows, drop the VAR-slot register cache, then bind
 * module/dep and run body_sync.
 * The egg forwarder never clears that cache, and mega reuses one context, so
 * the next function would reload a stale rbx. Then-blocks enter here too;
 * the former Windows host-gcc twin cleared on every entry.
 * Darwin and Linux do not clear here.
 * @param arena *u8 — AST arena, passed through to body_sync
 * @param elf_ctx *u8 — emit context, passed through to body_sync
 * @param block_ref i32 — block whose body is emitted
 * @param ctx *u8 — asm function context; bind reads the module from it
 * @param ta i32 — target arch, passed through to body_sync
 * @return i32 — body_sync status; 0 ok, -1 fail
 * PLATFORM: SHARED entry. The cache clear runs only on WINDOWS.
 */
#[no_mangle]
export function backend_emit_block_body_sync_elf(
  arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    // PLATFORM: WINDOWS — egg body_sync leaves the VAR-slot cache stale.
    if (link_abi_host_is_windows() != 0) {
      glue_binop_var_slot_cache_clear();
    }
    glue_asm_block_diverged_set(0);
    glue_block_body_bind_module_dep_from_ctx(ctx);
    return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
  }
}
