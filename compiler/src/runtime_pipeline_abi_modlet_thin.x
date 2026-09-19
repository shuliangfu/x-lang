// Thin pure: wave631 M2 — modlet family ONE-set.
// Root fix for the w629 dual-table split: the from_x rest's prepare wrote
// g_pipeline_asm_modlet_cold while the -E chunk lane's weak find/load/lea
// read the hot g_pipeline_asm_modlet — addr_of(&module_scalar_cell) then
// failed find (-1) → CG002 -99 (user) / mov $0 (monofile slot fns).
// This thin carries the WHOLE table-touching family + the table + its
// companion state in ONE member; product PREFER both ends makes
// prepare/find/load/lea share a single table. G.7: bodies copied
// verbatim from the mega leaves; the transitive callee closure rides
// along as same-file copies so bare calls stay unsafe-free exactly as
// in the mega. PLATFORM: SHARED — PREFER_ASM both ends.

let g_pipeline_asm_modlet: u8[86020] = [];
let g_pipe_elf_shndx_sidecar_owner: *u8 = 0 as *u8;
let g_pipe_elf_reloc_sidecar_owner: *u8 = 0 as *u8;
let g_pipe_elf_reloc_shndx: u8[65536] = [];
let g_pipe_elf_shndx_override: i32 = 0;
let g_pipe_elf_sym_is_common: u8[16384] = [];
let g_pipe_elf_common_owner: *u8 = 0 as *u8;
let g_pipe_elf_data_len: i32 = 0;
let g_pipe_dep_sc_blob: u8[17408] = [];
let g_pipe_module_sc_last_sc1: *u8 = 0 as *u8;
let g_pipe_arena_sc_last_sc1: *u8 = 0 as *u8;
let g_pipe_onefunc_mru_blob: u8[256] = [];
let g_pipe_module_sc_last_key1: *u8 = 0 as *u8;
let g_pipe_module_sc_last_key0: *u8 = 0 as *u8;
let g_pipe_arena_sc_blob: u8[417792] = [];
let g_pipe_module_sc_blob: u8[221184] = [];
let g_pipe_module_sc_last_sc0: *u8 = 0 as *u8;
let g_pipe_onefunc_sc_used_hi: i32 = 0;
let g_pipe_arena_sc_last_sc0: *u8 = 0 as *u8;
let g_pipe_arena_sc_last_key1: *u8 = 0 as *u8;
let g_pipe_onefunc_sc_blob: u8[966656] = [];
let g_pipe_arena_sc_last_key0: *u8 = 0 as *u8;
let g_pipe_onefunc_mru_clock: i32 = 0;
let g_pipe_elf_reloc_heap: u8[196608] = [];
let g_wave148_fb: u8[256] = [];
let g_pipe_tl_n: i32[128] = [];
let g_pipe_tl_entries: u8[1024] = [];
let g_pipe_sl_mod: u8[1024] = [];
let g_pipe_tl_mod: u8[1024] = [];
let g_wave148_tname: u8[64] = [];
let g_pipe_elf_reloc_r_type: u8[65536] = [];
let g_pipe_elf_reloc_r_pcrel: u8[16384] = [];
let g_pipe_elf_reloc_sym_heap: u8[4194304] = [];
let g_pipe_modlet_strpool_seq: i32 = 0;
let g_pipe_elf_label_shndx: u8[65536] = [];
let g_pipe_elf_patch_shndx: u8[65536] = [];
let g_pipe_elf_data_buf: u8[65536] = [];
let g_pipe_gv_mmap_flags: i32 = 34;
let g_pipeline_asm_emit_arena: *u8 = 0 as *u8;
let g_pipeline_asm_emit_dep_pipe: *u8 = 0 as *u8;
let g_pipe_sl_fn: i32[128] = [];
let g_pipe_sl_n: i32[128] = [];
let g_pipe_sl_tpn: i32[128] = [];
let g_pipe_elf_ws_hdr32: u8[32] = [];
let g_pipe_elf_ws_undef_lens: u8[1024] = [];
let g_pipe_elf_ws_ent: u8[256] = [];
let g_pipe_elf_label_mod_scope_active: i32 = 0;
let g_pipe_elf_ws_shstr_ready: i32 = 0;
let g_pipe_elf_sym_common_size: u8[65536] = [];
let g_pipe_elf_ws_ehdr: u8[256] = [];
let g_pipe_elf_sym_common_align: u8[65536] = [];
let g_pipe_elf_ws_shdr: u8[1280] = [];
let g_pipe_elf_ws_und_lens: u8[1024] = [];
let g_pipe_elf_ws_shstr_std: u8[64] = [];
let g_pipe_elf_ws_seg: u8[152] = [];
let g_pipe_elf_ws_rela: u8[24] = [];
let g_pipe_elf_ws_und_src: u8[1024] = [];
let g_pipe_elf_ws_name2: u8[256] = [];
let g_pipe_elf_ws_pgo_undef_names: u8[4096] = [];
let g_pipe_elf_ws_name: u8[256] = [];
let g_pipe_elf_ws_shstr_pgo: u8[107] = [];
let g_pipe_elf_ws_pgo_undef_lens: u8[256] = [];
let g_pipe_elf_ws_lc: u8[48] = [];
let g_pipe_elf_ws_undef_names: u8[32768] = [];
let g_pipe_elf_ws_seg2: u8[152] = [];
let g_pipe_elf_data_owner: *u8 = 0 as *u8;
let g_pipe_elf_label_mod_scope_base: i32 = 0;
let g_pipeline_asm_emit_module: *u8 = 0 as *u8;
let g_pipe_sl_layouts: u8[1024] = [];

// True cross-TU faces (call sites are already unsafe in the copied bodies).

/**
 * Build the modlet table and emit homes for module lets.
 * Accepts:
 *   (1) mutable scalar COMMON init → 8-byte COMMON (historic wave139 LIT/BOOL;
 *       wave338 adds EXPR_NEG-over-LIT + null TYPE_PTR AS/LIT 0)
 *   (2) fixed TYPE_ARRAY (kind 10) with ARRAY_LIT init (kind 46), e.g. `u8[N]=[]`
 *       and `const A:[2]i32=[10,32]`:
 *       · empty lit `[]` → SHN_COMMON / Mach-O __common (BSS zero; correct)
 *       · non-empty lit that fits in the F7 .data buf (64 KiB, including
 *         interned STRING_LIT pool + absolute64 RELA on pointer slots,
 *         including 9.4.2 named-symbol ADDR_OF / fn-ptr elems) →
 *         ELF .data / Mach-O __DATA baked at prepare time
 *         (library TUs have no hoist-target entry; COMMON+seed stays zero)
 *       · non-empty lit that does not fit → COMMON + hoist seed_nonzero (historic)
 *   (3) scalar ADDR_OF / fn-ptr (tk 9/18, pipe_modlet_scalar_init_is_ptr_addr):
 *       `let p: *i32 = &g` / `let h: *u8 = inc` / `inc as *u8` → 8-byte
 *       .data + absolute64 RELA (same reloc authority as (2) elems).
 *       Hoist skip uses the same predicate (9.6.0 dual-home class).
 * Without (2), pure-asm stacked every module array into each function frame
 * (~sum of all g_labi_* buffers per call) → stack overflow / dangling path
 * returns (labi_path_pure hybrid SEGV on opt/si/hello).
 * Const TYPE_ARRAY used to skip here (is_const) and hoist into main only —
 * non-main INDEX then had no home (CG002). Same home path as mutable
 * when the elem is not TYPE_SLICE; seed_nonzero writes ARRAY_LIT elems
 * only for COMMON-backed cells (skips .data-backed — may be RO after link).
 * Const `[N][]T` (elem SLICE) still skips — fat rows hoist + durable.
 * Other const (scalars, dest-SLICE) still skip — those hoist / use text cells.
 * COMMON / .data names are Lxml_<name-hash><module-fp> (not Lxlang_ml_<idx>):
 * SHN_COMMON / Mach-O __common merge by name, so per-index labels aliased
 * every TU's N-th module let (check_only 512B leftover).
 * @param m *u8 - Module*
 * @param a *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok (incl no-op); -1 COMMON / .data emit fail
 * wave139 pure: G.7 authority (was static prepare_and_emit_elf_c).
 * Cap residual: top_level readers + expr_kind/int_val + type_kind/array size +
 *   common_sym + F7 .data bake + fixed_array_total_bytes + pipe nlets/nexprs.
 * PLATFORM: SHARED — ELF .data + Mach-O __DATA,__const for non-empty ARRAY_LIT.
 */
#[no_mangle]
export function pipeline_asm_modlet_prepare_and_emit_elf_c(m: *u8, a: *u8, elf_ctx: *u8, ta: i32): i32 {
  pipeline_asm_modlet_reset();
  if (m == 0 as *u8 || a == 0 as *u8 || elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  let nlets: i32 = pipe_mod_get_num_top_level_lets(m);
  if (nlets <= 0) {
    return 0;
  }
  let nexprs: i32 = pipe_load_i32_le(a, pipe_arena_off_num_exprs());
  let tl: i32 = 0;
  while (tl < nlets) {
    let is_const: i32 = 0;
    unsafe {
      is_const = pipeline_module_top_level_let_is_const(m, tl);
    }
    // Do not skip all const here: const TYPE_ARRAY + ARRAY_LIT needs COMMON
    // so non-main INDEX can LEA. Gate is after tk / init_kind below.
    let name_len: i32 = 0;
    unsafe {
      name_len = pipeline_module_top_level_let_name_len(m, tl);
    }
    if (name_len <= 0 || name_len > 255) {
      tl = tl + 1;
      continue;
    }
    let init_ref: i32 = 0;
    unsafe {
      init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    }
    if (init_ref <= 0 || init_ref > nexprs) {
      tl = tl + 1;
      continue;
    }
    let init_kind: i32 = 0;
    unsafe {
      init_kind = pipeline_expr_kind_ord_at(a, init_ref);
    }
    // Classify: scalar COMMON (LIT/BOOL/NEG-over-LIT/null-ptr) vs fixed
    // array ARRAY_LIT (46) vs scalar ADDR_OF / fn-ptr bake.
    // wave338: NEG-over-LIT + null TYPE_PTR join the COMMON arm (was
    // only ek 0/2) so Cap library TUs get durable homes. PLATFORM: SHARED.
    let cell_sz: i32 = 8;
    let imm: i32 = 0;
    let type_ref: i32 = 0;
    unsafe {
      type_ref = pipeline_module_top_level_let_type_ref(m, tl);
    }
    let tk: i32 = 0;
    if (type_ref > 0) {
      unsafe {
        tk = pipeline_type_kind_ord_at(a, type_ref);
      }
    }
    let imm_buf: i32[1] = [];
    imm_buf[0] = 0;
    if (pipe_modlet_scalar_init_common_imm(a, init_ref, tk, is_const, &imm_buf[0]) == 1) {
      imm = imm_buf[0];
      cell_sz = 8;
    } else {
      // TYPE_ARRAY (10) + ARRAY_LIT (46): durable BSS for mutable *and*
      // const scalar / nested `[K][N]T` arrays. Const `[N][]T` (elem
      // TYPE_SLICE) stays skipped — payload is fat rows, seed writes LIT
      // only; hoist + durable dest_elem_ty is that home (cmns na).
      // Scalar ADDR_OF / fn-ptr (tk 9/18): 8-byte .data cell, baked
      // below via pipe_modlet_bake_ptr_addr_elem_to_data. Predicate
      // matches hoist skip (9.6.0 dual-home). PLATFORM: SHARED.
      if (tk == 9 || tk == 18) {
        let is_pa: i32 = 0;
        is_pa = pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref);
        if (is_pa == 0) {
          tl = tl + 1;
          continue;
        }
        cell_sz = 8;
        imm = 0;
      } else {
      if (tk != 10 || init_kind != 46) {
        tl = tl + 1;
        continue;
      }
      if (is_const != 0) {
        let et_p: i32 = 0;
        let etk_p: i32 = 0;
        unsafe {
          et_p = pipeline_type_elem_ref_at(a, type_ref);
        }
        if (et_p > 0) {
          unsafe {
            etk_p = pipeline_type_kind_ord_at(a, et_p);
          }
        }
        if (etk_p == 11) {
          tl = tl + 1;
          continue;
        }
      }
      unsafe {
        cell_sz = glue_fixed_array_total_bytes_c(a, type_ref, 0);
      }
      if (cell_sz <= 0) {
        tl = tl + 1;
        continue;
      }
      // Cap residual guard: reject absurd COMMON sizes (not product BSS).
      // PLATFORM: SHARED — low 30 bits hold payload; bit30 = array decay.
      // Product: fmt_check_cmd_thin g_fmt_file_list_paths = DRIVER_FMT_MAX_FILES(8192)×512
      // = 4194304 (4 MiB). Historical 1 MiB cap skipped that cell → pure-asm
      // &g_fmt_file_list_paths[0] UNHANDLED → CG002 in fmt_file_list_at (Stage12.0.5).
      // Cap 8 MiB: covers 4 MiB product + headroom; still << 0x3FFFFFFF encoding max.
      if (cell_sz > 8388608) {
        tl = tl + 1;
        continue;
      }
      // Mark array decay so payload==8 (u8[8]) is not treated as scalar load.
      cell_sz = cell_sz | pipe_modlet_cell_array_bit();
      imm = 0;
      }
    }
    // PLATFORM: SHARED — table is a fixed BSS (pipe_modlet_max).
    // Silent `break` at 64 used to drop extras: load/store then missed the
    // cell and fell through to a stack slot (9.6.0 dual-home class).
    // G.7: complete this existing table — loud-fail (return -1 → CG002)
    // when a registrable cell would exceed the cap. Skip-only leftover
    // lets (const scalars, nameless, non-ARRAY) must not trip the cap.
    if (pipe_modlet_get_n() >= pipe_modlet_max()) {
      return 0 - 1;
    }
    let idx: i32 = pipe_modlet_get_n();
    pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(idx), name_len);
    let k: i32 = 0;
    let nbase: i32 = pipe_modlet_off_name(idx);
    while (k < name_len) {
      let b: i32 = 0;
      unsafe {
        b = pipeline_module_top_level_let_name_byte_at(m, tl, k);
        g_pipeline_asm_modlet[nbase + k] = b as u8;
      }
      k = k + 1;
    }
    pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(idx), imm);
    pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx), cell_sz);
    pipe_modlet_set_n(idx + 1);
    tl = tl + 1;
  }
  let i: i32 = 0;
  let nn: i32 = pipe_modlet_get_n();
  let module_fp: i64 = pipe_modlet_module_fp();
  while (i < nn) {
    pipe_modlet_assign_unique_label(i, module_fp);
    i = i + 1;
  }
  i = 0;
  while (i < nn) {
    let llen2: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(i));
    let lbase2: i32 = pipe_modlet_off_label(i);
    let csz_raw: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(i));
    // Home size = payload only (strip array-decay bit30 / data bit29).
    let csz2: i32 = pipe_modlet_cell_payload(csz_raw);
    let calign: i32 = 8;
    let use_data: i32 = 0;
    let init_ref2: i32 = 0;
    let type_ref2: i32 = 0;
    let ik2: i32 = 0;
    let tk2: i32 = 0;
    let et2: i32 = 0;
    let ne2: i32 = 0;
    let data_off: i32 = 0;
    let data_len_now: i32 = 0;
    let pad: i32 = 0;
    let nbase2: i32 = 0;
    let nlen2: i32 = 0;
    let tl2: i32 = 0;
    let match_tl: i32 = 0;
    let k2: i32 = 0;
    let b2: i32 = 0;
    let rc: i32 = 0;
    let pool_bytes: i32 = 0;
    if (csz2 == 1) {
      calign = 1;
    } else {
      if (csz2 == 2) {
        calign = 2;
      } else {
        if (csz2 == 4) {
          calign = 4;
        } else {
          if (csz2 >= 16) {
            calign = 16;
          }
        }
      }
    }
    // Resolve the originating top-level let by name (array bake AND
    // scalar ptr-addr). Non-empty TYPE_ARRAY ARRAY_LIT → F7 .data when
    // cell+pool fits. Scalar ADDR_OF / fn-ptr → 8-byte .data + absolute64
    // RELA (library TUs have no hoist-target seed). Empty `u8[N]=[]`
    // stays COMMON. Oversized falls back to COMMON + hoist seed.
    // PLATFORM: SHARED library-TU .data.
    nlen2 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i));
    nbase2 = pipe_modlet_off_name(i);
    match_tl = 0 - 1;
    tl2 = 0;
    while (tl2 < nlets) {
      let tln: i32 = 0;
      unsafe {
        tln = pipeline_module_top_level_let_name_len(m, tl2);
      }
      if (tln == nlen2 && tln > 0) {
        k2 = 0;
        while (k2 < tln) {
          let mb: i32 = 0;
          unsafe {
            b2 = pipeline_module_top_level_let_name_byte_at(m, tl2, k2);
            mb = g_pipeline_asm_modlet[nbase2 + k2] as i32;
          }
          if (b2 != mb) {
            break;
          }
          k2 = k2 + 1;
        }
        if (k2 == tln) {
          match_tl = tl2;
          break;
        }
      }
      tl2 = tl2 + 1;
    }
    if (match_tl >= 0) {
      unsafe {
        init_ref2 = pipeline_module_top_level_let_init_ref(m, match_tl);
        type_ref2 = pipeline_module_top_level_let_type_ref(m, match_tl);
      }
      if (init_ref2 > 0 && init_ref2 <= nexprs && type_ref2 > 0) {
        unsafe {
          ik2 = pipeline_expr_kind_ord_at(a, init_ref2);
          tk2 = pipeline_type_kind_ord_at(a, type_ref2);
          ne2 = pipeline_expr_array_lit_num_elems_at(a, init_ref2);
        }
        if (pipe_modlet_cell_is_array(csz_raw) != 0 && ik2 == 46 && tk2 == 10 && ne2 > 0) {
          pool_bytes = pipe_modlet_array_lit_string_pool_bytes(a, init_ref2);
          if (pool_bytes >= 0) {
            unsafe {
              data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx);
            }
            if (data_len_now < 0) {
              data_len_now = 0;
            }
            pad = 0;
            if (calign > 1) {
              pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
            }
            if (data_len_now + pad + csz2 + pool_bytes <= 65536) {
              use_data = 1;
            }
          }
        } else {
          if (pipe_modlet_cell_is_array(csz_raw) == 0 && (tk2 == 9 || tk2 == 18)) {
            if (pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref2) != 0) {
              unsafe {
                data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx);
              }
              if (data_len_now < 0) {
                data_len_now = 0;
              }
              pad = 0;
              if (calign > 1) {
                pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
              }
              if (data_len_now + pad + csz2 <= 65536) {
                use_data = 1;
              }
            }
          }
          // wave344: non-zero scalar imm (ordinals / home_off=-1) → .data.
          // Library Cap thins never run seed_nonzero hoist; COMMON stays 0
          // and poisons kind tables (check_expr XT001). Zero imm stays COMMON.
          // PLATFORM: SHARED library-TU .data knife · LINUX gold · MACOS.
          if (use_data == 0 && pipe_modlet_cell_is_array(csz_raw) == 0) {
            let imm_d: i32 = 0;
            imm_d = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i));
            if (imm_d != 0) {
              unsafe {
                data_len_now = pipeline_elf_ctx_emit_data_len(elf_ctx);
              }
              if (data_len_now < 0) {
                data_len_now = 0;
              }
              pad = 0;
              if (calign > 1) {
                pad = (calign - (data_len_now & (calign - 1))) & (calign - 1);
              }
              if (data_len_now + pad + csz2 <= 65536) {
                use_data = 1;
              }
            }
          }
        }
      }
    }
    if (use_data != 0) {
      if (pad > 0) {
        unsafe {
          rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, pad);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      unsafe {
        data_off = pipeline_elf_ctx_emit_data_len(elf_ctx);
        pipeline_elf_ctx_set_shndx_override(elf_ctx, 4);
        rc = pipeline_elf_ctx_add_label(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, data_off);
      }
      if (rc != 0) {
        unsafe {
          pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
        }
        return 0 - 1;
      }
      unsafe {
        rc = pipeline_elf_ctx_add_sym(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, data_off);
      }
      if (rc != 0) {
        unsafe {
          pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
        }
        return 0 - 1;
      }
      unsafe {
        rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, csz2);
      }
      if (rc != 0) {
        unsafe {
          pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
        }
        return 0 - 1;
      }
      if (pipe_modlet_cell_is_array(csz_raw) != 0) {
        unsafe {
          et2 = pipeline_type_elem_ref_at(a, type_ref2);
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            a, elf_ctx, init_ref2, et2, data_off, 0, csz2, m);
          pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
        }
      } else {
        // Ptr-addr bake OR wave344 scalar non-zero imm poke.
        // bake_ptr_addr returns 1 = not-an-address (must not trip -1).
        // PLATFORM: SHARED library-TU .data.
        let pa_b: i32 = 0;
        let imm_b: i32 = 0;
        if (init_ref2 > 0) {
          pa_b = pipe_modlet_scalar_init_is_ptr_addr(a, m, init_ref2);
        }
        if (pa_b != 0) {
          unsafe {
            rc = pipe_modlet_bake_ptr_addr_elem_to_data(
              a, elf_ctx, m, init_ref2, 8, data_off);
            pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
          }
        } else {
          imm_b = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i));
          unsafe {
            rc = pipe_modlet_bake_scalar_imm_to_data(elf_ctx, data_off, imm_b, csz2);
            pipeline_elf_ctx_set_shndx_override(elf_ctx, 0);
          }
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
      pipe_store_i32_le(
        &g_pipeline_asm_modlet[0],
        pipe_modlet_off_cell_size(i),
        csz_raw | pipe_modlet_cell_data_bit());
    } else {
      unsafe {
        rc = pipeline_elf_ctx_add_common_sym(elf_ctx, &g_pipeline_asm_modlet[lbase2], llen2, csz2, calign);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    i = i + 1;
  }
  return 0;

}

