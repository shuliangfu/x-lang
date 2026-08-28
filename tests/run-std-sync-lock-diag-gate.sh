#!/usr/bin/env bash
# STD-111: std.sync lock diag — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary /
# prefer-c) + soft auto-make + check=/run=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product lock_diag.x
# -o exit0 = hard run (run+=). check = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sync-lock-diag-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sync-lock-diag gate FAIL: $*" >&2
  std_sync_lock_diag_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-111: sync lock diag manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sync-lock-diag-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_DIAG_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-111 lock_diag_set_enabled lock_diag_err_order lock_diag_smoke; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

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
  grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_sync_lock_diag_symbols_ok "$MOD_X" "$SYNC_DIAG_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sync-lock-diag manifest OK"

if [ "${XLANG_STD111_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sync_lock_diag_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sync-lock-diag gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-111: smoke (XLANG=$XLANG_BIN; check obs; lock_diag product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std111_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sync-lock-diag OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

OUT="/tmp/xlang_std111_lock_diag_$$"
LOG="/tmp/xlang_std111_lock_diag_build_$$.log"
if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
  exitcode=0
  "$OUT" >/dev/null 2>&1 || exitcode=$?
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "lock_diag.x exit=$exitcode (expect $SMOKE_EXPECT; refuse soft SKIP→OK)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-sync-lock-diag OK: lock_diag"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "lock_diag.x link (refuse soft SKIP→OK)"
fi

std_sync_lock_diag_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sync-lock-diag gate OK (host=$(ci_host_summary))"
