/* seeds/async_asm_pool_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/async_asm_pool.x
 * Product cold path still embeds seeds/async_asm_pool.from_x.c via pipeline_glue #include (no FROM_X).
 * Hybrid/PREFER path: g05_try_x_to_o(async_asm_pool.x) + rest (-DSHUX_ASYNC_ASM_POOL_FROM_X, marker only).
 * R2: full.x eats helpers + build_layout; FROM_X rest business H=0 (only slice_marker in seed rest).
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./shux -E ... src/asm/async_asm_pool.x | filter DBG + polish prologue
 * NOTE: use ./shux (not shux-x) so non-#[no_mangle] keep short names where applicable.
 * Stack: build_layout caches let indices only (no u8[4096]) — Ubuntu -E stability.
 * PLATFORM: SHARED — pool API symbol contract; Ubuntu gold + mac prove.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern int32_t async_asm_pool_x_doc_anchor(void);
extern int32_t asm_pool_expr_is_await(uint8_t * a, int32_t er);
extern int32_t asm_pool_expr_has_await(uint8_t * a, int32_t er);
extern int32_t asm_pool_expr_is_var_named(uint8_t * a, int32_t er, uint8_t * name, int32_t nlen);
extern int32_t asm_pool_expr_refs_name(uint8_t * a, int32_t er, uint8_t * name, int32_t nlen);
extern int32_t asm_pool_block_rest_refs_name(uint8_t * a, int32_t br, int32_t from_exclusive, uint8_t * name, int32_t nlen);
extern int32_t asm_pool_type_size_bytes(uint8_t * a, uint8_t * m, int32_t type_ref);
extern int32_t asm_pool_load_i32_le(uint8_t * p, int32_t off);
extern void asm_pool_store_i32_le(uint8_t * p, int32_t off, int32_t v);
extern void asm_pool_live_add(uint8_t * lay, uint8_t * name, int32_t nlen, int32_t sz);
extern uint32_t async_asm_pool_fn_id_from_name(uint8_t * name, int32_t name_len);
extern int32_t async_asm_pool_func_needs_cps(uint8_t * arena, uint8_t * mod, int32_t func_index);
extern int32_t async_asm_pool_build_layout(uint8_t * arena, uint8_t * mod, int32_t func_index, uint8_t * out);
extern int32_t pipeline_expr_kind_ord_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_unary_operand_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_as_operand_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_as_target_type_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_index_base_ref(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_index_index_ref(uint8_t * a, int32_t er);
extern int32_t pipeline_expr_var_name_len(uint8_t * a, int32_t er);
extern void pipeline_expr_var_name_into(uint8_t * a, int32_t er, uint8_t * out);
extern int32_t ast_ast_block_num_lets(uint8_t * a, int32_t br);
extern int32_t ast_ast_block_num_expr_stmts(uint8_t * a, int32_t br);
extern int32_t ast_ast_block_num_stmt_order(uint8_t * a, int32_t br);
extern uint8_t ast_ast_block_stmt_order_kind(uint8_t * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(uint8_t * a, int32_t br, int32_t si);
extern int32_t pipeline_block_let_init_ref(uint8_t * a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_expr_stmt_ref(uint8_t * a, int32_t br, int32_t ei);
extern int32_t pipeline_asm_block_final_expr_ref_at(uint8_t * a, int32_t br);
extern int32_t pipeline_type_kind_ord_at(uint8_t * a, int32_t tr);
extern int32_t pipeline_type_named_name_into(uint8_t * a, int32_t tr, uint8_t * out);
extern int32_t pipeline_module_num_struct_layouts_at(uint8_t * m);
extern int32_t pipeline_module_struct_layout_name_len(uint8_t * m, int32_t k);
extern uint8_t pipeline_module_struct_layout_name_byte_at(uint8_t * m, int32_t k, int32_t j);
extern int32_t typeck_x_type_size_from_layout_glue(uint8_t * m, uint8_t * a, int32_t k, int32_t depth);
extern int32_t pipeline_module_func_is_async_at(uint8_t * m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(uint8_t * m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(uint8_t * m, int32_t fi);
extern void pipeline_module_func_name_copy64(uint8_t * m, int32_t fi, uint8_t * dst);
extern int32_t pipeline_block_let_type_ref(uint8_t * a, int32_t br, int32_t li);
extern int32_t pipeline_block_let_name_len(uint8_t * a, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(uint8_t * a, int32_t br, int32_t li, uint8_t * dst);
int32_t async_asm_pool_x_doc_anchor(void) {
  return 0;
}
int32_t asm_pool_expr_is_await(uint8_t * a, int32_t er) {
  if ((a ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  {
    int32_t ko = pipeline_expr_kind_ord_at(a, er);
    if ((ko ==55)) {
      int32_t uop = pipeline_expr_unary_operand_ref_at(a, er);
      if ((uop > 0)) {
        return 1;
      }
      return 0;
    }
    if ((ko !=54)) {
      return 0;
    }
    if ((pipeline_expr_as_target_type_ref_at(a, er) > 0)) {
      return 0;
    }
    if ((pipeline_expr_as_operand_ref_at(a, er) > 0)) {
      return 0;
    }
    int32_t uop2 = pipeline_expr_unary_operand_ref_at(a, er);
    if ((uop2 > 0)) {
      return 1;
    }
  }
  return 0;
}
int32_t asm_pool_expr_has_await(uint8_t * a, int32_t er) {
  if ((a ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  {
    if ((asm_pool_expr_is_await(a, er) !=0)) {
      return 1;
    }
    int32_t ko = pipeline_expr_kind_ord_at(a, er);
    if ((ko >=4)) {
      if ((ko <=21)) {
        if ((asm_pool_expr_has_await(a, pipeline_expr_binop_left_ref_at(a, er)) !=0)) {
          return 1;
        }
        return asm_pool_expr_has_await(a, pipeline_expr_binop_right_ref_at(a, er));
      }
    }
    if ((ko ==22)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==23)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==24)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==54)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==55)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==51)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==52)) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if ((ko ==44)) {
      return asm_pool_expr_has_await(a, pipeline_expr_field_access_base_ref(a, er));
    }
    if ((ko ==47)) {
      if ((asm_pool_expr_has_await(a, pipeline_expr_index_base_ref(a, er)) !=0)) {
        return 1;
      }
      return asm_pool_expr_has_await(a, pipeline_expr_index_index_ref(a, er));
    }
  }
  return 0;
}
int32_t asm_pool_expr_is_var_named(uint8_t * a, int32_t er, uint8_t * name, int32_t nlen) {
  if ((a ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    if ((pipeline_expr_kind_ord_at(a, er) !=3)) {
      return 0;
    }
    int32_t vlen = pipeline_expr_var_name_len(a, er);
    if ((vlen !=nlen)) {
      return 0;
    }
    uint8_t vbuf[64] = {};
    (void)(pipeline_expr_var_name_into(a, er, &((vbuf)[0])));
    int32_t i = 0;
    while ((i < nlen)) {
      if (((vbuf)[i] !=(name)[i])) {
        return 0;
      }
      (void)((i = (i + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t asm_pool_expr_refs_name(uint8_t * a, int32_t er, uint8_t * name, int32_t nlen) {
  if ((a ==0)) {
    return 0;
  }
  if ((er <=0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    if ((asm_pool_expr_is_var_named(a, er, name, nlen) !=0)) {
      return 1;
    }
    int32_t ko = pipeline_expr_kind_ord_at(a, er);
    if ((ko >=4)) {
      if ((ko <=21)) {
        if ((asm_pool_expr_refs_name(a, pipeline_expr_binop_left_ref_at(a, er), name, nlen) !=0)) {
          return 1;
        }
        return asm_pool_expr_refs_name(a, pipeline_expr_binop_right_ref_at(a, er), name, nlen);
      }
    }
    if ((ko ==22)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==23)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==24)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==54)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==55)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==51)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==52)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if ((ko ==44)) {
      return asm_pool_expr_refs_name(a, pipeline_expr_field_access_base_ref(a, er), name, nlen);
    }
    if ((ko ==47)) {
      if ((asm_pool_expr_refs_name(a, pipeline_expr_index_base_ref(a, er), name, nlen) !=0)) {
        return 1;
      }
      return asm_pool_expr_refs_name(a, pipeline_expr_index_index_ref(a, er), name, nlen);
    }
  }
  return 0;
}
int32_t asm_pool_block_rest_refs_name(uint8_t * a, int32_t br, int32_t from_exclusive, uint8_t * name, int32_t nlen) {
  if ((a ==0)) {
    return 0;
  }
  if ((br <=0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    int32_t nso = ast_ast_block_num_stmt_order(a, br);
    int32_t si = (from_exclusive + 1);
    while ((si < nso)) {
      uint8_t kind = ast_ast_block_stmt_order_kind(a, br, si);
      int32_t idx = ast_ast_block_stmt_order_idx(a, br, si);
      if ((kind ==1)) {
        if ((idx >=0)) {
          if ((idx < ast_ast_block_num_lets(a, br))) {
            int32_t init = pipeline_block_let_init_ref(a, br, idx);
            if ((init > 0)) {
              if ((asm_pool_expr_refs_name(a, init, name, nlen) !=0)) {
                return 1;
              }
            }
          }
        }
      } else {
        if ((kind ==2)) {
          if ((idx >=0)) {
            if ((idx < ast_ast_block_num_expr_stmts(a, br))) {
              int32_t ex = ast_pipeline_block_expr_stmt_ref(a, br, idx);
              if ((ex > 0)) {
                if ((asm_pool_expr_refs_name(a, ex, name, nlen) !=0)) {
                  return 1;
                }
              }
            }
          }
        }
      }
      (void)((si = (si + 1)));
    }
    int32_t fin = pipeline_asm_block_final_expr_ref_at(a, br);
    if ((fin > 0)) {
      if ((asm_pool_expr_refs_name(a, fin, name, nlen) !=0)) {
        return 1;
      }
    }
  }
  return 0;
}
int32_t asm_pool_type_size_bytes(uint8_t * a, uint8_t * m, int32_t type_ref) {
  if ((a ==0)) {
    return 8;
  }
  if ((type_ref <=0)) {
    return 8;
  }
  {
    int32_t kind = pipeline_type_kind_ord_at(a, type_ref);
    if ((kind ==0)) {
      return 4;
    }
    if ((kind ==1)) {
      return 4;
    }
    if ((kind ==2)) {
      return 1;
    }
    if ((kind ==3)) {
      return 8;
    }
    if ((kind ==4)) {
      return 8;
    }
    if ((kind ==5)) {
      return 8;
    }
    if ((kind ==6)) {
      return 8;
    }
    if ((kind ==7)) {
      return 8;
    }
    if ((kind ==9)) {
      return 8;
    }
    if ((kind ==8)) {
      uint8_t name[64] = {};
      int32_t nlen = pipeline_type_named_name_into(a, type_ref, &((name)[0]));
      if ((nlen <=0)) {
        return 8;
      }
      if ((m ==0)) {
        return 8;
      }
      int32_t nlay = pipeline_module_num_struct_layouts_at(m);
      int32_t k = 0;
      while ((k < nlay)) {
        int32_t ln = pipeline_module_struct_layout_name_len(m, k);
        if ((ln ==nlen)) {
          int32_t j = 0;
          int32_t eq = 1;
          while ((j < nlen)) {
            if ((pipeline_module_struct_layout_name_byte_at(m, k, j) !=(name)[j])) {
              (void)((eq = 0));
              break;
            }
            (void)((j = (j + 1)));
          }
          if ((eq !=0)) {
            int32_t sz = typeck_x_type_size_from_layout_glue(m, a, k, 0);
            if ((sz > 0)) {
              return sz;
            }
            return 8;
          }
        }
        (void)((k = (k + 1)));
      }
      return 8;
    }
  }
  return 8;
}
int32_t asm_pool_load_i32_le(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return 0;
  }
  int32_t m = 256;
  int32_t a = ((int32_t)((p)[off]));
  (void)((a = (a + (((int32_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((int32_t)((p)[(off + 2)])) * (m * m)))));
  (void)((a = (a + (((int32_t)((p)[(off + 3)])) * ((m * m) * m)))));
  return a;
}
void asm_pool_store_i32_le(uint8_t * p, int32_t off, int32_t v) {
  if ((p ==0)) {
    return;
  }
  uint32_t u = ((uint32_t)(v));
  (void)(((p)[off] = ((uint8_t)((u & 255)))));
  (void)(((p)[(off + 1)] = ((uint8_t)(((u / 256) & 255)))));
  (void)(((p)[(off + 2)] = ((uint8_t)(((u / 65536) & 255)))));
  (void)(((p)[(off + 3)] = ((uint8_t)(((u / 16777216) & 255)))));
}
void asm_pool_live_add(uint8_t * lay, uint8_t * name, int32_t nlen, int32_t sz) {
  if ((lay ==0)) {
    return;
  }
  if ((name ==0)) {
    return;
  }
  if ((nlen <=0)) {
    return;
  }
  if ((nlen > 63)) {
    return;
  }
  {
    int32_t num = asm_pool_load_i32_le(lay, 8);
    if ((num >=64)) {
      return;
    }
    int32_t i = 0;
    while ((i < num)) {
      int32_t base = (12 + (i * 76));
      int32_t elen = asm_pool_load_i32_le(lay, (base + 64));
      if ((elen ==nlen)) {
        int32_t eq = 1;
        int32_t j = 0;
        while ((j < nlen)) {
          if (((lay)[(base + j)] !=(name)[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if ((eq !=0)) {
          return;
        }
      }
      (void)((i = (i + 1)));
    }
    int32_t off = 0;
    (void)((i = 0));
    while ((i < num)) {
      int32_t base2 = (12 + (i * 76));
      (void)((off = (off + asm_pool_load_i32_le(lay, (base2 + 68)))));
      (void)((i = (i + 1)));
    }
    int32_t slot = (12 + (num * 76));
    int32_t k = 0;
    while ((k < nlen)) {
      (void)(((lay)[(slot + k)] = (name)[k]));
      (void)((k = (k + 1)));
    }
    (void)(((lay)[(slot + nlen)] = 0));
    (void)(asm_pool_store_i32_le(lay, (slot + 64), nlen));
    int32_t sz2 = sz;
    if ((sz2 <=0)) {
      (void)((sz2 = 4));
    }
    (void)(asm_pool_store_i32_le(lay, (slot + 68), sz2));
    (void)(asm_pool_store_i32_le(lay, (slot + 72), off));
    (void)(asm_pool_store_i32_le(lay, 8, (num + 1)));
  }
}
uint32_t async_asm_pool_fn_id_from_name(uint8_t * name, int32_t name_len) {
  if ((name ==0)) {
    return 1;
  }
  if ((name_len <=0)) {
    return 1;
  }
  uint32_t h = -2128831035;
  int32_t i = 0;
  while ((i < name_len)) {
    (void)((h = ((h ^ ((uint32_t)((name)[i]))) * 16777619)));
    (void)((i = (i + 1)));
  }
  if ((h ==0)) {
    return 1;
  }
  return h;
}
int32_t async_asm_pool_func_needs_cps(uint8_t * arena, uint8_t * mod, int32_t func_index) {
  if ((arena ==0)) {
    return 0;
  }
  if ((mod ==0)) {
    return 0;
  }
  if ((func_index < 0)) {
    return 0;
  }
  {
    if ((pipeline_module_func_is_async_at(mod, func_index) ==0)) {
      return 0;
    }
    int32_t br = pipeline_module_func_body_ref_at(mod, func_index);
    if ((br <=0)) {
      return 0;
    }
    int32_t nso = ast_ast_block_num_stmt_order(arena, br);
    int32_t si = 0;
    while ((si < nso)) {
      if ((ast_ast_block_stmt_order_kind(arena, br, si) ==1)) {
        int32_t li = ast_ast_block_stmt_order_idx(arena, br, si);
        int32_t init = pipeline_block_let_init_ref(arena, br, li);
        if ((init > 0)) {
          if ((asm_pool_expr_has_await(arena, init) !=0)) {
            return 1;
          }
        }
      }
      (void)((si = (si + 1)));
    }
  }
  return 0;
}
int32_t async_asm_pool_build_layout(uint8_t * arena, uint8_t * mod, int32_t func_index, uint8_t * out) {
  if ((arena ==0)) {
    return -1;
  }
  if ((mod ==0)) {
    return -1;
  }
  if ((out ==0)) {
    return -1;
  }
  if ((func_index < 0)) {
    return -1;
  }
  int32_t zi = 0;
  while ((zi < 4880)) {
    (void)(((out)[zi] = 0));
    (void)((zi = (zi + 1)));
  }
  if ((async_asm_pool_func_needs_cps(arena, mod, func_index) ==0)) {
    return 1;
  }
  {
    uint8_t fname[64] = {};
    int32_t fnlen = pipeline_module_func_name_len_at(mod, func_index);
    (void)(pipeline_module_func_name_copy64(mod, func_index, fname));
    uint32_t fid = async_asm_pool_fn_id_from_name(fname, fnlen);
    (void)(asm_pool_store_i32_le(out, 0, ((int32_t)(fid))));
    (void)(asm_pool_store_i32_le(out, 4876, -1));
    int32_t br = pipeline_module_func_body_ref_at(mod, func_index);
    int32_t nso = ast_ast_block_num_stmt_order(arena, br);
    int32_t defined_lets[64] = {};
    int32_t n_def = 0;
    int32_t si = 0;
    while ((si < nso)) {
      uint8_t kind = ast_ast_block_stmt_order_kind(arena, br, si);
      int32_t idx = ast_ast_block_stmt_order_idx(arena, br, si);
      int32_t nlets = ast_ast_block_num_lets(arena, br);
      if ((kind ==1)) {
        if ((idx >=0)) {
          if ((idx < nlets)) {
            int32_t init = pipeline_block_let_init_ref(arena, br, idx);
            if ((init > 0)) {
              if ((asm_pool_expr_has_await(arena, init) !=0)) {
                int32_t na = asm_pool_load_i32_le(out, 4);
                (void)(asm_pool_store_i32_le(out, 4, (na + 1)));
                int32_t cur_await = asm_pool_load_i32_le(out, 4876);
                if ((cur_await < 0)) {
                  (void)(asm_pool_store_i32_le(out, 4876, si));
                }
                int32_t li = 0;
                while ((li < n_def)) {
                  int32_t def_idx = (defined_lets)[li];
                  int32_t dlen = pipeline_block_let_name_len(arena, br, def_idx);
                  if ((dlen > 0)) {
                    if ((dlen <=63)) {
                      uint8_t dname[64] = {};
                      (void)(pipeline_block_let_name_copy64(arena, br, def_idx, dname));
                      if ((asm_pool_block_rest_refs_name(arena, br, si, dname, dlen) !=0)) {
                        int32_t tref = pipeline_block_let_type_ref(arena, br, def_idx);
                        int32_t sz = asm_pool_type_size_bytes(arena, mod, tref);
                        (void)(asm_pool_live_add(out, dname, dlen, sz));
                      }
                    }
                  }
                  (void)((li = (li + 1)));
                }
                uint8_t cur_nb[64] = {};
                int32_t cur_len = pipeline_block_let_name_len(arena, br, idx);
                if ((cur_len > 0)) {
                  if ((cur_len <=63)) {
                    (void)(pipeline_block_let_name_copy64(arena, br, idx, cur_nb));
                    if ((asm_pool_block_rest_refs_name(arena, br, si, cur_nb, cur_len) !=0)) {
                      int32_t tref2 = pipeline_block_let_type_ref(arena, br, idx);
                      int32_t sz2 = asm_pool_type_size_bytes(arena, mod, tref2);
                      (void)(asm_pool_live_add(out, cur_nb, cur_len, sz2));
                    }
                  }
                }
              }
            }
            int32_t llen = pipeline_block_let_name_len(arena, br, idx);
            if ((llen > 0)) {
              if ((llen <=63)) {
                if ((n_def < 64)) {
                  (void)(((defined_lets)[n_def] = idx));
                  (void)((n_def = (n_def + 1)));
                }
              }
            }
          }
        }
      }
      (void)((si = (si + 1)));
    }
    int32_t num_awaits = asm_pool_load_i32_le(out, 4);
    if ((num_awaits > 0)) {
      return 0;
    }
  }
  return 1;
}
