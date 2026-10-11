module std.net.tls_stub_import_alias;

/*
 * Import aliases for std.net.tls_stub and std.net.tcp_pool.
 * The net merge used to generate a C file and compile it with host cc.
 * These strong forwards are the same names. Bodies live in tls_stub.o and
 * tcp_pool.o, which the merge links beside this object.
 * PLATFORM: SHARED. Darwin and Linux compile this with -backend asm.
 * Windows keeps the generated C file.
 * The old C file also emitted weak io and addr stubs. Those symbols have no
 * relocation in the merged net object. Addr symbols come from the addr fast
 * object. This file does not re-export them.
 */

/**
 * Forward `std_net_tls_stub_net_tls_is_available_c`.
 * Returns the stub's availability flag (0).
 */
export function std_net_tls_stub_net_tls_is_available_c(): i32 {
  unsafe {
    return net_tls_is_available_c();
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_backend_name_c`.
 * Returns the callee's name pointer. The name already ends in `_c`.
 */
export function std_net_tls_stub_net_tls_backend_name_c(): *u8 {
  unsafe {
    return net_tls_backend_name_c();
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_connect_client_c`.
 * The callee returns i64. This wrapper returns that i64.
 * fd < 0: 0, and the stub sets last_error to -2.
 */
export function std_net_tls_stub_net_tls_connect_client_c(fd: i32, sni: *u8): i64 {
  unsafe {
    return net_tls_connect_client_c(fd, sni);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_connect_client_alpn_c`.
 * Returns the callee's i64 (0 on the stub).
 */
export function std_net_tls_stub_net_tls_connect_client_alpn_c(fd: i32, sni: *u8,
    alpn: *u8, alpn_len: i32): i64 {
  unsafe {
    return net_tls_connect_client_alpn_c(fd, sni, alpn, alpn_len);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_close_c`.
 * Returns the callee's i32.
 */
export function std_net_tls_stub_net_tls_close_c(h: i64): i32 {
  unsafe {
    return net_tls_close_c(h);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_read_c`.
 * Returns the callee's i32.
 */
export function std_net_tls_stub_net_tls_read_c(h: i64, buf: *u8, cap: i32): i32 {
  unsafe {
    return net_tls_read_c(h, buf, cap);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_write_c`.
 * Returns the callee's i32.
 */
export function std_net_tls_stub_net_tls_write_c(h: i64, buf: *u8, len: i32): i32 {
  unsafe {
    return net_tls_write_c(h, buf, len);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_last_error_c`.
 * Returns the stub's last error code.
 */
export function std_net_tls_stub_net_tls_last_error_c(): i32 {
  unsafe {
    return net_tls_last_error_c();
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_alpn_selected_c`.
 * Returns the callee's i32.
 */
export function std_net_tls_stub_net_tls_alpn_selected_c(h: i64, out: *u8, out_cap: i32): i32 {
  unsafe {
    return net_tls_alpn_selected_c(h, out, out_cap);
  }
}

/**
 * Forward `std_net_tls_stub_net_tls_alpn_is_h2_c`.
 * Returns the callee's i32.
 */
export function std_net_tls_stub_net_tls_alpn_is_h2_c(h: i64): i32 {
  unsafe {
    return net_tls_alpn_is_h2_c(h);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_create_c`.
 * Returns the pool handle as i64. 0 means the create failed.
 */
export function std_net_tcp_pool_net_tcp_pool_create_c(addr: u32, port: u32, max_idle: i32): i64 {
  unsafe {
    return net_tcp_pool_create_c(addr, port, max_idle);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_acquire_c`.
 * Returns the callee's i32. A null handle returns -1.
 */
export function std_net_tcp_pool_net_tcp_pool_acquire_c(h: i64, timeout_ms: u32): i32 {
  unsafe {
    return net_tcp_pool_acquire_c(h, timeout_ms);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_release_c`.
 * Returns the callee's i32.
 */
export function std_net_tcp_pool_net_tcp_pool_release_c(h: i64, fd: i32): i32 {
  unsafe {
    return net_tcp_pool_release_c(h, fd);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_drain_c`.
 * Drops idle sockets on the callee. A null handle returns immediately.
 */
export function std_net_tcp_pool_net_tcp_pool_drain_c(h: i64): void {
  unsafe {
    net_tcp_pool_drain_c(h);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_destroy_c`.
 * Frees the pool on the callee. A null handle returns immediately.
 */
export function std_net_tcp_pool_net_tcp_pool_destroy_c(h: i64): void {
  unsafe {
    net_tcp_pool_destroy_c(h);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_connect_count_c`.
 * A null handle returns -1.
 */
export function std_net_tcp_pool_net_tcp_pool_connect_count_c(h: i64): i32 {
  unsafe {
    return net_tcp_pool_connect_count_c(h);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_idle_count_c`.
 * A null handle returns -1.
 */
export function std_net_tcp_pool_net_tcp_pool_idle_count_c(h: i64): i32 {
  unsafe {
    return net_tcp_pool_idle_count_c(h);
  }
}

/**
 * Forward `std_net_tcp_pool_net_tcp_pool_smoke_c`.
 * Returns 0 when the callee's create/count/destroy smoke passes.
 */
export function std_net_tcp_pool_net_tcp_pool_smoke_c(): i32 {
  unsafe {
    return net_tcp_pool_smoke_c();
  }
}

extern function net_tls_is_available_c(): i32;
extern function net_tls_backend_name_c(): *u8;
extern function net_tls_connect_client_c(fd: i32, sni: *u8): i64;
extern function net_tls_connect_client_alpn_c(fd: i32, sni: *u8, alpn: *u8, alpn_len: i32): i64;
extern function net_tls_close_c(h: i64): i32;
extern function net_tls_read_c(h: i64, buf: *u8, cap: i32): i32;
extern function net_tls_write_c(h: i64, buf: *u8, len: i32): i32;
extern function net_tls_last_error_c(): i32;
extern function net_tls_alpn_selected_c(h: i64, out: *u8, out_cap: i32): i32;
extern function net_tls_alpn_is_h2_c(h: i64): i32;
extern function net_tcp_pool_create_c(addr: u32, port: u32, max_idle: i32): i64;
extern function net_tcp_pool_acquire_c(h: i64, timeout_ms: u32): i32;
extern function net_tcp_pool_release_c(h: i64, fd: i32): i32;
extern function net_tcp_pool_drain_c(h: i64): void;
extern function net_tcp_pool_destroy_c(h: i64): void;
extern function net_tcp_pool_connect_count_c(h: i64): i32;
extern function net_tcp_pool_idle_count_c(h: i64): i32;
extern function net_tcp_pool_smoke_c(): i32;
