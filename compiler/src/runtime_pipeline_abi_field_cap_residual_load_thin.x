// Thin overlay: Cap residual struct field load width + signed load (wave1007/1008).
// G.7: body matches glue_field_access_load_bytes_for_type_ref +
//   pipeline_expr_field_access_load_byte_sz in runtime_pipeline_abi.x /
//   field_load_sz_thin (Cap residual TYPE_NAMED → 4-byte cells).
// wave1008: FIELD_ACCESS load_sz==4 uses LDRSW / movslq (align INDEX/SoA);
//   overrides VAR-base emit so local `s.v = (0-1) as i8` reads -1 on ARM64.
// Strong first-wins over pabi_weak weak faces on Darwin/Windows.
// PLATFORM: SHARED freestanding · MACOS|DARWIN / WINDOWS overlay ·
//   LINUX via modlet + field_load layout/main PREFER.

export extern function pipeline_arena_num_types(a: *u8): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(a: *u8, ty_ref: i32, out: *u8): i32;
export extern function pipeline_type_elem_ref_at(a: *u8, ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(a: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_resolved_type_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(a: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_module_num_struct_layouts_at(m: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(m: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_num_fields(m: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(m: *u8, k: i32, j: i32, out: *u8): void;
export extern function pipeline_module_struct_layout_field_type_ref(m: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(m: *u8, k: i32, j: i32): i32;
export extern function typeck_x_named_builtin_size(nm: *u8, nlen: i32): i32;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_match_name_is_subject_field_c(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_match_matched_ref_c(): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, base_ref: i32): i32;
export extern function glue_local_var_slot_needs_ptr_load_elf_c(arena: *u8, base_ref: i32, var_off: i32, ctx: *u8): i32;
export extern function glue_slice_dual_gp_length_off_c(var_off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, var_off: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function glue_field_access_call_arg_struct_by_addr_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_field_call_arg_try_load_agg_from_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_typeck_get_dep_ctx(): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_module_enum_name_len(module: *u8, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *u8, idx: i32, off: i32): u8;

/**
 * Compare n bytes at a and b; 1 if equal, else 0.
 * @param a *u8 — left bytes
 * @param b *u8 — right bytes
 * @param n i32 — length; n<=0 → 1
 * @return i32 — 1 equal, 0 mismatch
 * PLATFORM: SHARED — thin-local twin of wave151_bytes_eq.
 */
function field_cap_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) {
    return 1;
  }
  if (a == (0 as *u8) || b == (0 as *u8)) {
    return 0;
  }
  while (i < n) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * 1 if module m declares an enum named nm[0..nlen), else 0.
 * @param m *u8 - Module*
 * @param nm *u8 - enum name bytes (unqualified)
 * @param nlen i32 - name length
 * @return i32 - 1 found, 0 not found
 * PLATFORM: SHARED - w1544.
 */
function field_cap_module_has_enum(m: *u8, nm: *u8, nlen: i32): i32 {
  let ei: i32 = 0;
  let el: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let b1: i32 = 0;
  let b2: i32 = 0;
  if (m == (0 as *u8) || nlen <= 0) {
    return 0;
  }
  while (ei < 4096) {
    unsafe {
      el = pipeline_module_enum_name_len(m, ei);
    }
    if (el <= 0) {
      return 0;
    }
    if (el == nlen) {
      eq = 1;
      j = 0;
      while (j < nlen) {
        unsafe {
          b1 = (pipeline_module_enum_name_byte_at(m, ei, j) as i32) & 255;
          b2 = (nm[j] as i32) & 255;
        }
        if (b1 != b2) {
          eq = 0;
          break;
        }
        j = j + 1;
      }
      if (eq != 0) {
        return 1;
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * Enum-typed TYPE_NAMED field width: 4 (C layout stores the tag as int).
 * Searches the current module, then typeck dep modules; a qualified name
 * (`token.TokenKind`) is matched by its last segment.
 * w1544: x86/arm64 `t.kind = (N as K)` stored 8 bytes and zeroed the next
 * i32 field (lexer Token.line), since TYPE_NAMED non-builtin fell to 8.
 * @param a *u8 - ASTArena*
 * @param m *u8 - Module*
 * @param ty_ref i32 - TYPE_NAMED type ref
 * @return i32 - 4 if enum, else 0
 * PLATFORM: SHARED - w1544.
 */
function field_cap_named_enum_width(a: *u8, m: *u8, ty_ref: i32): i32 {
  let nm: u8[256] = [];
  let nlen: i32 = 0;
  let st: i32 = 0;
  let i: i32 = 0;
  let ctx: *u8 = 0 as *u8;
  let dm: *u8 = 0 as *u8;
  let nd: i32 = 0;
  let di: i32 = 0;
  if (a == (0 as *u8) || ty_ref <= 0) {
    return 0;
  }
  unsafe {
    nlen = pipeline_type_named_name_into(a, ty_ref, &nm[0]);
  }
  if (nlen <= 0 || nlen > 255) {
    return 0;
  }
  i = 0;
  while (i < nlen) {
    if (nm[i] == (46 as u8)) {
      st = i + 1;
    }
    i = i + 1;
  }
  if (st >= nlen) {
    return 0;
  }
  if (field_cap_module_has_enum(m, &nm[st], nlen - st) != 0) {
    return 4;
  }
  unsafe {
    ctx = pipeline_typeck_get_dep_ctx();
  }
  if (ctx == (0 as *u8)) {
    return 0;
  }
  unsafe {
    nd = pipeline_dep_ctx_ndep(ctx);
  }
  di = 0;
  while (di < nd && di < 4096) {
    unsafe {
      dm = pipeline_dep_ctx_module_at(ctx, di);
    }
    if (dm != (0 as *u8) && dm != m) {
      if (field_cap_module_has_enum(dm, &nm[st], nlen - st) != 0) {
        return 4;
      }
    }
    di = di + 1;
  }
  return 0;
}

/**
 * Load width for a type_ref. Cap residual TYPE_NAMED i8/i16/u16 → 4.
 * @param a *u8 - ASTArena*
 * @param ty_ref i32 - type ref
 * @return i32 - byte size
 * PLATFORM: SHARED — G.7 twin of mega glue_field_access_load_bytes_for_type_ref.
 */
#[no_mangle]
export function glue_field_access_load_bytes_for_type_ref(a: *u8, ty_ref: i32): i32 {
  let kind_ord: i32 = 0;
  let ntypes: i32 = 0;
  let nlen: i32 = 0;
  let bsz: i32 = 0;
  let nm: u8[16] = [];
  if (a == (0 as *u8) || ty_ref <= 0) {
    return 8;
  }
  unsafe {
    ntypes = pipeline_arena_num_types(a);
  }
  if (ty_ref > ntypes) {
    return 8;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  }
  if (kind_ord == 2 || kind_ord == 1) {
    return 1;
  }
  if (kind_ord == 3) {
    /* 记212: sentinel 40 → scalar load zext (not LDRSW). Byte width still 4. */
    return 40;
  }
  if (kind_ord == 0 || kind_ord == 13 || kind_ord == 14) {
    return 4;
  }
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15
      || kind_ord == 9 || kind_ord == 18) {
    return 8;
  }
  if (kind_ord == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(a, ty_ref, &nm[0]);
    }
    if (nlen > 0 && nlen < 16) {
      unsafe {
        bsz = typeck_x_named_builtin_size(&nm[0], nlen);
      }
      if (bsz == 1 || bsz == 2 || bsz == 4 || bsz == 8) {
        return bsz;
      }
    }
    return 8;
  }
  return 4;
}

/**
 * FIELD_ACCESS load width with Cap residual TYPE_NAMED → 4 (wave1007).
 * @param a *u8 - ASTArena*
 * @param m *u8 - Module*
 * @param expr_ref i32 - FIELD_ACCESS expr ref
 * @return i32 - load byte size
 * PLATFORM: SHARED — G.7 twin of field_load_sz_thin / mega.
 */
#[no_mangle]
export function pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32 {
  let tr: i32 = 0;
  let base_tr: i32 = 0;
  let base_ref: i32 = 0;
  let struct_name: u8[256] = [];
  let nlen: i32 = 0;
  let flen: i32 = 0;
  let field_name: u8[256] = [];
  let k: i32 = 0;
  let j: i32 = 0;
  let ftr: i32 = 0;
  let kind_ord: i32 = 0;
  let ftr_kind: i32 = 0;
  let nsl: i32 = 0;
  let nf: i32 = 0;
  let fnlen: i32 = 0;
  let feq: i32 = 0;
  let fi: i32 = 0;
  let fb: u8[256] = [];
  let ln: i32 = 0;
  let eq: i32 = 0;
  let hit: i32 = 0;
  let nm_is_some: u8[7] = [105, 115, 95, 115, 111, 109, 101];
  let nm_is_none: u8[7] = [105, 115, 95, 110, 111, 110, 101];
  if (a == (0 as *u8) || expr_ref <= 0) {
    return 8;
  }
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
    flen = pipeline_expr_field_access_name_len(a, expr_ref);
  }
  if (base_ref <= 0 || flen <= 0 || flen > 255) {
    return 8;
  }
  unsafe {
    pipeline_expr_field_access_name_into(a, expr_ref, &field_name[0]);
  }
  /* 记212: layout field type beats missing mono stamp for U32 (key_hash). */
  unsafe {
    let _ftr212: i32 = glue_field_access_field_type_ref_c(a, m, expr_ref);
    let _fk212: i32 = 0;
    if (_ftr212 > 0) {
      _fk212 = pipeline_type_kind_ord_at(a, _ftr212);
      if (_fk212 == 3) {
        return 40;
      }
    }
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  }
  if (tr > 0) {
    unsafe {
      kind_ord = pipeline_type_kind_ord_at(a, tr);
    }
    if (kind_ord == 8) {
      hit = glue_field_access_load_bytes_for_type_ref(a, tr);
      if (hit == 1 || hit == 2 || hit == 4) {
        return hit;
      }
      if (field_cap_named_enum_width(a, m, tr) == 4) {
        return 4;
      }
    } else if (kind_ord != 10 && kind_ord != 11 && kind_ord != 12) {
      return glue_field_access_load_bytes_for_type_ref(a, tr);
    }
  }
  unsafe {
    base_tr = pipeline_expr_resolved_type_ref(a, base_ref);
  }
  if (base_tr > 0) {
    unsafe {
      kind_ord = pipeline_type_kind_ord_at(a, base_tr);
    }
    if (kind_ord == 9) {
      unsafe {
        let elem_tr_lbs: i32 = pipeline_type_elem_ref_at(a, base_tr);
        if (elem_tr_lbs > 0) {
          base_tr = elem_tr_lbs;
          kind_ord = pipeline_type_kind_ord_at(a, base_tr);
        }
      }
    }
    if (kind_ord == 8) {
      unsafe {
        nlen = pipeline_type_named_name_into(a, base_tr, &struct_name[0]);
      }
      if (nlen > 0 && nlen <= 63 && m != (0 as *u8)) {
        unsafe {
          nsl = pipeline_module_num_struct_layouts_at(m);
        }
        k = 0;
        while (k < nsl) {
          unsafe {
            ln = pipeline_module_struct_layout_name_len(m, k);
          }
          eq = 1;
          if (ln != nlen) {
            eq = 0;
          } else {
            j = 0;
            while (j < nlen) {
              unsafe {
                if (pipeline_module_struct_layout_name_byte_at(m, k, j) != (struct_name[j] as i32)) {
                  eq = 0;
                  break;
                }
              }
              j = j + 1;
            }
          }
          if (eq != 0) {
            unsafe {
              nf = pipeline_module_struct_layout_num_fields(m, k);
            }
            j = 0;
            while (j < nf) {
              unsafe {
                fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
              }
              feq = 1;
              if (fnlen != flen) {
                feq = 0;
              } else {
                unsafe {
                  pipeline_module_struct_layout_field_name_into(m, k, j, &fb[0]);
                }
                fi = 0;
                while (fi < fnlen) {
                  if (fb[fi] != field_name[fi]) {
                    feq = 0;
                    break;
                  }
                  fi = fi + 1;
                }
              }
              if (feq != 0) {
                unsafe {
                  ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
                  ftr_kind = pipeline_type_kind_ord_at(a, ftr);
                }
                hit = glue_field_access_load_bytes_for_type_ref(a, ftr);
                if (ftr_kind == 8) {
                  if (hit == 1 || hit == 2 || hit == 4) {
                    return hit;
                  }
                  if (field_cap_named_enum_width(a, m, ftr) == 4) {
                    return 4;
                  }
                } else {
                  return hit;
                }
              }
              j = j + 1;
            }
          }
          k = k + 1;
        }
      }
    }
  }
  if (flen == 7 && field_cap_bytes_eq(&field_name[0], &nm_is_some[0], 7) != 0) {
    return 1;
  }
  if (flen == 7 && field_cap_bytes_eq(&field_name[0], &nm_is_none[0], 7) != 0) {
    return 1;
  }
  return 8;
}

/**
 * FIELD_ACCESS scalar load from [rax/x0]. Cap residual / i32 4-byte cells
 * use signed load (LDRSW / movslq), same as INDEX esz==4.
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param load_sz i32 - 1 / 4 / 8
 * @param ta i32 - target arch
 * @return i32 - 0 ok; encoder rc
 * PLATFORM: SHARED — wave1008 G.7 twin of mega.
 */
#[no_mangle]
export function glue_field_access_emit_scalar_load_from_rax_elf_c(
  elf_ctx: *u8, load_sz: i32, ta: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  // load_sz==40: TYPE_U32 sentinel (记212). LDRSW/movsxd then zxt so
  // key_hash with high bit (FNV) compares equal to zero-extended param.
  // load_sz==4: signed i32 / Cap residual (wave1008 LDRSW).
  unsafe {
    if (load_sz == 1) {
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
    if (load_sz == 8) {
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
    if (load_sz == 40) {
      if (ta == 1) {
        return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
      }
      if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
      return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
    }
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
}

/**
 * Compare n bytes at a and b; 1 if equal, else 0.
 * Twin of mega wave151_bytes_eq for slice dual-GP name match.
 * @param a *u8 — left
 * @param b *u8 — right
 * @param n i32 — length
 * @return i32 — 1 equal, 0 mismatch
 * PLATFORM: SHARED thin-local.
 */
function field_cap_emit_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) {
    return 1;
  }
  if (a == (0 as *u8) || b == (0 as *u8)) {
    return 0;
  }
  while (i < n) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Byte offset of one named field on a named struct type.
 * Walks module struct layouts by the type's name, then by the field name.
 * Writes that field's type ref through out_ty when the pointer is set.
 * @param arena *u8 - ASTArena*
 * @param m *u8 - Module*
 * @param ty_ref i32 - TYPE_NAMED of the struct; <=0 returns -1
 * @param name *u8 - field name bytes, not necessarily NUL-terminated
 * @param nlen i32 - name length; <=0 returns -1
 * @param out_ty *i32 - optional field type ref; null skips the write
 * @return i32 - byte offset, or -1 when the type or field is missing
 * PLATFORM: SHARED.
 */
function field_cap_named_field_off(arena: *u8, m: *u8, ty_ref: i32, name: *u8, nlen: i32, out_ty: *i32): i32 {
  // field_name_into copies 256 bytes. A 64-byte dest overflows and
  // clears the length local, so the byte compare never runs.
  let struct_name: u8[256] = [];
  let fb: u8[256] = [];
  let tlen: i32 = 0;
  let nsl: i32 = 0;
  let k: i32 = 0;
  let ln: i32 = 0;
  let nf: i32 = 0;
  let j: i32 = 0;
  let fnlen: i32 = 0;
  let fi: i32 = 0;
  let eq: i32 = 0;
  let feq: i32 = 0;
  if (out_ty != (0 as *i32)) {
    out_ty[0] = 0;
  }
  if (arena == (0 as *u8) || m == (0 as *u8) || ty_ref <= 0 || name == (0 as *u8) || nlen <= 0) {
    return 0 - 1;
  }
  unsafe {
    tlen = pipeline_type_named_name_into(arena, ty_ref, &struct_name[0]);
    nsl = pipeline_module_num_struct_layouts_at(m);
  }
  if (tlen <= 0 || tlen > 63) {
    return 0 - 1;
  }
  k = 0;
  while (k < nsl) {
    unsafe {
      ln = pipeline_module_struct_layout_name_len(m, k);
    }
    eq = 0;
    if (ln == tlen) {
      eq = 1;
      j = 0;
      while (j < tlen) {
        let sb: i32 = 0;
        let lb: i32 = 0;
        // Store both sides first. A single compare that indexes the
        // buffer and calls the layout byte getter clobbers the call
        // result with the index on this Darwin product.
        sb = struct_name[j] as i32;
        unsafe {
          lb = pipeline_module_struct_layout_name_byte_at(m, k, j);
        }
        if (lb != sb) {
          eq = 0;
        }
        j = j + 1;
      }
    }
    if (eq != 0) {
      unsafe {
        nf = pipeline_module_struct_layout_num_fields(m, k);
      }
      j = 0;
      while (j < nf) {
        unsafe {
          fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
        }
        feq = 0;
        if (fnlen == nlen) {
          unsafe {
            pipeline_module_struct_layout_field_name_into(m, k, j, &fb[0]);
          }
          feq = 1;
          fi = 0;
          while (fi < fnlen) {
            let left: i32 = 0;
            let right: i32 = 0;
            left = fb[fi] as i32;
            right = name[fi] as i32;
            if (left != right) {
              feq = 0;
            }
            fi = fi + 1;
          }
        }
        if (feq != 0) {
          if (out_ty != (0 as *i32)) {
            unsafe {
              out_ty[0] = pipeline_module_struct_layout_field_type_ref(m, k, j);
            }
          }
          unsafe {
            return pipeline_module_struct_layout_field_offset_at(m, k, j);
          }
        }
        j = j + 1;
      }
    }
    k = k + 1;
  }
  return 0 - 1;
}

/**
 * VAR-base FIELD_ACCESS with Cap residual signed load (wave1008).
 * Strong first-wins over pabi_weak `ldr w` tail on Darwin/Windows.
 * A match bind with no local slot loads from the subject slot plus the
 * bind field offset and this access's offset inside that field's type.
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param expr_ref i32 - FIELD_ACCESS
 * @param ctx *u8 - AsmFuncCtx*
 * @param ta i32 - target arch
 * @return i32 - 0 ok; -1 error; -99 UNHANDLED
 * PLATFORM: SHARED — G.7 twin of mega pipeline_asm_emit_var_field_access_elf_c.
 */
#[no_mangle]
export function pipeline_asm_emit_var_field_access_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  let base_ref: i32 = 0;
  let vlen: i32 = 0;
  let var_off: i32 = 0;
  let field_off: i32 = 0;
  let load_sz: i32 = 0;
  let vname: u8[256] = [];
  let base_ty_sl: i32 = 0;
  let flen_sl: i32 = 0;
  let fn_sl: u8[256] = [];
  let nm_length: u8[6] = [108, 101, 110, 103, 116, 104];
  let nm_data: u8[4] = [100, 97, 116, 97];
  let agg: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let kord: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3) {
      return 0 - 99;
    }
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 255) {
      return 0 - 99;
    }
    pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
    var_off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    if (var_off < 0) {
      var_off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
    }
    if (var_off < 0) {
      // Match bind `h` in `Wrap { h } => h.b` has no local slot.
      // The subject holds the struct. Add the bind's field offset
      // and this access's field offset, then scalar-load.
      // PLATFORM: MACOS|ARM64 · LINUX x86_64.
      mod = pipeline_asm_emit_module_ref_c();
      if (mod != (0 as *u8)) {
        if (pipeline_codegen_match_name_is_subject_field_c(mod, arena, &vname[0], pipeline_expr_var_name_len(arena, base_ref)) != 0) {
          let matched: i32 = 0;
          let src_off: i32 = 0;
          let bind_off: i32 = 0;
          let subj_ty: i32 = 0;
          let bind_ty: i32 = 0;
          let acc_off: i32 = 0;
          let acc_name: u8[64] = [];
          matched = pipeline_codegen_match_matched_ref_c();
          if (matched > 0 && pipeline_expr_kind_ord_at(arena, matched) == 3) {
            src_off = glue_var_expr_stack_off_elf_c(arena, ctx, matched);
            subj_ty = pipeline_expr_resolved_type_ref(arena, matched);
            field_off = 0 - 1;
            bind_off = field_cap_named_field_off(arena, mod, subj_ty, &vname[0], pipeline_expr_var_name_len(arena, base_ref), &bind_ty);
            pipeline_expr_field_access_name_into(arena, expr_ref, &acc_name[0]);
            acc_off = field_cap_named_field_off(
              arena, mod, bind_ty, &acc_name[0],
              pipeline_expr_field_access_name_len(arena, expr_ref), 0 as *i32);
            if (acc_off >= 0) {
              field_off = acc_off;
            }
            if (src_off >= 0 && bind_off >= 0 && field_off >= 0) {
              if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta) != 0) {
                return 0 - 1;
              }
              if (bind_off != 0) {
                if (backend_enc_add_imm_to_rax_arch(elf_ctx, bind_off, ta) != 0) {
                  return 0 - 1;
                }
              }
              if (field_off != 0) {
                if (backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0) {
                  return 0 - 1;
                }
              }
              load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, expr_ref);
              return glue_field_access_emit_scalar_load_from_rax_elf_c(elf_ctx, load_sz, ta);
            }
          }
        }
      }
      return 0 - 99;
    }
    base_ty_sl = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
    flen_sl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (base_ty_sl > 0 && flen_sl > 0 && flen_sl <= 63) {
      kord = pipeline_type_kind_ord_at(arena, base_ty_sl);
      if (kord == 11 && glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, var_off, ctx) == 0) {
        pipeline_expr_field_access_name_into(arena, expr_ref, &fn_sl[0]);
        if (flen_sl == 6 && field_cap_emit_bytes_eq(&fn_sl[0], &nm_length[0], 6) != 0) {
          return backend_enc_load_rbp_to_rax_arch(
            elf_ctx, glue_slice_dual_gp_length_off_c(var_off, ta), ta
          );
        }
        if (flen_sl == 4 && field_cap_emit_bytes_eq(&fn_sl[0], &nm_data[0], 4) != 0) {
          return backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta);
        }
      }
    }
    mod = pipeline_asm_emit_module_ref_c();
    field_off = glue_field_access_effective_offset_c(arena, mod, expr_ref);
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, var_off, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0) {
      return 0 - 1;
    }
    if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0) {
      return 0;
    }
    // Positive: 9–16B field already dereferenced into the return pair.
    // Zero: scalar load below. PLATFORM: SHARED.
    agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0) {
      return 0 - 1;
    }
    if (agg > 0) {
      return 0;
    }
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, expr_ref);
    {
      let _tr_u32: i32 = 0;
      let _ko_u32: i32 = 0;
      _tr_u32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
      if (_tr_u32 <= 0) {
        _tr_u32 = glue_field_access_field_type_ref_c(arena, mod, expr_ref);
      }
      if (_tr_u32 > 0) {
        _ko_u32 = pipeline_type_kind_ord_at(arena, _tr_u32);
        if (_ko_u32 == 3) { load_sz = 40; }
      }
    }
    return glue_field_access_emit_scalar_load_from_rax_elf_c(elf_ctx, load_sz, ta);
  }
}
