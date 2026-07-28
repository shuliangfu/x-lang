/* seeds/runtime_backtrace_platform_surface.from_x.c
 * G-02f-21 runtime_backtrace_platform R2 thin+rest surface - isomorphic with src/asm/runtime_backtrace_platform.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_backtrace_platform.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (15 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 15 public API forwards to _impl extern C bridges;
 *   rest keeps OS-specific logic (execinfo/dladdr/DbgHelp/CaptureStackBackTrace)
 * Cap residual: 13 _impl - backtrace_u8_hex2/read_frame_addr/write_frame_addr/copy_sym_name/
 *   format_hex_addr/name_has_gold_anchor/capture/symbolicate/gold_anchor_addr/
 *   capture_and_check_gold_c/xplat_platform_name/xplat_quality + xlang_crash_evidence_collect_impl
 * Note: doc_anchor runtime_backtrace_platform_x_doc_anchor (no ast_; backtrace_/xlang_ prefix not trigger).
 * Logic: 15 functions = 14 backtrace_*_c forwards + name_has_gold_anchor (DIRECT forward to _impl).
 * Regen: ./xlang-c -E ... runtime_backtrace_platform.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void backtrace_u8_hex2_impl(uint8_t b, uint8_t *out);
extern uint8_t *backtrace_read_frame_addr_impl(uint8_t *buf, int32_t i);
extern void backtrace_write_frame_addr_impl(uint8_t *buf, int32_t i, uint8_t *addr);
extern void backtrace_copy_sym_name_impl(uint8_t *out, int32_t name_cap, uint8_t *name);
extern void backtrace_format_hex_addr_impl(uint8_t *out, int32_t cap, uint8_t *addr);
extern int32_t backtrace_name_has_gold_anchor_impl(uint8_t *name);
extern int32_t backtrace_capture_impl(uint8_t *buf, int32_t max_frames);
extern int32_t backtrace_symbolicate_impl(uint8_t *buf, int32_t len, uint8_t *out_ptrs,
                                          uint8_t *out_names, int32_t max);
extern uint8_t *backtrace_gold_anchor_addr_impl(void);
extern int32_t backtrace_capture_and_check_gold_c_impl(void);
extern uint8_t *backtrace_xplat_platform_name_impl(void);
extern int32_t backtrace_xplat_quality_impl(void);
extern void xlang_crash_evidence_collect_impl(int32_t has_msg, int32_t msg_val);

int32_t runtime_backtrace_platform_x_doc_anchor(void) {
  return 0;
}

void backtrace_u8_hex2(uint8_t b, uint8_t *out) {
  backtrace_u8_hex2_impl(b, out);
}

uint8_t *backtrace_read_frame_addr_c(uint8_t *buf, int32_t i) {
  return backtrace_read_frame_addr_impl(buf, i);
}

void backtrace_write_frame_addr_c(uint8_t *buf, int32_t i, uint8_t *addr) {
  backtrace_write_frame_addr_impl(buf, i, addr);
}

void backtrace_copy_sym_name_c(uint8_t *out, int32_t name_cap, uint8_t *name) {
  backtrace_copy_sym_name_impl(out, name_cap, name);
}

void backtrace_format_hex_addr_c(uint8_t *out, int32_t cap, uint8_t *addr) {
  backtrace_format_hex_addr_impl(out, cap, addr);
}

int32_t backtrace_name_has_gold_anchor_c(uint8_t *name) {
  return backtrace_name_has_gold_anchor_impl(name);
}

int32_t backtrace_capture_c(uint8_t *buf, int32_t max_frames) {
  return backtrace_capture_impl(buf, max_frames);
}

int32_t backtrace_symbolicate_c(uint8_t *buf, int32_t len, uint8_t *out_ptrs,
                                uint8_t *out_names, int32_t max) {
  return backtrace_symbolicate_impl(buf, len, out_ptrs, out_names, max);
}

uint8_t *backtrace_gold_anchor_addr_c(void) {
  return backtrace_gold_anchor_addr_impl();
}

int32_t backtrace_capture_and_check_gold_c(void) {
  return backtrace_capture_and_check_gold_c_impl();
}

uint8_t *backtrace_xplat_platform_name_c(void) {
  return backtrace_xplat_platform_name_impl();
}

int32_t backtrace_xplat_quality_c(void) {
  return backtrace_xplat_quality_impl();
}

void xlang_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val) {
  xlang_crash_evidence_collect_impl(has_msg, msg_val);
}

int32_t name_has_gold_anchor(uint8_t *name) {
  return backtrace_name_has_gold_anchor_impl(name);
}
