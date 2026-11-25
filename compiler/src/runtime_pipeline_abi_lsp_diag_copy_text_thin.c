/* Host-gcc twin of typool lsp_diag_copy_text (runtime_lsp_glue.x).
 * typool first-wins T 0x140395a3c (fromsrc_s86; no leftover W) compiled
 * `c = src[n]; dst[n] = c` as shallow lea through &src / &dst plus
 * scale-8 qword loads/stores:
 *   lea rax,[rbp-0x20]; lea rax,[rax+rbx*8]; mov rax,[rax]
 *   lea rax,[rbp-0x10]; lea rax,[rax+rbx*8]; mov [rax],rcx
 * and compiled `if (c == 0) { break; }` as a jmp to the while-head.
 * On fromsrc_s86 check examples/hello.x (repo cwd), typool
 * lsp_diag_add_code called typool lsp_diag_copy_text(e->msg, 0xf1, msg)
 * after seven successful thin appends. Live GDB: ENTER_COPY n=2
 * dst=s_diag+0x1c cap=241 src=heap_msg ret=0x14039c233; typool
 * scale-8 store at typool 0x140395b63 wrote i=0 src into &dst,
 * i=1 cap 0xf1 into saved rbx, i=2 src into saved rbp, i=3 cap 0xf1
 * into the return slot (dest 0x103f7148 val=0xf1); then 240 stores
 * and ret to 0xf1. SIGSEGV RIP=0xf1, rsp repeating heap_msg / 0xf1.
 * Writer RIP typool 0x140395b63 (scale-8 qword store). Caller return
 * RIP typool lsp_diag_add_code at 0x14039c233, immediately after the
 * second `call lsp_diag_copy_text`. typool lsp_diag_add /
 * typool lsp_diag_add_code / typool driver_diagnostic_parse_skip_function
 * / typool driver_diag_append_i32 / typool driver_diag_append_name /
 * typool diag_io_fputc are not in this thin. Host-gcc twin indexes
 * bytes through the dst/src pointers and uses a real break. docs-only
 * .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

void lsp_diag_copy_text(uint8_t *dst, int32_t cap, uint8_t *src) {
  int32_t n;
  uint8_t c;

  if (dst == 0) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  if (src == 0) {
    dst[0] = 0;
    return;
  }
  n = 0;
  while (n + 1 < cap) {
    c = src[n];
    if (c == 0) {
      break;
    }
    dst[n] = c;
    n = n + 1;
  }
  dst[n] = 0;
}
