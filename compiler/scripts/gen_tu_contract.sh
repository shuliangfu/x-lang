#!/bin/bash
# gen_tu_contract.sh — G-02f / Phase 0：为单个试点 TU 生成 contract.md + contract.json
#
# 用法：
#   sh scripts/gen_tu_contract.sh <x-file> [seed-c-or-o]
#
# 说明：
#   - 默认依赖 prove_x_o.sh 产物；若缺失则先自动调用 prove_x_o.sh
#   - 合同输出到 analysis/tu_contracts/<stem>.contract.{md,json}

set -eu

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
usage:
  sh scripts/gen_tu_contract.sh <x-file> [seed-c-or-o]

examples:
  sh scripts/gen_tu_contract.sh src/asm/simd_loop_thin.x seeds/simd_loop.from_x.c
  sh scripts/gen_tu_contract.sh src/asm/simd_enc_thin.x seeds/simd_enc.from_x.c
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage >&2
  exit 2
fi

X_SRC="$1"
SEED_SRC="${2:-}"
TIMEOUT="${XLANG_CONTRACT_TIMEOUT:-8}"

if [ ! -f "$X_SRC" ]; then
  echo "gen_tu_contract: missing x source: $X_SRC" >&2
  exit 1
fi

run_timeout() {
  _timeout="$1"
  shift
  perl -e 'alarm shift; exec @ARGV' "$_timeout" "$@"
}

resolve_seed_src() {
  _x_src="$1"
  _stem="$(basename "$_x_src" .x)"
  _seed_dir="seeds"
  _macro=""
  _macro_hits=""
  _hit_count=0

  if [ -f "${_seed_dir}/${_stem}.from_x.c" ]; then
    printf '%s\n' "${_seed_dir}/${_stem}.from_x.c"
    return 0
  fi

  case "$_stem" in
    *_thin)
      _base="${_stem%_thin}"
      if [ -f "${_seed_dir}/${_base}.from_x.c" ]; then
        printf '%s\n' "${_seed_dir}/${_base}.from_x.c"
        return 0
      fi
      ;;
  esac

  _macro="$(rg -o 'XLANG_[A-Z0-9_]+_FROM_X' "$_x_src" | sort -u | head -n 1 || true)"
  if [ -n "$_macro" ]; then
    _macro_hits="$(rg -l "$_macro" "$_seed_dir" -g '*.from_x.c' | sort -u || true)"
    _hit_count="$(printf '%s\n' "$_macro_hits" | awk 'NF { n++ } END { print n + 0 }')"
    if [ "$_hit_count" = "1" ]; then
      printf '%s\n' "$_macro_hits"
      return 0
    fi
  fi

  return 1
}

if [ -z "$SEED_SRC" ]; then
  SEED_SRC="$(resolve_seed_src "$X_SRC" || true)"
fi

acquire_probe_lock() {
  _stem="$1"
  _lock_root="../tests/probes/prove_x_o"
  _lock_dir="${_lock_root}/${_stem}.lock"
  _lock_timeout="${XLANG_PROVE_LOCK_TIMEOUT:-15}"
  _start_ts="${SECONDS:-0}"

  mkdir -p "$_lock_root"
  while ! mkdir "$_lock_dir" 2>/dev/null; do
    if [ $(( ${SECONDS:-0} - _start_ts )) -ge "$_lock_timeout" ]; then
      echo "gen_tu_contract: timed out waiting for probe lock: $_lock_dir" >&2
      exit 1
    fi
    sleep 1
  done
  printf '%s\n' "$$" >"${_lock_dir}/pid"
  trap 'rm -rf "$_lock_dir"' EXIT INT TERM HUP
}

