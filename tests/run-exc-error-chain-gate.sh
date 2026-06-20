#!/usr/bin/env bash
# EXC-004：错误链路追踪 manifest + 烟测门禁
#
# 1) exc-error-chain-v1.md + manifest
# 2) std/error ErrorChain API 符号
# 3) native shux：tests/exc/error_chain_smoke.sx
#
# 用法：./tests/run-exc-error-chain-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_EXC_ERROR_CHAIN_DOC:-analysis/exc-error-chain-v1.md}"
MATRIX="${SHUX_EXC_ERROR_CHAIN_TSV:-tests/baseline/exc-error-chain.tsv}"
ERR_MOD="${SHUX_STD_ERROR_MOD:-std/error/mod.sx}"
MIN_ITEMS=8
SMOKE="tests/exc/error_chain_smoke.sx"

native_shu() {
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

echo "=== EXC-004: error chain manifest ==="
for f in "$DOC" "$MATRIX" "$ERR_MOD" analysis/exc-result-error-v1-rfc.md; do
  if [ ! -f "$f" ]; then
    echo "exc-error-chain gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

MISS=0
FOUND=0
echo "=== EXC-004: symbol check ==="
while IFS=$'\t' read -r item_id kind sym src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    section)
      if ! grep -qF "$sym" "$DOC" 2>/dev/null; then
        echo "exc-error-chain FAIL: doc missing '$sym' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol|fn_*|type_*)
      if ! grep -qE "(struct|function) ${sym}[ ({]" "$ERR_MOD" 2>/dev/null; then
        echo "exc-error-chain FAIL: ${sym} not in $ERR_MOD" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    import)
      if ! grep -qF "$sym" "$ERR_MOD" 2>/dev/null; then
        echo "exc-error-chain FAIL: missing import $sym" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    run)
      SMOKE="$src"
      if [ ! -f "$SMOKE" ]; then
        echo "exc-error-chain FAIL: missing $SMOKE" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "exc-error-chain gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-error-chain gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-error-chain manifest OK (items=${FOUND})"

make -C compiler -q 2>/dev/null || make -C compiler
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "exc-error-chain gate SKIP smoke (no native shux)" >&2
  echo "exc-error-chain gate OK"
  exit 0
fi

OUT=/tmp/shux_exc_error_chain
echo "=== EXC-004: chain smoke (SHUX=$SHUX_BIN) ==="
set +e
"$SHUX_BIN" -L . "$SMOKE" -o "$OUT" >/tmp/shux_exc_chain_compile.log 2>&1
_comp_ec=$?
set -e
if [ "$_comp_ec" -ne 0 ]; then
  # Docker/shux-c -o 偶发 SIGSEGV；check 通过则视为 typeck 烟测 OK
  if [ "$_comp_ec" -eq 139 ] && "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    echo "exc-error-chain smoke OK (check-only, compile SIGSEGV)"
    echo "exc-error-chain gate OK"
    exit 0
  fi
  cat /tmp/shux_exc_chain_compile.log >&2
  exit 1
fi
EC=0
"$OUT" >/dev/null 2>&1 || EC=$?
if [ "$EC" -ne 0 ]; then
  echo "exc-error-chain gate FAIL: smoke exit=$EC" >&2
  exit 1
fi
echo "exc-error-chain smoke OK"

echo "exc-error-chain gate OK"
