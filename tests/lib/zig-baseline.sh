#!/usr/bin/env bash
# zig-baseline.sh — Zig 对标基线共享工具（PERF-001）
#
# 用法（source）：
#   # shellcheck source=tests/lib/zig-baseline.sh
#   . "$(dirname "$0")/lib/zig-baseline.sh"
#
# 环境：
#   SHUX_ZIG_BASELINE_TSV — 默认 tests/baseline/zig-perf.tsv
#   SHUX_ZIG_BASELINE_STRICT=1 — zig 版本须匹配 meta zig_version_pin
#   SHUX_ZIG_BASELINE_VERIFY=1 — 实测 median 须在 recorded median × tolerance 内

# 基线 TSV 路径（相对 repo 根）。
ZIG_BASELINE_TSV="${SHUX_ZIG_BASELINE_TSV:-tests/baseline/zig-perf.tsv}"

# 读取 meta 行：zig_baseline_meta_get zig_version_pin
zig_baseline_meta_get() {
  local key="$1"
  awk -F'\t' -v k="$key" '
    $1 == "meta" && $2 == k { print $3; exit }
  ' "$ZIG_BASELINE_TSV" 2>/dev/null
}

# 打印 Zig 版本串（无 zig 时返回空）。
zig_baseline_version_string() {
  if command -v zig >/dev/null 2>&1; then
    zig version 2>/dev/null | awk '{print $1}'
  fi
}

# 提取 major.minor（0.13.0 → 0.13）。
zig_baseline_version_major_minor() {
  local v="${1:-$(zig_baseline_version_string)}"
  echo "$v" | sed -n 's/^\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p'
}

# 检查当前 zig 是否匹配基线 pin；STRICT=1 且不匹配时返回 1。
zig_baseline_check_version() {
  local pin mm cur
  pin="$(zig_baseline_meta_get zig_version_pin)"
  cur="$(zig_baseline_version_major_minor)"
  if [ -z "$pin" ]; then
    echo "zig-baseline WARN: no zig_version_pin in $ZIG_BASELINE_TSV" >&2
    return 0
  fi
  if ! command -v zig >/dev/null 2>&1; then
    echo "zig-baseline: zig not installed (pin=$pin)" >&2
    [ "${SHUX_ZIG_BASELINE_STRICT:-0}" = "1" ] && return 1
    return 0
  fi
  mm="$(zig_baseline_version_major_minor "$pin")"
  if [ "$cur" = "$mm" ]; then
    echo "zig-baseline: zig version OK ($cur ~ pin $pin)"
    return 0
  fi
  echo "zig-baseline WARN: zig $cur != pin $pin (use SHUX_CI_ZIG_VERSION=$pin or tarball)" >&2
  [ "${SHUX_ZIG_BASELINE_STRICT:-0}" = "1" ] && return 1
  return 0
}

# 统一 Zig 优化编译：apt 旧版 -O2；0.13+ 回退 ReleaseFast（与 perf 脚本一致）。
zig_build_exe_o2() {
  local zig_src="$1"
  local out="$2"
  local opt_primary opt_fallback
  opt_primary="$(zig_baseline_meta_get zig_opt_primary)"
  opt_fallback="$(zig_baseline_meta_get zig_opt_fallback)"
  [ -n "$opt_primary" ] || opt_primary="-O2"
  [ -n "$opt_fallback" ] || opt_fallback="-O ReleaseFast"
  if zig build-exe "$opt_primary" "$zig_src" -femit-bin="$out" 2>/dev/null && [ -x "$out" ]; then
    return 0
  fi
  if zig build-exe $opt_fallback "$zig_src" -femit-bin="$out" 2>/dev/null && [ -x "$out" ]; then
    return 0
  fi
  return 1
}

# 从 time 输出提取 real 秒（与 run-perf-baseline.sh 一致）。
zig_baseline_extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' \
    | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

# 多次运行取 real 中位数。
zig_baseline_median_real() {
  local exe="$1"
  local runs="${2:-3}"
  local i vals med
  vals=""
  for i in $(seq 1 "$runs"); do
    vals=$( ( time "$exe" >/dev/null ) 2>&1 | zig_baseline_extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

# 打印基线 host 摘要（可追溯）。
zig_baseline_host_summary() {
  local ref_host ref_date ZIG_VER
  ref_host="$(zig_baseline_meta_get reference_host)"
  ref_date="$(zig_baseline_meta_get reference_date)"
  ZIG_VER="$(zig_baseline_version_string)"
  echo "reference_host=${ref_host:-?} reference_date=${ref_date:-?} current=$(uname -s 2>/dev/null)/$(uname -m 2>/dev/null) zig=${ZIG_VER:-none}"
}

# 校验 TSV：meta 必填项 + 每个 case 源文件存在。
zig_baseline_validate_tsv() {
  local tsv="$1"
  local missing=0
  local key
  if [ ! -f "$tsv" ]; then
    echo "zig-baseline FAIL: missing $tsv" >&2
    return 1
  fi
  for key in zig_version_pin zig_opt_primary reference_host reference_date runs; do
    if [ -z "$(zig_baseline_meta_get "$key")" ]; then
      echo "zig-baseline FAIL: missing meta $key" >&2
      missing=$((missing + 1))
    fi
  done
  while IFS=$'\t' read -r typ case_id _rest; do
    [ "$typ" = "case" ] || continue
    local src
    src=$(awk -F'\t' -v c="$case_id" '$1=="case" && $2==c {print $4; exit}' "$tsv")
    [ -n "$src" ] || continue
    if [ ! -f "tests/bench/$src" ] && [ ! -f "$src" ]; then
      echo "zig-baseline FAIL: case $case_id missing source tests/bench/$src" >&2
      missing=$((missing + 1))
    fi
  done < "$tsv"
  [ "$missing" -eq 0 ]
}
