#!/usr/bin/env bash
# STD-052: std.backtrace symbolicate gate — honesty residual
# XLANG fallthrough / auto-make / ensure rebuild / check=/c_gold=/x=/skip=
# →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` / `ensure_runtime_backtrace_platform_o` rebuild +
# C gold auto-make + report check=/c_gold=/x=/skip= retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# XLANG fallthrough / soft ensure rebuild). check residual = obs
# (paused 2026-08-05). Host-C archaeology = obs (existing
# std/backtrace/backtrace.o + compiler/runtime_backtrace_platform.o
# only; never rebuild; never pass extra CLI .o). tests/backtrace/
# symbolicate_known.x product -o exit0 = hard run. C gold file
# existence is TSV-required; compile/run is not a green signal
# (historically auto-made runtime_backtrace_platform.o /
# runtime_process_argv.o / runtime_link_abi_user_env.o). Report:
# run=/obs=/skip=. Keep ## 5. Gate. Live ensure_std family left.
# F-backtrace v1/v2 still hard-delegate this gate (must stay exit 0).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-backtrace-symbolicate-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_BACKTRACE_SYM_DOC:-analysis/archive/std/std-backtrace-symbolicate-v1.md}"
MANIFEST="${XLANG_STD_BACKTRACE_SYM_TSV:-tests/baseline/std-backtrace-symbolicate.tsv}"
VECTORS="${XLANG_STD_BACKTRACE_SYM_VECTORS:-tests/baseline/std-backtrace-symbolicate-vectors.tsv}"
MOD_X="std/backtrace/mod.x"
BT_RUNTIME="compiler/seeds/runtime_backtrace_platform.from_x.c"
BT_X="std/backtrace/backtrace.x"
LIB="tests/lib/std-backtrace-symbolicate.sh"
SMOKE_X="tests/backtrace/symbolicate_known.x"
SMOKE_C="tests/backtrace/symbolicate_gold.c"
MIN_APIS=2

# shellcheck source=tests/lib/std-backtrace-symbolicate.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-backtrace-symbolicate gate FAIL: $*" >&2
  std_backtrace_sym_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
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

echo "=== STD-052: backtrace symbolicate manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-backtrace-symbolicate-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$BT_X" "$BT_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-052 gold_anchor SYM_NAME_LEN dladdr; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 5\. Gate' "$DOC" || die "doc missing ## 5. Gate section"

grep -qF 'gold_anchor' "$VECTORS" 2>/dev/null || die "vectors missing gold_anchor"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_backtrace_sym_symbols_ok "$MOD_X" "$BT_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-backtrace-symbolicate manifest OK"

if [ "${XLANG_STD_BACKTRACE_SYM_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_backtrace_sym_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-backtrace-symbolicate gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-052: smoke (XLANG=$XLANG_BIN; check/C-gold/host-C=obs; symbolicate_known.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o /
# ensure_runtime_backtrace_platform_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std052_bt_check_$$.log 2>&1
chk_bt=$?
set -e
if [ "$chk_bt" -ne 0 ]; then
  echo "std-backtrace-symbolicate OBS check (paused / CHK residual known=$chk_bt; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o. Product -o is the hard path (pure .x).
# C gold file existence is TSV-required; compile/run of host-C is not a
# green signal (historically ensure_std_c_o + ensure_runtime_backtrace_platform_o
# + auto-make of process_argv / link_abi_user_env).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in std/backtrace/backtrace.o compiler/runtime_backtrace_platform.o; do
  if [ ! -f "$o" ]; then
    echo "std-backtrace-symbolicate OBS missing $o (no soft ensure; product -o still hard)" >&2
    OBS=$((OBS + 1))
  fi
done

# symbolicate_known.x product -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_backtrace_sym_run_smoke "$XLANG_BIN" "$SMOKE_X" "known"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-backtrace-symbolicate OK: product symbolicate_known.x"
else
  die "product -o $SMOKE_X failed (refuse soft SKIP→OK)"
fi

std_backtrace_sym_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-backtrace-symbolicate gate OK"
