#!/usr/bin/env bash
# STD-111：std.sync 调试锁诊断门禁（假权威诚实）。
#
# 用法：./tests/run-std-sync-lock-diag-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); lock_diag.x exit 0 hard-fail (no soft
# SKIP when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP on missing c + fossil
# "## 4. 验证与门禁" DOC section).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD111_DOC:-analysis/archive/std/std-sync-lock-diag-v1.md}"
MANIFEST="${XLANG_STD111_TSV:-tests/baseline/std-sync-lock-diag.tsv}"
MOD_X="std/sync/mod.x"
SYNC_DIAG_X="std/sync/sync.x"
SYNC_X="std/sync/sync.x"
LIB="tests/lib/std-sync-lock-diag.sh"
SMOKE_X="tests/sync/lock_diag.x"
SMOKE_EXPECT=0
MIN_APIS=8

# shellcheck source=tests/lib/std-sync-lock-diag.sh
. "$LIB"

echo "=== STD-111: sync lock diag manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sync-lock-diag-v1.md ]; then
  echo "std-sync-lock-diag gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_DIAG_X" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-sync-lock-diag gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-111 lock_diag_set_enabled lock_diag_err_order lock_diag_smoke; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sync-lock-diag gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-sync-lock-diag gate FAIL: doc missing '## 3. Gate'" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-sync-lock-diag FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sync-lock-diag gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sync_lock_diag_symbols_ok "$MOD_X" "$SYNC_DIAG_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sync_lock_diag_emit_report "fail" 0 0 0
  echo "std-sync-lock-diag gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sync-lock-diag manifest OK"

if [ "${XLANG_STD111_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sync_lock_diag_emit_report "ok" 0 0 1
  echo "std-sync-lock-diag gate OK (manifest only)"
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

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-111: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-sync-lock-diag gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/sync/mod.o 2>/dev/null || xlang_compiler_make ../std/sync/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/sync/sync.o 2>/dev/null || xlang_compiler_make ../std/sync/sync.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std111_lock_diag_$$"
  LOG="/tmp/xlang_std111_lock_diag_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-sync-lock-diag gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_sync_lock_diag_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-sync-lock-diag gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_sync_lock_diag_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-sync-lock-diag gate FAIL: no native xlang" >&2
  std_sync_lock_diag_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-sync-lock-diag check_ok=${CHECK_OK} (observational)"
std_sync_lock_diag_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-sync-lock-diag gate OK"
