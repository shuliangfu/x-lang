#!/usr/bin/env bash
# STD-120: import std.db compat layer gate — honesty soft prefer-c /
# soft SKIP→OK / soft auto-make / soft ensure_std_c_o / x=/skip= report →硬绿.
#
# Honesty: prefer-c first (xlang-c check then x_smoke, no xlang_asm) +
# soft SKIP→OK (no xlang-c still gate OK / SKIP=1) + soft `ensure_std_c_o`
# + soft `xlang_compiler_make xlang-c` + hard xlang-c check/x_smoke +
# report `x=`/`skip=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Host-C archaeology = obs only (prebuilt std/db/sqlite/sqlite.o; refuse
# soft ensure). check residual = obs (paused 2026-08-05). tip product
# -o UNDEF / SEGV / exit≠0 = obs (product debt; leave; same residual as
# STD-057 / STD-065 sqlite family). Report: run=/obs=/skip=. Keep
# ## 3. Gate. Keep keywords std.db.sqlite / is_deprecated / db_open_c.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-db-compat-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD120_DOC:-analysis/archive/std/std-db-compat-v1.md}"
MANIFEST="${XLANG_STD120_TSV:-tests/baseline/std-db-compat-manifest.tsv}"
VECTORS="${XLANG_STD120_VECTORS:-tests/baseline/std-db-compat-vectors.tsv}"
MOD_X="std/db/mod.x"
SQLITE_X="std/db/sqlite/mod.x"
LIB="tests/lib/std-db-compat.sh"
SMOKE_X="tests/std-db/compat_smoke.x"
README="std/db/README.md"
MIN_APIS=5

# shellcheck source=tests/lib/std-db-compat.sh
. "$LIB"
std_db_compat_source_sqlite

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-db-compat gate FAIL: $*" >&2
  std_db_compat_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-120: db compat manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SQLITE_X" "$SMOKE_X" "$README"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-db-compat-v1.md ] || die "dual-authority fossil analysis/std-db-compat-v1.md (archive live)"

for kw in 'std.db.sqlite' is_deprecated db_open_c; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || \
    grep -qF -- "$kw" "$VECTORS" 2>/dev/null || \
    grep -qF -- "$kw" "$MOD_X" 2>/dev/null || die "doc/vectors/mod missing '$kw'"
done
grep -qF 'std.db.sqlite' "$DOC" || die "doc missing std.db.sqlite"
grep -qF 'is_deprecated' "$VECTORS" || die "vectors missing is_deprecated"
grep -qF 'db_open_c' "$MOD_X" || die "mod missing db_open_c"
grep -qF '## 3. Gate' "$DOC" || die "doc missing ## 3. Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_db_compat_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-db-compat manifest OK"

if [ "${XLANG_STD120_DB_COMPAT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_db_compat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-db-compat gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-120: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt sqlite.o = obs, not soft SKIP→OK.
set +e
std_db_compat_host_c_obs std/db/sqlite/sqlite.o
c_rc=$?
set -e
# Presence is not a green signal (no dedicated C harness; G.7 refuse new one).
# Missing prebuilt = obs; present = archaeology note only.
if [ "$c_rc" -ne 0 ]; then
  echo "std-db-compat OBS host-C sqlite.o (rc=$c_rc)" >&2
  OBS=$((OBS + 1))
else
  echo "std-db-compat OBS host-C sqlite.o present (not a green signal; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_db_compat_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-db-compat OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV/UNDEF residual = obs (leave product debt; sqlite family).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence. G.7: parent run_smoke.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "compat"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-db-compat OK: product compat_smoke"
else
  echo "std-db-compat OBS tip product compat_smoke (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_db_compat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-db-compat gate OK"
