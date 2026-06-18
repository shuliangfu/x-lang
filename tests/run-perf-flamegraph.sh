#!/usr/bin/env bash
# PERF-005：perf 采样 + Top-N 热点报告自动生成
#
# Linux + perf 可用时：对 manifest 用例 perf record，输出 Top-20 符号 TSV。
# 可选：系统有 stackcollapse-perf.pl + flamegraph.pl 时另存 SVG。
#
# 用法：
#   ./tests/run-perf-flamegraph.sh
#   SHU=./compiler/shu-c SHU_PERF_FLAMEGRAPH_CASE=check_typeck ./tests/run-perf-flamegraph.sh
#   SHU_PERF_FLAMEGRAPH_OUT_DIR=/tmp/fg ./tests/run-perf-flamegraph.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHU_PERF_FLAMEGRAPH_TSV:-tests/baseline/perf-flamegraph.tsv}"
OUT_DIR="${SHU_PERF_FLAMEGRAPH_OUT_DIR:-/tmp/shu-perf-flamegraph}"
ONLY_CASE="${SHU_PERF_FLAMEGRAPH_CASE:-}"
TOPN="${SHU_PERF_FLAMEGRAPH_TOPN:-20}"
PREFIX="${SHU_PERF_FLAMEGRAPH_PREFIX:-shu: [SHU_PERF_FLAMEGRAPH]}"

# shellcheck source=tests/lib/perf-flamegraph.sh
. tests/lib/perf-flamegraph.sh

# 判断 shu 是否可在本机 exec。
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

# 解析 manifest anchor 为 perf 采样的 shu 子命令（不含 perf 本身）。
# check：anchor 形如 "check path/to.su"
# compile：anchor 形如 "compile path/to.su -o /tmp/out"
fg_run_profile_case() {
  local item_id="$1"
  local anchor="$2"
  local out_case="$3"
  local log_file="$4"
  local action rest src outpath
  action="${anchor%% *}"
  rest="${anchor#* }"
  case "$action" in
    check)
      perf_fg_top_symbols "$item_id" "$SHU_BIN" check "$rest" >>"$out_case" 2>>"$log_file"
      ;;
    compile)
      src=$(echo "$rest" | awk '{print $1}')
      outpath=$(echo "$rest" | awk '{for(i=1;i<=NF;i++) if($i=="-o") print $(i+1)}')
      perf_fg_top_symbols "$item_id" "$SHU_BIN" "$src" -o "$outpath" >>"$out_case" 2>>"$log_file"
      ;;
    *)
      return 1
      ;;
  esac
}

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ ! -f "$MANIFEST" ]; then
  echo "run-perf-flamegraph: missing manifest $MANIFEST" >&2
  exit 1
fi

if ! perf_fg_probe_ok; then
  echo "${PREFIX} SKIP (perf record unavailable; need Linux + perf)" >&2
  exit 0
fi

if [ -z "$SHU_BIN" ]; then
  echo "${PREFIX} SKIP (no native shu)" >&2
  exit 0
fi

mkdir -p "$OUT_DIR"
SUMMARY="${OUT_DIR}/top${TOPN}-summary.tsv"
: >"$SUMMARY"
echo "${PREFIX} shu=${SHU_BIN} out=${OUT_DIR} topn=${TOPN}" >&2

FAIL=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix|report_header|hook_*|cross_*|smoke_case) continue ;; esac
  case "$kind" in
    profile_case)
      if [ -n "$ONLY_CASE" ] && [ "$item_id" != "$ONLY_CASE" ]; then
        continue
      fi
      action="${anchor%% *}"
      rest="${anchor#* }"
      echo "${PREFIX} profiling case=${item_id} action=${action} ${rest}" >&2
      out_case="${OUT_DIR}/${item_id}-top${TOPN}.tsv"
      if fg_run_profile_case "$item_id" "$anchor" "$out_case" "${OUT_DIR}/${item_id}.log"; then
        cat "$out_case" >>"$SUMMARY"
        echo "${PREFIX} case=${item_id} report=${out_case}" >&2
      else
        rc=$?
        if [ "$rc" -eq 2 ]; then
          echo "${PREFIX} case=${item_id} WARN partial top (see ${out_case})" >&2
          [ -f "$out_case" ] && cat "$out_case" >>"$SUMMARY"
        else
          echo "${PREFIX} case=${item_id} FAIL" >&2
          FAIL=$((FAIL + 1))
        fi
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  echo "run-perf-flamegraph FAIL: ${FAIL} case(s)" >&2
  exit 1
fi
echo "perf-flamegraph OK (summary=${SUMMARY})"
