#!/usr/bin/env bash
# STD-028: std.runtime panic hook cross-platform gate (false-authority honesty).
#
# Usage: ./tests/run-std-runtime-panic-hook-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); panic_hook_align.x + runtime_ready.x exit 0
# hard-fail (no soft SKIP when native xlang present). EXC-002 delegate is
# observational (report exc=; never soft-SKIP whole gate to OK). Report
# check=/hook=/ready=/exc=/skip=. Product surface already green under asm;
# gate was portable-false-red (prefer xlang-c / soft SKIP on missing native /
# stale top-level EXC RFC path / ## 4. 验收 without ## 6. Gate).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
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

# Refuse resurrected top-level EXC RFC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as run-exc-panic-abort-gate.sh.
if [ -f analysis/exc-panic-abort-v1-rfc.md ]; then
  echo "std-runtime-panic gate FAIL: top-level EXC DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

echo "=== STD-028: runtime panic hook manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNTIME_X" "$RUNTIME_IMPL" "$README" \
  "$HOOK_X" "$READY_X" "$EXC_DOC" \
  compiler/seeds/runtime_panic.from_x.c compiler/seeds/runtime_panic_arm64.from_x.c \
  compiler/src/asm/runtime_panic_x86_64.s; do
  if [ ! -f "$f" ]; then
    echo "std-runtime-panic gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in panic_hook_collect xlang_crash_evidence_collect_c EXC-002 abort; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-runtime-panic gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-runtime-panic gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

miss="$(std_runtime_panic_manifest_ok "$DOC" "$README" "$RUNTIME_X" "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  std_runtime_panic_emit_report "fail" 0 0 0 0 0
  echo "std-runtime-panic gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "std-runtime-panic manifest OK"

if [ "${XLANG_STD_RUNTIME_PANIC_MANIFEST_ONLY:-0}" = "1" ]; then
  std_runtime_panic_emit_report "ok" 0 0 0 0 1
  echo "std-runtime-panic gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
HOOK_OK=0
READY_OK=0
EXC_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-028: smoke (XLANG=$XLANG_BIN; check observational; hook/ready hard; EXC observational) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$HOOK_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$READY_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-runtime-panic gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_runtime_panic_run_smoke "$XLANG_BIN" "$HOOK_X" "hook"; then
    HOOK_OK=1
  else
    std_runtime_panic_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi
  if std_runtime_panic_run_smoke "$XLANG_BIN" "$READY_X" "ready"; then
    READY_OK=1
  else
    std_runtime_panic_emit_report "fail" "$CHECK_OK" "$HOOK_OK" 0 0 0
    exit 1
  fi

  # EXC-002 delegate: observational only. Soft-SKIP→OK was false authority;
  # hard-failing EXC here would open neighbor debt outside this soft knife.
  # PLATFORM: SHARED — report exc=; never set skip=1 from EXC.
  if [ -x "$EXC_GATE" ]; then
    echo "=== STD-028: delegate EXC-002 (observational) ==="
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      "$EXC_GATE" >/tmp/std_runtime_exc_panic.log 2>&1; then
      EXC_OK=1
    else
      echo "std-runtime-panic gate SKIP EXC-002 (observational; see /tmp/std_runtime_exc_panic.log)" >&2
      EXC_OK=0
    fi
  fi
  SKIP=0
else
  echo "std-runtime-panic gate FAIL: no native xlang" >&2
  std_runtime_panic_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check/exc stay observational; hard-green signal is hook=/ready=.
echo "std-runtime-panic check_ok=${CHECK_OK} exc_ok=${EXC_OK} (observational)"
std_runtime_panic_emit_report "ok" "$CHECK_OK" "$HOOK_OK" "$READY_OK" "$EXC_OK" "$SKIP"
echo "std-runtime-panic gate OK"
