/* Host-gcc twin of lexer_cfg_parse_triple_literals (cfg_eval.x
 * cfg_parse_triple_literals / seeds cfg_eval_gen).
 * typool first-wins T 0x140378f70 (fromsrc_s80) compiles
 * `let lit_linux: u8[6] = [108,105,110,117,120,0]` (and sibling local
 * lit arrays) as qword stores through a bogus base:
 *   lea rax,[rbp+0x1eba5420]; mov QWORD PTR [rbx+stride],imm
 * with stride 0xe4 between bytes. Writer RIP typool 0x140378fbd
 * (store of 0x6c / 'l'). GDB: entered from typool
 * cfg_apply_compile_target_from_triple + 123 (caller return RIP
 * 0x14037b68b); computed dest 0x2efa2dc0 is unmapped → SIGSEGV.
 * The face itself is the typool-wrong (local u8[N] lit init), not a
 * smashed caller argument. Host-gcc twin keeps the lits on the stack
 * and indexes u8 directly. docs-only .x, do not idx8. Do not JMP
 * typool rec T 0x140087de4. Do not fold typool diag_io_fputc /
 * runtime_read_file_malloc / pp_path / ensure_default_lib /
 * runtime_release_file_view_impl in this thin. */
#include <stdint.h>

extern void lexer_cfg_copy_cstr(uint8_t *dest, int32_t dest_sz, uint8_t *src);
extern int32_t lexer_cfg_triple_contains_ci(uint8_t *buf, int32_t b, int32_t e, uint8_t *needle);
extern int32_t lexer_cfg_triple_has(uint8_t *triple, int32_t tlen, uint8_t *a, uint8_t *b);
extern uint8_t *cfg_host_os_lit(void);
extern uint8_t *cfg_host_arch_lit(void);

void lexer_cfg_parse_triple_literals(uint8_t *triple, int32_t tlen, uint8_t *os_out, int32_t os_sz, uint8_t *arch_out, int32_t arch_sz) {
  uint8_t lit_linux[6];
  uint8_t lit_macos[6];
  uint8_t lit_darwin[7];
  uint8_t lit_windows[8];
  uint8_t lit_freebsd[8];
  uint8_t lit_win32[6];
  uint8_t lit_aarch64[8];
  uint8_t lit_arm64[6];
  uint8_t lit_x86_64[7];
  uint8_t lit_amd64[6];
  uint8_t lit_riscv64[8];

  lit_linux[0] = 108; lit_linux[1] = 105; lit_linux[2] = 110;
  lit_linux[3] = 117; lit_linux[4] = 120; lit_linux[5] = 0;
  lit_macos[0] = 109; lit_macos[1] = 97; lit_macos[2] = 99;
  lit_macos[3] = 111; lit_macos[4] = 115; lit_macos[5] = 0;
  lit_darwin[0] = 100; lit_darwin[1] = 97; lit_darwin[2] = 114;
  lit_darwin[3] = 119; lit_darwin[4] = 105; lit_darwin[5] = 110;
  lit_darwin[6] = 0;
  lit_windows[0] = 119; lit_windows[1] = 105; lit_windows[2] = 110;
  lit_windows[3] = 100; lit_windows[4] = 111; lit_windows[5] = 119;
  lit_windows[6] = 115; lit_windows[7] = 0;
  lit_freebsd[0] = 102; lit_freebsd[1] = 114; lit_freebsd[2] = 101;
  lit_freebsd[3] = 101; lit_freebsd[4] = 98; lit_freebsd[5] = 115;
  lit_freebsd[6] = 100; lit_freebsd[7] = 0;
  lit_win32[0] = 119; lit_win32[1] = 105; lit_win32[2] = 110;
  lit_win32[3] = 51; lit_win32[4] = 50; lit_win32[5] = 0;
  lit_aarch64[0] = 97; lit_aarch64[1] = 97; lit_aarch64[2] = 114;
  lit_aarch64[3] = 99; lit_aarch64[4] = 104; lit_aarch64[5] = 54;
  lit_aarch64[6] = 52; lit_aarch64[7] = 0;
  lit_arm64[0] = 97; lit_arm64[1] = 114; lit_arm64[2] = 109;
  lit_arm64[3] = 54; lit_arm64[4] = 52; lit_arm64[5] = 0;
  lit_x86_64[0] = 120; lit_x86_64[1] = 56; lit_x86_64[2] = 54;
  lit_x86_64[3] = 95; lit_x86_64[4] = 54; lit_x86_64[5] = 52;
  lit_x86_64[6] = 0;
  lit_amd64[0] = 97; lit_amd64[1] = 109; lit_amd64[2] = 100;
  lit_amd64[3] = 54; lit_amd64[4] = 52; lit_amd64[5] = 0;
  lit_riscv64[0] = 114; lit_riscv64[1] = 105; lit_riscv64[2] = 115;
  lit_riscv64[3] = 99; lit_riscv64[4] = 118; lit_riscv64[5] = 54;
  lit_riscv64[6] = 52; lit_riscv64[7] = 0;

  if (os_out == 0)
    return;
  if (os_sz <= 0)
    return;
  if (arch_out == 0)
    return;
  if (arch_sz <= 0)
    return;
  lexer_cfg_copy_cstr(os_out, os_sz, cfg_host_os_lit());
  lexer_cfg_copy_cstr(arch_out, arch_sz, cfg_host_arch_lit());
  if (triple == 0)
    return;
  if (tlen <= 0)
    return;
  if (lexer_cfg_triple_contains_ci(triple, 0, tlen, &lit_linux[0]) != 0) {
    lexer_cfg_copy_cstr(os_out, os_sz, &lit_linux[0]);
  } else if (lexer_cfg_triple_has(triple, tlen, &lit_darwin[0], &lit_macos[0]) != 0) {
    lexer_cfg_copy_cstr(os_out, os_sz, &lit_macos[0]);
  } else if (lexer_cfg_triple_contains_ci(triple, 0, tlen, &lit_freebsd[0]) != 0) {
    lexer_cfg_copy_cstr(os_out, os_sz, &lit_freebsd[0]);
  } else if (lexer_cfg_triple_has(triple, tlen, &lit_windows[0], &lit_win32[0]) != 0) {
    lexer_cfg_copy_cstr(os_out, os_sz, &lit_windows[0]);
  }
  if (lexer_cfg_triple_has(triple, tlen, &lit_aarch64[0], &lit_arm64[0]) != 0) {
    lexer_cfg_copy_cstr(arch_out, arch_sz, &lit_aarch64[0]);
  } else if (lexer_cfg_triple_has(triple, tlen, &lit_x86_64[0], &lit_amd64[0]) != 0) {
    lexer_cfg_copy_cstr(arch_out, arch_sz, &lit_x86_64[0]);
  } else if (lexer_cfg_triple_contains_ci(triple, 0, tlen, &lit_riscv64[0]) != 0) {
    lexer_cfg_copy_cstr(arch_out, arch_sz, &lit_riscv64[0]);
  }
}
