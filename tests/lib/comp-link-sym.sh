#!/usr/bin/env bash
# comp-link-sym.sh — COMP-008 链接符号冲突分类共享库
#
# 在 BOOT-004 粗粒度 stage=link 之上，解析 undefined / duplicate 并输出归因变量。
# 用法：
#   . tests/lib/comp-link-sym.sh
#   comp_link_sym_classify "$(cat ci.log)"
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
PATTERNS="${SHUX_LINK_SYM_PATTERNS:-$ROOT/tests/baseline/comp-link-sym-patterns.tsv}"

# 剥 Mach-O 前导下划线，便于与 manifest 期望比对。
comp_link_sym_normalize() {
  local s="${1:-}"
  s="${s#_}"
  printf '%s' "$s"
}

# 从 log 文本提取首个 .o/.a 路径（用于 L4-object 归因）。
comp_link_sym_extract_object() {
  local log="$1"
  printf '%s' "$log" | grep -Eo '[A-Za-z0-9_./-]+\.(o|a)' | head -1 || true
}

# 从 log 按常见 ld 文案提取符号名（兜底，模式表未捕获时）。
comp_link_sym_guess_symbol() {
  local log="$1"
  local sym=""
  sym="$(printf '%s' "$log" | grep -Eo "undefined symbol: _?[A-Za-z0-9_]+" | head -1 | sed 's/undefined symbol: //' || true)"
  if [ -z "$sym" ]; then
    sym="$(printf '%s' "$log" | grep -Eo "duplicate symbol '_?[A-Za-z0-9_]+'" | head -1 | sed "s/duplicate symbol '//;s/'$//" || true)"
  fi
  if [ -z "$sym" ]; then
    sym="$(printf '%s' "$log" | grep -Eo 'multiple definition of `?_?[A-Za-z0-9_]+' | head -1 | sed 's/multiple definition of `//;s/`.*//' || true)"
  fi
  if [ -z "$sym" ]; then
    sym="$(printf '%s' "$log" | grep -Eo 'undefined: [A-Za-z0-9_]+' | head -1 | sed 's/undefined: //' || true)"
  fi
  comp_link_sym_normalize "$sym"
}

# 对整段 linker log 分类；stdout 输出 SHUX_LINK_* 变量（可 source）。
comp_link_sym_classify() {
  local log="$1"
  local best_prio=999999
  local best_kind=""
  local best_hint=""
  local best_repro=""
  local best_pid=""
  local best_symbol=""

  if [ ! -f "$PATTERNS" ]; then
    echo "comp-link-sym FAIL: missing patterns $PATTERNS" >&2
    return 1
  fi

  while IFS=$'\t' read -r pid regex kind hint repro prio _notes; do
    [ -z "${pid:-}" ] && continue
    case "$pid" in \#*) continue ;; esac
    [ -z "${regex:-}" ] && continue
    if printf '%s' "$log" | grep -qE "$regex"; then
      local p="${prio:-999}"
      if [ "$p" -lt "$best_prio" ]; then
        best_prio="$p"
        best_kind="$kind"
        best_hint="$hint"
        best_repro="$repro"
        best_pid="$pid"
      fi
    fi
  done < "$PATTERNS"

  if [ -z "$best_kind" ]; then
    echo "SHUX_LINK_KIND=unknown"
    echo "SHUX_LINK_SYMBOL="
    echo "SHUX_LINK_HINT=unclassified"
    echo "SHUX_LINK_REPRO=full_ci"
    echo "SHUX_LINK_PATTERN="
    echo "SHUX_LINK_OBJECT="
    echo "SHUX_LINK_CONFIDENCE=low"
    echo "comp-link-sym: no pattern match" >&2
    return 1
  fi

  best_symbol="$(comp_link_sym_guess_symbol "$log")"

  local obj=""
  obj="$(comp_link_sym_extract_object "$log")"

  echo "SHUX_LINK_KIND=$best_kind"
  if [ -n "$best_symbol" ]; then
    echo "SHUX_LINK_SYMBOL=$best_symbol"
  else
    echo "SHUX_LINK_SYMBOL="
  fi
  echo "SHUX_LINK_HINT=$best_hint"
  echo "SHUX_LINK_REPRO=$best_repro"
  echo "SHUX_LINK_PATTERN=$best_pid"
  if [ -n "$obj" ]; then
    echo "SHUX_LINK_OBJECT=$obj"
  else
    echo "SHUX_LINK_OBJECT="
  fi
  echo "SHUX_LINK_CONFIDENCE=classified"
  echo "comp-link-sym: kind=$best_kind symbol=${best_symbol:-?} hint=$best_hint repro=$best_repro" >&2
  return 0
}
