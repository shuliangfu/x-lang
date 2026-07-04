#!/usr/bin/env bash
# 文件职责：按需构建 std 下由 C 实现的 .o，供 asm/-o 链接解析 mod.x 中的 extern（如 std.csv.next_field）。
# bootstrap-driver-seed 仅链 io/fs/heap，不构建全量 STD_AND_PANIC_O；依赖本脚本的 run-*.sh 须先 ensure。
# 用法：. "$(dirname "$0")/lib/build-std-c-o.sh" && ensure_std_c_o ../std/csv/csv.o

# 探测本机是否可链 libsqlite3（与 tests/lib/std-sqlite-gate.sh 一致）。
_std_c_o_probe_sqlite3() {
  local out="/tmp/shux_sqlite_probe_$$"
  if ! cc -std=c11 -x c - -lsqlite3 -o "$out" 2>/dev/null <<'EOF'
#include <sqlite3.h>
int main(void) { return sqlite3_libversion() ? 0 : 1; }
EOF
  then
    rm -f "$out"
    return 1
  fi
  rm -f "$out"
  return 0
}

# F-07 v1：已迁移为纯 .x 的 std 模块禁止经 cc -c 构建 .o（须 shux -backend asm）。
_std_c_o_forbidden_migrated() {
  local repo_rel="$1"
  case "$repo_rel" in
    std/io/io.o|std/fs/fs.o|std/heap/heap.o|std/compress/compress.o|\
    std/compress/zlib/zlib.o|std/compress/gzip/gzip.o|\
    std/compress/brotli/brotli.o|std/compress/zstd/zstd.o|\
    std/net/net.c|std/path/path.c|std/uuid/uuid.c|std/sort/sort.c|\
    std/process/process.c|std/random/random.c|std/time/time.c|std/math/math.c|\
    std/base64/base64.c|std/string/string.c|std/encoding/encoding.c|\
    std/runtime/runtime.c|std/cli/cli.c|std/ffi/ffi.c|std/env/env.c|\
    std/log/log.c|std/simd/simd.c|\
    std/security/security.c|std/context/context.c|std/trace/trace.c|std/sync/sync.c|\
    std/task/task.c|std/csv/csv.c|std/json/json.c|std/regex/regex.c|std/unicode/unicode.c|std/hash/hash.c|std/dynlib/dynlib.c|std/backtrace/backtrace.c|std/http/http.c|std/tar/tar.c|std/channel/channel.c|std/atomic/atomic.c|std/thread/thread.c|std/queue/queue.c|std/crypto/crypto.c|std/async/scheduler.c|std/async/future.c|std/cache/cache.c|std/config/config.c|std/datetime/datetime.c|std/elf/elf.c|std/test/test.c|std/url/url.c|std/schema/schema.c|std/socketio/socketio.c)
      echo "ensure_std_c_o FORBIDDEN (F-07 v1/v2): $repo_rel is pure .x / deleted — use shux -backend asm, not cc -c" >&2
      return 0
      ;;
  esac
  return 1
}

