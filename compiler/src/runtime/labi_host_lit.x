// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-269 / P2 link_abi L2 host lit → R2 full.
// wave760 Class K: #[cfg] two-level owns xlang_host_is_*_impl (was Cap #if in
// seeds/runtime_link_abi.from_x.c rest). FROM_X rest skips those #if bodies.
// Same-name #[cfg] `return 1` dual-emits reti32 on Darwin — helpers + dispatch.
// Cold non-FROM_X still uses rest #if. Do not -E as repair.
// wave763 Class N: FROM_X rest skips Cap WEAK empty bootstrap_init_* ;
// product strong TLS/environ init stays in bootstrap_nostdlib_stubs (CB-fix:
// L2 must not export empty strong and win allow-multiple-definition).
// PLATFORM: SHARED — Darwin + Ubuntu L2.

#[cfg(target_os = "linux")]
#[no_mangle]
export function xlang_host_is_linux_impl_on(): i32 { return 1; }
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function xlang_host_is_linux_impl_off(): i32 { return 0; }

#[cfg(target_os = "linux")]
#[no_mangle]
export function xlang_host_is_linux_impl(): i32 {
  return xlang_host_is_linux_impl_on();
}
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function xlang_host_is_linux_impl(): i32 {
  return xlang_host_is_linux_impl_off();
}

#[cfg(target_os = "macos")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl_on(): i32 { return 1; }
#[cfg(target_os = "macos")]
#[cfg(not(target_arch = "aarch64"))]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl_off(): i32 { return 0; }
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl_off(): i32 { return 0; }

#[cfg(target_os = "macos")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl(): i32 {
  return xlang_host_is_apple_aarch64_impl_on();
}
#[cfg(target_os = "macos")]
#[cfg(not(target_arch = "aarch64"))]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl(): i32 {
  return xlang_host_is_apple_aarch64_impl_off();
}
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function xlang_host_is_apple_aarch64_impl(): i32 {
  return xlang_host_is_apple_aarch64_impl_off();
}

#[no_mangle]
export function xlang_host_is_linux(): i32 { return xlang_host_is_linux_impl(); }
#[no_mangle]
export function xlang_host_is_apple_aarch64(): i32 { return xlang_host_is_apple_aarch64_impl(); }
#[no_mangle]
export function labi_host_lit_count(): i32 { return 2; }

// wave761 Class L: four link_abi host gates move out of mega rest Cap #if.
// Two-level helpers avoid Darwin same-name #[cfg] dual-emission.

#[cfg(target_os = "macos")]
#[no_mangle]
export function link_abi_host_is_apple_on(): i32 { return 1; }
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function link_abi_host_is_apple_off(): i32 { return 0; }
#[cfg(target_os = "macos")]
#[no_mangle]
export function link_abi_host_is_apple(): i32 { return link_abi_host_is_apple_on(); }
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function link_abi_host_is_apple(): i32 { return link_abi_host_is_apple_off(); }

#[cfg(target_os = "windows")]
#[no_mangle]
export function link_abi_host_is_windows_on(): i32 { return 1; }
#[cfg(not(target_os = "windows"))]
#[no_mangle]
export function link_abi_host_is_windows_off(): i32 { return 0; }
#[cfg(target_os = "windows")]
#[no_mangle]
export function link_abi_host_is_windows(): i32 { return link_abi_host_is_windows_on(); }
#[cfg(not(target_os = "windows"))]
#[no_mangle]
export function link_abi_host_is_windows(): i32 { return link_abi_host_is_windows_off(); }

#[cfg(target_os = "linux")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function link_abi_host_is_linux_x86_64_on(): i32 { return 1; }
#[cfg(target_os = "linux")]
#[cfg(not(target_arch = "x86_64"))]
#[no_mangle]
export function link_abi_host_is_linux_x86_64_off(): i32 { return 0; }
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function link_abi_host_is_linux_x86_64_off(): i32 { return 0; }
#[cfg(target_os = "linux")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function link_abi_host_is_linux_x86_64(): i32 { return link_abi_host_is_linux_x86_64_on(); }
#[cfg(target_os = "linux")]
#[cfg(not(target_arch = "x86_64"))]
#[no_mangle]
export function link_abi_host_is_linux_x86_64(): i32 { return link_abi_host_is_linux_x86_64_off(); }
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function link_abi_host_is_linux_x86_64(): i32 { return link_abi_host_is_linux_x86_64_off(); }

#[cfg(target_arch = "aarch64")]
#[cfg(target_os = "linux")]
#[no_mangle]
export function link_abi_host_is_posix_aarch64_on(): i32 { return 1; }
#[cfg(target_arch = "aarch64")]
#[cfg(target_os = "macos")]
#[no_mangle]
export function link_abi_host_is_posix_aarch64_on(): i32 { return 1; }
#[cfg(not(target_arch = "aarch64"))]
#[no_mangle]
export function link_abi_host_is_posix_aarch64_off(): i32 { return 0; }
#[cfg(target_arch = "aarch64")]
#[cfg(not(target_os = "linux"))]
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function link_abi_host_is_posix_aarch64_off(): i32 { return 0; }
#[cfg(target_arch = "aarch64")]
#[cfg(target_os = "linux")]
#[no_mangle]
export function link_abi_host_is_posix_aarch64(): i32 { return link_abi_host_is_posix_aarch64_on(); }
#[cfg(target_arch = "aarch64")]
#[cfg(target_os = "macos")]
#[no_mangle]
export function link_abi_host_is_posix_aarch64(): i32 { return link_abi_host_is_posix_aarch64_on(); }
#[cfg(not(target_arch = "aarch64"))]
#[no_mangle]
export function link_abi_host_is_posix_aarch64(): i32 { return link_abi_host_is_posix_aarch64_off(); }
#[cfg(target_arch = "aarch64")]
#[cfg(not(target_os = "linux"))]
#[cfg(not(target_os = "macos"))]
#[no_mangle]
export function link_abi_host_is_posix_aarch64(): i32 { return link_abi_host_is_posix_aarch64_off(); }

// wave762 Class M: pthread stub gate was Cap #if WEAK in link_abi rest.
// Two-level helpers avoid Darwin same-name #[cfg] dual-emission.
// WINDOWS=1 (winpthreads crash on 256MiB custom stack); POSIX=0.

#[cfg(target_os = "windows")]
#[no_mangle]
export function bootstrap_nostdlib_pthread_is_stub_on(): i32 { return 1; }
#[cfg(not(target_os = "windows"))]
#[no_mangle]
export function bootstrap_nostdlib_pthread_is_stub_off(): i32 { return 0; }
#[cfg(target_os = "windows")]
#[no_mangle]
export function bootstrap_nostdlib_pthread_is_stub(): i32 {
  return bootstrap_nostdlib_pthread_is_stub_on();
}
#[cfg(not(target_os = "windows"))]
#[no_mangle]
export function bootstrap_nostdlib_pthread_is_stub(): i32 {
  return bootstrap_nostdlib_pthread_is_stub_off();
}

// wave763 Class N / Class CB-fix: do NOT export empty bootstrap_init_static_tls
// / bootstrap_init_environ here. Strong empty + G05 -Wl,--allow-multiple-definition
// + runtime_link_abi before bootstrap_nostdlib_stubs in G05_OBJS stole the real
// stubs TLS init → Ubuntu tip pure-ld SEGV on %fs:0x28 stack canary.
// FROM_X rest only forward-declares; product strong body = seeds/bootstrap_nostdlib_stubs.
// Cap WEAK empty remains in !FROM_X rest as archaeology fallback.