/**
 * Find the modlet table index for a given name.
 * @param name *u8 - name bytes; null -> -1
 * @param name_len i32 - length; <=0 -> -1
 * @return i32 - >=0 index on match; -1 on miss
 * wave139 pure: was static pipeline_asm_modlet_find.
 * PLATFORM: SHARED - linear scan; cold asm emit path.
 */
function pipeline_asm_modlet_find(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0 - 1;
  }
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let nl: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i));
    if (nl == name_len) {
      let k: i32 = 0;
      let base: i32 = pipe_modlet_off_name(i);
      while (k < name_len) {
        let b: i32 = 0;
        unsafe {
          b = g_pipeline_asm_modlet[base + k] as i32;
          if (b != (name[k] as i32)) {
            break;
          }
        }
        k = k + 1;
      }
      if (k == name_len) {
        return i;
      }
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Load a shared modlet cell into rax/x0.
 * Scalar cells (cell_size==8, no array bit): LEA base into rax then load qword.
 * Array/blob cells (array bit or legacy payload!=8): LEA base into rax only
 *   (C array decay). Fixed TYPE_ARRAY module lets need the address for
 *   INDEX / `&arr[0]` / call args; loading the first qword is wrong.
 *
 * G.7 root fix (fmt pure-asm format residual): LEA must target rax/x0, NOT
 * rbx/x1. cmp parks the left operand in rbx/x1; the old lea_rbx + ldr
 * clobbered it so `i >= g_modlet_n[0]` compared (&n) >= n (always true) and
 * fmt_file_list_at always returned null → driver_fmt_one_file never ran.
 * store_from_rax still uses lea_rbx (address in rbx, value in rax).
 *
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - modlet name
 * @param name_len i32 - length
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 miss/null/bad arch
 * wave139 pure: G.7 authority (was static load_to_rax_elf_c).
 * Stage 12.0.5: array bit30 on cell_size so u8[8] (e.g. g_labi_icc_oopt_buf)
 *   is LEA-only; prior payload!=8 heuristic collided with scalar 8-byte cells
 *   → pure-asm hybrid SEGV on invoke_cc_list head_flags strb [null].
 * Cap residual: append_bytes for arm64 ldr x0,[x0] / x86 movq (%rax),%rax.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if ((ta != 0 && ta != 1) || elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let idx: i32 = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (pipeline_asm_modlet_lea_rax_arch(elf_ctx, idx, ta) != 0) {
    return 0 - 1;
  }
  // Array/blob COMMON: address already in rax (C array decay), do not load payload.
  // G.7: bit30 marks TYPE_ARRAY (incl. payload==8); legacy unflagged N!=8 still LEA.
  let csz: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx));
  if (pipe_modlet_cell_is_array(csz) != 0) {
    return 0;
  }
  if (ta == 1) {
    // ldr x0, [x0] = 0xf9400000
    let ldr4: u8[4] = [];
    ldr4[0] = 0x00 as u8;
    ldr4[1] = 0x00 as u8;
    ldr4[2] = 0x40 as u8;
    ldr4[3] = 0xf9 as u8;
    let rc: i32 = 0;
    unsafe {
      rc = pipeline_elf_ctx_append_bytes(elf_ctx, &ldr4[0], 4);
    }
    return rc;
  }
  // movq (%rax), %rax = 48 8b 00
  let mov3: u8[3] = [];
  mov3[0] = 0x48 as u8;
  mov3[1] = 0x8b as u8;
  mov3[2] = 0x00 as u8;
  let rc2: i32 = 0;
  unsafe {
    rc2 = pipeline_elf_ctx_append_bytes(elf_ctx, &mov3[0], 3);
  }
  return rc2;
}

/**
 * Reset the modlet table to empty (n=0).
 * @return void
 * wave139 pure: was static pipeline_asm_modlet_reset in modlet.c.
 * PLATFORM: SHARED - O(1); called once per mega emit.
 */
function pipeline_asm_modlet_reset(): void {
  pipe_modlet_set_n(0);
  g_pipe_modlet_strpool_seq = 0;
}

/**
 * Store rax/x0 into a shared modlet cell.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - modlet name
 * @param name_len i32 - length
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 miss/null/bad arch
 * wave139 pure: G.7 authority (was static store_from_rax_elf_c).
 * Cap residual: backend_enc_store_rax_to_rbx_indirect_arch (sz=8).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  if ((ta != 0 && ta != 1) || elf_ctx == 0 as *u8) {
    return 0 - 1;
  }
  let idx: i32 = pipeline_asm_modlet_find(name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) != 0) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, 8, ta);
  }
  return rc;
}

/**
 * Seed COMMON cells once on hoist-target entry.
 * Scalar cells: non-zero init_imm (historic wave139).
 * TYPE_ARRAY ARRAY_LIT cells: prepare emits zero BSS; write LIT elems
 * into COMMON so dest-SLICE / INDEX LEA sees the source payload
 * (`let A:[2]i32=[10,32]` and `const A:[2]i32=[10,32]`). Empty
 * `u8[N]=[]` stays zero (correct).
 * Arena/module from emit ctx (no extra pointer arg).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 mov/store fail
 * wave139 pure: G.7 authority (was static seed_nonzero_inits_elf_c).
 * Cap residual: backend_enc_mov_imm64_to_rax_arch + store_from_rax +
 *   store_rax_to_rbx_offset + ARRAY_LIT readers.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32 {
  if (elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let imm: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_init_imm(i));
    if (imm != 0) {
      let rc: i32 = 0;
      unsafe {
        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      let nlen: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i));
      let nbase: i32 = pipe_modlet_off_name(i);
      if (pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &g_pipeline_asm_modlet[nbase], nlen, ta) != 0) {
        return 0 - 1;
      }
    }
    i = i + 1;
  }
  // Module TYPE_ARRAY ARRAY_LIT (const + mutable) → COMMON is BSS zero
  // until we store elems here (hoist skips all TYPE_ARRAY). dest-SLICE
  // wrap / INDEX LEAs the cell; without this seed A[0] reads 0.
  // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  let arena: *u8 = pipeline_asm_emit_ctx_arena_get();
  let mod: *u8 = pipeline_asm_emit_module_ref_c();
  if (arena != (0 as *u8) && mod != (0 as *u8)) {
    let nlets: i32 = pipe_mod_get_num_top_level_lets(mod);
    let nexprs: i32 = pipe_load_i32_le(arena, pipe_arena_off_num_exprs());
    let tl: i32 = 0;
    while (tl < nlets) {
      let nlen: i32 = 0;
      let init_ref: i32 = 0;
      let type_ref: i32 = 0;
      let ik: i32 = 0;
      let tk: i32 = 0;
      let idx: i32 = 0;
      let csz: i32 = 0;
      let et: i32 = 0;
      let rc2: i32 = 0;
      let name_buf: u8[256] = [];
      let k: i32 = 0;
      unsafe {
        nlen = pipeline_module_top_level_let_name_len(mod, tl);
      }
      if (nlen > 0 && nlen <= 255) {
        k = 0;
        while (k < nlen) {
          unsafe {
            name_buf[k] = pipeline_module_top_level_let_name_byte_at(mod, tl, k) as u8;
          }
          k = k + 1;
        }
        idx = pipeline_asm_modlet_find(&name_buf[0], nlen);
        if (idx >= 0) {
          csz = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_cell_size(idx));
          // Skip .data-backed cells: bytes already baked at prepare; stores
          // into Mach-O __DATA,__const may fault after final link.
          // PLATFORM: SHARED — library-TU .data knife.
          if (pipe_modlet_cell_is_array(csz) != 0 && pipe_modlet_cell_is_data(csz) == 0) {
            unsafe {
              init_ref = pipeline_module_top_level_let_init_ref(mod, tl);
              type_ref = pipeline_module_top_level_let_type_ref(mod, tl);
            }
            if (init_ref > 0 && init_ref <= nexprs && type_ref > 0) {
              unsafe {
                ik = pipeline_expr_kind_ord_at(arena, init_ref);
                tk = pipeline_type_kind_ord_at(arena, type_ref);
              }
              if (ik == 46 && tk == 10) {
                unsafe {
                  et = pipeline_type_elem_ref_at(arena, type_ref);
                }
                if (pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta) == 0) {
                  rc2 = pipe_modlet_seed_array_lit_elems_to_rbx(
                    arena, elf_ctx, init_ref, et, ta, 0, mod);
                  if (rc2 != 0) {
                    return rc2;
                  }
                }
              }
            }
          }
        }
      }
      tl = tl + 1;
    }
  }
  return 0;
}

/**
 * 9.6.3 pure: does this module already declare a top-level let/const with the
 * exact given name? Registration-side duplicate guard for the top-level-let
 * parse authority (P012 kind=2): two module-level bindings with one name used
 * to compile silently with the second registration winning.
 * @param m *u8 — Module*; null → 0
 * @param name *u8 — binding-name bytes (not NUL-terminated)
 * @param name_len i32 — name length; <= 0 → 0
 * @return i32 — 1 = name already declared, 0 = no
 * PLATFORM: SHARED — sole provider after top_level leave; seed twin in
 * runtime_pipeline_abi.from_x.c must stay in step.
 */
#[no_mangle]
export function asm_module_top_level_let_name_exists(m: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
      return 0;
    }
    let ntl: i32 = pipe_mod_get_num_top_level_lets(m);
    let tl: i32 = 0;
    while (tl < ntl) {
      let nl: i32 = pipeline_module_top_level_let_name_len(m, tl);
      if (nl == name_len && nl > 0) {
        let k: i32 = 0;
        while (k < name_len) {
          if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != (name[k] as i32)) {
            break;
          }
          k = k + 1;
        }
        if (k == name_len) {
          return 1;
        }
      }
      tl = tl + 1;
    }
    return 0;
  }
}

/**
 * Emit lea rbx, [rip+disp32] for a modlet COMMON cell (x86_64).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * wave139 pure: was static lea_rbx_rip_x86.
 * PLATFORM: LINUX|UBUNTU x86_64 — R_X86_64_PC32 to SHN_COMMON BSS.
 */
function pipeline_asm_modlet_lea_rbx_rip_x86(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx));
  let lbase: i32 = pipe_modlet_off_label(idx);
  let lea7: u8[7] = [];
  lea7[0] = 0x48 as u8;
  lea7[1] = 0x8d as u8;
  lea7[2] = 0x1d as u8;
  lea7[3] = 0 as u8;
  lea7[4] = 0 as u8;
  lea7[5] = 0 as u8;
  lea7[6] = 0 as u8;
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &lea7[0], 7);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let rel32_at: i32 = 0;
  unsafe {
    rel32_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, &g_pipeline_asm_modlet[lbase], llen);
  }
  return rc;
}

/**
 * Emit lea rax, [rip+disp32] for a modlet COMMON cell (x86_64).
 * Used by load_to_rax so value loads do not clobber cmp's parked left in rbx.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * PLATFORM: LINUX|UBUNTU x86_64 — R_X86_64_PC32 to SHN_COMMON BSS.
 */
function pipeline_asm_modlet_lea_rax_rip_x86(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx));
  let lbase: i32 = pipe_modlet_off_label(idx);
  // REX.W LEA rax, [rip+disp32] = 48 8d 05 disp32
  let lea7: u8[7] = [];
  lea7[0] = 0x48 as u8;
  lea7[1] = 0x8d as u8;
  lea7[2] = 0x05 as u8;
  lea7[3] = 0 as u8;
  lea7[4] = 0 as u8;
  lea7[5] = 0 as u8;
  lea7[6] = 0 as u8;
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &lea7[0], 7);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let rel32_at: i32 = 0;
  unsafe {
    rel32_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc(elf_ctx, rel32_at, &g_pipeline_asm_modlet[lbase], llen);
  }
  return rc;
}

/**
 * Emit adrp x1 + add x1,pageoff for a modlet COMMON cell (arm64).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * wave139 pure: was static lea_rbx_adrp_arm64.
 * PLATFORM: MACOS|ARM64 — ARM64_RELOC_PAGE21 + PAGEOFF12.
 */
function pipeline_asm_modlet_lea_rbx_adrp_arm64(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx));
  let lbase: i32 = pipe_modlet_off_label(idx);
  let adrp4: u8[4] = [];
  adrp4[0] = 0x01 as u8;
  adrp4[1] = 0x00 as u8;
  adrp4[2] = 0x00 as u8;
  adrp4[3] = 0x90 as u8;
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &adrp4[0], 4);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let adrp_at: i32 = 0;
  unsafe {
    adrp_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, adrp_at, &g_pipeline_asm_modlet[lbase], llen, 3, 1);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add4: u8[4] = [];
  add4[0] = 0x21 as u8;
  add4[1] = 0x00 as u8;
  add4[2] = 0x00 as u8;
  add4[3] = 0x91 as u8;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &add4[0], 4);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add_at: i32 = 0;
  unsafe {
    add_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, add_at, &g_pipeline_asm_modlet[lbase], llen, 4, 0);
  }
  return rc;
}

/**
 * Emit adrp x0 + add x0,pageoff for a modlet COMMON cell (arm64).
 * Used by load_to_rax so value loads do not clobber cmp's parked left in x1.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @return i32 - 0 ok; -1 on failure
 * PLATFORM: MACOS|ARM64 — ARM64_RELOC_PAGE21 + PAGEOFF12.
 */
function pipeline_asm_modlet_lea_rax_adrp_arm64(elf_ctx: *u8, idx: i32): i32 {
  let n: i32 = pipe_modlet_get_n();
  if (elf_ctx == 0 as *u8 || idx < 0 || idx >= n) {
    return 0 - 1;
  }
  let llen: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx));
  let lbase: i32 = pipe_modlet_off_label(idx);
  // adrp x0, #0 → 0x90000000
  let adrp4: u8[4] = [];
  adrp4[0] = 0x00 as u8;
  adrp4[1] = 0x00 as u8;
  adrp4[2] = 0x00 as u8;
  adrp4[3] = 0x90 as u8;
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &adrp4[0], 4);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let adrp_at: i32 = 0;
  unsafe {
    adrp_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, adrp_at, &g_pipeline_asm_modlet[lbase], llen, 3, 1);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // add x0, x0, #0 → 0x91000000
  let add4: u8[4] = [];
  add4[0] = 0x00 as u8;
  add4[1] = 0x00 as u8;
  add4[2] = 0x00 as u8;
  add4[3] = 0x91 as u8;
  unsafe {
    rc = pipeline_elf_ctx_append_bytes(elf_ctx, &add4[0], 4);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let add_at: i32 = 0;
  unsafe {
    add_at = pipeline_elf_ctx_emit_code_len(elf_ctx) - 4;
    rc = pipeline_elf_ctx_append_reloc_typed(elf_ctx, add_at, &g_pipeline_asm_modlet[lbase], llen, 4, 0);
  }
  return rc;
}

/**
 * Dispatch lea rbx/x1 to modlet COMMON cell by target arch.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 ok; -1 unsupported or encoder fail
 * wave139 pure: was static lea_rbx_arch.
 * PLATFORM: SHARED.
 */
function pipeline_asm_modlet_lea_rbx_arch(elf_ctx: *u8, idx: i32, ta: i32): i32 {
  if (ta == 1) {
    return pipeline_asm_modlet_lea_rbx_adrp_arm64(elf_ctx, idx);
  }
  if (ta == 0) {
    return pipeline_asm_modlet_lea_rbx_rip_x86(elf_ctx, idx);
  }
  return 0 - 1;
}

/**
 * Dispatch lea rax/x0 to modlet COMMON cell by target arch.
 * Value-load path only — must not touch rbx/x1 (cmp parks left there).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param idx i32 - table index
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 ok; -1 unsupported or encoder fail
 * PLATFORM: SHARED.
 */
function pipeline_asm_modlet_lea_rax_arch(elf_ctx: *u8, idx: i32, ta: i32): i32 {
  if (ta == 1) {
    return pipeline_asm_modlet_lea_rax_adrp_arm64(elf_ctx, idx);
  }
  if (ta == 0) {
    return pipeline_asm_modlet_lea_rax_rip_x86(elf_ctx, idx);
  }
  return 0 - 1;
}

/**
 * LEA a same-module function's link symbol into rax/x0.
 * 9.4.2 single authority for the Cap-fn-ptr symbol spell (was inlined in
 * pipeline_asm_emit_as_elf_impl, the VAR fast face, and their twins):
 * source-level name; Mach-O leading '_' on Darwin, bare ELF symbol on
 * Linux. Callers must have confirmed the name resolves to a same-module
 * function (glue_module_func_index_by_name_c >= 0); this face re-checks
 * bounds only. Spelling is pipe_modlet_fn_sym_spell_into.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param name *u8 - source-level function name
 * @param name_len i32 - name length (1..255)
 * @param ta i32 - target arch (0=x86_64 1=arm64)
 * @return i32 - 0 ok; -1 bad args / encode fail
 * Exported for the first-wins fnptr_as thin (same spell, one authority).
 * PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare name.
 */
#[no_mangle]
export function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  let sym: u8[130] = [];
  let len: i32 = 0;
  let rc: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255 || (ta != 0 && ta != 1)) {
    return 0 - 1;
  }
  len = pipe_modlet_fn_sym_spell_into(elf_ctx, name, name_len, &sym[0]);
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_lea_sym_to_reg_arch(elf_ctx, 0, &sym[0], len, ta);
  }
  return rc;
}

/**
 * LEA a non-local named binding's ADDRESS into rax/x0 (9.4.2).
 * Module-let COMMON cell first (pipeline_asm_modlet_lea_rax_arch — the
 * same home the generic VAR emit reads, array bit30 included), then the
 * same-module function link symbol. Returns -1 when the name is neither:
 * callers loud-fail (ADDR_OF keeps -99; lvalue keeps -1).
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param m *u8 - Module* (fn lookup; null skips the fn branch)
 * @param name *u8 - source-level name
 * @param name_len i32 - name length (1..255)
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 not a modlet cell / not a same-module fn
 * Exported: the FROM_X seed rest lvalue fallback (Ubuntu hybrid) resolves
 * this WEAK mega face; the cold student uses the _cold static twin.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx: *u8, m: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  let idx: i32 = 0;
  let fi: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255 || (ta != 0 && ta != 1)) {
    return 0 - 1;
  }
  idx = pipeline_asm_modlet_find(name, name_len);
  if (idx >= 0) {
    return pipeline_asm_modlet_lea_rax_arch(elf_ctx, idx, ta);
  }
  if (m != (0 as *u8)) {
    unsafe {
      fi = glue_module_func_index_by_name_c(m, name, name_len);
    }
    if (fi >= 0) {
      return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, name, name_len, ta);
    }
  }
  return 0 - 1;
}

/**
 * Lookup or create arena sidecar for pointer key.
 * @param key *u8 — arena/module/onefunc key; null -> null
 * @param create i32 — non-zero to allocate free slot + init GrowVecs
 * @return *u8 — sidecar base or null
 * wave275 pure-owned leave; G.7 single process table.
 * P2 Darwin -o: 2-slot MRU before the MAX=512 linear walk.
 * PLATFORM: SHARED freestanding arena Cap leave.
 */
