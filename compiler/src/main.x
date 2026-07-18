// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
//
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

const ast = import("ast");
const codegen = import("codegen");
const sys = import("std.sys");
export extern "C" function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize;
export extern "C" function fs_posix_close_c(fd: i32): i32;
/* See implementation. */
export extern function preprocess_x_buf(source_buf: *u8, source_len: isize, out_buf: *u8, out_cap: i32): i32;
/* See implementation. */
export extern function driver_cmd_fmt(argc: i32, argv: *u8): i32;
export extern function driver_cmd_check(argc: i32, argv: *u8): i32;
export extern function driver_cmd_test(argc: i32, argv: *u8): i32;

/* See implementation. */
export struct DriverXEmitState {
  path_buf: u8[512];
  path_len: i32;
  /* See implementation. */
  emit_extern_imports: i32;
  /* See implementation. */
  use_asm_backend: i32;
  /* See implementation. */
  target_arch: i32;
  /* See implementation. */
  out_path_buf: u8[512];
  out_path_len: i32;
}

/* See implementation. */
export extern function driver_emit_lib_root_reset(state: *u8): void;
export extern function driver_emit_append_lib_root(state: *u8, path: *u8, len: i32): i32;
export extern function driver_emit_lib_root_count(state: *u8): i32;
export extern function driver_emit_lib_root_len(state: *u8, i: i32): i32;
export extern function driver_emit_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void;

/** Exported function `driver_emit_state_key`.
 * Implements `driver_emit_state_key`.
 * @param state *DriverXEmitState
 * @return *u8
 */
export function driver_emit_state_key(state: *DriverXEmitState): *u8 {
  return state as *u8;
}

/** Exported function `driver_emit_try_append_lib_from_argv`.
 * Implements `driver_emit_try_append_lib_from_argv`.
 * @param argc i32
 * @param argv *u8
 * @param arg_i i32
 * @param state *DriverXEmitState
 * @return i32
 */
export function driver_emit_try_append_lib_from_argv(argc: i32, argv: *u8, arg_i: i32, state: *DriverXEmitState): i32 {
  let tmp: u8[256] = [];
  let llen: i32 = driver_get_argv_i(argc, argv, arg_i, &tmp[0], 256);
  if (llen >= 0 && driver_emit_append_lib_root(driver_emit_state_key(state), &tmp[0], llen) >= 0) {
    return 1;
  }
  return 0;
}

/** Exported function `driver_emit_ensure_default_lib_root`.
 * Implements `driver_emit_ensure_default_lib_root`.
 * @param state *DriverXEmitState
 * @return void
 */
export function driver_emit_ensure_default_lib_root(state: *DriverXEmitState): void {
  if (driver_emit_lib_root_count(driver_emit_state_key(state)) == 0) {
    let dot: u8[1] = [46];
    driver_emit_append_lib_root(driver_emit_state_key(state), &dot[0], 1);
  }
}

/** Exported function `driver_emit_copy_lib_roots_to_ctx`.
 * Implements `driver_emit_copy_lib_roots_to_ctx`.
 * @param state *DriverXEmitState
 * @param ctx *PipelineDepCtx
 * @return void
 */
