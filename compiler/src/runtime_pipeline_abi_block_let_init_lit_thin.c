/* Host-gcc twin of glue_block_let_init_lit_c (simd_loop.x).
 * typool first-wins T 0x14026775c typool-wrong lea -0x40(%rbp) of
 * let vbuf: u8[256] = []; passed to host-cc pipeline_expr_var_name_into
 * memset(out, 0, 256) smashes the caller retaddr (Rip=0) during typool-
 * rebuild of runtime_asm_io_stubs.x (name buffer "iovcnt"). Do not idx8
 * the documentation .x twin. */
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
extern int32_t ast_ast_block_num_lets(uint8_t *arena, int32_t block_ref);
extern int32_t pipeline_block_let_name_len(uint8_t *arena, int32_t block_ref, int32_t li);
extern void pipeline_block_let_name_copy64(uint8_t *arena, int32_t block_ref, int32_t li,
                                           uint8_t *out);
extern int32_t pipeline_block_let_init_ref(uint8_t *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_expr_int_val_at(uint8_t *arena, int32_t expr_ref);

int32_t glue_block_let_init_lit_c(uint8_t *arena, int32_t block_ref, int32_t var_ref,
                                  int32_t *out_lit) {
  int32_t vlen, nlet, li, llen, k, matched, init_ref;
  uint8_t vbuf[256];
  uint8_t lb[256];

  if (out_lit == 0)
    return 0;
  if (var_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_ref);
  if (vlen <= 0)
    return 0;
  if (vlen > 127)
    return 0;
  memset(vbuf, 0, 256);
  pipeline_expr_var_name_into(arena, var_ref, &vbuf[0]);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  li = 0;
  while (li < nlet) {
    llen = pipeline_block_let_name_len(arena, block_ref, li);
    if (llen == vlen) {
      memset(lb, 0, 256);
      pipeline_block_let_name_copy64(arena, block_ref, li, &lb[0]);
      matched = 1;
      k = 0;
      while (k < vlen) {
        if (lb[k] != vbuf[k])
          matched = 0;
        k = k + 1;
      }
      if (matched != 0) {
        init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
        if (init_ref <= 0)
          return 0;
        if (pipeline_expr_kind_ord_at(arena, init_ref) != 0)
          return 0;
        out_lit[0] = pipeline_expr_int_val_at(arena, init_ref);
        return 1;
      }
    }
    li = li + 1;
  }
  return 0;
}
