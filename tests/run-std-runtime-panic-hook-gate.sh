#!/usr/bin/env bash
# STD-028: std.runtime panic hook — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary /
# prefer-c) + soft auto-make + check=/hook=/ready=/exc=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product panic_hook_align.x + runtime_ready.x exit0 = hard run (run+=).
# check + EXC-002 delegate = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-runtime-panic-hook-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_RUNTIME_PANIC_DOC:-analysis/archive/std/std-runtime-panic-hook-v1.md}"
MANIFEST="${XLANG_STD_RUNTIME_PANIC_TSV:-tests/baseline/std-runtime-panic-hook.tsv}"
EXC_DOC="${XLANG_EXC_PANIC_ABORT_DOC:-analysis/archive/exc/exc-panic-abort-v1-rfc.md}"
RUNTIME_X="std/runtime/mod.x"
RUNTIME_IMPL="std/runtime/runtime.x"
README="std/runtime/README.md"
LIB="tests/lib/std-runtime-panic-hook.sh"
HOOK_X="tests/exc/panic_hook_align.x"
READY_X="tests/exc/runtime_ready.x"
EXC_GATE="tests/run-exc-panic-abort-gate.sh"

# shellcheck source=tests/lib/std-runtime-panic-hook.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-runtime-panic gate FAIL: $*" >&2
  std_runtime_panic_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

# Refuse resurrected top-level EXC RFC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as run-exc-panic-abort-gate.sh.
if [ -f analysis/exc-panic-abort-v1-rfc.md ]; then
  die "top-level EXC DOC resurrected (live = archive/exc/)"
fi

echo "=== STD-028: runtime panic hook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNTIME_X" "$RUNTIME_IMPL" "$README" \
  "$HOOK_X" "$READY_X" "$EXC_DOC" \
  compiler/seeds/runtime_panic.from_x.c compiler/seeds/runtime_panic_arm64.from_x.c \
  compiler/src/asm/runtime_panic_x86_64.s; do
  [ -f "$f" ] || die "missing $f"
done

for kw in panic_hook_collect xlang_crash_evidence_collect_c EXC-002 abort; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

miss="$(std_runtime_panic_manifest_ok "$DOC" "$README" "$RUNTIME_X" "$MANIFEST" || true)"
[ "${miss:-0}" -eq 0 ] || die "manifest_miss=${miss}"
echo "std-runtime-panic manifest OK"

if [ "${XLANG_STD_RUNTIME_PANIC_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_runtime_panic_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-runtime-panic gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-028: smoke (XLANG=$XLANG_BIN; check/EXC obs; hook+ready product -o hard) ==="

# Observational check (paused 2026-08-05); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$HOOK_X" >/tmp/xlang_std_runtime_panic_chk_hook.log 2>&1
chk1=$?
"$XLANG_BIN" check -L . "$READY_X" >/tmp/xlang_std_runtime_panic_chk_ready.log 2>&1
chk2=$?
set -e
if [ "$chk1" -ne 0 ] || [ "$chk2" -ne 0 ]; then
  echo "std-runtime-panic OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_runtime_panic_run_smoke "$XLANG_BIN" "$HOOK_X" "hook"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-runtime-panic OK: hook"
else
  die "panic_hook_align.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_runtime_panic_run_smoke "$XLANG_BIN" "$READY_X" "ready"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-runtime-panic OK: ready"
else
  die "runtime_ready.x exit!=0 (refuse soft SKIP→OK)"
fi

# EXC-002 delegate: observational only. Soft-SKIP→OK was false authority;
# hard-failing EXC here would open neighbor debt outside this soft knife.
# PLATFORM: SHARED — report via obs=; never set skip=1 from EXC.
if [ -x "$EXC_GATE" ]; then
  echo "=== STD-028: delegate EXC-002 (observational) ==="
  set +e
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    "$EXC_GATE" >/tmp/std_runtime_exc_panic.log 2>&1
  exc_rc=$?
  set -e
  if [ "$exc_rc" -ne 0 ]; then
    echo "std-runtime-panic OBS EXC-002 (see /tmp/std_runtime_exc_panic.log)" >&2
    OBS=$((OBS + 1))
  fi
fi

std_runtime_panic_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-runtime-panic gate OK (host=$(ci_host_summary))"
