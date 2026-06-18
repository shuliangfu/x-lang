#!/usr/bin/env bash
# EXC-005：CLI/LSP 错误显示统一 manifest + golden 烟测
#
# 1) exc-cli-lsp-error-v1.md + manifest
# 2) hub 符号与格式 pattern
# 3) golden fixture message 子串（compile + check）
#
# 用法：./tests/run-exc-cli-lsp-error-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_EXC_CLI_LSP_DOC:-analysis/exc-cli-lsp-error-v1.md}"
MATRIX="${SHU_EXC_CLI_LSP_TSV:-tests/baseline/exc-cli-lsp-error.tsv}"
MIN_ITEMS=10

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

echo "=== EXC-005: CLI/LSP error display manifest ==="
for f in "$DOC" "$MATRIX" compiler/src/lsp/lsp_diag.h; do
  if [ ! -f "$f" ]; then
    echo "exc-cli-lsp-error gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

MISS=0
FOUND=0
HOOK=""
echo "=== EXC-005: hub and format check ==="
while IFS=$'\t' read -r item_id kind anchor src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "exc-cli-lsp-error FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif [ "$anchor" = "fail" ]; then
        if ! grep -qE 'static int fail\(' "$src" 2>/dev/null; then
          echo "exc-cli-lsp-error FAIL: parse fail() not in $src" >&2
          MISS=$((MISS + 1))
        fi
      elif ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: ${anchor} not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    pattern)
      if [ ! -f "$src" ] || ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: pattern '$anchor' not in $src ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    golden)
      if [ ! -f "$src" ]; then
        echo "exc-cli-lsp-error FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "exc-cli-lsp-error FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOK="$path"
      fi
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "exc-cli-lsp-error gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-cli-lsp-error gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-cli-lsp-error manifest OK (items=${FOUND})"

make -C compiler -q 2>/dev/null || make -C compiler

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu ./compiler/shu-su; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "exc-cli-lsp-error gate SKIP golden (no native shu)" >&2
  echo "exc-cli-lsp-error gate OK"
  exit 0
fi

FAILS=0
echo "=== EXC-005: golden compile stderr (SHU=$SHU_BIN) ==="
while IFS=$'\t' read -r item_id kind anchor src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  [ "$kind" = "golden" ] || continue
  want="$notes"
  echo "── compile golden: $src ──"
  err=$("$SHU_BIN" "$src" -o /tmp/shu_exc_cli_lsp_fail 2>&1) || true
  if ! echo "$err" | grep -qF "$want"; then
    echo "exc-cli-lsp-error FAIL compile: missing phrase '$want' in $src" >&2
    echo "$err" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  if ! echo "$err" | grep -qE 'typeck error:|parse error at'; then
    echo "exc-cli-lsp-error FAIL compile: missing CLI prefix in $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  if ! echo "$err" | grep -qE ' at [0-9]+:[0-9]+|parse error at [0-9]+:[0-9]+:'; then
    echo "exc-cli-lsp-error FAIL compile: missing line:col in $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "exc-cli-lsp-error OK compile $src"
done < "$MATRIX"

echo "=== EXC-005: golden check format ==="
assign="tests/typeck/type_mismatch_assign.su"
want="assignment type mismatch: expected i32, found bool"
chk=$("$SHU_BIN" check "$assign" 2>&1) && {
  echo "exc-cli-lsp-error FAIL: check should fail on $assign" >&2
  FAILS=$((FAILS + 1))
} || true
if ! echo "$chk" | grep -qF "$want"; then
  echo "exc-cli-lsp-error FAIL check: missing '$want'" >&2
  echo "$chk" >&2
  FAILS=$((FAILS + 1))
elif ! echo "$chk" | grep -qE ' - error: '; then
  echo "exc-cli-lsp-error FAIL check: missing ' - error: ' format" >&2
  echo "$chk" >&2
  FAILS=$((FAILS + 1))
elif ! echo "$chk" | grep -qE ':[0-9]+:[0-9]+ - error:'; then
  echo "exc-cli-lsp-error FAIL check: missing path:line:col" >&2
  echo "$chk" >&2
  FAILS=$((FAILS + 1))
else
  echo "exc-cli-lsp-error OK check format"
fi

if [ "$FAILS" -gt 0 ]; then
  echo "exc-cli-lsp-error gate FAIL: golden=${FAILS}" >&2
  exit 1
fi

echo "exc-cli-lsp-error gate OK"
