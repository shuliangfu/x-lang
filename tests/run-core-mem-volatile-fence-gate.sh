#!/usr/bin/env bash
# CORE-017：core.mem volatile/fence 门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_SU="core/mem/mod.su"
MEM_C="core/mem/mem.c"
MANIFEST="tests/baseline/core-mem-volatile-fence.tsv"
SMOKE_SU="tests/core-mem/volatile_fence.su"
SMOKE_C="tests/core-mem/volatile_fence_smoke.c"
PREFIX="shu: [SHU_CORE017_MEM_VOLATILE]"

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
for f in "$MOD_SU" "$MEM_C" "$MANIFEST" "$SMOKE_SU" "$SMOKE_C"; do
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
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
if ! grep -qF "mem_volatile_fence_smoke_c" "$MEM_C" 2>/dev/null; then
  echo "core-mem-volatile gate FAIL: missing C smoke symbol" >&2
  exit 1
fi
echo "core-mem-volatile manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../core/mem/mem.o

C_OK=0
echo "=== CORE-017: C smoke ==="
c_exe="/tmp/shu_core017_mem_vf_$$"
if cc -Wall -Wextra -o "$c_exe" "$SMOKE_C" core/mem/mem.o 2>/dev/null; then
  set +e
  "$c_exe" >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f "$c_exe"
  if [ "$c_ec" -ne 0 ]; then
    echo "core-mem-volatile gate FAIL: C smoke exit=$c_ec" >&2
    exit 1
  fi
  C_OK=1
else
  echo "core-mem-volatile gate FAIL: compile $SMOKE_C" >&2
  exit 1
fi

SU_OK=0
SKIP=0
SHU_BIN=""
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
fi
if [ -n "$SHU_BIN" ]; then
  echo "=== CORE-017: .su compile+run (SHU=$SHU_BIN) ==="
  su_exe="/tmp/shu_core017_mem_vf_run_$$"
  rm -f "$su_exe"
  if ! "$SHU_BIN" -L . "$SMOKE_SU" -o "$su_exe" >/dev/null 2>&1; then
    echo "core-mem-volatile gate FAIL: compile $SMOKE_SU" >&2
    "$SHU_BIN" -L . "$SMOKE_SU" -o "$su_exe" 2>&1 | tail -15 >&2 || true
    exit 1
  fi
  set +e
  "$su_exe" >/dev/null 2>&1
  su_ec=$?
  set -e
  rm -f "$su_exe"
  if [ "$su_ec" -ne 0 ]; then
    echo "core-mem-volatile gate FAIL: run $SMOKE_SU exit=$su_ec" >&2
    exit 1
  fi
  echo "=== CORE-017: .su typeck (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "core-mem-volatile gate FAIL: typeck $SMOKE_SU" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    exit 1
  fi
  SU_OK=2
else
  echo "core-mem-volatile gate SKIP .su (no native shu)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok c=${C_OK} su=${SU_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "core-mem-volatile-fence gate OK"