ensure_std_c_o() {
  local rel="$1"
  if [ -z "$rel" ]; then
    echo "ensure_std_c_o: missing path (e.g. ../std/csv/csv.o)" >&2
    return 1
  fi
  # make -C compiler 使用 compiler/ 为 cwd 的相对路径；gate 从仓库根 source 时传入 ../std/...。
  local make_rel="$rel"
  local repo_rel="$rel"
  case "$rel" in
    ../std/*) repo_rel="${rel#../}" ;;
  esac
  if _std_c_o_forbidden_migrated "$repo_rel"; then
    return 1
  fi
  # STD-139 stub 会覆盖 std/db/sqlite/sqlite.o；后续 gate 须恢复 SQLite3 后端。
  case "$repo_rel" in
    std/db/sqlite/sqlite.o)
      make_rel="../std/db/sqlite/sqlite.o"
      if [ -f "$repo_rel" ] && strings "$repo_rel" 2>/dev/null | grep -qF 'stub backend'; then
        rm -f "$repo_rel"
      fi
      if ! _std_c_o_probe_sqlite3; then
        make -C compiler sqlite-o-stub >/dev/null 2>&1 || {
          echo "ensure_std_c_o FAIL: sqlite-o-stub (no libsqlite3)" >&2
          return 1
        }
        return 0
      fi
      ;;
  esac
  make -C compiler -q "$make_rel" 2>/dev/null || make -C compiler "$make_rel"
}

# F-ZC：确保 runtime_time_os.o 存在；C 烟测链 time.o 时须一并链接。
ensure_runtime_time_os_o() {
  make -C compiler -q runtime_time_os.o 2>/dev/null || make -C compiler runtime_time_os.o
}

# F-ZC：确保 runtime_random_fill.o 存在；C 烟测链 random.o 时须一并链接。
ensure_runtime_random_fill_o() {
  make -C compiler -q runtime_random_fill.o 2>/dev/null || make -C compiler runtime_random_fill.o
}

# F-ZC：确保 runtime_dynlib_os.o 存在；C 烟测链 dynlib.o 时须一并链接。
ensure_runtime_dynlib_os_o() {
  make -C compiler -q runtime_dynlib_os.o 2>/dev/null || make -C compiler runtime_dynlib_os.o
}

# F-ZC：确保 runtime_env_os.o 存在；C 烟测链 env.o 时须一并链接。
ensure_runtime_env_os_o() {
  make -C compiler -q runtime_env_os.o 2>/dev/null || make -C compiler runtime_env_os.o
}

# F-ZC：确保 runtime_queue_contention.o 存在；C 烟测链 queue.o 时须一并链接。
ensure_runtime_queue_contention_o() {
  make -C compiler -q runtime_queue_contention.o 2>/dev/null || make -C compiler runtime_queue_contention.o
}

# F-ZC：确保 runtime_backtrace_platform.o 存在；C 烟测链 backtrace.o 时须一并链接。
ensure_runtime_backtrace_platform_o() {
  make -C compiler -q runtime_backtrace_platform.o 2>/dev/null || make -C compiler runtime_backtrace_platform.o
}

# F-ZC：确保 runtime_log_os.o 存在；C 烟测链 log.o 时须一并链接。
ensure_runtime_log_os_o() {
  make -C compiler -q runtime_log_os.o 2>/dev/null || make -C compiler runtime_log_os.o
}

# F-ZC：确保 runtime_math_libm.o 存在；C 烟测链 math.o 时须一并链接。
ensure_runtime_math_libm_o() {
  make -C compiler -q runtime_math_libm.o 2>/dev/null || make -C compiler runtime_math_libm.o
}

# F-ZC：确保 runtime_atomic_glue.o 存在；C 烟测链 atomic.o 时须一并链接。
ensure_runtime_atomic_glue_o() {
  make -C compiler -q runtime_atomic_glue.o 2>/dev/null || make -C compiler runtime_atomic_glue.o
}

# F-ZC：确保 runtime_channel_glue.o 存在；C 烟测链 channel.o 时须一并链接。
ensure_runtime_channel_glue_o() {
  make -C compiler -q runtime_channel_glue.o 2>/dev/null || make -C compiler runtime_channel_glue.o
}

# F-ZC：确保 runtime_net_udp_batch.o / runtime_net_workers.o 存在；链 net.o 时须一并链接。
ensure_runtime_net_udp_batch_o() {
  make -C compiler -q runtime_net_udp_batch.o 2>/dev/null || make -C compiler runtime_net_udp_batch.o
}

ensure_runtime_net_workers_o() {
  make -C compiler -q runtime_net_workers.o 2>/dev/null || make -C compiler runtime_net_workers.o
}

# F-ZC：asm -o 最小链 / net gcc 回退须 runtime_asm_io_stubs.o、runtime_panic.o、runtime_process_argv.o。
ensure_runtime_asm_io_stubs_o() {
  make -C compiler -q runtime_asm_io_stubs.o 2>/dev/null || make -C compiler runtime_asm_io_stubs.o
}

ensure_runtime_panic_o() {
  make -C compiler -q runtime_panic.o 2>/dev/null || make -C compiler runtime_panic.o
}

ensure_runtime_process_argv_o() {
  make -C compiler -q runtime_process_argv.o 2>/dev/null || make -C compiler runtime_process_argv.o
}

# F-ZC：确保 runtime_sync_os.o / runtime_sync_lock_diag_tls.o；链 sync.o 时须一并链接。
ensure_runtime_sync_os_o() {
  make -C compiler -q runtime_sync_os.o 2>/dev/null || make -C compiler runtime_sync_os.o
}

ensure_runtime_sync_lock_diag_tls_o() {
  make -C compiler -q runtime_sync_lock_diag_tls.o 2>/dev/null || make -C compiler runtime_sync_lock_diag_tls.o
}

ensure_runtime_thread_glue_o() {
  make -C compiler -q runtime_thread_glue.o 2>/dev/null || make -C compiler runtime_thread_glue.o
}

# F-ZC：确保 runtime_process_os_glue.o；链 process.o 时须一并链接。
ensure_runtime_process_os_glue_o() {
  make -C compiler -q runtime_process_os_glue.o 2>/dev/null || make -C compiler runtime_process_os_glue.o
}

ensure_runtime_scheduler_glue_o() {
  make -C compiler -q runtime_scheduler_glue.o 2>/dev/null || make -C compiler runtime_scheduler_glue.o
}

ensure_runtime_http_glue_o() {
  make -C compiler -q runtime_http_glue.o 2>/dev/null || make -C compiler runtime_http_glue.o
}

ensure_runtime_kv_mmap_glue_o() {
  make -C compiler -q runtime_kv_mmap_glue.o 2>/dev/null || make -C compiler runtime_kv_mmap_glue.o
}

ensure_runtime_arrow_simd_glue_o() {
  make -C compiler -q runtime_arrow_simd_glue.o 2>/dev/null || make -C compiler runtime_arrow_simd_glue.o
}

ensure_runtime_sqlite_glue_o() {
  make -C compiler -q runtime_sqlite_glue.o 2>/dev/null || make -C compiler runtime_sqlite_glue.o
}

ensure_runtime_crypto_inc_glue_o() {
  make -C compiler -q runtime_crypto_inc_glue.o 2>/dev/null || make -C compiler runtime_crypto_inc_glue.o
}

ensure_runtime_ed25519_ref10_glue_o() {
  make -C compiler -q runtime_ed25519_ref10_glue.o 2>/dev/null || make -C compiler runtime_ed25519_ref10_glue.o
}

ensure_runtime_tls_mbedtls_bio_o() {
  make -C compiler -q runtime_tls_mbedtls_bio.o 2>/dev/null || make -C compiler runtime_tls_mbedtls_bio.o
}
