/* seeds/labi_std_list.from_x.c — G-02f-271 P2 link_abi L8 std list pure
 * Logic source: src/runtime/labi_std_list.x
 * Hybrid: SHUX_LABI_STD_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: default ASM ld std module .o plan (order + flag kind + op).
 * IO/ensure/push stay in mega interpreter (shux_asm_ld_append_std_objs).
 */
#include <stddef.h>

/* Ops — keep in sync with mega interpreter in runtime_link_abi.from_x.c */
enum {
  LABI_STD_OP_STD = 1,
  LABI_STD_OP_IO_STUBS = 2,
  LABI_STD_OP_PRIMARY_PANIC = 3,
  LABI_STD_OP_PRIMARY_TIME_OS = 4,
  LABI_STD_OP_PRIMARY_RANDOM_FILL = 5,
  LABI_STD_OP_PRIMARY_ENV_OS = 6,
  LABI_STD_OP_GLUE_THREAD = 10,
  LABI_STD_OP_GLUE_SYNC_PAIR = 11,
  LABI_STD_OP_GLUE_CRYPTO_PAIR = 12,
  LABI_STD_OP_GLUE_LOG = 13,
  LABI_STD_OP_GLUE_ATOMIC = 14,
  LABI_STD_OP_GLUE_CHANNEL = 15,
  LABI_STD_OP_GLUE_BACKTRACE = 16,
  LABI_STD_OP_GLUE_MATH = 17,
  LABI_STD_OP_GLUE_SQLITE = 18,
  LABI_STD_OP_GLUE_DYNLIB = 19,
  LABI_STD_OP_GLUE_HTTP = 20,
  LABI_STD_OP_TASK_SPECIAL = 30
};

/* flag_kind for OP_STD:
 * 0 none
 * 1 have_process (local)
 * 2 have_thread
 * 3 have_sync
 * 4 have_crypto (local)
 * 5 have_log (local)
 * 6 have_atomic (local)
 * 7 have_channel
 * 8 have_backtrace (local)
 * 9 have_math
 * 10 have_sqlite
 * 11 have_elf
 * 12 have_dynlib
 * 13 have_http (local)
 */
typedef struct LabiStdPlanStep {
  int op;
  const char *rel;
  int flag_kind;
} LabiStdPlanStep;

