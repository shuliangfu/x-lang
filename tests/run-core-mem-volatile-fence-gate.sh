#!/usr/bin/env bash
# CORE-017：core.mem volatile/fence 门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_X="core/mem/mod.x"
MANIFEST="tests/baseline/core-mem-volatile-fence.tsv"
SMOKE_X="tests/core-mem/volatile_fence.x"
PREFIX="shux: [SHUX_CORE017_MEM_VOLATILE]"

stdlib_cm_native_shu() {
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

echo "=== CORE-017: core.mem volatile/fence manifest ==="
for f in "$MOD_X" "$MANIFEST" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "core-mem-volatile gate FAIL: missing $f" >&2
    exit 1
  fi
done
MIN_APIS=6
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"
API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "core-mem-volatile gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"
if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "core-mem-volatile gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi
echo "core-mem-volatile manifest OK"
C_OK=0
X_OK=0
SKIP=0
SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi
if [ -n "$SHUX_BIN" ]; then
  echo "=== CORE-017: .x compile+run (SHUX=$SHUX_BIN) ==="
  su_exe="/tmp/shux_core017_mem_vf_run_$$"
  rm -f "$su_exe"
  if ! "$SHUX_BIN" -L . "$SMOKE_X" -o "$su_exe" >/dev/null 2>&1; then
    echo "core-mem-volatile gate FAIL: compile $SMOKE_X" >&2
    "$SHUX_BIN" -L . "$SMOKE_X" -o "$su_exe" 2>&1 | tail -15 >&2 || true
    exit 1
  fi
  set +e
  "$su_exe" >/dev/null 2>&1
  su_ec=$?
  set -e
  rm -f "$su_exe"
  if [ "$su_ec" -ne 0 ]; then
    echo "core-mem-volatile gate FAIL: run $SMOKE_X exit=$su_ec" >&2
    exit 1
  fi
  echo "=== CORE-017: .x typeck (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "core-mem-volatile gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    exit 1
  fi
  X_OK=2
else
  echo "core-mem-volatile gate SKIP .x (no native shux)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok c=${C_OK} x=${X_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "core-mem-volatile-fence gate OK"