#[no_mangle]
export function arena_sidecar_get(key: *u8, create: i32): *u8 {
  if (key == 0 as *u8) {
    return 0 as *u8;
  }
  let hit: *u8 = pipe_arena_sc_recall(key);
  if (hit != 0 as *u8) {
    return hit;
  }
  let i: i32 = 0;
  while (i < pipe_arena_sc_max()) {
    let sc: *u8 = pipe_arena_sc_at(i);
    let used: i32 = pipe_load_i32_le(sc, 8);
    if (used != 0) {
      let k: *u8 = pipe_load_ptr_slot(sc, 0);
      if (k == key) {
        pipe_arena_sc_remember(key, sc);
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_arena_sc_max()) {
    let sc2: *u8 = pipe_arena_sc_at(i);
    let used2: i32 = pipe_load_i32_le(sc2, 8);
    if (used2 == 0) {
      pipe_store_ptr_slot(sc2, 0, key);
      pipe_store_i32_le(sc2, 8, 1);
      let ic: i32 = pipe_gv_init_cap();
      if (grow_vec_init(sc2 + (16 as usize), 532, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (48 as usize), 1224, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (80 as usize), 92, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (112 as usize), 324, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (144 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (176 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (208 as usize), 12, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (240 as usize), 268, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (272 as usize), 8, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (304 as usize), 16, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (336 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      /* Cap 4.2.8 sync: W277_LabeledStmt is 528 (label[256]+goto_target[256]);
       * the stale 272 (128-era) stride made the 2nd+ labeled stmt's 528-byte
       * write smash the neighboring slot — same class as the onefunc region
       * stride fix (2026-09-13). */
      if (grow_vec_init(sc2 + (368 as usize), 528, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (400 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (432 as usize), 8, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (464 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (496 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (528 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (560 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (592 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (624 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (656 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (688 as usize), 24, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (720 as usize), 264, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (752 as usize), 4, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(sc2 + (784 as usize), 264, ic) == 0) {
        pipe_arena_sc_free(sc2);
        return 0 as *u8;
      }
      pipe_arena_sc_remember(key, sc2);
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Formal/let element force_esz for ARRAY_LIT durable/stack pack.
 * @param arena *u8 - ASTArena*
 * @param et i32 - element type_ref
 * @return i32 - force_esz (0 = lit-infer)
 * wave143 pure: G.7 authority (was static glue_array_lit_force_esz_from_elem_type_c).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
#[no_mangle]
export function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32 {
  /* wave496: G.7 ≡ fnptr_array_esz_thin — no-local tipU heal (pipe cells). */
  let ek: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let cell_i: u8[8];
  let cell_m: u8[8];
  if (arena == (0 as *u8) || et <= 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell_i[0], 0, pipeline_type_kind_ord_at(arena, et));
  }
  ek = pipe_load_i32_le(&cell_i[0], 0);
  if (ek == 2 || ek == 1) {
    return 1;
  }
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14) {
    return 4;
  }
  /*
   * 10.3.1 slice13: TYPE_FN=18 shares Cap opaque fn-ptr ABI with TYPE_PTR=9 —
   * array-lit elem store/INDEX stride must be 8B. Prior miss → return 0 →
   * callers force_esz=4 → `mov %eax` truncates LEA; INDEX 8B load reads
   * garbage → SEGV on Cap blr. G.7 ≡ glue_type_size_simple kind 18.
   * PLATFORM: SHARED freestanding.
   */
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9 || ek == 18) {
    return 8;
  }
  if (ek == 8) {
    unsafe {
      pipe_store_ptr_slot(&cell_m[0], 0, pipeline_asm_emit_module_ref_c());
    }
    mod = pipe_load_ptr_slot(&cell_m[0], 0);
    if (mod != (0 as *u8)) {
      unsafe {
        pipe_store_i32_le(&cell_i[0], 0, glue_type_size_simple(mod, arena, et, 0));
      }
      ssz = pipe_load_i32_le(&cell_i[0], 0);
      if (ssz > 0) {
        return ssz;
      }
    }
  }
  // TYPE_ARRAY=10: row stride = sizeof([N]T). `[][2]i32` must not fall through
  // to 0 — durable would then store each nested ARRAY_LIT as a pointer (8B)
  // and INDEX x[i][j] would read pointer bits. Reuse fixed-array total bytes.
  // PLATFORM: SHARED freestanding.
  if (ek == 10) {
    unsafe {
      pipe_store_i32_le(&cell_i[0], 0, glue_fixed_array_total_bytes_c(arena, et, 0));
    }
    ssz = pipe_load_i32_le(&cell_i[0], 0);
    if (ssz > 0) {
      return ssz;
    }
  }
  if (ek == 11) {
    return 16;
  }
  return 0;
}

/**
 * Total payload bytes of a fixed TYPE_ARRAY, recursive for multi-dim
 * (`[2][3]i32` → 24). Element TYPE_PTR=9 / TYPE_FN=18 is pointer width 8
 * (`*i32[2]` → 16; `[2]function(i32):i32` → 16). G.7 complete of the
 * 10.3.1 TYPE_FN 8B ABI (force_esz already had kind 18; this size face
 * missed it and baked `[2]TYPE_FN` as 8 bytes → span overflow CG002).
 * @param arena *u8 - ASTArena*; null → 0
 * @param ty_ref i32 - type pool ref; must be TYPE_ARRAY (ord 10)
 * @param depth i32 - recursion depth; depth > 8 → 0 (cycle/depth guard)
 * @return i32 - n * elem_bytes; 0 on non-array / bad depth / bad size
 * wave180 pure-owned G.7 authority (was Cap residual index_helpers).
 * PLATFORM: SHARED freestanding layout · LINUX gold.
 */
#[no_mangle]
export function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32 {
  let n: i32 = 0;
  let elem: i32 = 0;
  let ek: i32 = 0;
  let esz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || ty_ref <= 0 || depth > 8) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, ty_ref);
  }
  if (ek != 10) {
    return 0;
  }
  unsafe {
    n = pipeline_type_array_size_at(arena, ty_ref);
    elem = pipeline_type_elem_ref_at(arena, ty_ref);
  }
  if (n <= 0 || elem <= 0) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, elem);
  }
  if (ek == 10) {
    esz = glue_fixed_array_total_bytes_c(arena, elem, depth + 1);
    if (esz <= 0) {
      return 0;
    }
    return n * esz;
  }
  if (ek == 2 || ek == 1) {
    esz = 1;
  } else if (ek == 0 || ek == 3 || ek == 13 || ek == 14) {
    esz = 4;
  } else if (ek == 15 || ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 9 || ek == 18) {
    // TYPE_FN=18 is Cap opaque fn-ptr ABI (8B), twin of force_esz / seed C.
    esz = 8;
  } else if (ek == 8) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
    if (mod != (0 as *u8)) {
      esz = glue_type_size_simple(mod, arena, elem, 0);
      if (esz <= 0) {
        esz = 8;
      }
    } else {
      esz = 4;
    }
  } else if (ek == 11) {
    // TYPE_SLICE fat row: [N][]T stride is 16, not the 4B scalar default.
    // PLATFORM: SHARED freestanding.
    esz = 16;
  } else {
    esz = 4;
  }
  return n * esz;
}

/**
 * Module function index by name; -1 not found.
 * @param mod *u8 - Module*
 * @param name *u8 - name bytes
 * @param name_len i32 - length
 * @return i32 - func index or -1
 * wave148 pure: G.7 authority (was static glue_module_func_index_by_name_c).
 * PLATFORM: SHARED — Cap residual: typeck_check_expr / typeck_ctfe / fold_count_up_while.
 */
#[no_mangle]
export function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32 {
  let fi: i32 = 0;
  let flen: i32 = 0;
  let nfuncs: i32 = 0;
  let k: i32 = 0;
  if (mod == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  unsafe {
    nfuncs = pipeline_module_num_funcs(mod);
  }
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      flen = pipeline_module_func_name_len_at(mod, fi);
    }
    if (flen == name_len) {
      unsafe {
        pipeline_module_func_name_copy64(mod, fi, &g_wave148_fb[0]);
      }
      k = 0;
      while (k < name_len) {
        if (g_wave148_fb[k] != name[k]) {
          break;
        }
        k = k + 1;
      }
      if (k == name_len) {
        return fi;
      }
    }
    fi = fi + 1;
  }
  return 0 - 1;
}

/**
 * Compare module struct layout name at index k to name[0..nlen).
 * @return i32 - 1 equal; 0 otherwise
 * wave154 pure helper. PLATFORM: SHARED.
 */
function glue_struct_layout_name_eq_c(m: *u8, k: i32, name: *u8, nlen: i32): i32 {
  let ln: i32 = 0;
  let j: i32 = 0;
  let b: i32 = 0;
  if (m == (0 as *u8) || name == (0 as *u8) || nlen <= 0) {
    return 0;
  }
  unsafe {
    ln = pipeline_module_struct_layout_name_len(m, k);
  }
  if (ln != nlen) {
    return 0;
  }
  j = 0;
  while (j < nlen) {
    unsafe {
      b = pipeline_module_struct_layout_name_byte_at(m, k, j);
    }
    if (b != (name[j] as i32)) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

/**
 * Byte size of a type (C twin of typeck.x typeck_x_type_size).
 * @param m *u8 - Module* (may be null for scalar-only)
 * @param a *u8 - ASTArena*
 * @param ty_ref i32 - type ref
 * @param depth i32 - recursion depth (cap 64)
 * @return i32 - byte size; 0 on miss/invalid
 * wave154 pure: G.7 authority (was glue_type_size_simple in struct_lit.c).
 * Cap residual: typeck_soa_array_storage_size_glue / typeck_x_type_size_from_layout_glue
 *   + dep pipe for cross-module TYPE_NAMED.
 * PLATFORM: SHARED — f32(14)=4; slice=16; dep-arena field sizing.
 * SIMD named spelling (i32x4 / Vec4f / i32x8) has no struct layout — miss
 * used to return 4 (one lane). That classified the 16B INTEGER / 32B MEMORY
 * ABI as a scalar GP (idv callee stored only x0; c[2] leftover). G.7: reuse
 * glue_vector_type_lanes_esz_c (lanes*esz). Do not add an i32x4 name table.
 */
#[no_mangle]
export function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32 {
  let kind_ord: i32 = 0;
  let nt: i32 = 0;
  let elem_ref: i32 = 0;
  let asz: i32 = 0;
  let es: i32 = 0;
  let soa_sz: i32 = 0;
  let vl: i32 = 0;
  let ves: i32 = 0;
  let name: u8[256] = [];
  let nlen: i32 = 0;
  let k: i32 = 0;
  let nlayouts: i32 = 0;
  let di: i32 = 0;
  let nd: i32 = 0;
  let dm: *u8 = 0 as *u8;
  let da: *u8 = 0 as *u8;
  let dep: *u8 = 0 as *u8;
  let sz: i32 = 0;
  if (a == (0 as *u8) || ty_ref <= 0 || depth > 64) {
    return 0;
  }
  unsafe {
    nt = pipeline_arena_num_types(a);
  }
  if (ty_ref > nt) {
    return 0;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  }
  // UNIT=16
  if (kind_ord == 16) {
    return 0;
  }
  // bool=2
  if (kind_ord == 2) {
    return 1;
  }
  // i32=0 u32=3 bool-like u8=1 f32=14 → 4
  // TYPE_VECTOR=13 is NOT scalar — handled with ARRAY below (lanes * esz).
  // Stage12 soft residual (2026-08-13): old `|| kind_ord == 13` made Vec4f size=4
  // → call pack 1 GP + formal gcc SSE xmm0/xmm1 SEGV (mask ptr never in rdi).
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 1 || kind_ord == 14) {
    return 4;
  }
  // i64/u64/usize/isize/ptr/f64/TYPE_FN: 5,4,6,7,15,9,18 → 8
  // 10.3.3: TYPE_FN is opaque Cap-fn-ptr ABI (pointer-sized), not scalar miss→0.
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15
      || kind_ord == 9 || kind_ord == 18) {
    return 8;
  }
  // SLICE=11 → 16
  if (kind_ord == 11) {
    return 16;
  }
  // ARRAY=10 LINEAR=12 TYPE_VECTOR=13 → N * elem_size (SIMD lanes via array_size)
  if (kind_ord == 10 || kind_ord == 12 || kind_ord == 13) {
    unsafe {
      elem_ref = pipeline_type_elem_ref_at(a, ty_ref);
      asz = pipeline_type_array_size_at(a, ty_ref);
    }
    if (elem_ref <= 0 || asz <= 0) {
      /* TYPE_VECTOR without array_size: still SIMD. lanes*esz, not 0→8B floor. */
      if (kind_ord == 13) {
        if (glue_vector_type_lanes_esz_c(a, ty_ref, &vl, &ves) == 0 && vl > 0 && ves > 0) {
          return vl * ves;
        }
      }
      return 0;
    }
    // SoA only for fixed ARRAY (not SIMD VECTOR).
    if (kind_ord == 10 || kind_ord == 12) {
      unsafe {
        soa_sz = typeck_soa_array_storage_size_glue(m, a, elem_ref, asz, depth + 1);
      }
      if (soa_sz > 0) {
        return soa_sz;
      }
    }
    es = glue_type_size_simple(m, a, elem_ref, depth + 1);
    if (es > 0) {
      return asz * es;
    }
    return 0;
  }
  // TYPE_NAMED=8
  if (kind_ord == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(a, ty_ref, &name[0]);
    }
    if (nlen <= 0 || nlen > 255) {
      return 4;
    }
    if (m != (0 as *u8)) {
      unsafe {
        nlayouts = pipeline_module_num_struct_layouts_at(m);
      }
      k = 0;
      while (k < nlayouts) {
        if (glue_struct_layout_name_eq_c(m, k, &name[0], nlen) != 0) {
          unsafe {
            return typeck_x_type_size_from_layout_glue(m, a, k, depth + 1);
          }
        }
        k = k + 1;
      }
    }
    // Dep exact-name layout (field type_refs are dep-arena indices)
    unsafe {
      dep = pipeline_asm_emit_dep_pipe_c();
    }
    if (dep != (0 as *u8)) {
      unsafe {
        nd = pipeline_dep_ctx_ndep(dep);
      }
      di = 0;
      while (di < nd) {
        unsafe {
          dm = pipeline_dep_ctx_module_at(dep, di);
          da = pipeline_dep_ctx_arena_at(dep, di);
        }
        if (dm != (0 as *u8) && da != (0 as *u8)) {
          unsafe {
            nlayouts = pipeline_module_num_struct_layouts_at(dm);
          }
          k = 0;
          while (k < nlayouts) {
            if (glue_struct_layout_name_eq_c(dm, k, &name[0], nlen) != 0) {
              unsafe {
                sz = typeck_x_type_size_from_layout_glue(dm, da, k, depth + 1);
              }
              if (sz > 0) {
                return sz;
              }
            }
            k = k + 1;
          }
        }
        di = di + 1;
      }
    }
    /* No struct layout: SIMD named spelling is lanes*esz (16B dual-GP /
     * 32B sret), not the 4B scalar miss. Non-SIMD named stay 4. */
    if (glue_vector_type_lanes_esz_c(a, ty_ref, &vl, &ves) == 0 && vl > 0 && ves > 0) {
      return vl * ves;
    }
    return 4;
  }
  return 0;
}

/**
 * Extract lane count and element byte-width for a TYPE_VECTOR / SIMD spelling.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref
 * @param out_lanes *i32 - written lanes
 * @param out_esz *i32 - written element size
 * @return i32 - 0 ok; -1 not SIMD / null
 * wave148 pure: G.7 authority (was static glue_vector_type_lanes_esz_c).
 * PLATFORM: SHARED pure type introspection.
 */
#[no_mangle]
export function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32 {
  let lanes: i32 = 4;
  let esz: i32 = 4;
  let elem_ref: i32 = 0;
  let tk: i32 = 0;
  let nlen: i32 = 0;
  let nt: i32 = 0;
  let arr_sz: i32 = 0;
  let spell_lanes: i32 = 0;
  let spell_esz: i32 = 0;
  let rc: i32 = 0;
  let etk: i32 = 0;
  if (arena == (0 as *u8) || out_lanes == (0 as *i32) || out_esz == (0 as *i32)) {
    return 0 - 1;
  }
  unsafe {
    rc = asm_type_is_simd_vector_spelling(arena, type_ref);
  }
  if (rc == 0) {
    return 0 - 1;
  }
  unsafe {
    nt = pipeline_arena_num_types(arena);
    arr_sz = pipeline_type_array_size_at(arena, type_ref);
    tk = pipeline_type_kind_ord_at(arena, type_ref);
  }
  if (arr_sz > 0) {
    lanes = arr_sz;
  } else {
    lanes = 4;
  }
  if (tk == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(arena, type_ref, &g_wave148_tname[0]);
    }
    if (nlen > 0) {
      unsafe {
        rc = xlang_simd_vector_lanes_esz_from_spelling(&g_wave148_tname[0], nlen as usize, &spell_lanes, &spell_esz);
      }
      if (rc == 0) {
        unsafe {
          out_lanes[0] = spell_lanes;
          out_esz[0] = spell_esz;
        }
        return 0;
      }
    }
    lanes = 4;
    if (nlen == 5 && g_wave148_tname[4] == 56) {
      lanes = 8;
    }
    if (nlen == 6 && g_wave148_tname[4] == 49 && g_wave148_tname[5] == 54) {
      lanes = 16;
    }
  }
  esz = 4;
  unsafe {
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  }
  if (elem_ref > 0 && elem_ref <= nt) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ref);
    }
    if (etk == 2) {
      esz = 1;
    } else {
      if (etk == 14) {
        esz = 4;
      } else {
        if (etk == 8 || etk == 4 || etk == 5 || etk == 6) {
          esz = 8;
        }
      }
    }
  }
  unsafe {
    out_lanes[0] = lanes;
    out_esz[0] = esz;
  }
  return 0;
}

/**
 * Return pointer to element idx, or null if out of range.
 * @param v *u8 - GrowVec*
 * @param idx i32 - element index
 * @return *u8 - element address or null
 * wave271 pure-owned leave (was static grow_vec_at).
 * PLATFORM: SHARED freestanding GrowVec Cap leave.
 */
#[no_mangle]
export function grow_vec_at(v: *u8, idx: i32): *u8 {
  if (v == 0 as *u8) {
    return 0 as *u8;
  }
  let data: *u8 = pipe_gv_load_data(v);
  if (data == 0 as *u8) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  let len: i32 = pipe_gv_load_len(v);
  if (idx >= len) {
    return 0 as *u8;
  }
  let es: i64 = pipe_gv_load_elem_sz(v);
  if (es <= 0) {
    return 0 as *u8;
  }
  let off: i64 = (idx as i64) * es;
  return data + (off as usize);
}

/**
 * Free GrowVec data and reset fields (does not free the GrowVec struct itself).
 * @param v *u8 - GrowVec*; null -> no-op
 * @return void
 * wave271 pure-owned leave (was static grow_vec_free).
 * PLATFORM: SHARED freestanding GrowVec Cap leave.
 */
#[no_mangle]
export function grow_vec_free(v: *u8): void {
  if (v == 0 as *u8) {
    return;
  }
  let data: *u8 = pipe_gv_load_data(v);
  if (data != 0 as *u8) {
    let cap: i32 = pipe_gv_load_cap(v);
    let es: i64 = pipe_gv_load_elem_sz(v);
    let nbytes: i64 = (cap as i64) * es;
    let mm: i32 = pipe_gv_load_mmap(v);
    pipe_gv_dealloc_bytes(data, nbytes, mm);
    pipe_gv_store_data(v, 0 as *u8);
  }
  pipe_gv_store_cap(v, 0);
  pipe_gv_store_len(v, 0);
  pipe_gv_store_mmap(v, 0);
}

/**
 * Initialize a GrowVec with capacity initial_cap elements of size elem_sz.
 * @param v *u8 - GrowVec*; null -> 0
 * @param elem_sz i64 - element byte size; <=0 -> 0
 * @param initial_cap i32 - initial capacity; <=0 uses AST_POOL_INIT_CAP (256)
 * @return i32 - 1 success, 0 failure
 * wave271 pure-owned leave (was static grow_vec_init).
 * PLATFORM: SHARED freestanding GrowVec Cap leave.
 */
#[no_mangle]
export function grow_vec_init(v: *u8, elem_sz: i64, initial_cap: i32): i32 {
  if (v == 0 as *u8) {
    return 0;
  }
  if (elem_sz <= 0) {
    return 0;
  }
  pipe_gv_store_data(v, 0 as *u8);
  pipe_gv_store_cap(v, 0);
  pipe_gv_store_len(v, 0);
  pipe_gv_store_elem_sz(v, elem_sz);
  pipe_gv_store_mmap(v, 0);
  let ic: i32 = initial_cap;
  if (ic <= 0) {
    ic = pipe_gv_init_cap();
  }
  let nbytes: i64 = (ic as i64) * elem_sz;
  let mm: i32 = 0;
  let p: *u8 = pipe_gv_alloc_bytes(nbytes, &mm);
  if (p == 0 as *u8) {
    return 0;
  }
  pipe_gv_store_data(v, p);
  pipe_gv_store_mmap(v, mm);
  pipe_gv_store_cap(v, ic);
  return 1;
}

/**
 * Load i32 little-endian from base+off.
 * @param base *u8
 * @param off i32
 * @return i32
 * PLATFORM: SHARED.
 */
function pipe_ar_load_i32(base: *u8, off: i32): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  let b0: i32 = 0;
  let b1: i32 = 0;
  let b2: i32 = 0;
  let b3: i32 = 0;
  unsafe {
    b0 = base[off] as i32;
    b1 = base[off + 1] as i32;
    b2 = base[off + 2] as i32;
    b3 = base[off + 3] as i32;
  }
  return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

/**
 * LP64 offsetof(struct ast_ASTArena, num_exprs).
 * Layout: num_types@0 num_exprs@4.
 * @return i32 - 4
 * PLATFORM: SHARED LP64.
 */
function pipe_arena_off_num_exprs(): i32 {
  return 4;
}

/**
 * Pointer to ArenaSidecar slot i (0..511).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null if i out of range
 * PLATFORM: SHARED freestanding arena sidecar table.
 */
function pipe_arena_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_arena_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_arena_sc_size() as i64);
  return &g_pipe_arena_sc_blob[0] + (off as usize);
}

/**
 * Drop arena last-hit slots that point at `sc` (called from free).
 * @param sc *u8 — sidecar being freed
 */
function pipe_arena_sc_drop_last(sc: *u8): void {
  if (g_pipe_arena_sc_last_sc0 == sc) {
    g_pipe_arena_sc_last_key0 = 0 as *u8;
    g_pipe_arena_sc_last_sc0 = 0 as *u8;
  }
  if (g_pipe_arena_sc_last_sc1 == sc) {
    g_pipe_arena_sc_last_key1 = 0 as *u8;
    g_pipe_arena_sc_last_sc1 = 0 as *u8;
  }
}

function pipe_arena_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  pipe_arena_sc_drop_last(sc);
  grow_vec_free(sc + (16 as usize));
  grow_vec_free(sc + (48 as usize));
  grow_vec_free(sc + (80 as usize));
  grow_vec_free(sc + (112 as usize));
  grow_vec_free(sc + (144 as usize));
  grow_vec_free(sc + (176 as usize));
  grow_vec_free(sc + (208 as usize));
  grow_vec_free(sc + (240 as usize));
  grow_vec_free(sc + (272 as usize));
  grow_vec_free(sc + (304 as usize));
  grow_vec_free(sc + (336 as usize));
  grow_vec_free(sc + (368 as usize));
  grow_vec_free(sc + (400 as usize));
  grow_vec_free(sc + (432 as usize));
  grow_vec_free(sc + (464 as usize));
  grow_vec_free(sc + (496 as usize));
  grow_vec_free(sc + (528 as usize));
  grow_vec_free(sc + (560 as usize));
  grow_vec_free(sc + (592 as usize));
  grow_vec_free(sc + (624 as usize));
  grow_vec_free(sc + (656 as usize));
  grow_vec_free(sc + (688 as usize));
  grow_vec_free(sc + (720 as usize));
  grow_vec_free(sc + (752 as usize));
  grow_vec_free(sc + (784 as usize));
  unsafe {
    memset(sc, 0, pipe_arena_sc_size() as usize);
  }
}

/**
 * 2-slot MRU lookup for the arena sidecar table.
 * @param key *u8 — arena pointer key
 * @return *u8 — cached sidecar or null
 */
function pipe_arena_sc_recall(key: *u8): *u8 {
  if (g_pipe_arena_sc_last_key0 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_arena_sc_last_sc0, key) != 0) {
      return g_pipe_arena_sc_last_sc0;
    }
  }
  if (g_pipe_arena_sc_last_key1 == key) {
    if (pipe_sc_last_slot_ok(g_pipe_arena_sc_last_sc1, key) != 0) {
      return g_pipe_arena_sc_last_sc1;
    }
  }
  return 0 as *u8;
}

