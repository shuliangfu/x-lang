#!/usr/bin/env bash
# tst-001-boundary.sh — TST-001 边界用例 manifest 与烟测辅助
#
# 用法（source 后）：
#   tst001_count_cases X MIN
#   tst001_verify_manifest TSV
#   tst001_run_boundary XLANG_BIN X OUT
#   tst001_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

TST001_PREFIX="${XLANG_TST001_BOUNDARY_PREFIX:-xlang: [XLANG_TST001_BOUNDARY]}"

# Count live boundary vectors: unique nonzero `return N` exit codes.
# (Historical `// case N` markers were stripped; exit codes remain the authority.)
tst001_count_cases() {
  local x="$1"
  local min="$2"
  local n
  n="$(grep -oE 'return [1-9][0-9]*' "$x" 2>/dev/null | sort -u | wc -l | tr -d '[:space:]')"
  n="${n:-0}"
  if [ "$n" -lt "$min" ]; then
    echo "TST-001 FAIL: $x has ${n} unique nonzero returns, want >= ${min}" >&2
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
  local xlang="$1"
  local x="$2"
  local out="$3"
  rm -f "$out"
  if ! "$xlang" -L . "$x" -o "$out" >/tmp/tst001_smoke.log 2>&1; then
    cat /tmp/tst001_smoke.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "TST-001 FAIL: $x exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
tst001_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${TST001_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
