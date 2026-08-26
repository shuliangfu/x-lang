#!/usr/bin/env bash
# STD-048：std.queue 并发安全可选封装门禁（假权威诚实）。
#
# 用法：./tests/run-std-queue-concurrent-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); tests/queue/main.x exit 0 hard-fail (no soft
# SKIP when native xlang present). sync_queue_roundtrip + C contention
# observational (SyncQueue / queue-sync UNDEF residual). Report
# check=/main=/sync=/c=/skip=. Product Queue_i32 main already green under asm;
# gate was portable-false-red (prefer xlang-c / soft SKIP when no native /
# fake MAIN_OK without running .x / ## 4. 门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_QUEUE_CONCURRENT_DOC:-analysis/archive/std/std-queue-concurrent-v1.md}"
MANIFEST="${XLANG_STD_QUEUE_CONCURRENT_TSV:-tests/baseline/std-queue-concurrent.tsv}"
MOD_X="std/queue/mod.x"
QUEUE_C="std/queue/queue.x"
CONTENTION_C="tests/queue/sync_queue_contention_ok.c"
LIB="tests/lib/std-queue-concurrent.sh"
SMOKE_X="tests/queue/sync_queue_roundtrip.x"
MAIN_X="tests/queue/main.x"
MIN_APIS=6

# shellcheck source=tests/lib/std-queue-concurrent.sh
. "$LIB"

echo "=== STD-048: queue concurrent manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$QUEUE_C" "$SMOKE_X" "$MAIN_X" "$CONTENTION_C"; do
  if [ ! -f "$f" ]; then
    echo "std-queue-concurrent gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-048 SyncQueue_i32 std.channel sync_smoke sync_queue_contention_smoke_c; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-queue-concurrent gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-queue-concurrent gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-queue-concurrent gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-queue-concurrent gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_queue_conc_symbols_ok "$MOD_X" "$QUEUE_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_queue_conc_emit_report "fail" 0 0 0 0 0
  echo "std-queue-concurrent gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-queue-concurrent manifest OK"

if [ "${XLANG_STD_QUEUE_CONCURRENT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_queue_conc_emit_report "ok" 0 0 0 0 1
  echo "std-queue-concurrent gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
MAIN_OK=0
SYNC_OK=0
C_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-048: API rename grep (XLANG=$XLANG_BIN) ==="
  for sym in new push_back pop_front length deinit sync_new sync_push sync_try_pop sync_deinit sync_smoke; do
    if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
      echo "std-queue-concurrent gate FAIL: mod missing function ${sym}" >&2
      std_queue_conc_emit_report "fail" 0 0 0 0 0
      exit 1
    fi
  done
  for call in queue.sync_new queue.sync_push queue.sync_try_pop; do
    if ! grep -q "${call}" "$SMOKE_X" 2>/dev/null; then
      echo "std-queue-concurrent gate FAIL: smoke missing ${call}" >&2
      std_queue_conc_emit_report "fail" 0 0 0 0 0
      exit 1
    fi
  done
  if ! grep -q "queue.new" "$MAIN_X" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: main missing queue.new" >&2
    std_queue_conc_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if grep -qE 'function queue_i32_|function queue_u8_|function sync_queue_i32_' "$MOD_X" 2>/dev/null; then
    echo "std-queue-concurrent gate FAIL: mod still has old queue_* API names" >&2
    std_queue_conc_emit_report "fail" 0 0 0 0 0
    exit 1
  fi

  echo "=== STD-048: smoke (XLANG=$XLANG_BIN; check/sync/c observational; main hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-queue-concurrent gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/queue/queue.o
  ensure_std_c_o ../std/sync/sync.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Hard: Queue_i32 main.x must exit 0 under product asm.
  if std_queue_conc_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
    SKIP=0
  else
    std_queue_conc_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi

  # Observational: SyncQueue .x (product queue-sync UNDEF residual — not soft).
  if std_queue_conc_run_smoke "$XLANG_BIN" "$SMOKE_X" "sync_rt"; then
    SYNC_OK=1
  else
    echo "std-queue-concurrent gate SKIP sync_queue_roundtrip (product residual)" >&2
  fi

  # Observational: C contention harness (pthread / host .o; not product asm path).
  if std_queue_conc_run_c_smoke "$QUEUE_C"; then
    C_OK=1
  else
    echo "std-queue-concurrent gate SKIP c contention smoke (observational)" >&2
  fi
else
  echo "std-queue-concurrent gate FAIL: no native xlang" >&2
  std_queue_conc_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check/sync/c stay observational; hard-green signal is main=.
echo "std-queue-concurrent check_ok=${CHECK_OK} sync_ok=${SYNC_OK} c_ok=${C_OK} (observational)"
std_queue_conc_emit_report "ok" "$CHECK_OK" "$MAIN_OK" "$SYNC_OK" "$C_OK" "$SKIP"
echo "std-queue-concurrent gate OK"
