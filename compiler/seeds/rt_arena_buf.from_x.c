/* seeds/rt_arena_buf.from_x.c — Cap-global-bss arrays only.
 * driver_arena_buf, driver_module_buf, and labi_rt_arena_buf_slice_marker
 * are defined only in src/runtime/rt_arena_buf.x. The marker C body was
 * deleted in w858 (it returned 1). Do not reintroduce a #ifndef twin.
 * This file remains because the 128MiB arena and the 2MiB module array
 * are not an .x export (export let becomes static). Slot accessors live
 * in runtime_driver_abi.
 * PLATFORM: SHARED — product links pure-asm .x + this BSS object. No
 * full-seed fallback: a seed-only cc defines neither function nor marker.
 */
#include <stdint.h>

/** Arena storage for codegen struct ast_ASTArena. Must be at least
 * pipeline_sizeof_arena(). The host pool is about 90MiB; 128MiB is headroom.
 */
#define DRIVER_ARENA_STATIC_SIZE (128 * 1024 * 1024)
#define DRIVER_MODULE_STATIC_SIZE (2 * 1024 * 1024)

/* Cap-global-bss residual: these arrays must be non-static so other TUs
 * can take their address. An .x export let lowers to static and cannot
 * replace this block. driver_abi slot functions extern these symbols.
 * PLATFORM: MACOS — a tentative COMMON 128MiB object takes a size-derived
 * section alignment of 0x8000, and Apple ld then warns that it is reducing
 * __DATA,__common alignment from 0x8000 to 0x4000. The {0} initializer
 * forces a defined zerofill (alignment 2^0) so the .o stays tiny.
 * PLATFORM: SHARED seed — Linux ELF BSS uses the same shape.
 */
uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE] = {0};
uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE] = {0};