STEM="$(basename "$X_SRC" .x)"
acquire_probe_lock "$STEM"
PROBE_DIR="../tests/probes/prove_x_o/${STEM}"
CONTRACT_DIR="../analysis/tu_contracts"
MD_OUT="${CONTRACT_DIR}/${STEM}.contract.md"
JSON_OUT="${CONTRACT_DIR}/${STEM}.contract.json"
SYMS_TXT="${PROBE_DIR}/${STEM}.syms.txt"
SEED_SYMS_TXT="${PROBE_DIR}/${STEM}.seed.syms.txt"
ONLY_X_TXT="${PROBE_DIR}/${STEM}.only_x.txt"
ONLY_SEED_TXT="${PROBE_DIR}/${STEM}.only_seed.txt"
MERGED_SYMS_TXT="${PROBE_DIR}/${STEM}.merged.syms.txt"
REST_MACRO_TXT="${PROBE_DIR}/${STEM}.rest_macro.txt"
PROBE_SEED_LINK_O="${PROBE_DIR}/${STEM}.seed.probe_link.o"
PROBE_MERGED_LINK_O="${PROBE_DIR}/${STEM}.merged.probe_link.o"
SNAPSHOT_JSON="${PROBE_DIR}/${STEM}.snapshot_compare.json"

mkdir -p "$CONTRACT_DIR"

if [ ! -f "$SYMS_TXT" ] || { [ -n "$SEED_SRC" ] && [ ! -f "$SEED_SYMS_TXT" ]; }; then
  if [ -n "$SEED_SRC" ]; then
    run_timeout "$TIMEOUT" sh scripts/prove_x_o.sh "$X_SRC" "$SEED_SRC"
  else
    run_timeout "$TIMEOUT" sh scripts/prove_x_o.sh "$X_SRC"
  fi
fi

if [ ! -f "$SYMS_TXT" ]; then
  echo "gen_tu_contract: missing prove output: $SYMS_TXT" >&2
  exit 1
fi

line_count() {
  _file="$1"
  if [ -f "$_file" ]; then
    wc -l <"$_file" | tr -d ' '
  else
    echo 0
  fi
}

json_escape() {
  printf '%s' "$1" | perl -0pe 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g'
}

json_array_from_file() {
  _file="$1"
  if [ ! -f "$_file" ]; then
    printf '[]'
    return 0
  fi
  awk '
    BEGIN { printf "["; first = 1 }
    NF {
      gsub(/\\/,"\\\\",$0)
      gsub(/"/,"\\\"",$0)
      if (!first) printf ", "
      printf "\"%s\"", $0
      first = 0
    }
    END { printf "]" }
  ' "$_file"
}

SYMS_COUNT="$(line_count "$SYMS_TXT")"
SEED_COUNT="$(line_count "$SEED_SYMS_TXT")"
ONLY_X_COUNT="$(line_count "$ONLY_X_TXT")"
ONLY_SEED_COUNT="$(line_count "$ONLY_SEED_TXT")"
LD_R_STATUS="pending"
REST_MACRO_VALUE=""
SMOKE_STATUS="pending"
SNAPSHOT_STATUS="pending"

if [ -f "$MERGED_SYMS_TXT" ]; then
  LD_R_STATUS="ok"
fi
if [ -f "$REST_MACRO_TXT" ]; then
  REST_MACRO_VALUE="$(cat "$REST_MACRO_TXT")"
fi
if [ -f "$PROBE_SEED_LINK_O" ] && [ -f "$PROBE_MERGED_LINK_O" ]; then
  SMOKE_STATUS="symbol_resolve_ok"
fi
if [ -f "$SNAPSHOT_JSON" ]; then
  SNAPSHOT_STATUS="$(sed -n 's/.*"status": "\(.*\)".*/\1/p' "$SNAPSHOT_JSON" | head -n 1)"
  if [ -z "$SNAPSHOT_STATUS" ]; then
    SNAPSHOT_STATUS="pending"
  fi
fi

X_ROLE="thin/.x provider"
SEED_ROLE="seed/rest provider"
if [ "$ONLY_X_COUNT" = "0" ] && [ "$ONLY_SEED_COUNT" != "0" ]; then
  X_ROLE="thin wrapper / partial provider"
  SEED_ROLE="rest provider (_impl residual present)"
fi

cat >"$MD_OUT" <<EOF
# TU Contract: ${STEM}

