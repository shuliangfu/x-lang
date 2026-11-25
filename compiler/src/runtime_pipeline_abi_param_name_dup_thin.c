/*
 * Host-gcc twin of parser_onefunc_param_name_dup_c (pthin_body_tl.x).
 * Root (s46 unofficial hello --check hang): typool first-wins W at
 *   0x1404d8248 is live. After as_suffix consumes the '.' of fmt.println,
 *   hello check no longer dies at P001@206; typool dup_c is then entered
 *   for OneFunc param-name duplicate checks.
 * typool compiled `if (pb != nb) break;` as:
 *   setne / je k++ / jmp inner-loop-head
 * so a first-byte mismatch jumps back to `while (k < name_len)` with k
 * still 0 instead of breaking to i++. gdb: 50k+ calls of typool
 * pipeline_onefunc_param_name_byte_at from typool dup_c+455, always
 * i=0 off=0, used_hi=1. Historical onefunc-MRU RIP is just the hot
 * typool get inside that tight loop, not a bug in mru_recall itself.
 * Class: typool miscompiled break-as-continue on a byte mismatch
 *   (write-one-slot / compare-another cousin: increment never taken).
 * Fold allowlist: parser_onefunc_param_name_dup_c only.
 * Do not fold typool pend BSS, typool w1545_pend_rcx_emit, or
 *   typool onefunc_sidecar_get / formal-ensure.
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

int32_t pipeline_onefunc_param_name_len(uint8_t *pool, int32_t i);
uint8_t pipeline_onefunc_param_name_byte_at(uint8_t *pool, int32_t i, int32_t off);

int32_t parser_onefunc_param_name_dup_c(uint8_t *pool, int32_t nparams,
                                       uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t k;
  int32_t pl;
  uint8_t nb;
  uint8_t pb;

  if (pool == 0 || name == 0 || name_len <= 0 || nparams <= 0) {
    return 0;
  }
  i = 0;
  while (i < nparams) {
    pl = pipeline_onefunc_param_name_len(pool, i);
    if (pl == name_len) {
      k = 0;
      while (k < name_len) {
        nb = name[k];
        pb = pipeline_onefunc_param_name_byte_at(pool, i, k);
        if (pb != nb) {
          break;
        }
        k = k + 1;
      }
      if (k == name_len) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}