/**
 * Remember arena sidecar as MRU slot 0; previous slot 0 shifts to 1.
 * @param key *u8 — arena pointer key
 * @param sc *u8 — sidecar base
 */
function pipe_arena_sc_remember(key: *u8, sc: *u8): void {
  if (g_pipe_arena_sc_last_key0 == key) {
    g_pipe_arena_sc_last_sc0 = sc;
    return;
  }
  g_pipe_arena_sc_last_key1 = g_pipe_arena_sc_last_key0;
  g_pipe_arena_sc_last_sc1 = g_pipe_arena_sc_last_sc0;
  g_pipe_arena_sc_last_key0 = key;
  g_pipe_arena_sc_last_sc0 = sc;
}

function pipe_arena_sc_size(): i32 { return 816; }
function pipe_arena_sc_max(): i32 { return 512; }
function pipe_module_sc_size(): i32 { return 432; }
function pipe_module_sc_max(): i32 { return 512; }
function pipe_onefunc_sc_size(): i32 { return 944; }
function pipe_onefunc_sc_max(): i32 { return 1024; }

// Flat BSS tables (zero-init; used flags start 0).
// Arena/module: 2-slot MRU (copy src/dst ping-pong). Onefunc: 16-slot ring
// + used_hi (dummy-wire live keys). Miss walk for onefunc stops at used_hi.
// PLATFORM: SHARED — Darwin/Linux product thin; leftover-PE seed twin matches.
// Onefunc 16-slot ring: slot i stores key at ptr-index 2*i and sidecar at 2*i+1
// (LP64 8-byte cells; 16*(key+sc) = 256 bytes). Clock is next insert index.
// used_hi is exclusive end of occupied process-table slots (0..MAX).
// PLATFORM: SHARED — Darwin/Linux product thin; leftover-PE seed twin matches.

/**
 * True if sidecar slot is used and its key pointer equals `key`.
 * @param sc *u8 — sidecar base; null -> 0
 * @param key *u8 — lookup key
 * @return i32 — 1 ok, 0 miss
 * PLATFORM: SHARED — 2-slot MRU helper for sidecar_get.
 */
function pipe_sc_last_slot_ok(sc: *u8, key: *u8): i32 {
  if (sc == 0 as *u8) {
    return 0;
  }
  if (pipe_load_i32_le(sc, 8) == 0) {
    return 0;
  }
  if (pipe_load_ptr_slot(sc, 0) != key) {
    return 0;
  }
  return 1;
}

/**
 * Pointer to DepCtxSidecar slot i (0..63).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null if i out of range
 * PLATFORM: SHARED freestanding DepCtx table.
 */
function pipe_dep_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_dep_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_dep_sc_size() as i64);
  return &g_pipe_dep_sc_blob[0] + (off as usize);
}

/**
 * Free all GrowVecs in a DepCtxSidecar and zero the slot.
 * @param sc *u8 - sidecar base
 * @return void
 */
function pipe_dep_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices()));
  grow_vec_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_backup()));
  unsafe {
    memset(sc, 0, pipe_dep_sc_size() as usize);
  }
}

/**
 * GrowVec* field inside a DepCtxSidecar at given byte offset.
 * @param sc *u8 - sidecar base
 * @param field_off i32 - offset of GrowVec within sidecar
 * @return *u8 - GrowVec* or null
 */
function pipe_dep_sc_gv(sc: *u8, field_off: i32): *u8 {
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  if (field_off < 0) {
    return 0 as *u8;
  }
  return sc + (field_off as usize);
}

function pipe_dep_sc_size(): i32 { return 272; }
function pipe_dep_sc_max(): i32 { return 64; }
function pipe_dep_sc_off_ctx(): i32 { return 0; }
function pipe_dep_sc_off_used(): i32 { return 8; }
function pipe_dep_sc_off_dep_modules(): i32 { return 16; }
function pipe_dep_sc_off_dep_arenas(): i32 { return 48; }
function pipe_dep_sc_off_dep_path_rows(): i32 { return 80; }
function pipe_dep_sc_off_dep_path_lens(): i32 { return 112; }
function pipe_dep_sc_off_lib_root_rows(): i32 { return 144; }
function pipe_dep_sc_off_lib_root_lens(): i32 { return 176; }
function pipe_dep_sc_off_empty_param_indices(): i32 { return 208; }
function pipe_dep_sc_off_empty_param_backup(): i32 { return 240; }

// PipelineDepCtx field offsets (LP64) — match pure pipe_pctx_off_* where present.
function pipe_pctx_off_ndep(): i32 { return 0; }
function pipe_pctx_off_path_buf(): i32 { return 524; }
function pipe_pctx_off_loaded_buf(): i32 { return 1036; }
function pipe_pctx_off_preprocess_buf(): i32 { return 4195352; }
function pipe_pctx_off_use_asm_backend(): i32 { return 8389660; }
function pipe_pctx_off_target_arch(): i32 { return 8389664; }
function pipe_pctx_off_use_macho_o(): i32 { return 8389672; }
function pipe_pctx_off_use_coff_o(): i32 { return 8389676; }
function pipe_pctx_off_current_block_ref(): i32 { return 8389680; }
function pipe_pctx_off_typeck_loop_depth(): i32 { return 8389684; }
function pipe_pctx_off_current_func_index(): i32 { return 8389688; }
function pipe_pctx_off_entry_already_parsed(): i32 { return 8389696; }
function pipe_pctx_off_current_func_empty_param_count(): i32 { return 8389704; }
function pipe_pctx_off_current_codegen_module(): i32 { return 8389720; }
function pipe_pctx_off_current_codegen_arena(): i32 { return 8389728; }
function pipe_pctx_off_current_codegen_dep_index(): i32 { return 8389736; }
function pipe_pctx_off_current_codegen_prefix_mirror(): i32 { return 8389740; }
function pipe_pctx_off_current_codegen_prefix_len(): i32 { return 8389996; }
function pipe_pctx_off_asm_entry_module_only(): i32 { return 8390000; }

/** Byte size of PipelineDepCtx (Cap 4.2.8 name mirrors [256]). PLATFORM: SHARED LP64. */
export function pipeline_sizeof_dep_ctx(): usize {
  return 8390600 as usize;
}

/**
 * Lookup or create DepCtxSidecar for PipelineDepCtx key.
 * @param ctx *u8 - PipelineDepCtx*; null -> null
 * @param create i32 - non-zero to allocate free slot + init GrowVecs
 * @return *u8 - sidecar or null
 * G.7 single process table (was residual g_xlang_depctx_sc + depctx_sidecar_get).
 * PLATFORM: SHARED freestanding DepCtx table — product matrix dual-end.
 */
function pipe_depctx_sidecar_get(ctx: *u8, create: i32): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  let i: i32 = 0;
  while (i < pipe_dep_sc_max()) {
    let sc: *u8 = pipe_dep_sc_at(i);
    let used: i32 = pipe_load_i32_le(sc, pipe_dep_sc_off_used());
    if (used != 0) {
      let k: *u8 = pipe_load_ptr_slot(sc, 0);
      if (k == ctx) {
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_dep_sc_max()) {
    let sc2: *u8 = pipe_dep_sc_at(i);
    let used2: i32 = pipe_load_i32_le(sc2, pipe_dep_sc_off_used());
    if (used2 == 0) {
      // bind key + mark used before init so partial fail can free
      pipe_store_ptr_slot(sc2, 0, ctx);
      pipe_store_i32_le(sc2, pipe_dep_sc_off_used(), 1);
      let ic: i32 = pipe_gv_init_cap();
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_modules()), 8, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_arenas()), 8, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      // path rows: 128-byte elems (wave579)
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_path_rows()), 256, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_path_lens()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      // lib_root rows: 256-byte elems
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_lib_root_rows()), 256, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_lib_root_lens()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_empty_param_indices()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (grow_vec_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_empty_param_backup()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Store i32 LE into flat u8 BSS array at element index.
 */
function pipe_elf_bss_store_i32(blob: *u8, idx: i32, v: i32): void {
  if (blob == 0 as *u8 || idx < 0) {
    return;
  }
  pipe_store_i32_le(blob, idx * 4, v);
}

/**
 * Reset COMMON object sidecar for this ctx owner.
 */
function pipe_elf_common_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_common_owner = ctx_bytes;
  unsafe {
    memset(&g_pipe_elf_sym_is_common[0], 0, 16384 as usize);
    memset(&g_pipe_elf_sym_common_size[0], 0, 65536 as usize);
    memset(&g_pipe_elf_sym_common_align[0], 0, 65536 as usize);
  }
}

/**
 * Current emit ELF section index.
 * F7: respects the shndx override (when non-zero, returns it so new
 * relocs/syms/labels are tagged as data-section).
 */
function pipe_elf_current_shndx(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return pipe_elf_shnx_text();
  }
  if (g_pipe_elf_shndx_override != 0) {
    return g_pipe_elf_shndx_override;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0) {
    if (pipe_load_i32_le(ctx, pipe_elf_off_emit_hot()) != 0) {
      return pipe_elf_shnx_hot();
    }
    return pipe_elf_shnx_unlikely();
  }
  return pipe_elf_shnx_text();
}

/**
 * Pointer to label entry i within ctx.
 */
function pipe_elf_label_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_labels() as i64) + (i as i64) * (pipe_elf_label_esz() as i64);
  return ctx + (off as usize);
}

function pipe_elf_label_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0 || idx >= pipe_elf_table_cap()) {
    return;
  }
  g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
  pipe_elf_bss_store_i32(&g_pipe_elf_label_shndx[0], idx, shndx);
}

/**
 * Pointer to inline reloc entry i.
 */
function pipe_elf_reloc_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_relocs() as i64) + (i as i64) * (pipe_elf_reloc_esz() as i64);
  return ctx + (off as usize);
}

/**
 * Heap reloc entry base for heap index hi.
 */
function pipe_elf_reloc_heap_at(hi: i32): *u8 {
  if (hi < 0 || hi >= pipe_elf_reloc_heap_cap()) {
    return 0 as *u8;
  }
  let off: i64 = (hi as i64) * (pipe_elf_reloc_heap_esz() as i64);
  return &g_pipe_elf_reloc_heap[0] + (off as usize);
}

/**
 * Pointer to reloc_sym_names[i].bytes.
 */
function pipe_elf_reloc_name_row(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_reloc_sym_names() as i64) + (i as i64) * (pipe_elf_reloc_name_esz() as i64);
  return ctx + (off as usize);
}

function pipe_elf_reloc_shndx_set(ctx_bytes: *u8, idx: i32, shndx: i32): void {
  if (ctx_bytes == 0 as *u8 || idx < 0) {
    return;
  }
  if (idx < pipe_elf_table_cap()) {
    g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_shndx[0], idx, shndx);
    return;
  }
  if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  }
  let hi: i32 = idx - pipe_elf_table_cap();
  let h: *u8 = pipe_elf_reloc_heap_at(hi);
  if (h != 0 as *u8) {
    pipe_store_i32_le(h, pipe_elf_rh_off_shndx(), shndx);
  }
}

/**
 * Heap reloc sym name row for heap index hi.
 */
function pipe_elf_reloc_sym_heap_at(hi: i32): *u8 {
  if (hi < 0 || hi >= pipe_elf_reloc_heap_cap()) {
    return 0 as *u8;
  }
  // Cap 4.2.8: row stride 256 (was wave580 128).
  let off: i64 = (hi as i64) * 256;
  return &g_pipe_elf_reloc_sym_heap[0] + (off as usize);
}

/**
 * Reset label/patch/reloc shndx sidecars.
 */
function pipe_elf_shndx_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_shndx_sidecar_owner = ctx_bytes;
  unsafe {
    memset(&g_pipe_elf_label_shndx[0], 0, 65536 as usize);
    memset(&g_pipe_elf_patch_shndx[0], 0, 65536 as usize);
    memset(&g_pipe_elf_reloc_shndx[0], 0, 65536 as usize);
  }
}

/**
 * Pointer to sym entry i.
 */
function pipe_elf_sym_at(ctx: *u8, i: i32): *u8 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 as *u8;
  }
  let off: i64 = (pipe_elf_off_syms() as i64) + (i as i64) * (pipe_elf_sym_esz() as i64);
  return ctx + (off as usize);
}

function pipe_elf_table_cap(): i32 { return 16384; }
function pipe_elf_reloc_heap_cap(): i32 { return 16384; }
function pipe_elf_reloc_total_cap(): i32 { return 32768; }
function pipe_elf_code_buf_cap(): i32 { return 8716288; }
function pipe_elf_code_hot_cap(): i32 { return 1048576; }
function pipe_elf_shnx_text(): i32 { return 1; }
function pipe_elf_shnx_hot(): i32 { return 2; }
function pipe_elf_shnx_unlikely(): i32 { return 3; }
/**
 * F7: section index for the read-only data section (__DATA,__const on Mach-O).
 * Vtable static data with absolute pointer relocations lives here, separate
 * from __TEXT,__text which is pure_instructions and rejects such relocations.
 * PLATFORM: SHARED freestanding ELF leave.
 */
function pipe_elf_shnx_data(): i32 { return 4; }
function pipe_elf_undef_cap(): i32 { return 256; }
function pipe_elf_macho_undef_cap(): i32 { return 256; }
function pipe_elf_pgo_undef_cap(): i32 { return 32; }
function pipe_elf_codegen_out_cap(): i32 { return 9437184; }

// Entry sizes
function pipe_elf_label_esz(): i32 { return 264; }
function pipe_elf_patch_esz(): i32 { return 268; }
function pipe_elf_reloc_esz(): i32 { return 8; }
function pipe_elf_reloc_name_esz(): i32 { return 256; }
function pipe_elf_sym_esz(): i32 { return 268; }
function pipe_elf_reloc_heap_esz(): i32 { return 12; }

// Field offsets inside PipelineElfCtxAccess
function pipe_elf_off_code_len(): i32 { return 0; }
function pipe_elf_off_labels(): i32 { return 4; }
function pipe_elf_off_num_labels(): i32 { return 4325380; }
function pipe_elf_off_patches(): i32 { return 4325384; }
function pipe_elf_off_num_patches(): i32 { return 8716296; }
function pipe_elf_off_relocs(): i32 { return 8716300; }
function pipe_elf_off_reloc_sym_names(): i32 { return 8847372; }
function pipe_elf_off_num_relocs(): i32 { return 13041676; }
function pipe_elf_off_syms(): i32 { return 13041680; }
function pipe_elf_off_num_syms(): i32 { return 17432592; }
function pipe_elf_off_sym_name_len(): i32 { return 17432596; }
function pipe_elf_off_e_machine(): i32 { return 17432600; }
function pipe_elf_off_reloc_type_r_pc32(): i32 { return 17432604; }
function pipe_elf_off_current_frame_size(): i32 { return 17432608; }
function pipe_elf_off_macho_uscore(): i32 { return 17432612; }
function pipe_elf_off_code_hot_len(): i32 { return 17432616; }
function pipe_elf_off_emit_hot(): i32 { return 17432620; }
function pipe_elf_sizeof_access(): i32 { return 17432624; }
function pipe_elf_off_code_data(): i32 { return 17432624; }
function pipe_elf_off_code_hot_data(): i32 { return 26148912; }
function pipe_elf_off_sym_name_data(): i32 { return 27197488; }

// Label entry sub-offsets
function pipe_elf_lab_off_name(): i32 { return 0; }
function pipe_elf_lab_off_name_len(): i32 { return 256; }
function pipe_elf_lab_off_offset(): i32 { return 260; }
// Patch entry
function pipe_elf_pat_off_rel32(): i32 { return 0; }
function pipe_elf_pat_off_name(): i32 { return 4; }
function pipe_elf_pat_off_name_len(): i32 { return 260; }
function pipe_elf_pat_off_imm_bits(): i32 { return 264; }
// Reloc entry
function pipe_elf_rel_off_offset(): i32 { return 0; }
function pipe_elf_rel_off_name_len(): i32 { return 4; }
// Sym entry
function pipe_elf_sym_off_name(): i32 { return 0; }
function pipe_elf_sym_off_name_len(): i32 { return 256; }
function pipe_elf_sym_off_offset(): i32 { return 260; }
function pipe_elf_sym_off_shndx(): i32 { return 264; }
// Heap reloc entry
function pipe_elf_rh_off_offset(): i32 { return 0; }
function pipe_elf_rh_off_name_len(): i32 { return 4; }
function pipe_elf_rh_off_shndx(): i32 { return 8; }

// ---------------------------------------------------------------------------
// BSS sidecars (G.7 single process tables; bind owner on reset)
// ---------------------------------------------------------------------------
// Cap 4.2.8: RELOC_HEAP_CAP(16384) × 256-byte name rows (was 128 → 2097152).



// default -1 per entry: init on reset via memset 0xff


// Writer workspace (avoids huge pure stack frames; single-threaded compile)
/* F7: shstrtab is 63 bytes once .data + .rela.data are appended after the
 * historic 46-byte ".text.symtab.strtab.shstrtab.rela.text" blob.
 * PLATFORM: LINUX ELF writer (buffer shared with the Mach-O path unused). */
