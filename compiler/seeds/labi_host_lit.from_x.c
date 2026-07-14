/* seeds/labi_host_lit.from_x.c — G-02f-269/L P2 link_abi L2 host lit thin shells
 * Logic source: src/runtime/labi_host_lit.x（真迁 thin 转发；#if 在 mega rest）
 * Hybrid: SHUX_LABI_HOST_LIT_FROM_X + ld -r into runtime_link_abi.o
 * 产品 PREFER_X_O：g05_try_x_to_o(labi_host_lit.x)；本 seed 冷启动 / fallback
 * prove：nm IDENTICAL（2 公共 gate + labi_host_lit_count + U _impl）
 *
 * Thin shells that forward to *_impl in mega rest.
 * 🔒 #if host bodies: shux_host_is_linux_impl / shux_host_is_apple_aarch64_impl (always in rest)
 * Bootstrap-safe compile-time detection (not runtime uname).
 */

/* Host #if bodies provided by runtime_link_abi.from_x.c rest (always). */
int shux_host_is_linux_impl(void);
int shux_host_is_apple_aarch64_impl(void);

int shux_host_is_linux(void) {
  return shux_host_is_linux_impl();
}

int shux_host_is_apple_aarch64(void) {
  return shux_host_is_apple_aarch64_impl();
}

/* Pure audit: number of L2 host-lit thin gates in this slice. */
int labi_host_lit_count(void) {
  return 2;
}
