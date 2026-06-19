#!/usr/bin/env bash
# LANG-007：unsafe 语法与边界门禁
#
# 读取 tests/baseline/lang-unsafe-api.tsv：
#   policy=run          — 编译运行 .sx
#   policy=compile_fail — 编译须失败且 stderr 含 implicit padding
#   policy=hook         — 调用 tests/run-*.sh
#
# 用法：./tests/run-lang-unsafe-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_LANG_UNSAFE_TSV:-tests/baseline/lang-unsafe-api.tsv}"

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

echo "=== LANG-007: unsafe boundary manifest ==="
for f in \
  analysis/lang-unsafe-v1-rfc.md \
  analysis/type-region-v1-rfc.md \
  "$MATRIX" \
  tests/unsafe/allow_padding_ok.sx \
  tests/unsafe/padding_rejected.sx \
  tests/unsafe/raw_ptr_null.sx \
  tests/unsafe/extern_putchar.sx; do
  if [ ! -f "$f" ]; then
    echo "lang-unsafe gate FAIL: missing $f" >&2
    exit 1
  fi
done
# U4：unsafe 关键字须在 lexer 保留列表中
if ! grep -q '"unsafe"' compiler/src/asm/parser_asm_emit_heavy_stretch_slice.c 2>/dev/null \
  && ! grep -q 'unsafe' compiler/src/lexer/token.sx 2>/dev/null; then
  echo "lang-unsafe gate FAIL: unsafe keyword not reserved in lexer" >&2
  exit 1
fi
echo "lang-unsafe manifest OK"

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
  echo "lang-unsafe gate SKIP bench (no native shux)" >&2
  exit 0
fi

run_sx_case() {
  local script="$1"
  local want_ec="$2"
  local src="tests/unsafe/${script}"
  local out="/tmp/shux_unsafe_${script%.sx}"
  if [ ! -f "$src" ]; then
    echo "lang-unsafe FAIL: missing $src" >&2
    return 1
  fi
  if ! "$SHUX_BIN" -L . "$src" -o "$out" >/tmp/shux_unsafe_compile.log 2>&1; then
    cat /tmp/shux_unsafe_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "lang-unsafe FAIL $script: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

compile_fail_case() {
  local script="$1"
  local src="tests/unsafe/${script}"
  local out="/tmp/shux_unsafe_fail_${script%.sx}"
  local err="/tmp/shux_unsafe_fail_compile.log"
  if [ ! -f "$src" ]; then
    echo "lang-unsafe FAIL: missing $src" >&2
    return 1
  fi
  if "$SHUX_BIN" -L . "$src" -o "$out" >"$err" 2>&1; then
    echo "lang-unsafe FAIL $script: expected compile error" >&2
    return 1
  fi
  if ! grep -qE 'implicit padding|typeck error' "$err"; then
    echo "lang-unsafe FAIL $script: stderr missing implicit padding/typeck error" >&2
    cat "$err" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== LANG-007: unsafe boundary smoke (SHUX=$SHUX_BIN) ==="

while IFS=$'\t' read -r case_id mode script policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  echo "── $case_id [$mode]: $notes ──"
  case "$policy" in
    run)
      if run_sx_case "$script" "${want_ec:-0}"; then
        echo "lang-unsafe OK $case_id"
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    compile_fail)
      if compile_fail_case "$script"; then
        echo "lang-unsafe OK $case_id (compile_fail)"
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      hook="tests/${script}"
      chmod +x "$hook" 2>/dev/null || true
      if SHUX="$SHUX_BIN" "$hook"; then
        echo "lang-unsafe OK $case_id ($script)"
      else
        echo "lang-unsafe FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    *)
      echo "lang-unsafe WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "lang-unsafe gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "lang-unsafe gate OK"
