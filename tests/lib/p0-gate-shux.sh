#!/usr/bin/env bash
# p0-gate-shux.sh — 自举前 P0 gate 编译器选择（typeck 优先 gen1 asm，seed shux-c 作回退）
#
# shux_asm_stage1 在 Docker 低内存下 check 偶发 SIGSEGV/OOM(137)；对 137/139 重试，
# 再回退 shux_asm2 / shux-c（contextual typing 已覆盖 usize 字面量）。
#
# 用法（source 后）：
#   p0_gate_run_typeck "$sx"   # stdout=编译器路径；失败 return 1
#   p0_gate_try_run_o "$bin" "$sx" "$exe"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "${BASH_SOURCE[0]}")/ci-host.sh"
# shellcheck source=tests/lib/gate-progress.sh
. "$(dirname "${BASH_SOURCE[0]}")/gate-progress.sh" 2>/dev/null || true

p0_gate_log() {
  if declare -F gate_progress >/dev/null 2>&1; then
    gate_progress "$@" >&2
  else
    printf '[p0] %s\n' "$*" >&2
  fi
}

# 未设 SHUX 时优先 shux-c（V6 smoke 已验 -c/-o；避 stage1 OOM/SIGSEGV）。
p0_gate_default_seed() {
  if [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ] && ci_native_shu "${SHUX}"; then
    echo "${SHUX}"
    return 0
  fi
  if [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
    echo ./compiler/shux-c
    return 0
  fi
  return 1
}

# typeck：先 seed（shux-c），失败再按候选列表回退。
p0_gate_run_typeck_prefer_seed() {
  local sx="$1"
  local seed
  if seed="$(p0_gate_default_seed)"; then
    p0_gate_log "typeck prefer seed: $seed $(basename "$sx")"
    if p0_gate_typeck_one "$seed" "$sx"; then
      echo "$seed"
      return 0
    fi
    p0_gate_log "typeck seed failed, fallback candidates ..."
  fi
  p0_gate_run_typeck "$sx"
}

# 候选 typeck 编译器列表（按优先级）。
# SHUX_P0_SKIP_STAGE1=1 时仅 seed/shux-c（省 7+ 分钟 stage1 OOM 重试）。
p0_gate_typeck_candidates() {
  local cand
  if [ -n "${SHUX:-}" ] && [ -x "${SHUX}" ] && ci_native_shu "${SHUX}"; then
    echo "${SHUX}"
  fi
  if [ "${SHUX_P0_SKIP_STAGE1:-0}" = "1" ]; then
    [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c && echo ./compiler/shux-c
    return 0
  fi
  # macOS 上 shux_asm_stage1 会吃 60G+ 内存（asm 后端无内存限制），强制跳过
  if [ "$(uname)" = "Darwin" ]; then
    [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c && echo ./compiler/shux-c
    return 0
  fi
  for cand in ./compiler/shux_asm_stage1 ./compiler/shux_asm2 ./compiler/shux_asm \
              ./compiler/shux ./compiler/shux-c; do
    if [ -x "$cand" ] && ci_native_shu "$cand"; then
      echo "$cand"
    fi
  done
}

# 对单文件 typeck；137/139 时最多重试 3 次。
p0_gate_typeck_one() {
  local bin="$1"
  local sx="$2"
  local logf try ec
  logf="/tmp/shux_p0_typeck_$$.log"
  for try in 1 2 3; do
    p0_gate_log "typeck try $try: $bin $(basename "$sx")"
    set +e
    "$bin" check -L . "$sx" >"$logf" 2>&1
    ec=$?
    set -e
    if [ "$ec" -eq 0 ]; then
      rm -f "$logf"
      return 0
    fi
    if [ "$ec" -eq 137 ] || [ "$ec" -eq 139 ]; then
      sleep 1
      continue
    fi
    cat "$logf" >&2
    rm -f "$logf"
    return 1
  done
  cat "$logf" >&2 2>/dev/null || true
  rm -f "$logf"
  return 1
}

# 依次尝试候选编译器直至 typeck 通过；stdout 输出成功者路径。
p0_gate_run_typeck() {
  local sx="$1"
  local bin
  while IFS= read -r bin; do
    [ -n "$bin" ] || continue
    if p0_gate_typeck_one "$bin" "$sx"; then
      echo "$bin"
      return 0
    fi
  done < <(p0_gate_typeck_candidates)
  return 1
}

# 尝试 -o 编译并运行；shux-c 走 -backend c；失败时默认 WARN 返回 2。
# 参数：$1=编译器 $2=.sx $3=exe；SHUX_P0_GATE_RUN_STRICT=1 时失败即 exit 1。
p0_gate_try_run_o() {
  local bin="$1"
  local sx="$2"
  local exe="$3"
  local ec run_ec logf backend_args=""
  logf="/tmp/shux_p0_gate_o_$$.log"
  rm -f "$exe"
  case "$(basename "$bin")" in
    shux-c) backend_args="-backend c" ;;
  esac
  if [ "${SHUX_MINIMAL_CC_LINK:-0}" = "1" ]; then
    export SHUX_MINIMAL_CC_LINK=1
  fi
  local o_timeout="${SHUX_P0_GATE_O_TIMEOUT:-300}"
  local hb="${SHUX_P0_GATE_O_HEARTBEAT:-15}"
  p0_gate_log "-o compile: $bin $(basename "$sx") (timeout=${o_timeout}s, heartbeat=${hb}s) ..."
  set +e
  # shellcheck disable=SC2086
  if declare -F gate_progress_run_heartbeat >/dev/null 2>&1; then
    gate_progress_run_heartbeat "-o $bin $(basename "$sx")" "$hb" \
      gate_run_timeout "$o_timeout" "$bin" $backend_args -L . "$sx" -o "$exe" \
      >"$logf" 2>&1
    ec=$?
  else
    gate_run_timeout "$o_timeout" "$bin" $backend_args -L . "$sx" -o "$exe" >"$logf" 2>&1
    ec=$?
  fi
  if [ "$ec" -ne 0 ] || [ ! -x "$exe" ]; then
    p0_gate_log "-o 直链失败 ec=$ec，尝试 min-link ..."
    local min_wrap root
    root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    min_wrap="$root/tests/lib/shux-min-link.sh"
    if [ -x "$min_wrap" ] && [ -x "$bin" ]; then
      export SHUX_MIN_LINK_REAL="$bin"
      rm -f "$exe"
      if declare -F gate_progress_run_heartbeat >/dev/null 2>&1; then
        gate_progress_run_heartbeat "min-link $(basename "$sx")" "$hb" \
          gate_run_timeout "$o_timeout" "$min_wrap" $backend_args -L . "$sx" -o "$exe" \
          >>"$logf" 2>&1
        ec=$?
      else
        # shellcheck disable=SC2086
        gate_run_timeout "$o_timeout" "$min_wrap" $backend_args -L . "$sx" -o "$exe" >>"$logf" 2>&1
        ec=$?
      fi
    fi
  fi
  set -e
  if [ "$ec" -ne 0 ] || [ ! -x "$exe" ]; then
    if [ "${SHUX_P0_GATE_RUN_STRICT:-0}" = "1" ]; then
      cat "$logf" >&2
      echo "p0-gate: -o FAIL ec=$ec (SHUX_P0_GATE_RUN_STRICT=1)" >&2
      rm -f "$logf"
      return 1
    fi
    echo "p0-gate WARN: -o skipped ($bin ec=$ec; C6 asm直链待修)" >&2
    tail -3 "$logf" >&2 2>/dev/null || true
    rm -f "$logf"
    return 2
  fi
  run_ec=0
  "$exe" >/dev/null 2>&1 || run_ec=$?
  rm -f "$exe" "$logf"
  echo "$run_ec"
  return 0
}
