#!/usr/bin/env bash
# lang-const-eval.sh — LANG-006 CTFE 共享 runner
#
# 用法：
#   ./tests/lib/lang-const-eval.sh           # 全量 case（需 native shux）
#   ./tests/lib/lang-const-eval.sh case_id   # 单 case（manifest item_id）
set -e
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

MANIFEST="${SHUX_LANG_CONST_EVAL_MANIFEST:-tests/baseline/lang-const-eval.tsv}"
ONE="${1:-}"

# 判断本机能否直接执行给定 shux 二进制
lang_const_eval_native_shu() {
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

# 解析可用 shux；失败返回 2
lang_const_eval_resolve_shu() {
  if [ -n "${SHUX:-}" ] && lang_const_eval_native_shu "$SHUX"; then
    echo "$SHUX"
    return 0
  fi
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if lang_const_eval_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 2
}

# 编译运行 .sx 并校验退出码
lang_const_eval_run_sx() {
  local shux="$1"
  local src="$2"
  local want="$3"
  local tag="$4"
  local out="/tmp/shux_lang_const_${tag}"
  if [ ! -f "$src" ]; then
    echo "lang-const-eval FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$out" >/tmp/shux_lang_const_compile.log 2>&1; then
    cat /tmp/shux_lang_const_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want" ]; then
    echo "lang-const-eval FAIL $tag: exit=$ec want=$want" >&2
    return 1
  fi
  return 0
}

# 从 manifest notes 解析 exit N
lang_const_eval_want_exit() {
  local notes="$1"
  case "$notes" in
    *exit\ [0-9]*) echo "$notes" | sed -n 's/.*exit \([0-9][0-9]*\).*/\1/p' | head -1 ;;
    *) echo "0" ;;
  esac
}

# 主入口：全量或单 case runnable
lang_const_eval_main() {
  local ONE="${1:-}"
  local SHUX_BIN=""
  if ! SHUX_BIN="$(lang_const_eval_resolve_shu)"; then
    echo "lang-const-eval: no native shux (SKIP runnable)" >&2
    return 2
  fi

  make -C compiler -q 2>/dev/null || make -C compiler

  local FAILS=0
  local RAN=0
  while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      case)
        if [ -n "$ONE" ] && [ "$item_id" != "$ONE" ]; then
          continue
        fi
        local want
        want="$(lang_const_eval_want_exit "${notes:-}")"
        RAN=$((RAN + 1))
        echo "── lang-const-eval $item_id (want=$want) ──"
        if lang_const_eval_run_sx "$SHUX_BIN" "$src" "$want" "$item_id"; then
          echo "lang-const-eval OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
      script)
        if [ -n "$ONE" ] && [ "$item_id" != "$ONE" ]; then
          continue
        fi
        RAN=$((RAN + 1))
        echo "── lang-const-eval hook $item_id ──"
        chmod +x "$src" 2>/dev/null || true
        if SHUX="$SHUX_BIN" "$src"; then
          echo "lang-const-eval OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"

  if [ -n "$ONE" ] && [ "$RAN" -eq 0 ]; then
    echo "lang-const-eval FAIL: unknown item_id=$ONE" >&2
    return 1
  fi

  if [ "$FAILS" -gt 0 ]; then
    echo "lang-const-eval runner FAIL: ${FAILS} case(s)" >&2
    return 1
  fi
  echo "lang-const-eval runner OK (${RAN} runnable)"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  lang_const_eval_main "${1:-}"
  exit $?
fi
