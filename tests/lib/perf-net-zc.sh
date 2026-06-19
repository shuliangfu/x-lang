#!/usr/bin/env bash
# perf-net-zc.sh — PERF-009 共享：Linux perf cycles/byte 与网络零拷贝报告行
#
# 用法（source 后）：
#   perf_nz_probe_ok
#   perf_nz_stat_cycles CMD...
#   perf_nz_cycles_per_mib CYCLES BYTES
#   perf_nz_read_caps case_id [baseline_tsv]
#   perf_nz_within_cap case_id cycles_per_mib [baseline_tsv]
#   perf_nz_run_echo_cycles client_exe server_c port
#   perf_nz_report_emit case_id cycles bytes cycles_per_mib cap ref_case ref_cpm ok_flag
#
# 环境：
#   SHUX_NET_ZC_PREFIX — 默认 shux: [SHUX_NET_ZC]

# 解析 perf 可执行路径。
perf_nz_resolve_bin() {
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

# perf stat 是否可用于 cycles 事件。
perf_nz_probe_ok() {
  local perf_cmd out cycles
  [ "$(uname -s)" = "Linux" ] || return 1
  perf_cmd="$(perf_nz_resolve_bin)" || return 1
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  out=$("$perf_cmd" stat -x, -e cycles -- /bin/true 2>&1 || true)
  cycles=$(perf_nz_csv_event_count "$out" "cycles")
  [ -n "$cycles" ] && [ "$cycles" != "0" ]
}

# perf stat -x, CSV：取 event 计数值。
perf_nz_csv_event_count() {
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
perf_nz_text_event_count() {
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

# 对命令跑 perf stat cycles；结果写入 perf_nz_cycles。
perf_nz_stat_cycles() {
  local perf_cmd out
  perf_nz_cycles=""
  if ! perf_nz_probe_ok; then
    return 1
  fi
  perf_cmd="$(perf_nz_resolve_bin)" || return 1
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  out=$("$perf_cmd" stat -x, -e cycles,instructions -- "$@" 2>&1 || true)
  if echo "$out" | grep -qiE 'Permission denied|perf_event_paranoid'; then
    if command -v sudo >/dev/null 2>&1; then
      out=$(sudo "$perf_cmd" stat -x, -e cycles,instructions -- "$@" 2>&1 || true)
    fi
  fi
  perf_nz_cycles=$(perf_nz_csv_event_count "$out" "cycles")
  if [ -z "$perf_nz_cycles" ]; then
    perf_nz_cycles=$(perf_nz_text_event_count "$out" "cycles")
  fi
  [ -n "$perf_nz_cycles" ] && [ "$perf_nz_cycles" != "0" ]
}

# 计算 cycles/MiB（bytes 为 xfer 总字节）。
perf_nz_cycles_per_mib() {
  local cycles="$1"
  local bytes="$2"
  awk -v c="$cycles" -v b="$bytes" 'BEGIN {
    if (b <= 0) { print "nan"; exit }
    printf "%.2f", (c * 1048576.0) / b
  }'
}

# echo bench：起 C server + perf stat 跑 client；返回 client exit code。
perf_nz_run_echo_cycles() {
  local client_exe="$1"
  local server_c="$2"
  local port="$3"
  local srv spid rc
  srv="$(mktemp /tmp/shux_nz_echo_srv.XXXXXX)"
  if ! cc -O2 "$server_c" -o "$srv" 2>/dev/null; then
    return 1
  fi
  "$srv" "$port" >/dev/null 2>&1 &
  spid=$!
  sleep 0.15
  rc=0
  perf_nz_stat_cycles "$client_exe" "$port" || rc=$?
  kill "$spid" 2>/dev/null || true
  wait "$spid" 2>/dev/null || true
  rm -f "$srv"
  return "$rc"
}

# 从 net-zc-perf.tsv 读取 cap / ref。
perf_nz_read_caps() {
  local case_id="$1"
  local baseline="${2:-tests/baseline/net-zc-perf.tsv}"
  perf_nz_cap_cpm=""
  perf_nz_xfer_bytes=""
  perf_nz_zc_lt_ref=""
  perf_nz_needs_io_uring=""
  while IFS=$'\t' read -r cid _su _srv bytes cap_mib ref needs_uring _notes; do
    [ -z "${cid:-}" ] && continue
    case "$cid" in \#*) continue ;; esac
    if [ "$cid" = "$case_id" ]; then
      perf_nz_cap_cpm="$cap_mib"
      perf_nz_xfer_bytes="$bytes"
      perf_nz_zc_lt_ref="$ref"
      perf_nz_needs_io_uring="$needs_uring"
      return 0
    fi
  done < "$baseline"
  return 1
}

# 比较 cycles/MiB 是否在 cap 内；stdout 输出 1/0。
perf_nz_within_cap() {
  local case_id="$1"
  local cpm="$2"
  local baseline="${3:-tests/baseline/net-zc-perf.tsv}"
  if ! perf_nz_read_caps "$case_id" "$baseline"; then
    echo 0
    return 1
  fi
  if awk -v c="$cpm" -v cap="$perf_nz_cap_cpm" 'BEGIN { exit (c + 0 <= cap + 0) ? 0 : 1 }'; then
    echo 1
    return 0
  fi
  echo 0
  return 0
}

# 输出结构化网络零拷贝 CPU/byte 报告行（OBS-003 bracket 兼容）。
perf_nz_report_emit() {
  local case_id="$1"
  local cycles="$2"
  local bytes="$3"
  local cpm="$4"
  local cap_cpm="$5"
  local ref_case="$6"
  local ref_cpm="$7"
  local ok_flag="$8"
  local prefix="${SHUX_NET_ZC_PREFIX:-shux: [SHUX_NET_ZC]}"
  printf '%s case=%s cycles=%s bytes=%s cycles_per_mib=%s cap_cycles_per_mib=%s ref_case=%s ref_cycles_per_mib=%s ok=%s\n' \
    "$prefix" "$case_id" "$cycles" "$bytes" "$cpm" "$cap_cpm" "${ref_case:--}" "${ref_cpm:--}" "$ok_flag" >&2
}
