#!/usr/bin/env bash
# tst-001-boundary.sh — TST-001 边界用例 manifest 与烟测辅助
#
# 用法（source 后）：
#   tst001_count_cases SX MIN
#   tst001_verify_manifest TSV
#   tst001_run_boundary SHUX_BIN SX OUT
#   tst001_emit_report status io_ok fs_ok net_ok str_ok skip

TST001_PREFIX="${SHUX_TST001_BOUNDARY_PREFIX:-shux: [SHUX_TST001_BOUNDARY]}"

# 统计「case N」注释行数；不足 min 时返回 1。
tst001_count_cases() {
  local sx="$1"
  local min="$2"
  local n
  n="$(grep -cE '// case [0-9]+' "$sx" 2>/dev/null || echo 0)"
  if [ "$n" -lt "$min" ]; then
    echo "TST-001 FAIL: $sx has ${n} cases, want >= ${min}" >&2
    return 1
  fi
  echo "$n"
  return 0
}

# 校验 manifest 文件条目存在；echo 缺失数。
tst001_verify_manifest() {
  local tsv="$1"
  local miss=0
  local item_id kind path min_cases _mod _notes
  while IFS=$'\t' read -r item_id kind path min_cases _mod _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      boundary|file)
        if [ ! -f "$path" ]; then
          echo "TST-001 FAIL: missing $path ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$path" ]; then
          echo "TST-001 FAIL: missing gate $path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行边界烟测；成功返回 0。
tst001_run_boundary() {
  local shux="$1"
  local sx="$2"
  local out="$3"
  rm -f "$out"
  if ! "$shux" -L . "$sx" -o "$out" >/tmp/tst001_smoke.log 2>&1; then
    cat /tmp/tst001_smoke.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "TST-001 FAIL: $sx exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
tst001_emit_report() {
  local status="$1"
  local io_ok="$2"
  local fs_ok="$3"
  local net_ok="$4"
  local str_ok="$5"
  local skip="$6"
  echo "${TST001_PREFIX} status=${status} io=${io_ok} fs=${fs_ok} net=${net_ok} str=${str_ok} skip=${skip}"
}
