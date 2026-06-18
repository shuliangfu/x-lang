#!/usr/bin/env bash
# tst-003-std-roundtrip.sh — TST-003：round-trip 向量库辅助
#
# 用法（source 后）：
#   tst003_verify_manifest TSV
#   tst003_ensure_o REL_O
#   tst003_run_vector SHU_BIN TEST_PATH TAG
#   tst003_emit_report status vectors pass skip

TST003_PREFIX="${SHU_TST003_ROUNDTRIP_PREFIX:-shu: [SHU_TST003_ROUNDTRIP]}"

# 校验 manifest 中 roundtrip 行文件存在；echo 缺失数。
tst003_verify_manifest() {
  local tsv="$1"
  local miss=0
  local item_id kind _mod test_path _needs_o
  while IFS=$'\t' read -r item_id kind _mod test_path _needs_o _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|lib|gate) continue ;; esac
    case "$kind" in
      roundtrip)
        if [ ! -f "$test_path" ]; then
          echo "tst-003-roundtrip FAIL: missing test '$test_path' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$test_path" ]; then
          echo "tst-003-roundtrip FAIL: missing file '$test_path'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 按需构建 std C .o（相对 repo 根路径，如 std/csv/csv.o）。
tst003_ensure_o() {
  local rel="$1"
  [ -z "$rel" ] || [ "$rel" = "-" ] && return 0
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o "$rel"
}

# 编译运行烟测；0=成功，2=链接环境 SKIP（如缺 libzstd），1=硬失败。
tst003_run_vector() {
  local shu="$1"
  local test_path="$2"
  local tag="$3"
  local exe="/tmp/shu_tst003_rt_${tag}_$$"
  local log="/tmp/shu_tst003_build_${tag}_$$.log"
  if [ ! -f "$test_path" ]; then
    echo "tst-003-roundtrip FAIL: missing $test_path" >&2
    return 1
  fi
  if ! "$shu" check -L . "$test_path" >/dev/null 2>&1; then
    echo "tst-003-roundtrip FAIL: typeck $test_path" >&2
    "$shu" check -L . "$test_path" 2>&1 | tail -8 >&2 || true
    return 1
  fi
  if ! "$shu" -L . "$test_path" -o "$exe" >"$log" 2>&1; then
    if grep -qE "library 'zstd' not found|cannot find -lzstd" "$log" 2>/dev/null; then
      rm -f "$exe" "$log"
      return 2
    fi
    echo "tst-003-roundtrip FAIL: compile $test_path" >&2
    tail -8 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  rm -f "$log"
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "tst-003-roundtrip FAIL: run $test_path exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
tst003_emit_report() {
  local status="$1"
  local vectors="$2"
  local pass="$3"
  local skip="$4"
  echo "${TST003_PREFIX} status=${status} vectors=${vectors} pass=${pass} skip=${skip}"
}
