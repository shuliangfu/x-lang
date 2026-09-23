/* seeds/backend_arch_emit_dispatch.from_x.c — w849 slice marker only.
 * The 47 ta-dispatch shells live only in src/asm/backend_arch_emit_dispatch.x.
 * w849 deleted those C bodies and seeds/backend_arch_emit_dispatch_thin.from_x.c.
 * Product src/asm/backend_arch_emit_dispatch.o is pure-asm of that .x plus
 * this marker. The marker returns 0, matching the previous FROM_X rest.
 * There is no gcc -E path and no cold full-seed fallback.
 * XLANG_BACKEND_ARCH_EMIT_DISPATCH_FROM_X and XLANG_L2_ARCH_EMIT_THIN_FROM_X
 * are no longer read. XLANG_G05_PREFER_X_O is ignored.
 * Windows takes the same path.
 * PLATFORM: SHARED.
 */
int backend_arch_emit_dispatch_slice_marker(void) {
  return 0;
}
