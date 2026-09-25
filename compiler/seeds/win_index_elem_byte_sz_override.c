/**
 * PLATFORM: WINDOWS leftover-PE — first-wins INDEX esz authority.
 *
 * Mega leftover embeds glue_index + pipeline_asm_index_elem_byte_sz_c in
 * one .o. PE first-wins does NOT rewrite intra-object calls, so overriding
 * only glue_index left emit_index_thin still calling mega's index_elem which
 * intra-called the old Cap residual i8→1 peel. That made i8[4] INDEX
 * stride-1 + movzbl while bake keeps 4-byte cells (sum==1, g[1]==0).
 *
 * This object first-wins BOTH symbols. Same-TU index_elem → glue_index so
 * w1012: ARRAY/SLICE named i8 → esz=1 (true pack).
 * w1015: ARRAY/SLICE named i16 → esz=2 (true pack + sext16).
 * u16 stays Cap residual 4. PTR *i8 stays 1.
 * Authority: SHARED tip first-wins (also Darwin/Linux via g05 sidecar).
 * Link FIRST via g05 _WIN_ASSIGN_OVERRIDES / selfhost_pabi.
 */
#include <stdint.h>

extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ty_ref, uint8_t *out);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *mod, int32_t func_idx,
                                                          uint8_t *name, int32_t name_len);
extern int32_t glue_field_access_field_type_ref_c(void *arena, void *mod, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_var_expr_type_ref_with_decl_fallback_c(void *arena, int32_t expr_ref);

/**
 * Peel INDEX element byte size from a type ref.
 * ARRAY/SLICE named i8 → 1, i16 → 2 (true pack); u16 Cap residual → 4; PTR *i8 → 1.
 */
int32_t glue_index_elem_byte_sz_from_type_ref_c(void *arena, int32_t tr) {
  int32_t kind_ord;
  int32_t pointee;
  int32_t asz;
  int32_t ssz;
  void *mod;
  if (tr <= 0 || arena == 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 9) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7)
        return 8;
      if (kind_ord == 9)
        return 8;
      if (kind_ord == 10) {
        asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      /* PTR *named: Cap residual i8/u8/bool stay byte loads. */
      if (kind_ord == 8) {
        uint8_t sn[64];
        int32_t sl = pipeline_type_named_name_into(arena, pointee, sn);
        if (sl == 2 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'8')
          return 1;
        if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8')
          return 1;
        if (sl == 4 && sn[0] == (uint8_t)'b' && sn[1] == (uint8_t)'o' &&
            sn[2] == (uint8_t)'o' && sn[3] == (uint8_t)'l')
          return 1;
        if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'3' && sn[2] == (uint8_t)'2')
          return 4;
        if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'3' && sn[2] == (uint8_t)'2')
          return 4;
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          ssz = glue_type_size_simple(mod, arena, pointee, 0);
          if (ssz > 0)
            return ssz;
        }
      }
    }
    return 4;
  }
  if (kind_ord == 10 || kind_ord == 11) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 15)
        return 8;
      if (kind_ord == 9 || kind_ord == 18)
        return 8;
      if (kind_ord == 10) {
        asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      if (kind_ord == 11)
        return 16;
      /* ARRAY/SLICE: true-pack named i8 → 1 on Darwin/Linux.
       * PLATFORM: WINDOWS — Cap residual INDEX esz=4 until bake tip is
       * stable with emit/assign (w1013 park). SHARED otherwise.
       */
      if (kind_ord == 8) {
        uint8_t sn[64];
        int32_t sl = pipeline_type_named_name_into(arena, pointee, sn);
        if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8') {
#if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
          return 4;
#else
          return 1;
#endif
        }
        if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6') {
#if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
          return 4;
#else
          return 2;
#endif
        }
        if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
          return 4;
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          ssz = glue_type_size_simple(mod, arena, pointee, 0);
          if (ssz > 0)
            return ssz;
        }
      }
    }
  }
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
    return 4;
  if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7)
    return 8;
  if (kind_ord == 11)
    return 16;
  if (kind_ord == 8) {
    /* Bare named: true-pack i8 → 1, i16 → 2; Cap residual u16 → 4. */
    uint8_t sn[64];
    int32_t sl = pipeline_type_named_name_into(arena, tr, sn);
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8') {
    #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
      return 4;
    #else
      return 1;
    #endif
    }
    if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6') {
    #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
      return 4;
    #else
      return 2;
    #endif
    }
    if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 4;
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      ssz = glue_type_size_simple(mod, arena, tr, 0);
      if (ssz > 0)
        return ssz;
    }
  }
  return 8;
}

/**
 * INDEX expression element byte size — emit_index_thin imports this.
 * Same-TU calls glue_index above (Cap residual ARRAY→4), so PE first-wins
 * actually reaches the bake-aligned stride.
 */
