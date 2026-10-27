// 10.53: Cap tip seed_nonzero — re-fold module f64 lets from AST so hi
// bits are not lost when table init_imm is still 32-bit (bak_cap).
export extern "C" function backend_enc_mov_imm64_to_rax_arch(
  elf_ctx: *u8, lo: i32, hi: i32, ta: i32
): i32;
export extern function pipeline_asm_modlet_store_from_rax_elf_c(
  elf_ctx: *u8, name: *u8, name_len: i32, ta: i32
): i32;
export extern function pipeline_asm_modlet_lea_rbx_arch(
  elf_ctx: *u8, idx: i32, ta: i32
): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function pipeline_module_main_func_index(m: *u8): i32;
export extern function pipe_mod_get_num_top_level_lets(m: *u8): i32;
export extern "C" function pipeline_module_top_level_let_name_len(m: *u8, tl: i32): i32;
export extern "C" function pipeline_module_top_level_let_name_byte_at(m: *u8, tl: i32, k: i32): i32;
export extern "C" function pipeline_module_top_level_let_init_ref(m: *u8, tl: i32): i32;
export extern "C" function pipeline_module_top_level_let_type_ref(m: *u8, tl: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, tr: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, eref: i32): i32;
export extern function pipe_modlet_fold_f64_elem_bits(
  arena: *u8, eref: i32, out_lo: *i32, out_hi: *i32
): i32;
export extern function pipe_modlet_get_n(): i32;
export extern function pipe_modlet_off_init_imm(i: i32): i32;
export extern function pipe_modlet_off_name_len(i: i32): i32;
export extern function pipe_modlet_off_name(i: i32): i32;
export extern function pipe_modlet_off_cell_size(i: i32): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_modlet_cell_is_array(csz: i32): i32;
export extern function pipe_modlet_cell_is_data(csz: i32): i32;
export extern function pipeline_asm_modlet_find(name: *u8, name_len: i32): i32;
export extern function pipe_modlet_seed_array_lit_elems_to_rbx(
  arena: *u8, elf_ctx: *u8, lit: i32, et: i32, ta: i32, base: i32, m: *u8
): i32;
export extern function pipe_arena_off_num_exprs(): i32;
export extern function pipe_modlet_table_base(): *u8;

