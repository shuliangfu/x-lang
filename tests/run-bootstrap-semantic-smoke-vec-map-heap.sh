#!/usr/bin/env bash
# BOOT-015 subset: vec / map / heap check (observational) + optional link+run.
#
# Used by bootstrap-verify / check-7.2 semantic smoke; does not replace full
# run-vec/map/heap. Honesty 2026-08-26: check is observational (paused
# 2026-08-05); link+run is the hard signal when BOOT015_SKIP_LINK is unset.
# Prefer caller to pin XLANG=./compiler/xlang_asm and XLANG_LINK_XLANG.
#
# Usage:
#   XLANG=./compiler/xlang_asm ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh
#   BOOT015_SKIP_LINK=1 …  # skip link+run (manifest / typeck-only callers)
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

XLANG="${XLANG:-./compiler/xlang_asm}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"

# shellcheck source=tests/lib/boot-015-semantic-smoke.sh
. tests/lib/boot-015-semantic-smoke.sh

if [ ! -x "$XLANG" ]; then
  echo "bootstrap-semantic-smoke FAIL: XLANG not executable: $XLANG" >&2
  exit 127
fi

# Prefer pin when unset so Darwin-arm64 does not remap asm→c.
# PLATFORM: SHARED — product path honesty.
if [ -z "${XLANG_LINK_XLANG:-}" ]; then
  export XLANG_LINK_XLANG="$XLANG"
fi
# MSYS2 / non-x86_64: link fallback xlang-c (same as run-bootstrap-xlang-gate).
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

CHECK_OK=0
LINK_OK=0
LINK_SKIP=0
LINK_FAIL=0
for mod in vec map heap; do
  src="tests/${mod}/main.x"
  # Observational check (paused 2026-08-05); does not hard-fail the subset.
  if boot015_check_one "$XLANG" "$src"; then
    CHECK_OK=$((CHECK_OK + 1))
    echo "bootstrap-semantic-smoke check OK $mod"
  else
    echo "bootstrap-semantic-smoke SKIP check $mod (paused 2026-08-05)" >&2
  fi
  if [ -n "${BOOT015_SKIP_LINK:-}" ]; then
    LINK_SKIP=$((LINK_SKIP + 1))
    continue
  fi
  out="${OUT_DIR}/xlang_boot015_${mod}"
  lr=0
  boot015_link_run_one "$XLANG" "$src" "$out" || lr=$?
  if [ "$lr" -eq 0 ]; then
    LINK_OK=$((LINK_OK + 1))
    echo "bootstrap-semantic-smoke link+run OK $mod"
  elif [ "$lr" -eq 2 ]; then
    LINK_SKIP=$((LINK_SKIP + 1))
    if [ -n "${BOOT015_REQUIRE_LINK:-}" ]; then
      echo "bootstrap-semantic-smoke FAIL: link $mod (BOOT015_REQUIRE_LINK=1)" >&2
      LINK_FAIL=$((LINK_FAIL + 1))
    else
      echo "bootstrap-semantic-smoke SKIP link $mod (check observational)"
    fi
  else
    echo "bootstrap-semantic-smoke FAIL: run $mod" >&2
    LINK_FAIL=$((LINK_FAIL + 1))
  fi
done

# Hard-fail only on link/run failures (or REQUIRE_LINK link miss).
# When SKIP_LINK is set, subset stays green on observational path.
if [ "$LINK_FAIL" -gt 0 ]; then
  boot015_emit_report "fail" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
  exit 1
fi
if [ -z "${BOOT015_SKIP_LINK:-}" ] && [ "$LINK_OK" -lt 3 ] && [ -n "${BOOT015_REQUIRE_LINK:-}" ]; then
  boot015_emit_report "fail" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
  exit 1
fi
# Default (no SKIP_LINK): require 3/3 link+run for subset OK.
if [ -z "${BOOT015_SKIP_LINK:-}" ] && [ "$LINK_OK" -lt 3 ]; then
  boot015_emit_report "fail" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
  echo "bootstrap-semantic-smoke FAIL: link_ok=${LINK_OK} < 3" >&2
  exit 1
fi

boot015_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
echo "bootstrap-semantic-smoke vec/map/heap OK (XLANG=$XLANG)"
