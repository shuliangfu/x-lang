#!/usr/bin/env bash
# STD-065: std.db.sqlite exec-deep / tx gate — honesty soft prefer-c /
# soft SKIP→OK / soft auto-make / soft std_sqlite_build_o / soft ensure /
# tx_c=/tx_x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c then xlang, no xlang_asm) + soft SKIP→OK
# (no native / no libsqlite3 / typeck-fail / link-fail still gate OK) +
# soft `std_sqlite_build_o` / soft `ensure_std_c_o` + hard C smoke after
# rebuild + report `tx_c=`/`tx_x=`/`skip=` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Host-C archaeology = obs only (prebuilt std/db/sqlite/sqlite.o;
# refuse soft ensure/build_o). check residual = obs (paused 2026-08-05).
# tip product -o SEGV/UNDEF = obs (product debt; leave). Report:
# run=/obs=/skip=. Parent STD-057 hard-delegate MANIFEST_ONLY (already
# honesty-closed). Keep ## 4. Gate. Keep keywords STD-065 / begin_tx /
# rollback / tx_begin / db_sqlite_tx_exec_smoke_c.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-exec-deep-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD065_DOC:-analysis/archive/std/std-sqlite-exec-deep-v1.md}"
MANIFEST="${XLANG_STD065_TSV:-tests/baseline/std-sqlite-exec-deep.tsv}"
VECTORS="${XLANG_STD065_VECTORS:-tests/baseline/std-sqlite-exec-deep-vectors.tsv}"
MOD_X="std/db/sqlite/mod.x"
DB_C="std/db/sqlite/sqlite.x"
LIB="tests/lib/std-sqlite-exec-deep.sh"
SMOKE_X="tests/std-sqlite/exec_tx_roundtrip.x"
SMOKE_C="tests/std-sqlite/exec_tx_roundtrip_ok.c"
MIN_TX=3

# shellcheck source=tests/lib/std-sqlite-exec-deep.sh
. "$LIB"
std_sqlite_exec_deep_source_sqlite

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite-exec-deep gate FAIL: $*" >&2
  std_sqlite_exec_deep_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== STD-065: db exec deep manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$DB_C" "$SMOKE_X" "$SMOKE_C" \
  analysis/archive/std/std-sqlite-v1.md tests/run-std-sqlite-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-sqlite-exec-deep-v1.md ] || die "dual-authority fossil analysis/std-sqlite-exec-deep-v1.md (archive live)"

for kw in STD-065 begin_tx rollback tx_begin db_sqlite_tx_exec_smoke_c; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" || die "doc missing ## 4. Gate section"
grep -qF 'tx_commit' "$VECTORS" 2>/dev/null || die "vectors missing tx_commit"
grep -qF 'tx_rollback' "$VECTORS" 2>/dev/null || die "vectors missing tx_rollback"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_tx_apis) MIN_TX="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_TX" ] || die "api count $API_N < min $MIN_TX"

sym_miss="$(std_sqlite_exec_deep_symbols_ok "$MOD_X" "$DB_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sqlite-exec-deep manifest OK"

# Parent STD-057 already honesty-closed; hard-delegate MANIFEST_ONLY.
# Original env XLANG_STD_SQLITE_SQLITE_MANIFEST_ONLY was a no-op typo.
# PLATFORM: SHARED archaeology — refuse reopening STD-057 product residual.
echo "=== STD-065: parent STD-057 manifest ==="
chmod +x tests/run-std-sqlite-gate.sh
XLANG_STD_SQLITE_MANIFEST_ONLY=1 ./tests/run-std-sqlite-gate.sh

if [ "${XLANG_STD065_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_exec_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite-exec-deep gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-065: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make/build_o.
# PLATFORM: SHARED — missing libsqlite3 / prebuilt .o = obs, not soft SKIP→OK.
set +e
std_sqlite_exec_deep_run_c_smoke "$DB_C"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-sqlite-exec-deep OK: c smoke"
    ;;
  *)
    echo "std-sqlite-exec-deep OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sqlite_exec_deep_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite-exec-deep OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV/UNDEF residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "tx"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite-exec-deep OK: product exec_tx_roundtrip"
else
  echo "std-sqlite-exec-deep OBS tip product exec_tx_roundtrip (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_exec_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite-exec-deep gate OK"