static const LabiStdPlanStep g_labi_std_plan[] = {
    {LABI_STD_OP_IO_STUBS, "compiler/runtime_asm_io_stubs.o", 0},
    {LABI_STD_OP_STD, "std/process/process.o", 1},
    {LABI_STD_OP_STD, "std/string/string.o", 0},
    {LABI_STD_OP_STD, "std/path/path.o", 0},
    {LABI_STD_OP_STD, "std/runtime/runtime.o", 0},
    {LABI_STD_OP_PRIMARY_PANIC, "compiler/runtime_panic.o", 0},
    {LABI_STD_OP_STD, "std/thread/thread.o", 2},
    {LABI_STD_OP_GLUE_THREAD, "compiler/runtime_thread_glue.o", 0},
    {LABI_STD_OP_PRIMARY_TIME_OS, "compiler/runtime_time_os.o", 0},
    {LABI_STD_OP_STD, "std/time/time.o", 0},
    {LABI_STD_OP_PRIMARY_RANDOM_FILL, "compiler/runtime_random_fill.o", 0},
    {LABI_STD_OP_STD, "std/random/random.o", 0},
    {LABI_STD_OP_PRIMARY_ENV_OS, "compiler/runtime_env_os.o", 0},
    {LABI_STD_OP_STD, "std/env/env.o", 0},
    {LABI_STD_OP_STD, "std/sync/sync.o", 3},
    {LABI_STD_OP_GLUE_SYNC_PAIR, "compiler/runtime_sync_lock_diag_tls.o", 0},
    {LABI_STD_OP_STD, "std/encoding/encoding.o", 0},
    {LABI_STD_OP_STD, "std/base64/base64.o", 0},
    {LABI_STD_OP_STD, "std/crypto/crypto.o", 4},
    {LABI_STD_OP_GLUE_CRYPTO_PAIR, "compiler/runtime_ed25519_ref10_glue.o", 0},
    {LABI_STD_OP_STD, "std/log/log.o", 5},
    {LABI_STD_OP_GLUE_LOG, "compiler/runtime_log_os.o", 0},
    {LABI_STD_OP_STD, "std/atomic/atomic.o", 6},
    {LABI_STD_OP_GLUE_ATOMIC, "compiler/runtime_atomic_glue.o", 0},
    {LABI_STD_OP_STD, "std/channel/channel.o", 7},
    {LABI_STD_OP_GLUE_CHANNEL, "compiler/runtime_channel_glue.o", 0},
    {LABI_STD_OP_STD, "std/backtrace/backtrace.o", 8},
    {LABI_STD_OP_GLUE_BACKTRACE, "compiler/runtime_backtrace_platform.o", 0},
    {LABI_STD_OP_STD, "std/hash/hash.o", 0},
    {LABI_STD_OP_STD, "std/math/math.o", 9},
    {LABI_STD_OP_GLUE_MATH, "compiler/runtime_math_libm.o", 0},
    {LABI_STD_OP_STD, "std/sort/sort.o", 0},
    {LABI_STD_OP_STD, "std/ffi/ffi.o", 0},
    {LABI_STD_OP_STD, "std/db/sqlite/sqlite.o", 10},
    {LABI_STD_OP_GLUE_SQLITE, "compiler/runtime_sqlite_glue.o", 0},
    {LABI_STD_OP_STD, "std/elf/elf.o", 11},
    {LABI_STD_OP_STD, "std/json/json.o", 0},
    {LABI_STD_OP_STD, "std/csv/csv.o", 0},
    {LABI_STD_OP_STD, "std/regex/regex.o", 0},
    {LABI_STD_OP_STD, "std/unicode/unicode.o", 0},
    {LABI_STD_OP_STD, "std/dynlib/dynlib.o", 12},
    {LABI_STD_OP_GLUE_DYNLIB, "compiler/runtime_dynlib_os.o", 0},
    {LABI_STD_OP_STD, "std/http/http.o", 13},
    {LABI_STD_OP_GLUE_HTTP, "compiler/runtime_http_glue.o", 0},
    {LABI_STD_OP_STD, "std/socketio/socketio.o", 0},
    {LABI_STD_OP_STD, "std/tar/tar.o", 0},
    {LABI_STD_OP_STD, "std/simd/simd.o", 0},
    {LABI_STD_OP_STD, "std/context/context.o", 0},
    {LABI_STD_OP_STD, "std/error/error.o", 0},
    {LABI_STD_OP_STD, "std/datetime/datetime.o", 0},
    {LABI_STD_OP_STD, "std/uuid/uuid.o", 0},
    {LABI_STD_OP_STD, "std/url/url.o", 0},
    {LABI_STD_OP_STD, "std/cli/cli.o", 0},
    {LABI_STD_OP_STD, "std/security/security.o", 0},
    {LABI_STD_OP_STD, "std/config/config.o", 0},
    {LABI_STD_OP_STD, "std/cache/cache.o", 0},
    {LABI_STD_OP_STD, "std/trace/trace.o", 0},
    {LABI_STD_OP_TASK_SPECIAL, "std/task/task.o", 0},
};

int labi_std_plan_count(void) {
  return (int)(sizeof g_labi_std_plan / sizeof g_labi_std_plan[0]);
}

int labi_std_plan_step_at(int i, int *op_out, const char **rel_out, int *flag_kind_out) {
  int n = labi_std_plan_count();
  if (i < 0 || i >= n)
    return 0;
  if (op_out)
    *op_out = g_labi_std_plan[i].op;
  if (rel_out)
    *rel_out = g_labi_std_plan[i].rel;
  if (flag_kind_out)
    *flag_kind_out = g_labi_std_plan[i].flag_kind;
  return 1;
}

/* Pure: count of OP_STD entries with std/ prefix (audit / unit). */
int labi_std_default_std_rel_count(void) {
  int n = labi_std_plan_count();
  int i;
  int c = 0;
  for (i = 0; i < n; i++) {
    if (g_labi_std_plan[i].op == LABI_STD_OP_STD)
      c = c + 1;
  }
  return c;
}

const char *labi_std_default_std_rel_at(int j) {
  int n = labi_std_plan_count();
  int i;
  int c = 0;
  if (j < 0)
    return NULL;
  for (i = 0; i < n; i++) {
    if (g_labi_std_plan[i].op != LABI_STD_OP_STD)
      continue;
    if (c == j)
      return g_labi_std_plan[i].rel;
    c = c + 1;
  }
  return NULL;
}
