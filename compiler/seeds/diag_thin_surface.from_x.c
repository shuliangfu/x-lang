/* seeds/diag_thin_surface.from_x.c
 * G-02f diag_thin R2 mixed surface - isomorphic with src/diag_thin.x
 * Product PREFER_X_O: xlang_asm -E(.x) -> thin.o + ld -r with rest (diag_thin rest C)
 * Prove: full.x vs this surface -> nm IDENTICAL (78 symbols)
 * Mode: mixed - 19 DIRECT compute + 59 thin+rest forwards to _impl
 * Cap residual: 53 _impl bridges (rest C provides function bodies; thin forwards via _impl)
 * doc_anchor: none (diag_thin.x has no doc_anchor marker; -E output contains no diag_thin_x_doc_anchor)
 * Logic: 78 functions = 19 DIRECT compute
 *   + 59 thin+rest forwards to _impl (diag_ctx_get_use_color_impl,
 *      diag_ctx_get_file_impl, diag_ctx_get_source_impl,
 *      diag_ctx_get_source_len_impl, diag_ctx_set_all_impl,
 *      diag_code_table_has_impl, diag_entry_kind_impl,
 *      diag_entry_summary_impl, diag_entry_details_impl,
 *      diag_push_file_apply_impl, diag_should_color_impl,
 *      diag_color_reset_impl, diag_set_json_mode_impl,
 *      diag_json_enabled_impl, diag_extract_line_impl,
 *      diag_print_header_impl, diag_print_code_table_impl,
 *      diag_print_known_codes_impl, diag_print_code_explain_impl,
 *      diag_report_with_code_impl, diag_report_human_impl,
 *      diag_code_eq_impl, diag_levenshtein_ci_impl,
 *      diag_json_write_str_impl, diag_report_json_impl,
 *      diag_json_severity_impl, diag_code_suggest_impl,
 *      diag_json_get_state_impl, diag_json_set_state_impl,
 *      diag_io_fputc_impl, diag_io_fputs_impl,
 *      diag_io_fputs_u04x_impl, diag_io_fflush_impl,
 *      diag_io_fprint_line_col_impl, diag_io_fprint_loc_file_line_col_impl,
 *      diag_io_fprint_loc_file_line_impl, diag_io_fprint_loc_file_impl,
 *      diag_io_fprint_loc_line_col_impl, diag_io_fprint_gutter_blank_impl,
 *      diag_io_fprint_src_line_impl, diag_io_fprint_gutter_bar_impl,
 *      diag_io_fprint_caret_mark_impl, diag_code_table_len_impl,
 *      diag_io_fprint_unknown_code_impl, diag_io_fprint_code_table_hdr_impl,
 *      diag_io_fprint_code_table_row_impl, diag_code_table_code_at_impl,
 *      diag_code_table_kind_at_impl, diag_code_table_summary_at_impl,
 *      diag_code_table_details_at_impl, diag_entry_code_impl,
 *      diag_stderr_impl, diag_stdout_impl).
 * Regen: xlang_asm -E src/diag_thin.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
/* Forward declarations for all 78 surface functions (nm IDENTICAL targets). */
extern int32_t diag_line_digits(int32_t line);
extern int32_t diag_thin_diag_cstr_len_bounded(uint8_t * s);
extern int32_t diag_thin_diag_bytes_match_at(uint8_t * hay, uint8_t * needle, int32_t off, int32_t nlen);
extern int32_t diag_kind_is_exact(uint8_t * kind, uint8_t * needle);
extern int32_t diag_kind_contains(uint8_t * kind, uint8_t * needle);
extern uint8_t * diag_color_prefix(uint8_t * plain, uint8_t * color);
extern uint8_t * diag_get_file(void);
extern uint8_t * diag_get_source(void);
extern int64_t diag_get_source_len(void);
extern int32_t diag_code_is_known(uint8_t * code);
extern uint8_t * diag_code_kind(uint8_t * code);
extern uint8_t * diag_code_summary(uint8_t * code);
extern uint8_t * diag_code_details(uint8_t * code);
extern void diag_set_file(uint8_t * path, uint8_t * source, int64_t source_len);
extern void diag_report(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * msg, uint8_t * detail);
extern void diag_store_ptr_le(uint8_t * p, uint8_t * val);
extern void diag_store_usize_le(uint8_t * p, size_t val);
extern void diag_snap_store_ptr(uint8_t * snap, int32_t off, uint8_t * val);
extern void diag_snap_store_usize(uint8_t * snap, int32_t off, size_t val);
extern void diag_snap_store_i32(uint8_t * snap, int32_t off, int32_t val);
extern uint8_t * diag_snap_load_ptr(uint8_t * snap, int32_t off);
extern size_t diag_snap_load_usize(uint8_t * snap, int32_t off);
extern int32_t diag_snap_load_i32(uint8_t * snap, int32_t off);
extern void diag_push_snap_save(uint8_t * snapshot);
extern void diag_push_file(uint8_t * snapshot, uint8_t * path, uint8_t * source, int64_t source_len);
extern void diag_restore(uint8_t * snapshot);
extern int32_t diag_should_color(void);
extern uint8_t * diag_color_reset(void);
extern void diag_set_json_mode(int32_t enable);
extern int32_t diag_json_enabled(void);
extern int32_t diag_extract_line(int32_t line_no, uint8_t * line_start_out, uint8_t * line_len_out);
extern void diag_print_header(uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * kind_color, uint8_t * reset);
extern void diag_print_code_table(uint8_t * out);
extern void diag_print_known_codes(uint8_t * out);
extern void diag_print_code_explain(uint8_t * out, uint8_t * code);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void diag_report_human(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern int32_t diag_code_eq(uint8_t * lhs, uint8_t * rhs);
extern int32_t diag_levenshtein_ci(uint8_t * a, uint8_t * b);
extern void diag_json_write_str(uint8_t * out, uint8_t * s);
extern void diag_report_json(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg);
extern uint8_t * diag_json_severity(uint8_t * kind);
extern uint8_t * diag_code_suggest(uint8_t * code, uint8_t * out, int64_t out_cap);
extern int32_t diag_ctx_get_use_color(void);
extern int32_t diag_code_table_has(uint8_t * code);
extern int32_t diag_json_get_state(void);
extern int32_t diag_json_set_state(int32_t v);
extern int32_t diag_io_fputc(uint8_t * o, int32_t c);
extern int32_t diag_io_fputs(uint8_t * s, uint8_t * o);
extern void diag_io_fputs_u04x(uint8_t * o, uint32_t c);
extern void diag_io_fflush(uint8_t * o);
extern void diag_io_fprint_line_col(uint8_t * o, int32_t line, int32_t col);
extern void diag_io_fprint_loc_file_line_col(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_loc_file_line(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, uint8_t * rs);
extern void diag_io_fprint_loc_file(uint8_t * o, uint8_t * pc, uint8_t * file, uint8_t * rs);
extern void diag_io_fprint_loc_line_col(uint8_t * o, uint8_t * pc, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_gutter_blank(uint8_t * o, int32_t width);
extern void diag_io_fprint_src_line(uint8_t * o, int32_t line, uint8_t * start, int32_t len);
extern void diag_io_fprint_gutter_bar(uint8_t * o, int32_t width);
extern void diag_io_fprint_caret_mark(uint8_t * o, uint8_t * cc, uint8_t * rs, uint8_t * detail);
extern int64_t diag_code_table_len(void);
extern void diag_io_fprint_unknown_code(uint8_t * out, uint8_t * code);
extern void diag_io_fprint_code_table_hdr(uint8_t * out);
extern void diag_io_fprint_code_table_row(uint8_t * out, uint8_t * code, uint8_t * kind, uint8_t * summary);
extern uint8_t * diag_ctx_get_file(void);
extern uint8_t * diag_ctx_get_source(void);
extern int64_t diag_ctx_get_source_len(void);
extern void diag_ctx_set_all(uint8_t * path, uint8_t * source, int64_t source_len, int32_t use_color);
extern uint8_t * diag_code_table_code_at(int64_t i);
extern uint8_t * diag_code_table_kind_at(int64_t i);
extern uint8_t * diag_code_table_summary_at(int64_t i);
extern uint8_t * diag_code_table_details_at(int64_t i);
extern uint8_t * diag_entry_code(uint8_t * code);
extern uint8_t * diag_entry_kind(uint8_t * code);
extern uint8_t * diag_entry_summary(uint8_t * code);
extern uint8_t * diag_entry_details(uint8_t * code);
extern uint8_t * diag_stderr(void);
extern uint8_t * diag_stdout(void);
/* Cap residual: 53 _impl bridges (thin+rest forwards target these; defined in rest C). */
extern int32_t diag_ctx_get_use_color_impl(void);
extern uint8_t * diag_ctx_get_file_impl(void);
extern uint8_t * diag_ctx_get_source_impl(void);
extern int64_t diag_ctx_get_source_len_impl(void);
extern void diag_ctx_set_all_impl(uint8_t * path, uint8_t * source, int64_t source_len, int32_t use_color);
extern int32_t diag_code_table_has_impl(uint8_t * code);
extern uint8_t * diag_entry_kind_impl(uint8_t * code);
extern uint8_t * diag_entry_summary_impl(uint8_t * code);
extern uint8_t * diag_entry_details_impl(uint8_t * code);
extern void diag_push_file_apply_impl(uint8_t * path, uint8_t * source, int64_t source_len);
extern int32_t diag_should_color_impl(void);
extern uint8_t * diag_color_reset_impl(void);
extern void diag_set_json_mode_impl(int32_t enable);
extern int32_t diag_json_enabled_impl(void);
extern int32_t diag_extract_line_impl(int32_t line_no, uint8_t * line_start_out, uint8_t * line_len_out);
extern void diag_print_header_impl(uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * kind_color, uint8_t * reset);
extern void diag_print_code_table_impl(uint8_t * out);
extern void diag_print_known_codes_impl(uint8_t * out);
extern void diag_print_code_explain_impl(uint8_t * out, uint8_t * code);
extern void diag_report_with_code_impl(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void diag_report_human_impl(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern int32_t diag_code_eq_impl(uint8_t * lhs, uint8_t * rhs);
extern int32_t diag_levenshtein_ci_impl(uint8_t * a, uint8_t * b);
extern void diag_json_write_str_impl(uint8_t * out, uint8_t * s);
extern void diag_report_json_impl(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg);
extern uint8_t * diag_json_severity_impl(uint8_t * kind);
extern uint8_t * diag_code_suggest_impl(uint8_t * code, uint8_t * out, int64_t out_cap);
extern int32_t diag_json_get_state_impl(void);
extern int32_t diag_json_set_state_impl(int32_t v);
extern int32_t diag_io_fputc_impl(uint8_t * o, int32_t c);
extern int32_t diag_io_fputs_impl(uint8_t * s, uint8_t * o);
extern void diag_io_fputs_u04x_impl(uint8_t * o, uint32_t c);
extern void diag_io_fflush_impl(uint8_t * o);
extern void diag_io_fprint_line_col_impl(uint8_t * o, int32_t line, int32_t col);
extern void diag_io_fprint_loc_file_line_col_impl(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_loc_file_line_impl(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, uint8_t * rs);
extern void diag_io_fprint_loc_file_impl(uint8_t * o, uint8_t * pc, uint8_t * file, uint8_t * rs);
extern void diag_io_fprint_loc_line_col_impl(uint8_t * o, uint8_t * pc, int32_t line, int32_t col, uint8_t * rs);
extern void diag_io_fprint_gutter_blank_impl(uint8_t * o, int32_t width);
extern void diag_io_fprint_src_line_impl(uint8_t * o, int32_t line, uint8_t * start, int32_t len);
extern void diag_io_fprint_gutter_bar_impl(uint8_t * o, int32_t width);
extern void diag_io_fprint_caret_mark_impl(uint8_t * o, uint8_t * cc, uint8_t * rs, uint8_t * detail);
extern int64_t diag_code_table_len_impl(void);
extern void diag_io_fprint_unknown_code_impl(uint8_t * out, uint8_t * code);
extern void diag_io_fprint_code_table_hdr_impl(uint8_t * out);
extern void diag_io_fprint_code_table_row_impl(uint8_t * out, uint8_t * code, uint8_t * kind, uint8_t * summary);
extern uint8_t * diag_code_table_code_at_impl(int64_t i);
extern uint8_t * diag_code_table_kind_at_impl(int64_t i);
extern uint8_t * diag_code_table_summary_at_impl(int64_t i);
extern uint8_t * diag_code_table_details_at_impl(int64_t i);
extern uint8_t * diag_entry_code_impl(uint8_t * code);
extern uint8_t * diag_stderr_impl(void);
extern uint8_t * diag_stdout_impl(void);
int32_t diag_line_digits(int32_t line) {
  int32_t width = 1;
  while ((line >=10)) {
    (void)((line = (line / 10)));
    (void)((width = (width + 1)));
  }
  return width;
}
int32_t diag_thin_diag_cstr_len_bounded(uint8_t * s) {
  if ((s ==0)) {
    return 0;
  }
  int32_t n = 0;
  while ((n < 4096)) {
    if (((s)[n] ==0)) {
      return n;
    }
    (void)((n = (n + 1)));
  }
  return 4096;
}
int32_t diag_thin_diag_bytes_match_at(uint8_t * hay, uint8_t * needle, int32_t off, int32_t nlen) {
  int32_t j = 0;
  while ((j < nlen)) {
    if (((hay)[(off + j)] !=(needle)[j])) {
      return 0;
    }
    (void)((j = (j + 1)));
  }
  return 1;
}
int32_t diag_kind_is_exact(uint8_t * kind, uint8_t * needle) {
  if ((kind ==0)) {
    return 0;
  }
  if ((needle ==0)) {
    return 0;
  }
  int32_t klen = diag_thin_diag_cstr_len_bounded(kind);
  int32_t nlen = diag_thin_diag_cstr_len_bounded(needle);
  if ((klen !=nlen)) {
    return 0;
  }
  return diag_thin_diag_bytes_match_at(kind, needle, 0, nlen);
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
  int32_t nlen = diag_thin_diag_cstr_len_bounded(needle);
  if ((nlen <=0)) {
    return 0;
  }
  int32_t klen = diag_thin_diag_cstr_len_bounded(kind);
  if ((klen < nlen)) {
    return 0;
  }
  int32_t s = 0;
  while (((s + nlen) <=klen)) {
    if ((diag_thin_diag_bytes_match_at(kind, needle, s, nlen) !=0)) {
      return 1;
    }
    (void)((s = (s + 1)));
  }
  return 0;
}
uint8_t * diag_color_prefix(uint8_t * plain, uint8_t * color) {
  if ((diag_ctx_get_use_color_impl() !=0)) {
    return color;
  }
  return plain;
  return plain;
}
uint8_t * diag_get_file(void) {
  return diag_ctx_get_file_impl();
}
uint8_t * diag_get_source(void) {
  return diag_ctx_get_source_impl();
}
int64_t diag_get_source_len(void) {
  return diag_ctx_get_source_len_impl();
}
int32_t diag_code_is_known(uint8_t * code) {
  return diag_code_table_has_impl(code);
}
uint8_t * diag_code_kind(uint8_t * code) {
  return diag_entry_kind_impl(code);
}
uint8_t * diag_code_summary(uint8_t * code) {
  return diag_entry_summary_impl(code);
}
uint8_t * diag_code_details(uint8_t * code) {
  return diag_entry_details_impl(code);
}
void diag_set_file(uint8_t * path, uint8_t * source, int64_t source_len) {
  {
    int32_t c = diag_should_color_impl();
    (void)(diag_ctx_set_all_impl(path, source, source_len, c));
  }
}
void diag_report(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * msg, uint8_t * detail) {
  {
    uint8_t * z = 0;
    (void)(diag_report_with_code_impl(file, line, col, kind, z, msg, detail));
  }
}
void diag_store_ptr_le(uint8_t * p, uint8_t * val) {
  if ((p ==0)) {
    return;
  }
  {
    size_t a = ((size_t)(val));
    size_t m = 256;
    size_t b0 = (a % m);
    size_t a1 = (a / m);
    size_t b1 = (a1 % m);
    size_t a2 = (a1 / m);
    size_t b2 = (a2 % m);
    size_t a3 = (a2 / m);
    size_t b3 = (a3 % m);
    size_t a4 = (a3 / m);
    size_t b4 = (a4 % m);
    size_t a5 = (a4 / m);
    size_t b5 = (a5 % m);
    size_t a6 = (a5 / m);
    size_t b6 = (a6 % m);
    size_t a7 = (a6 / m);
    size_t b7 = (a7 % m);
    (void)(((p)[0] = ((uint8_t)(b0))));
    (void)(((p)[1] = ((uint8_t)(b1))));
    (void)(((p)[2] = ((uint8_t)(b2))));
    (void)(((p)[3] = ((uint8_t)(b3))));
    (void)(((p)[4] = ((uint8_t)(b4))));
    (void)(((p)[5] = ((uint8_t)(b5))));
    (void)(((p)[6] = ((uint8_t)(b6))));
    (void)(((p)[7] = ((uint8_t)(b7))));
  }
}
void diag_store_usize_le(uint8_t * p, size_t val) {
  if ((p ==0)) {
    return;
  }
  {
    size_t a = val;
    size_t m = 256;
    size_t b0 = (a % m);
    size_t a1 = (a / m);
    size_t b1 = (a1 % m);
    size_t a2 = (a1 / m);
    size_t b2 = (a2 % m);
    size_t a3 = (a2 / m);
    size_t b3 = (a3 % m);
    size_t a4 = (a3 / m);
    size_t b4 = (a4 % m);
    size_t a5 = (a4 / m);
    size_t b5 = (a5 % m);
    size_t a6 = (a5 / m);
    size_t b6 = (a6 % m);
    size_t a7 = (a6 / m);
    size_t b7 = (a7 % m);
    (void)(((p)[0] = ((uint8_t)(b0))));
    (void)(((p)[1] = ((uint8_t)(b1))));
    (void)(((p)[2] = ((uint8_t)(b2))));
    (void)(((p)[3] = ((uint8_t)(b3))));
    (void)(((p)[4] = ((uint8_t)(b4))));
    (void)(((p)[5] = ((uint8_t)(b5))));
    (void)(((p)[6] = ((uint8_t)(b6))));
    (void)(((p)[7] = ((uint8_t)(b7))));
  }
}
void diag_snap_store_ptr(uint8_t * snap, int32_t off, uint8_t * val) {
  if ((snap ==0)) {
    return;
  }
  {
    uint8_t * q = (snap + off);
    (void)(diag_store_ptr_le(q, val));
  }
}
void diag_snap_store_usize(uint8_t * snap, int32_t off, size_t val) {
  if ((snap ==0)) {
    return;
  }
  {
    uint8_t * q = (snap + off);
    (void)(diag_store_usize_le(q, val));
  }
}
void diag_snap_store_i32(uint8_t * snap, int32_t off, int32_t val) {
  if ((snap ==0)) {
    return;
  }
  if ((val < 0)) {
    {
      uint8_t * q = (snap + off);
      (void)(((q)[0] = 0));
      (void)(((q)[1] = 0));
      (void)(((q)[2] = 0));
      (void)(((q)[3] = 0));
    }
    return;
  }
  {
    uint8_t * q = (snap + off);
    int32_t a = val;
    int32_t b0 = (a % 256);
    int32_t a1 = (a / 256);
    int32_t b1 = (a1 % 256);
    int32_t a2 = (a1 / 256);
    int32_t b2 = (a2 % 256);
    int32_t a3 = (a2 / 256);
    int32_t b3 = (a3 % 256);
    (void)(((q)[0] = ((uint8_t)(b0))));
    (void)(((q)[1] = ((uint8_t)(b1))));
    (void)(((q)[2] = ((uint8_t)(b2))));
    (void)(((q)[3] = ((uint8_t)(b3))));
  }
}
uint8_t * diag_snap_load_ptr(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return ((uint8_t *)(0));
  }
  {
    uint8_t * q = (snap + off);
    size_t m = 256;
    size_t m2 = (m * m);
    size_t m4 = (m2 * m2);
    size_t a0 = ((size_t)((q)[0]));
    size_t a1 = (a0 + (((size_t)((q)[1])) * m));
    size_t a2 = (a1 + (((size_t)((q)[2])) * m2));
    size_t a3 = (a2 + (((size_t)((q)[3])) * (m2 * m)));
    size_t a4 = (a3 + (((size_t)((q)[4])) * m4));
    size_t a5 = (a4 + (((size_t)((q)[5])) * (m4 * m)));
    size_t a6 = (a5 + (((size_t)((q)[6])) * (m4 * m2)));
    size_t a7 = (a6 + (((size_t)((q)[7])) * ((m4 * m2) * m)));
    return ((uint8_t *)(a7));
  }
  return ((uint8_t *)(0));
}
size_t diag_snap_load_usize(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return 0;
  }
  {
    uint8_t * q = (snap + off);
    size_t m = 256;
    size_t m2 = (m * m);
    size_t m4 = (m2 * m2);
    size_t a0 = ((size_t)((q)[0]));
    size_t a1 = (a0 + (((size_t)((q)[1])) * m));
    size_t a2 = (a1 + (((size_t)((q)[2])) * m2));
    size_t a3 = (a2 + (((size_t)((q)[3])) * (m2 * m)));
    size_t a4 = (a3 + (((size_t)((q)[4])) * m4));
    size_t a5 = (a4 + (((size_t)((q)[5])) * (m4 * m)));
    size_t a6 = (a5 + (((size_t)((q)[6])) * (m4 * m2)));
    size_t a7 = (a6 + (((size_t)((q)[7])) * ((m4 * m2) * m)));
    return a7;
  }
  return 0;
}
int32_t diag_snap_load_i32(uint8_t * snap, int32_t off) {
  if ((snap ==0)) {
    return 0;
  }
  {
    uint8_t * q = (snap + off);
    int32_t m = 256;
    int32_t a0 = ((int32_t)((q)[0]));
    int32_t a1 = (a0 + (((int32_t)((q)[1])) * m));
    int32_t a2 = (a1 + ((((int32_t)((q)[2])) * m) * m));
    int32_t a3 = (a2 + (((((int32_t)((q)[3])) * m) * m) * m));
    return a3;
  }
  return 0;
}
void diag_push_snap_save(uint8_t * snapshot) {
  if ((snapshot ==0)) {
    return;
  }
  (void)(diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file_impl()));
  (void)(diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source_impl()));
  (void)(diag_snap_store_usize(snapshot, 16, ((size_t)(diag_ctx_get_source_len_impl()))));
  (void)(diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color_impl()));
}
void diag_push_file(uint8_t * snapshot, uint8_t * path, uint8_t * source, int64_t source_len) {
  (void)(diag_push_snap_save(snapshot));
  (void)(diag_push_file_apply_impl(path, source, source_len));
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
    (void)(diag_ctx_set_all_impl(p, s, ((int64_t)(sl)), c));
  }
}
int32_t diag_should_color(void) {
  return diag_should_color_impl();
}
uint8_t * diag_color_reset(void) {
  return diag_color_reset_impl();
}
void diag_set_json_mode(int32_t enable) {
  (void)(diag_set_json_mode_impl(enable));
}
int32_t diag_json_enabled(void) {
  return diag_json_enabled_impl();
}
int32_t diag_extract_line(int32_t line_no, uint8_t * line_start_out, uint8_t * line_len_out) {
  return diag_extract_line_impl(line_no, line_start_out, line_len_out);
  return -1;
}
void diag_print_header(uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * kind_color, uint8_t * reset) {
  (void)(diag_print_header_impl(kind, code, msg, kind_color, reset));
}
void diag_print_code_table(uint8_t * out) {
  (void)(diag_print_code_table_impl(out));
}
void diag_print_known_codes(uint8_t * out) {
  (void)(diag_print_known_codes_impl(out));
}
void diag_print_code_explain(uint8_t * out, uint8_t * code) {
  (void)(diag_print_code_explain_impl(out, code));
}
void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail) {
  (void)(diag_report_with_code_impl(file, line, col, kind, code, msg, detail));
}
void diag_report_human(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail) {
  (void)(diag_report_human_impl(file, line, col, kind, code, msg, detail));
}
int32_t diag_code_eq(uint8_t * lhs, uint8_t * rhs) {
  return diag_code_eq_impl(lhs, rhs);
}
int32_t diag_levenshtein_ci(uint8_t * a, uint8_t * b) {
  return diag_levenshtein_ci_impl(a, b);
}
void diag_json_write_str(uint8_t * out, uint8_t * s) {
  (void)(diag_json_write_str_impl(out, s));
}
void diag_report_json(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg) {
  (void)(diag_report_json_impl(file, line, col, kind, code, msg));
}
uint8_t * diag_json_severity(uint8_t * kind) {
  return diag_json_severity_impl(kind);
}
uint8_t * diag_code_suggest(uint8_t * code, uint8_t * out, int64_t out_cap) {
  return diag_code_suggest_impl(code, out, out_cap);
}
int32_t diag_ctx_get_use_color(void) {
  return diag_ctx_get_use_color_impl();
}
int32_t diag_code_table_has(uint8_t * code) {
  return diag_code_table_has_impl(code);
}
int32_t diag_json_get_state(void) {
  return diag_json_get_state_impl();
  return -2;
}
int32_t diag_json_set_state(int32_t v) {
  return diag_json_set_state_impl(v);
}
int32_t diag_io_fputc(uint8_t * o, int32_t c) {
  return diag_io_fputc_impl(o, c);
}
int32_t diag_io_fputs(uint8_t * s, uint8_t * o) {
  return diag_io_fputs_impl(s, o);
}
void diag_io_fputs_u04x(uint8_t * o, uint32_t c) {
  (void)(diag_io_fputs_u04x_impl(o, c));
}
void diag_io_fflush(uint8_t * o) {
  (void)(diag_io_fflush_impl(o));
}
void diag_io_fprint_line_col(uint8_t * o, int32_t line, int32_t col) {
  (void)(diag_io_fprint_line_col_impl(o, line, col));
}
void diag_io_fprint_loc_file_line_col(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, int32_t col, uint8_t * rs) {
  (void)(diag_io_fprint_loc_file_line_col_impl(o, pc, file, line, col, rs));
}
void diag_io_fprint_loc_file_line(uint8_t * o, uint8_t * pc, uint8_t * file, int32_t line, uint8_t * rs) {
  (void)(diag_io_fprint_loc_file_line_impl(o, pc, file, line, rs));
}
void diag_io_fprint_loc_file(uint8_t * o, uint8_t * pc, uint8_t * file, uint8_t * rs) {
  (void)(diag_io_fprint_loc_file_impl(o, pc, file, rs));
}
void diag_io_fprint_loc_line_col(uint8_t * o, uint8_t * pc, int32_t line, int32_t col, uint8_t * rs) {
  (void)(diag_io_fprint_loc_line_col_impl(o, pc, line, col, rs));
}
void diag_io_fprint_gutter_blank(uint8_t * o, int32_t width) {
  (void)(diag_io_fprint_gutter_blank_impl(o, width));
}
void diag_io_fprint_src_line(uint8_t * o, int32_t line, uint8_t * start, int32_t len) {
  (void)(diag_io_fprint_src_line_impl(o, line, start, len));
}
void diag_io_fprint_gutter_bar(uint8_t * o, int32_t width) {
  (void)(diag_io_fprint_gutter_bar_impl(o, width));
}
void diag_io_fprint_caret_mark(uint8_t * o, uint8_t * cc, uint8_t * rs, uint8_t * detail) {
  (void)(diag_io_fprint_caret_mark_impl(o, cc, rs, detail));
}
int64_t diag_code_table_len(void) {
  return diag_code_table_len_impl();
}
void diag_io_fprint_unknown_code(uint8_t * out, uint8_t * code) {
  (void)(diag_io_fprint_unknown_code_impl(out, code));
}
void diag_io_fprint_code_table_hdr(uint8_t * out) {
  (void)(diag_io_fprint_code_table_hdr_impl(out));
}
void diag_io_fprint_code_table_row(uint8_t * out, uint8_t * code, uint8_t * kind, uint8_t * summary) {
  (void)(diag_io_fprint_code_table_row_impl(out, code, kind, summary));
}
uint8_t * diag_ctx_get_file(void) {
  return diag_ctx_get_file_impl();
}
uint8_t * diag_ctx_get_source(void) {
  return diag_ctx_get_source_impl();
}
int64_t diag_ctx_get_source_len(void) {
  return diag_ctx_get_source_len_impl();
}
void diag_ctx_set_all(uint8_t * path, uint8_t * source, int64_t source_len, int32_t use_color) {
  (void)(diag_ctx_set_all_impl(path, source, source_len, use_color));
}
uint8_t * diag_code_table_code_at(int64_t i) {
  return diag_code_table_code_at_impl(i);
}
uint8_t * diag_code_table_kind_at(int64_t i) {
  return diag_code_table_kind_at_impl(i);
}
uint8_t * diag_code_table_summary_at(int64_t i) {
  return diag_code_table_summary_at_impl(i);
}
uint8_t * diag_code_table_details_at(int64_t i) {
  return diag_code_table_details_at_impl(i);
}
uint8_t * diag_entry_code(uint8_t * code) {
  return diag_entry_code_impl(code);
}
uint8_t * diag_entry_kind(uint8_t * code) {
  return diag_entry_kind_impl(code);
}
uint8_t * diag_entry_summary(uint8_t * code) {
  return diag_entry_summary_impl(code);
}
uint8_t * diag_entry_details(uint8_t * code) {
  return diag_entry_details_impl(code);
}
uint8_t * diag_stderr(void) {
  return diag_stderr_impl();
}
uint8_t * diag_stdout(void) {
  return diag_stdout_impl();
}
