// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_net_sock_fast.x — Thin wrappers for Winsock startup.
// Darwin arm64 socket, bind, listen, and the errno _c faces live in
// runtime_net_sock_fast_darwin.x. Linux and Windows keep the C seed.
// PLATFORM: SHARED wrappers. MACOS|DARWIN arm64 bodies are the other file.

export extern "C" function net_ensure_wsa_impl_c(): void;
export extern "C" function net_wsa_ctor_impl_c(): void;

/**
 * Anchor function for runtime_net_sock_fast .x module documentation.
 * @return i32 — always 0
 */
export function runtime_net_sock_fast_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Ensure Winsock (WSAStartup) is initialized on Windows; no-op on POSIX.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function net_ensure_wsa(): void {
  unsafe {
    net_ensure_wsa_impl_c();
  }
}

/**
 * Constructor hook initializing Winsock at process startup on Windows.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function net_wsa_ctor(): void {
  unsafe {
    net_wsa_ctor_impl_c();
  }
}
