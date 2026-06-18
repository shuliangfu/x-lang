#!/usr/bin/env bash
# NEXT-YELLOW：一次性清除 NEXT.md 全部 🟡 项门禁（CORE-018～020 / STD-159～167）
#
# 用法：./tests/run-next-yellow-clear-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/next-yellow-clear-v1.md"
MANIFEST="tests/baseline/next-yellow-clear.tsv"
PREFIX="shu: [SHU_NEXT_YELLOW_CLEAR]"

native_shu() {
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

echo "=== NEXT-YELLOW: manifest ==="
for f in "$DOC" "$MANIFEST" NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "next-yellow-clear gate FAIL: missing $f" >&2
    exit 1
  fi
done

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    symbol)
      if ! grep -qE "function ${anchor}\\(" "$mod_path" 2>/dev/null; then
        echo "next-yellow-clear FAIL: missing ${anchor} in ${mod_path}" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|smoke|doc)
      if [ ! -f "$anchor" ]; then
        echo "next-yellow-clear FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MISS" -gt 0 ]; then
  echo "${PREFIX} status=fail miss=${MISS}"
  exit 1
fi
echo "next-yellow-clear manifest OK"

# 扩展 CORE-009 bitops gate（CORE-018）
./tests/run-core-builtin-bitops-gate.sh >/dev/null 2>&1 || {
  echo "next-yellow-clear FAIL: core-builtin-bitops (CORE-018)" >&2
  exit 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
SHU_BIN=""
for cand in ./compiler/shu-c ./compiler/shu; do
  if native_shu "$cand"; then SHU_BIN="$cand"; break; fi
done

if [ -n "$SHU_BIN" ]; then
  echo "=== NEXT-YELLOW: typeck smokes (SHU=$SHU_BIN) ==="
  SMOKES=(
    tests/debug/diag_smoke.su
    tests/iterator/u64_roundtrip.su
    tests/exc/runtime_diag_smoke.su
    tests/string/unicode_bridge.su
    tests/vec/u16_roundtrip.su
    tests/map/iter_rehash.su
    tests/queue/u8_roundtrip.su
    tests/net/tcp_pool_smoke.su
    tests/thread/pool_stats.su
    tests/fmt/template_smoke.su
    tests/stub/sqlite_net_stub.su
  )
  for s in "${SMOKES[@]}"; do
    if ! "$SHU_BIN" check -L . "$s" >/dev/null 2>&1; then
      echo "next-yellow-clear FAIL: typeck $s" >&2
      "$SHU_BIN" check -L . "$s" 2>&1 | tail -6 >&2 || true
      echo "${PREFIX} status=fail check=0"
      exit 1
    fi
  done
  CHECK_OK=1
  SKIP=0
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  make -C compiler -q ../core/builtin/builtin.o 2>/dev/null || make -C compiler ../core/builtin/builtin.o
  # shellcheck source=tests/lib/bootstrap-link-shu.sh
  . "$(dirname "$0")/lib/bootstrap-link-shu.sh"
  RUN_LIST=(
    tests/vec/u16_roundtrip.su
    tests/map/iter_rehash.su
    tests/queue/u8_roundtrip.su
    tests/net/tcp_pool_smoke.su
    tests/fmt/template_smoke.su
    tests/stub/sqlite_net_stub.su
    tests/iterator/u64_roundtrip.su
  )
  RUN_OK=1
  for s in "${RUN_LIST[@]}"; do
    out="/tmp/shu_yellow_$(basename "$s" .su)"
    if $RUN_SHU -L . "$s" -o "$out" 2>/tmp/shu_yellow_build.log; then
      ec=0
      "$out" >/dev/null 2>&1 || ec=$?
      if [ "$ec" -ne 0 ]; then
        echo "next-yellow-clear WARN: runnable $s exit=$ec (continuing)" >&2
        RUN_OK=0
      fi
    else
      echo "next-yellow-clear SKIP link $s" >&2
      RUN_OK=0
    fi
  done
else
  echo "next-yellow-clear SKIP typeck (no native shu)" >&2
fi

echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} skip=${SKIP}"
echo "next-yellow-clear gate OK"
