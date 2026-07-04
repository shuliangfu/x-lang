#!/usr/bin/env bash
# STD-018：std.mem 与 core.mem 职责边界 manifest 门禁
#
# 1) std-mem-boundary-v1.md 职责矩阵
# 2) std.mem 不 import core.mem；双模块锚点存在
# 3) 可选：native shux 时 std_mem_boundary 烟测 typeck
#
# 用法：./tests/run-std-mem-boundary-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_MEM_BOUNDARY_DOC:-analysis/std-mem-boundary-v1.md}"
MANIFEST="${SHUX_STD_MEM_BOUNDARY_TSV:-tests/baseline/std-mem-boundary.tsv}"
CORE_X="core/mem/mod.x"
STD_X="std/mem/mod.x"
STD_README="std/mem/README.md"
SMOKE="tests/mem/std_mem_boundary.x"
LIB="tests/lib/std-mem-boundary.sh"
MIN_CORE=4
MIN_STD=4

# shellcheck source=tests/lib/std-mem-boundary.sh
. tests/lib/std-mem-boundary.sh

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

echo "=== STD-018: std.mem boundary manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CORE_X" "$STD_X" "$STD_README" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-mem-boundary gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_core_only) MIN_CORE="$c2" ;;
    min_std_only) MIN_STD="$c2" ;;
  esac
done < "$MANIFEST"

for kw in core.mem std.mem 职责矩阵 无重复; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-mem-boundary gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
CORE_N=0
STD_N=0
echo "=== STD-018: sections, smokes, refs ==="
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-mem-boundary FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    core_only) CORE_N=$((CORE_N + 1)) ;;
    std_only) STD_N=$((STD_N + 1)) ;;
    smoke|runner)
      if [ ! -f "$anchor" ]; then
        echo "std-mem-boundary FAIL: missing $anchor ($item_id)" >&2
        MISS=$((MISS + 1))
      elif [ "$kind" = "smoke" ] && ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-mem-boundary FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$mod_path" ]; then
        echo "std-mem-boundary FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
        echo "std-mem-boundary FAIL: $mod_path missing anchor '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    doc_readme|file)
  esac
done < "$MANIFEST"

if [ "$CORE_N" -lt "$MIN_CORE" ] || [ "$STD_N" -lt "$MIN_STD" ]; then
  echo "std-mem-boundary gate FAIL: core=${CORE_N} std=${STD_N}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-mem-boundary gate FAIL: missing=${MISS}" >&2
  exit 1
fi

sym_miss="$(std_mem_boundary_symbols_ok "$CORE_X" "$STD_X" "$MANIFEST" || true)"
cross_miss="$(std_mem_boundary_forbidden_ok "$STD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ] || [ "${cross_miss:-0}" -gt 0 ]; then
  std_mem_boundary_emit_report "fail" "$CORE_N" "$STD_N" 0 1
  exit 1
fi

# README 须引用边界 RFC
if ! grep -qF 'std-mem-boundary' "$STD_README" 2>/dev/null && ! grep -qF '职责边界' "$STD_README" 2>/dev/null; then
  echo "std-mem-boundary gate FAIL: std/mem/README.md missing boundary section" >&2
  exit 1
fi

SKIP=1
CHECK_OK=0
SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi
if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
    SKIP=0
  else
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -5 >&2 || true
    std_mem_boundary_emit_report "fail" "$CORE_N" "$STD_N" 1 0
    exit 1
  fi
else
  echo "std-mem-boundary gate SKIP typeck (no native shux)" >&2
fi

std_mem_boundary_emit_report "ok" "$CORE_N" "$STD_N" 1 "$SKIP"
echo "std-mem-boundary manifest OK (core=${CORE_N} std=${STD_N})"
echo "std-mem-boundary gate OK"