## 1. 当前权威源
- x 源：\`${X_SRC}\`
- seed 源：\`${SEED_SRC:-N/A}\`
- prove 工件目录：\`${PROBE_DIR}\`

## 2. 当前目标
- 当前阶段：Phase 0 试点
- 本次目标：先证明该 TU 已具备最小 L1/L2 闭环
- 当前角色判断：
  - \`${X_ROLE}\`
  - \`${SEED_ROLE}\`

## 3. 导出符号合同
- thin/.x 当前导出数：${SYMS_COUNT}
- seed/rest 当前导出数：${SEED_COUNT}
- thin/.x 独有导出：${ONLY_X_COUNT}
- seed/rest 残余导出：${ONLY_SEED_COUNT}

### 3.1 必须由 thin/.x 提供
EOF

if [ -s "$SYMS_TXT" ]; then
  sed 's/^/- `/' "$SYMS_TXT" | sed 's/$/`/' >>"$MD_OUT"
else
  echo "- （空）" >>"$MD_OUT"
fi

cat >>"$MD_OUT" <<'EOF'

### 3.2 当前仍由 seed/rest 提供
EOF

if [ -s "$ONLY_SEED_TXT" ]; then
  sed 's/^/- `/' "$ONLY_SEED_TXT" | sed 's/$/`/' >>"$MD_OUT"
else
  echo "- （空）" >>"$MD_OUT"
fi

cat >>"$MD_OUT" <<EOF

### 3.3 thin/.x 独有导出（若非空，后续需审计）
EOF

if [ -s "$ONLY_X_TXT" ]; then
  sed 's/^/- `/' "$ONLY_X_TXT" | sed 's/$/`/' >>"$MD_OUT"
else
  echo "- （空）" >>"$MD_OUT"
fi

cat >>"$MD_OUT" <<EOF

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表
  - thin+rest 宏边界：${REST_MACRO_VALUE:-N/A}
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot
  - critical_field_offsets

## 5. 验证状态
- prove_x_o.sh：已跑通最小 L1/L2
- 已完成：
  - bootstrap-safe lint
  - .x -> -E
  - cc -c
  - nm
  - seed 符号对照
  - ld -r thin+rest 合并：${LD_R_STATUS}
- 待补：
  - smoke / probe：${SMOKE_STATUS}
  - canonical snapshot compare：${SNAPSHOT_STATUS}

## 6. 删除 seed 的门槛
- 当前阶段：**不允许删 seed**
- 必须补齐：
  - provider 边界稳定
  - ld -r 闭环
  - smoke / probe 一致
  - 连续构建不回退 seed

## 7. 备注
- 本文件由 compiler/scripts/gen_tu_contract.sh 生成
- 当前只作为试点 TU 的最小合同，不代表最终 ABI 审计已完成
EOF

cat >"$JSON_OUT" <<EOF
{
  "schema_version": 1,
  "tu": "$(json_escape "$STEM")",
  "x_src": "$(json_escape "$X_SRC")",
  "seed_src": "$(json_escape "${SEED_SRC:-}")",
  "probe_dir": "$(json_escape "$PROBE_DIR")",
  "phase": "phase0_trial",
  "status": {
    "prove_x_o": "ok",
    "ld_r": "$(json_escape "$LD_R_STATUS")",
    "smoke_probe": "$(json_escape "$SMOKE_STATUS")",
    "snapshot_compare": "$(json_escape "$SNAPSHOT_STATUS")"
  },
  "role": {
    "x": "$(json_escape "$X_ROLE")",
    "seed": "$(json_escape "$SEED_ROLE")"
  },
  "counts": {
    "x_symbols": ${SYMS_COUNT},
    "seed_symbols": ${SEED_COUNT},
    "only_x": ${ONLY_X_COUNT},
    "only_seed": ${ONLY_SEED_COUNT}
  },
  "symbols": {
    "x": $(json_array_from_file "$SYMS_TXT"),
    "seed": $(json_array_from_file "$SEED_SYMS_TXT"),
    "only_x": $(json_array_from_file "$ONLY_X_TXT"),
    "only_seed": $(json_array_from_file "$ONLY_SEED_TXT")
  },
  "rest_macro": "$(json_escape "$REST_MACRO_VALUE")",
  "delete_seed_gate": {
    "allowed_now": false,
    "requirements": [
      "provider boundary stabilized",
      "ld -r validated",
      "smoke or probe matched",
      "no seed fallback on repeated builds"
    ]
  }
}
EOF

echo "gen_tu_contract: ok"
echo "  md:   $MD_OUT"
echo "  json: $JSON_OUT"
exit 0
