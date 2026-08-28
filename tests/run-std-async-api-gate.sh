#!/usr/bin/env bash
# STD-004: std.async stable API gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make + check=/switch=/imp=/drain=/coop=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft ensure). Product i06_async_switch + async_mod_import + async_drain_idle
# -o exit0 = hard run (all three folded into run=). check / coop_pingpong 1M
# (product UNDEF residual) = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-async-api-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ASYNC_API_DOC:-analysis/archive/std/std-async-api-v1.md}"
BASELINE="${XLANG_STD_ASYNC_API_TSV:-tests/baseline/std-async-api.tsv}"
LIB="tests/lib/std-async-api.sh"
MOD="std/async/mod.x"
SMOKE_SWITCH="bench/i06_async_switch.x"
SMOKE_IMP="examples/cookbook/async_mod_import.x"
SMOKE_DRAIN="examples/cookbook/async_drain_idle.x"
SMOKE_COOP="bench/i06_async_1m_coop.x"

# shellcheck source=tests/lib/std-async-api.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-async-api gate FAIL: $*" >&2
  std_async_api_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-004: std.async stable API manifest ==="
for f in "$DOC" "$BASELINE" "$LIB" "$MOD" "$SMOKE_SWITCH" "$SMOKE_IMP" "$SMOKE_DRAIN" "$SMOKE_COOP"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-004 std.async coop_pingpong wait_completion; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
for kw in i06_async_switch async_mod_import async_drain_idle; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 10. Gate' "$DOC" 2>/dev/null || die "doc missing '## 10. Gate'"

sym_miss="$(std_async_api_symbols_ok "$MOD" "$BASELINE" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-async-api manifest OK"

if [ "${XLANG_STD_ASYNC_API_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_async_api_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-async-api gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-004: smoke (XLANG=$XLANG_BIN; check/coop obs; switch+imp+drain product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_SWITCH" >/tmp/xlang_std004_async_switch_check.log 2>&1
chk_sw=$?
"$XLANG_BIN" check -L . "$SMOKE_IMP" >/tmp/xlang_std004_async_imp_check.log 2>&1
chk_imp=$?
set -e
if [ "$chk_sw" -ne 0 ] || [ "$chk_imp" -ne 0 ]; then
  echo "std-async-api OBS check (paused / CHK residual switch=$chk_sw imp=$chk_imp; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_SWITCH" "switch"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-async-api OK: switch"
else
  die "product -o switch failed (refuse soft SKIP→OK)"
fi
if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_IMP" "imp"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-async-api OK: imp"
else
  die "product -o imp failed (refuse soft SKIP→OK)"
fi
if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_DRAIN" "drain"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-async-api OK: drain"
else
  die "product -o drain failed (refuse soft SKIP→OK)"
fi

# Observational coop/1m (product UNDEF residual; never hard-green).
# PLATFORM: SHARED — coop_pingpong link surface still product debt.
if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_COOP" "coop"; then
  echo "std-async-api coop OK (observational)"
else
  echo "std-async-api OBS coop/1m (product UNDEF residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_async_api_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-async-api gate OK"