/* F7: Mach-O writer workspace for the second LC_SEGMENT_64 (__DATA,__const).
 * Single-threaded compile; reused per module. */
/* F7: data section buffer for vtable static data (read-only data with absolute
 * pointer relocations; cannot live in __TEXT,__text which is pure_instructions).
 * Single-threaded compile; reset per-module via pipeline_elf_ctx_reset_data. */
/* F7: shndx override (0 = no override; 4 = data section). When non-zero,
 * pipe_elf_current_shndx returns this value, so new relocs/syms/labels are
 * tagged as data-section. Set before emitting vtable statics; clear after.
 * Single-threaded compile; safe as a global mutable. */

/**
 * Byte equality for name rows.
 * @param a *u8 @param a_len i32 @param b *u8 @param b_len i32
 * @return i32 - 1 equal, 0 not
 * PLATFORM: SHARED freestanding ELF leave.
 */
function pipe_elf_name_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) {
    return 0;
  }
  if (a_len < 0) {
    return 0;
  }
  if (a_len == 0) {
    return 1;
  }
  if (a == 0 as *u8 || b == 0 as *u8) {
    return 0;
  }
  let i: i32 = 0;
  while (i < a_len) {
    unsafe {
      if (a[i] != b[i]) {
        return 0;
      }
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Allocate nbytes for GrowVec data (mmap large; calloc small).
 * @param nbytes i64 - byte count; <=0 -> null
 * @param out_mm *i32 - set to 1 if mmap-backed, else 0; may be null
 * @return *u8 - buffer or null
 * PLATFORM: POSIX mmap when thresh met; WINDOWS calloc only.
 */
function pipe_gv_alloc_bytes(nbytes: i64, out_mm: *i32): *u8 {
  if (out_mm != 0 as *i32) {
    unsafe {
      out_mm[0] = 0;
    }
  }
  if (nbytes <= 0) {
    return 0 as *u8;
  }
  // Prefer mmap for large blocks when POSIX flags available (RSS munmap path).
  let flags: i32 = pipe_gv_mmap_flags();
  if (flags != 0 && nbytes >= pipe_gv_mmap_thresh()) {
    let p: *u8 = 0 as *u8;
    let fd: i32 = 0;
    fd = fd - 1;
    let off: i64 = 0 as i64;
    unsafe {
      p = mmap(0 as *u8, nbytes as usize, 3, flags, fd, off);
    }
    if (p != 0 as *u8 && pipe_gv_ptr_is_map_failed(p) == 0) {
      if (out_mm != 0 as *i32) {
        unsafe {
          out_mm[0] = 1;
        }
      }
      return p;
    }
  }
  let one: usize = 1 as usize;
  let nb: usize = nbytes as usize;
  let p2: *u8 = 0 as *u8;
  unsafe {
    p2 = calloc(one, nb);
  }
  return p2;
}

function pipe_gv_dealloc_bytes(p: *u8, nbytes: i64, mmap_backed: i32): void {
  if (p == 0 as *u8) {
    return;
  }
  if (mmap_backed != 0) {
    if (nbytes > 0) {
      unsafe {
        munmap(p, nbytes as usize);
      }
    }
    return;
  }
  unsafe {
    free(p);
  }
}

/**
 * Load GrowVec.cap.
 * @param v *u8 - GrowVec*
 * @return i32
 */
function pipe_gv_load_cap(v: *u8): i32 {
  return pipe_load_i32_le(v, pipe_gv_off_cap());
}

/**
 * Load GrowVec.elem_sz (size_t as i64).
 * @param v *u8 - GrowVec*
 * @return i64
 */
function pipe_gv_load_elem_sz(v: *u8): i64 {
  if (v == 0 as *u8) {
    return 0;
  }
  // elem_sz at byte offset 16 = size_t slot index 2
  return xlang_size_slot_get(v, 2);
}

/**
 * Load GrowVec.len.
 * @param v *u8 - GrowVec*
 * @return i32
 */
function pipe_gv_load_len(v: *u8): i32 {
  return pipe_load_i32_le(v, pipe_gv_off_len());
}

/**
 * Load GrowVec.mmap_backed flag.
 * @param v *u8 - GrowVec*
 * @return i32 - 0 or 1
 */
function pipe_gv_load_mmap(v: *u8): i32 {
  return pipe_load_i32_le(v, pipe_gv_off_mmap());
}

/**
 * MAP_PRIVATE|MAP_ANON flags for anonymous mmap.
 * @return i32 - flags (0 => disable mmap path)
 * PLATFORM: LINUX MAP_ANON=0x20; MACOS MAP_ANON=0x1000; else 0.
 */
function pipe_gv_mmap_flags(): i32 {
  return g_pipe_gv_mmap_flags;
}

/**
 * True when p is MAP_FAILED ((void*)-1).
 * @param p *u8 - mmap result
 * @return i32 - 1 if failed mapping, else 0
 * PLATFORM: SHARED LP64.
 */
function pipe_gv_ptr_is_map_failed(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  let cell: u8[8] = [];
  xlang_ptr_slot_set(&cell[0], 0, p);
  let bits: i64 = xlang_size_slot_get(&cell[0], 0);
  // MAP_FAILED == (void*)-1 on LP64; keep i64 on both sides (T001).
  let failed: i64 = 0 as i64;
  failed = failed - 1;
  if (bits == failed) {
    return 1;
  }
  return 0;
}

/**
 * Store GrowVec.cap.
 * @param v *u8 - GrowVec*
 * @param c i32
 */
function pipe_gv_store_cap(v: *u8, c: i32): void {
  pipe_store_i32_le(v, pipe_gv_off_cap(), c);
}

/**
 * Store GrowVec.data pointer.
 * @param v *u8 - GrowVec*
 * @param p *u8 - data pointer
 */
function pipe_gv_store_data(v: *u8, p: *u8): void {
  if (v == 0 as *u8) {
    return;
  }
  xlang_ptr_slot_set(v, 0, p);
}

/**
 * Store GrowVec.elem_sz.
 * @param v *u8 - GrowVec*
 * @param es i64 - element size in bytes
 */
function pipe_gv_store_elem_sz(v: *u8, es: i64): void {
  if (v == 0 as *u8) {
    return;
  }
  xlang_size_slot_set(v, 2, es);
}

/**
 * Store GrowVec.len.
 * @param v *u8 - GrowVec*
 * @param n i32
 */
function pipe_gv_store_len(v: *u8, n: i32): void {
  pipe_store_i32_le(v, pipe_gv_off_len(), n);
}

/**
 * Store GrowVec.mmap_backed flag.
 * @param v *u8 - GrowVec*
 * @param mm i32
 */
function pipe_gv_store_mmap(v: *u8, mm: i32): void {
  pipe_store_i32_le(v, pipe_gv_off_mmap(), mm);
}

/**
 * Load host LE i32 from base[off..off+3]. Null base or off negative -> 0.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @return i32 - signed value (u32 reconstruct then cast)
 * G.7 pair of pipe_store_i32_le; local - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_load_i32_le(base: *u8, off: i32): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  let b0: u32 = 0;
  let b1: u32 = 0;
  let b2: u32 = 0;
  let b3: u32 = 0;
  unsafe {
    b0 = base[off] as u32;
    b1 = base[off + 1] as u32;
    b2 = base[off + 2] as u32;
    b3 = base[off + 3] as u32;
  }
  let u: u32 = b0 + b1 * 256 + b2 * 65536 + b3 * 16777216;
  return u as i32;
}

/** Exported function `pipe_load_ptr_slot`.
 * Implements `pipe_load_ptr_slot`.
 * @param base *u8
 * @param i i32
 * @return *u8
 */
export function pipe_load_ptr_slot(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = base[off] as usize;
  a = a + (base[off + 1] as usize) * m;
  a = a + (base[off + 2] as usize) * m2;
  a = a + (base[off + 3] as usize) * (m2 * m);
  a = a + (base[off + 4] as usize) * m4;
  a = a + (base[off + 5] as usize) * (m4 * m);
  a = a + (base[off + 6] as usize) * (m4 * m2);
  a = a + (base[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/**
 * Read module.num_top_level_lets (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 * PLATFORM: SHARED LP64.
 */
function pipe_mod_get_num_top_level_lets(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_mod_off_num_top_level_lets());
}

/**
 * LP64 offsetof(struct ast_Module, num_funcs).
 * @return i32 - 0
 * PLATFORM: SHARED LP64.
 */
function pipe_mod_off_num_funcs(): i32 {
  return 0;
}

/**
 * LP64 offsetof(struct ast_Module, num_top_level_lets).
 * Layout: num_funcs@0 main_func_index@4 num_imports@8 num_top_level_lets@12.
 * @return i32 - 12
 * PLATFORM: SHARED LP64 - dual-end with sizeof Module=68.
 */
function pipe_mod_off_num_top_level_lets(): i32 {
  return 12;
}

/**
 * Fold one ARRAY_LIT element to its constant i32 value.
 * Accepts EXPR_LIT (ek 0) and EXPR_NEG over EXPR_LIT (ek 22) — the parser's
 * compound-reparse normal form for negative literals, e.g. `[-600, 2]`
 * produces EXPR_NEG(EXPR_LIT), not a bare negative LIT. Anything else
 * (FLOAT_LIT, binop, VAR, ...) is not a compile-time constant elem; callers
 * must loud-fail (return -1) instead of silently dropping the element —
 * the historic silent drop baked/seeded zeros for `let g: i32[2] = [-1, 2]`.
 * @param arena *u8 - ASTArena
 * @param eref i32 - element expr ref
 * @param out_val *i32 - folded two's-complement i32 value
 * @return i32 - 1 = folded constant; 0 = not a supported constant elem
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_array_lit_elem_const_val(
  arena: *u8, eref: i32, out_val: *i32
): i32 {
  let ek: i32 = 0;
  let op: i32 = 0;
  let v: i32 = 0;
  if (arena == (0 as *u8) || eref <= 0 || out_val == (0 as *i32)) {
    return 0;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  if (ek == 0) {
    unsafe {
      v = pipeline_expr_int_val_at(arena, eref);
    }
    unsafe {
      out_val[0] = v;
    }
    return 1;
  }
  if (ek == 22) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(arena, eref);
    }
    if (op <= 0) {
      return 0;
    }
    unsafe {
      ek = pipeline_expr_kind_ord_at(arena, op);
    }
    if (ek != 0) {
      return 0;
    }
    unsafe {
      v = pipeline_expr_int_val_at(arena, op);
    }
    unsafe {
      out_val[0] = 0 - v;
    }
    return 1;
  }
  return 0;
}

/**
 * Sum interned-pool bytes for every STRING_LIT elem (recursively).
 * Each STRING_LIT contributes slen+1 (payload + NUL). slen>4095 is the
 * parser STRING_LIT overflow cap: return -1 so prepare keeps the cell
 * COMMON rather than silently truncating. Nested ARRAY_LIT rows recurse.
 * @param arena *u8 - ASTArena
 * @param init_ref i32 - ARRAY_LIT expr
 * @return i32 - >=0 interned byte count (0 = no strings); -1 too-long/null
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_array_lit_string_pool_bytes(
  arena: *u8, init_ref: i32
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let slen: i32 = 0;
  let sub: i32 = 0;
  let total: i32 = 0;
  if (arena == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  unsafe {
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    }
    if (eref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, eref);
      }
      if (ek == 59) {
        unsafe {
          slen = glue_asm_string_lit_len(arena, eref);
        }
        if (slen < 0 || slen > 4095) {
          return 0 - 1;
        }
        total = total + slen + 1;
      }
      if (ek == 46) {
        sub = pipe_modlet_array_lit_string_pool_bytes(arena, eref);
        if (sub < 0) {
          return 0 - 1;
        }
        total = total + sub;
      }
    }
    ei = ei + 1;
  }
  return total;
}

/**
 * Assign a TU-unique COMMON symbol into label[idx].
 * Format (21 bytes): Lxml_<hex8(fnv32(name||idx))><hex8(module_fp)>
 * Historic Lxlang_ml_<idx> collided across every assembled TU (SHN_COMMON
 * takes the largest size). Ubuntu then aliased driver_check_only_flag_slot
 * to a 512-byte Lxlang_ml_0 whose first word was entry source len (0xa7),
 * so -o ran under parse_strict / check_only.
 * @param idx i32 — table index 0..n-1
 * @param module_fp i64 — pipe_modlet_module_fp()
 * @return void
 * PLATFORM: SHARED — ELF SHN_COMMON + Mach-O __DATA,__common.
 */
function pipe_modlet_assign_unique_label(idx: i32, module_fp: i64): void {
  let nl: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(idx));
  let nbase: i32 = pipe_modlet_off_name(idx);
  let h: i64 = 2166136261;
  let k: i32 = 0;
  while (k < nl) {
    let b: i32 = 0;
    unsafe {
      b = g_pipeline_asm_modlet[nbase + k] as i32;
    }
    h = pipe_modlet_fnv32_mix(h, b);
    k = k + 1;
  }
  h = pipe_modlet_fnv32_mix(h, idx & 255);
  let lbase: i32 = pipe_modlet_off_label(idx);
  unsafe {
    g_pipeline_asm_modlet[lbase] = 76 as u8;
    g_pipeline_asm_modlet[lbase + 1] = 120 as u8;
    g_pipeline_asm_modlet[lbase + 2] = 109 as u8;
    g_pipeline_asm_modlet[lbase + 3] = 108 as u8;
    g_pipeline_asm_modlet[lbase + 4] = 95 as u8;
  }
  pipe_modlet_write_hex8(lbase, 5, h);
  pipe_modlet_write_hex8(lbase, 13, module_fp);
  pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx), 21);
}

/**
 * Bake ARRAY_LIT constant elems into an already-reserved .data cell.
 * Twin of pipe_modlet_seed_array_lit_elems_to_rbx but writes object-file
 * bytes (library TUs never enter hoist-target seed). One nested ARRAY_LIT
 * level for `[K][N]T` rows; deeper nest is a later leaf. Empty lit is a
 * no-op (zeros already reserved). Elem contract: EXPR_LIT and
 * EXPR_NEG-over-LIT fold via pipe_modlet_array_lit_elem_const_val;
 * anything else (FLOAT_LIT, binop, VAR, ...) loud-fails — the historic
 * silent drop baked zeros for `[-1, 2]`. STRING_LIT elems intern into the
 * .data string pool and record an absolute64 reloc on the pointer slot.
 * 9.4.2 ptr/fn ADDR_OF / bare-fn elems record an absolute64 reloc on the
 * named symbol (G.7 complete of pipeline_elf_ctx_append_reloc_absolute64).
 * slen>4095 loud-fails (parser STRING_LIT overflow cap / L011).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param init_ref i32 - ARRAY_LIT expr
 * @param elem_ty i32 - dest elem type_ref (scalar or TYPE_ARRAY row)
 * @param data_base i32 - absolute offset of the cell in g_pipe_elf_data_buf
 * @param base_off i32 - byte offset within the cell
 * @param span_bytes i32 - bytes this literal may occupy (cell size at top
 *     call, row size for nested rows); literal exceeding span = loud fail
 * @param m *u8 - Module* (fn lookup for address elems; may be null)
 * @return i32 - 0 ok; -1 poke fail / non-constant elem / span overflow
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · ELF .data.
 */
function pipe_modlet_bake_array_lit_elems_to_data(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32, data_base: i32, base_off: i32,
  span_bytes: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let ev: i32 = 0;
  let esz: i32 = 4;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let bi: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ty);
    }
  }
  if (etk == 10) {
    unsafe {
      inner_et = pipeline_type_elem_ref_at(arena, elem_ty);
      ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    }
    row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
    if (row_sz <= 0) {
      row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
    }
    // ne<=0: empty row lit is a no-op (zeros already reserved). Span guard:
    // row count must fit this literal's row span — a mismatch (typeck gap
    // or absurd literal) loud-fails instead of silently leaving rows zero.
    if (ne <= 0) {
      return 0;
    }
    if (row_sz > 0 && ne > span_bytes / row_sz) {
      return 0 - 1;
    }
    ei = 0;
    while (ei < ne) {
      unsafe {
        eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
      }
      if (eref > 0) {
        unsafe {
          ek = pipeline_expr_kind_ord_at(arena, eref);
        }
        if (ek == 46) {
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            arena, elf_ctx, eref, inner_et, data_base, base_off + ei * row_sz, row_sz, m);
          if (rc != 0) {
            return rc;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
  esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    esz = 4;
  }
  unsafe {
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  // ne<=0: empty lit is a no-op (zeros already reserved). Span guard:
  // elem count must fit this literal's elem span (no silent truncation).
  if (ne <= 0) {
    return 0;
  }
  if (esz > 0 && ne > span_bytes / esz) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    }
    if (eref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, eref);
      }
      // STRING_LIT elem: intern bytes + NUL into the .data pool and
      // record an absolute64 reloc on this pointer slot. Prepare now
      // routes string-bearing arrays here when the pool fits.
      if (ek == 59) {
        rc = pipe_modlet_bake_string_lit_elem_to_data(
          arena, elf_ctx, eref, data_base + base_off + ei * esz);
        if (rc != 0) {
          return rc;
        }
        ei = ei + 1;
        continue;
      }
      // 9.4.2 address-valued elem (bare fn / `fn as *u8` / `&global`):
      // record an absolute64 reloc on this pointer slot. rc==1 → not an
      // address literal, fall through to the const fold (loud-fail).
      if ((etk == 9 || etk == 18) && m != (0 as *u8)) {
        rc = pipe_modlet_bake_ptr_addr_elem_to_data(
          arena, elf_ctx, m, eref, esz, data_base + base_off + ei * esz);
        if (rc < 0) {
          return 0 - 1;
        }
        if (rc == 0) {
          ei = ei + 1;
          continue;
        }
      }
      // LIT / EXPR_NEG-over-LIT: fold, then peel two's-complement bytes
      // little-endian via u32 (unsigned division). The historic signed
      // `cur / 256` peel corrupted bytes 1..3 of negative elems.
      if (pipe_modlet_array_lit_elem_const_val(arena, eref, &ev) == 0) {
        return 0 - 1;
      }
      let uw: u32 = ev as u32;
      bi = 0;
      while (bi < esz) {
        unsafe {
          rc = pipeline_elf_ctx_data_poke_u8(
            elf_ctx, data_base + base_off + ei * esz + bi, (uw & 255) as i32);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        uw = uw / 256;
        bi = bi + 1;
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Bake one address-valued ARRAY_LIT elem as an absolute64 reloc on an
 * already-reserved .data pointer slot (9.4.2).
 *
 * Completes the STRING_LIT intern path: named-symbol addresses (bare
 * same-module fn, `fn as *u8`, `&global`) cannot be poked as immediates,
 * so prepare used to keep those tables COMMON and rely on the hoist-target
 * seeder. Library TUs never seed, leaving the slots NULL. G.7: reloc
 * authority is pipeline_elf_ctx_append_reloc_absolute64 (F7 vtable +
 * STRING_LIT intern). Symbol spelling is pipe_modlet_fn_sym_spell_into
 * (same Mach-O '_' / ELF bare as pipe_modlet_lea_fn_sym_to_rax).
 *
 * ADDR_OF prefers the modlet unique label (COMMON or .data cell), then
 * the same-module function link symbol. A bare VAR that is not a
 * same-module fn is a VALUE copy, not an address literal: return 1 so
 * the caller falls through to the const fold (which loud-fails).
 *
 * Called with shndx_override already 4 (prepare's bake window).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param m *u8 - Module* (fn lookup; null → not-an-address-elem)
 * @param eref i32 - element expr ref
 * @param esz i32 - dest elem byte size (must be 8)
 * @param slot_off i32 - absolute .data offset of the 8-byte pointer slot
 * @return i32 - 0 recorded reloc; 1 not an address elem; -1 loud fail
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_bake_ptr_addr_elem_to_data(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, slot_off: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let sym: u8[130] = [];
  let slen: i32 = 0;
  let fi: i32 = 0;
  let idx: i32 = 0;
  let llen: i32 = 0;
  let lbase: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0 || slot_off < 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  if (ek == 54) {
    unsafe {
      nref = pipeline_expr_as_operand_ref_at(arena, eref);
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        nref = pipeline_expr_unary_operand_ref_at(arena, eref);
      }
    } else {
      if (ek != 3) {
        return 1;
      }
      nref = eref;
    }
  }
  if (nref <= 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, nref);
  }
  if (ek != 3) {
    return 1;
  }
  unsafe {
    vlen = pipeline_expr_var_name_len(arena, nref);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, nref, &name[0]);
  }
  if (esz != 8) {
    return 0 - 1;
  }
  if (is_addr_of != 0) {
    idx = pipeline_asm_modlet_find(&name[0], vlen);
    if (idx >= 0) {
      llen = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_label_len(idx));
      lbase = pipe_modlet_off_label(idx);
      if (llen <= 0 || llen > 24) {
        return 0 - 1;
      }
      unsafe {
        rc = pipeline_elf_ctx_append_reloc_absolute64(
          elf_ctx, slot_off, &g_pipeline_asm_modlet[lbase], llen);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    if (m == (0 as *u8)) {
      return 0 - 1;
    }
    unsafe {
      fi = glue_module_func_index_by_name_c(m, &name[0], vlen);
    }
    if (fi < 0) {
      return 0 - 1;
    }
    slen = pipe_modlet_fn_sym_spell_into(elf_ctx, &name[0], vlen, &sym[0]);
    if (slen <= 0) {
      return 0 - 1;
    }
    unsafe {
      rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &sym[0], slen);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (m == (0 as *u8)) {
    return 1;
  }
  unsafe {
    fi = glue_module_func_index_by_name_c(m, &name[0], vlen);
  }
  if (fi < 0) {
    return 1;
  }
  slen = pipe_modlet_fn_sym_spell_into(elf_ctx, &name[0], vlen, &sym[0]);
  if (slen <= 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &sym[0], slen);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Bake a scalar module-let immediate into an already-reserved .data cell.
 * wave344: library Cap TUs never run seed_nonzero; non-zero COMMON stays 0.
 * Peels two's-complement LE bytes via u32 (same as ARRAY_LIT LIT peel).
 * Sign-extends into bytes beyond 4 when csz>=8 (NEG -1 → 0xff..ff).
 * @param elf_ctx *u8 — ElfCodegenCtx*
 * @param data_off i32 — absolute .data offset of the cell
 * @param imm i32 — folded init (may be negative)
 * @param csz i32 — cell payload bytes (1..8 typical; capped at 8)
 * @return i32 — 0 ok; -1 poke fail / bad args
 * PLATFORM: SHARED freestanding · ELF .data · Mach-O __DATA,__const.
 */
function pipe_modlet_bake_scalar_imm_to_data(
  elf_ctx: *u8, data_off: i32, imm: i32, csz: i32
): i32 {
  let bi: i32 = 0;
  let n: i32 = 0;
  let rc: i32 = 0;
  let uw: u32 = 0;
  let hi: u32 = 0;
  if (elf_ctx == (0 as *u8) || data_off < 0 || csz <= 0) {
    return 0 - 1;
  }
  n = csz;
  if (n > 8) {
    n = 8;
  }
  // Same unsigned LE peel as ARRAY_LIT LIT elems (signed /256 corrupts).
  uw = imm as u32;
  bi = 0;
  while (bi < n && bi < 4) {
    unsafe {
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (uw & 255) as i32);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    uw = uw / 256;
    bi = bi + 1;
  }
  // Sign-extend into bytes 4..7 for 8-byte cells (NEG -1 → 0xff..ff).
  if (bi < n) {
    hi = 0;
    if (imm < 0) {
      hi = 4294967295 as u32;
    }
    while (bi < n) {
      unsafe {
        rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (hi & 255) as i32);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      hi = hi / 256;
      bi = bi + 1;
    }
  }
  return 0;
}

/**
 * Intern one STRING_LIT into the F7 .data string pool and record an
 * absolute64 reloc on the already-reserved pointer slot.
 *
 * Label form (22 bytes, TU-unique): Lxmls_ + hex8(seq) + hex8(module_fp).
 * Seq resets with the modlet table. G.7: reloc authority is
 * pipeline_elf_ctx_append_reloc_absolute64 (same sentinel the F7 vtable
 * statics use). Bytes come from the STRING_LIT overflow chain (head
 * var_name plus int_val-linked chunks); slen>4095 loud-fails.
 *
 * Called with shndx_override already 4 (prepare's bake window).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param eref i32 - STRING_LIT expr
 * @param slot_off i32 - absolute .data offset of the 8-byte pointer slot
 * @return i32 - 0 ok; -1 intern/reloc/label fail
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32 {
  let slen: i32 = 0;
  let pool_off: i32 = 0;
  let rc: i32 = 0;
  let bi: i32 = 0;
  let seq: i32 = 0;
  let fp: i64 = 0;
  let lab: u8[24] = [];
  let i: i32 = 0;
  let shift: i32 = 0;
  let nib: i32 = 0;
  let ch: u8 = 0 as u8;
  let sbuf: u8[256] = [];
  let cur: i32 = 0;
  let n: i32 = 0;
  let copied: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0 || slot_off < 0) {
    return 0 - 1;
  }
  unsafe {
    slen = glue_asm_string_lit_len(arena, eref);
  }
  if (slen < 0 || slen > 4095) {
    return 0 - 1;
  }
  unsafe {
    pool_off = pipeline_elf_ctx_emit_data_len(elf_ctx);
  }
  if (pool_off < 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, slen + 1);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  copied = 0;
  cur = eref;
  while (copied < slen && cur > 0) {
    unsafe {
      pipeline_expr_var_name_into(arena, cur, &sbuf[0]);
    }
    if (cur == eref) {
      n = slen;
      if (n > 255) {
        n = 255;
      }
    } else {
      unsafe {
        n = glue_asm_string_lit_len(arena, cur);
      }
    }
    if (n < 0) {
      n = 0;
    }
    if (n > slen - copied) {
      n = slen - copied;
    }
    bi = 0;
    while (bi < n) {
      unsafe {
        rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, pool_off + copied + bi, sbuf[bi] as i32);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      bi = bi + 1;
    }
    copied = copied + n;
    unsafe {
      cur = pipeline_expr_int_val_at(arena, cur);
    }
  }
  g_pipe_modlet_strpool_seq = g_pipe_modlet_strpool_seq + 1;
  seq = g_pipe_modlet_strpool_seq;
  fp = pipe_modlet_module_fp();
  unsafe {
    lab[0] = 76 as u8;
    lab[1] = 120 as u8;
    lab[2] = 109 as u8;
    lab[3] = 108 as u8;
    lab[4] = 115 as u8;
    lab[5] = 95 as u8;
  }
  i = 0;
  while (i < 8) {
    shift = (7 - i) * 4;
    nib = (seq >> shift) & 15;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      lab[6 + i] = ch;
    }
    i = i + 1;
  }
  i = 0;
  while (i < 8) {
    shift = (7 - i) * 4;
    nib = ((fp >> shift) & 15) as i32;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      lab[14 + i] = ch;
    }
    i = i + 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_add_label(elf_ctx, &lab[0], 22, pool_off);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_add_sym(elf_ctx, &lab[0], 22, pool_off);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &lab[0], 22);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * TYPE_ARRAY flag in cell_size: bit 30 = 0x40000000 = 1073741824.
 * @return i32 — flag mask
 * PLATFORM: SHARED — modlet table encoding.
 */
function pipe_modlet_cell_array_bit(): i32 {
  return 1073741824;
}

/**
 * Non-empty ARRAY_LIT baked into .data flag: bit 29 = 0x20000000 = 536870912.
 * When set, hoist-target seed_nonzero must not store over the cell (may be
 * RO after final link on Mach-O __const). Library TUs never enter hoist.
 * @return i32 — flag mask
 * PLATFORM: SHARED — modlet table encoding · ELF .data + Mach-O __DATA,__const.
 */
function pipe_modlet_cell_data_bit(): i32 {
  return 536870912;
}

/**
 * Whether load must return address (array decay), not first qword.
 * @param csz i32 — stored cell_size word
 * @return i32 — 1 LEA-only; 0 load qword
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_is_array(csz: i32): i32 {
  if ((csz & 1073741824) != 0) {
    return 1;
  }
  // Legacy: arrays registered without the bit still used payload!=8.
  let p: i32 = csz & 536870911;
  if (p != 8 && p > 0) {
    return 1;
  }
  return 0;
}

/**
 * Whether the ARRAY_LIT payload was baked into .data at prepare time.
 * @param csz i32 — stored cell_size word
 * @return i32 — 1 .data-backed; 0 COMMON/BSS (needs hoist seed if non-empty)
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_is_data(csz: i32): i32 {
  if ((csz & 536870912) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Payload bytes for COMMON / .data emit (mask out array + data flags).
 * @param csz i32 — stored cell_size word
 * @return i32 — size >= 1 (default 8 if empty)
 * PLATFORM: SHARED.
 */
function pipe_modlet_cell_payload(csz: i32): i32 {
  let p: i32 = csz & 536870911;
  if (p <= 0) {
    return 8;
  }
  return p;
}

/**
 * Spell a same-module function's link name into dst.
 * Mach-O leading '_' on Darwin, bare ELF name on Linux. Completes the
 * spelling previously inlined in pipe_modlet_lea_fn_sym_to_rax so LEA
 * and .data absolute64 relocs share one authority.
 * @param elf_ctx *u8 - ElfCodegenCtx (reads macho_leading_underscore)
 * @param name *u8 - source-level function name
 * @param name_len i32 - 1..255
 * @param dst *u8 - caller buffer; capacity >= name_len+1 (typically 130)
 * @return i32 - spelled length; -1 bad args
 * PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare name.
 */
function pipe_modlet_fn_sym_spell_into(
  elf_ctx: *u8, name: *u8, name_len: i32, dst: *u8
): i32 {
  let macho: i32 = 0;
  let k: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || dst == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  unsafe {
    macho = pipeline_elf_ctx_macho_leading_underscore(elf_ctx);
  }
  if (macho != 0) {
    unsafe {
      dst[0] = 95 as u8;
    }
    k = 0;
    while (k < name_len) {
      unsafe {
        dst[k + 1] = name[k];
      }
      k = k + 1;
    }
    return name_len + 1;
  }
  k = 0;
  while (k < name_len) {
    unsafe {
      dst[k] = name[k];
    }
    k = k + 1;
  }
  return name_len;
}

/**
 * FNV-1a 32-bit mix of one byte (unsigned 32-bit wrap).
 * Same basis/prime as asm_empty_text_stub_label (G.7: no second hash family).
 * @param h i64 — hash in 0..2^32-1
 * @param b i32 — byte 0..255
 * @return i64 — mixed hash in 0..2^32-1
 * PLATFORM: SHARED — COMMON label identity only.
 */
function pipe_modlet_fnv32_mix(h: i64, b: i32): i64 {
  let x: i64 = (h ^ (b as i64)) * 16777619;
  return x & 4294967295;
}

function pipe_modlet_get_n(): i32 {
  return pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_n());
}

/**
 * Fixed modlet table capacity (COMMON / .data cells per TU).
 * @return i32 — XLANG_ASM_MODLET_MAX; index range 0 .. max-1
 * PLATFORM: SHARED — single authority for offset bases and the prepare cap.
 * G.7: complete the existing table; do not add a second growable table.
 */
function pipe_modlet_max(): i32 {
  /* wave624: 512 — the mega TU itself has 331 registrable top-level lets;
   * the old 256 cap hit the loud-fail gate at monofile codegen START
   * (CG002 code_len=0, mega FORCE blocker head). 512 covers the mega with
   * headroom; buffer g_pipeline_asm_modlet grows 43012→86020 to match.
   * PLATFORM: SHARED — single authority (seed twin mirrors). */
  return 512;
}

/**
 * Fingerprint of every registered modlet name (order-sensitive).
 * Two TUs with different let sets get different COMMON prefixes.
 * @return i64 — FNV-1a 32-bit in 0..2^32-1
 * PLATFORM: SHARED — SHN_COMMON / Mach-O __common merge by symbol name.
 */
function pipe_modlet_module_fp(): i64 {
  let h: i64 = 2166136261;
  let n: i32 = pipe_modlet_get_n();
  let i: i32 = 0;
  while (i < n) {
    let nl: i32 = pipe_load_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_name_len(i));
    let base: i32 = pipe_modlet_off_name(i);
    h = pipe_modlet_fnv32_mix(h, nl & 255);
    let k: i32 = 0;
    while (k < nl) {
      let b: i32 = 0;
      unsafe {
        b = g_pipeline_asm_modlet[base + k] as i32;
      }
      h = pipe_modlet_fnv32_mix(h, b);
      k = k + 1;
    }
    h = pipe_modlet_fnv32_mix(h, 0);
    i = i + 1;
  }
  return h;
}

/**
 * Byte offset of cell_size[i] in the modlet table (COMMON payload size).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout Stage 12.0.5. Base = init_imm_base + max*4.
 *
 * Encoding (Stage 12.0.5 / invoke_cc_list + library-TU .data):
 *   low 29 bits = payload bytes for SHN_COMMON or .data
 *   bit 29 (0x20000000) = non-empty ARRAY_LIT baked into ELF .data /
 *     Mach-O __DATA,__const (library TUs have no hoist-target seed)
 *   bit 30 (0x40000000) = TYPE_ARRAY address-decay (LEA-only load)
 * Scalar lit cells store plain 8 (no bit). Arrays store N|bit30 so u8[8]
 * (payload==8) does not collide with scalar load-qword (labi g_labi_icc_oopt_buf).
 * Product max payload 8 MiB << bit29; mask shrink 30→29 is safe.
 */
function pipe_modlet_off_cell_size(i: i32): i32 {
  return pipe_modlet_off_init_imm(0) + (pipe_modlet_max() * 4) + (i * 4);
}

/**
 * Byte offset of init_imm[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = label_base + max*24.
 */
function pipe_modlet_off_init_imm(i: i32): i32 {
  return pipe_modlet_off_label(0) + (pipe_modlet_max() * 24) + (i * 4);
}

/**
 * Byte offset of label[i][0] in the modlet table (24B slot).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = label_len_base + max*4.
 */
function pipe_modlet_off_label(i: i32): i32 {
  return pipe_modlet_off_label_len(0) + (pipe_modlet_max() * 4) + (i * 24);
}

/**
 * Byte offset of label_len[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = name_base + max*128.
 */
function pipe_modlet_off_label_len(i: i32): i32 {
  return pipe_modlet_off_name(0) + (pipe_modlet_max() * 128) + (i * 4);
}

/**
 * Byte offset of n (registered cell count) in the modlet table.
 * @return i32 — always 0
 * PLATFORM: SHARED — LP64 table layout.
 */
function pipe_modlet_off_n(): i32 {
  return 0;
}

/**
 * Byte offset of name[i][0] in the modlet table (128B slot).
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout. Base = 4 + max*4.
 */
function pipe_modlet_off_name(i: i32): i32 {
  return 4 + (pipe_modlet_max() * 4) + (i * 128);
}

/**
 * Byte offset of name_len[i] in the modlet table.
 * @param i i32 — table index 0 .. pipe_modlet_max()-1
 * @return i32 — byte offset within g_pipeline_asm_modlet
 * PLATFORM: SHARED — LP64 table layout.
 */
function pipe_modlet_off_name_len(i: i32): i32 {
  return 4 + (i * 4);
}

/**
 * wave338: True when a mutable scalar module-let init is prepare-COMMON-owned.
 * Completes the historic LIT/BOOL gate (ek 0/2) with:
 *   · EXPR_NEG-over-LIT (ek 22) — parser normal form for `let g: i32 = -1`
 *   · Null TYPE_PTR (tk 9): bare LIT 0 or AS(LIT 0) — `let p: *u8 = 0 as *u8`
 * Library TUs / Cap thins have no hoist-target main; without COMMON the
 * pure-asm backend constant-folds loads and drops stores (typeck_active /
 * emit_ctx_sret home_off=-1 class). Hoist skip MUST agree (9.6.0 dual-home).
 * @param arena *u8 — ASTArena
 * @param init_ref i32 — top-level let init expr
 * @param tk i32 — type kind ord (9 = TYPE_PTR)
 * @param is_const i32 — 1 = const let (prepare skips; hoist keeps)
 * @param out_imm *i32 — folded two's-complement init (0 for null ptr)
 * @return i32 — 1 register 8-byte COMMON; 0 keep other arms / hoist
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_scalar_init_common_imm(
  arena: *u8, init_ref: i32, tk: i32, is_const: i32, out_imm: *i32
): i32 {
  let ik: i32 = 0;
  let fold_buf: i32[1] = [];
  let op: i32 = 0;
  let oek: i32 = 0;
  let v: i32 = 0;
  if (is_const != 0 || arena == (0 as *u8) || init_ref <= 0 || out_imm == (0 as *i32)) {
    return 0;
  }
  fold_buf[0] = 0;
  unsafe {
    ik = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ik == 2) {
    unsafe {
      v = pipeline_expr_int_val_at(arena, init_ref);
    }
    unsafe {
      out_imm[0] = v;
    }
    return 1;
  }
  if (pipe_modlet_array_lit_elem_const_val(arena, init_ref, &fold_buf[0]) == 1) {
    unsafe {
      out_imm[0] = fold_buf[0];
    }
    return 1;
  }
  if (tk == 9) {
    if (ik == 0) {
      unsafe {
        v = pipeline_expr_int_val_at(arena, init_ref);
      }
      if (v == 0) {
        unsafe {
          out_imm[0] = 0;
        }
        return 1;
      }
    } else {
      if (ik == 54) {
        unsafe {
          op = pipeline_expr_as_operand_ref_at(arena, init_ref);
        }
        if (op > 0) {
          unsafe {
            oek = pipeline_expr_kind_ord_at(arena, op);
          }
          if (oek == 0) {
            unsafe {
              v = pipeline_expr_int_val_at(arena, op);
            }
            if (v == 0) {
              unsafe {
                out_imm[0] = 0;
              }
              return 1;
            }
          }
        }
      }
    }
  }
  return 0;
}

/**
 * True when a scalar module-let init is a compile-time address that
 * prepare can bake as an 8-byte .data cell + absolute64 reloc.
 *
 * Completes 9.4.2 ARRAY_LIT table bake for the scalar leftover:
 *   `let p: *i32 = &g` (ADDR_OF 51 over a pass-1 modlet cell or fn)
 *   `let h: *u8 = inc` (VAR 3 naming a same-module fn)
 *   TYPE_FN init `inc as ...` (AS 54 over a fn)
 *
 * Pass-1 cells (independently knowable at hoist time, before the
 * modlet table exists): mutable scalar LIT/BOOL (init 0/2,
 * is_const==0) and TYPE_ARRAY + ARRAY_LIT (tk 10, ik 46).
 *
 * Rejects VAR copies of another pointer/fn-ptr let (`let g = f`) so
 * those keep historic hoist. Rejects ADDR_OF of const scalars
 * (prepare does not give them a cell).
 *
 * Hoist skip and prepare register MUST agree (9.6.0 dual-home class).
 * @param arena *u8 - ASTArena
 * @param m *u8 - Module* (fn lookup + top-level let scan; null → 0)
 * @param init_ref i32 - scalar let init expr
 * @return i32 - 1 bake-able address init; 0 keep hoist
 * PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA unsigned64.
 */
function pipe_modlet_scalar_init_is_ptr_addr(
  arena: *u8, m: *u8, init_ref: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let fi: i32 = 0;
  let nlets: i32 = 0;
  let tl: i32 = 0;
  let nlen: i32 = 0;
  let k: i32 = 0;
  let b: i32 = 0;
  let same: i32 = 0;
  let t_init: i32 = 0;
  let t_ik: i32 = 0;
  let t_tr: i32 = 0;
  let t_tk: i32 = 0;
  let t_const: i32 = 0;
  let nexprs: i32 = 0;
  if (arena == (0 as *u8) || m == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ek == 54) {
    unsafe {
      nref = pipeline_expr_as_operand_ref_at(arena, init_ref);
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        nref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
      }
    } else {
      if (ek != 3) {
        return 0;
      }
      nref = init_ref;
    }
  }
  if (nref <= 0) {
    return 0;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, nref);
  }
  if (ek != 3) {
    return 0;
  }
  unsafe {
    vlen = pipeline_expr_var_name_len(arena, nref);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, nref, &name[0]);
    fi = glue_module_func_index_by_name_c(m, &name[0], vlen);
  }
  if (fi >= 0) {
    return 1;
  }
  if (is_addr_of == 0) {
    return 0;
  }
  // ADDR_OF of a pass-1 modlet cell. Walk the module lets (not the
  // live table) so hoist — which runs before prepare — agrees.
  nlets = pipe_mod_get_num_top_level_lets(m);
  nexprs = pipe_load_i32_le(arena, pipe_arena_off_num_exprs());
  tl = 0;
  while (tl < nlets) {
    unsafe {
      nlen = pipeline_module_top_level_let_name_len(m, tl);
    }
    if (nlen == vlen) {
      same = 1;
      k = 0;
      while (k < nlen) {
        unsafe {
          b = pipeline_module_top_level_let_name_byte_at(m, tl, k);
        }
        if (b != (name[k] as i32)) {
          same = 0;
          break;
        }
        k = k + 1;
      }
      if (same != 0) {
        unsafe {
          t_const = pipeline_module_top_level_let_is_const(m, tl);
          t_init = pipeline_module_top_level_let_init_ref(m, tl);
          t_tr = pipeline_module_top_level_let_type_ref(m, tl);
        }
        t_ik = 0;
        t_tk = 0;
        if (t_init > 0 && t_init <= nexprs) {
          unsafe {
            t_ik = pipeline_expr_kind_ord_at(arena, t_init);
          }
        }
        if (t_tr > 0) {
          unsafe {
            t_tk = pipeline_type_kind_ord_at(arena, t_tr);
          }
        }
        if (t_const == 0 && (t_ik == 0 || t_ik == 2)) {
          return 1;
        }
        if (t_tk == 10 && t_ik == 46) {
          return 1;
        }
        return 0;
      }
    }
    tl = tl + 1;
  }
  return 0;
}

