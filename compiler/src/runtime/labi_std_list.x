// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-271 / P2 link_abi L8：默认 std 链接计划表（纯数据）→ R2 full。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_std_list.from_x.c。
// hybrid 宏 SHUX_LABI_STD_LIST_FROM_X；FROM_X rest 仅 marker（H=0）。
//
// R2 full：真迁 if/else + let 绑定短字符串（依赖 W-string-nul；无全局表）。
// 禁止「函数体仅 return "lit"」——parser 会 skip 整函数；用 let p + return p。
// plan_step_at 的 const char** out：.x 用 *usize 写指针值（与 C 指针 ABI 同宽）。
// IO/ensure/push 仍在 mega 解释器 shux_asm_ld_append_std_objs（🔒）。
//
// Ops：STD=1 IO_STUBS=2 PRIMARY_PANIC=3 TIME_OS=4 RANDOM_FILL=5 ENV_OS=6
// GLUE_THREAD=10 SYNC=11 CRYPTO=12 LOG=13 ATOMIC=14 CHANNEL=15 BACKTRACE=16
// MATH=17 SQLITE=18 DYNLIB=19 HTTP=20 TASK_SPECIAL=30

/** Return the number of default std link plan steps (must match step_at cases).
 * PLATFORM: SHARED — pure table; seed labi_std_list.from_x.c must stay in sync. */
#[no_mangle]
export function labi_std_plan_count(): i32 {
  return 60;
}

/** Fill one plan step: op / rel path / flag_kind. Returns 1 if i is in range.
 * out: C int* / const char** / int*; .x writes via *i32 + *usize + *i32.
 * PLATFORM: SHARED — includes std/vec + std/fs (fk0) formal; task remains last. */
