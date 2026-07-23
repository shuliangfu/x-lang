/*
 * xlang_user_link_abi_getenv.h — user-domain link_abi_getenv face for STD_AND_PANIC
 *
 * wave252 G.7: residual STD_AND_PANIC leaves (backtrace/env_os/process_os/log_os/http_glue)
 * must not call raw libc getenv; authority name is link_abi_getenv (≡ wave222 pure thin
 * null/empty gate → link_abi_getenv_impl host getenv).
 *
 * Product host g05 authority remains labi_diag_pure.x + mega link_abi_getenv_impl —
 * this header is NEVER compiled into the g05 60/62-obj bag.
 *
 * Dual-end co-link policy (PLATFORM: SHARED user/STD_AND_PANIC only):
 * - Strong twin: runtime_panic C seeds (wave251) when that TU is linked (mac / non-x86_64 C).
 * - Linux x86_64 product panic is freestanding .s (no face, must not pull libc getenv).
 * - Residual leaves that still need face under .s panic define a weak twin via
 *   XLANG_USER_LINK_ABI_GETENV_PROVIDE_WEAK_TWIN before including this header.
 * - Strong wins over weak when both present; multiple weak copies are linker-ok.
 *
 * Usage:
 *   #define XLANG_USER_LINK_ABI_GETENV_PROVIDE_WEAK_TWIN 1
 *   #include <xlang_user_link_abi_getenv.h>
 *   // then call link_abi_getenv("KEY") instead of getenv("KEY")
 *
 * Or declaration-only (panic / already has strong twin):
 *   #include <xlang_user_link_abi_getenv.h>
 */

#ifndef XLANG_USER_LINK_ABI_GETENV_H
#define XLANG_USER_LINK_ABI_GETENV_H

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__GNUC__) || defined(__clang__)
#define XLANG_USER_ENV_WEAK __attribute__((weak))
#else
#define XLANG_USER_ENV_WEAK
#endif

#if defined(XLANG_USER_LINK_ABI_GETENV_PROVIDE_WEAK_TWIN)

#include <stdlib.h>

/**
 * Cap residual host getenv for user-linked STD_AND_PANIC residual TUs (≡ product _impl).
 * Weak: strong may come from runtime_panic C seed (wave251).
 * @param name NUL-terminated environment key; may be null
 * @return value pointer from process env block, or NULL
 */
XLANG_USER_ENV_WEAK
const char *link_abi_getenv_impl(const char *name) {
  if (!name || !name[0])
    return NULL;
  return getenv(name);
}

/**
 * Public face twin: null/empty gate then host residual (≡ product pure thin / wave251).
 * Weak: strong may come from runtime_panic C seed (wave251).
 * @param name NUL-terminated environment key
 * @return NULL on null/empty; else link_abi_getenv_impl value
 */
XLANG_USER_ENV_WEAK
const char *link_abi_getenv(const char *name) {
  if (!name || !name[0])
    return NULL;
  return link_abi_getenv_impl(name);
}

#else

const char *link_abi_getenv(const char *name);
const char *link_abi_getenv_impl(const char *name);

#endif /* XLANG_USER_LINK_ABI_GETENV_PROVIDE_WEAK_TWIN */

#ifdef __cplusplus
}
#endif

#endif /* XLANG_USER_LINK_ABI_GETENV_H */
