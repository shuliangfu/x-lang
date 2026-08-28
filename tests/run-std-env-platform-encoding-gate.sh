#!/usr/bin/env bash
# STD-132: std.env platform encoding gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft XLANG
# fallthrough (explicit-bad still picks another binary) + check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft ensure rebuild). Product platform_encoding.x -o exit0 = hard run (run=1).
# check / host-C archaeology = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-env-platform-encoding-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD132_ENV_PLATFORM_ENCODING_DOC:-analysis/archive/std/std-env-platform-encoding-v1.md}"
MANIFEST="${XLANG_STD132_ENV_PLATFORM_ENCODING_MANIFEST:-tests/baseline/std-env-platform-encoding-manifest.tsv}"
MOD_X="std/env/mod.x"
ENV_IMPL="std/env/env.x"
ENV_GLUE="compiler/seeds/runtime_env_os.from_x.c"
LIB="tests/lib/std-env-platform-encoding.sh"
SMOKE_X="tests/env/platform_encoding.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-env-platform-encoding.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-env-platform-encoding gate FAIL: $*" >&2
  std_env_platform_encoding_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-132: env platform-encoding manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-env-platform-encoding-v1.md ] || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-132 env_parse_kv_entry platform_encoding; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

sym_miss="$(std_env_platform_encoding_symbols_ok "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-env-platform-encoding manifest OK"

if [ "${XLANG_STD132_ENV_PLATFORM_ENCODING_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_env_platform_encoding_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-env-platform-encoding gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-132: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
ENV_O="std/env/env.o"
if [ -f "$ENV_O" ] && nm "$ENV_O" 2>/dev/null | grep -qF 'env_platform_encoding_smoke_c' \
  && std_env_platform_encoding_run_c_smoke "$ENV_O"; then
  echo "std-env-platform-encoding c smoke OK (observational)"
else
  echo "std-env-platform-encoding OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std132_env_pe_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-env-platform-encoding OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std132_env_pe_$$"
LOG="/tmp/xlang_std132_env_pe_build_$$.log"
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
echo "std-env-platform-encoding OK: product -o"

std_env_platform_encoding_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-env-platform-encoding gate OK"
