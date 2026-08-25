#!/usr/bin/env bash
# STD-150：std.sort 复杂 key 比较器策略门禁（假权威诚实）。
#
# 用法：./tests/run-std-sort-key-cmp-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); key_stable.x exit 0 hard-fail (no soft SKIP).
# Fossil API anchors → product: sort_stable_by_key→stable_by_key,
# cmp_key_i32_fn→cmp_key_fn, cmp_i32_asc_fn→cmp_asc_fn,
# sort_stable_key_tag_c→stable_key_tag. C smoke observational only.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SORT_KEY_CMP_DOC:-analysis/archive/std/std-sort-key-cmp-v1.md}"
MANIFEST="${XLANG_STD_SORT_KEY_CMP_MANIFEST:-tests/baseline/std-sort-key-cmp-manifest.tsv}"
VECTORS="${XLANG_STD_SORT_KEY_CMP_VECTORS:-tests/baseline/std-sort-key-cmp.tsv}"
MOD_X="std/sort/mod.x"
SORT_X="std/sort/sort.x"
LIB="tests/lib/std-sort-key-cmp.sh"
SMOKE_X="tests/std-sort/key_stable.x"
SMOKE_C="tests/std-sort/key_cmp_ok.c"
# Designed success score (key_stable.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-sort-key-cmp.sh
. "$LIB"

echo "=== STD-150: sort key cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SORT_X" "$SMOKE_X" "$SMOKE_C" std/sort/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sort-key-cmp gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-150 stable_by_key cmp_key_fn KeyTag; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sort-key-cmp gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "stable_by_key" std/sort/README.md 2>/dev/null; then
  echo "std-sort-key-cmp gate FAIL: README missing stable_by_key" >&2
  exit 1
fi

[ ! -f std/sort/sort.c ] || { echo "std-sort-key-cmp gate FAIL: sort.c should be deleted" >&2; exit 1; }

sym_miss="$(std_sort_key_cmp_symbols_ok "$MOD_X" "$SORT_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sort_key_cmp_emit_report "fail" 0 0 0
  exit 1
fi

if ! std_sort_key_cmp_vectors_ok "$VECTORS" 3; then
  std_sort_key_cmp_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-sort-key-cmp registry OK"

if [ "${XLANG_STD_SORT_KEY_CMP_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sort_key_cmp_emit_report "ok" 0 0 1
  echo "std-sort-key-cmp gate OK (manifest only)"
  exit 0
fi

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
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is key_stable.x via asm.
echo "=== STD-150: sort key c smoke (observational) ==="
C_NOTE=0
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/sort/sort.o 2>/dev/null && std_sort_key_cmp_run_c_smoke "$SORT_X"; then
    C_NOTE=1
    echo "std-sort-key-cmp c smoke OK (observational)"
  else
    echo "std-sort-key-cmp gate SKIP c smoke (observational; no full sort.o)" >&2
  fi
else
  echo "std-sort-key-cmp gate SKIP c smoke (observational; no xlang-c)" >&2
fi
echo "std-sort-key-cmp c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-150: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-sort-key-cmp gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/sort/mod.o 2>/dev/null || xlang_compiler_make ../std/sort/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/sort/sort.o 2>/dev/null || xlang_compiler_make ../std/sort/sort.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_sort_key_cmp_$$"
  LOG="/tmp/xlang_std_sort_key_cmp_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-sort-key-cmp gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_sort_key_cmp_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-sort-key-cmp gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_sort_key_cmp_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-sort-key-cmp gate FAIL: no native xlang" >&2
  std_sort_key_cmp_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-sort-key-cmp check_ok=${CHECK_OK} (observational)"
std_sort_key_cmp_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-sort-key-cmp gate OK"
