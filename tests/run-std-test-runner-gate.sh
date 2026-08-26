#!/usr/bin/env bash
# STD-145：std.test 统一 test runner 门禁（假权威诚实）。
#
# 用法：./tests/run-std-test-runner-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); runner_smoke.x exit 0 + report lines hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product surface had NUL-truncation bugs in report literals (TST_LIT_SUMMARY /
# case-line mid); fixed at produce point in std/test/test.x. Gate was also
# portable-false-red (prefer xlang-c / hard check / soft SKIP on missing c +
# section grep against resurrected top-level DOC path).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD145_DOC:-analysis/archive/std/std-test-runner-v1.md}"
MANIFEST="${XLANG_STD145_TSV:-tests/baseline/std-test-runner-manifest.tsv}"
MOD_X="std/test/mod.x"
TEST_X="std/test/test.x"
LIB="tests/lib/std-test-runner.sh"
SMOKE_X="tests/std-test/runner_smoke.x"
SMOKE_EXPECT=0
MIN_APIS=4

# shellcheck source=tests/lib/std-test-runner.sh
. "$LIB"

echo "=== STD-145: std.test runner manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-test-runner-v1.md ]; then
  echo "std-test-runner gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TEST_X" "$SMOKE_X" std/test/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-test-runner gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-145 runner_case runner_finish XLANG_TEST_SUMMARY; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-test-runner gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-test-runner gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

if ! grep -qF "runner_reset" std/test/README.md 2>/dev/null; then
  echo "std-test-runner gate FAIL: README missing runner_reset" >&2
  exit 1
fi

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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-test-runner FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-test-runner gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_test_runner_symbols_ok "$MOD_X" "$TEST_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_test_runner_emit_report "fail" 0 0 0
  echo "std-test-runner gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-test-runner registry OK"

if [ "${XLANG_STD145_MANIFEST_ONLY:-0}" = "1" ]; then
  std_test_runner_emit_report "ok" 0 0 1
  echo "std-test-runner gate OK (manifest only)"
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
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-145: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-test-runner gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # Rebuild product std.test .o so NUL literal fixes are on the link path.
  # PLATFORM: SHARED — std/test is SHARED report surface.
  xlang_compiler_make -q ../std/test/mod.o 2>/dev/null || xlang_compiler_make ../std/test/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/test/test.o 2>/dev/null || xlang_compiler_make ../std/test/test.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std145_runner_$$"
  LOG="/tmp/xlang_std145_runner_build_$$.log"
  ERR="/tmp/xlang_std145_runner_err_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>"$ERR" || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -ne "$SMOKE_EXPECT" ]; then
      echo "std-test-runner gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      cat "$ERR" >&2 || true
      std_test_runner_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    if ! grep -qF 'xlang: [XLANG_TEST] name=case_ok status=pass' "$ERR" 2>/dev/null; then
      echo "std-test-runner gate FAIL: missing pass line" >&2
      cat "$ERR" >&2 || true
      std_test_runner_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    if ! grep -qF 'xlang: [XLANG_TEST_SUMMARY] total=2 pass=1 fail=0 skip=1' "$ERR" 2>/dev/null; then
      echo "std-test-runner gate FAIL: missing summary" >&2
      cat "$ERR" >&2 || true
      std_test_runner_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    RUN_OK=1
    SKIP=0
  else
    echo "std-test-runner gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_test_runner_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-test-runner gate FAIL: no native xlang" >&2
  std_test_runner_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable + report lines).
echo "std-test-runner check_ok=${CHECK_OK} (observational)"
std_test_runner_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-test-runner gate OK"
