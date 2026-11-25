/* Host-gcc twin of fmt_file_list_n / n_set / at / store
 * (fmt_check_cmd_thin.x). typool first-wins W fmt_file_list_store
 * 0x140249c40 (fromsrc_s75) compiles slot[k] = c as scale-8 qword
 * stores through &slot:
 *   lea rax,[rbp-0x30]; lea rax,[rax+rbx*8]; mov QWORD PTR [rbx],rax
 * Writer RIP typool 0x140249d3c. GDB: entered with the real abs
 * .../examples/hello.x; at i=5 stored 0x140251db2 over saved rbx,
 * at i=6 stored the path pointer over saved rbp, at i=7 stored
 * 0x105f6ec0 over the return address. Epilogue then returned to
 * that unmapped RIP (first-chance 0x105f6ec0 / 0x10456ec0 /
 * 0x104d6ec0 across runs). Same-class typool scale-8 through
 * &abs_path for abs_path[k] at 0x140249d17, and typool 32-bit
 * add eax,ebx for `base + (n * 512)` at 0x140249ce8 (typool BSS
 * 0x149c6ee80 truncated). typool fmt_file_list_at W 0x140249b9c
 * has the same 32-bit add at 0x140249c28 (`return base + (i * 512)`);
 * check later iterates via at, so it is live once store stands.
 * typool n / n_set / typool BSS are Lxml_* mangled; this twin owns
 * g_fmt_file_list_paths[4194304] (8192 x 512) and g_fmt_file_list_n[1]
 * and first-wins the four accessors together so they share one BSS.
 * Host-gcc twin uses a 64-bit pointer add and indexes *u8 directly.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

uint8_t g_fmt_file_list_paths[4194304];
int32_t g_fmt_file_list_n[1];

int32_t fmt_file_list_n(void) {
  return g_fmt_file_list_n[0];
}

void fmt_file_list_n_set(int32_t v) {
  if (v < 0)
    g_fmt_file_list_n[0] = 0;
  else
    g_fmt_file_list_n[0] = v;
}

uint8_t *fmt_file_list_at(int32_t i) {
  uint8_t *base;

  if (i < 0)
    return 0;
  if (i >= g_fmt_file_list_n[0])
    return 0;
  base = &g_fmt_file_list_paths[0];
  return base + (i * 512);
}

int32_t fmt_file_list_store(uint8_t *abs_path) {
  int32_t n;
  int32_t k;
  uint8_t *base;
  uint8_t *slot;
  uint8_t c;

  if (abs_path == 0)
    return 0 - 1;
  n = g_fmt_file_list_n[0];
  if (n >= 8192)
    return 0 - 1;
  base = &g_fmt_file_list_paths[0];
  slot = base + (n * 512);
  k = 0;
  while (k < 511) {
    c = abs_path[k];
    slot[k] = c;
    if (c == 0) {
      fmt_file_list_n_set(n + 1);
      return 0;
    }
    k = k + 1;
  }
  slot[511] = 0;
  fmt_file_list_n_set(n + 1);
  return 0;
}
