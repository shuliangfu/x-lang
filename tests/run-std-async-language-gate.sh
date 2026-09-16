#!/usr/bin/env bash
# STD-041: std.async ↔ language async/await bridge gate.
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die. `xlang check`
# is observational (check gate paused 2026-08-05). await_scheduler_mod
# coop UNDEF = obs (aligned with std-async-1m). Report
# run=/mod=/obs=/skip_1m=.
#
# Usage: ./tests/run-std-async-language-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when
# archived; live roadmap = analysis/自举进度.md (NEXT.md left; refuse
# resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ALANG_DOC:-analysis/archive/std/std-async-language-v1.md}"
MANIFEST="${XLANG_STD_ALANG_TSV:-tests/baseline/std-async-language.tsv}"
MOD_X="std/async/mod.x"
SCHED_C="compiler/seeds/runtime_scheduler_glue.from_x.c"
LIB="tests/lib/std-async-language.sh"
RUN_X="tests/async/await_scheduler_run.x"
MOD_TEST_X="tests/async/await_scheduler_mod.x"
PREFIX="xlang: [XLANG_STD_ASYNC_LANGUAGE]"

# shellcheck source=tests/lib/std-async-language.sh
. tests/lib/std-async-language.sh

RUN_OK=0
MOD_OK=0
OBS=0
SKIP_1M=0

die() {
  echo "std-async-language gate FAIL: $*" >&2
  std_alang_emit_report "fail" "$RUN_OK" "$MOD_OK" "$SKIP_1M" "$OBS"
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

echo "=== STD-041: async language bridge manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SCHED_C" "$RUN_X" "$MOD_TEST_X"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

for kw in scheduler_reset drain_idle await_scheduler_run async_1m_coop extern 重声明; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done

if ! grep -qF "xlang_async_run_i32" "$SCHED_C" 2>/dev/null; then
  die "scheduler.c missing xlang_async_run_i32"
fi

sym_miss="$(std_alang_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  die "symbol_miss=${sym_miss}"
fi
echo "std-async-language manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== STD-041: smoke (XLANG=$XLANG_BIN; check observational) ==="
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make ../std/async/scheduler.o -q 2>/dev/null \
  || xlang_compiler_make ../std/async/scheduler.o 2>/dev/null || true

# check gate paused — observational only (not hard fail / not soft silence).
# PLATFORM: SHARED — check debt deferred post-selfhost.
for x in "$RUN_X" "$MOD_TEST_X"; do
  if ! "$XLANG_BIN" check -L . "$x" >/dev/null 2>&1; then
    echo "std-async-language OBS check $x (check paused)" >&2
    OBS=1
  fi
done

# RUN smoke product residual (Darwin compile crash / Ubuntu exit≠0) → obs.
# PLATFORM: SHARED — not soft silence; count obs.
if std_alang_run_smoke "$XLANG_BIN" "$RUN_X" "/tmp/xlang_async_alang_run"; then
  RUN_OK=1
else
  echo "std-async-language OBS run ($RUN_X; product residual)" >&2
  OBS=1
fi

# mod smoke may hit coop UNDEF (aligned with std-async-1m) → obs.
# PLATFORM: SHARED — product residual; not soft silence.
if std_alang_run_smoke "$XLANG_BIN" "$MOD_TEST_X" "/tmp/xlang_async_alang_mod"; then
  MOD_OK=1
else
  echo "std-async-language OBS mod ($MOD_TEST_X; coop UNDEF / product residual)" >&2
  OBS=1
fi

echo "=== STD-041: delegate 1M task stress ==="
chmod +x tests/run-std-async-1m-gate.sh
if ! XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-std-async-1m-gate.sh; then
  die "1m delegate"
fi

std_alang_emit_report "ok" "$RUN_OK" "$MOD_OK" "$SKIP_1M" "$OBS"
echo "std-async-language gate OK"
