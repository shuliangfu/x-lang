/* Generated from backend_asm_strict_fallback_alias.x (G-02f-24 true .x).
 * Regen: ./shux-c -E -L .. backend_asm_strict_fallback_alias.x > seeds/backend_asm_strict_fallback_alias.from_x.c
 */
#include <stdint.h>
#include <stddef.h>
extern int32_t pipeline_backend_asm_codegen_ast_c(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx);
extern int32_t pipeline_backend_asm_codegen_ast_to_elf_c(uint8_t * module, uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx);
int32_t backend_asm_codegen_ast(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx) {
  (void)(({   {
    int32_t r = pipeline_backend_asm_codegen_ast_c(module, arena, out, ctx);
    return r;
  }
 }));
  return 0;
}
int32_t backend_asm_codegen_ast_to_elf(uint8_t * module, uint8_t * arena, uint8_t * elf_ctx, uint8_t * ctx) {
  (void)(({   {
    int32_t r = pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, ctx);
    return r;
  }
 }));
  return 0;
}
