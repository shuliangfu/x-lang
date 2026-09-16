#!/usr/bin/env bash
# CORE-011: core.fmt f64 NaN/Inf/precision gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make +
# bootstrap-link wrap + check SKIP narrative retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make). Product -o
# f64_special.x exit0 = hard run; check = obs. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-fmt-f64-special-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-fmt-f64-special.sh
. tests/lib/core-fmt-f64-special.sh

DOC="${XLANG_CORE_FMT_F64_SPECIAL_DOC:-analysis/archive/core/core-fmt-f64-special-v1.md}"
MANIFEST="${XLANG_CORE_FMT_F64_SPECIAL_TSV:-tests/baseline/core-fmt-f64-special.tsv}"
FMT_X="core/fmt/mod.x"
STD_FMT_X="std/fmt/mod.x"
LIB="tests/lib/core-fmt-f64-special.sh"
SMOKE="tests/fmt/f64_special.x"
SMOKE_EXPECT=0
MIN_SYMBOLS=6

PREFIX="${XLANG_CORE_FMT_F64_SPECIAL_PREFIX:-xlang: [XLANG_CORE_FMT_F64_SPECIAL]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-fmt-f64-special gate FAIL: $*" >&2
  core_fmt_f64_special_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== CORE-011: f64 NaN/Inf/prec (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
if [ -f analysis/core-fmt-f64-special-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$FMT_X" "$STD_FMT_X" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in NaN Inf fmt_f64_to_buf_prec FMT_F64_DEFAULT_PREC 截断; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-fmt-f64-special FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-fmt-f64-special FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMBOLS" ] || [ "$MISS" -gt 0 ]; then
  die "symbols=${SYM_N} miss=${MISS}"
fi

sym_miss="$(core_fmt_f64_special_symbols_ok "$FMT_X" "$STD_FMT_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-fmt-f64-special manifest OK (symbols=${SYM_N})"

# Goldens must call live core.fmt long names (not std.fmt short to_buf aliases).
for kw in fmt_f64_to_buf fmt_f64_to_buf_prec; do
  grep -qF "fmt.$kw" "$SMOKE" 2>/dev/null || die "smoke missing live call fmt.$kw"
done
if grep -qE 'fmt\.(to_buf|to_buf_prec)\(' "$SMOKE" 2>/dev/null; then
  die "smoke still uses std.fmt short aliases on core.fmt"
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "core-fmt-f64-special OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_fmt_f64_$$"
trap 'rm -f "$exe"' EXIT
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_core_fmt_f64_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_fmt_f64_o.log 2>/dev/null || true
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$run_ec (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))

core_fmt_f64_special_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-fmt-f64-special gate OK"
ok_report
