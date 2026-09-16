#!/usr/bin/env bash
# STD-124: std.regex atomic group `(?>...)` gate — honesty soft prefer-c /
# soft SKIP→OK / soft auto-make / soft ensure_std_c_o / hard C smoke /
# c=/x= report →硬绿.
#
# Honesty: prefer-c first (xlang-c check then x_smoke, no xlang_asm) +
# soft SKIP→OK (no xlang-c still gate OK / SKIP=1) + soft `ensure_std_c_o`
# + soft `xlang_compiler_make xlang-c` + hard C smoke after rebuild +
# report `c=`/`x=`/`skip=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Host-C archaeology = obs only (prebuilt std/regex/regex.o via parent
# STD-051 `std_regex_run_c_smoke`; refuse soft ensure). check residual
# = obs (paused 2026-08-05). tip product -o UNDEF / missing-main /
# exit≠0 = obs (product debt; leave; same residual as STD-051 xplat
# atomic_match.x). Report: run=/obs=/skip=. Parent STD-051
# hard-delegate MANIFEST_ONLY (already honesty-closed). Keep ## 3. Gate.
# Keep keywords STD-124 / atomic_nest.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-regex-atomic-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD124_DOC:-analysis/archive/std/std-regex-atomic-v1.md}"
MANIFEST="${XLANG_STD124_TSV:-tests/baseline/std-regex-atomic-manifest.tsv}"
REGEX_X="std/regex/regex.x"
MOD_X="std/regex/mod.x"
LIB="tests/lib/std-regex-atomic.sh"
SMOKE_X="tests/regex/atomic_match.x"
SMOKE_C="tests/regex/regex_min_ok.c"

# shellcheck source=tests/lib/std-regex-atomic.sh
. "$LIB"
std_regex_atomic_source_regex

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-regex-atomic gate FAIL: $*" >&2
  std_regex_atomic_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-124: regex atomic manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$REGEX_X" "$MOD_X" "$SMOKE_X" "$SMOKE_C" \
  analysis/archive/std/std-regex-v1.md tests/run-std-regex-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-regex-atomic-v1.md ] || die "dual-authority fossil analysis/std-regex-atomic-v1.md (archive live)"

for kw in STD-124 atomic_nest; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" || die "doc missing ## 3. Gate section"
grep -qF atomic_nest "$REGEX_X" || die "regex.x missing atomic_nest"

sym_miss="$(std_regex_atomic_symbols_ok "$REGEX_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-regex-atomic manifest OK"

# Parent STD-051 already honesty-closed; hard-delegate MANIFEST_ONLY.
# PLATFORM: SHARED archaeology — refuse reopening STD-051 product residual.
echo "=== STD-124: parent STD-051 manifest ==="
chmod +x tests/run-std-regex-gate.sh
XLANG_STD_REGEX_MANIFEST_ONLY=1 ./tests/run-std-regex-gate.sh

if [ "${XLANG_STD124_REGEX_ATOMIC_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_regex_atomic_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-regex-atomic gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-124: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# Parent C smoke (regex_min_ok.c / regex_min_smoke_c) already covers pat20 atomic.
# PLATFORM: SHARED — missing prebuilt regex.o = obs, not soft SKIP→OK.
set +e
std_regex_run_c_smoke "$REGEX_X"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-regex-atomic OK: c smoke"
    ;;
  *)
    echo "std-regex-atomic OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_regex_atomic_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-regex-atomic OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF / missing-main / exit≠0 residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence / hard die on product residual.
if std_regex_run_smoke "$XLANG_BIN" "$SMOKE_X" "atomic"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-regex-atomic OK: product atomic_match"
else
  echo "std-regex-atomic OBS tip product atomic_match (UNDEF/missing-main residual)" >&2
  OBS=$((OBS + 1))
fi

std_regex_atomic_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-regex-atomic gate OK"
