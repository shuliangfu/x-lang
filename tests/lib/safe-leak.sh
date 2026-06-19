#!/usr/bin/env bash
# safe-leak.sh — SAFE-005 共享：ASAN/LSAN 泄漏夜跑辅助
#
# 用法（source 后）：
#   safe_leak_asan_ok
#   safe_leak_run_su SHUX_BIN src tag
#   safe_leak_run_probe
#   safe_leak_emit_report status cases_ok cases_fail leak_count

SAFE_LEAK_PREFIX="${SHUX_LEAK_NIGHTLY_PREFIX:-shux: [SHUX_LEAK_NIGHTLY]}"

# 检测当前 cc 是否支持 -fsanitize=address。
safe_leak_asan_ok() {
  local tmp="/tmp/shux_leak_asan_probe_$$.c"
  local out="/tmp/shux_leak_asan_probe_$$"
  cat >"$tmp" <<'EOF'
int main(void) { return 0; }
EOF
  if cc -fsanitize=address "$tmp" -o "$out" 2>/dev/null; then
    rm -f "$tmp" "$out"
    return 0
  fi
  rm -f "$tmp" "$out"
  return 1
}

# 以 ASAN 编译并运行 .sx；泄漏或崩溃返回 1。
safe_leak_run_su() {
  local shux="$1"
  local src="$2"
  local tag="${3:-leak}"
  local exe="/tmp/shux_safe_leak_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "safe-leak FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -fsanitize=address -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -fsanitize=address -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  ASAN_OPTIONS="${ASAN_OPTIONS:-detect_leaks=1:exitcode=23:halt_on_error=1}" \
    "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -eq 0 ]; then
    return 0
  fi
  echo "safe-leak FAIL: $tag asan exit=$ec ($src)" >&2
  return 1
}

# 运行故意泄漏 probe；应被 ASAN 检出（非 0 退出）。
safe_leak_run_probe() {
  local exe="/tmp/shux_leak_probe_$$"
  if ! cc -fsanitize=address tests/leak/leak_probe.c -o "$exe" 2>/dev/null; then
    echo "safe-leak probe SKIP: compile" >&2
    return 0
  fi
  local ec=0
  ASAN_OPTIONS=detect_leaks=1:exitcode=23:halt_on_error=1 "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "safe-leak probe OK (detected intentional leak ec=$ec)"
    return 0
  fi
  echo "safe-leak probe FAIL: intentional leak not detected" >&2
  return 1
}

# 输出结构化夜跑报告行（OBS-003 bracket 兼容）。
safe_leak_emit_report() {
  local status="$1"
  local cases_ok="$2"
  local cases_fail="$3"
  local leak_count="$4"
  echo "${SAFE_LEAK_PREFIX} status=${status} cases_ok=${cases_ok} cases_fail=${cases_fail} leaks=${leak_count}"
}