/**
 * Store ARRAY_LIT LIT elems into COMMON already LEA'd in rbx.
 * One nested ARRAY_LIT level is enough for `[K][N]T` rows; deeper
 * nest is a later leaf. Empty lit is a no-op (BSS zero).
 * 9.4.2: ptr/fn-typed tables with address elems (bare fn / `fn as *u8` /
 * `&global`) store the link-time address via
 * pipe_modlet_seed_ptr_addr_elem_to_rbx — `m` feeds the fn lookup.
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param init_ref i32 - ARRAY_LIT expr
 * @param elem_ty i32 - dest elem type_ref (scalar or TYPE_ARRAY row)
 * @param ta i32 - 0=x86_64 1=arm64
 * @param base_off i32 - byte offset in the COMMON cell
 * @param m *u8 - Module* (address-elem fn lookup; may be null)
 * @return i32 - 0 ok; -1 store fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_seed_array_lit_elems_to_rbx(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32, ta: i32, base_off: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let ev: i32 = 0;
  let esz: i32 = 4;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let hi: i32 = 0;
  let sa: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ty);
    }
  }
  if (etk == 10) {
    unsafe {
      inner_et = pipeline_type_elem_ref_at(arena, elem_ty);
      ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    }
    row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
    if (row_sz <= 0) {
      row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
    }
    // ne<=0: empty row lit is a no-op (BSS zero). ne>1024: entry-seed code
    // bound — loud-fail instead of the historic silent zero fill.
    if (ne <= 0) {
      return 0;
    }
    if (ne > 1024) {
      return 0 - 1;
    }
    ei = 0;
    while (ei < ne) {
      unsafe {
        eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
      }
      if (eref > 0) {
        unsafe {
          ek = pipeline_expr_kind_ord_at(arena, eref);
        }
        if (ek == 46) {
          rc = pipe_modlet_seed_array_lit_elems_to_rbx(
            arena, elf_ctx, eref, inner_et, ta, base_off + ei * row_sz, m);
          if (rc != 0) {
            return rc;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
  esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    esz = 4;
  }
  unsafe {
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  // ne<=0: empty lit is a no-op (BSS zero). ne>1024: entry-seed code-size
  // bound (~16B emitted per elem) — loud-fail instead of silent zero fill.
  if (ne <= 0) {
    return 0;
  }
  if (ne > 1024) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    }
    if (eref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, eref);
      }
      // STRING_LIT elem: emit the string bytes inline in .text and LEA
      // their address (rax/x0), then store esz bytes at rbx+off. Cells
      // reach here when the .data bake+pool does not fit (budget or
      // 9.4.2 ADDR_OF neighbor); loud-fails on len > 126 (jmp-skip cap).
      if (ek == 59) {
        unsafe {
          rc = glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, eref, ta);
        }
        if (rc != 0) {
          return rc;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + ei * esz, esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        if ((etk == 9 || etk == 18) && m != (0 as *u8)) {
          // 9.4.2 address-valued elem (bare fn / `fn as *u8` / `&global`):
          // resolve the link-time address at hoist-target entry and store
          // 8B into COMMON. sa==1 → not an address literal, fall through
          // to the const fold (which loud-fails, keeping old behavior).
          sa = pipe_modlet_seed_ptr_addr_elem_to_rbx(
            arena, elf_ctx, m, eref, esz, base_off + ei * esz, ta);
          if (sa < 0) {
            return 0 - 1;
          }
          if (sa == 0) {
            ei = ei + 1;
            continue;
          }
        }
        // LIT / EXPR_NEG-over-LIT elem: fold to the constant value. A
        // negative imm passes hi=-1 so the (hi:lo) imm64 halves rebuild
        // the two's-complement value in rax before the esz store. Any
        // other elem kind is not a compile-time constant: loud-fail
        // (was: silently skipped, leaving the elem zero at runtime).
        if (pipe_modlet_array_lit_elem_const_val(arena, eref, &ev) == 0) {
          return 0 - 1;
        }
        hi = 0;
        if (ev < 0) {
          hi = 0 - 1;
        }
        unsafe {
          rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, ev, hi, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, base_off + ei * esz, esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Seed one address-valued ARRAY_LIT elem (9.4.2) at rbx+off.
 * Accepts bare same-module fn (VAR 3), `fn as *u8` (AS 54), and ADDR_OF
 * (51) over a global let or fn. The address is resolved at hoist-target
 * entry: bare/AS fn name → link symbol (pipe_modlet_lea_fn_sym_to_rax),
 * ADDR_OF → modlet COMMON cell address first, then fn symbol (shared
 * resolver). A VAR naming a module let is a VALUE copy, not an address
 * literal: return 1 so the caller's const fold loud-fails (historic
 * behavior, never a silent zero).
 * @param arena *u8 - ASTArena
 * @param elf_ctx *u8 - ElfCodegenCtx
 * @param m *u8 - Module*
 * @param eref i32 - element expr ref
 * @param esz i32 - dest elem byte size (must be 8: pointers/fn addrs)
 * @param off i32 - byte offset of the elem inside the COMMON cell
 * @param ta i32 - target arch
 * @return i32 - 0 = stored; 1 = not an address elem (caller falls back
 *         to the const fold); -1 = loud fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
function pipe_modlet_seed_ptr_addr_elem_to_rbx(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, off: i32, ta: i32
): i32 {
  let ek: i32 = 0;
  let is_addr_of: i32 = 0;
  let nref: i32 = 0;
  let vlen: i32 = 0;
  let name: u8[256] = [];
  let fi: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  if (ek == 54) {
    unsafe {
      nref = pipeline_expr_as_operand_ref_at(arena, eref);
    }
  } else {
    if (ek == 51) {
      is_addr_of = 1;
      unsafe {
        nref = pipeline_expr_unary_operand_ref_at(arena, eref);
      }
    } else {
      if (ek != 3) {
        return 1;
      }
      nref = eref;
    }
  }
  if (nref <= 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, nref);
  }
  if (ek != 3) {
    return 1;
  }
  unsafe {
    vlen = pipeline_expr_var_name_len(arena, nref);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, nref, &name[0]);
  }
  if (is_addr_of != 0) {
    // &global → COMMON cell address (modlet-first); &fn → link symbol.
    rc = pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx, m, &name[0], vlen, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    if (m == (0 as *u8)) {
      return 1;
    }
    unsafe {
      fi = glue_module_func_index_by_name_c(m, &name[0], vlen);
    }
    if (fi < 0) {
      // Bare name that is not a same-module fn (module-let value copy):
      // not an address literal — the const fold loud-fails downstream.
      return 1;
    }
    rc = pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &name[0], vlen, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  if (esz != 8) {
    // Pointer/fn addresses are 8B; narrower elem types never reach here.
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, off, esz, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

function pipe_modlet_set_n(n: i32): void {
  pipe_store_i32_le(&g_pipeline_asm_modlet[0], pipe_modlet_off_n(), n);
}

/**
 * Write 8 lowercase hex digits of a 32-bit value into the modlet label slot.
 * @param lbase i32 — byte offset of label[idx] in g_pipeline_asm_modlet
 * @param off i32 — write offset 0..15 within that 24-byte label
 * @param v i64 — value; only low 32 bits are written
 * @return void
 * PLATFORM: SHARED — label field is 24 bytes (Stage 12.0.5 layout).
 */
