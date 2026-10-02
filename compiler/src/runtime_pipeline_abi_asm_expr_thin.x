// Thin pure: asm_expr FULL leaf (emit_expr_elf_rec + emit_expr_elf_c).
// G.7: body matches seeds/runtime_pipeline_abi.from_x.c emit_expr_elf_rec
// with ko==60 → pipeline_asm_try_emit_inline_asm_expr_elf_c.
// wave350: also own emit_expr_elf_c so inject redefine-sym cannot leave
// mega emit_expr_elf_c bound to *_pabi_superseded rec (bare INDEX CG002).
// ensure: inject_asm_expr_thin injects THIS on MACOS only.
// wave409/419: MACOS PREFER full (product L2 green); LINUX HARD BAN tip
//   reinject (helpers-only also product opt=255 after proper relink).
// wave752: classify full emit_expr_elf_c tip frame — NOT leftover-wipe.
//   Live tip = leftover gcc W thin wrapper (Darwin weak sub #0x40 /
//   LINUX W endbr64 sub $0x20 size 0x3e) that calls emit_expr_elf_rec.
//   LINUX rec already w739 PREFER T (push+sub $0x19b8). MACOS keep full
//   overlay (rec weak sub #0x60). Standalone full -c T=3 U=35 nsects=1:
//   tip still smash (Darwin sub #0x890 / LINUX push+sub $0x888); rec smash
//   (sub ~#0x19c0 / $0x19b8). Re-PREFER of full tip would dest-overwrite
//   healthy leftover W tip wrapper. HARD BAN PREFER of tip remains.
//   Do not gcc -E as the repair. Do not leftover-first.
// PLATFORM: SHARED freestanding emit · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_if_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_if_arm_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_match_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_panic_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function leftover_emit_struct_lit_into_parked_rbx(arena: *u8, elf_ctx: *u8, lit_ref: i32, ctx: *u8, ta: i32, base_off: i32): i32;
export extern function pipeline_asm_emit_array_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_addr_of_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_method_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_asm_emit_string_lit_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32;
export extern function pipeline_asm_try_emit_inline_asm_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_cmp_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_break_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_continue_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_neg_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_bitnot_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lognot_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_await_sync_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_try_propagate_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_logand_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_logor_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_enum_namespace_field_tag(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_emit_expr_elf_slow(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;

export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

/**
 * Load i32 from pipe cell (local; tip-stable mid `x=cell_load()`).
 * @param base *u8 — cell base
 * @return i32 — stored value
 * PLATFORM: SHARED — wave495 tipU heal helper.
 */
function w495_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}


/**
 * Emit an INT_LIT whose i64 value does not fit in i32 as a full imm64.
 * w1504 (10.30): the Darwin leftover pabi emit_expr_elf_fast calls
 * pipeline_expr_int64_val_at without a prototype (implicit int), so it
 * sign-extends w0 and range-checks only bit 31; 10000000000 became
 * mov w0,#0xe400; movk w0,#0x540b,lsl16. The rec owns wide literals first.
 * Float-typed literals stay on the fast path (it converts to f32/f64 bits).
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — INT_LIT expression ref
 * @param ta i32 — target arch
 * @return i32 — emit rc when handled; -99 when not a wide int literal
 * PLATFORM: SHARED freestanding emit (Linux/Win fast already emit the same imm64).
 */
function w1504_emit_wide_int_lit(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32 {
  let v64: i64 = 0;
  let i32_max: i64 = 2147483647;
  let i32_min: i64 = 0;
  let tref: i32 = 0;
  let tk: i32 = 0;
  let lo: i32 = 0;
  let hi: i32 = 0;
  unsafe {
    v64 = pipeline_expr_int64_val_at(arena, expr_ref);
  }
  i32_min = 0 - 2147483647 - 1;
  if (v64 >= i32_min && v64 <= i32_max) {
    return 0 - 99;
  }
  unsafe {
    tref = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (tref > 0) {
    unsafe {
      tk = pipeline_type_kind_ord_at(arena, tref);
    }
    if (tk == 14 || tk == 15) {
      return 0 - 99;
    }
  }
  lo = v64 as i32;
  hi = (v64 >> 32) as i32;
  unsafe {
    return backend_enc_mov_imm64_to_rax_arch(elf_ctx, lo, hi, ta);
  }
}

/**
 * Freestanding expr ELF recursion with EXPR_ASM (60) slice0.
 * Fast path first; kind dispatch includes asm!("template") → try_emit.
 * Kind 45 (STRUCT_LIT) reads the global sret cell. When the mega published
 * active, a home offset, and a return wider than 16 on x86_64, the existing
 * parked-rbx writer copies u8[256] fields. Otherwise the byte-sized struct-lit
 * emitter runs. Omits XLANG_DEBUG_REGEX_EMIT fprintf (wave106 style).
 * @param arena *u8 — AST arena; null is not used (expr_ref <= 0 takes the slow path)
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — expression ref; <= 0 skips the kind load
 * @param ctx *u8 — asm function context passed through to callees
 * @param ta i32 — target arch; 0 is x86_64, the only arch that takes the wide sret copy
 * @return i32 — 0 ok; negative error; -99 unhandled from the wide-int helper
 * PLATFORM: SHARED rec. The 256-byte writer is WINDOWS leftover; other hosts
 * resolve the same symbol and do not take the ta==0 gate on arm64.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  /* wave495: no-local — pipe cells + w495_cell_i32 (ban mid `x=extern()`). */
  let r: i32 = 0;
  let ko: i32 = 0 - 1;
  let out_rc: i32 = 0;
  let ns_tag: i32 = 0;
  let sret_act: i32 = 0;
  let sret_home: i32 = 0 - 1;
  let sret_sz: i32 = 0;
  let cell_ko: u8[8];
  let cell_r: u8[8];
  let cell_ns: u8[8];
  if (expr_ref > 0) {
    unsafe {
      /* PLATFORM: SHARED — tip drops mid `ko=pipeline_expr_kind_ord_at()`; pipe cell. */
      pipe_store_i32_le(&cell_ko[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    }
    ko = w495_cell_i32(&cell_ko[0]);
  }
  if (ko == 0) {
    unsafe {
      /* w1504 (10.30): wide INT_LIT imm64 before the fast path; pipe cell. */
      pipe_store_i32_le(&cell_r[0], 0, w1504_emit_wide_int_lit(arena, elf_ctx, expr_ref, ta));
    }
    r = w495_cell_i32(&cell_r[0]);
    if (r != (0 - 99)) {
      return r;
    }
  }
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `r=pipeline_asm_emit_expr_elf_fast()`; pipe cell. */
    pipe_store_i32_le(&cell_r[0], 0, pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta));
  }
  r = w495_cell_i32(&cell_r[0]);
  if (r != (0 - 99)) {
    return r;
  }
  if (ko == 25 || ko == 27) {
    unsafe {
      return pipeline_asm_emit_expr_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 26) {
    unsafe {
      return pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 43) {
    unsafe {
      return pipeline_asm_emit_match_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 42) {
    unsafe {
      return pipeline_asm_emit_panic_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 45) {
    /* Same gate as the from_x rec: load the sret home into rbx, push it,
     * and let the existing parked-rbx writer copy a 256-byte VAR field.
     * Pipe cells keep each extern result out of a mid-statement store.
     * PLATFORM: SHARED check. ta==0 selects the x86_64 SysV home. */
    unsafe {
      pipe_store_i32_le(&cell_r[0], 0, pipeline_asm_emit_ctx_sret_active_get());
    }
    sret_act = w495_cell_i32(&cell_r[0]);
    unsafe {
      pipe_store_i32_le(&cell_ko[0], 0, pipeline_asm_emit_ctx_sret_home_off_get());
    }
    sret_home = w495_cell_i32(&cell_ko[0]);
    unsafe {
      pipe_store_i32_le(&cell_ns[0], 0, pipeline_asm_emit_ctx_sret_ret_sz_get());
    }
    sret_sz = w495_cell_i32(&cell_ns[0]);
    if (sret_act != 0 && sret_home >= 0 && sret_sz > 16 && sret_sz <= 4096 && ta == 0) {
      unsafe {
        pipe_store_i32_le(&cell_r[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, sret_home, ta));
      }
      r = w495_cell_i32(&cell_r[0]);
      if (r == 0) {
        unsafe {
          pipe_store_i32_le(&cell_r[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
        }
        r = w495_cell_i32(&cell_r[0]);
      }
      if (r == 0) {
        unsafe {
          pipe_store_i32_le(&cell_r[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
        }
        r = w495_cell_i32(&cell_r[0]);
      }
      if (r == 0) {
        unsafe {
          pipe_store_i32_le(&cell_r[0], 0, leftover_emit_struct_lit_into_parked_rbx(arena, elf_ctx, expr_ref, ctx, ta, 0));
        }
        r = w495_cell_i32(&cell_r[0]);
        if (r == 0) {
          unsafe {
            pipe_store_i32_le(&cell_r[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
          }
          r = w495_cell_i32(&cell_r[0]);
          if (r == 0) {
            unsafe {
              pipe_store_i32_le(&cell_r[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
            }
            r = w495_cell_i32(&cell_r[0]);
          }
        } else {
          unsafe {
            pipe_store_i32_le(&cell_r[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
          }
        }
      }
      if (r != 0) {
        return 0 - 1;
      }
      return 0;
    }
    unsafe {
      return pipeline_asm_emit_struct_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 46) {
    unsafe {
      return pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 47) {
    unsafe {
      return pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 51) {
    unsafe {
      return pipeline_asm_emit_addr_of_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 52) {
    unsafe {
      return pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 48) {
    unsafe {
      return pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 49) {
    unsafe {
      return pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 59) {
    unsafe {
      return glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    }
  }
  /* Stage10 10.2.1: EXPR_ASM (slice1 in-operand needs ctx) */
  if (ko == 60) {
    unsafe {
      return pipeline_asm_try_emit_inline_asm_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko >= 14 && ko <= 19) {
    unsafe {
      return pipeline_asm_emit_cmp_elf(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 41) {
    unsafe {
      return pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 39) {
    unsafe {
      return pipeline_asm_emit_break_elf_c(arena, elf_ctx, ctx, ta);
    }
  }
  if (ko == 40) {
    unsafe {
      return pipeline_asm_emit_continue_elf_c(arena, elf_ctx, ctx, ta);
    }
  }
  if (ko == 22) {
    unsafe {
      return pipeline_asm_emit_neg_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 23) {
    unsafe {
      return pipeline_asm_emit_bitnot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 24) {
    unsafe {
      return pipeline_asm_emit_lognot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  unsafe {
    if (glue_expr_is_await_at_c(arena, expr_ref) != 0) {
      return pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
    if (glue_expr_is_x_as_cast_at_c(arena, expr_ref) != 0) {
      return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 58 || ko == 57) {
    unsafe {
      return pipeline_asm_emit_try_propagate_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 28 || (ko >= 29 && ko <= 38)) {
    unsafe {
      return pipeline_asm_emit_assign_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 20) {
    unsafe {
      return pipeline_asm_emit_logand_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 21) {
    unsafe {
      return pipeline_asm_emit_logor_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 44) {
    unsafe {
      /* PLATFORM: SHARED — tip drops mid `ns_tag=pipeline_expr_enum_namespace_field_tag()`; pipe cell. */
      pipe_store_i32_le(&cell_ns[0], 0, pipeline_expr_enum_namespace_field_tag(arena, expr_ref));
    }
    ns_tag = w495_cell_i32(&cell_ns[0]);
    if (ns_tag >= 0) {
      unsafe {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
      }
    }
    return 0 - 1;
  }
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `out_rc=backend_emit_expr_elf_slow()`; direct return. */
    return backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
  }
}

/**
 * Public expr ELF face — thin delegate to emit_expr_elf_rec.
 * wave350: must ship with rec in this thin so product inject does not leave
 * mega emit_expr_elf_c calling *_pabi_superseded rec after redefine-sym.
 * @return i32 — face status from rec
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
