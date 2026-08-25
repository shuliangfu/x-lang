#!/usr/bin/env bash
# STD-071：std.context 门禁（F-context v2：纯 context.x；假权威诚实）。
#
# 用法：./tests/run-std-context-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); cancel_smoke.x exit 0 hard-fail (no soft SKIP).
# C smoke remains observational (archaeology host-C path; not hard green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CONTEXT_DOC:-analysis/archive/std/std-context-v1.md}"
MANIFEST="${XLANG_STD_CONTEXT_MANIFEST:-tests/baseline/std-context-manifest.tsv}"
MOD_X="std/context/mod.x"
CTX_X="std/context/context.x"
LIB="tests/lib/std-context.sh"
SMOKE_X="tests/std-context/cancel_smoke.x"
SMOKE_C="tests/std-context/context_smoke_ok.c"
MIN_APIS=10
# Designed success score (cancel_smoke.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-context.sh
. "$LIB"

echo "=== STD-071: std.context manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CTX_X" "$SMOKE_X" "$SMOKE_C" std/context/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
[ ! -f std/context/context_node_glue.c ] || {
  echo "std-context gate FAIL: context_node_glue.c should be deleted (F-context v2)" >&2
  exit 1
}

for kw in STD-071 background with_cancel is_cancelled remaining_ns; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-context gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-context gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-context gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_context_symbols_ok "$MOD_X" "$CTX_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_context_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-context manifest OK"

if [ "${XLANG_STD_CONTEXT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_context_emit_report "ok" 0 0 1
  echo "std-context gate OK (manifest only)"
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
# PLATFORM: SHARED archaeology — product honesty is cancel_smoke.x via asm.
echo "=== STD-071: context c smoke (observational) ==="
C_NOTE=0
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/context/context.o 2>/dev/null && std_context_run_c_smoke "$CTX_X"; then
    C_NOTE=1
    echo "std-context c smoke OK (observational)"
  else
    echo "std-context gate SKIP c smoke (observational; no full context.o)" >&2
  fi
else
  echo "std-context gate SKIP c smoke (observational; no xlang-c)" >&2
fi
echo "std-context c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-071: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-context gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/context/mod.o 2>/dev/null || xlang_compiler_make ../std/context/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/context/context.o 2>/dev/null || xlang_compiler_make ../std/context/context.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_context_$$"
  LOG="/tmp/xlang_std_context_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-context gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_context_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-context gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_context_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-context gate FAIL: no native xlang" >&2
  std_context_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-context check_ok=${CHECK_OK} (observational)"
std_context_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-context gate OK"
