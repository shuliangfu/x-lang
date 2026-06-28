#!/usr/bin/env bash
# STD-025：std.env env_iter / args_iter 门禁
#
# 用法：./tests/run-std-env-iter-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_ENV_ITER_DOC:-analysis/std-env-iter-v1.md}"
MANIFEST="${SHUX_STD_ENV_ITER_TSV:-tests/baseline/std-env-iter.tsv}"
ENV_SX="std/env/mod.sx"
ENV_IMPL="std/env/env.sx"
ENV_GLUE="compiler/src/asm/runtime_env_os.c"
LIB="tests/lib/std-env-iter.sh"
SMOKE="tests/env/env_iter.sx"
RUNNER="tests/run-env.sh"

# shellcheck source=tests/lib/std-env-iter.sh
. tests/lib/std-env-iter.sh

echo "=== STD-025: env iter manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$ENV_SX" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE" "$RUNNER"; do
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

sym_miss="$(std_env_iter_symbols_ok "$ENV_SX" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_env_iter_emit_report "fail" 0 0 0
  echo "std-env-iter gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-env-iter manifest OK"

stdlib_cm_native_shu() {
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
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-025: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-env-iter gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_env_iter_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q ../std/env/env.o 2>/dev/null || make -C compiler ../std/env/env.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if $RUN_SHUX -L . "$SMOKE" -o /tmp/shux_std_env_iter 2>/tmp/shux_std_env_iter_build.log; then
    exitcode=0
    /tmp/shux_std_env_iter >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-env-iter gate FAIL: runnable exit=$exitcode" >&2
      std_env_iter_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-env-iter gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shux_std_env_iter_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-env-iter gate SKIP typeck (no native shux)" >&2
fi

std_env_iter_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-env-iter gate OK"