#[no_mangle]
export function labi_std_plan_step_at(
  i: i32, op_out: *i32, rel_out: *usize, flag_kind_out: *i32
): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 60) {
    return 0;
  }
  if (i == 0) {
    if (op_out != 0 as *i32) {
      op_out[0] = 2;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_asm_io_stubs.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 1) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/process/process.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 1;
    }
    return 1;
  }
  if (i == 2) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/string/string.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 3) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/path/path.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 4) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/runtime/runtime.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 5) {
    if (op_out != 0 as *i32) {
      op_out[0] = 3;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_panic.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 6) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/thread/thread.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 2;
    }
    return 1;
  }
  if (i == 7) {
    if (op_out != 0 as *i32) {
      op_out[0] = 10;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_thread_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 8) {
    if (op_out != 0 as *i32) {
      op_out[0] = 4;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_time_os.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 9) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/time/time.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 10) {
    if (op_out != 0 as *i32) {
      op_out[0] = 5;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_random_fill.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 11) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/random/random.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 12) {
    if (op_out != 0 as *i32) {
      op_out[0] = 6;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_env_os.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 13) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/env/env.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 14) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/sync/sync.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 3;
    }
    return 1;
  }
  if (i == 15) {
    if (op_out != 0 as *i32) {
      op_out[0] = 11;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_sync_lock_diag_tls.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 16) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/encoding/encoding.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 17) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/base64/base64.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 18) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/crypto/crypto.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 4;
    }
    return 1;
  }
  if (i == 19) {
    if (op_out != 0 as *i32) {
      op_out[0] = 12;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_ed25519_ref10_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 20) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/log/log.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 5;
    }
    return 1;
  }
  if (i == 21) {
    if (op_out != 0 as *i32) {
      op_out[0] = 13;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_log_os.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 22) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/atomic/atomic.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 6;
    }
    return 1;
  }
  if (i == 23) {
    if (op_out != 0 as *i32) {
      op_out[0] = 14;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_atomic_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 24) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/channel/channel.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 7;
    }
    return 1;
  }
  if (i == 25) {
    if (op_out != 0 as *i32) {
      op_out[0] = 15;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_channel_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 26) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/backtrace/backtrace.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 8;
    }
    return 1;
  }
  if (i == 27) {
    if (op_out != 0 as *i32) {
      op_out[0] = 16;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_backtrace_platform.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 28) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/hash/hash.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 29) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/math/math.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 9;
    }
    return 1;
  }
  if (i == 30) {
    if (op_out != 0 as *i32) {
      op_out[0] = 17;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_math_libm.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 31) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/sort/sort.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 32) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/ffi/ffi.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 33) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/db/sqlite/sqlite.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 10;
    }
    return 1;
  }
  if (i == 34) {
    if (op_out != 0 as *i32) {
      op_out[0] = 18;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_sqlite_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 35) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/elf/elf.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 11;
    }
    return 1;
  }
  if (i == 36) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/json/json.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 37) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/csv/csv.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 38) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/regex/regex.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 39) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/unicode/unicode.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 40) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/dynlib/dynlib.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 12;
    }
    return 1;
  }
  if (i == 41) {
    if (op_out != 0 as *i32) {
      op_out[0] = 19;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_dynlib_os.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 42) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/http/http.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 13;
    }
    return 1;
  }
  if (i == 43) {
    if (op_out != 0 as *i32) {
      op_out[0] = 20;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "compiler/runtime_http_glue.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 44) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/socketio/socketio.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 45) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/tar/tar.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 46) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/simd/simd.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 47) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/context/context.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 48) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/error/error.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 49) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/datetime/datetime.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 50) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/uuid/uuid.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 51) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/url/url.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 52) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/cli/cli.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 53) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/security/security.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 54) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/config/config.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 55) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/cache/cache.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 56) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/trace/trace.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  // PLATFORM: SHARED — std.vec link_only product .o; fk0 UNDEF gate in mega.
  if (i == 57) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/vec/vec.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  /* PLATFORM: SHARED — formal fs.o (mod.x+posix.x); asm skips std.fs co-emit; fk0 gated. */
  if (i == 58) {
    if (op_out != 0 as *i32) {
      op_out[0] = 1;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/fs/fs.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  if (i == 59) {
    if (op_out != 0 as *i32) {
      op_out[0] = 30;
    }
    if (rel_out != 0 as *usize) {
      let p: *u8 = "std/task/task.o";
      rel_out[0] = p as usize;
    }
    if (flag_kind_out != 0 as *i32) {
      flag_kind_out[0] = 0;
    }
    return 1;
  }
  return 0;
}

/** Pure: count of OP_STD entries with std/ prefix (audit / unit).
 * PLATFORM: SHARED — includes std/vec/vec.o + std/fs/fs.o. */
#[no_mangle]
export function labi_std_default_std_rel_count(): i32 {
  return 43;
}

#[no_mangle]
export function labi_std_default_std_rel_at(j: i32): *u8 {
  if (j < 0) {
    return 0 as *u8;
  }
  if (j == 0) {
    let p: *u8 = "std/process/process.o";
    return p;
  }
  if (j == 1) {
    let p: *u8 = "std/string/string.o";
    return p;
  }
  if (j == 2) {
    let p: *u8 = "std/path/path.o";
    return p;
  }
  if (j == 3) {
    let p: *u8 = "std/runtime/runtime.o";
    return p;
  }
  if (j == 4) {
    let p: *u8 = "std/thread/thread.o";
    return p;
  }
  if (j == 5) {
    let p: *u8 = "std/time/time.o";
    return p;
  }
  if (j == 6) {
    let p: *u8 = "std/random/random.o";
    return p;
  }
  if (j == 7) {
    let p: *u8 = "std/env/env.o";
    return p;
  }
  if (j == 8) {
    let p: *u8 = "std/sync/sync.o";
    return p;
  }
  if (j == 9) {
    let p: *u8 = "std/encoding/encoding.o";
    return p;
  }
  if (j == 10) {
    let p: *u8 = "std/base64/base64.o";
    return p;
  }
  if (j == 11) {
    let p: *u8 = "std/crypto/crypto.o";
    return p;
  }
  if (j == 12) {
    let p: *u8 = "std/log/log.o";
    return p;
  }
  if (j == 13) {
    let p: *u8 = "std/atomic/atomic.o";
    return p;
  }
  if (j == 14) {
    let p: *u8 = "std/channel/channel.o";
    return p;
  }
  if (j == 15) {
    let p: *u8 = "std/backtrace/backtrace.o";
    return p;
  }
  if (j == 16) {
    let p: *u8 = "std/hash/hash.o";
    return p;
  }
  if (j == 17) {
    let p: *u8 = "std/math/math.o";
    return p;
  }
  if (j == 18) {
    let p: *u8 = "std/sort/sort.o";
    return p;
  }
  if (j == 19) {
    let p: *u8 = "std/ffi/ffi.o";
    return p;
  }
  if (j == 20) {
    let p: *u8 = "std/db/sqlite/sqlite.o";
    return p;
  }
  if (j == 21) {
    let p: *u8 = "std/elf/elf.o";
    return p;
  }
  if (j == 22) {
    let p: *u8 = "std/json/json.o";
    return p;
  }
  if (j == 23) {
    let p: *u8 = "std/csv/csv.o";
    return p;
  }
  if (j == 24) {
    let p: *u8 = "std/regex/regex.o";
    return p;
  }
  if (j == 25) {
    let p: *u8 = "std/unicode/unicode.o";
    return p;
  }
  if (j == 26) {
    let p: *u8 = "std/dynlib/dynlib.o";
    return p;
  }
  if (j == 27) {
    let p: *u8 = "std/http/http.o";
    return p;
  }
  if (j == 28) {
    let p: *u8 = "std/socketio/socketio.o";
    return p;
  }
  if (j == 29) {
    let p: *u8 = "std/tar/tar.o";
    return p;
  }
  if (j == 30) {
    let p: *u8 = "std/simd/simd.o";
    return p;
  }
  if (j == 31) {
    let p: *u8 = "std/context/context.o";
    return p;
  }
  if (j == 32) {
    let p: *u8 = "std/error/error.o";
    return p;
  }
  if (j == 33) {
    let p: *u8 = "std/datetime/datetime.o";
    return p;
  }
  if (j == 34) {
    let p: *u8 = "std/uuid/uuid.o";
    return p;
  }
  if (j == 35) {
    let p: *u8 = "std/url/url.o";
    return p;
  }
  if (j == 36) {
    let p: *u8 = "std/cli/cli.o";
    return p;
  }
  if (j == 37) {
    let p: *u8 = "std/security/security.o";
    return p;
  }
  if (j == 38) {
    let p: *u8 = "std/config/config.o";
    return p;
  }
  if (j == 39) {
    let p: *u8 = "std/cache/cache.o";
    return p;
  }
  if (j == 40) {
    let p: *u8 = "std/trace/trace.o";
    return p;
  }
  if (j == 41) {
    let p: *u8 = "std/vec/vec.o";
    return p;
  }
  if (j == 42) {
    let p: *u8 = "std/fs/fs.o";
    return p;
  }
  return 0 as *u8;
}

