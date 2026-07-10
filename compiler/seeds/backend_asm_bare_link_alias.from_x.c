/* Generated from backend_asm_bare_link_alias.x (G-02f-25 true .x).
 * Regen: ./shux-c -E -L .. backend_asm_bare_link_alias.x > seeds/backend_asm_bare_link_alias.from_x.c
 */
#include <stdint.h>
#include <stddef.h>
extern int32_t asm_codegen_ast(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx);
extern int32_t asm_codegen_ast_to_elf(uint8_t * module, uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx);
extern int32_t emit_expr_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta);
extern int32_t emit_block_body_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, uint8_t * ctx, int32_t ta);
int32_t backend_asm_codegen_ast(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx) {
  (void)(({   {
    int32_t r = asm_codegen_ast(module, arena, out, ctx);
    return r;
  }
 }));
  return 0;
}
int32_t backend_asm_codegen_ast_to_elf(uint8_t * module, uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx) {
  (void)(({   {
    int32_t r = asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
    return r;
  }
 }));
  return 0;
}
int32_t backend_emit_expr_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t expr_ref, uint8_t * ctx, int32_t ta) {
  (void)(({   {
    int32_t r = emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
    return r;
  }
 }));
  return 0;
}
int32_t backend_emit_block_body_elf(uint8_t * arena, uint8_t * elf_ctx, int32_t block_ref, uint8_t * ctx, int32_t ta) {
  (void)(({   {
    int32_t r = emit_block_body_elf(arena, elf_ctx, block_ref, ctx, ta);
    return r;
  }
 }));
  return 0;
}
