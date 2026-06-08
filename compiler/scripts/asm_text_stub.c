/**
 * asm_text_stub.c — build_shu_asm CI 最小 .o 占位，保证 Mach-O __text / ELF .text / COFF .text 非空。
 * 用于 macOS/Windows CI 跳过 -backend asm emit（MSYS 上 token/typeck 等会挂起 45min+）。
 */
void shu_asm_ci_text_stub(void) {}
