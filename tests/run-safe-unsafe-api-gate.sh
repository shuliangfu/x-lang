#!/usr/bin/env bash
# SAFE-002：unsafe API 清单自动检查门禁
#
# 1) safe-unsafe-api.tsv — Tier-U symbol 须在 source 存在
# 2) safe-unsafe-extern.tsv — Tier-E 模块 extern 集合须与 baseline 完全一致
# 3) 联动 LANG-007 run-lang-unsafe-gate.sh
#
# 用法：./tests/run-safe-unsafe-api-gate.sh
set -e
cd "$(dirname "$0")/.."

API_TSV="${SHUX_SAFE_UNSAFE_API_TSV:-tests/baseline/safe-unsafe-api.tsv}"
EXT_TSV="${SHUX_SAFE_UNSAFE_EXTERN_TSV:-tests/baseline/safe-unsafe-extern.tsv}"

echo "=== SAFE-002: unsafe API manifest ==="
for f in \
  analysis/safe-unsafe-api-v1.md \
  analysis/lang-unsafe-v1-rfc.md \
  "$API_TSV" \
  "$EXT_TSV"; do
  if [ ! -f "$f" ]; then
    echo "safe-unsafe-api gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "safe-unsafe-api manifest OK"

tier_u_source_symbol() {
  local sym="$1"
  local src="$2"
  case "$src:$sym" in
    std/heap/mod.sx:alloc_aligned) echo "alloc_align" ;;
    std/heap/mod.sx:alloc_i32|std/heap/mod.sx:alloc_u8) echo "alloc" ;;
    std/heap/mod.sx:free_i32|std/heap/mod.sx:free_u8) echo "free" ;;
    std/heap/mod.sx:realloc_i32|std/heap/mod.sx:realloc_u8) echo "realloc" ;;
    std/heap/mod.sx:copy_i32_at|std/heap/mod.sx:copy_u8_at) echo "copy" ;;
    std/io/mod.sx:read_ptr_len) echo "ptr_len" ;;
    std/io/mod.sx:read_ptr_slice) echo "ptr_slice" ;;
    std/io/mod.sx:read_ptr_gen) echo "ptr_gen" ;;
    std/io/mod.sx:read_ptr_view) echo "ptr_view" ;;
    std/fs/mod.sx:fs_read) echo "read" ;;
    std/fs/mod.sx:fs_write) echo "write" ;;
    std/fs/mod.sx:fs_pread) echo "pread" ;;
    std/fs/mod.sx:fs_pwrite) echo "pwrite" ;;
    std/fs/mod.sx:fs_mmap_ro) echo "mmap_ro" ;;
    std/fs/mod.sx:fs_mmap_rw) echo "mmap_rw" ;;
    std/fs/mod.sx:fs_munmap) echo "munmap" ;;
    *) echo "$sym" ;;
  esac
}

# ── Tier-U symbol 存在性 ──
MISS=0
N=0
echo "=== SAFE-002: Tier-U API symbol check ==="
while IFS=$'\t' read -r sym kind mod mode src; do
  [ -z "${sym:-}" ] && continue
  case "$sym" in \#*) continue ;; esac
  N=$((N + 1))
  if [ ! -f "$src" ]; then
    echo "safe-unsafe-api FAIL: missing source $src ($sym)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  source_sym="$(tier_u_source_symbol "$sym" "$src")"
  case "$kind" in
    struct)
      if ! grep -qE "struct ${source_sym}([[:space:]]|\\{)" "$src"; then
        echo "safe-unsafe-api FAIL: struct ${sym} not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    function)
      if ! grep -qE "function ${source_sym}\\(" "$src"; then
        echo "safe-unsafe-api FAIL: function ${sym} not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    *)
      echo "safe-unsafe-api FAIL: unknown kind $kind for $sym" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$API_TSV"

if [ "$MISS" -gt 0 ]; then
  echo "safe-unsafe-api gate FAIL: ${MISS}/${N} Tier-U symbols missing" >&2
  exit 1
fi
echo "safe-unsafe-api Tier-U OK (${N} symbols)"

# ── Tier-E extern 漂移检查 ──
echo "=== SAFE-002: Tier-E extern drift check ==="
# 按 source_file 分组 baseline extern
drift_fail=0
while IFS= read -r src_file || [ -n "$src_file" ]; do
  [ -z "$src_file" ] && continue
  case "$src_file" in \#*) continue ;; esac
  if [ ! -f "$src_file" ]; then
    echo "safe-unsafe-api FAIL: Tier-E source missing $src_file" >&2
    drift_fail=1
    continue
  fi
  # baseline 中该文件期望的 extern 集合
  expected="$(awk -F'\t' -v f="$src_file" '$1==f && $0 !~ /^#/ {print $2}' "$EXT_TSV" | sort -u)"
  # 源码实际 extern 集合
  actual="$(grep -oE 'extern function [a-zA-Z0-9_]+' "$src_file" \
    | sed 's/extern function //' | sort -u)"
  exp_n="$(printf '%s\n' "$expected" | grep -c . || true)"
  act_n="$(printf '%s\n' "$actual" | grep -c . || true)"
  # 未登记 extern
  while IFS= read -r en; do
    [ -z "$en" ] && continue
    if ! printf '%s\n' "$expected" | grep -qx "$en"; then
      echo "safe-unsafe-api FAIL: unlisted extern $en in $src_file (update $EXT_TSV)" >&2
      drift_fail=1
    fi
  done <<< "$actual"
  # baseline 中多余（已删除的 extern）
  while IFS= read -r en; do
    [ -z "$en" ] && continue
    if ! printf '%s\n' "$actual" | grep -qx "$en"; then
      echo "safe-unsafe-api FAIL: baseline extern $en missing from $src_file" >&2
      drift_fail=1
    fi
  done <<< "$expected"
  echo "safe-unsafe-api extern OK $src_file (${act_n} extern)"
done < <(awk -F'\t' '$0 !~ /^#/ && NF>=1 {print $1}' "$EXT_TSV" | sort -u)

if [ "$drift_fail" -ne 0 ]; then
  exit 1
fi

echo "=== SAFE-002: LANG-007 unsafe boundary (hook) ==="
chmod +x tests/run-lang-unsafe-gate.sh
./tests/run-lang-unsafe-gate.sh

echo "safe-unsafe-api gate OK"
