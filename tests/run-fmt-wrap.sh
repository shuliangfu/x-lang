#!/usr/bin/env bash
# xlang fmt wrap regression: comments unwrapped; code wraps at ;/,/space;
# array comma spacing; post-fmt fmt --check + product -o hard.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link). `xlang check` paused (2026-08-05) → former silent-check
# arms = obs= (CHK002), not soft FAIL→OK. fmt + fmt --check + product -o hard.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_FMT_WRAP_PREFIX:-xlang: [FMT-WRAP]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "fmt-wrap FAIL: $*" >&2
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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

# PLATFORM: SHARED — fmt builtin ignore includes "/tests/" so stage temp
# copies outside tests/ (e.g. /tmp) for fmt --check file_list_push.
_FMT_WRAP_TMP="${TMPDIR:-/tmp}/xlang_fmt_wrap_$$"
mkdir -p "$_FMT_WRAP_TMP"
trap 'rm -rf "$_FMT_WRAP_TMP"' EXIT

run_one_case() {
  local tag="$1" src="$2" want="$3"
  local tmp="$_FMT_WRAP_TMP/${tag}_out.x"
  local exe="$_FMT_WRAP_TMP/${tag}_bin"
  local log="$_FMT_WRAP_TMP/${tag}.log"
  local out chk2 o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  cp "$src" "$tmp"

  set +e
  out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" fmt "$tmp" 2>&1)
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag fmt timeout"
  elif [ "$o_ec" -ne 0 ]; then
    die "$tag fmt failed (ec=$o_ec): $out"
  fi

  python3 compiler/scripts/scan_fmt_damage.py "$tmp" \
    || die "$tag scan_fmt_damage failed"
  python3 compiler/scripts/verify_comment_prefixes.py "$tmp" \
    || die "$tag verify_comment_prefixes failed"

  if grep -E '^[[:space:]]*(refix|fix)\[' "$tmp" >/dev/null 2>&1; then
    die "$tag fmt split identifier inside prefix[...]"
  fi
  if grep -E '[^[:space:];][[:space:]]*;[[:alnum:]_\[]' "$tmp" >/dev/null 2>&1; then
    die "$tag fmt missing space after semicolon before identifier"
  fi

  # Check-paused arm (CHK002): former silent `xlang check` after fmt.
  echo "fmt-wrap OBS ${tag}_check (check paused CHK002; not soft FAIL→OK)" >&2
  OBS=$((OBS + 1))

  set +e
  chk2=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" fmt --check "$tmp" 2>&1)
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag fmt --check timeout"
  elif [ "$o_ec" -ne 0 ] || [ -n "$chk2" ]; then
    die "$tag expected silent fmt --check, ec=$o_ec out=$chk2"
  fi

  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$tmp" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "  OK: $src (fmt+fmt--check+product -o exit $want)"
}

echo "=== fmt-wrap gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

echo "fmt wrap regression:"
run_one_case wrap_cases tests/fmt/fmt_wrap_cases.x 16
run_one_case comprehensive tests/fmt/fmt_comprehensive.x 65
run_one_case semicolon_space tests/fmt/fmt_semicolon_space.x 5
run_one_case operator_space tests/fmt/fmt_operator_space.x 8
run_one_case array_comma_space tests/fmt/fmt_array_comma_space.x 116

ok_report
echo "fmt wrap test OK (all cases)"
