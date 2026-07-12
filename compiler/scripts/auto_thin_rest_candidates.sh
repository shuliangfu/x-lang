#!/bin/bash
# auto_thin_rest_candidates.sh — G-02f / Phase 2: 扫描 .x + seed 对，识别可做 thin+rest 切割的候选
#
# 目标（与方法论 §4.2 / §5 P1 对齐）：
#   - 不自动落盘 .x / seed 修改
#   - 只输出候选列表 + 风险标注，供人工评估
#   - 已切割的 TU（已有 _thin.x 或 seed 有 SHUX_*_FROM_X 宏）标为 already_split
#   - 不适合切割的 TU（无 #[no_mangle] / 纯数据文件）标为 not_candidate
#
# 判定规则（与方法论 §3.2 "不能只看符号交集" 对齐）：
#   1. .x 中 #[no_mangle] 函数数 > 0（thin 的入口）
#   2. seed 中可识别 pure helper 与 impl 分离潜力（*_impl 后缀 / #ifndef 保护块）
#   3. 风险标记：argv / va_list / weak / #if / 大文件（>1000 行 seed）
#
# 用法：
#   sh scripts/auto_thin_rest_candidates.sh [--json] [--out <path>]
#
# 输出（默认文本表格）：
#   pair_name | x_nm_count | seed_lines | impl | risk_flags | status
#   ...
#   summary: candidates=N already_split=N not_candidate=N
#
# 输出（--json）：单行 JSON 数组
#
# 工件路径：tests/probes/auto_thin_rest_candidates/
#
# 【Why 根源】性能：预计算 seed 列表 + 单次 rg 批量检测，避免 N×M rg 调用。
# 【Invariant】pairs.tsv 是稳定工件，可被 abi_snapshot_diff.sh 等下游工具消费。
# 【Asm/Perf】O(N) 单遍扫描，N=*.x 文件数；rg 单次调用带多模式。

set -eu

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
usage:
  sh scripts/auto_thin_rest_candidates.sh [--json] [--out <path>]

options:
  --json        输出单行 JSON 数组（默认文本表格）
  --out <path>  写入文件路径（默认 stdout）
EOF
}

OUTPUT_FMT="text"
OUTPUT_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --json)
      OUTPUT_FMT="json"
      shift
      ;;
    --out)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    *)
      echo "auto_thin_rest_candidates: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SEED_DIR="seeds"
SRC_DIR="src"
PROBE_DIR="../tests/probes/auto_thin_rest_candidates"
mkdir -p "$PROBE_DIR"

PAIRS_FILE="${PROBE_DIR}/pairs.tsv"
: >"$PAIRS_FILE"

