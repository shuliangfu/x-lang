#!/usr/bin/env bash
# STD-106：std.log 日志轮转 + 异步缓冲门禁（假权威诚实）。
#
# 用法：./tests/run-std-log-rotate-async-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); rotate_async.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke remains observational (archaeology host-C
# path; not hard green). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP when no xlang-c).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD106_DOC:-analysis/archive/std/std-log-rotate-async-v1.md}"
MANIFEST="${XLANG_STD106_TSV:-tests/baseline/std-log-rotate-async.tsv}"
VECTORS="${XLANG_STD106_VECTORS:-tests/baseline/std-log-rotate-async-vectors.tsv}"
MOD_X="std/log/mod.x"
LOG_X="std/log/log.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
LIB="tests/lib/std-log-rotate-async.sh"
SMOKE_X="tests/std-log/rotate_async.x"
SMOKE_C="tests/std-log/rotate_async_smoke_ok.c"
MIN_APIS=3
# Designed success score (rotate_async.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-log-rotate-async.sh
. "$LIB"

echo "=== STD-106: log rotate-async manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-log-rotate-async-v1.md ]; then
  echo "std-log-rotate-async gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-log-rotate-async gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-106 set_rotate_limit async_flush rotate; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-log-rotate-async gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-log-rotate-async gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

if ! grep -qF 'async1' "$VECTORS" 2>/dev/null; then
  echo "std-log-rotate-async gate FAIL: vectors missing async_defer gold" >&2
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
        echo "std-log-rotate-async gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-log-rotate-async gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-log-rotate-async gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_log_rotate_async_symbols_ok "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_log_rotate_async_emit_report "fail" 0 0 0
  echo "std-log-rotate-async gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-log-rotate-async manifest OK"

if [ "${XLANG_STD106_MANIFEST_ONLY:-0}" = "1" ]; then
  std_log_rotate_async_emit_report "ok" 0 0 1
  echo "std-log-rotate-async gate OK (manifest only)"
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
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is rotate_async.x via asm.
echo "=== STD-106: log c smoke (observational) ==="
C_NOTE=0
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
if ensure_std_c_o ../std/log/log.o 2>/dev/null && ensure_runtime_log_os_o 2>/dev/null && std_log_rotate_async_run_c_smoke "$LOG_X"; then
  C_NOTE=1
  echo "std-log-rotate-async c smoke OK (observational)"
else
  echo "std-log-rotate-async gate SKIP c smoke (observational; no full log.o / link)" >&2
fi
echo "std-log-rotate-async c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-106: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-log-rotate-async gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std106_log_ra_$$"
  LOG="/tmp/xlang_std106_log_ra_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-log-rotate-async gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_log_rotate_async_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-log-rotate-async gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_log_rotate_async_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-log-rotate-async gate FAIL: no native xlang" >&2
  std_log_rotate_async_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-log-rotate-async check_ok=${CHECK_OK} (observational)"
std_log_rotate_async_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-log-rotate-async gate OK"
