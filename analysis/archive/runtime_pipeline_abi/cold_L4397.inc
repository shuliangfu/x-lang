/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
int32_t xlang_asm_codegen_elf_o_product_emit(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
}
