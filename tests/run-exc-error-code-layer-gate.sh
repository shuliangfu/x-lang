#!/usr/bin/env bash
# EXC-003：错误码分层（语言/库/系统）manifest + 烟测门禁
#
# 1) exc-error-code-layer-v1.md + manifest
# 2) std/error 符号与 fs_last_error 侧车
# 3) native shux：tests/exc/error_code_layer.sx exit 0
#
# 用法：./tests/run-exc-error-code-layer-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_EXC_CODE_LAYER_DOC:-analysis/exc-error-code-layer-v1.md}"
MATRIX="${SHUX_EXC_CODE_LAYER_TSV:-tests/baseline/exc-error-code-layer.tsv}"
MIN_ITEMS=12

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

echo "=== EXC-003: error code layer manifest ==="
for f in \
  "$DOC" \
  "$MATRIX" \
  analysis/exc-result-error-v1-rfc.md \
  std/error/mod.sx; do
  if [ ! -f "$f" ]; then
    echo "exc-error-code-layer gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

MISS=0
FOUND=0
SMOKE=""
echo "=== EXC-003: manifest symbol check ==="
while IFS=$'\t' read -r item_id kind sym src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    doc_anchor)
      if ! grep -qF "$sym" "$DOC" 2>/dev/null; then
        echo "exc-error-code-layer FAIL: doc missing '$sym' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    naming_rule)
      if ! grep -qF "$sym" "$src" 2>/dev/null; then
        echo "exc-error-code-layer FAIL: naming '$sym' not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "exc-error-code-layer FAIL: missing $src ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qE "(function|void|int32_t|i32) ${sym}\\(" "$src" 2>/dev/null; then
        echo "exc-error-code-layer FAIL: symbol ${sym} not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    run)
      SMOKE="$src"
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "exc-error-code-layer gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-error-code-layer gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-error-code-layer manifest OK (items=${FOUND})"

# EXC-001 交叉引用
if ! grep -q 'EXC-003' analysis/exc-result-error-v1-rfc.md 2>/dev/null; then
  echo "exc-error-code-layer WARN: exc-result-error-v1-rfc.md has no EXC-003 ref" >&2
fi

make -C compiler -q 2>/dev/null || make -C compiler

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
  echo "exc-error-code-layer gate SKIP smoke (no native shux)" >&2
  echo "exc-error-code-layer gate OK"
  exit 0
fi

if [ -z "$SMOKE" ] || [ ! -f "$SMOKE" ]; then
  echo "exc-error-code-layer gate FAIL: missing smoke $SMOKE" >&2
  exit 1
fi

OUT=/tmp/shux_exc_code_layer
echo "=== EXC-003: layer smoke (SHUX=$SHUX_BIN) ==="
if ! "$SHUX_BIN" -L . "$SMOKE" -o "$OUT" >/tmp/shux_exc_code_layer_compile.log 2>&1; then
  cat /tmp/shux_exc_code_layer_compile.log >&2
  exit 1
fi
EC=0
"$OUT" >/dev/null 2>&1 || EC=$?
if [ "$EC" -ne 0 ]; then
  echo "exc-error-code-layer gate FAIL: smoke exit=$EC" >&2
  exit 1
fi
echo "exc-error-code-layer smoke OK"

echo "exc-error-code-layer gate OK"
