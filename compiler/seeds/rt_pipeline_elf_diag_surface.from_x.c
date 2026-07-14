/* seeds/rt_pipeline_elf_diag_surface.from_x.c
 * G-02f rt_pipeline_elf_diag L2 thin surface — isomorphic with src/runtime/rt_pipeline_elf_diag.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_pipeline_elf_diag.x) + hybrid rest seed
 *   seeds/rt_pipeline_elf_diag.from_x.c (-DSHUX_RT_PIPELINE_ELF_DIAG_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: read-table/diag body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_pipeline_elf_diag.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern void runtime_pipeline_elf_ctx_diag_note_impl(uint8_t * ctx_bytes);
void runtime_pipeline_elf_ctx_diag_note(uint8_t * ctx_bytes) {
  {
    runtime_pipeline_elf_ctx_diag_note_impl(ctx_bytes);
    return;
  }
}
