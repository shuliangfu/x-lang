#!/usr/bin/env bash
# SAFE-002: unsafe API inventory — leftover accept top-level DOC →硬绿.
#
# Honesty: leftover "prefer archive when present; accept top-level until
# SAFE soft knife" retired. Live = analysis/archive/safe/. Refuse
# top-level resurrect of safe-unsafe-api-v1.md (dual authority with
# archive). LANG-007 DOC live remains archive/lang. Nested
# run-lang-unsafe-gate.sh already honesty-closed (leave unused
# compiler-make source). Report: run=/obs=/skip=.
# Keep `safe-unsafe-api gate OK`.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-safe-unsafe-api-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

API_TSV="${XLANG_SAFE_UNSAFE_API_TSV:-tests/baseline/safe-unsafe-api.tsv}"
EXT_TSV="${XLANG_SAFE_UNSAFE_EXTERN_TSV:-tests/baseline/safe-unsafe-extern.tsv}"
PREFIX="xlang: [XLANG_SAFE_API]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-unsafe-api gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== SAFE-002: unsafe API manifest (archive DOC; refuse leftover accept top-level) ==="
# LANG-007 DOC live = archive/lang (honesty soft→硬绿 2026-08-27).
LANG_UNSAFE_DOC="analysis/archive/lang/lang-unsafe-v1-rfc.md"
SAFE_API_DOC="${XLANG_SAFE_UNSAFE_API_DOC:-analysis/archive/safe/safe-unsafe-api-v1.md}"
if [ -f analysis/safe-unsafe-api-v1.md ]; then
  die "dual-authority fossil analysis/safe-unsafe-api-v1.md (archive live)"
fi
if [ -f analysis/lang-unsafe-v1-rfc.md ]; then
  die "top-level lang-unsafe DOC resurrected (live = archive/lang/)"
fi
for f in \
  "$SAFE_API_DOC" \
  "$LANG_UNSAFE_DOC" \
  "$API_TSV" \
  "$EXT_TSV"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$SAFE_API_DOC" || die "doc missing ## Gate section"
echo "safe-unsafe-api manifest OK"

tier_u_source_symbol() {
  local sym="$1"
  local src="$2"
  case "$src:$sym" in
    std/heap/mod.x:alloc_aligned) echo "alloc_align" ;;
    std/heap/mod.x:alloc_i32|std/heap/mod.x:alloc_u8) echo "alloc" ;;
    std/heap/mod.x:free_i32|std/heap/mod.x:free_u8) echo "free" ;;
    std/heap/mod.x:realloc_i32|std/heap/mod.x:realloc_u8) echo "realloc" ;;
    std/heap/mod.x:copy_i32_at|std/heap/mod.x:copy_u8_at) echo "copy" ;;
    std/io/mod.x:read_ptr_len) echo "ptr_len" ;;
    std/io/mod.x:read_ptr_slice) echo "ptr_slice" ;;
    std/io/mod.x:read_ptr_gen) echo "ptr_gen" ;;
    std/io/mod.x:read_ptr_view) echo "ptr_view" ;;
    std/fs/mod.x:fs_read) echo "read" ;;
    std/fs/mod.x:fs_write) echo "write" ;;
    std/fs/mod.x:fs_pread) echo "pread" ;;
    std/fs/mod.x:fs_pwrite) echo "pwrite" ;;
    std/fs/mod.x:fs_mmap_ro) echo "mmap_ro" ;;
    std/fs/mod.x:fs_mmap_rw) echo "mmap_rw" ;;
    std/fs/mod.x:fs_munmap) echo "munmap" ;;
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
  die "${MISS}/${N} Tier-U symbols missing (refuse leftover accept top-level / leftover SKIP→OK)"
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
  die "Tier-E extern drift (refuse leftover accept top-level / leftover SKIP→OK)"
fi

echo "=== SAFE-002: LANG-007 unsafe boundary (hook) ==="
if [ "${XLANG_SAFE_SKIP_LANG_UNSAFE:-0}" = "1" ]; then
  echo "safe-unsafe-api: skip lang-unsafe hook (XLANG_SAFE_SKIP_LANG_UNSAFE=1)"
else
  chmod +x tests/run-lang-unsafe-gate.sh
  ./tests/run-lang-unsafe-gate.sh || die "nested LANG-007 failed (refuse leftover accept top-level / leftover SKIP→OK)"
fi

RUN_OK=$((RUN_OK + 1))
echo "safe-unsafe-api gate OK"
ok_report
exit 0
