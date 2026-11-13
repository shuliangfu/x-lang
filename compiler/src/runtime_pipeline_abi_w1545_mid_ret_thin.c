/*
 * Host-gcc twin of w1545_win_mid_ret_call only.
 *
 * Root (s42): typool backend_call_dispatch_w1545_win_mid_ret_call stores
 *   the post-call reload u8[8] at scale-8 (qword stride), then
 *   w1545_put(&b[0], 4) / put(..., 3) appends the packed view
 *   48 00 00 00 48 00 00 instead of 48 8B 50 08 / 48 8B 00.
 *   gdb of s41 while emitting option: mid_ret put#1/#2 twice (some_ptr_u8
 *   and map_ptr_u8); typool pend_rcx_emit append was not on that path.
 *
 * The pending sret slots live in typool BSS (Lxml_045d986c7ed6acf6 /
 *   Lxml_1282d7477ed6acf6 / Lxml_46cbe7807ed6acf6). typool pend_is,
 *   typool emit_call_args, typool pend_rcx_emit, and typool inlined
 *   rip-loads all use those addresses. A private folded BSS splits
 *   that state (s42 first fold: no sret lea, buf in rcx, run 139).
 *
 * PLATFORM: WINDOWS — PE fold first-wins; LINUX/MACOS use the .x thin.
 */
#include <stdint.h>

extern int32_t pipeline_asm_emit_call_sret_reg_shift_c(void);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t expr_ref);
extern int32_t w1545_win_mid_named_sz(uint8_t *arena, int32_t ty);
extern int32_t backend_call_dispatch_w1545_win_extern_slice_ret_sz(uint8_t *arena, int32_t expr_ref, int32_t ty);
extern int32_t call_dispatch_load_i32_le(uint8_t *p, int32_t off);
extern void call_dispatch_store_i32_le(uint8_t *p, int32_t off, int32_t v);
extern int32_t backend_call_dispatch_w1521_body(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t is_m);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *elf_ctx, uint8_t *b, int32_t n);

/*
 * typool w1545_pend_{expr,off,used} (Lxml_045d986c7ed6acf6 /
 * Lxml_1282d7477ed6acf6 / Lxml_46cbe7807ed6acf6). Mingw emits .refptr
 * for extern data, which pe_fold_append_last cannot resolve, so bind
 * the VAs proven on s40/s41 (nm + gdb) directly.
 */
#define W1545_PEND_EXPR (*(int32_t *)(uintptr_t)0x1404f0720ULL)
#define W1545_PEND_OFF  (*(int32_t *)(uintptr_t)0x1404f0724ULL)
#define W1545_PEND_USED (*(int32_t *)(uintptr_t)0x1404f0728ULL)

int32_t backend_call_dispatch_w1545_win_mid_ret_call(uint8_t *arena, uint8_t *elf_ctx, int32_t expr_ref, uint8_t *ctx, int32_t ta, int32_t is_m) {
  int32_t ty;
  int32_t sz;
  int32_t cur;
  int32_t off;
  int32_t p_e;
  int32_t p_o;
  int32_t p_u;
  int32_t rc;
  int32_t used;
  uint8_t b[8];
  if (ta != 0 || expr_ref <= 0) {
    return 0;
  }
  if (pipeline_asm_emit_call_sret_reg_shift_c() != 0) {
    return 0;
  }
  ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  sz = w1545_win_mid_named_sz(arena, ty);
  if (sz == 0) {
    sz = backend_call_dispatch_w1545_win_extern_slice_ret_sz(arena, expr_ref, ty);
  }
  if (sz == 0) {
    return 0;
  }
  cur = call_dispatch_load_i32_le(ctx, 4);
  if (cur < 8) {
    cur = 8;
  }
  off = cur + 16;
  call_dispatch_store_i32_le(ctx, 4, off);
  p_e = W1545_PEND_EXPR;
  p_o = W1545_PEND_OFF;
  p_u = W1545_PEND_USED;
  W1545_PEND_EXPR = expr_ref;
  W1545_PEND_OFF = off;
  W1545_PEND_USED = 0;
  rc = backend_call_dispatch_w1521_body(arena, elf_ctx, expr_ref, ctx, ta, is_m);
  used = W1545_PEND_USED;
  W1545_PEND_EXPR = p_e;
  W1545_PEND_OFF = p_o;
  W1545_PEND_USED = p_u;
  if (rc != 0) {
    return 0 - 1;
  }
  if (used != 0) {
    /* mov rdx, [rax+8]  (48 8B 50 08); mov rax, [rax]  (48 8B 00) */
    b[0] = 72;
    b[1] = 139;
    b[2] = 80;
    b[3] = 8;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4) != 0) {
      return 0 - 1;
    }
    b[0] = 72;
    b[1] = 139;
    b[2] = 0;
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 3) != 0) {
      return 0 - 1;
    }
  }
  return 1;
}
