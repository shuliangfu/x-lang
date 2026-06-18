#!/usr/bin/env bash
# perf-cache-miss.sh — PERF-006 共享：Linux perf L1 miss 测量与报告行
#
# 用法（source 后）：
#   perf_cm_probe_ok
#   perf_cm_l1_miss_pct /path/to/exe
#   perf_cm_report_emit case_id layout miss_pct cap_pct ok_flag
#
# 环境：
#   SHU_CACHE_MISS_PREFIX — 默认 shu: [SHU_CACHE_MISS]

# 解析 perf 可执行路径（GHA 常仅 linux-tools-* 目录下有 perf）。
perf_cm_resolve_bin() {
  local p
  if command -v perf >/dev/null 2>&1; then
    command -v perf
    return 0
  fi
  for p in /usr/lib/linux-tools/*/perf; do
    if [ -x "$p" ]; then
      printf '%s' "$p"
      return 0
    fi
  done
  return 1
}

# perf stat 是否可用于 L1 事件。
perf_cm_probe_ok() {
  local perf_cmd out loads misses pair
  [ "$(uname -s)" = "Linux" ] || return 1
  perf_cmd="$(perf_cm_resolve_bin)" || return 1
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  pair=$(perf_cm_stat_load_miss_pair "$perf_cmd" /bin/true "L1-dcache-loads" "L1-dcache-load-misses")
  loads="${pair%% *}"
  misses="${pair#* }"
  [ -n "$loads" ] && [ -n "$misses" ]
}

# perf stat -x, CSV：取 event 对应计数值。
perf_cm_csv_event_count() {
  local out="$1"
  local event="$2"
  echo "$out" | awk -F, -v ev="$event" '
    index($0, ev) && $1 ~ /^[0-9][0-9,]*$/ {
      gsub(/,/, "", $1)
      print $1
      exit
    }
  '
}

# 默认文本输出：取含 event 行中首个正整数。
perf_cm_text_event_count() {
  local out="$1"
  local event="$2"
  echo "$out" | awk -v ev="$event" '
    index($0, ev) && $0 !~ /not supported|not counted|<not/ {
      for (i = 1; i <= NF; i++) {
        gsub(/,/, "", $i)
        if ($i ~ /^[0-9]+$/ && $i + 0 > 0) {
          print $i
          exit
        }
      }
    }
  '
}

# 跑 perf stat 并解析 loads/misses；失败时 loads/misses 为空。
perf_cm_stat_load_miss_pair() {
  local perf_cmd="$1"
  local exe="$2"
  local ev_load="$3"
  local ev_miss="$4"
  local out loads misses
  out=$("$perf_cmd" stat -x, -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
  if echo "$out" | grep -qiE 'Permission denied|perf_event_paranoid'; then
    if command -v sudo >/dev/null 2>&1; then
      out=$(sudo "$perf_cmd" stat -x, -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
    fi
  fi
  loads=$(perf_cm_csv_event_count "$out" "$ev_load")
  misses=$(perf_cm_csv_event_count "$out" "$ev_miss")
  if [ -z "$loads" ] || [ -z "$misses" ]; then
    out=$("$perf_cmd" stat -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
    loads=$(perf_cm_text_event_count "$out" "$ev_load")
    misses=$(perf_cm_text_event_count "$out" "$ev_miss")
  fi
  printf '%s %s' "$loads" "$misses"
}

# 对可执行文件测 L1 miss 率（%）；失败打印 nan。
perf_cm_l1_miss_pct() {
  local exe="$1"
  local perf_cmd loads misses pct pair
  perf_cmd="$(perf_cm_resolve_bin)" || { echo "nan"; return; }
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  pair=$(perf_cm_stat_load_miss_pair "$perf_cmd" "$exe" "L1-dcache-loads" "L1-dcache-load-misses")
  loads="${pair%% *}"
  misses="${pair#* }"
  if [ -z "$loads" ] || [ -z "$misses" ]; then
    pair=$(perf_cm_stat_load_miss_pair "$perf_cmd" "$exe" "cache-references" "cache-misses")
    loads="${pair%% *}"
    misses="${pair#* }"
  fi
  if [ -z "$loads" ] || [ -z "$misses" ] || [ "$loads" = "0" ]; then
    echo "nan"
    return
  fi
  pct=$(awk -v m="$misses" -v l="$loads" 'BEGIN { printf "%.4f", (m/l)*100.0 }')
  echo "$pct"
}

# 输出结构化 cache miss 报告行（OBS-003 bracket 兼容）。
perf_cm_report_emit() {
  local case_id="$1"
  local layout="$2"
  local miss_pct="$3"
  local cap_pct="$4"
  local ok_flag="$5"
  local prefix="${SHU_CACHE_MISS_PREFIX:-shu: [SHU_CACHE_MISS]}"
  printf '%s case=%s layout=%s l1_miss_pct=%s cap_pct=%s ok=%s\n' \
    "$prefix" "$case_id" "$layout" "$miss_pct" "$cap_pct" "$ok_flag" >&2
}

# dod-soa 兼容别名（历史函数名）。
perf_resolve_bin() { perf_cm_resolve_bin "$@"; }
perf_csv_event_count() { perf_cm_csv_event_count "$@"; }
perf_text_event_count() { perf_cm_text_event_count "$@"; }
perf_stat_load_miss_pair() { perf_cm_stat_load_miss_pair "$@"; }
perf_l1_miss_pct() { perf_cm_l1_miss_pct "$@"; }
