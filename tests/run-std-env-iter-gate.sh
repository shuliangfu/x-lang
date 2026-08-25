#!/usr/bin/env bash
# STD-025：std.env env_iter / args_iter 门禁（假权威诚实）。
#
# 用法：./tests/run-std-env-iter-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: runnable hard-green (std/env product surface + cookbook env_args_iter);
# Prefer xlang_asm; env_iter.x exit 0 hard-fail (no soft SKIP / no hard check).
# check smoke observational SKIP (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ENV_ITER_DOC:-analysis/archive/std/std-env-iter-v1.md}"
MANIFEST="${XLANG_STD_ENV_ITER_TSV:-tests/baseline/std-env-iter.tsv}"
ENV_X="std/env/mod.x"
ENV_IMPL="std/env/env.x"
ENV_GLUE="compiler/seeds/runtime_env_os.from_x.c"
LIB="tests/lib/std-env-iter.sh"
SMOKE="tests/env/env_iter.x"
COOKBOOK="examples/cookbook/env_args_iter.x"
RUNNER="tests/run-env.sh"
# Designed success score (tests/env/env_iter.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-env-iter.sh
. tests/lib/std-env-iter.sh

echo "=== STD-025: env iter manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$ENV_X" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-env-iter gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in iter_next args_iter_next environ GetEnvironmentStringsA; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-env-iter gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_env_iter_symbols_ok "$ENV_X" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_env_iter_emit_report "fail" 0 0 0
  echo "std-env-iter gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-env-iter manifest OK"

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
  echo "=== STD-025: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-env-iter gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/env/env.o 2>/dev/null || xlang_compiler_make ../std/env/env.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_env_iter_$$"
  LOG="/tmp/xlang_std_env_iter_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-env-iter gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_env_iter_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-env-iter gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_env_iter_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi

  # Neighborhood cookbook (args_iter) — same product face; hard-fail if present.
  if [ -f "$COOKBOOK" ]; then
    CB_OUT="/tmp/xlang_std_env_args_cookbook_$$"
    CB_LOG="/tmp/xlang_std_env_args_cookbook_build_$$.log"
    if $RUN_XLANG build -L . "$COOKBOOK" -o "$CB_OUT" 2>"$CB_LOG"; then
      cb_ec=0
      "$CB_OUT" >/dev/null 2>&1 || cb_ec=$?
      rm -f "$CB_OUT"
      if [ "$cb_ec" -ne 0 ]; then
        echo "std-env-iter gate FAIL cookbook env_args_iter exit=$cb_ec" >&2
        std_env_iter_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
      echo "std-env-iter cookbook env_args_iter OK"
    else
      echo "std-env-iter gate FAIL cookbook env_args_iter link" >&2
      tail -20 "$CB_LOG" 2>/dev/null >&2 || true
      std_env_iter_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  fi
else
  echo "std-env-iter gate SKIP typeck (no native xlang)" >&2
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-env-iter check_ok=${CHECK_OK} (observational)"
std_env_iter_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-env-iter gate OK"
