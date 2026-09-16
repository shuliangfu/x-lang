#!/usr/bin/env bash
# safe-leak.sh — SAFE-005 shared helpers (honesty soft→硬绿).
#
# Usage (source):
#   safe_leak_asan_ok
#   safe_leak_run_x XLANG_BIN src tag
#   safe_leak_run_probe
#   safe_leak_emit_report status run obs skip
# PLATFORM: LINUX ASAN primary; Darwin/Windows = skip (platform N/A).

SAFE_LEAK_PREFIX="${XLANG_LEAK_NIGHTLY_PREFIX:-xlang: [XLANG_LEAK_NIGHTLY]}"

# Detect whether host cc supports -fsanitize=address.
safe_leak_asan_ok() {
  local tmp="/tmp/xlang_leak_asan_probe_$$.c"
  local out="/tmp/xlang_leak_asan_probe_$$"
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

# Compile and run .x under ASAN; leak or crash returns 1.
# PLATFORM: LINUX — ASAN/LSAN night path.
safe_leak_run_x() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-leak}"
  local exe="/tmp/xlang_safe_leak_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "safe-leak FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -fsanitize=address -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$xlang" -fsanitize=address -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
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

# Intentional leak probe; ASAN must detect (non-zero exit).
safe_leak_run_probe() {
  local exe="/tmp/xlang_leak_probe_$$"
  if ! cc -fsanitize=address tests/leak/leak_probe.c -o "$exe" 2>/dev/null; then
    echo "safe-leak probe SKIP: compile" >&2
    return 2
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

# Emit structured gate report line.
safe_leak_emit_report() {
  local status="$1"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${SAFE_LEAK_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}
