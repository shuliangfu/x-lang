#!/usr/bin/env bash
# SAFE-004：FFI 边界内存契约 manifest 门禁
#
# 1) safe-ffi-contract-v1.md + matrix
# 2) 每个 case .sx 存在且文档引用
# 3) native shux：逐条编译运行 + run-ffi.sh hook
#
# 用法：./tests/run-safe-ffi-contract-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_SAFE_FFI_DOC:-analysis/safe-ffi-contract-v1.md}"
MANIFEST="${SHUX_SAFE_FFI_MANIFEST:-tests/baseline/safe-ffi-contract.tsv}"
MOD_SU="${SHUX_SAFE_FFI_MOD:-std/ffi/mod.sx}"
MIN_CASES=8

# shellcheck source=tests/lib/safe-ffi.sh
. tests/lib/safe-ffi.sh

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

echo "=== SAFE-004: FFI memory contract manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_SU" std/ffi/ffi.c; do
  if [ ! -f "$f" ]; then
    echo "safe-ffi-contract gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
echo "=== SAFE-004: contract matrix ==="
while IFS=$'\t' read -r case_id contract_rule api src expect_rc _tier _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  case "$case_id" in
    read_path|rules|matrix|verify)
      anchor="$api"
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|gate)
      if [ ! -f "$src" ]; then
        echo "safe-ffi FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ffi)
      path="tests/$api"
      if [ ! -f "$path" ]; then
        echo "safe-ffi FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$api")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing hook $api" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$api" ]; then
        echo "safe-ffi FAIL: missing xref $api" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$api")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing xref $api" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-ffi FAIL: missing case $src ($case_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$contract_rule" "$DOC" 2>/dev/null; then
        echo "safe-ffi FAIL: doc missing rule $contract_rule" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "safe-ffi-contract gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in contract FFI memory runnable cstr_len cstring_new; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "safe-ffi-contract gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "safe-ffi-contract gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "safe-ffi-contract manifest OK (cases=${CASE_N})"

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
  echo "=== SAFE-004: contract cases (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/ffi/ffi.o
  FAIL=0
  while IFS=$'\t' read -r case_id _rule _api src expect_rc _tier _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in
      case_*)
        if safe_ffi_run_case "$SHUX_BIN" "$src" "$expect_rc" "$case_id"; then
          echo "safe-ffi-contract OK $case_id"
        else
          FAIL=$((FAIL + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"
  if [ "$FAIL" -gt 0 ]; then
    echo "safe-ffi-contract gate FAIL: cases=${FAIL}" >&2
    exit 1
  fi
  chmod +x tests/run-ffi.sh
  ./tests/run-ffi.sh
else
  echo "safe-ffi-contract gate SKIP cases (no native shux)" >&2
fi

echo "safe-ffi-contract gate OK"
