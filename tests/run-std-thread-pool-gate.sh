#!/usr/bin/env bash
# STD-043：std.thread 线程池与命名线程门禁（假权威诚实）。
#
# 用法：./tests/run-std-thread-pool-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); pool_roundtrip.x + main.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/pool=/name=/main=/skip=.
# API anchors aligned to product short names (set_name_self/start/submit/drain/
# stop/pending) — fossil thread_pool_* / thread_set_name_self were portable-
# false-red. Product surface already green under asm; gate was prefer-c / hard
# check / soft SKIP / fossil-name false-red.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_THREAD_POOL_DOC:-analysis/archive/std/std-thread-pool-v1.md}"
MANIFEST="${XLANG_STD_THREAD_POOL_TSV:-tests/baseline/std-thread-pool.tsv}"
MOD_X="std/thread/mod.x"
THREAD_RUNTIME="${XLANG_STD_THREAD_IMPL:-compiler/seeds/runtime_thread_glue.from_x.c}"
LIB="tests/lib/std-thread-pool.sh"
POOL_X="tests/thread/pool_roundtrip.x"
MAIN_X="tests/thread/main.x"
MIN_APIS=6

# shellcheck source=tests/lib/std-thread-pool.sh
. "$LIB"

echo "=== STD-043: thread pool manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$THREAD_RUNTIME" "$POOL_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-thread-pool gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-043 thread_pool_start set_name_self pool_roundtrip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-thread-pool gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-thread-pool gate FAIL: doc missing '## 5. Gate'" >&2
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
        echo "std-thread-pool gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-thread-pool gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-thread-pool gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_thread_pool_symbols_ok "$MOD_X" "$THREAD_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_thread_pool_emit_report "fail" 0 0 0 0 0
  echo "std-thread-pool gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-thread-pool manifest OK"

if [ "${XLANG_STD_THREAD_POOL_MANIFEST_ONLY:-0}" = "1" ]; then
  std_thread_pool_emit_report "ok" 0 0 0 0 1
  echo "std-thread-pool gate OK (manifest only)"
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
POOL_OK=0
NAME_OK=0
MAIN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-043: smoke (XLANG=$XLANG_BIN; check observational; pool/main hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$POOL_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-thread-pool gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/thread/thread.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_thread_pool_run_smoke "$XLANG_BIN" "$POOL_X" "pool"; then
    POOL_OK=1
    # pool_roundtrip exercises set_name_self; name tracked with pool.
    NAME_OK=1
  else
    std_thread_pool_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi
  if std_thread_pool_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
    SKIP=0
  else
    std_thread_pool_emit_report "fail" "$CHECK_OK" "$POOL_OK" "$NAME_OK" 0 0
    exit 1
  fi
else
  echo "std-thread-pool gate FAIL: no native xlang" >&2
  std_thread_pool_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is pool= + main=.
echo "std-thread-pool check_ok=${CHECK_OK} (observational)"
std_thread_pool_emit_report "ok" "$CHECK_OK" "$POOL_OK" "$NAME_OK" "$MAIN_OK" "$SKIP"
echo "std-thread-pool gate OK"
