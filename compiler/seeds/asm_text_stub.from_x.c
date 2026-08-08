/**
 * seeds/asm_text_stub.from_x.c — 8.3.7 CI __text placeholder (wave297 seed leave)
 * Authority (G.7): weak empty text so Mach-O __text / ELF .text / COFF .text is non-empty
 * when build_xlang_asm falls back after asm emit abort (macOS/Windows CI skips heavy emit).
 * Host leaf scripts/asm_text_stub.c deleted; build_xlang_asm emit_asm_text_stub_o seed-only.
 * PLATFORM: SHARED — weak so multi-module embed does not multiple-define on strict link.
 */
__attribute__((weak)) void xlang_asm_ci_text_stub(void) {}
