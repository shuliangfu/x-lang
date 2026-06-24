/**
 * asm_text_stub.c — build_shux_asm CI 最小 .o 占位，保证 Mach-O __text / ELF .text / COFF .text 非空。
 * 用于 macOS/Windows CI 跳过 -backend asm emit（MSYS 上 token/typeck 等会挂起 45min+）。
 * weak：首遍 BUILD 多模块均 embed 此桩，strict 并列链时避免 multiple definition。
 */
__attribute__((weak)) void shux_asm_ci_text_stub(void) {}
