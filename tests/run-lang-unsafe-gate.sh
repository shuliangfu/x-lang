#!/usr/bin/env bash
# LANG-007：unsafe 语法与边界门禁
#
# 读取 tests/baseline/lang-unsafe-api.tsv：
#   policy=run          — 编译运行 .x
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
  tests/unsafe/allow_padding_ok.x \
  tests/unsafe/padding_rejected.x \
  tests/unsafe/raw_ptr_null.x \
  tests/unsafe/extern_putchar.x \
  tests/unsafe/unsafe_block_deref_ok.x \
  tests/unsafe/deref_outside_unsafe_fail.x \
  tests/unsafe/extern_outside_unsafe_fail.x; do
  if [ ! -f "$f" ]; then
    echo "lang-unsafe gate FAIL: missing $f" >&2
    exit 1
  fi
done
# U4：unsafe 关键字须在 lexer 保留列表中
if ! grep -q '"unsafe"' compiler/src/asm/parser_asm_emit_heavy_stretch_slice.c 2>/dev/null \
  && ! grep -q 'unsafe' compiler/src/lexer/token.x 2>/dev/null; then
  echo "lang-unsafe gate FAIL: unsafe keyword not reserved in lexer" >&2
  exit 1
fi
echo "lang-unsafe manifest OK"

# bstrict / W3：stage2 shux_asm(2) 用于 asm -o；但真机仅 git pull 源码后，陈旧 shux_asm2 可能落后于新刷出的 shux/shux_asm。
# 因此默认选 native 候选里“最新”的一个，避免 gate 继续绑定旧 gen2。
# 若调用方已设 SHUX，则绝不 make 重建（防内存打爆 / 超时）。
SHUX_BIN=""
if [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ]; then
  SHUX_BIN="${SHUX}"
else
  # 仅在未指定 SHUX 时尝试轻量 ensure shux-c（-q 已最新则不重建）
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  for cand in ./compiler/shux_asm2 ./compiler/shux_asm ./compiler/shux; do
    if [ -x "$cand" ] && native_shu "$cand"; then
      if [ -z "$SHUX_BIN" ] || [ "$cand" -nt "$SHUX_BIN" ]; then
        SHUX_BIN="$cand"
      fi
    fi
  done
  if [ -z "$SHUX_BIN" ]; then
    for cand in ./compiler/shux-c; do
      if [ -x "$cand" ] && native_shu "$cand"; then
        SHUX_BIN="$cand"
        break
      fi
    done
  fi
fi
if [ -z "$SHUX_BIN" ] && [ "$(uname -s)" = Linux ] && [ -x ./compiler/shux-c ]; then
  SHUX_BIN=./compiler/shux-c
fi

if [ -z "$SHUX_BIN" ]; then
  echo "lang-unsafe gate SKIP bench (no native shux)" >&2
  exit 0
fi

# 单条 compile/run 超时（秒），避免 asm -o 挂死占满 CPU。
SHUX_CASE_TIMEOUT="${SHUX_CASE_TIMEOUT:-120}"
run_timeout_case() {
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=15 "$SHUX_CASE_TIMEOUT" "$@" || {
      local ec=$?
      [ "$ec" -eq 124 ] && echo "lang-unsafe FAIL: timeout after ${SHUX_CASE_TIMEOUT}s: $*" >&2
      return "$ec"
    }
  else
    "$@"
  fi
}

run_x_case() {
  local script="$1"
  local want_ec="$2"
  local src="tests/unsafe/${script}"
  local out="/tmp/shux_unsafe_${script%.x}"
  if [ ! -f "$src" ]; then
    echo "lang-unsafe FAIL: missing $src" >&2
    return 1
  fi
  # LANG-007：relink seed 的 asm -o 路径 x parse 回归中；`-backend c` 与 check 同走 C 前端（unsafe 边界已覆盖）。
  if ! run_timeout_case "$SHUX_BIN" -backend c -L . "$src" -o "$out" >/tmp/shux_unsafe_compile.log 2>&1; then
    cat /tmp/shux_unsafe_compile.log >&2
    return 1
  fi
  local ec=0
  run_timeout_case "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "lang-unsafe FAIL $script: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

compile_fail_case() {
  local script="$1"
  local src="tests/unsafe/${script}"
  local err="/tmp/shux_unsafe_fail_compile.log"
  if [ ! -f "$src" ]; then
    echo "lang-unsafe FAIL: missing $src" >&2
    return 1
  fi
  # asm -o 历史上 skip_typeck 会漏掉 implicit padding；check 与 compile 的 typeck 路径对齐且更稳。
  if run_timeout_case "$SHUX_BIN" check -L . "$src" >"$err" 2>&1; then
    echo "lang-unsafe FAIL $script: expected compile error" >&2
    return 1
  fi
  if ! grep -qE 'implicit padding|typeck error|requires unsafe block' "$err"; then
    echo "lang-unsafe FAIL $script: stderr missing implicit padding/typeck/unsafe error" >&2
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
      if run_x_case "$script" "${want_ec:-0}"; then
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
      # struct 回归：typeck 走 seed shux；-o 链接仍由 bootstrap-link-shux 选 shux-c（Docker 上 seed -o 易 SIGSEGV）。
      hook_env=()
      if [ "$script" = "run-struct.sh" ] && [ -x ./compiler/shux ]; then
        hook_env=(SHUX=./compiler/shux)
      fi
      if run_timeout_case env "${hook_env[@]}" SHUX="$SHUX_BIN" "$hook"; then
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

echo "=== G-FFI-5: std/ffi + std/sys unsafe wrap hook ==="
chmod +x tests/run-g-ffi-5-std-wrap-gate.sh 2>/dev/null || true
if env SHUX="$SHUX_BIN" ./tests/run-g-ffi-5-std-wrap-gate.sh; then
  echo "lang-unsafe G-FFI-5 hook OK"
else
  echo "lang-unsafe gate FAIL: G-FFI-5 std wrap" >&2
  exit 1
fi

echo "lang-unsafe gate OK"
