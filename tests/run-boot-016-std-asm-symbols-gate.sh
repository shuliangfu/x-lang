#!/usr/bin/env bash
# BOOT-016：shu_asm 路径 Top-N std .o 符号完整性门禁
#
# 1) boot-016-std-asm-symbols-v1.md + manifest
# 2) runtime.c asm_ld_append_std_objs 含各 obj 路径
# 3) 构建 Top-N .o 并用 nm 校验锚点符号已定义
#
# 用法：./tests/run-boot-016-std-asm-symbols-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_BOOT016_DOC:-analysis/boot-016-std-asm-symbols-v1.md}"
MANIFEST="${SHU_BOOT016_TSV:-tests/baseline/boot-016-std-asm-symbols.tsv}"
RUNTIME="${SHU_BOOT016_RUNTIME:-compiler/src/runtime.c}"
LIB="tests/lib/boot-016-std-asm-symbols.sh"
MIN_TOP=12

# shellcheck source=tests/lib/boot-016-std-asm-symbols.sh
. tests/lib/boot-016-std-asm-symbols.sh

echo "=== BOOT-016: std asm symbol manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNTIME"; do
  if [ ! -f "$f" ]; then
    echo "boot-016-std-asm-symbols gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_top_n) MIN_TOP="$c2" ;;
  esac
done < "$MANIFEST"

for kw in shu_asm asm_ld_append_std_objs Top-N BOOT-016; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-016-std-asm-symbols gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
OBJ_N=0
echo "=== BOOT-016: manifest sections ==="
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-016 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

runtime_miss="$(boot016_verify_runtime_paths "$RUNTIME" "$MANIFEST" || true)"

if [ "${runtime_miss:-0}" -gt 0 ]; then
  boot016_emit_report "fail" 0 0 "$runtime_miss" 1
  exit 1
fi
echo "boot-016 runtime paths OK"

if ! command -v nm >/dev/null 2>&1; then
  echo "boot-016-std-asm-symbols gate SKIP nm (no nm)" >&2
  boot016_emit_report "ok" 0 0 0 1
  echo "boot-016-std-asm-symbols gate OK (skip)"
  exit 0
fi

SYM_MISS=0
OBJ_OK=0
echo "=== BOOT-016: Top-N std .o symbol check ==="
while IFS=$'\t' read -r item_id kind obj_rel anchor getter _notes; do
  [ "$kind" = "std_obj" ] || continue
  OBJ_N=$((OBJ_N + 1))
  if ! boot016_ensure_obj "$obj_rel"; then
    echo "boot-016 FAIL: missing object $obj_rel ($item_id)" >&2
    SYM_MISS=$((SYM_MISS + 1))
    continue
  fi
  if boot016_nm_has_symbol "$obj_rel" "$anchor"; then
    OBJ_OK=$((OBJ_OK + 1))
    echo "boot-016 OK $obj_rel:$anchor"
  else
    echo "boot-016 FAIL: $obj_rel missing symbol $anchor" >&2
    SYM_MISS=$((SYM_MISS + 1))
  fi
done < "$MANIFEST"

if [ "$OBJ_N" -lt "$MIN_TOP" ]; then
  echo "boot-016-std-asm-symbols gate FAIL: obj_rows=${OBJ_N} < min ${MIN_TOP}" >&2
  exit 1
fi
if [ "$SYM_MISS" -gt 0 ]; then
  boot016_emit_report "fail" "$OBJ_OK" "$SYM_MISS" 0 0
  exit 1
fi

boot016_emit_report "ok" "$OBJ_OK" 0 0 0
echo "boot-016-std-asm-symbols manifest OK (top_n=${OBJ_OK})"
echo "boot-016-std-asm-symbols gate OK"
