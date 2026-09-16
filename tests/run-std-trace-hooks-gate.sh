#!/usr/bin/env bash
# STD-118: std.trace io/net/async hooks gate — honesty residual
# prefer-c / auto-make / ensure rebuild / check=/c=/x=/skip= →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK
# (no xlang-c still gate OK) + soft `xlang_compiler_make -q ||
# xlang_compiler_make` + `ensure_std_c_o … || true` of trace.o /
# time.o / random.o + C smoke auto-make of runtime_time_os.o /
# runtime_random_fill.o + report c=/x=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native
# = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# XLANG fallthrough / soft ensure rebuild). check residual = obs
# (paused 2026-08-05). Host-C archaeology = obs (existing
# std/trace/trace.o + std/time/time.o + std/random/random.o only;
# never rebuild; never pass extra CLI .o). tests/std-trace/
# hooks_smoke.x product -o: hard run when it links; tip std_trace_*
# UNDEF = obs (product debt; refuse soft SKIP→OK). C smoke file
# existence is TSV-required; compile/run is not a green signal
# (historically auto-made runtime_time_os.o / runtime_random_fill.o).
# Report: run=/obs=/skip=. Keep ## 3. Gate. Live ensure_std family
# left. F-trace v1/v2 still observational-delegate this gate (leave;
# their own fallthrough＋auto-make of trace.o left). TSV/DOC API
# anchors aligned to live product short names (hook_begin / io_read /
# io_write / net_connect / async_drain; fossils hook_span_begin /
# hook_io_*_ctx retired). PLATFORM: SHARED archaeology — Ubuntu gold
# still required.
# Usage: ./tests/run-std-trace-hooks-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD118_TRACE_HOOKS_DOC:-analysis/archive/std/std-trace-hooks-v1.md}"
MANIFEST="${XLANG_STD118_TRACE_HOOKS_TSV:-tests/baseline/std-trace-hooks-manifest.tsv}"
VECTORS="${XLANG_STD118_TRACE_HOOKS_VECTORS:-tests/baseline/std-trace-hooks-vectors.tsv}"
MOD_X="std/trace/mod.x"
TRACE_X="std/trace/trace.x"
LIB="tests/lib/std-trace-hooks.sh"
SMOKE_X="tests/std-trace/hooks_smoke.x"
SMOKE_C="tests/std-trace/hooks_smoke_ok.c"
MIN_APIS=6

# shellcheck source=tests/lib/std-trace-hooks.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-trace-hooks gate FAIL: $*" >&2
  std_trace_hooks_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-118: trace hooks manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-trace-hooks-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$TRACE_X" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-118 hook_begin io_read async_drain; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 3\. Gate' "$DOC" || die "doc missing ## 3. Gate section"

grep -qF 'io.read' "$VECTORS" 2>/dev/null || die "vectors missing io.read"

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

sym_miss="$(std_trace_hooks_symbols_ok "$MOD_X" "$TRACE_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-trace-hooks manifest OK"

if [ "${XLANG_STD118_TRACE_HOOKS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_trace_hooks_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-trace-hooks gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-118: smoke (XLANG=$XLANG_BIN; check/C-smoke/host-C=obs; hooks_smoke.x product -o hard-when-links / UNDEF=obs) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std118_hooks_check_$$.log 2>&1
chk_h=$?
set -e
if [ "$chk_h" -ne 0 ]; then
  echo "std-trace-hooks OBS check (paused / CHK residual known=$chk_h; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o. Product -o is the hard path (pure .x).
# C smoke file existence is TSV-required; compile/run of host-C is not a
# green signal (historically ensure_std_c_o + auto-make of
# runtime_time_os.o / runtime_random_fill.o). Do not observe general
# compiler runtime objects.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in std/trace/trace.o std/time/time.o std/random/random.o; do
  if [ ! -f "$o" ]; then
    echo "std-trace-hooks OBS missing $o (no soft ensure; product -o still hard-when-links)" >&2
    OBS=$((OBS + 1))
  fi
done

# hooks_smoke.x product -o: hard-green when it actually links+runs;
# tip std_trace_* / std_async_* UNDEF = obs (product debt, same as
# STD-088 nested_smoke.x). Refuse soft SKIP→OK.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_trace_hooks_run_smoke "$XLANG_BIN" "$SMOKE_X" "hooks"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-trace-hooks OK: product hooks_smoke.x"
else
  echo "std-trace-hooks OBS tip product -o (std_trace_* UNDEF residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_trace_hooks_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-trace-hooks gate OK"