function pipe_modlet_write_hex8(lbase: i32, off: i32, v: i64): void {
  let i: i32 = 0;
  while (i < 8) {
    let shift: i32 = (7 - i) * 4;
    let nib: i32 = ((v >> shift) & 15) as i32;
    let ch: u8 = 48 as u8;
    if (nib >= 10) {
      ch = (87 + nib) as u8;
    } else {
      ch = (48 + nib) as u8;
    }
    unsafe {
      g_pipeline_asm_modlet[lbase + off + i] = ch;
    }
    i = i + 1;
  }
}

/**
 * Find map slot for module pointer.
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_sl_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_sl_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Read module.num_struct_layouts header (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_sl_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_sl_off_header_n());
}

/**
 * Pointer to layout entry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - layout index
 * @return *u8 - entry base or null
 */
function pipe_sl_layout_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_sl_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_sl_layouts[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + (idx * pipe_sl_layout_size());
}

/**
 * Byte size of one pure StructLayout entry (C 160 + tp meta 8).
 * @return i32 - 296
 * PLATFORM: SHARED LP64.
 */
function pipe_sl_layout_size(): i32 {
  return 296;
}

/**
 * Offsets within pure layout entry.
 */
function pipe_sl_off_name_len(): i32 { return 256; }
function pipe_sl_off_field_base(): i32 { return 260; }
function pipe_sl_off_num_fields(): i32 { return 264; }
function pipe_sl_off_allow_padding(): i32 { return 268; }
function pipe_sl_off_soa(): i32 { return 272; }
function pipe_sl_off_packed(): i32 { return 276; }
function pipe_sl_off_repr_compatible(): i32 { return 280; }
function pipe_sl_off_is_export(): i32 { return 284; }
function pipe_sl_off_tp_base(): i32 { return 288; }
function pipe_sl_off_tp_count(): i32 { return 292; }

/**
 * Offsets within field entry.
 */
function pipe_sl_foff_name_len(): i32 { return 256; }
function pipe_sl_foff_offset(): i32 { return 260; }
function pipe_sl_foff_type_ref(): i32 { return 264; }
function pipe_sl_foff_align(): i32 { return 268; }

/**
 * LP64 offsetof(struct ast_Module, num_struct_layouts) == 16.
 * @return i32 - 16
 * PLATFORM: SHARED LP64.
 */
function pipe_sl_off_header_n(): i32 {
  return 16;
}

/**
 * Soft-reset pure counts when header num_struct_layouts is 0.
 * Zeros layout/field/tp live n; keeps malloc capacity.
 * @param module *u8 - module key
 * @return void
 */
function pipe_sl_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_sl_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_sl_n[s] = 0;
  g_pipe_sl_fn[s] = 0;
  g_pipe_sl_tpn[s] = 0;
}

/**
 * Store host LE i32 at base[off..off+3]. Null base or off negative -> no-op.
 * @param base *u8 - object base
 * @param off i32 - byte offset
 * @param v i32 - value
 * @return void
 * G.7 same pattern as driver_abi_store_i32_le (wave19); local copy - not exported.
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_i32_le(base: *u8, off: i32, v: i32): void {
  if (base == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    let u: u32 = v as u32;
    base[off] = (u & 255) as u8;
    base[off + 1] = ((u / 256) & 255) as u8;
    base[off + 2] = ((u / 65536) & 255) as u8;
    base[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/**
 * Store little-endian pointer into base[i] (LP64 8-byte cell).
 * Module-local pair of pipe_load_ptr_slot (no second G.7 path).
 * @param base *u8 - table base; null -> no-op
 * @param i i32 - slot index; i < 0 -> no-op
 * @param val *u8 - pointer bits to store (may be null)
 * @return void
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void {
  if (base == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  let off: i32 = i * 8;
  unsafe {
    let m: usize = 256 as usize;
    let b255: usize = 255 as usize;
    let u0: usize = val as usize;
    base[off] = (u0 & b255) as u8;
    let u1: usize = u0 / m;
    base[off + 1] = (u1 & b255) as u8;
    let u2: usize = u1 / m;
    base[off + 2] = (u2 & b255) as u8;
    let u3: usize = u2 / m;
    base[off + 3] = (u3 & b255) as u8;
    let u4: usize = u3 / m;
    base[off + 4] = (u4 & b255) as u8;
    let u5: usize = u4 / m;
    base[off + 5] = (u5 & b255) as u8;
    let u6: usize = u5 / m;
    base[off + 6] = (u6 & b255) as u8;
    let u7: usize = u6 / m;
    base[off + 7] = (u7 & b255) as u8;
  }
}

/**
 * Pointer to TopLevelLetEntry at (slot, idx); null if OOB.
 * @param slot i32 - map slot
 * @param idx i32 - entry index
 * @return *u8 - entry base or null
 */
function pipe_tl_entry_at(slot: i32, idx: i32): *u8 {
  if (slot < 0) {
    return 0 as *u8;
  }
  if (slot >= 128) {
    return 0 as *u8;
  }
  if (idx < 0) {
    return 0 as *u8;
  }
  if (idx >= g_pipe_tl_n[slot]) {
    return 0 as *u8;
  }
  let base: *u8 = xlang_ptr_slot_get(&g_pipe_tl_entries[0], slot);
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  return base + pipe_tl_entry_off(idx);
}

/**
 * Byte offset of entry idx within the flat entry table.
 * @param idx i32 - entry index
 * @return i32 - byte offset
 */
function pipe_tl_entry_off(idx: i32): i32 {
  return idx * pipe_tl_entry_size();
}

/**
 * Byte size of one TopLevelLetEntry (name + 5 i32 fields).
 * @return i32 - 276
 * PLATFORM: SHARED LP64 - must match C sizeof(TopLevelLetEntry).
 */
function pipe_tl_entry_size(): i32 {
  return 276;
}

/**
 * Find map slot for module pointer (exact key match).
 * @param module *u8 - module key; null -> -1
 * @return i32 - slot 0..127 or -1
 */
function pipe_tl_find_slot(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < 128) {
    let k: *u8 = xlang_ptr_slot_get(&g_pipe_tl_mod[0], i);
    if (k == module) {
      return i;
    }
    i = i + 1;
  }
  return 0 - 1;
}

/**
 * Read module.num_top_level_lets header field (null -> 0).
 * @param module *u8 - opaque ast_Module
 * @return i32 - header count
 */
function pipe_tl_get_header_n(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_tl_off_header_n());
}

/**
 * LP64 offsetof(struct ast_Module, num_top_level_lets).
 * @return i32 - 12
 * PLATFORM: SHARED LP64 - dual-end; see pipe_mod_off_num_top_level_lets.
 */
function pipe_tl_off_header_n(): i32 {
  return 12;
}

/**
 * Byte offset of init_ref within TopLevelLetEntry.
 * @return i32 - 264
 */
function pipe_tl_off_init_ref(): i32 {
  return 264;
}

/**
 * Byte offset of is_const within TopLevelLetEntry.
 * @return i32 - 140
 */
function pipe_tl_off_is_const(): i32 {
  return 268;
}

/**
 * Byte offset of name_len within TopLevelLetEntry.
 * @return i32 - 128
 */
function pipe_tl_off_name_len(): i32 {
  return 256;
}

/**
 * Byte offset of type_ref within TopLevelLetEntry.
 * @return i32 - 260
 */
function pipe_tl_off_type_ref(): i32 {
  return 260;
}

/**
 * Soft-reset pure counts when header num_top_level_lets is 0 (parse/module reset).
 * Keeps malloc capacity; zeros live n.
 * @param module *u8 - module key
 * @return void
 */
function pipe_tl_soft_sync(module: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (pipe_tl_get_header_n(module) != 0) {
    return;
  }
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return;
  }
  g_pipe_tl_n[s] = 0;
}

/**
 * Copy n bytes src -> dst.
 * @param dst *u8 - destination
 * @param src *u8 - source
 * @param n i32 - count
 * PLATFORM: SHARED.
 */
function pipe_ty_copy_bytes(dst: *u8, src: *u8, n: i32): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (src == 0 as *u8) {
    return;
  }
  if (n <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      dst[i] = src[i];
    }
    i = i + 1;
  }
}

/**
 * Cap residual num_types via unsafe.
 * @param a *u8 - ASTArena*
 * @return i32 - type count
 * PLATFORM: SHARED.
 */
function pipe_ty_num_types(a: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = pipeline_arena_num_types(a);
  }
  return n;
}

/**
 * Cap residual type_ptr via unsafe.
 * @param a *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return *u8 - Type* or null
 * PLATFORM: SHARED.
 */
function pipe_ty_ptr(a: *u8, ref: i32): *u8 {
  let tp: *u8 = 0 as *u8;
  unsafe {
    tp = pipeline_arena_type_ptr(a, ref);
  }
  return tp;
}

/**
 * Resolve Type* for ref with bounds check.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - 1-based type ref
 * @return *u8 - Type* or null
 * PLATFORM: SHARED.
 */
function pipe_ty_slot_at(arena: *u8, ref: i32): *u8 {
  if (arena == 0 as *u8) {
    return 0 as *u8;
  }
  if (ref <= 0) {
    return 0 as *u8;
  }
  let nt: i32 = pipe_ty_num_types(arena);
  if (ref > nt) {
    return 0 as *u8;
  }
  return pipe_ty_ptr(arena, ref);
}

/**
 * Read arena.num_types.
 * @param a *u8
 * @return i32
 * wave276 pure Cap leave. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_arena_num_types(a: *u8): i32 {
  if (a == 0 as *u8) {
    return 0;
  }
  return pipe_ar_load_i32(a, pipe_ar_off_num_types());
}

/**
 * Main-pool Type* for 1-based ref.
 * @param a *u8 - ASTArena*
 * @param ref i32 - 1-based type ref
 * @return *u8 - Type* or null
 * wave276 pure Cap leave. PLATFORM: SHARED freestanding arena leave.
 */
#[no_mangle]
export function pipeline_arena_type_ptr(a: *u8, ref: i32): *u8 {
  if (a == 0 as *u8) {
    return 0 as *u8;
  }
  if (ref <= 0) {
    return 0 as *u8;
  }
  let nt: i32 = pipe_ar_load_i32(a, pipe_ar_off_num_types());
  if (ref > nt) {
    return 0 as *u8;
  }
  let sc: *u8 = arena_sidecar_get(a, 0);
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  return grow_vec_at(sc + (pipe_ar_sc_types() as usize), ref - 1);
}

