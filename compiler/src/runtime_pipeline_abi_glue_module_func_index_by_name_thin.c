/* Source-faithful glue_module_func_index_by_name twin
 * (compiler/src/asm/backend_try_inline_dispatch.x).
 * s160 hello-build residual: uninstrumented compile_timeout=true in 25.103s,
 * no first-chance AV under DEBUG_ONLY_THIS_PROCESS (40s). Suspended RIP
 * snapshots for 20s stayed in typool glue_module_func_index_by_name
 * (s160 T 0x1403ebef8) around +0x1ad..+0x1ff, same rbp/rsp, caller typool
 * glue_call_lookup_callee_mod_fi_arena+0x236a. typool name-compare loop:
 * lea rax,[rbp-0x140] / lea rax,[rbp-0x18]; lea rax,[rax+k*8]; mov rax,[rax]
 * is typool scale-8 lea-of-local-slot of fb[k] / name[k]; typool mismatch
 * does ok=0 then jmp to the while(k<nlen) head without incrementing k
 * (typool break-as-jmp-to-head), so the loop never exits.
 * typool glue / typool lookup were not folded on s160; this NEW pin proves
 * typool glue itself is the first producer of THIS residual. typool note /
 * typool enc_* / typool store-or-load cousins were not entered as the
 * spinner and were not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

int32_t pipeline_module_num_funcs(uint8_t *mod);
int32_t pipeline_asm_module_func_name_len_at(uint8_t *mod, int32_t fi);
void pipeline_asm_module_func_name_copy64(uint8_t *mod, int32_t fi, uint8_t *dst);

int32_t glue_module_func_index_by_name(uint8_t *mod, uint8_t *name, int32_t nlen) {
  int32_t nfuncs;
  int32_t fi;
  int32_t flen;
  int32_t k;
  int32_t ok;
  uint8_t fb[256];
  if (mod == 0) {
    return 0 - 1;
  }
  if (name == 0) {
    return 0 - 1;
  }
  if (nlen <= 0) {
    return 0 - 1;
  }
  if (nlen > 255) {
    return 0 - 1;
  }
  nfuncs = pipeline_module_num_funcs(mod);
  fi = 0;
  while (fi < nfuncs) {
    flen = pipeline_asm_module_func_name_len_at(mod, fi);
    if (flen == nlen) {
      pipeline_asm_module_func_name_copy64(mod, fi, &fb[0]);
      k = 0;
      ok = 1;
      while (k < nlen) {
        if (fb[k] != name[k]) {
          ok = 0;
          break;
        }
        k = k + 1;
      }
      if (ok != 0) {
        return fi;
      }
    }
    fi = fi + 1;
  }
  return 0 - 1;
}
