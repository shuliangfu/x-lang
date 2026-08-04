/* seeds/runtime_lsp_glue_surface.from_x.c
 * G-02f runtime_lsp_glue R2 mixed surface - isomorphic with src/asm/runtime_lsp_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_lsp_glue.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (54 symbols)
 * Mode: mixed - 37 DIRECT compute + 17 thin+rest forwards to _impl
 * Cap residual: 23 extern bridges (17 *_impl + 6 lsp_entry_/lsp_json_key_)
 * doc_anchor: runtime_lsp_glue_x_doc_anchor (defined here, returns 0).
 * Logic: 54 functions = 37 DIRECT compute
 *   + 17 thin+rest forwards to _impl (lsp_free_import_cache_impl,
 *      lsp_init_lib_roots_once_impl, lsp_diag_x_ctx_alloc_size_impl,
 *      build_line_index_impl, line_index_of_func_impl, expr_at_impl,
 *      expr_max_line_impl, block_max_line_impl, add_ref_for_func_impl,
 *      build_refs_index_impl, find_def_in_module_impl,
 *      lsp_typeck_entry_module_impl, collect_refs_index_in_expr_impl,
 *      collect_refs_index_in_block_impl, find_def_in_expr_impl,
 *      find_def_in_block_impl, type_to_string_impl).
 * Regen: xlang_asm -E src/asm/runtime_lsp_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
/* Forward declarations for all 54 surface functions (nm IDENTICAL targets). */
extern int32_t runtime_lsp_glue_x_doc_anchor(void);
extern void lsp_free_import_cache(void);
extern int32_t runtime_lsp_glue_lsp_hex_nibble(int32_t c);
extern int32_t runtime_lsp_glue_lsp_uri_has_file_scheme(uint8_t * uri);
extern void lsp_uri_to_fs_path(uint8_t * uri, uint8_t * out, int64_t cap);
extern void lsp_fs_path_to_uri(uint8_t * path, uint8_t * uri, int32_t cap);
extern int32_t lsp_path_last_slash(uint8_t * path);
extern void lsp_update_entry_dir(uint8_t * path);
extern void lsp_init_lib_roots_once(void);
extern void lsp_diag_copy_text(uint8_t * dst, int32_t cap, uint8_t * src);
extern int64_t lsp_diag_x_ctx_alloc_size(void);
extern int32_t json_escape_str(uint8_t * msg, uint8_t * out, int32_t cap);
extern void build_line_index(uint8_t * mod);
extern int32_t line_index_of_func(uint8_t * f);
extern int32_t expr_at(uint8_t * e, int32_t line, int32_t col);
extern int32_t expr_max_line(uint8_t * e);
extern int32_t block_max_line(uint8_t * b);
extern void add_ref_for_func(uint8_t * f, int32_t line, int32_t col);
extern void build_refs_index(uint8_t * mod);
extern int32_t find_def_in_module(uint8_t * mod, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern void lsp_typeck_entry_module(uint8_t * mod, int32_t only);
extern void collect_refs_index_in_expr(uint8_t * e);
extern void collect_refs_index_in_block(uint8_t * b);
extern int32_t find_def_in_expr(uint8_t * mod, uint8_t * e, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern int32_t find_def_in_block(uint8_t * mod, uint8_t * b, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern int32_t type_to_string(uint8_t * ty, uint8_t * buf, int32_t cap);
extern int32_t line_char_to_offset(uint8_t * doc, int32_t len, int32_t line, int32_t character);
extern void lsp_doc_line_count(uint8_t * doc, int32_t len, int32_t * out_last_line, int32_t * out_last_line_char);
extern int32_t runtime_lsp_glue_lsp_json_is_ws(uint8_t c);
extern int32_t runtime_lsp_glue_lsp_match_quote_text_quote(uint8_t * body, int32_t i);
extern int32_t runtime_lsp_glue_lsp_match_quote_textdocument_quote(uint8_t * body, int32_t i);
extern int32_t lsp_find_text_value_from(uint8_t * body, int32_t len, int32_t search_start, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_find_text_value(uint8_t * body, int32_t len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_fmt_is_atom_tail(uint8_t c);
extern int32_t lsp_fmt_is_atom_head(uint8_t c);
extern int32_t lsp_fmt_unary_lhs(uint8_t prev);
extern int32_t col_in_ident_span(int32_t line, int32_t col, int32_t sl, int32_t sc, uint8_t * name);
extern int32_t runtime_lsp_glue_lsp_load_i32_at(uint8_t * p, int32_t off);
extern uint8_t * runtime_lsp_glue_lsp_load_ptr_at(uint8_t * p, int32_t off);
extern int32_t func_name_covers(uint8_t * f, int32_t line, int32_t col);
extern int32_t lsp_parse_int(uint8_t * body, int32_t len, int32_t offset, int32_t * out);
extern int32_t lsp_line_has_block_comment_end(uint8_t * doc, int32_t start, int32_t len);
extern uint8_t lsp_fmt_last_out(uint8_t * out_buf, int32_t out_len);
extern uint8_t lsp_fmt_prev_src(uint8_t * doc, int32_t start, int32_t j);
extern int32_t lsp_fmt_src_ws_before(uint8_t * doc, int32_t start, int32_t j);
extern int32_t lsp_fmt_src_ws_after(uint8_t * doc, int32_t start, int32_t len, int32_t j);
extern int32_t lsp_find_key_after(uint8_t * body, int32_t len, int32_t start, uint8_t * key);
extern int32_t lsp_extract_position_from_params(uint8_t * body, int32_t len, int32_t * out_line, int32_t * out_character);
extern int32_t lsp_line_is_block_comment(uint8_t * doc, int32_t content_start, int32_t content_len, int32_t in_block);
extern int32_t lsp_parse_bool_after(uint8_t * body, int32_t len, int32_t start, uint8_t * key, int32_t * out_val);
extern int32_t lsp_fmt_space_before(uint8_t * doc, int32_t start, int32_t j, uint8_t * out_buf, int32_t * out_len, int32_t out_cap);
extern int32_t lsp_fmt_space_after(uint8_t * doc, int32_t start, int32_t len, int32_t j, uint8_t * out_buf, int32_t * out_len, int32_t out_cap);
extern int32_t lsp_json_escape_ident(uint8_t * s, uint8_t * esc, int32_t esc_cap);
extern uint32_t lsp_hash_source(uint8_t * src, int32_t len);
/* Cap residual: 17 _impl bridges (thin+rest forwards target these). */
extern void lsp_free_import_cache_impl(void);
extern void lsp_init_lib_roots_once_impl(void);
extern int64_t lsp_diag_x_ctx_alloc_size_impl(void);
extern void build_line_index_impl(uint8_t * mod);
extern int32_t line_index_of_func_impl(uint8_t * f);
extern int32_t expr_at_impl(uint8_t * e, int32_t line, int32_t col);
extern int32_t expr_max_line_impl(uint8_t * e);
extern int32_t block_max_line_impl(uint8_t * b);
extern void add_ref_for_func_impl(uint8_t * f, int32_t line, int32_t col);
extern void build_refs_index_impl(uint8_t * mod);
extern int32_t find_def_in_module_impl(uint8_t * mod, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern void lsp_typeck_entry_module_impl(uint8_t * mod, int32_t only);
extern void collect_refs_index_in_expr_impl(uint8_t * e);
extern void collect_refs_index_in_block_impl(uint8_t * b);
extern int32_t find_def_in_expr_impl(uint8_t * mod, uint8_t * e, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern int32_t find_def_in_block_impl(uint8_t * mod, uint8_t * b, int32_t line, int32_t col, int32_t * ol, int32_t * oc);
extern int32_t type_to_string_impl(uint8_t * ty, uint8_t * buf, int32_t cap);
/* Cap residual: 6 lsp_ bridges (entry dir + json key providers, defined in rest C). */
extern void lsp_entry_dir_set_dot(void);
extern void lsp_entry_fs_path_store(uint8_t * path);
extern void lsp_entry_dir_store_prefix(uint8_t * path, int32_t n);
extern uint8_t * lsp_json_key_position(void);
extern uint8_t * lsp_json_key_line(void);
extern uint8_t * lsp_json_key_character(void);
int32_t runtime_lsp_glue_x_doc_anchor(void) {
  return 0;
}
void lsp_free_import_cache(void) {
  (void)(lsp_free_import_cache_impl());
}
int32_t runtime_lsp_glue_lsp_hex_nibble(int32_t c) {
  if ((c >=48)) {
    if ((c <=57)) {
      return (c - 48);
    }
  }
  if ((c >=97)) {
    if ((c <=102)) {
      return ((c - 97) + 10);
    }
  }
  if ((c >=65)) {
    if ((c <=70)) {
      return ((c - 65) + 10);
    }
  }
  return -1;
}
int32_t runtime_lsp_glue_lsp_uri_has_file_scheme(uint8_t * uri) {
  if ((uri ==0)) {
    return 0;
  }
  if (((uri)[0] !=102)) {
    return 0;
  }
  if (((uri)[1] !=105)) {
    return 0;
  }
  if (((uri)[2] !=108)) {
    return 0;
  }
  if (((uri)[3] !=101)) {
    return 0;
  }
  if (((uri)[4] !=58)) {
    return 0;
  }
  if (((uri)[5] !=47)) {
    return 0;
  }
  if (((uri)[6] !=47)) {
    return 0;
  }
  return 1;
}
void lsp_uri_to_fs_path(uint8_t * uri, uint8_t * out, int64_t cap) {
  if ((uri ==0)) {
    return;
  }
  if ((out ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  {
    (void)(((out)[0] = 0));
    if ((runtime_lsp_glue_lsp_uri_has_file_scheme(uri) ==0)) {
      return;
    }
    int64_t p = 7;
    int64_t k = 0;
    while (((k + 1) < cap)) {
      uint8_t c = (uri)[p];
      if ((c ==0)) {
        break;
      }
      if ((c ==37)) {
        int32_t hi = ((int32_t)((uri)[(p + 1)]));
        int32_t lo = ((int32_t)((uri)[(p + 2)]));
        if ((hi ==0)) {
          break;
        }
        if ((lo ==0)) {
          break;
        }
        int32_t vh = runtime_lsp_glue_lsp_hex_nibble(hi);
        int32_t vl = runtime_lsp_glue_lsp_hex_nibble(lo);
        int32_t v = 0;
        if ((vh >=0)) {
          (void)((v = (vh * 16)));
        }
        if ((vl >=0)) {
          (void)((v = (v + vl)));
        }
        (void)(((out)[k] = ((uint8_t)(v))));
        (void)((k = (k + 1)));
        (void)((p = (p + 3)));
      } else {
        (void)(((out)[k] = c));
        (void)((k = (k + 1)));
        (void)((p = (p + 1)));
      }
    }
    (void)(((out)[k] = 0));
  }
}
void lsp_fs_path_to_uri(uint8_t * path, uint8_t * uri, int32_t cap) {
  if ((path ==0)) {
    return;
  }
  if ((uri ==0)) {
    return;
  }
  if ((cap < 8)) {
    return;
  }
  int32_t k = 0;
  (void)(((uri)[k] = ((uint8_t)(102))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(105))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(108))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(101))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(58))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(47))));
  (void)((k = (k + 1)));
  (void)(((uri)[k] = ((uint8_t)(47))));
  (void)((k = (k + 1)));
  int32_t p = 0;
  while (((k + 4) < cap)) {
    uint8_t c = (path)[p];
    if ((c ==0)) {
      break;
    }
    if ((c ==32)) {
      (void)(((uri)[k] = ((uint8_t)(37))));
      (void)((k = (k + 1)));
      (void)(((uri)[k] = ((uint8_t)(50))));
      (void)((k = (k + 1)));
      (void)(((uri)[k] = ((uint8_t)(48))));
      (void)((k = (k + 1)));
    } else {
      (void)(((uri)[k] = c));
      (void)((k = (k + 1)));
    }
    (void)((p = (p + 1)));
  }
  (void)(((uri)[k] = ((uint8_t)(0))));
}
int32_t lsp_path_last_slash(uint8_t * path) {
  if ((path ==0)) {
    return -1;
  }
  {
    int32_t last = -1;
    int32_t i = 0;
    while ((i < 4096)) {
      if (((path)[i] ==0)) {
        break;
      }
      if (((path)[i] ==47)) {
        (void)((last = i));
      }
      (void)((i = (i + 1)));
    }
    return last;
  }
  return -1;
}
void lsp_update_entry_dir(uint8_t * path) {
  {
    if ((path ==0)) {
      (void)(lsp_entry_dir_set_dot());
      return;
    }
    if (((path)[0] ==0)) {
      (void)(lsp_entry_dir_set_dot());
      return;
    }
    (void)(lsp_entry_fs_path_store(path));
    int32_t last = lsp_path_last_slash(path);
    if ((last < 0)) {
      (void)(lsp_entry_dir_set_dot());
      return;
    }
    int32_t n = last;
    if ((n > 511)) {
      (void)((n = 511));
    }
    (void)(lsp_entry_dir_store_prefix(path, n));
  }
}
void lsp_init_lib_roots_once(void) {
  (void)(lsp_init_lib_roots_once_impl());
}
void lsp_diag_copy_text(uint8_t * dst, int32_t cap, uint8_t * src) {
  if ((dst ==0)) {
    return;
  }
  if ((cap <=0)) {
    return;
  }
  {
    if ((src ==0)) {
      (void)(((dst)[0] = 0));
      return;
    }
    int32_t n = 0;
    while (((n + 1) < cap)) {
      uint8_t c = (src)[n];
      if ((c ==0)) {
        break;
      }
      (void)(((dst)[n] = c));
      (void)((n = (n + 1)));
    }
    (void)(((dst)[n] = 0));
  }
}
int64_t lsp_diag_x_ctx_alloc_size(void) {
  return lsp_diag_x_ctx_alloc_size_impl();
  return 0;
}
int32_t json_escape_str(uint8_t * msg, uint8_t * out, int32_t cap) {
  if ((out ==0)) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  if ((msg ==0)) {
    (void)(((out)[0] = 0));
    return 0;
  }
  {
    int32_t k = 0;
    int32_t i = 0;
    while ((k < (cap - 1))) {
      uint8_t c = (msg)[i];
      if ((c ==0)) {
        break;
      }
      if ((c ==34)) {
        if (((k + 2) > (cap - 1))) {
          break;
        }
        (void)(((out)[k] = 92));
        (void)((k = (k + 1)));
        (void)(((out)[k] = 34));
        (void)((k = (k + 1)));
      } else {
        if ((c ==92)) {
          if (((k + 2) > (cap - 1))) {
            break;
          }
          (void)(((out)[k] = 92));
          (void)((k = (k + 1)));
          (void)(((out)[k] = 92));
          (void)((k = (k + 1)));
        } else {
          if ((c ==10)) {
            if (((k + 2) > (cap - 1))) {
              break;
            }
            (void)(((out)[k] = 92));
            (void)((k = (k + 1)));
            (void)(((out)[k] = 110));
            (void)((k = (k + 1)));
          } else {
            if ((c ==13)) {
              if (((k + 2) > (cap - 1))) {
                break;
              }
              (void)(((out)[k] = 92));
              (void)((k = (k + 1)));
              (void)(((out)[k] = 114));
              (void)((k = (k + 1)));
            } else {
              if ((c ==9)) {
                if (((k + 2) > (cap - 1))) {
                  break;
                }
                (void)(((out)[k] = 92));
                (void)((k = (k + 1)));
                (void)(((out)[k] = 116));
                (void)((k = (k + 1)));
              } else {
                (void)(((out)[k] = c));
                (void)((k = (k + 1)));
              }
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
    (void)(((out)[k] = 0));
    return k;
  }
  return 0;
}
void build_line_index(uint8_t * mod) {
  (void)(build_line_index_impl(mod));
}
int32_t line_index_of_func(uint8_t * f) {
  return line_index_of_func_impl(f);
  return 0;
}
int32_t expr_at(uint8_t * e, int32_t line, int32_t col) {
  return expr_at_impl(e, line, col);
  return 0;
}
int32_t expr_max_line(uint8_t * e) {
  return expr_max_line_impl(e);
  return 0;
}
int32_t block_max_line(uint8_t * b) {
  return block_max_line_impl(b);
  return 0;
}
void add_ref_for_func(uint8_t * f, int32_t line, int32_t col) {
  (void)(add_ref_for_func_impl(f, line, col));
}
void build_refs_index(uint8_t * mod) {
  (void)(build_refs_index_impl(mod));
}
int32_t find_def_in_module(uint8_t * mod, int32_t line, int32_t col, int32_t * ol, int32_t * oc) {
  return find_def_in_module_impl(mod, line, col, ol, oc);
  return 0;
}
void lsp_typeck_entry_module(uint8_t * mod, int32_t only) {
  (void)(lsp_typeck_entry_module_impl(mod, only));
}
void collect_refs_index_in_expr(uint8_t * e) {
  (void)(collect_refs_index_in_expr_impl(e));
}
void collect_refs_index_in_block(uint8_t * b) {
  (void)(collect_refs_index_in_block_impl(b));
}
int32_t find_def_in_expr(uint8_t * mod, uint8_t * e, int32_t line, int32_t col, int32_t * ol, int32_t * oc) {
  return find_def_in_expr_impl(mod, e, line, col, ol, oc);
  return 0;
}
int32_t find_def_in_block(uint8_t * mod, uint8_t * b, int32_t line, int32_t col, int32_t * ol, int32_t * oc) {
  return find_def_in_block_impl(mod, b, line, col, ol, oc);
  return 0;
}
int32_t type_to_string(uint8_t * ty, uint8_t * buf, int32_t cap) {
  return type_to_string_impl(ty, buf, cap);
  return 0;
}
int32_t line_char_to_offset(uint8_t * doc, int32_t len, int32_t line, int32_t character) {
  if ((doc ==0)) {
    return -1;
  }
  if ((len < 0)) {
    return -1;
  }
  if ((line < 0)) {
    return -1;
  }
  if ((character < 0)) {
    return -1;
  }
  {
    int32_t cur_line = 0;
    int32_t i = 0;
    while ((i < len)) {
      if ((cur_line >=line)) {
        break;
      }
      if (((doc)[i] ==10)) {
        (void)((cur_line = (cur_line + 1)));
      }
      (void)((i = (i + 1)));
    }
    if ((cur_line !=line)) {
      return -1;
    }
    int32_t col = 0;
    while ((col < character)) {
      if ((i >=len)) {
        break;
      }
      if (((doc)[i] ==10)) {
        break;
      }
      (void)((col = (col + 1)));
      (void)((i = (i + 1)));
    }
    if ((col !=character)) {
      return -1;
    }
    return i;
  }
  return -1;
}
void lsp_doc_line_count(uint8_t * doc, int32_t len, int32_t * out_last_line, int32_t * out_last_line_char) {
  if ((out_last_line ==0)) {
    return;
  }
  if ((out_last_line_char ==0)) {
    return;
  }
  {
    if ((doc ==0)) {
      (void)(((out_last_line)[0] = 0));
      (void)(((out_last_line_char)[0] = 0));
      return;
    }
    if ((len < 0)) {
      (void)(((out_last_line)[0] = 0));
      (void)(((out_last_line_char)[0] = 0));
      return;
    }
    int32_t lines = 0;
    int32_t last_char = 0;
    int32_t i = 0;
    while ((i < len)) {
      if (((doc)[i] ==10)) {
        (void)((lines = (lines + 1)));
        (void)((last_char = 0));
      } else {
        (void)((last_char = (last_char + 1)));
      }
      (void)((i = (i + 1)));
    }
    if ((lines > 0)) {
      (void)(((out_last_line)[0] = (lines - 1)));
    } else {
      (void)(((out_last_line)[0] = 0));
    }
    (void)(((out_last_line_char)[0] = last_char));
  }
}
int32_t runtime_lsp_glue_lsp_json_is_ws(uint8_t c) {
  if ((c ==32)) {
    return 1;
  }
  if ((c ==9)) {
    return 1;
  }
  if ((c ==10)) {
    return 1;
  }
  if ((c ==13)) {
    return 1;
  }
  return 0;
}
int32_t runtime_lsp_glue_lsp_match_quote_text_quote(uint8_t * body, int32_t i) {
  if (((body)[i] !=34)) {
    return 0;
  }
  if (((body)[(i + 1)] !=116)) {
    return 0;
  }
  if (((body)[(i + 2)] !=101)) {
    return 0;
  }
  if (((body)[(i + 3)] !=120)) {
    return 0;
  }
  if (((body)[(i + 4)] !=116)) {
    return 0;
  }
  if (((body)[(i + 5)] !=34)) {
    return 0;
  }
  return 1;
}
int32_t runtime_lsp_glue_lsp_match_quote_textdocument_quote(uint8_t * body, int32_t i) {
  if (((body)[i] !=34)) {
    return 0;
  }
  if (((body)[(i + 1)] !=116)) {
    return 0;
  }
  if (((body)[(i + 2)] !=101)) {
    return 0;
  }
  if (((body)[(i + 3)] !=120)) {
    return 0;
  }
  if (((body)[(i + 4)] !=116)) {
    return 0;
  }
  if (((body)[(i + 5)] !=68)) {
    return 0;
  }
  if (((body)[(i + 6)] !=111)) {
    return 0;
  }
  if (((body)[(i + 7)] !=99)) {
    return 0;
  }
  if (((body)[(i + 8)] !=117)) {
    return 0;
  }
  if (((body)[(i + 9)] !=109)) {
    return 0;
  }
  if (((body)[(i + 10)] !=101)) {
    return 0;
  }
  if (((body)[(i + 11)] !=110)) {
    return 0;
  }
  if (((body)[(i + 12)] !=116)) {
    return 0;
  }
  if (((body)[(i + 13)] !=34)) {
    return 0;
  }
  return 1;
}
int32_t lsp_find_text_value_from(uint8_t * body, int32_t len, int32_t search_start, uint8_t * out_buf, int32_t out_cap) {
  if ((body ==0)) {
    return -1;
  }
  if ((out_buf ==0)) {
    return -1;
  }
  if ((out_cap <=0)) {
    return -1;
  }
  if ((len < 0)) {
    return -1;
  }
  if ((search_start < 0)) {
    return -1;
  }
  {
    int32_t i = search_start;
    while (((i + 6) <=len)) {
      if ((runtime_lsp_glue_lsp_match_quote_text_quote(body, i) ==0)) {
        (void)((i = (i + 1)));
      } else {
        int32_t s = (i + 6);
        while ((s < len)) {
          if ((runtime_lsp_glue_lsp_json_is_ws((body)[s]) ==0)) {
            break;
          }
          (void)((s = (s + 1)));
        }
        if ((s >=len)) {
          (void)((i = (i + 1)));
        } else {
          if (((body)[s] !=58)) {
            (void)((i = (i + 1)));
          } else {
            (void)((s = (s + 1)));
            while ((s < len)) {
              if ((runtime_lsp_glue_lsp_json_is_ws((body)[s]) ==0)) {
                break;
              }
              (void)((s = (s + 1)));
            }
            if ((s >=len)) {
              (void)((i = (i + 1)));
            } else {
              if (((body)[s] !=34)) {
                (void)((i = (i + 1)));
              } else {
                int32_t start = (s + 1);
                int32_t out_len = 0;
                while ((start < len)) {
                  if ((out_len >=(out_cap - 1))) {
                    break;
                  }
                  uint8_t c = (body)[start];
                  if ((c ==34)) {
                    if ((start ==0)) {
                      break;
                    }
                    if (((body)[(start - 1)] !=92)) {
                      break;
                    }
                  }
                  if ((c ==92)) {
                    if (((start + 1) >=len)) {
                      break;
                    }
                    (void)((start = (start + 1)));
                    uint8_t e = (body)[start];
                    if ((e ==110)) {
                      (void)(((out_buf)[out_len] = 10));
                    } else {
                      if ((e ==114)) {
                        (void)(((out_buf)[out_len] = 13));
                      } else {
                        if ((e ==116)) {
                          (void)(((out_buf)[out_len] = 9));
                        } else {
                          (void)(((out_buf)[out_len] = e));
                        }
                      }
                    }
                    (void)((out_len = (out_len + 1)));
                    (void)((start = (start + 1)));
                  } else {
                    (void)(((out_buf)[out_len] = c));
                    (void)((out_len = (out_len + 1)));
                    (void)((start = (start + 1)));
                  }
                }
                (void)(((out_buf)[out_len] = 0));
                return out_len;
              }
            }
          }
        }
      }
    }
  }
  return -1;
}
int32_t lsp_find_text_value(uint8_t * body, int32_t len, uint8_t * out_buf, int32_t out_cap) {
  if ((body ==0)) {
    return -1;
  }
  if ((out_buf ==0)) {
    return -1;
  }
  if ((out_cap <=0)) {
    return -1;
  }
  if ((len < 0)) {
    return -1;
  }
  {
    int32_t i = 0;
    while (((i + 14) <=len)) {
      if ((runtime_lsp_glue_lsp_match_quote_textdocument_quote(body, i) !=0)) {
        int32_t n = lsp_find_text_value_from(body, len, (i + 14), out_buf, out_cap);
        if ((n >=0)) {
          return n;
        }
      }
      (void)((i = (i + 1)));
    }
  }
  return lsp_find_text_value_from(body, len, 0, out_buf, out_cap);
}
int32_t lsp_fmt_is_atom_tail(uint8_t c) {
  if ((c >=97)) {
    if ((c <=122)) {
      return 1;
    }
  }
  if ((c >=65)) {
    if ((c <=90)) {
      return 1;
    }
  }
  if ((c >=48)) {
    if ((c <=57)) {
      return 1;
    }
  }
  if ((c ==95)) {
    return 1;
  }
  if ((c ==41)) {
    return 1;
  }
  if ((c ==93)) {
    return 1;
  }
  if ((c ==125)) {
    return 1;
  }
  return 0;
}
int32_t lsp_fmt_is_atom_head(uint8_t c) {
  if ((c >=97)) {
    if ((c <=122)) {
      return 1;
    }
  }
  if ((c >=65)) {
    if ((c <=90)) {
      return 1;
    }
  }
  if ((c >=48)) {
    if ((c <=57)) {
      return 1;
    }
  }
  if ((c ==95)) {
    return 1;
  }
  if ((c ==40)) {
    return 1;
  }
  if ((c ==91)) {
    return 1;
  }
  if ((c ==123)) {
    return 1;
  }
  return 0;
}
int32_t lsp_fmt_unary_lhs(uint8_t prev) {
  if ((prev ==0)) {
    return 1;
  }
  if ((prev ==40)) {
    return 1;
  }
  if ((prev ==91)) {
    return 1;
  }
  if ((prev ==123)) {
    return 1;
  }
  if ((prev ==44)) {
    return 1;
  }
  if ((prev ==58)) {
    return 1;
  }
  if ((prev ==59)) {
    return 1;
  }
  if ((prev ==61)) {
    return 1;
  }
  if ((prev ==43)) {
    return 1;
  }
  if ((prev ==45)) {
    return 1;
  }
  if ((prev ==42)) {
    return 1;
  }
  if ((prev ==47)) {
    return 1;
  }
  if ((prev ==37)) {
    return 1;
  }
  if ((prev ==38)) {
    return 1;
  }
  if ((prev ==124)) {
    return 1;
  }
  if ((prev ==94)) {
    return 1;
  }
  if ((prev ==33)) {
    return 1;
  }
  if ((prev ==126)) {
    return 1;
  }
  if ((prev ==60)) {
    return 1;
  }
  if ((prev ==62)) {
    return 1;
  }
  return 0;
}
int32_t col_in_ident_span(int32_t line, int32_t col, int32_t sl, int32_t sc, uint8_t * name) {
  if ((name ==0)) {
    return 0;
  }
  if ((sl !=line)) {
    return 0;
  }
  if ((sc <=0)) {
    return 0;
  }
  int32_t len = 0;
  while ((len < 512)) {
    if (((name)[len] ==0)) {
      break;
    }
    (void)((len = (len + 1)));
  }
  if ((len <=0)) {
    return 0;
  }
  if ((col < sc)) {
    return 0;
  }
  if ((col >=(sc + len))) {
    return 0;
  }
  return 1;
}
int32_t runtime_lsp_glue_lsp_load_i32_at(uint8_t * p, int32_t off) {
  int32_t m = 256;
  int32_t a = ((int32_t)((p)[off]));
  (void)((a = (a + (((int32_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((int32_t)((p)[(off + 2)])) * (m * m)))));
  (void)((a = (a + (((int32_t)((p)[(off + 3)])) * ((m * m) * m)))));
  return a;
}
uint8_t * runtime_lsp_glue_lsp_load_ptr_at(uint8_t * p, int32_t off) {
  if ((p ==0)) {
    return ((uint8_t *)(0));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((p)[off]));
  (void)((a = (a + (((size_t)((p)[(off + 1)])) * m))));
  (void)((a = (a + (((size_t)((p)[(off + 2)])) * m2))));
  (void)((a = (a + (((size_t)((p)[(off + 3)])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 4)])) * m4))));
  (void)((a = (a + (((size_t)((p)[(off + 5)])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((p)[(off + 6)])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((p)[(off + 7)])) * ((m4 * m2) * m)))));
  return ((uint8_t *)(a));
}
int32_t func_name_covers(uint8_t * f, int32_t line, int32_t col) {
  if ((f ==0)) {
    return 0;
  }
  uint8_t * name = runtime_lsp_glue_lsp_load_ptr_at(f, 8);
  if ((name ==0)) {
    return 0;
  }
  int32_t sl = runtime_lsp_glue_lsp_load_i32_at(f, 0);
  int32_t sc = runtime_lsp_glue_lsp_load_i32_at(f, 4);
  return col_in_ident_span(line, col, sl, sc, name);
}
int32_t lsp_parse_int(uint8_t * body, int32_t len, int32_t offset, int32_t * out) {
  if ((body ==0)) {
    return -1;
  }
  if ((out ==0)) {
    return -1;
  }
  if ((len < 0)) {
    return -1;
  }
  if ((offset < 0)) {
    return -1;
  }
  if ((offset >=len)) {
    return -1;
  }
  (void)(((out)[0] = 0));
  while ((offset < len)) {
    uint8_t c = (body)[offset];
    if ((c < 48)) {
      break;
    }
    if ((c > 57)) {
      break;
    }
    int32_t v = (out)[0];
    (void)(((out)[0] = ((v * 10) + (((int32_t)(c)) - 48))));
    (void)((offset = (offset + 1)));
  }
  return offset;
}
int32_t lsp_line_has_block_comment_end(uint8_t * doc, int32_t start, int32_t len) {
  int32_t i = 0;
  while (((i + 1) < len)) {
    if (((doc)[(start + i)] ==42)) {
      if (((doc)[((start + i) + 1)] ==47)) {
        return 1;
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t lsp_fmt_last_out(uint8_t * out_buf, int32_t out_len) {
  int32_t k = (out_len - 1);
  while ((k >=0)) {
    uint8_t c = (out_buf)[k];
    if ((c !=32)) {
      if ((c !=9)) {
        return c;
      }
    }
    (void)((k = (k - 1)));
  }
  return ((uint8_t)(0));
}
uint8_t lsp_fmt_prev_src(uint8_t * doc, int32_t start, int32_t j) {
  int32_t k = (j - 1);
  while ((k >=0)) {
    uint8_t c = (doc)[(start + k)];
    if ((c !=32)) {
      if ((c !=9)) {
        if ((c !=13)) {
          return c;
        }
      }
    }
    (void)((k = (k - 1)));
  }
  return ((uint8_t)(0));
}
int32_t lsp_fmt_src_ws_before(uint8_t * doc, int32_t start, int32_t j) {
  int32_t k = (j - 1);
  if ((k < 0)) {
    return 0;
  }
  uint8_t c = (doc)[(start + k)];
  if ((c ==32)) {
    return 1;
  }
  if ((c ==9)) {
    return 1;
  }
  return 0;
}
int32_t lsp_fmt_src_ws_after(uint8_t * doc, int32_t start, int32_t len, int32_t j) {
  int32_t k = (j + 1);
  if ((k >=len)) {
    return 0;
  }
  uint8_t c = (doc)[(start + k)];
  if ((c ==32)) {
    return 1;
  }
  if ((c ==9)) {
    return 1;
  }
  return 0;
}
int32_t lsp_find_key_after(uint8_t * body, int32_t len, int32_t start, uint8_t * key) {
  if ((body ==0)) {
    return -1;
  }
  if ((key ==0)) {
    return -1;
  }
  if ((len < 0)) {
    return -1;
  }
  if ((start < 0)) {
    return -1;
  }
  {
    int32_t key_len = 0;
    while ((key_len < 256)) {
      if (((key)[key_len] ==0)) {
        break;
      }
      (void)((key_len = (key_len + 1)));
    }
    if ((key_len <=0)) {
      return -1;
    }
    int32_t s = start;
    while (((s + key_len) <=len)) {
      int32_t matched = 1;
      int32_t j = 0;
      while ((j < key_len)) {
        if (((body)[(s + j)] !=(key)[j])) {
          (void)((matched = 0));
          break;
        }
        (void)((j = (j + 1)));
      }
      if ((matched !=0)) {
        return (s + key_len);
      }
      (void)((s = (s + 1)));
    }
  }
  return -1;
}
int32_t lsp_extract_position_from_params(uint8_t * body, int32_t len, int32_t * out_line, int32_t * out_character) {
  if ((body ==0)) {
    return -1;
  }
  if ((len <=0)) {
    return -1;
  }
  if ((out_line ==0)) {
    return -1;
  }
  if ((out_character ==0)) {
    return -1;
  }
  {
    int32_t pos = lsp_find_key_after(body, len, 0, lsp_json_key_position());
    if ((pos < 0)) {
      return -1;
    }
    int32_t line_start = lsp_find_key_after(body, len, pos, lsp_json_key_line());
    if ((line_start < 0)) {
      return -1;
    }
    int32_t char_start = lsp_find_key_after(body, len, pos, lsp_json_key_character());
    if ((char_start < 0)) {
      return -1;
    }
    int32_t line_end = lsp_parse_int(body, len, line_start, out_line);
    if ((line_end < 0)) {
      return -1;
    }
    int32_t char_end = lsp_parse_int(body, len, char_start, out_character);
    if ((char_end < 0)) {
      return -1;
    }
  }
  return 0;
}
int32_t lsp_line_is_block_comment(uint8_t * doc, int32_t content_start, int32_t content_len, int32_t in_block) {
  if ((doc ==0)) {
    return 0;
  }
  if ((content_len >=2)) {
    if (((doc)[content_start] ==47)) {
      if (((doc)[(content_start + 1)] ==42)) {
        return 1;
      }
    }
  }
  if ((in_block !=0)) {
    if ((content_len >=1)) {
      if (((doc)[content_start] ==42)) {
        return 1;
      }
    }
  }
  return 0;
}
int32_t lsp_parse_bool_after(uint8_t * body, int32_t len, int32_t start, uint8_t * key, int32_t * out_val) {
  if ((out_val ==0)) {
    return -1;
  }
  int32_t k = lsp_find_key_after(body, len, start, key);
  if ((k < 0)) {
    return -1;
  }
  if (((k + 4) <=len)) {
    if ((((((body)[k] ==116) && ((body)[(k + 1)] ==114)) && ((body)[(k + 2)] ==117)) && ((body)[(k + 3)] ==101))) {
      (void)(((out_val)[0] = 1));
      return 0;
    }
  }
  if (((k + 5) <=len)) {
    if (((((((body)[k] ==102) && ((body)[(k + 1)] ==97)) && ((body)[(k + 2)] ==108)) && ((body)[(k + 3)] ==115)) && ((body)[(k + 4)] ==101))) {
      (void)(((out_val)[0] = 0));
      return 0;
    }
  }
  return -1;
}
int32_t lsp_fmt_space_before(uint8_t * doc, int32_t start, int32_t j, uint8_t * out_buf, int32_t * out_len, int32_t out_cap) {
  if ((out_buf ==0)) {
    return 0;
  }
  if ((out_len ==0)) {
    return 0;
  }
  if ((lsp_fmt_src_ws_before(doc, start, j) !=0)) {
    return 0;
  }
  {
    int32_t olen = (out_len)[0];
    uint8_t last = lsp_fmt_last_out(out_buf, olen);
    if ((last !=0)) {
      if ((last !=32)) {
        if ((last !=9)) {
          if ((olen < (out_cap - 1))) {
            (void)(((out_buf)[olen] = 32));
            (void)(((out_len)[0] = (olen + 1)));
            return 1;
          }
        }
      }
    }
  }
  return 0;
}
int32_t lsp_fmt_space_after(uint8_t * doc, int32_t start, int32_t len, int32_t j, uint8_t * out_buf, int32_t * out_len, int32_t out_cap) {
  if ((out_buf ==0)) {
    return 0;
  }
  if ((out_len ==0)) {
    return 0;
  }
  if ((lsp_fmt_src_ws_after(doc, start, len, j) !=0)) {
    return 0;
  }
  int32_t k = (j + 1);
  while ((k < len)) {
    uint8_t n = (doc)[(start + k)];
    if ((n ==32)) {
      (void)((k = (k + 1)));
      continue;
    }
    if ((n ==9)) {
      (void)((k = (k + 1)));
      continue;
    }
    if ((n ==13)) {
      (void)((k = (k + 1)));
      continue;
    }
    if ((lsp_fmt_is_atom_head(n) !=0)) {
      {
        int32_t olen = (out_len)[0];
        if ((olen < (out_cap - 1))) {
          (void)(((out_buf)[olen] = 32));
          (void)(((out_len)[0] = (olen + 1)));
          return 1;
        }
      }
    }
    return 0;
  }
  return 0;
}
int32_t lsp_json_escape_ident(uint8_t * s, uint8_t * esc, int32_t esc_cap) {
  if ((s ==0)) {
    return 0;
  }
  if ((esc ==0)) {
    return 0;
  }
  if ((esc_cap < 4)) {
    return 0;
  }
  int32_t e = 0;
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if ((e >=(esc_cap - 3))) {
      break;
    }
    uint8_t c = (s)[i];
    if ((c ==34)) {
      (void)(((esc)[e] = 92));
      (void)((e = (e + 1)));
      if ((e >=(esc_cap - 1))) {
        break;
      }
      (void)(((esc)[e] = c));
      (void)((e = (e + 1)));
    } else {
      if ((c ==92)) {
        (void)(((esc)[e] = 92));
        (void)((e = (e + 1)));
        if ((e >=(esc_cap - 1))) {
          break;
        }
        (void)(((esc)[e] = c));
        (void)((e = (e + 1)));
      } else {
        (void)(((esc)[e] = c));
        (void)((e = (e + 1)));
      }
    }
    (void)((i = (i + 1)));
  }
  (void)(((esc)[e] = 0));
  return e;
}
uint32_t lsp_hash_source(uint8_t * src, int32_t len) {
  if ((src ==0)) {
    return 0;
  }
  uint64_t golden_hi = ((uint64_t)(2654435769));
  uint64_t golden_lo = 2135587861;
  uint64_t two32 = ((uint64_t)(4294967296));
  uint64_t golden = ((golden_hi * two32) + golden_lo);
  uint64_t h = ((uint64_t)(len));
  int32_t i = 0;
  while (((i + 8) <=len)) {
    uint64_t x = 0;
    int32_t k = 0;
    while ((k < 8)) {
      uint64_t b = ((uint64_t)((src)[(i + k)]));
      uint64_t shift = 1;
      int32_t s = 0;
      while ((s < k)) {
        (void)((shift = (shift * 256)));
        (void)((s = (s + 1)));
      }
      (void)((x = (x + (b * shift))));
      (void)((k = (k + 1)));
    }
    (void)((h = ((h * golden) + x)));
    (void)((i = (i + 8)));
  }
  while ((i < len)) {
    (void)((h = ((h * golden) + ((uint64_t)((src)[i])))));
    (void)((i = (i + 1)));
  }
  return ((uint32_t)((h ^ (h / two32))));
}
