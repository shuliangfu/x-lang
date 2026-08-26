#!/usr/bin/env bash
# BOOT-019 subset: parser/typeck dogfood check (observational) + link+run.
#
# Used by bootstrap-verify / check-7.2 Stage2 expand; does not replace full
# run-parser/run-typeck. Honesty 2026-08-26: check is observational (paused
# 2026-08-05); link+run is the hard signal when BOOT019_SKIP_LINK is unset.
# Prefer caller to pin XLANG=./compiler/xlang_asm and XLANG_LINK_XLANG.
#
# Usage:
#   XLANG=./compiler/xlang_asm ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
#   BOOT019_SKIP_LINK=1 …  # skip link+run (manifest / typeck-only callers)
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

XLANG="${XLANG:-./compiler/xlang_asm}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"

# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. tests/lib/boot-019-stage2-dogfood.sh

if [ ! -x "$XLANG" ]; then
  echo "bootstrap-stage2-dogfood FAIL: XLANG not executable: $XLANG" >&2
  exit 127
fi

# Prefer pin when unset so Darwin-arm64 does not remap asm→c.
# PLATFORM: SHARED — product path honesty.
if [ -z "${XLANG_LINK_XLANG:-}" ]; then
  export XLANG_LINK_XLANG="$XLANG"
fi
# MSYS2 / non-x86_64 (non-Darwin): link fallback xlang-c.
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/xlang-c ]; then
    export XLANG_LINK_XLANG=./compiler/xlang-c
  fi
fi
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/xlang-c ] && [ "$(uname -s)" != "Darwin" ]; then
      export XLANG_LINK_XLANG=./compiler/xlang-c
    fi
    ;;
esac

# parser subset: syntax / multi-function / expression
PARSER_SMOKES=(
  tests/parser/semicolon_required.x
  tests/parser/two_functions.x
  tests/parser/binary_expr_return.x
)
# typeck subset: Option / Result / generic
TYPECK_SMOKES=(
  tests/option/main.x
  tests/result/main.x
  tests/generic/main.x
)

CHECK_OK=0
LINK_OK=0
LINK_SKIP=0
LINK_FAIL=0

run_smoke_list() {
  local label="$1"
  shift
  local src
  for src in "$@"; do
    # Observational check (paused 2026-08-05); does not hard-fail the subset.
    if boot019_check_one "$XLANG" "$src"; then
      CHECK_OK=$((CHECK_OK + 1))
      echo "bootstrap-stage2-dogfood check OK $label $(basename "$src")"
    else
      echo "bootstrap-stage2-dogfood SKIP check $label $(basename "$src") (paused 2026-08-05)" >&2
    fi
    if [ -n "${BOOT019_SKIP_LINK:-}" ]; then
      LINK_SKIP=$((LINK_SKIP + 1))
      continue
    fi
    local base
    base=$(basename "$src" .x)
    local out="${OUT_DIR}/xlang_boot019_${base}"
    local expect lr=0
    expect=$(boot019_expected_exit "$src")
    boot019_link_run_one "$XLANG" "$src" "$out" "$expect" || lr=$?
    if [ "$lr" -eq 0 ]; then
      LINK_OK=$((LINK_OK + 1))
      echo "bootstrap-stage2-dogfood link+run OK $label $(basename "$src")"
    elif [ "$lr" -eq 2 ]; then
      LINK_SKIP=$((LINK_SKIP + 1))
      if [ -n "${BOOT019_REQUIRE_LINK:-}" ]; then
        echo "bootstrap-stage2-dogfood FAIL: link $src (BOOT019_REQUIRE_LINK=1)" >&2
        LINK_FAIL=$((LINK_FAIL + 1))
      else
        echo "bootstrap-stage2-dogfood SKIP link $label $(basename "$src") (check observational)"
      fi
    else
      echo "bootstrap-stage2-dogfood FAIL: run $src" >&2
      LINK_FAIL=$((LINK_FAIL + 1))
    fi
  done
}

run_smoke_list parser "${PARSER_SMOKES[@]}"
run_smoke_list typeck "${TYPECK_SMOKES[@]}"

# Hard-fail only on link/run failures (or REQUIRE_LINK link miss).
# When SKIP_LINK is set, subset stays green on observational path.
if [ "$LINK_FAIL" -gt 0 ]; then
  boot019_emit_report "fail" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
  exit 1
fi
# Default (no SKIP_LINK): require 6/6 link+run for subset OK.
if [ -z "${BOOT019_SKIP_LINK:-}" ] && [ "$LINK_OK" -lt 6 ]; then
  boot019_emit_report "fail" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
  echo "bootstrap-stage2-dogfood FAIL: link_ok=${LINK_OK} < 6" >&2
  exit 1
fi

boot019_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
echo "bootstrap-stage2-dogfood parser/typeck OK (XLANG=$XLANG build check_ok=$CHECK_OK)"