export function driver_emit_copy_lib_roots_to_ctx(state: *DriverXEmitState, ctx: *PipelineDepCtx): void {
  let k: i32 = 0;
  let n: i32 = driver_emit_lib_root_count(driver_emit_state_key(state));
  let tmp: u8[256] = [];
  while (k < n) {
    let llen: i32 = driver_emit_lib_root_len(driver_emit_state_key(state), k);
    if (llen > 0) {
      driver_emit_lib_root_copy(driver_emit_state_key(state), k, &tmp[0], 256);
      ast_pipeline_ctx_append_lib_root(ctx, &tmp[0], llen);
    }
    k = k + 1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function driver_emit_state_default(): DriverXEmitState {
  return DriverXEmitState {
    path_buf: [],
    path_len: 0,
    emit_extern_imports: 0,
    use_asm_backend: 1,
    target_arch: 0
  };
}

/**
 * See implementation.
 */
export function pipeline_dep_ctx_for_emit(use_asm: i32, target: i32): PipelineDepCtx {
  let ctx: PipelineDepCtx = PipelineDepCtx {
    ndep: 0,
    entry_dir_buf: [],
    entry_dir_len: 0,
    num_lib_roots: 0
  };
  ctx.use_asm_backend = use_asm;
  ctx.target_arch = target;
  ctx.current_func_index = -1;
  ctx.current_func_single_empty_param_index = -1;
  return ctx;
}

/* See implementation. */
export extern function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32;
/**
 * See implementation.
 * See implementation.
 */
export extern function driver_argv_drop_subcommand(argc: i32, argv: *u8): *u8;
/* See implementation. */
export extern function driver_build_build_x(): i32;
/* See implementation. */
export extern function driver_exec_compiled(argc: i32, argv: *u8): i32;
/* See implementation. */
export extern function driver_fs_open_read_path(path: *u8, path_len: i32): i32;
/* See implementation. */
export extern function driver_arena_buf(): *u8;
export extern function driver_module_buf(): *u8;
/* See implementation. */
export extern function driver_fs_open_write(path: *u8, path_len: i32): i32;
/* See implementation. */
export extern function driver_pipeline_fail_code(rc: i32, path: *u8): void;
/* See implementation. */
export extern function driver_print_x_smoke_summary(module: *u8, codegen_len: usize): void;

/* See implementation. */
export extern function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32;
export extern function driver_run_x_emit_c_set_lib(i: i32, buf: *u8, len: i32): i32;
export extern function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32;
/* See implementation. */
export extern function driver_run_x_emit_c_set_emit_extern(v: i32): i32;
export extern function driver_run_x_emit_c(): i32;

/* See implementation. */
export extern function pipeline_run_x_pipeline_impl(module: *u8, arena: *u8, source_data: *u8, source_len: usize, out_buf: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;
/* See implementation. */
export extern function ast_pipeline_ctx_append_lib_root(ctx: *PipelineDepCtx, path: *u8, len: i32): i32;

/* See implementation. */
export extern function driver_run_compiler_full(argc: i32, argv: *u8): i32;
/** Exported function `run_compiler_c_impl`.
 * Implements `run_compiler_c_impl`.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
export function run_compiler_c_impl(argc: i32, argv: *u8): i32 {
  return driver_run_compiler_full(argc, argv);
}
/** Exported function `run_compiler_c`.
 * Implements `run_compiler_c`.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
export function run_compiler_c(argc: i32, argv: *u8): i32 {
  return run_compiler_c_impl(argc, argv);
}

/**
 * See implementation.
 */
export function main_run_compiler_c(argc: i32, argv: *u8): i32 {
  return run_compiler_c(argc, argv);
}

/** Exported function `eq_minus_L`.
 * Implements `eq_minus_L`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_L(buf: *u8, len: i32): i32 {
  if (len < 2) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 76) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_x`.
 * Implements `eq_minus_x`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_x(buf: *u8, len: i32): i32 {
  if (len < 3) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 115 && buf[2] == 120) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_E`.
 * Implements `eq_minus_E`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_E(buf: *u8, len: i32): i32 {
  if (len < 2) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 69) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_E_extern`.
 * Implements `eq_minus_E_extern`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_E_extern(buf: *u8, len: i32): i32 {
  if (len < 9) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 69 && buf[2] == 45 && buf[3] == 101 && buf[4] == 120 && buf[5] == 116 && buf[6] == 101 && buf[7] == 114 && buf[8] == 110) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_backend`.
 * Implements `eq_minus_backend`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_backend(buf: *u8, len: i32): i32 {
  if (len < 8) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 98 && buf[2] == 97 && buf[3] == 99 && buf[4] == 107 && buf[5] == 101 && buf[6] == 110 && buf[7] == 100) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_asm`.
 * Implements `eq_asm`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_asm(buf: *u8, len: i32): i32 {
  if (len < 3) {
    return 0;
  }
  if (buf[0] == 97 && buf[1] == 115 && buf[2] == 109) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_lsp`.
 * Implements `eq_minus_lsp`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_lsp(buf: *u8, len: i32): i32 {
  if (len < 5) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 45 && buf[2] == 108 && buf[3] == 115 && buf[4] == 112) {
    return 1;
  }
  return 0;
}

/** Exported function `eq_minus_target`.
 * Implements `eq_minus_target`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function eq_minus_target(buf: *u8, len: i32): i32 {
  if (len < 7) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 116 && buf[2] == 97 && buf[3] == 114 && buf[4] == 103 && buf[5] == 101 && buf[6] == 116) {
    return 1;
  }
  return 0;
}

/** Exported function `str_eq`.
 * Implements `str_eq`.
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return i32
 */
export function str_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `target_contains_arm`.
 * Implements `target_contains_arm`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function target_contains_arm(buf: *u8, len: i32): i32 {
  let start: i32 = 0;
  while (start + 7 <= len) {
    if (buf[start] == 97 && buf[start + 1] == 97 && buf[start + 2] == 114 && buf[start + 3] == 99 && buf[start + 4] == 104 && buf[start + 5] == 54 && buf[start + 6] == 52) {
      return 1;
    }
    start = start + 1;
  }
  start = 0;
  while (start + 5 <= len) {
    if (buf[start] == 97 && buf[start + 1] == 114 && buf[start + 2] == 109 && buf[start + 3] == 54 && buf[start + 4] == 52) {
      return 1;
    }
    start = start + 1;
  }
  return 0;
}

/** Exported function `target_contains_riscv`.
 * Implements `target_contains_riscv`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function target_contains_riscv(buf: *u8, len: i32): i32 {
  let start: i32 = 0;
  while (start + 7 <= len) {
    if (buf[start] == 114 && buf[start + 1] == 105 && buf[start + 2] == 115 && buf[start + 3] == 99 && buf[start + 4] == 118 && buf[start + 5] == 54 && buf[start + 6] == 52) {
      return 1;
    }
    start = start + 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function driver_argv_parse_x_path(argc: i32, argv: *u8, state: *DriverXEmitState): i32 {
  state.path_len = 0;
  driver_emit_lib_root_reset(driver_emit_state_key(state));
  state.emit_extern_imports = 0;
  /* See implementation. */
  state.use_asm_backend = 1;
  state.target_arch = 0;
  state.out_path_len = 0;
  if (argc < 2) {
    return 2;
  }
  let arg_buf: u8[512] = [];
  let i: i32 = 1;
  let has_o: i32 = 0;
  while (i < argc) {
    let len: i32 = driver_get_argv_i(argc, argv, i, arg_buf, 512);
    if (len < 0) {
      i = i + 1;
      continue;
    }
    if (eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {
      let tlen: i32 = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
      if (tlen >= 0 && target_contains_arm(arg_buf, tlen) != 0) {
        state.target_arch = 1;
      }
      if (tlen >= 0 && target_contains_riscv(arg_buf, tlen) != 0) {
        state.target_arch = 2;
      }
      i = i + 2;
      continue;
    }
    if (eq_minus_L(arg_buf, len) != 0) {
      if (i + 1 >= argc) {
        return 2;
      }
      driver_emit_try_append_lib_from_argv(argc, argv, i + 1, state);
      i = i + 2;
      continue;
    }
    if (eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {
      let vlen: i32 = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
      /* See implementation. */
      if (vlen >= 0 && vlen == 1 && arg_buf[0] == 99) {
        state.use_asm_backend = 0;
      }
      if (vlen >= 0 && eq_asm(arg_buf, vlen) != 0) {
        state.use_asm_backend = 1;
      }
      i = i + 2;
      continue;
    }
    /* See implementation. */
    if (len == 2 && arg_buf[0] == 45 && arg_buf[1] == 111) {
      if (i + 1 < argc) {
        let olen: i32 = driver_get_argv_i(argc, argv, i + 1, state.out_path_buf, 512);
        if (olen >= 0) {
          state.out_path_len = olen;
        }
        i = i + 2;
      } else {
        has_o = 1;
        i = i + 1;
      }
      continue;
    }
    if (len == 2 && arg_buf[0] == 45 && arg_buf[1] == 79) {
      i = i + 1;
      if (i < argc) {
        i = i + 1;
      }
      continue;
    }
    if (eq_minus_x(arg_buf, len) != 0) {
      i = i + 1;
      continue;
    }
    if (eq_minus_E(arg_buf, len) != 0) {
      i = i + 1;
      continue;
    }
    if (eq_minus_E_extern(arg_buf, len) != 0) {
      i = i + 1;
      continue;
    }
    if (state.path_len == 0 && len > 0) {
      let k: i32 = 0;
      while (k < len && k < 512) {
        state.path_buf[k] = arg_buf[k];
        k = k + 1;
      }
      state.path_len = len;
    }
    i = i + 1;
  }
  if (has_o != 0) {
    return 1;
  }
  if (state.path_len == 0) {
    return 2;
  }
  /* See implementation. */
  driver_emit_ensure_default_lib_root(state);
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function driver_argv_parse_x(argc: i32, argv: *u8, state: *DriverXEmitState): i32 {
  state.path_len = 0;
  driver_emit_lib_root_reset(driver_emit_state_key(state));
  state.emit_extern_imports = 0;
  state.use_asm_backend = 0;
  state.target_arch = 0;
  state.out_path_len = 0;
  if (argc < 3) {
    return 0;
  }
  let arg_buf: u8[512] = [];
  let i: i32 = 1;
  while (i < argc) {
    let len: i32 = driver_get_argv_i(argc, argv, i, arg_buf, 512);
    if (len < 0) {
      i = i + 1;
      continue;
    }
    if (eq_minus_L(arg_buf, len) != 0 && i + 1 < argc) {
      driver_emit_try_append_lib_from_argv(argc, argv, i + 1, state);
      i = i + 2;
      continue;
    }
    if (eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {
      let vlen: i32 = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
      if (vlen >= 0 && eq_asm(arg_buf, vlen) != 0) {
        state.use_asm_backend = 1;
      }
      i = i + 2;
      continue;
    }
    if (eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {
      let tlen: i32 = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
      if (tlen >= 0 && target_contains_arm(arg_buf, tlen) != 0) {
        state.target_arch = 1;
      }
      if (tlen >= 0 && target_contains_riscv(arg_buf, tlen) != 0) {
        state.target_arch = 2;
      }
      i = i + 2;
      continue;
    }
    if (eq_minus_x(arg_buf, len) != 0) {
      i = i + 1;
      continue;
    }
    if (eq_minus_E(arg_buf, len) != 0) {
      let pi: i32 = i + 1;
      while (pi < argc) {
        let plen_temp: i32 = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
        if (plen_temp > 0 && eq_minus_L(arg_buf, plen_temp) != 0 && pi + 1 < argc) {
          driver_emit_try_append_lib_from_argv(argc, argv, pi + 1, state);
          pi = pi + 2;
          continue;
        }
        if (plen_temp > 0 && eq_minus_x(arg_buf, plen_temp) != 0) {
          pi = pi + 1;
          continue;
        }
        break;
      }
      if (pi < argc) {
        let opt_len: i32 = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
        if (opt_len >= 0 && eq_minus_E_extern(arg_buf, opt_len) != 0) {
          state.emit_extern_imports = 1;
          pi = pi + 1;
        }
      }
      if (pi < argc) {
        let plen: i32 = driver_get_argv_i(argc, argv, pi, state.path_buf, 512);
        if (plen >= 0) {
          state.path_len = plen;
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function driver_run_x_emit_x(state: *DriverXEmitState): i32 {
  if (state.path_len >= 0 && state.path_len < 511) {
    state.path_buf[state.path_len] = 0 as u8;
  }
  let loaded_buf: u8[4194304] = [];
  let cap_i: i32 = 4194304;
  let n: i32 = sys.read_file_into(&state.path_buf[0], &loaded_buf[0], cap_i);
  if (n < 0) {
    return 1;
  }
  let preprocess_buf: u8[4194304] = [];
  let out_len: i32 = preprocess_x_buf(&loaded_buf[0], n, &preprocess_buf[0], 4194304);
  if (out_len < 0) {
    return 1;
  }
  /* See implementation. */
  let arena_buf: *u8 = driver_arena_buf();
  let module_buf: *u8 = driver_module_buf();
  let ctx: PipelineDepCtx = pipeline_dep_ctx_for_emit(state.use_asm_backend, state.target_arch);
  let last_slash: i32 = -1;
  let k: i32 = 0;
  while (k < state.path_len && k < 512) {
    if (state.path_buf[k] == 47) {
      last_slash = k;
    }
    k = k + 1;
  }
  if (last_slash >= 0) {
    k = 0;
    while (k < last_slash && k < 511) {
      ctx.entry_dir_buf[k] = state.path_buf[k];
      k = k + 1;
    }
    ctx.entry_dir_buf[k] = 0;
    ctx.entry_dir_len = k;
  } else {
    ctx.entry_dir_buf[0] = 46;
    ctx.entry_dir_buf[1] = 0;
    ctx.entry_dir_len = 1;
  }
  ctx.num_lib_roots = 0;
  driver_emit_copy_lib_roots_to_ctx(state, &ctx);
  let out: CodegenOutBuf = CodegenOutBuf { data: [], len: 0 };
  let source_len: usize = out_len as usize;
  let rc: i32 = pipeline_run_x_pipeline_impl(module_buf, arena_buf, preprocess_buf, source_len, &out, &ctx);
  if (rc != 0) {
    driver_pipeline_fail_code(rc, &ctx.path_buf[0]);
    return 1;
  }
  /* See implementation. */
  let len: i32 = out.len;
  if (state.out_path_len == 0) {
    driver_print_x_smoke_summary(module_buf, len as usize);
  }
  if (state.out_path_len > 0) {
    let fd: i32 = driver_fs_open_write(state.out_path_buf, state.out_path_len);
    if (fd < 0) {
      return 1;
    }
    if (len > 262144) {
      let written: isize = fs_posix_write_c(fd, out.data, 262144);
      fs_posix_close_c(fd);
      if (written < 0 || (written as i32) != 262144) {
        return 1;
      }
    } else {
      let written: isize = fs_posix_write_c(fd, out.data, len as usize);
      fs_posix_close_c(fd);
      if (written < 0 || (written as i32) != len) {
        return 1;
      }
    }
  } else {
    if (len > 262144) {
      let written: isize = fs_posix_write_c(1, out.data, 262144);
      if (written < 0 || (written as i32) != 262144) {
        return 1;
      }
    } else {
      let written: isize = fs_posix_write_c(1, out.data, len as usize);
      if (written < 0 || (written as i32) != len) {
        return 1;
      }
    }
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function main_run_compiler_x_path_impl(argc: i32, argv: *u8): i32 {
  let state: DriverXEmitState = driver_emit_state_default();
  let r: i32 = driver_argv_parse_x_path(argc, argv, &state);
  if (r == 1) {
    return run_compiler_c_impl(argc, argv);
  }
  if (r == 2) {
    return run_compiler_c_impl(argc, argv);
  }
  if (state.use_asm_backend != 0) {
    return run_compiler_c_impl(argc, argv);
  }
  /*
   * See implementation.
   * See implementation.
   * See implementation.
   * See implementation.
   */
  if (state.out_path_len > 0) {
    return run_compiler_c_impl(argc, argv);
  }
  return driver_run_x_emit_x(&state);
}

/**
 * See implementation.
 */
export function main_cmd_build(argc: i32, argv: *u8): i32 {
  if (argc < 2) {
    return driver_build_build_x();
  }
  return main_run_compiler_x_path_impl(argc, argv);
}

/**
 * See implementation.
 */
export function main_cmd_run(argc: i32, argv: *u8): i32 {
  if (argc < 2) {
    return 1;
  }
  let rc: i32 = main_run_compiler_x_path_impl(argc, argv);
  if (rc == 0) {
    return driver_exec_compiled(argc, argv);
  }
  return rc;
}

/* See implementation. */
export extern function typeck_lsp_main(): i32;

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function entry(argc: i32, argv: *u8): i32 {
  let arg_buf: u8[64] = [];
  let i: i32 = 1;
  while (i < argc) {
    let len: i32 = driver_get_argv_i(argc, argv, i, arg_buf, 64);
    if (len >= 0 && eq_minus_lsp(arg_buf, len) != 0) {
      return typeck_lsp_main();
    }
    i = i + 1;
  }
  /* See implementation. */
  if (argc >= 2) {
    let alen: i32 = driver_get_argv_i(argc, argv, 1, arg_buf, 64);
    if (alen > 0 && arg_buf[0] != 45) {
      let w_build: u8[5] = [98, 117, 105, 108, 100];
      let w_run: u8[3] = [114, 117, 110];
      let w_fmt: u8[3] = [102, 109, 116];
      let w_check: u8[5] = [99, 104, 101, 99, 107];
      let w_test: u8[4] = [116, 101, 115, 116];
      if (str_eq(&arg_buf[0], alen, &w_build[0], 5) != 0) {
        return main_cmd_build(argc - 1, driver_argv_drop_subcommand(argc, argv));
      }
      if (str_eq(&arg_buf[0], alen, &w_run[0], 3) != 0) {
        return main_cmd_run(argc - 1, driver_argv_drop_subcommand(argc, argv));
      }
      if (str_eq(&arg_buf[0], alen, &w_fmt[0], 3) != 0) {
        return driver_cmd_fmt(argc - 1, driver_argv_drop_subcommand(argc, argv));
      }
      if (str_eq(&arg_buf[0], alen, &w_check[0], 5) != 0) {
        return driver_cmd_check(argc - 1, driver_argv_drop_subcommand(argc, argv));
      }
      if (str_eq(&arg_buf[0], alen, &w_test[0], 4) != 0) {
        return driver_cmd_test(argc - 1, driver_argv_drop_subcommand(argc, argv));
      }
    }
  }
  let state: DriverXEmitState = driver_emit_state_default();
  if (driver_argv_parse_x(argc, argv, &state) != 0) {
    /* See implementation. */
    /* See implementation. */
    driver_run_x_emit_c_set_emit_extern(state.emit_extern_imports);
    driver_run_x_emit_c_set_path(state.path_buf, state.path_len);
    let k: i32 = 0;
    let n_roots: i32 = driver_emit_lib_root_count(driver_emit_state_key(&state));
    let lib_tmp: u8[256] = [];
    while (k < n_roots) {
      let llen: i32 = driver_emit_lib_root_len(driver_emit_state_key(&state), k);
      driver_emit_lib_root_copy(driver_emit_state_key(&state), k, &lib_tmp[0], 256);
      driver_run_x_emit_c_set_lib(k, &lib_tmp[0], llen);
      k = k + 1;
    }
    driver_run_x_emit_c_set_n_lib_roots(n_roots);
    return driver_run_x_emit_c();
  }
  /* See implementation. */
  return main_run_compiler_x_path_impl(argc, argv);
}
