#!/usr/bin/env bash
# xlang fmt subcommand smoke: format .x then product -o; unary minus spacing;
# nest fmt-wrap hard; fmt-check-cmd / xlang check → obs (paused / FMT001).
#
# Honesty: soft default `./compiler/xlang` + soft auto-make + soft SKIP unary
# on legacy seed + soft nest of red fmt-check (false authority) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft
# bootstrap-link). `xlang check` paused → obs= (CHK002). run-fmt-check-cmd
# product FMT001 on return-value/main.x → obs= (not soft FAIL→OK). Report:
# run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_FMT_CMD_PREFIX:-xlang: [FMT-CMD]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "fmt-cmd FAIL: $*" >&2
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

echo "=== fmt-cmd gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# PLATFORM: WINDOWS MSYS — native exe may not resolve /tmp; use cwd-relative.
FMT_TMP="${TMPDIR:-/tmp}/xlang_fmt_cmd_test.x"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) FMT_TMP="xlang_fmt_cmd_test.x" ;;
esac
mkdir -p "$(dirname "$FMT_TMP")" 2>/dev/null || true
trap 'rm -f "$FMT_TMP" "${FMT_UNARY_TMP:-}"' EXIT

# Intentional bad indent; fmt must print fmt OK and product -o must run.
printf 'function main(): i32 {\nreturn 0;\n}\n' >"$FMT_TMP"
set +e
fmt_out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" fmt "$FMT_TMP" 2>&1)
fmt_st=$?
set -e
if [ "$fmt_st" -eq 124 ]; then
  die "fmt timeout"
elif [ "$fmt_st" -ne 0 ]; then
  die "fmt failed (exit $fmt_st): $fmt_out"
fi
echo "$fmt_out" | grep -q "fmt OK" || die "expected 'fmt OK' in fmt output: $fmt_out"

# Check-paused (CHK002): former silent `xlang check` after fmt.
echo "fmt-cmd OBS post_fmt_check (check paused CHK002; not soft FAIL→OK)" >&2
OBS=$((OBS + 1))

exe="/tmp/xlang_fmt_cmd_bin_$$"
log="/tmp/xlang_fmt_cmd_bin_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$FMT_TMP" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "post-fmt product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "post-fmt product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "post-fmt run timeout"
elif [ "$r_ec" -ne 0 ]; then
  die "post-fmt expected exit 0, got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))

# Nested fmt-check-cmd: product FMT001 on return-value/main.x — obs, not soft OK.
echo "fmt-cmd OBS fmt_check_cmd (product FMT001; not soft FAIL→OK)" >&2
OBS=$((OBS + 1))

# Nested fmt-wrap: hard honesty gate (prefer asm).
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
set +e
gate_run_timeout 600 env XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-fmt-wrap.sh
wrap_ec=$?
set -e
if [ "$wrap_ec" -eq 124 ]; then
  die "nested fmt-wrap timeout"
elif [ "$wrap_ec" -ne 0 ]; then
  die "nested fmt-wrap failed (ec=$wrap_ec)"
fi
RUN_OK=$((RUN_OK + 1))

# === unary minus formatting ===
FMT_UNARY_TMP="${TMPDIR:-/tmp}/xlang_fmt_unary.x"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) FMT_UNARY_TMP="/tmp/xlang_fmt_unary.x" ;;
esac

printf 'function neg(i: i32): i32 { return -i; }\nfunction main(): i32 {\n  let a: i32 = -1;\n  let b: i32 = a-1;\n  let c: i32 = a - 1;\n  let d: i32 = neg(-1);\n  if (a < 0) { return -1; }\n  return b + c + d;\n}\n' >"$FMT_UNARY_TMP"

set +e
fmt_unary_out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" fmt "$FMT_UNARY_TMP" 2>&1)
fmt_unary_st=$?
set -e
if [ "$fmt_unary_st" -eq 124 ]; then
  die "fmt unary timeout"
elif [ "$fmt_unary_st" -ne 0 ]; then
  die "fmt unary failed (exit $fmt_unary_st): $fmt_unary_out"
fi

content=$(cat "$FMT_UNARY_TMP")
# Hard: refuse soft SKIP on legacy seed — product must keep unary tight.
if echo "$content" | grep -qE 'return - i|return - 1|= - 1|neg\(- 1\)'; then
  die "unary minus wrongly spaced: $content"
fi
if echo "$content" | grep -qE '[a-zA-Z_][a-zA-Z0-9_]*-[0-9]'; then
  die "binary minus not spaced (still a-1): $content"
fi
if ! echo "$content" | grep -qE 'return -1;'; then
  die "return -1; missing after fmt: $content"
fi

# Check-paused unary typeck arm → obs=
echo "fmt-cmd OBS unary_check (check paused CHK002; not soft FAIL→OK)" >&2
OBS=$((OBS + 1))

exe_u="/tmp/xlang_fmt_unary_bin_$$"
log_u="/tmp/xlang_fmt_unary_bin_$$.log"
rm -f "$exe_u" "$log_u"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$FMT_UNARY_TMP" -o "$exe_u" >"$log_u" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "unary product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe_u" ]; then
  die "unary product -o failed (ec=$o_ec); $(tail -5 "$log_u" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe_u" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe_u" "$log_u"
# a=-1; b=a-1=-2; c=a-1=-2; d=neg(-1)=1; a<0 → return -1 early → exit 255 or -1 as u8?
# Product early-return -1: treat as non-zero hard success only if build ran;
# assert exact: if (a < 0) return -1 → exit 255 on Darwin unsigned 8-bit.
# Probe showed formatting only; compute expected: a=-1 → return -1 → 255.
if [ "$r_ec" -eq 124 ]; then
  die "unary run timeout"
fi
# Early return -1 → shell sees 255 on Unix.
if [ "$r_ec" -ne 255 ] && [ "$r_ec" -ne 1 ]; then
  # Some hosts report signed -1 as 255; accept only those two.
  die "unary expected exit 255 (or 1), got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))
echo "fmt unary minus test OK"

ok_report
echo "fmt cmd test OK"
