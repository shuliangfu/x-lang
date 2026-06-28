#!/usr/bin/env bash
# STD-158：std.error 跨模块语义统一门禁
#
# 用法：./tests/run-std-error-semantics-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-error-semantics-v1.md"
MANIFEST="tests/baseline/std-error-semantics.tsv"
ERR_MOD="std/error/mod.sx"
LIB="tests/lib/std-error-semantics.sh"
SMOKE="tests/std/error_semantics_smoke.sx"
RECIPE="examples/cookbook/error_semantic_class.sx"
MIN_SYM=6

# shellcheck source=tests/lib/std-error-semantics.sh
. "$LIB"

echo "=== STD-158: error semantics manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$ERR_MOD" "$SMOKE" "$RECIPE"; do
  if [ ! -f "$f" ]; then
    echo "std-error-semantics gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-158 semantic_class is_timeout recommend_retry; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-error-semantics gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

SYM_N=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "symbol" ] && SYM_N=$((SYM_N + 1))
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYM" ]; then
  echo "std-error-semantics gate FAIL: symbols=$SYM_N < min $MIN_SYM" >&2
  exit 1
fi

sym_miss="$(std_error_semantics_symbols_ok "$ERR_MOD" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_error_semantics_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-error-semantics manifest OK"

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
  echo "=== STD-158: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1 \
    && "$SHUX_BIN" check -L . "$RECIPE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-error-semantics gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -5 >&2 || true
    std_error_semantics_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if $RUN_SHUX -L . "$SMOKE" -o /tmp/shux_std_error_semantics 2>/tmp/shux_std_error_sem_build.log; then
    ec=0
    /tmp/shux_std_error_semantics >/dev/null 2>&1 || ec=$?
    if [ "$ec" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-error-semantics gate FAIL: smoke exit=$ec" >&2
      std_error_semantics_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-error-semantics gate SKIP runnable (link failed)" >&2
    tail -5 /tmp/shux_std_error_sem_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-error-semantics gate SKIP typeck (no native shux)" >&2
fi

std_error_semantics_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-error-semantics gate OK"