# 预计算：seed 文件名集合（不带路径，不带 .from_x.c 后缀），用于 O(1) 查找
SEED_STEMS_FILE="${PROBE_DIR}/.seed_stems.tmp"
ls "$SEED_DIR"/*.from_x.c 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.from_x\.c$//' | sort -u >"$SEED_STEMS_FILE"

# 预计算：每个 seed 的行数 + 风险标记 + impl 计数 + 是否有 rest 宏
# 输出 TSV: stem \t lines \t impl_count \t has_rest_macro \t risk_flags
SEED_META_FILE="${PROBE_DIR}/.seed_meta.tmp"
: >"$SEED_META_FILE"

while IFS= read -r _seed_path; do
  [ -z "$_seed_path" ] && continue
  _seed_name="$(basename "$_seed_path" .from_x.c)"
  _lines="$(wc -l <"$_seed_path" | tr -d ' ')"

  # 单次 rg 调用收集所有风险标记 + impl 计数 + rest 宏
  _rg_out="$(rg -c -e '__attribute__\s*\(\(weak\)\)' -e '^\s*#\s*(if|ifdef|ifndef)' -e '\bva_list\b' -e '\bargv\b' -e '^[a-zA-Z_][a-zA-Z0-9_ \*]*\bimpl\b[[:space:]]*\(' -e 'SHUX_[A-Z0-9_]+_FROM_X' "$_seed_path" 2>/dev/null || true)"

  _weak_n=0
  _ifdef_n=0
  _va_list_n=0
  _argv_n=0
  _impl_n=0
  _rest_macro_n=0

  if [ -n "$_rg_out" ]; then
    # rg -c 输出格式：file:count（多模式时按模式顺序输出，每模式一行 file:count）
    _weak_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/weak/{print $2}' | head -n1)"
    _ifdef_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/ifdef/{print $2}' | head -n1)"
    _va_list_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/va_list/{print $2}' | head -n1)"
    _argv_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/argv/{print $2}' | head -n1)"
    _impl_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/impl/{print $2}' | head -n1)"
    _rest_macro_n="$(printf '%s\n' "$_rg_out" | awk -F: '$1~/FROM_X/{print $2}' | head -n1)"
  fi

  _weak_n="${_weak_n:-0}"
  _ifdef_n="${_ifdef_n:-0}"
  _va_list_n="${_va_list_n:-0}"
  _argv_n="${_argv_n:-0}"
  _impl_n="${_impl_n:-0}"
  _rest_macro_n="${_rest_macro_n:-0}"

  _risk_flags=""
  [ "$_argv_n" -gt 0 ] 2>/dev/null && _risk_flags="${_risk_flags}argv,"
  [ "$_va_list_n" -gt 0 ] 2>/dev/null && _risk_flags="${_risk_flags}va_list,"
  [ "$_weak_n" -gt 0 ] 2>/dev/null && _risk_flags="${_risk_flags}weak,"
  [ "$_ifdef_n" -gt 0 ] 2>/dev/null && _risk_flags="${_risk_flags}ifdef,"
  [ "$_lines" -gt 1000 ] 2>/dev/null && _risk_flags="${_risk_flags}large,"
  _risk_flags="${_risk_flags%,}"

  _has_rest_macro="no"
  [ "$_rest_macro_n" -gt 0 ] 2>/dev/null && _has_rest_macro="yes"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$_seed_name" "$_lines" "$_impl_n" "$_has_rest_macro" "$_risk_flags" "$_seed_path" >>"$SEED_META_FILE"
done <<EOF
$(ls "$SEED_DIR"/*.from_x.c 2>/dev/null)
EOF

# 查找 seed meta 的 helper
lookup_seed_meta() {
  _stem="$1"
  awk -F'\t' -v s="$_stem" '$1==s {print $2"\t"$3"\t"$4"\t"$5"\t"$6; exit}' "$SEED_META_FILE"
}

# 主扫描：遍历 .x 文件
while IFS= read -r x_file; do
  _stem="$(basename "$x_file" .x)"

  # 跳过已知非 thin 候选：纯数据 / 枚举 / 配置 / 平台
  case "$_stem" in
    token|token_standalone|types|arch|x86_64|arm64|riscv64|elf|coff|macho|asm|x86_64_enc)
      continue ;;
  esac

  # O(1) 查找 seed 是否存在
  if ! grep -qx "$_stem" "$SEED_STEMS_FILE"; then
    continue
  fi

  # 读取 seed meta
  _meta="$(lookup_seed_meta "$_stem")"
  if [ -z "$_meta" ]; then
    continue
  fi
  _seed_lines="$(printf '%s' "$_meta" | cut -f1)"
  _impl_count="$(printf '%s' "$_meta" | cut -f2)"
  _has_macro="$(printf '%s' "$_meta" | cut -f3)"
  _risk_flags="$(printf '%s' "$_meta" | cut -f4)"
  _seed_path="$(printf '%s' "$_meta" | cut -f5)"

  # 检查 .x 是否已有 _thin.x 变体
  _has_thin="no"
  _thin_file="${x_file%.x}_thin.x"
  [ -f "$_thin_file" ] && _has_thin="yes"

  # 统计 .x 中 #[no_mangle] 数量
  _nm_count="$(rg -c '#\[no_mangle\]' "$x_file" 2>/dev/null || echo 0)"

  # 状态判定
  _status="candidate"
  if [ "$_has_thin" = "yes" ] || [ "$_has_macro" = "yes" ]; then
    _status="already_split"
  elif [ "$_nm_count" = "0" ]; then
    _status="not_candidate"
  fi

  # TSV: pair_name | x_file | seed_file | x_nm | seed_lines | impl_count | has_thin | has_macro | risk_flags | status
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$_stem" "$x_file" "$_seed_path" "$_nm_count" "$_seed_lines" "$_impl_count" \
    "$_has_thin" "$_has_macro" "$_risk_flags" "$_status" >>"$PAIRS_FILE"
done <<EOF
$(find "$SRC_DIR" -type f -name '*.x' ! -name '*_thin.x' | sort)
EOF

# 文本表格输出
emit_text() {
  _out="$1"

  _counts="$(awk -F'\t' '
    NF == 10 {
      print $10
    }
  ' "$PAIRS_FILE" | sort | uniq -c)"

  _candidates="$(printf '%s\n' "$_counts" | awk '$2 == "candidate" {print $1; exit}')"
  _already="$(printf '%s\n' "$_counts" | awk '$2 == "already_split" {print $1; exit}')"
  _not_cand="$(printf '%s\n' "$_counts" | awk '$2 == "not_candidate" {print $1; exit}')"
  _candidates="${_candidates:-0}"
  _already="${_already:-0}"
  _not_cand="${_not_cand:-0}"

  {
    printf '%-40s %6s %10s %6s %8s %s\n' "pair_name" "x_nm" "seed_lines" "impl" "risk" "status"
    printf '%s\n' "-----------------------------------------------------------------------------------------"

    awk -F'\t' '
      NF == 10 {
        printf "%-40s %6s %10s %6s %8s %s\n", $1, $4, $5, $6, $9, $10
      }
    ' "$PAIRS_FILE"

    printf '%s\n' "-----------------------------------------------------------------------------------------"
    printf 'summary: candidates=%d already_split=%d not_candidate=%d\n' "$_candidates" "$_already" "$_not_cand"
  } >"$_out"
}

# JSON 输出（纯 awk 实现，避免 perl 依赖）
emit_json() {
  _out="$1"
  awk -F'\t' '
    BEGIN {
      printf "["
      first = 1
    }
    NF == 10 {
      if (!first) printf ","
      first = 0
      stem = $1; x = $2; seed = $3; nm = $4; lines = $5; impl = $6
      has_thin = $7; has_macro = $8; risk = $9; status = $10

      # JSON escape backslash and double-quote
      gsub(/\\/, "\\\\", stem)
      gsub(/"/, "\\\"", stem)
      gsub(/\\/, "\\\\", x)
      gsub(/"/, "\\\"", x)
      gsub(/\\/, "\\\\", seed)
      gsub(/"/, "\\\"", seed)
      gsub(/\\/, "\\\\", risk)
      gsub(/"/, "\\\"", risk)
      gsub(/\\/, "\\\\", status)
      gsub(/"/, "\\\"", status)

      # risk_flags 数组
      nr = split(risk, ra, ",")
      risk_arr = "["
      for (i = 1; i <= nr; i++) {
        if (i > 1) risk_arr = risk_arr ","
        risk_arr = risk_arr "\"" ra[i] "\""
      }
      risk_arr = risk_arr "]"

      ht = (has_thin == "yes" ? "true" : "false")
      hm = (has_macro == "yes" ? "true" : "false")

      line = "{\"pair_name\":\"" stem "\",\"x_file\":\"" x "\",\"seed_file\":\"" seed "\",\"x_no_mangle_count\":" (nm+0) ",\"seed_lines\":" (lines+0) ",\"seed_impl_count\":" (impl+0) ",\"has_thin_variant\":" ht ",\"has_rest_macro\":" hm ",\"risk_flags\":" risk_arr ",\"status\":\"" status "\"}"
      printf "%s", line
    }
    END {
      printf "]"
    }
  ' "$PAIRS_FILE" >"$_out"
}

if [ "$OUTPUT_FMT" = "json" ]; then
  if [ -n "$OUTPUT_PATH" ]; then
    emit_json "$OUTPUT_PATH"
    echo "auto_thin_rest_candidates: json written to $OUTPUT_PATH" >&2
  else
    emit_json "/dev/stdout"
    echo
  fi
else
  if [ -n "$OUTPUT_PATH" ]; then
    emit_text "$OUTPUT_PATH"
    echo "auto_thin_rest_candidates: text written to $OUTPUT_PATH" >&2
  else
    emit_text "/dev/stdout"
  fi
fi

# 清理临时文件
rm -f "$SEED_STEMS_FILE" "$SEED_META_FILE"

echo "  pairs_tsv:  $PAIRS_FILE" >&2

exit 0
