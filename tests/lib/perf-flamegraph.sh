#!/usr/bin/env bash
# perf-flamegraph.sh — PERF-005 共享：Linux perf 采样 + Top-N 符号报告
#
# 用法（source 后调用）：
#   perf_fg_resolve_bin          # 打印 perf 路径或失败
#   perf_fg_probe_ok             # perf record 是否可用
#   perf_fg_top_symbols CASE CMD...  # 采样并输出 Top-N TSV 行
#
# 环境：
#   SHU_PERF_FLAMEGRAPH_TOPN — Top 行数（默认 20）
#   SHU_PERF_FLAMEGRAPH_FREQ  — 采样频率 Hz（默认 997）
#   SHU_PERF_FLAMEGRAPH_PREFIX — stderr 前缀（默认 shu: [SHU_PERF_FLAMEGRAPH]）

# 解析 perf 可执行路径（GHA 常仅 linux-tools-* 目录下有 perf）。
perf_fg_resolve_bin() {
  local p
  if command -v perf >/dev/null 2>&1; then
    command -v perf
    return 0
  fi
  for p in /usr/lib/linux-tools/*/perf; do
    if [ -x "$p" ]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

# 探测 perf record 是否在本机可用（含 paranoid 放宽）。
perf_fg_probe_ok() {
  local perf_bin tmpdata
  [ "$(uname -s)" = "Linux" ] || return 1
  perf_bin="$(perf_fg_resolve_bin)" || return 1
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  tmpdata="$(mktemp -t shu-perf-fg-probe.XXXXXX.data)"
  if "$perf_bin" record -F 99 -o "$tmpdata" -- true 2>/dev/null; then
    rm -f "$tmpdata"
    return 0
  fi
  rm -f "$tmpdata"
  return 1
}

# 对给定命令 perf record，解析 perf report 输出 Top-N 符号（按 overhead% 降序）。
# 参数：case_id 以及要执行的完整命令（含可执行文件路径）。
#  stdout：case_id\trank\tpct\tsymbol  TSV；stderr：带 PREFIX 的摘要行。
perf_fg_top_symbols() {
  local case_id="$1"
  shift
  local perf_bin topn freq prefix tmpdata tmpreport rows
  topn="${SHU_PERF_FLAMEGRAPH_TOPN:-20}"
  freq="${SHU_PERF_FLAMEGRAPH_FREQ:-997}"
  prefix="${SHU_PERF_FLAMEGRAPH_PREFIX:-shu: [SHU_PERF_FLAMEGRAPH]}"
  perf_bin="$(perf_fg_resolve_bin)" || {
    echo "${prefix} case=${case_id} error=no_perf" >&2
    return 1
  }
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  tmpdata="$(mktemp -t "shu-perf-fg-${case_id}.XXXXXX.data")"
  tmpreport="$(mktemp -t "shu-perf-fg-${case_id}.XXXXXX.report")"
  # -g dwarf：便于后续 flamegraph.pl；Top-N 仍从 symbol 聚合报告读取。
  if ! "$perf_bin" record -F "$freq" -g --call-graph dwarf,4096 -o "$tmpdata" -- "$@" 2>/dev/null; then
    rm -f "$tmpdata" "$tmpreport"
    echo "${prefix} case=${case_id} error=record_failed" >&2
    return 1
  fi
  "$perf_bin" report -i "$tmpdata" --stdio -n --sort=symbol --percent-limit=0 \
    >"$tmpreport" 2>/dev/null || true
  rows=0
  # perf report 符号行形如：  12.34%  shu-c  [.] symbol_name
  while IFS= read -r line; do
    case "$line" in
      *"%"*)
        pct=$(echo "$line" | awk '{gsub(/%/,"",$1); print $1}')
        sym=$(echo "$line" | awk '{print $NF}')
        case "$pct" in
          ''|*[!0-9.]*)
            continue
            ;;
        esac
        case "$sym" in
          ''|'['*|']'*) continue ;;
        esac
        rows=$((rows + 1))
        printf '%s\t%d\t%s\t%s\n' "$case_id" "$rows" "$pct" "$sym"
        if [ "$rows" -ge "$topn" ]; then
          break
        fi
        ;;
    esac
  done < "$tmpreport"
  rm -f "$tmpdata" "$tmpreport"
  echo "${prefix} case=${case_id} top${topn}_done rows=${rows}" >&2
  if [ "$rows" -lt "$topn" ]; then
    echo "${prefix} case=${case_id} warn=rows_lt_topn got=${rows} want=${topn}" >&2
    return 2
  fi
  return 0
}

# 若系统存在 FlameGraph 工具链，从 perf.data 生成 SVG（可选；失败不致命）。
perf_fg_try_svg() {
  local perf_bin data_path svg_path collapse fg
  perf_bin="$(perf_fg_resolve_bin)" || return 1
  data_path="$1"
  svg_path="$2"
  collapse="$(command -v stackcollapse-perf.pl 2>/dev/null || true)"
  fg="$(command -v flamegraph.pl 2>/dev/null || true)"
  [ -n "$collapse" ] && [ -n "$fg" ] || return 1
  "$perf_bin" script -i "$data_path" 2>/dev/null | "$collapse" | "$fg" >"$svg_path" 2>/dev/null
}
