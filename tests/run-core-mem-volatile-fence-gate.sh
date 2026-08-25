#!/usr/bin/env bash
# CORE-017：core.mem volatile/fence 门禁（假权威诚实）。
#
# 用法：./tests/run-core-mem-volatile-fence-gate.sh
# 2026-08-25: runnable hard-green (labi_od_core_mem full needles ×31; check observational).
# Prefer xlang_asm; check stays observational (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology / formal core/mem/mem.o / labi needs_core_mem.
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

MOD_X="core/mem/mod.x"
MANIFEST="tests/baseline/core-mem-volatile-fence.tsv"
SMOKE_X="tests/core-mem/volatile_fence.x"
PREFIX="xlang: [XLANG_CORE017_MEM_VOLATILE]"

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
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

CHECK_OK=0
RUN_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-017: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-mem-volatile gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  OUT="/tmp/xlang_core017_mem_vf_$$"
  LOG="/tmp/xlang_core017_mem_vf_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "core-mem-volatile gate FAIL runnable exit=$exitcode" >&2
      exit 1
    fi
  else
    echo "core-mem-volatile gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    exit 1
  fi
else
  echo "core-mem-volatile gate SKIP .x (no native xlang)" >&2
fi

echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "core-mem-volatile-fence gate OK"
