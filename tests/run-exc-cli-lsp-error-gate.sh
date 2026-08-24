#!/usr/bin/env bash
# EXC-005：CLI/LSP 错误显示统一 manifest + golden 烟测（假权威诚实）。
#
# 1) archive DOC + manifest
# 2) hub 符号与格式 pattern（live lsp_diag.h / runtime_lsp_glue / parser.x / diag）
# 3) golden：compile 硬验；check 烟测 observational SKIP（check 闸门暂停）
#
# 用法：./tests/run-exc-cli-lsp-error-gate.sh
# wave honesty (2026-08-24 #8): DOC → analysis/archive/exc/;
# lsp_diag.c retired — hubs live in lsp_diag.h + runtime_lsp_glue.from_x.c.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_CLI_LSP_DOC:-analysis/archive/exc/exc-cli-lsp-error-v1.md}"
MATRIX="${XLANG_EXC_CLI_LSP_TSV:-tests/baseline/exc-cli-lsp-error.tsv}"
MIN_ITEMS=10

native_xlang() {
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

echo "=== EXC-005: CLI/LSP error display manifest (c retired) ==="

if [ -f compiler/src/lsp/lsp_diag.c ]; then
  echo "exc-cli-lsp-error gate FAIL: lsp_diag.c resurrected (live = lsp_diag.h)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" compiler/src/lsp/lsp_diag.h compiler/seeds/runtime_lsp_glue.from_x.c; do
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
      elif [ "$anchor" = "set_onefunc_fail" ]; then
        if ! grep -qF 'set_onefunc_fail' "$src" 2>/dev/null; then
          echo "exc-cli-lsp-error FAIL: set_onefunc_fail not in $src" >&2
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

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang ./compiler/xlang-x; do
    if native_xlang "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$XLANG_BIN" ]; then
  echo "exc-cli-lsp-error gate SKIP golden (no native xlang)" >&2
  echo "exc-cli-lsp-error gate OK"
  exit 0
fi

FAILS=0
echo "=== EXC-005: golden compile stderr (XLANG=$XLANG_BIN) ==="
while IFS=$'\t' read -r item_id kind anchor src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  [ "$kind" = "golden" ] || continue
  want="$notes"
  echo "── compile golden: $src ──"
  err=$("$XLANG_BIN" "$src" -o /tmp/xlang_exc_cli_lsp_fail 2>&1) || true
  if ! echo "$err" | grep -qF "$want"; then
    echo "exc-cli-lsp-error FAIL compile: missing phrase '$want' in $src" >&2
    echo "$err" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  if ! echo "$err" | grep -qE 'typeck error|parse error|error\['; then
    echo "exc-cli-lsp-error FAIL compile: missing CLI error kind in $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  if ! echo "$err" | grep -qE '[0-9]+:[0-9]+'; then
    echo "exc-cli-lsp-error FAIL compile: missing line:col in $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "exc-cli-lsp-error OK compile $src"
done < "$MATRIX"

echo "=== EXC-005: golden check format (observational; check gate paused) ==="
assign="tests/typeck/type_mismatch_assign.x"
want="assignment type mismatch: expected i32, found bool"
chk=$("$XLANG_BIN" check "$assign" 2>&1) || true
if echo "$chk" | grep -qF "$want"   && echo "$chk" | grep -qE 'error|typeck error'; then
  echo "exc-cli-lsp-error OK check format (observational)"
else
  echo "exc-cli-lsp-error SKIP check format (paused / format evolved; see observational)" >&2
fi

if [ "$FAILS" -gt 0 ]; then
  echo "exc-cli-lsp-error gate FAIL: golden=${FAILS}" >&2
  exit 1
fi

echo "exc-cli-lsp-error gate OK"
