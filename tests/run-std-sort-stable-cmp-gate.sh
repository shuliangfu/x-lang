#!/usr/bin/env bash
# STD-060：std.sort 稳定排序与自定义比较器门禁
#
# 用法：./tests/run-std-sort-stable-cmp-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_SORT_STABLE_CMP_DOC:-analysis/std-sort-stable-cmp-v1.md}"
MANIFEST="${SHU_STD_SORT_STABLE_CMP_TSV:-tests/baseline/std-sort-stable-cmp.tsv}"
VECTORS="${SHU_STD_SORT_STABLE_CMP_VECTORS:-tests/baseline/std-sort-stable-cmp-vectors.tsv}"
MOD_SU="std/sort/mod.su"
SORT_C="std/sort/sort.c"
LIB="tests/lib/std-sort-stable-cmp.sh"
SMOKE_STABLE="tests/std-sort/stable_i32.su"
SMOKE_CMP="tests/std-sort/cmp_desc.su"
SMOKE_C="tests/std-sort/stable_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-sort-stable-cmp.sh
. "$LIB"

echo "=== STD-060: sort stable/cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SORT_C" "$SMOKE_STABLE" "$SMOKE_CMP" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-sort-stable-cmp gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-060 sort_stable_i32 usize stable_dup; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sort-stable-cmp gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'cmp_desc' "$VECTORS" 2>/dev/null; then
  echo "std-sort-stable-cmp gate FAIL: vectors missing cmp_desc" >&2
  exit 1
fi

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
        echo "std-sort-stable-cmp gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sort-stable-cmp gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sort-stable-cmp gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sort_stable_cmp_symbols_ok "$MOD_SU" "$SORT_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sort_stable_cmp_emit_report "fail" 0 0 0
  echo "std-sort-stable-cmp gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sort-stable-cmp manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/sort/sort.o

C_OK=0
if std_sort_stable_cmp_run_c_smoke "$SORT_C"; then
  C_OK=1
else
  std_sort_stable_cmp_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
SHU_BIN=""
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
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-060: .su smoke (SHU=$SHU_BIN) ==="
  for su in "$SMOKE_STABLE" "$SMOKE_CMP"; do
    if ! "$SHU_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "std-sort-stable-cmp gate FAIL: typeck $su" >&2
      "$SHU_BIN" check -L . "$su" 2>&1 | tail -10 >&2 || true
      std_sort_stable_cmp_emit_report "fail" "$C_OK" 0 0
      exit 1
    fi
    if ! std_sort_stable_cmp_run_smoke "$SHU_BIN" "$su" "$(basename "$su" .su)"; then
      std_sort_stable_cmp_emit_report "fail" "$C_OK" 0 0
      exit 1
    fi
  done
  SU_OK=1
else
  echo "std-sort-stable-cmp gate SKIP .su smoke (no native shu)" >&2
  SKIP=1
fi

std_sort_stable_cmp_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-sort-stable-cmp gate OK"
