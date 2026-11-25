/* Host-gcc twin of driver_diag_append_cstr (runtime_driver_diagnostic.x
 * and runtime_driver_diagnostic_thin.x). typool first-wins T 0x1400f7070
 * (fromsrc_s85; no leftover W) compiled
 * `if (c == 0) { break; }` inside `while (j + 1 < cap)` as a jump to the
 * while condition, not out of the loop:
 *   test eax,eax; je store; jmp 0x1400f7109 (while-head)
 * When src hits NUL with j+1 < cap, typool falls into the while-head
 * with i/j unchanged and spins. Writer RIP typool 0x1400f716e (jmp to
 * the while-head on c==0) / typool 0x1400f712d (jl-not-taken stays in
 * the body because j+1 < cap). Caller return RIP typool
 * driver_diagnostic_parse_skip_function at 0x1400fbb3f, immediately
 * after `call driver_diag_append_cstr`.
 * GDB on fromsrc_s85 check examples/hello.x (repo cwd), live call/ret:
 * seven RET_PARSE kind=0, then ENTER_APPEND n=1 dst=heap cap=240 at=0
 * src=0x1400fbaf9 src[0]=112 ('p') ret=0x1400fbb3f; typool-wrong jmp
 * hit 200 times with i=19 j=19 cap=240 c=0 stuck; enters=1 rets=0.
 * Same typool-wrong class as typool parse_directive_into /
 * typool path_should_ignore break-as-jmp to while-head. Host-gcc twin
 * uses a real break. typool driver_diag_append_name /
 * typool driver_diag_append_i32 / typool driver_diagnostic_parse_skip_function
 * / typool diag_io_fputc are not in this thin. docs-only .x, do not idx8.
 * Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

int32_t driver_diag_append_cstr(uint8_t *dst, int32_t cap, int32_t at, uint8_t *src) {
  int32_t j;
  int32_t i;
  uint8_t c;

  if (dst == 0) {
    return at;
  }
  if (src == 0) {
    return at;
  }
  j = at;
  i = 0;
  while (j + 1 < cap) {
    c = src[i];
    if (c == 0) {
      break;
    }
    dst[j] = c;
    j = j + 1;
    i = i + 1;
  }
  dst[j] = 0;
  return j;
}
