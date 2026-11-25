/* Host-gcc twin of driver_current_dep_path_store / _load
 * (runtime_driver_abi_thin.x). typool first-wins T
 * driver_current_dep_path_store @ 0x1400e8288 (fromsrc_s104)
 * compiles `let c: u8 = path[i]` as lea rax,[&path];
 * lea (%rax,%rbx,8) (scale-8 through the local pointer slot)
 * and `g_driver_current_dep_path_buf[i] = c` as scale-8 through
 * typool BSS Lxml_080a5907299a1682, then compiles
 * `if (c == 0) break` as jmp back to the while-i<127 head
 * (0x1400e83a0 -> 0x1400e8336). Live-pinned on no-ASLR
 * `check examples/hello.x`: two samples 2s apart stayed at
 * typool +252/+256 with i=6, rax=nil, rcx=6, dest typool
 * buf+i*8. Caller return RIP typool
 * driver_set_current_dep_path_for_codegen+35 @ 0x1400e87af.
 * typool driver_current_dep_path_load @ 0x1400e83f4 only
 * returns &typool buf[0] and is folded here so store/load
 * share this host-cc BSS (objdump shows those two typool
 * faces are the only lea of the typool Lxml cells).
 * typool driver_set/get_current_dep_path_for_codegen only
 * call store/load and are not folded. docs-only .x, do not
 * idx8. Do not JMP typool rec T 0x140087de4. Do not fold
 * typool diag_io_fputc / typool rec / typool
 * lexer_next_impl wholesale in this thin. */
#include <stdint.h>

static uint8_t g_driver_current_dep_path_buf[128];
static uint8_t *g_driver_current_dep_path;

void driver_current_dep_path_store(const uint8_t *path) {
  int32_t i;
  uint8_t c;

  if (path == 0 || path[0] == 0) {
    g_driver_current_dep_path_buf[0] = 0;
    g_driver_current_dep_path = 0;
    return;
  }
  i = 0;
  while (i < 127) {
    c = path[i];
    g_driver_current_dep_path_buf[i] = c;
    if (c == 0) {
      break;
    }
    i = i + 1;
  }
  g_driver_current_dep_path_buf[127] = 0;
  g_driver_current_dep_path = &g_driver_current_dep_path_buf[0];
}

uint8_t *driver_current_dep_path_load(void) {
  return &g_driver_current_dep_path_buf[0];
}
