#!/usr/bin/env bash
# tst-004-std-sanitize.sh — TST-004：std ASAN 夜跑辅助
#
# 用法（source 后）：
#   tst004_sanitize_ensure_o rel_o
#   tst004_sanitize_run_case SHUX_BIN src tag
#   tst004_sanitize_verify_manifest TSV
#   tst004_sanitize_emit_report status cases_ok cases_fail skip

TST004_SAN_PREFIX="${SHUX_TST004_SANITIZE_PREFIX:-shux: [SHUX_TST004_SANITIZE]}"

# shellcheck source=tests/lib/safe-leak.sh
. "$(dirname "${BASH_SOURCE[0]}")/safe-leak.sh"

# 按需构建 std C .o（相对 compiler/Makefile）。
tst004_sanitize_ensure_o() {
  local rel="$1"
  [ -z "$rel" ] || [ "$rel" = "-" ] && return 0
  # shellcheck source=tests/lib/build-std-c-o.sh
  . "$(dirname "${BASH_SOURCE[0]}")/build-std-c-o.sh"
  ensure_std_c_o "$rel"
}

# 以 ASAN 编译并运行单个 .sx；成功 0，失败 1。
tst004_sanitize_run_case() {
  local shux="$1"
  local src="$2"
  local tag="${3:-case}"
  safe_leak_run_su "$shux" "$src" "$tag"
}

# 校验 manifest 文件与 case 行；echo 缺失数。
tst004_sanitize_verify_manifest() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor src needs_o
  while IFS=$'\t' read -r item_id kind anchor src needs_o _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|lib|runner|gate) continue ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "analysis/tst-004-std-sanitize-v1.md" 2>/dev/null; then
          echo "tst-004-sanitize FAIL: doc missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      case)
        if [ ! -f "$src" ]; then
          echo "tst-004-sanitize FAIL: missing case $src" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "tst-004-sanitize FAIL: missing xref $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$src" ]; then
          echo "tst-004-sanitize FAIL: missing script $src" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
tst004_sanitize_emit_report() {
  local status="$1"
  local cases_ok="$2"
  local cases_fail="$3"
  local skip="$4"
  echo "${TST004_SAN_PREFIX} status=${status} cases_ok=${cases_ok} cases_fail=${cases_fail} skip=${skip}"
}
