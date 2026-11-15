/* Host-gcc twin of fmt_check_path_bss_slot and fmt_path_resolve_abs
 * (fmt_check_cmd_thin.x). typool first-wins W fmt_check_path_bss_slot
 * (fromsrc 0x140249c78, official 0x1402482c8) compiles
 * `return base + (which * 512)` as `add eax, ebx`, a 32-bit ptr+int
 * that truncates typool BSS 0x149c6a680+0x200 to dest 0x49c6a880.
 * Writer RIP typool 0x140249d00. First-chance: msvcrt!strcpy_s from
 * _getcwd from typool fmt_path_resolve_abs (call 0x1402492fd, return
 * RIP 0x140249302, rdx=0x200). Official has the same 32-bit add at
 * 0x140248350 and also RC=139 on `check examples/hello.x`. Already
 * named in widen_mixed_thin.x; codegen fix 880b49939 is on tip, but
 * fmt_check_cmd_driver.o / official product still emit the 32-bit add.
 * Same-class typool fmt_path_resolve_abs W 0x140249160 compiles
 * path[i]/buf[i] as scale-8 qword loads/stores through &ptr (e.g.
 * lea rax,[rbp-0x20]; lea rax,[rax+rbx*8]). Host-gcc twin uses a
 * 64-bit pointer add and indexes *u8 directly. typool BSS is the
 * mangled Lxml_* common; this twin owns g_fmt_check_path_bss[1024]
 * (2×512: slot 0 current_file, slot 1 resolve_abs). docs-only .x,
 * do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t xlang_path_is_absolute(uint8_t *path);
extern uint8_t *getcwd(uint8_t *buf, int32_t size);

uint8_t g_fmt_check_path_bss[1024];

uint8_t *fmt_check_path_bss_slot(int32_t which) {
  uint8_t *base = &g_fmt_check_path_bss[0];
  if (which < 0)
    return base;
  if (which > 1)
    return base;
  return base + ((int32_t)(which * 512));
}

uint8_t *fmt_path_resolve_abs(uint8_t *path) {
  uint8_t *buf;
  uint8_t *p;
  int32_t i, n, plen, j;
  uint8_t c, c2;

  if (path == 0)
    return 0;
  buf = fmt_check_path_bss_slot(1);
  if (buf == 0)
    return 0;
  if (xlang_path_is_absolute(path) != 0) {
    i = 0;
    while (i < 511) {
      c = path[i];
      buf[i] = c;
      if (c == 0)
        return buf;
      i = i + 1;
    }
    buf[511] = 0;
    return buf;
  }
  p = getcwd(buf, 512);
  if (p == 0)
    return 0;
  n = 0;
  while (n < 511) {
    if (buf[n] == 0)
      break;
    n = n + 1;
  }
  plen = 0;
  while (plen < 512) {
    if (path[plen] == 0)
      break;
    plen = plen + 1;
  }
  if (n + 1 + plen >= 512)
    return 0;
  buf[n] = 47;
  n = n + 1;
  j = 0;
  while (j <= plen) {
    c2 = path[j];
    buf[n + j] = c2;
    if (c2 == 0)
      break;
    j = j + 1;
  }
  return buf;
}
