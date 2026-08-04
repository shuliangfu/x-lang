/* seeds/diag_surface.from_x.c
 * G-02f diag R2 mixed surface - isomorphic with src/diag.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/diag.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (42 symbols)
 * Mode: mixed - 35 DIRECT compute + 7 thin+rest forwards to bridges
 * Cap residual: 39 extern bridges (36 used + 3 unused _impl)
 *   Used: diag_ctx_ (5), diag_json_get/set_state (2), diag_code_table_ (6),
 *     diag_entry_ (4), link_abi_getenv (1), diag_stderr/stdout (2), diag_io_ (16).
 *   Unused _impl: diag_code_eq_impl, diag_kind_is_exact_impl, diag_line_digits_impl.
 * doc_anchor: none (diag.x has no doc_anchor)
 * Logic: 42 functions = 35 DIRECT compute
 *   + 7 thin+rest forwards (diag_get_file -> diag_ctx_get_file,
 *     diag_get_source -> diag_ctx_get_source, diag_get_source_len -> diag_ctx_get_source_len,
 *     diag_code_is_known -> diag_code_table_has, diag_code_kind -> diag_entry_kind,
 *     diag_code_summary -> diag_entry_summary, diag_code_details -> diag_entry_details)
 * Regen: xlang_asm -E src/diag.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>
/* Forward declarations for all 42 surface functions (nm IDENTICAL targets). */
extern uint8_t * diag_palette_kind_color(uint8_t * kind);
extern uint8_t * diag_palette_caret_color(uint8_t * kind);
extern void diag_report_human(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void diag_report(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * msg, uint8_t * detail);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern uint8_t * diag_get_file(void);
extern uint8_t * diag_get_source(void);
extern int64_t diag_get_source_len(void);
extern void diag_set_file(uint8_t * path, uint8_t * source, int64_t source_len);
extern void diag_snap_store_ptr(uint8_t * snap, int32_t off, uint8_t * val);
extern void diag_snap_store_usize(uint8_t * snap, int32_t off, size_t val);
extern void diag_snap_store_i32(uint8_t * snap, int32_t off, int32_t val);
extern uint8_t * diag_snap_load_ptr(uint8_t * snap, int32_t off);
extern size_t diag_snap_load_usize(uint8_t * snap, int32_t off);
extern int32_t diag_snap_load_i32(uint8_t * snap, int32_t off);
extern void diag_push_file(uint8_t * snapshot, uint8_t * path, uint8_t * source, int64_t source_len);
extern void diag_restore(uint8_t * snapshot);
extern int32_t diag_code_is_known(uint8_t * code);
extern uint8_t * diag_code_kind(uint8_t * code);
extern uint8_t * diag_code_summary(uint8_t * code);
extern uint8_t * diag_code_details(uint8_t * code);
extern void diag_print_known_codes(uint8_t * out);
extern void diag_print_code_explain(uint8_t * out, uint8_t * code);
extern void diag_print_code_table(uint8_t * out);
extern void diag_set_json_mode(int32_t enable);
extern int32_t diag_json_enabled(void);
extern int32_t diag_should_color(void);
extern uint8_t * diag_color_prefix(uint8_t * plain, uint8_t * color);
extern uint8_t * diag_color_reset(void);
extern void diag_store_ptr_le(uint8_t * p, uint8_t * val);
extern void diag_store_usize_le(uint8_t * p, size_t val);
extern void diag_print_header(uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * kind_color, uint8_t * reset);
extern int32_t diag_extract_line(int32_t line_no, uint8_t * line_start_out, uint8_t * line_len_out);
extern void diag_json_write_str(uint8_t * out, uint8_t * s);
extern void diag_report_json(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg);
extern uint8_t * diag_code_suggest(uint8_t * code, uint8_t * out, int64_t out_cap);
extern int32_t diag_levenshtein_ci(uint8_t * a, uint8_t * b);
extern int32_t diag_kind_contains(uint8_t * kind, uint8_t * needle);
extern int32_t diag_line_digits(int32_t line);
extern int32_t diag_kind_is_exact(uint8_t * kind, uint8_t * needle);
extern int32_t diag_code_eq(uint8_t * lhs, uint8_t * rhs);
extern uint8_t * diag_json_severity(uint8_t * kind);
/* Cap residual: 36 used extern bridges (rest C dependencies). */
extern int32_t diag_json_get_state(void);
extern void diag_json_set_state(int32_t v);
extern int32_t diag_ctx_get_use_color(void);
extern uint8_t * diag_ctx_get_file(void);
extern uint8_t * diag_ctx_get_source(void);
extern int64_t diag_ctx_get_source_len(void);
extern void diag_ctx_set_all(uint8_t * path, uint8_t * source, int64_t source_len, int32_t use_color);
extern int32_t diag_code_table_has(uint8_t * code);
extern int64_t diag_code_table_len(void);
extern uint8_t * diag_code_table_code_at(int64_t i);
extern uint8_t * diag_code_table_kind_at(int64_t i);
extern uint8_t * diag_code_table_summary_at(int64_t i);
extern uint8_t * diag_code_table_details_at(int64_t i);
extern uint8_t * diag_entry_code(uint8_t * code);
extern uint8_t * diag_entry_kind(uint8_t * code);
extern uint8_t * diag_entry_summary(uint8_t * code);
extern uint8_t * diag_entry_details(uint8_t * code);
extern uint8_t * link_abi_getenv(uint8_t * name);
extern uint8_t * diag_stderr(void);
extern uint8_t * diag_stdout(void);
extern int32_t diag_io_fputc(uint8_t * o, int32_t c);
extern int32_t diag_io_fputs(uint8_t * s, uint8_t * o);
extern void diag_io_fputs_u04x(uint8_t * o, int32_t c);
extern void diag_io_fflush(uint8_t * o);
extern void diag_io_fprint_line_col(uint8_t * o, int32_t line, int32_t col);
extern void diag_io_fprint_unknown_code(uint8_t * o, uint8_t * code);
extern void diag_io_fprint_code_table_hdr(uint8_t * o);
extern void diag_io_fprint_code_table_row(uint8_t * o, uint8_t * code, uint8_t * kind, uint8_t * summary);
extern void diag_io_fprint_loc_file_line_col(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_loc_file_line(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, uint8_t * rs);
extern void diag_io_fprint_loc_file(uint8_t * o, uint8_t * pc, uint8_t * file, uint8_t * rs);
extern void diag_io_fprint_loc_line_col(uint8_t * o, uint8_t * pc, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_gutter_blank(uint8_t * o, int32_t width);
extern void diag_io_fprint_src_line(uint8_t * o, int32_t line, uint8_t * start, int32_t len);
extern void diag_io_fprint_gutter_bar(uint8_t * o, int32_t width);
extern void diag_io_fprint_caret_mark(uint8_t * o, uint8_t * cc, uint8_t * rs, uint8_t * detail);
/* Cap residual: 3 unused _impl bridges (declared by -E, not called by surface). */
extern int32_t diag_code_eq_impl(uint8_t * lhs, uint8_t * rhs);
extern int32_t diag_kind_is_exact_impl(uint8_t * kind, uint8_t * needle);
extern int32_t diag_line_digits_impl(int32_t line);
uint8_t * diag_palette_kind_color(uint8_t * kind) {
  if ((kind ==0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x37\x6d"));
  }
  if (((kind)[0] ==0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x37\x6d"));
  }
  if ((diag_kind_contains(kind, ((uint8_t *)"\x65\x72\x72\x6f\x72")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x31\x6d"));
  }
  if ((diag_kind_contains(kind, ((uint8_t *)"\x77\x61\x72\x6e\x69\x6e\x67")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x33\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x69\x6e\x66\x6f")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x36\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x6e\x6f\x74\x65")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x34\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x68\x65\x6c\x70")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x32\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x68\x69\x6e\x74")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x32\x6d"));
  }
  return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x31\x3b\x33\x37\x6d"));
  return ((uint8_t *)"");
}
uint8_t * diag_palette_caret_color(uint8_t * kind) {
  if ((kind ==0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x37\x6d"));
  }
  if (((kind)[0] ==0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x37\x6d"));
  }
  if ((diag_kind_contains(kind, ((uint8_t *)"\x65\x72\x72\x6f\x72")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x31\x6d"));
  }
  if ((diag_kind_contains(kind, ((uint8_t *)"\x77\x61\x72\x6e\x69\x6e\x67")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x33\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x69\x6e\x66\x6f")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x36\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x6e\x6f\x74\x65")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x34\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x68\x65\x6c\x70")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x32\x6d"));
  }
  if ((diag_kind_is_exact(kind, ((uint8_t *)"\x68\x69\x6e\x74")) !=0)) {
    return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x32\x6d"));
  }
  return diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x37\x6d"));
  return ((uint8_t *)"");
}
void diag_report_human(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail) {
  {
    uint8_t * err = diag_stderr();
    uint8_t * actual_file = file;
    if ((actual_file ==0)) {
      (void)((actual_file = diag_ctx_get_file()));
    }
    uint8_t * kind_color = diag_palette_kind_color(kind);
    uint8_t * path_color = diag_color_prefix(((uint8_t *)""), ((uint8_t *)"\x1b\x5b\x33\x34\x6d"));
    uint8_t * caret_color = diag_palette_caret_color(kind);
    uint8_t * reset = diag_color_reset();
    uint8_t line_start_slot[8] = {};
    uint8_t line_len_slot[8] = {};
    int32_t have_line = 0;
    if ((line > 0)) {
      if ((diag_extract_line(line, &((line_start_slot)[0]), &((line_len_slot)[0])) ==0)) {
        (void)((have_line = 1));
      }
    }
    (void)(diag_print_header(kind, code, msg, kind_color, reset));
    if ((actual_file !=0)) {
      if ((line > 0)) {
        if ((col > 0)) {
          (void)(diag_io_fprint_loc_file_line_col(err, path_color, actual_file, line, col, reset));
        } else {
          (void)(diag_io_fprint_loc_file_line(err, path_color, actual_file, line, reset));
        }
      } else {
        (void)(diag_io_fprint_loc_file(err, path_color, actual_file, reset));
      }
    } else {
      if ((line > 0)) {
        if ((col > 0)) {
          (void)(diag_io_fprint_loc_line_col(err, path_color, line, col, reset));
        }
      }
    }
    if ((have_line ==0)) {
      (void)(diag_io_fflush(err));
      return;
    }
    if ((line <=0)) {
      (void)(diag_io_fflush(err));
      return;
    }
    if ((col <=0)) {
      (void)(diag_io_fflush(err));
      return;
    }
    uint8_t * line_start = diag_snap_load_ptr(&((line_start_slot)[0]), 0);
    size_t line_len_u = diag_snap_load_usize(&((line_len_slot)[0]), 0);
    int32_t line_len = ((int32_t)(line_len_u));
    int32_t width = diag_line_digits(line);
    (void)(diag_io_fprint_gutter_blank(err, width));
    (void)(diag_io_fprint_src_line(err, line, line_start, line_len));
    (void)(diag_io_fprint_gutter_bar(err, width));
    int32_t caret_col = 0;
    if ((col > 1)) {
      (void)((caret_col = (col - 1)));
    }
    int32_t i = 0;
    while ((i < caret_col)) {
      if ((i < line_len)) {
        if ((line_start !=0)) {
          if (((line_start)[i] ==9)) {
            (void)(diag_io_fputc(err, 9));
          } else {
            (void)(diag_io_fputc(err, 32));
          }
        } else {
          (void)(diag_io_fputc(err, 32));
        }
      } else {
        (void)(diag_io_fputc(err, 32));
      }
      (void)((i = (i + 1)));
    }
    (void)(diag_io_fprint_caret_mark(err, caret_color, reset, detail));
    (void)(diag_io_fflush(err));
  }
}
void diag_report(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * msg, uint8_t * detail) {
  (void)(diag_report_with_code(file, line, col, kind, 0, msg, detail));
}
void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail) {
  if ((diag_json_enabled() !=0)) {
    uint8_t * f = file;
    if ((f ==0)) {
      (void)((f = diag_ctx_get_file()));
    }
    (void)(diag_report_json(f, line, col, kind, code, msg));
    return;
  }
  (void)(diag_report_human(file, line, col, kind, code, msg, detail));
}
uint8_t * diag_get_file(void) {
  return diag_ctx_get_file();
  return ((uint8_t *)(0));
}
uint8_t * diag_get_source(void) {
  return diag_ctx_get_source();
  return ((uint8_t *)(0));
}
int64_t diag_get_source_len(void) {
  return diag_ctx_get_source_len();
  return 0;
}
void diag_set_file(uint8_t * path, uint8_t * source, int64_t source_len) {
  int32_t c = diag_should_color();
  (void)(diag_ctx_set_all(path, source, source_len, c));
}
void diag_snap_store_ptr(uint8_t * snap, int32_t off, uint8_t * val) {
  if ((snap ==0)) {
    return;
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  (void)(diag_store_ptr_le(q, val));
}
void diag_snap_store_usize(uint8_t * snap, int32_t off, size_t val) {
  if ((snap ==0)) {
    return;
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  (void)(diag_store_usize_le(q, val));
}
void diag_snap_store_i32(uint8_t * snap, int32_t off, int32_t val) {
  if ((snap ==0)) {
    return;
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  int32_t a = val;
  int32_t m = 256;
  if ((a < 0)) {
    (void)((a = 0));
  }
  (void)(((q)[0] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[1] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[2] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((q)[3] = ((uint8_t)((a % m)))));
}
uint8_t * diag_snap_load_ptr(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return ((uint8_t *)(0));
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((q)[0]));
  (void)((a = (a + (((size_t)((q)[1])) * m))));
  (void)((a = (a + (((size_t)((q)[2])) * m2))));
  (void)((a = (a + (((size_t)((q)[3])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((q)[4])) * m4))));
  (void)((a = (a + (((size_t)((q)[5])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((q)[6])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((q)[7])) * ((m4 * m2) * m)))));
  return ((uint8_t *)(a));
}
size_t diag_snap_load_usize(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return 0;
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  size_t m = 256;
  size_t m2 = (m * m);
  size_t m4 = (m2 * m2);
  size_t a = ((size_t)((q)[0]));
  (void)((a = (a + (((size_t)((q)[1])) * m))));
  (void)((a = (a + (((size_t)((q)[2])) * m2))));
  (void)((a = (a + (((size_t)((q)[3])) * (m2 * m)))));
  (void)((a = (a + (((size_t)((q)[4])) * m4))));
  (void)((a = (a + (((size_t)((q)[5])) * (m4 * m)))));
  (void)((a = (a + (((size_t)((q)[6])) * (m4 * m2)))));
  (void)((a = (a + (((size_t)((q)[7])) * ((m4 * m2) * m)))));
  return a;
}
int32_t diag_snap_load_i32(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return 0;
  }
  uint8_t * q = snap;
  int32_t i = 0;
  while ((i < off)) {
    (void)((q = (q + 1)));
    (void)((i = (i + 1)));
  }
  int32_t m = 256;
  int32_t a = ((int32_t)((q)[0]));
  (void)((a = (a + (((int32_t)((q)[1])) * m))));
  (void)((a = (a + ((((int32_t)((q)[2])) * m) * m))));
  (void)((a = (a + (((((int32_t)((q)[3])) * m) * m) * m))));
  return a;
}
void diag_push_file(uint8_t * snapshot, uint8_t * path, uint8_t * source, int64_t source_len) {
  {
    if ((snapshot !=0)) {
      (void)(diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file()));
      (void)(diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source()));
      int64_t sl0 = diag_ctx_get_source_len();
      (void)(diag_snap_store_usize(snapshot, 16, ((size_t)(sl0))));
      (void)(diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color()));
    }
    uint8_t * p = path;
    if ((p ==0)) {
      (void)((p = diag_ctx_get_file()));
    }
    uint8_t * s = source;
    int64_t sl = source_len;
    if ((s ==0)) {
      (void)((s = diag_ctx_get_source()));
      (void)((sl = diag_ctx_get_source_len()));
    }
    int32_t c = diag_should_color();
    (void)(diag_ctx_set_all(p, s, sl, c));
  }
}
void diag_restore(uint8_t * snapshot) {
  if ((snapshot ==0)) {
    return;
  }
  {
    uint8_t * p = diag_snap_load_ptr(snapshot, 0);
    uint8_t * s = diag_snap_load_ptr(snapshot, 8);
    size_t sl = diag_snap_load_usize(snapshot, 16);
    int32_t c = diag_snap_load_i32(snapshot, 24);
    (void)(diag_ctx_set_all(p, s, ((int64_t)(sl)), c));
  }
}
int32_t diag_code_is_known(uint8_t * code) {
  return diag_code_table_has(code);
  return 0;
}
uint8_t * diag_code_kind(uint8_t * code) {
  return diag_entry_kind(code);
  return ((uint8_t *)(0));
}
uint8_t * diag_code_summary(uint8_t * code) {
  return diag_entry_summary(code);
  return ((uint8_t *)(0));
}
uint8_t * diag_code_details(uint8_t * code) {
  return diag_entry_details(code);
  return ((uint8_t *)(0));
}
void diag_print_known_codes(uint8_t * out) {
  {
    uint8_t * o = out;
    if ((o ==0)) {
      (void)((o = diag_stdout()));
    }
    int64_t n = diag_code_table_len();
    int64_t i = 0;
    while ((i < n)) {
      uint8_t * c = diag_code_table_code_at(i);
      if ((i !=0)) {
        (void)(diag_io_fputs(((uint8_t *)"\x2c\x20"), o));
      }
      if ((c !=0)) {
        (void)(diag_io_fputs(c, o));
      }
      (void)((i = (i + 1)));
    }
    (void)(diag_io_fputc(o, 10));
  }
}
void diag_print_code_explain(uint8_t * out, uint8_t * code) {
  {
    uint8_t * o = out;
    if ((o ==0)) {
      (void)((o = diag_stdout()));
    }
    uint8_t * ec = diag_entry_code(code);
    if ((ec ==0)) {
      (void)(diag_io_fprint_unknown_code(o, code));
      (void)(diag_io_fputs(((uint8_t *)"\x4b\x6e\x6f\x77\x6e\x20\x63\x6f\x64\x65\x73\x3a\x20"), o));
      (void)(diag_print_known_codes(o));
      return;
    }
    (void)(diag_io_fputs(ec, o));
    (void)(diag_io_fputc(o, 10));
    (void)(diag_io_fputs(((uint8_t *)"\x4b\x69\x6e\x64\x3a\x20"), o));
    uint8_t * k = diag_entry_kind(code);
    if ((k !=0)) {
      (void)(diag_io_fputs(k, o));
    }
    (void)(diag_io_fputc(o, 10));
    (void)(diag_io_fputs(((uint8_t *)"\x53\x75\x6d\x6d\x61\x72\x79\x3a\x20"), o));
    uint8_t * s = diag_entry_summary(code);
    if ((s !=0)) {
      (void)(diag_io_fputs(s, o));
    }
    (void)(diag_io_fputc(o, 10));
    (void)(diag_io_fputs(((uint8_t *)"\x44\x65\x74\x61\x69\x6c\x73\x3a\x20"), o));
    uint8_t * d = diag_entry_details(code);
    if ((d !=0)) {
      (void)(diag_io_fputs(d, o));
    }
    (void)(diag_io_fputc(o, 10));
  }
}
void diag_print_code_table(uint8_t * out) {
  {
    uint8_t * o = out;
    if ((o ==0)) {
      (void)((o = diag_stdout()));
    }
    (void)(diag_io_fprint_code_table_hdr(o));
    int64_t n = diag_code_table_len();
    int64_t i = 0;
    while ((i < n)) {
      uint8_t * c = diag_code_table_code_at(i);
      uint8_t * k = diag_code_table_kind_at(i);
      uint8_t * s = diag_code_table_summary_at(i);
      (void)(diag_io_fprint_code_table_row(o, c, k, s));
      (void)((i = (i + 1)));
    }
  }
}
void diag_set_json_mode(int32_t enable) {
  if ((enable !=0)) {
    (void)(diag_json_set_state(1));
  } else {
    (void)(diag_json_set_state(0));
  }
}
int32_t diag_json_enabled(void) {
  {
    int32_t s = diag_json_get_state();
    if ((s ==-2)) {
      uint8_t k[16] = {};
      (void)(((k)[0] = 83));
      (void)(((k)[1] = 72));
      (void)(((k)[2] = 85));
      (void)(((k)[3] = 88));
      (void)(((k)[4] = 95));
      (void)(((k)[5] = 68));
      (void)(((k)[6] = 73));
      (void)(((k)[7] = 65));
      (void)(((k)[8] = 71));
      (void)(((k)[9] = 95));
      (void)(((k)[10] = 74));
      (void)(((k)[11] = 83));
      (void)(((k)[12] = 79));
      (void)(((k)[13] = 78));
      (void)(((k)[14] = 0));
      uint8_t * e = link_abi_getenv(&((k)[0]));
      int32_t v = 0;
      if ((e !=0)) {
        if (((e)[0] !=0)) {
          if (((e)[0] !=48)) {
            (void)((v = 1));
          }
        }
      }
      (void)(diag_json_set_state(v));
      (void)((s = v));
    }
    if ((s ==1)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t diag_should_color(void) {
  {
    uint8_t k[16] = {};
    (void)(((k)[0] = 83));
    (void)(((k)[1] = 72));
    (void)(((k)[2] = 85));
    (void)(((k)[3] = 88));
    (void)(((k)[4] = 95));
    (void)(((k)[5] = 78));
    (void)(((k)[6] = 79));
    (void)(((k)[7] = 95));
    (void)(((k)[8] = 67));
    (void)(((k)[9] = 79));
    (void)(((k)[10] = 76));
    (void)(((k)[11] = 79));
    (void)(((k)[12] = 82));
    (void)(((k)[13] = 0));
    if ((link_abi_getenv(&((k)[0])) !=0)) {
      return 0;
    }
    if ((isatty(2) !=0)) {
      return 1;
    }
  }
  return 0;
}
uint8_t * diag_color_prefix(uint8_t * plain, uint8_t * color) {
  if ((diag_ctx_get_use_color() !=0)) {
    return color;
  }
  return plain;
  return plain;
}
uint8_t * diag_color_reset(void) {
  if ((diag_ctx_get_use_color() !=0)) {
    return ((uint8_t *)"\x1b\x5b\x30\x6d");
  }
  return ((uint8_t *)"");
  return ((uint8_t *)"");
}
void diag_store_ptr_le(uint8_t * p, uint8_t * val) {
  if ((p ==0)) {
    return;
  }
  size_t a = ((size_t)(val));
  size_t m = 256;
  (void)(((p)[0] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[1] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[2] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[3] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[4] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[5] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[6] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[7] = ((uint8_t)((a % m)))));
}
void diag_store_usize_le(uint8_t * p, size_t val) {
  if ((p ==0)) {
    return;
  }
  size_t a = val;
  size_t m = 256;
  (void)(((p)[0] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[1] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[2] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[3] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[4] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[5] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[6] = ((uint8_t)((a % m)))));
  (void)((a = (a / m)));
  (void)(((p)[7] = ((uint8_t)((a % m)))));
}
void diag_print_header(uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * kind_color, uint8_t * reset) {
  {
    uint8_t * err = diag_stderr();
    uint8_t * m = msg;
    if ((m ==0)) {
      (void)((m = ((uint8_t *)"")));
    }
    uint8_t * k = kind;
    if ((k ==0)) {
      (void)((k = ((uint8_t *)"")));
    }
    uint8_t * kc = kind_color;
    if ((kc ==0)) {
      (void)((kc = ((uint8_t *)"")));
    }
    uint8_t * rs = reset;
    if ((rs ==0)) {
      (void)((rs = ((uint8_t *)"")));
    }
    if (((k)[0] ==0)) {
      (void)(diag_io_fputs(m, err));
      (void)(diag_io_fputc(err, 10));
      return;
    }
    (void)(diag_io_fputs(kc, err));
    (void)(diag_io_fputs(k, err));
    if ((code !=0)) {
      if (((code)[0] !=0)) {
        (void)(diag_io_fputc(err, 91));
        (void)(diag_io_fputs(code, err));
        (void)(diag_io_fputc(err, 93));
      }
    }
    (void)(diag_io_fputs(rs, err));
    (void)(diag_io_fputs(((uint8_t *)"\x3a\x20"), err));
    (void)(diag_io_fputs(m, err));
    (void)(diag_io_fputc(err, 10));
  }
}
int32_t diag_extract_line(int32_t line_no, uint8_t * line_start_out, uint8_t * line_len_out) {
  if ((line_no <=0)) {
    return -1;
  }
  if ((line_start_out ==0)) {
    return -1;
  }
  if ((line_len_out ==0)) {
    return -1;
  }
  {
    uint8_t * src = diag_ctx_get_source();
    int64_t len64 = diag_ctx_get_source_len();
    if ((src ==0)) {
      return -1;
    }
    if ((len64 <=0)) {
      return -1;
    }
    int32_t len = ((int32_t)(len64));
    if ((len64 > 2147483647)) {
      (void)((len = 2147483647));
    }
    int32_t line = 1;
    int32_t i = 0;
    int32_t start = 0;
    while ((i < len)) {
      if ((line ==line_no)) {
        break;
      }
      if (((src)[i] ==10)) {
        (void)((line = (line + 1)));
        (void)((start = (i + 1)));
      }
      (void)((i = (i + 1)));
    }
    if ((line !=line_no)) {
      return -1;
    }
    while ((i < len)) {
      uint8_t c = (src)[i];
      if ((c ==10)) {
        break;
      }
      if ((c ==13)) {
        break;
      }
      (void)((i = (i + 1)));
    }
    uint8_t * p = src;
    int32_t k = 0;
    while ((k < start)) {
      (void)((p = (p + 1)));
      (void)((k = (k + 1)));
    }
    (void)(diag_store_ptr_le(line_start_out, p));
    size_t ln = ((size_t)((i - start)));
    (void)(diag_store_usize_le(line_len_out, ln));
    return 0;
  }
  return -1;
}
void diag_json_write_str(uint8_t * out, uint8_t * s) {
  {
    uint8_t * p = s;
    if ((p ==0)) {
      (void)((p = ((uint8_t *)"")));
    }
    (void)(diag_io_fputc(out, 34));
    int32_t i = 0;
    while ((i < 1048576)) {
      uint8_t c = (p)[i];
      if ((c ==0)) {
        break;
      }
      if ((c ==34)) {
        (void)(diag_io_fputs(((uint8_t *)"\x5c\x22"), out));
      } else {
        if ((c ==92)) {
          (void)(diag_io_fputs(((uint8_t *)"\x5c\x5c"), out));
        } else {
          if ((c ==8)) {
            (void)(diag_io_fputs(((uint8_t *)"\x5c\x62"), out));
          } else {
            if ((c ==12)) {
              (void)(diag_io_fputs(((uint8_t *)"\x5c\x66"), out));
            } else {
              if ((c ==10)) {
                (void)(diag_io_fputs(((uint8_t *)"\x5c\x6e"), out));
              } else {
                if ((c ==13)) {
                  (void)(diag_io_fputs(((uint8_t *)"\x5c\x72"), out));
                } else {
                  if ((c ==9)) {
                    (void)(diag_io_fputs(((uint8_t *)"\x5c\x74"), out));
                  } else {
                    if ((c < 32)) {
                      (void)(diag_io_fputs_u04x(out, ((int32_t)(c))));
                    } else {
                      (void)(diag_io_fputc(out, ((int32_t)(c))));
                    }
                  }
                }
              }
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
    (void)(diag_io_fputc(out, 34));
  }
}
void diag_report_json(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg) {
  {
    uint8_t * err = diag_stderr();
    uint8_t * sev = diag_json_severity(kind);
    (void)(diag_io_fputs(((uint8_t *)"\x7b\x22\x73\x65\x76\x65\x72\x69\x74\x79\x22\x3a"), err));
    (void)(diag_json_write_str(err, sev));
    (void)(diag_io_fputs(((uint8_t *)"\x2c\x22\x63\x6f\x64\x65\x22\x3a"), err));
    if ((code !=0)) {
      if (((code)[0] !=0)) {
        (void)(diag_json_write_str(err, code));
      } else {
        (void)(diag_io_fputs(((uint8_t *)"\x6e\x75\x6c\x6c"), err));
      }
    } else {
      (void)(diag_io_fputs(((uint8_t *)"\x6e\x75\x6c\x6c"), err));
    }
    (void)(diag_io_fputs(((uint8_t *)"\x2c\x22\x66\x69\x6c\x65\x22\x3a"), err));
    if ((file !=0)) {
      if (((file)[0] !=0)) {
        (void)(diag_json_write_str(err, file));
      } else {
        (void)(diag_io_fputs(((uint8_t *)"\x6e\x75\x6c\x6c"), err));
      }
    } else {
      (void)(diag_io_fputs(((uint8_t *)"\x6e\x75\x6c\x6c"), err));
    }
    (void)(diag_io_fprint_line_col(err, line, col));
    uint8_t * m = msg;
    if ((m ==0)) {
      (void)((m = ((uint8_t *)"")));
    }
    (void)(diag_json_write_str(err, m));
    (void)(diag_io_fputs(((uint8_t *)"\x7d\x0a"), err));
    (void)(diag_io_fflush(err));
  }
}
uint8_t * diag_code_suggest(uint8_t * code, uint8_t * out, int64_t out_cap) {
  if ((code ==0)) {
    return ((uint8_t *)(0));
  }
  {
    int64_t n = diag_code_table_len();
    if ((n <=0)) {
      return ((uint8_t *)(0));
    }
    int32_t code_len = 0;
    while ((code_len < 256)) {
      if (((code)[code_len] ==0)) {
        break;
      }
      (void)((code_len = (code_len + 1)));
    }
    if ((code_len <=0)) {
      return ((uint8_t *)(0));
    }
    int32_t best_dist = 999;
    uint8_t * best = 0;
    int64_t i = 0;
    while ((i < n)) {
      uint8_t * cand = diag_code_table_code_at(i);
      if ((cand !=0)) {
        int32_t d = diag_levenshtein_ci(code, cand);
        if ((d < best_dist)) {
          (void)((best_dist = d));
          (void)((best = cand));
        }
      }
      (void)((i = (i + 1)));
    }
    if ((best ==0)) {
      return ((uint8_t *)(0));
    }
    if ((best_dist > 3)) {
      return ((uint8_t *)(0));
    }
    if ((best_dist > (code_len + 1))) {
      return ((uint8_t *)(0));
    }
    if ((out !=0)) {
      if ((out_cap > 0)) {
        int64_t lim = (out_cap - 1);
        int64_t j = 0;
        while ((j < lim)) {
          uint8_t ch = (best)[((int32_t)(j))];
          if ((ch ==0)) {
            break;
          }
          (void)(((out)[((int32_t)(j))] = ch));
          (void)((j = (j + 1)));
        }
        (void)(((out)[((int32_t)(j))] = 0));
        return out;
      }
    }
    return best;
  }
  return ((uint8_t *)(0));
}
int32_t diag_levenshtein_ci(uint8_t * a, uint8_t * b) {
  if ((a ==0)) {
    return 999;
  }
  if ((b ==0)) {
    return 999;
  }
  int32_t la = 0;
  while ((la < 64)) {
    if (((a)[la] ==0)) {
      break;
    }
    (void)((la = (la + 1)));
  }
  int32_t lb = 0;
  while ((lb < 64)) {
    if (((b)[lb] ==0)) {
      break;
    }
    (void)((lb = (lb + 1)));
  }
  if ((la >=64)) {
    return 999;
  }
  if ((lb >=64)) {
    return 999;
  }
  if ((la ==0)) {
    return lb;
  }
  if ((lb ==0)) {
    return la;
  }
  int32_t prev[64] = {};
  int32_t cur[64] = {};
  int32_t j = 0;
  while ((j <=lb)) {
    (void)(((prev)[j] = j));
    (void)((j = (j + 1)));
  }
  int32_t i = 1;
  while ((i <=la)) {
    (void)(((cur)[0] = i));
    (void)((j = 1));
    while ((j <=lb)) {
      uint8_t ca = (a)[(i - 1)];
      uint8_t cb = (b)[(j - 1)];
      if ((ca >=97)) {
        if ((ca <=122)) {
          (void)((ca = (ca - 32)));
        }
      }
      if ((cb >=97)) {
        if ((cb <=122)) {
          (void)((cb = (cb - 32)));
        }
      }
      int32_t cost = 1;
      if ((ca ==cb)) {
        (void)((cost = 0));
      }
      int32_t del = ((prev)[j] + 1);
      int32_t ins = ((cur)[(j - 1)] + 1);
      int32_t sub = ((prev)[(j - 1)] + cost);
      int32_t m = del;
      if ((ins < m)) {
        (void)((m = ins));
      }
      if ((sub < m)) {
        (void)((m = sub));
      }
      (void)(((cur)[j] = m));
      (void)((j = (j + 1)));
    }
    (void)((j = 0));
    while ((j <=lb)) {
      (void)(((prev)[j] = (cur)[j]));
      (void)((j = (j + 1)));
    }
    (void)((i = (i + 1)));
  }
  return (prev)[lb];
}
int32_t diag_kind_contains(uint8_t * kind, uint8_t * needle) {
  if ((kind ==0)) {
    return 0;
  }
  if ((needle ==0)) {
    return 0;
  }
  if (((needle)[0] ==0)) {
    return 0;
  }
  int32_t nlen = 0;
  while ((nlen < 4096)) {
    if (((needle)[nlen] ==0)) {
      break;
    }
    (void)((nlen = (nlen + 1)));
  }
  if ((nlen <=0)) {
    return 0;
  }
  int32_t klen = 0;
  while ((klen < 4096)) {
    if (((kind)[klen] ==0)) {
      break;
    }
    (void)((klen = (klen + 1)));
  }
  if ((klen < nlen)) {
    return 0;
  }
  int32_t s = 0;
  while (((s + nlen) <=klen)) {
    int32_t j = 0;
    int32_t ok = 1;
    while ((j < nlen)) {
      if (((kind)[(s + j)] !=(needle)[j])) {
        (void)((ok = 0));
        break;
      }
      (void)((j = (j + 1)));
    }
    if ((ok !=0)) {
      return 1;
    }
    (void)((s = (s + 1)));
  }
  return 0;
}
int32_t diag_line_digits(int32_t line) {
  int32_t width = 1;
  while ((line >=10)) {
    (void)((line = (line / 10)));
    (void)((width = (width + 1)));
  }
  return width;
}
int32_t diag_kind_is_exact(uint8_t * kind, uint8_t * needle) {
  if ((kind ==0)) {
    return 0;
  }
  if ((needle ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t a = (kind)[i];
    uint8_t b = (needle)[i];
    if ((a !=b)) {
      return 0;
    }
    if ((a ==0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t diag_code_eq(uint8_t * lhs, uint8_t * rhs) {
  if ((lhs ==0)) {
    return 0;
  }
  if ((rhs ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t a = (lhs)[i];
    uint8_t b = (rhs)[i];
    if ((a >=97)) {
      if ((a <=122)) {
        (void)((a = (a - 32)));
      }
    }
    if ((b >=97)) {
      if ((b <=122)) {
        (void)((b = (b - 32)));
      }
    }
    if ((a !=b)) {
      return 0;
    }
    if ((a ==0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * diag_json_severity(uint8_t * kind) {
  if ((kind ==0)) {
    return ((uint8_t *)"\x65\x72\x72\x6f\x72");
  }
  if (((kind)[0] ==0)) {
    return ((uint8_t *)"\x65\x72\x72\x6f\x72");
  }
  int32_t i = 0;
  while ((i < 256)) {
    if (((kind)[i] ==0)) {
      break;
    }
    if (((((((((kind)[i] ==119) && ((kind)[(i + 1)] ==97)) && ((kind)[(i + 2)] ==114)) && ((kind)[(i + 3)] ==110)) && ((kind)[(i + 4)] ==105)) && ((kind)[(i + 5)] ==110)) && ((kind)[(i + 6)] ==103))) {
      return ((uint8_t *)"\x77\x61\x72\x6e\x69\x6e\x67");
    }
    (void)((i = (i + 1)));
  }
  if (((((((kind)[0] ==105) && ((kind)[1] ==110)) && ((kind)[2] ==102)) && ((kind)[3] ==111)) && ((kind)[4] ==0))) {
    return ((uint8_t *)"\x69\x6e\x66\x6f");
  }
  if (((((((kind)[0] ==110) && ((kind)[1] ==111)) && ((kind)[2] ==116)) && ((kind)[3] ==101)) && ((kind)[4] ==0))) {
    return ((uint8_t *)"\x6e\x6f\x74\x65");
  }
  if (((((((kind)[0] ==104) && ((kind)[1] ==101)) && ((kind)[2] ==108)) && ((kind)[3] ==112)) && ((kind)[4] ==0))) {
    return ((uint8_t *)"\x68\x65\x6c\x70");
  }
  if (((((((kind)[0] ==104) && ((kind)[1] ==105)) && ((kind)[2] ==110)) && ((kind)[3] ==116)) && ((kind)[4] ==0))) {
    return ((uint8_t *)"\x68\x65\x6c\x70");
  }
  return ((uint8_t *)"\x65\x72\x72\x6f\x72");
}