int32_t pipeline_asm_index_elem_byte_sz_c(void *arena, int32_t expr_ref) {
  int32_t base_ref;
  int32_t tr;
  int32_t kind_ord;
  int32_t pointee;
  int32_t esz_base;
  void *mod;
  int32_t func_idx;
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref > 0) {
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      int32_t flen = pipeline_expr_field_access_name_len(arena, base_ref);
      if (flen == 3) {
        uint8_t fname[256];
        pipeline_expr_field_access_name_into(arena, base_ref, fname);
        if (fname[0] == (uint8_t)'p' && fname[1] == (uint8_t)'t' && fname[2] == (uint8_t)'r') {
          int32_t vref = pipeline_expr_field_access_base_ref(arena, base_ref);
          mod = pipeline_asm_emit_module_ref_c();
          func_idx = pipeline_asm_emit_func_index_c();
          if (vref > 0 && mod && pipeline_expr_kind_ord_at(arena, vref) == 3) {
            uint8_t vn[256];
            int32_t vl = pipeline_expr_var_name_len(arena, vref);
            int32_t pty = 0;
            if (vl > 0 && vl <= 63 && func_idx >= 0) {
              pipeline_expr_var_name_into(arena, vref, vn);
              pty = pipeline_module_func_param_type_ref_for_name(mod, func_idx, vn, vl);
            }
            if (pty > 0 && pipeline_type_kind_ord_at(arena, pty) == 9) {
              int32_t st = pipeline_type_elem_ref_at(arena, pty);
              uint8_t sn[128];
              int32_t sl = st > 0 ? pipeline_type_named_name_into(arena, st, sn) : 0;
              if (sl >= 6 && sn[sl - 1] == (uint8_t)'8' && sn[sl - 2] == (uint8_t)'u' &&
                  sn[sl - 3] == (uint8_t)'_' && sn[sl - 4] == (uint8_t)'c' && sn[sl - 5] == (uint8_t)'e' &&
                  sn[sl - 6] == (uint8_t)'V')
                return 1;
            }
          }
        }
      }
    }
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
      mod = pipeline_asm_emit_module_ref_c();
      tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    } else {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (tr <= 0)
        tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
    }
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 9) {
      esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      if (esz_base > 0 && esz_base < 8)
        return esz_base;
    } else if (tr > 0) {
      esz_base = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      if (esz_base > 0 && esz_base < 8)
        return esz_base;
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr > 0) {
    int32_t esz_res;
    if (pipeline_type_kind_ord_at(arena, tr) == 10) {
      int32_t asz = glue_fixed_array_total_bytes_c(arena, tr, 0);
      if (asz > 0)
        return asz;
    }
    if (pipeline_type_kind_ord_at(arena, tr) == 9)
      return 8;
    if (pipeline_type_kind_ord_at(arena, tr) == 11)
      return 16;
    esz_res = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    {
      int32_t base_ref2 = pipeline_expr_index_base_ref(arena, expr_ref);
      int32_t tr_base;
      int32_t esz_pt;
      if (base_ref2 > 0) {
        if (pipeline_expr_kind_ord_at(arena, base_ref2) == 44) {
          mod = pipeline_asm_emit_module_ref_c();
          tr_base = glue_field_access_field_type_ref_c(arena, mod, base_ref2);
        } else {
          tr_base = pipeline_expr_resolved_type_ref(arena, base_ref2);
          if (tr_base <= 0)
            tr_base = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref2);
        }
        if (tr_base > 0 && pipeline_type_kind_ord_at(arena, tr_base) == 9) {
          esz_pt = glue_index_elem_byte_sz_from_type_ref_c(arena, tr_base);
          if (esz_pt > 0 && (esz_res <= 0 || esz_pt < esz_res))
            return esz_pt;
        }
      }
    }
    return esz_res;
  }
  base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  if (base_ref <= 0)
    return 4;
  if (pipeline_expr_kind_ord_at(arena, base_ref) == 44) {
    mod = pipeline_asm_emit_module_ref_c();
    tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    if (tr > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    return 4;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr <= 0)
    return 4;
  kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 9)
    return glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  if (kind_ord == 10 || kind_ord == 11) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0) {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
      if (kind_ord == 2 || kind_ord == 1)
        return 1;
      if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
        return 4;
      if (kind_ord == 9)
        return 8;
      if (kind_ord == 10) {
        int32_t asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
        if (asz > 0)
          return asz;
      }
      if (kind_ord == 11)
        return 16;
      if (kind_ord == 8) {
        uint8_t sn[64];
        int32_t sl = pipeline_type_named_name_into(arena, pointee, sn);
        if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8') {
        #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
          return 4;
        #else
          return 1;
        #endif
        }
        if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6') {
        #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
          return 4;
        #else
          return 2;
        #endif
        }
        if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
          return 4;
        mod = pipeline_asm_emit_module_ref_c();
        if (mod) {
          int32_t esz = glue_type_size_simple(mod, arena, pointee, 0);
          if (esz > 0)
            return esz;
        }
      }
    }
  }
  if (kind_ord == 8) {
    uint8_t sn[64];
    int32_t sl = pipeline_type_named_name_into(arena, tr, sn);
    if (sl == 2 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'8') {
    #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
      return 4;
    #else
      return 1;
    #endif
    }
    if (sl == 3 && sn[0] == (uint8_t)'i' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6') {
    #if defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__)
      return 4;
    #else
      return 2;
    #endif
    }
    if (sl == 3 && sn[0] == (uint8_t)'u' && sn[1] == (uint8_t)'1' && sn[2] == (uint8_t)'6')
      return 4;
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      int32_t esz = glue_type_size_simple(mod, arena, tr, 0);
      if (esz > 0)
        return esz;
    }
  }
  if (kind_ord == 13) {
    pointee = pipeline_type_elem_ref_at(arena, tr);
    if (pointee > 0)
      return glue_index_elem_byte_sz_from_type_ref_c(arena, pointee);
    return 4;
  }
  return 8;
}

int32_t pipeline_asm_index_elem_byte_sz(void *a, int32_t index_expr_ref) {
  return pipeline_asm_index_elem_byte_sz_c(a, index_expr_ref);
}