/**
 * Get current emit AST arena pointer.
 * @return *u8 — ast_ASTArena* as *u8, or null
 * wave221 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_arena_get(): *u8 {
  return g_pipeline_asm_emit_arena;
}

/**
 * Get current asm emit dep pipe pointer.
 * @return *u8 — ast_PipelineDepCtx* as *u8, or null
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_dep_pipe_get(): *u8 {
  return g_pipeline_asm_emit_dep_pipe;
}

/**
 * Get current asm emit module pointer.
 * @return *u8 — ast_Module* as *u8, or null
 * wave222 pure: G.7 authority (was Cap residual glue_statics).
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_ctx_module_get(): *u8 {
  return g_pipeline_asm_emit_module;
}

/**
 * Read the current emit dep pipe.
 * @return *u8 - PipelineDepCtx* or null
 * wave141 pure: G.7 authority (was pipeline_asm_emit_dep_pipe_c).
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function pipeline_asm_emit_dep_pipe_c(): *u8 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = pipeline_asm_emit_ctx_dep_pipe_get();
  }
  return p;
}

/**
 * Read the module currently being emitted.
 * @return *u8 - ast_Module* or null
 * wave141 pure: G.7 authority (was pipeline_asm_emit_module_ref_c).
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function pipeline_asm_emit_module_ref_c(): *u8 {
  let m: *u8 = 0 as *u8;
  unsafe {
    m = pipeline_asm_emit_ctx_module_get();
  }
  return m;
}

/**
 * Read dep ASTArena* at idx.
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @return *u8 - ASTArena* or null
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8 {
  if (ctx == 0 as *u8 || idx < 0) {
    return 0 as *u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  let ars: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas());
  if (idx >= pipe_gv_load_len(ars)) {
    return 0 as *u8;
  }
  let pa: *u8 = grow_vec_at(ars, idx);
  if (pa == 0 as *u8) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(pa, 0);
}

/**
 * Read dep Module* at idx.
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @return *u8 - Module* or null
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8 {
  if (ctx == 0 as *u8 || idx < 0) {
    return 0 as *u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
  if (idx >= pipe_gv_load_len(mods)) {
    return 0 as *u8;
  }
  let pm: *u8 = grow_vec_at(mods, idx);
  if (pm == 0 as *u8) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(pm, 0);
}

/**
 * Soft-sync ndep from sidecar modules.len if larger; return ndep.
 * @param ctx *u8
 * @return i32 - ndep or 0
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_ndep(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  let nd: i32 = pipe_load_i32_le(ctx, pipe_pctx_off_ndep());
  if (sc != 0 as *u8) {
    let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
    let ml: i32 = pipe_gv_load_len(mods);
    if (ml > nd) {
      pipe_store_i32_le(ctx, pipe_pctx_off_ndep(), ml);
      nd = ml;
    }
  }
  return nd;
}

/**
 * Add SHN_COMMON object symbol (linker BSS, writable). Used by modlet mutable lets.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || sym_size <= 0) {
    return -1;
  }
  let al: i32 = sym_align;
  if (al <= 0) {
    al = 8;
  }
  if (g_pipe_elf_common_owner != ctx_bytes) {
    pipe_elf_common_sidecar_reset(ctx_bytes);
  }
  if (pipeline_elf_ctx_add_sym(ctx_bytes, name, name_len, sym_size) != 0) {
    return -1;
  }
  let si: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_syms()) - 1;
  if (si < 0 || si >= pipe_elf_table_cap()) {
    return -1;
  }
  unsafe {
    g_pipe_elf_sym_is_common[si] = 1;
  }
  pipe_elf_bss_store_i32(&g_pipe_elf_sym_common_size[0], si, sym_size);
  pipe_elf_bss_store_i32(&g_pipe_elf_sym_common_align[0], si, al);
  let se: *u8 = pipe_elf_sym_at(ctx_bytes, si);
  pipe_store_i32_le(se, pipe_elf_sym_off_shndx(), 65522);
  return 0;
}

/**
 * Add or update a local label at offset in current emit section.
 * @return i32 - 0 ok, -1 full/null
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_label(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let shndx: i32 = pipe_elf_current_shndx(ctx_bytes);
  let nl: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_labels());
  let l: i32 = 0;
  while (l < nl) {
    let lab: *u8 = pipe_elf_label_at(ctx_bytes, l);
    let llen: i32 = pipe_load_i32_le(lab, pipe_elf_lab_off_name_len());
    if (pipe_elf_name_eq(lab + (pipe_elf_lab_off_name() as usize), llen, name, name_len) != 0) {
      pipe_store_i32_le(lab, pipe_elf_lab_off_offset(), offset);
      pipe_elf_label_shndx_set(ctx_bytes, l, shndx);
      return 0;
    }
    l = l + 1;
  }
  if (nl >= pipe_elf_table_cap()) {
    return -1;
  }
  let li: i32 = nl;
  let lab2: *u8 = pipe_elf_label_at(ctx_bytes, li);
  let n: i32 = name_len;
  // Cap 4.2.8: labels.name[256] content ≤255 (was wave580 128 → asm -o long-name CG002).
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    unsafe {
      memcpy(lab2 + (pipe_elf_lab_off_name() as usize), name, n as usize);
    }
  }
  pipe_store_i32_le(lab2, pipe_elf_lab_off_name_len(), n);
  pipe_store_i32_le(lab2, pipe_elf_lab_off_offset(), offset);
  pipe_elf_label_shndx_set(ctx_bytes, li, shndx);
  pipe_store_i32_le(ctx_bytes, pipe_elf_off_num_labels(), nl + 1);
  return 0;
}

/**
 * Record export symbol; name bytes go into sym_name_data pool (cap 131072).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_add_sym(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len < 0) {
    return -1;
  }
  let ns: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_syms());
  if (ns >= pipe_elf_table_cap()) {
    return -1;
  }
  if (g_pipe_elf_common_owner != ctx_bytes) {
    pipe_elf_common_sidecar_reset(ctx_bytes);
  }
  let copy_len: i32 = name_len;
  // Cap 4.2.8: sym name pool holds '_' + ≤255 AST content (was wave580 128).
  if (copy_len > 256) {
    copy_len = 256;
  }
  if (copy_len < 0) {
    copy_len = 0;
  }
  let snl: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_sym_name_len());
  if (snl + copy_len > 131072) {
    return -1;
  }
  let sym_pool: *u8 = ctx_bytes + (pipe_elf_off_sym_name_data() as usize);
  let k: i32 = 0;
  while (k < copy_len) {
    unsafe {
      sym_pool[snl + k] = name[k];
    }
    k = k + 1;
  }
  pipe_store_i32_le(ctx_bytes, pipe_elf_off_sym_name_len(), snl + copy_len);
  let se: *u8 = pipe_elf_sym_at(ctx_bytes, ns);
  pipe_store_i32_le(se, pipe_elf_sym_off_name_len(), copy_len);
  pipe_store_i32_le(se, pipe_elf_sym_off_offset(), offset);
  let shndx: i32 = pipe_elf_shnx_text();
  if (g_pipe_elf_shndx_override != 0) {
    shndx = g_pipe_elf_shndx_override;
  } else if (pipeline_elf_pgo_hot_enabled() != 0 && pipe_load_i32_le(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    shndx = pipe_elf_shnx_hot();
  } else if (pipeline_elf_pgo_hot_enabled() != 0) {
    shndx = pipe_elf_shnx_unlikely();
  }
  pipe_store_i32_le(se, pipe_elf_sym_off_shndx(), shndx);
  unsafe {
    g_pipe_elf_sym_is_common[ns] = 0;
  }
  pipe_store_i32_le(ctx_bytes, pipe_elf_off_num_syms(), ns + 1);
  return 0;
}

/**
 * Append machine code bytes into current emit section.
 * @return i32 - 0 ok, -1 full/null
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32 {
  if (ctx_bytes == 0 as *u8 || ptr == 0 as *u8 || n < 0) {
    return -1;
  }
  let buf: *u8 = 0 as *u8;
  let len_off: i32 = pipe_elf_off_code_len();
  let cap: i32 = pipe_elf_code_buf_cap();
  if (pipeline_elf_pgo_hot_enabled() != 0 && pipe_load_i32_le(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    buf = ctx_bytes + (pipe_elf_off_code_hot_data() as usize);
    len_off = pipe_elf_off_code_hot_len();
    cap = pipe_elf_code_hot_cap();
  } else {
    buf = ctx_bytes + (pipe_elf_off_code_data() as usize);
  }
  let cur: i32 = pipe_load_i32_le(ctx_bytes, len_off);
  if (cur + n > cap) {
    return -1;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      buf[cur + i] = ptr[i];
    }
    i = i + 1;
  }
  pipe_store_i32_le(ctx_bytes, len_off, cur + n);
  return 0;
}

/**
 * F7: Append `n` zero bytes to the data section buffer (reserve + clear).
 * Used by modlet prepare to place a .data cell before poking ARRAY_LIT bytes.
 * @param ctx_bytes *u8 — ElfCodegenCtx*
 * @param n i32 — byte count; n<=0 is a no-op success
 * @return i32 — 0 ok; -1 overflow/null
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0 - 1;
  }
  if (n <= 0) {
    return 0;
  }
  if (g_pipe_elf_data_len < 0) {
    g_pipe_elf_data_len = 0;
  }
  if (g_pipe_elf_data_len + n > 65536) {
    return 0 - 1;
  }
  let off: i32 = g_pipe_elf_data_len;
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      g_pipe_elf_data_buf[off + i] = 0 as u8;
    }
    i = i + 1;
  }
  g_pipe_elf_data_len = off + n;
  return 0;
}

/**
 * Append external reloc; >TABLE_CAP uses heap sidecar.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32 {
  if (ctx_bytes == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
    return -1;
  }
  unsafe {
    if (name[0] == 0) {
      return -1;
    }
  }
  let nr: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_relocs());
  if (nr >= pipe_elf_reloc_total_cap()) {
    return -1;
  }
  let ri: i32 = nr;
  let sym_row: *u8 = 0 as *u8;
  if (ri < pipe_elf_table_cap()) {
    let ent: *u8 = pipe_elf_reloc_at(ctx_bytes, ri);
    pipe_store_i32_le(ent, pipe_elf_rel_off_offset(), offset);
    sym_row = pipe_elf_reloc_name_row(ctx_bytes, ri);
  } else {
    if (g_pipe_elf_reloc_sidecar_owner != ctx_bytes) {
      pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
    }
    let hi: i32 = ri - pipe_elf_table_cap();
    let hent: *u8 = pipe_elf_reloc_heap_at(hi);
    if (hent == 0 as *u8) {
      return -1;
    }
    pipe_store_i32_le(hent, pipe_elf_rh_off_offset(), offset);
    sym_row = pipe_elf_reloc_sym_heap_at(hi);
  }
  pipe_elf_reloc_shndx_set(ctx_bytes, ri, pipe_elf_current_shndx(ctx_bytes));
  // Cap 4.2.8: reloc_sym_names.bytes[256] (was wave580 memset/clamp 128).
  unsafe {
    memset(sym_row, 0, 256 as usize);
  }
  let n: i32 = name_len;
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  if (n > 0) {
    unsafe {
      memcpy(sym_row, name, n as usize);
    }
  }
  if (ri < pipe_elf_table_cap()) {
    let ent2: *u8 = pipe_elf_reloc_at(ctx_bytes, ri);
    pipe_store_i32_le(ent2, pipe_elf_rel_off_name_len(), n);
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_r_type[0], ri, 0);
    unsafe {
      g_pipe_elf_reloc_r_pcrel[ri] = 255;
    }
  } else {
    let hi2: i32 = ri - pipe_elf_table_cap();
    let h2: *u8 = pipe_elf_reloc_heap_at(hi2);
    if (h2 != 0 as *u8) {
      pipe_store_i32_le(h2, pipe_elf_rh_off_name_len(), n);
    }
  }
  pipe_store_i32_le(ctx_bytes, pipe_elf_off_num_relocs(), nr + 1);
  return 0;
}

/**
 * Append an absolute 64-bit pointer relocation (data slot holding a symbol address).
 *
 * F7 vtable statics store function pointers in a read-only data array, mirroring
 * the -E codegen path's `static void* vtable[] = { &wrapper_fn };`. Such a slot
 * requires an ABSOLUTE pointer reloc — NOT the default pc-relative branch reloc
 * that the untyped `pipeline_elf_ctx_append_reloc` produces (which on Mach-O
 * defaults to ARM64_RELOC_BRANCH26 and is rejected by ld on non-b/bl bytes).
 *
 * Sentinels:
 *   - r_type  = 200 (sentinel "absolute64"; both writers map to platform type)
 *   - r_pcrel = 0   (absolute, not pc-relative)
 *
 * The writers (Mach-O @ pipeline_macho_write_o_to_buf_c, ELF @
 * pipeline_elf_write_o_standard_to_buf_c) recognize r_type==200 and emit:
 *   - Mach-O arm64: r_type=0 (ARM64_RELOC_UNSIGNED), r_pcrel=0, r_length=3
 *   - ELF x86_64:   R_X86_64_64 (=1) with r_addend=0
 *   - ELF arm64:    R_AARCH64_ABS64 (=257) with r_addend=0
 *   - ELF riscv64:  R_RISCV_64 (=2) with r_addend=0
 *
 * @param ctx_bytes *u8  ElfCodegenCtx
 * @param offset    i32  byte offset within the section where the 8-byte slot lives
 * @param name      *u8  symbol name bytes (the wrapper function / target symbol)
 * @param name_len  i32  length of name
 * @return i32 0 ok, -1 fail
 * PLATFORM: SHARED freestanding ELF leave — G.7 single authority for absolute64.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc_absolute64(
  ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32 {
  /* r_type=200 sentinel; r_pcrel=0 (absolute). Writers map 200 → platform type. */
  return pipeline_elf_ctx_append_reloc_typed(ctx_bytes, offset, name, name_len, 200, 0);
}

/**
 * Append reloc with explicit r_type / r_pcrel (arm64 ADRP/PAGEOFF modlet).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_append_reloc_typed(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32, r_type: i32, r_pcrel: i32): i32 {
  if (pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len) != 0) {
    return -1;
  }
  let ri: i32 = pipe_load_i32_le(ctx_bytes, pipe_elf_off_num_relocs()) - 1;
  if (ri >= 0 && ri < pipe_elf_table_cap()) {
    pipe_elf_bss_store_i32(&g_pipe_elf_reloc_r_type[0], ri, r_type);
    if (r_pcrel < 0) {
      unsafe {
        g_pipe_elf_reloc_r_pcrel[ri] = 255;
      }
    } else {
      let pv: u8 = 0;
      if (r_pcrel != 0) {
        pv = 1;
      }
      unsafe {
        g_pipe_elf_reloc_r_pcrel[ri] = pv;
      }
    }
  }
  return 0;
}

/**
 * F7: Poke one byte into an already-reserved data-section offset.
 * @param ctx_bytes *u8 — ElfCodegenCtx*
 * @param off i32 — absolute offset within g_pipe_elf_data_buf
 * @param b i32 — byte value (low 8 bits)
 * @return i32 — 0 ok; -1 OOB/null
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 */
#[no_mangle]
export function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32 {
  if (ctx_bytes == 0 as *u8 || off < 0 || off >= g_pipe_elf_data_len) {
    return 0 - 1;
  }
  unsafe {
    g_pipe_elf_data_buf[off] = (b & 255) as u8;
  }
  return 0;
}

/**
 * Current emit section encoded length (x86 call patch rel32_at relative to this).
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_emit_code_len(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  if (pipeline_elf_pgo_hot_enabled() != 0 && pipe_load_i32_le(ctx_bytes, pipe_elf_off_emit_hot()) != 0) {
    return pipe_load_i32_le(ctx_bytes, pipe_elf_off_code_hot_len());
  }
  return pipe_load_i32_le(ctx_bytes, pipe_elf_off_code_len());
}

/**
 * F7: Current data section length (bytes already emitted to data buf).
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  return g_pipe_elf_data_len;
}

/**
 * Read macho_leading_underscore (Darwin call/reloc prefix '_').
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_macho_leading_underscore(ctx_bytes: *u8): i32 {
  if (ctx_bytes == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(ctx_bytes, pipe_elf_off_macho_uscore());
}

/**
 * Bind reloc sidecar owner; clear typed reloc rows; reset shndx sidecars.
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes: *u8): void {
  g_pipe_elf_reloc_sidecar_owner = ctx_bytes;
  pipe_elf_shndx_sidecar_reset(ctx_bytes);
  unsafe {
    memset(&g_pipe_elf_reloc_r_type[0], 0, 65536 as usize);
    memset(&g_pipe_elf_reloc_r_pcrel[0], 255, 16384 as usize);
  }
}

/**
 * F7: Set/clear shndx override. When set to 4 (data section), subsequent
 * relocs/syms/labels are tagged as data-section. Set to 0 to restore default
 * (text section). Single-threaded compile; safe as a global mutable.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_ctx_set_shndx_override(ctx_bytes: *u8, shndx: i32): void {
  g_pipe_elf_shndx_override = shndx;
}

/**
 * XLANG_WPO_PGO_HOT=1 enables .text.hot dual-section emit.
 * @return i32 - 1 enabled, 0 off
 * wave273 pure-owned leave.
 * PLATFORM: SHARED freestanding ELF leave.
 */
#[no_mangle]
export function pipeline_elf_pgo_hot_enabled(): i32 {
  let e: *u8 = 0 as *u8;
  unsafe {
    e = link_abi_getenv("XLANG_WPO_PGO_HOT");
  }
  if (e == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      if (e[1] == 0 || e[1] == 10) {
        return 0;
      }
    }
  }
  return 1;
}

/**
 * Read module.num_funcs (null -> 0).
 * @param module *u8 - opaque ast_Module*
 * @return i32 - function count
 * wave121 pure: G.7 single product authority (was pipeline_lint_meta.c).
 * PLATFORM: SHARED - sole provider after lint_meta leave.
 */
#[no_mangle]
export function pipeline_module_num_funcs(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(module, pipe_mod_off_num_funcs());
}

/**
 * Read module.num_struct_layouts (header; soft-sync pure map).
 * @param module *u8 - module
 * @return i32 - count or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_num_struct_layouts_at(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  return pipe_sl_get_header_n(module);
}

/**
 * Read one layout name byte; return i32 for Cap export-extern contract.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @param off i32 - byte offset 0..127
 * @return i32 - byte or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_name_byte_at(module: *u8, idx: i32, off: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  if (off >= 128) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  let nlen: i32 = pipe_load_i32_le(sl, pipe_sl_off_name_len());
  if (off >= nlen) {
    return 0;
  }
  unsafe {
    return sl[off] as i32;
  }
}

/**
 * Read layout name length.
 * @param module *u8 - module
 * @param idx i32 - layout index
 * @return i32 - name_len or 0
 */
#[no_mangle]
export function pipeline_module_struct_layout_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_sl_soft_sync(module);
  let s: i32 = pipe_sl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let sl: *u8 = pipe_sl_layout_at(s, idx);
  if (sl == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(sl, pipe_sl_off_name_len());
}

/**
 * Read init_ref of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - init_ref or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_init_ref(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_init_ref());
}

/**
 * Read is_const flag of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - is_const or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_is_const(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_is_const());
}

/**
 * Read one name byte of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @param off i32 - byte offset 0..126
 * @return i32 - name byte (0..255) or 0; i32 matches prior Cap export extern contract
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_name_byte_at(module: *u8, idx: i32, off: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  if (off >= 127) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  let nlen: i32 = pipe_load_i32_le(e, pipe_tl_off_name_len());
  if (off >= nlen) {
    return 0;
  }
  unsafe {
    return e[off] as i32;
  }
}

/**
 * Read name length of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - name_len or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_name_len(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_name_len());
}

/**
 * Read type_ref of top-level let idx.
 * @param module *u8 - module
 * @param idx i32 - let index
 * @return i32 - type_ref or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  pipe_tl_soft_sync(module);
  let s: i32 = pipe_tl_find_slot(module);
  if (s < 0) {
    return 0;
  }
  let e: *u8 = pipe_tl_entry_at(s, idx);
  if (e == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(e, pipe_tl_off_type_ref());
}

/**
 * Read Type.array_size.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - array_size or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_array_size_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(t, pipe_ar_ty_arr());
}

/**
 * Read Type.elem_type_ref.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - elem ref or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  return pipe_load_i32_le(t, pipe_ar_ty_elem());
}

/**
 * Read Type.kind ordinal; -1 invalid.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @return i32 - kind or -1
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32 {
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0 - 1;
  }
  return pipe_load_i32_le(t, 0);
}

/**
 * Copy Type.name into out64; return name_len.
 * @param arena *u8 - ASTArena*
 * @param ref i32 - type ref
 * @param out64 *u8 - buffer
 * @return i32 - full name_len or 0
 * wave270 pure Cap leave.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32 {
  if (out64 == 0 as *u8) {
    return 0;
  }
  let t: *u8 = pipe_ty_slot_at(arena, ref);
  if (t == 0 as *u8) {
    return 0;
  }
  let n: i32 = pipe_load_i32_le(t, pipe_ar_ty_name_len());
  let cn: i32 = n;
  if (cn > 255) {
    cn = 255;
  }
  if (cn > 0) {
    pipe_ty_copy_bytes(out64, t + 4, cn);
  }
  return n;
}

/**
 * Load pointer slot i from a char-star / void-star array base (G.7 pair with set).
 * @param arr *u8 - table base; null -> null
 * @param i i32 - index; i < 0 -> null
 * @return *u8 - pointer at slot (may be null)
 * wave46 pure. PLATFORM: SHARED LP64.
 * Note: never put the two-char end-comment marker inside prose (truncates the block).
 */
#[no_mangle]
export function xlang_ptr_slot_get(arr: *u8, i: i32): *u8 {
  if (arr == 0 as *u8) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(arr, i);
}

/**
 * Write pointer p into char-star / void-star array slot i (G.7 product authority).
 * @param arr *u8 - void** / char** table base as bytes; null -> no-op
 * @param i i32 - slot index; i < 0 -> no-op
 * @param p *u8 - pointer to store (may be null)
 * @return void
 * wave46 pure; driver_abi / fmt_check call this as Cap residual surface.
 * PLATFORM: SHARED LP64 - single authority in this TU under PREFER hybrid.
 */
#[no_mangle]
export function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void {
  pipe_store_ptr_slot(arr, i, p);
}

/**
 * Load size_t / i64 slot i from an array of LP64 8-byte cells (LE).
 * @param arr *u8 - size_t* base as bytes; null -> 0
 * @param i i32 - index; i < 0 -> 0
 * @return i64 - cell value as signed i64 (path lengths fit)
 * wave46 pure Cap residual; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_size_slot_get(arr: *u8, i: i32): i64 {
  if (arr == 0 as *u8) {
    return 0;
  }
  if (i < 0) {
    return 0;
  }
  // Same LE reconstruct as pipe_load_ptr_slot; cast pointer bits -> i64 length.
  let p: *u8 = pipe_load_ptr_slot(arr, i);
  return p as i64;
}

/**
 * Store size_t / i64 into arr[i] (LP64 8-byte LE cell).
 * @param arr *u8 - size_t* base as bytes; null -> no-op
 * @param i i32 - index; i < 0 -> no-op
 * @param v i64 - value (path length / buffer size)
 * @return void
 * wave46 pure; pairs xlang_size_slot_get. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  pipe_store_ptr_slot(arr, i, v as *u8);
}
