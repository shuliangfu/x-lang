/* seeds/labi_host_lit.from_x.c — G-02f-269 P2 link_abi L2 host lit
 * Logic source: src/runtime/labi_host_lit.x
 * Hybrid: SHUX_LABI_HOST_LIT_FROM_X + ld -r into runtime_link_abi.o
 * Host detection via C #if (bootstrap-safe; not runtime uname).
 */

int shux_host_is_linux(void) {
#if defined(__linux__)
  return 1;
#else
  return 0;
#endif
}

int shux_host_is_apple_aarch64(void) {
#if defined(__APPLE__) && defined(__aarch64__)
  return 1;
#else
  return 0;
#endif
}
