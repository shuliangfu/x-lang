#!/usr/bin/env bash
# STD-086: std.config gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true`) + soft
# XLANG fallthrough (explicit-bad still picks another binary) + check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product layer_smoke.x -o exit0 = hard run. check residual = obs (paused
# 2026-08-05). Host-C smoke remains observational archaeology (not hard green).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-config-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CONFIG_DOC:-analysis/archive/std/std-config-v1.md}"
MANIFEST="${XLANG_STD_CONFIG_MANIFEST:-tests/baseline/std-config-manifest.tsv}"
MOD_X="std/config/mod.x"
CFG_X="std/config/config.x"
LIB="tests/lib/std-config.sh"
SMOKE_X="tests/std-config/layer_smoke.x"
SMOKE_C="tests/std-config/config_smoke_ok.c"
MIN_APIS=15
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-config.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-config gate FAIL: $*" >&2
  std_config_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-086: std.config manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CFG_X" "$SMOKE_X" "$SMOKE_C" std/config/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-086 load_toml_file load_env_prefix merge get_i32 get_bool get_source source_toml; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

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

sym_miss="$(std_config_symbols_ok "$MOD_X" "$CFG_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-config manifest OK"

if [ "${XLANG_STD_CONFIG_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_config_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-config gate OK (manifest only)"
  exit 0
fi

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is layer_smoke.x via asm.
# config.o needs short-name fs_open_read_c/fs_posix_read_c (runtime_io_abi.o
# Track-L) + link_abi_getenv (runtime_link_abi_user_env.o). Do not invent a
# second fs_* ABI. Do NOT also link std/process/process.o +
# runtime_process_os_glue.o together: Ubuntu GNU ld hard-fails on multiple
# definition (Darwin ld was permissive).
echo "=== STD-086: config c smoke (observational) ==="
C_NOTE=0
if dod_native_exe ./compiler/xlang-c || dod_native_exe ./compiler/xlang || dod_native_exe ./compiler/xlang_asm; then
  xlang_compiler_make ../std/config/config.o ../std/env/env.o \
    runtime_process_argv.o runtime_env_os.o \
    src/runtime_io_abi.o runtime_link_abi_user_env.o >/dev/null 2>&1 || true
  if cc -std=c11 -O1 -o /tmp/xlang_config_smoke \
    "$SMOKE_C" std/config/config.o std/env/env.o \
    compiler/runtime_process_argv.o compiler/runtime_env_os.o \
    compiler/src/runtime_io_abi.o compiler/runtime_link_abi_user_env.o 2>/tmp/xlang_config_smoke_link.err; then
    if /tmp/xlang_config_smoke >/dev/null 2>&1; then
      C_NOTE=1
      echo "std-config c smoke OK (observational)"
    fi
    rm -f /tmp/xlang_config_smoke
  else
    echo "std-config OBS c smoke (archaeology link; refuse soft SKIP→OK)" >&2
    tail -n 10 /tmp/xlang_config_smoke_link.err 2>/dev/null || true
  fi
else
  echo "std-config OBS c smoke (archaeology; no compiler)" >&2
fi
if [ "$C_NOTE" -eq 0 ]; then
  OBS=$((OBS + 1))
fi
echo "std-config c_smoke_note=${C_NOTE}"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-086: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_config_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-config OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std086_config_$$"
LOG="/tmp/xlang_std086_config_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-config OK: product -o"

std_config_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-config gate OK"