#[no_mangle]
export function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32 {
  if (elf_ctx == 0 as *u8 || (ta != 0 && ta != 1)) {
    return 0;
  }
  let mod0: *u8 = 0 as *u8;
  let arena: *u8 = 0 as *u8;
  let mod: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  let tab: *u8 = 0 as *u8;
  unsafe { mod0 = pipeline_asm_emit_module_ref_c(); }
  if (mod0 != (0 as *u8)) {
    let mi: i32 = 0;
    unsafe { mi = pipeline_module_main_func_index(mod0); }
    if (mi < 0) {
      return 0;
    }
  }
  unsafe { arena = pipeline_asm_emit_ctx_arena_get(); }
  mod = mod0;
  unsafe { n = pipe_modlet_get_n(); }
  unsafe { tab = pipe_modlet_table_base(); }
  if (tab == (0 as *u8)) {
    return 0;
  }
  while (i < n) {
    let imm: i32 = 0;
    let imm_hi: i32 = 0;
    let nlen: i32 = 0;
    let nbase: i32 = 0;
    let flo: i32 = 0;
    let fhi: i32 = 0;
    let used_f64: i32 = 0;
    unsafe {
      imm = pipe_load_i32_le(tab, pipe_modlet_off_init_imm(i));
      nlen = pipe_load_i32_le(tab, pipe_modlet_off_name_len(i));
      nbase = pipe_modlet_off_name(i);
    }
    if (arena != (0 as *u8) && mod != (0 as *u8) && nlen > 0 && nlen <= 255) {
      let nlets: i32 = 0;
      let tl: i32 = 0;
      unsafe { nlets = pipe_mod_get_num_top_level_lets(mod); }
      while (tl < nlets) {
        let tlen: i32 = 0;
        unsafe { tlen = pipeline_module_top_level_let_name_len(mod, tl); }
        if (tlen == nlen) {
          let same: i32 = 1;
          let k: i32 = 0;
          while (k < nlen) {
            let b: i32 = 0;
            let tb: i32 = 0;
            unsafe {
              b = pipeline_module_top_level_let_name_byte_at(mod, tl, k);
              tb = pipe_load_i32_le(tab, nbase + k);
            }
            // name bytes are raw u8 in table; compare low byte of load? Better byte index.
            // Use tab[nbase+k] via pointer arith in unsafe:
            let cb: i32 = 0;
            unsafe {
              cb = (tab[nbase + k] as i32);
            }
            if (b != cb) {
              same = 0;
              break;
            }
            k = k + 1;
          }
          if (same != 0) {
            let tr: i32 = 0;
            let ir: i32 = 0;
            let tk: i32 = 0;
            unsafe {
              tr = pipeline_module_top_level_let_type_ref(mod, tl);
              ir = pipeline_module_top_level_let_init_ref(mod, tl);
            }
            if (tr > 0) {
              unsafe { tk = pipeline_type_kind_ord_at(arena, tr); }
            }
            if (tk == 15 && ir > 0) {
              let fb: i32 = 0;
              unsafe { fb = pipe_modlet_fold_f64_elem_bits(arena, ir, &flo, &fhi); }
              if (fb != 0) {
                imm = flo;
                imm_hi = fhi;
                used_f64 = 1;
              }
            }
            break;
          }
        }
        tl = tl + 1;
      }
    }
    if (imm != 0 || imm_hi != 0) {
      let rc: i32 = 0;
      unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, imm_hi, ta); }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &tab[nbase], nlen, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    let _u: i32 = used_f64;
    _u = _u;
    i = i + 1;
  }
  if (arena != (0 as *u8) && mod != (0 as *u8)) {
    let nlets2: i32 = 0;
    let nexprs: i32 = 0;
    let tl2: i32 = 0;
    unsafe { nlets2 = pipe_mod_get_num_top_level_lets(mod); }
    unsafe { nexprs = pipe_load_i32_le(arena, pipe_arena_off_num_exprs()); }
    while (tl2 < nlets2) {
      let nlen2: i32 = 0;
      let name_buf: u8[256] = [];
      let k2: i32 = 0;
      unsafe { nlen2 = pipeline_module_top_level_let_name_len(mod, tl2); }
      if (nlen2 > 0 && nlen2 <= 255) {
        k2 = 0;
        while (k2 < nlen2) {
          unsafe {
            name_buf[k2] = pipeline_module_top_level_let_name_byte_at(mod, tl2, k2) as u8;
          }
          k2 = k2 + 1;
        }
        let idx: i32 = 0;
        unsafe { idx = pipeline_asm_modlet_find(&name_buf[0], nlen2); }
        if (idx >= 0) {
          let csz: i32 = 0;
          let is_arr: i32 = 0;
          let is_data: i32 = 0;
          unsafe {
            csz = pipe_load_i32_le(tab, pipe_modlet_off_cell_size(idx));
            is_arr = pipe_modlet_cell_is_array(csz);
            is_data = pipe_modlet_cell_is_data(csz);
          }
          if (is_arr != 0 && is_data == 0) {
            let init_ref: i32 = 0;
            let type_ref: i32 = 0;
            let ik: i32 = 0;
            let tk: i32 = 0;
            let et: i32 = 0;
            let rc2: i32 = 0;
            let lea_rc: i32 = 0;
            unsafe {
              init_ref = pipeline_module_top_level_let_init_ref(mod, tl2);
              type_ref = pipeline_module_top_level_let_type_ref(mod, tl2);
            }
            if (init_ref > 0 && init_ref <= nexprs && type_ref > 0) {
              unsafe {
                ik = pipeline_expr_kind_ord_at(arena, init_ref);
                tk = pipeline_type_kind_ord_at(arena, type_ref);
              }
              if (ik == 46 && tk == 10) {
                unsafe { et = pipeline_type_elem_ref_at(arena, type_ref); }
                unsafe { lea_rc = pipeline_asm_modlet_lea_rbx_arch(elf_ctx, idx, ta); }
                if (lea_rc == 0) {
                  unsafe {
                    rc2 = pipe_modlet_seed_array_lit_elems_to_rbx(
                      arena, elf_ctx, init_ref, et, ta, 0, mod);
                  }
                  if (rc2 != 0) {
                    return rc2;
                  }
                }
              }
            }
          }
        }
      }
      tl2 = tl2 + 1;
    }
  }
  return 0;
}
