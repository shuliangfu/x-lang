#!/usr/bin/env bash
# TST-002：P0 模块边界测试波次 2 门禁（heap/vec/map/process）
#
# manifest + case 计数 + typeck + 链接烟测
# 用法：./tests/run-tst-002-boundary-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TST002_DOC:-analysis/tst-002-boundary-wave2-v1.md}"
MANIFEST="${SHU_TST002_TSV:-tests/baseline/tst-002-boundary-wave2.tsv}"
LIB="tests/lib/tst-002-boundary.sh"
MIN_CASES=8

# shellcheck source=tests/lib/tst-002-boundary.sh
. tests/lib/tst-002-boundary.sh

echo "=== TST-002: boundary wave 2 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "tst-002-boundary gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases_per_mod) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

for kw in std.heap std.vec std.map std.process boundary case 边界; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "tst-002-boundary gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

miss="$(tst002_verify_manifest "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  tst002_emit_report "fail" 0 0 0 0 1
  echo "tst-002-boundary gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi

BOUNDARY_N=0
while IFS=$'\t' read -r item_id kind path min_cases _mod _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|doc|gate) continue ;; esac
  case "$kind" in
    boundary)
      BOUNDARY_N=$((BOUNDARY_N + 1))
      want="${min_cases:-$MIN_CASES}"
      if ! tst002_count_cases "$path" "$want" >/dev/null; then
        tst002_emit_report "fail" 0 0 0 0 1
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$BOUNDARY_N" -lt 4 ]; then
  echo "tst-002-boundary gate FAIL: modules=${BOUNDARY_N} want 4" >&2
  exit 1
fi
echo "tst-002-boundary manifest OK (modules=${BOUNDARY_N} min_cases=${MIN_CASES})"

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

HEAP_OK=0
VEC_OK=0
MAP_OK=0
PROC_OK=0
SKIP=1
SHU_BIN=""

for cand in ./compiler/shu-c ./compiler/shu; do
  if stdlib_cm_native_shu "$cand"; then
    SHU_BIN="$cand"
    break
  fi
done

if [ -n "$SHU_BIN" ]; then
  echo "=== TST-002: typeck + smoke (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  make -C compiler -q ../std/heap/heap.o ../std/process/process.o 2>/dev/null \
    || make -C compiler ../std/heap/heap.o ../std/process/process.o 2>/dev/null || true
  for su in tests/heap/boundary.su tests/vec/boundary.su tests/map/boundary.su tests/process/boundary.su; do
    if ! "$SHU_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "tst-002-boundary gate FAIL: typeck $su" >&2
      "$SHU_BIN" check -L . "$su" 2>&1 | tail -8 >&2 || true
      tst002_emit_report "fail" "$HEAP_OK" "$VEC_OK" "$MAP_OK" "$PROC_OK" 0
      exit 1
    fi
  done
  if tst002_run_boundary "$SHU_BIN" tests/heap/boundary.su /tmp/shu_tst002_heap; then
    HEAP_OK=1
  else
    tst002_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if tst002_run_boundary "$SHU_BIN" tests/vec/boundary.su /tmp/shu_tst002_vec; then
    VEC_OK=1
  else
    tst002_emit_report "fail" "$HEAP_OK" 0 0 0 0
    exit 1
  fi
  if tst002_run_boundary "$SHU_BIN" tests/map/boundary.su /tmp/shu_tst002_map; then
    MAP_OK=1
  else
    tst002_emit_report "fail" "$HEAP_OK" "$VEC_OK" 0 0 0
    exit 1
  fi
  if tst002_run_boundary "$SHU_BIN" tests/process/boundary.su /tmp/shu_tst002_proc; then
    PROC_OK=1
  else
    tst002_emit_report "fail" "$HEAP_OK" "$VEC_OK" "$MAP_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "tst-002-boundary gate SKIP smoke (no native shu-c)" >&2
fi

tst002_emit_report "ok" "$HEAP_OK" "$VEC_OK" "$MAP_OK" "$PROC_OK" "$SKIP"
echo "tst-002-boundary gate OK"
