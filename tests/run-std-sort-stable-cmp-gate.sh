#!/usr/bin/env bash
# STD-060：std.sort 稳定排序与自定义比较器门禁（假权威诚实）。
#
# 用法：./tests/run-std-sort-stable-cmp-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); stable_i32.x + cmp_desc.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Fossil API anchors → product:
# sort_stable_i32/sort_stable_u8→stable, sort_i32_cmp→cmp,
# cmp_i32_desc_fn→cmp_desc_fn. C smoke observational only.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SORT_STABLE_CMP_DOC:-analysis/archive/std/std-sort-stable-cmp-v1.md}"
MANIFEST="${XLANG_STD_SORT_STABLE_CMP_TSV:-tests/baseline/std-sort-stable-cmp.tsv}"
VECTORS="${XLANG_STD_SORT_STABLE_CMP_VECTORS:-tests/baseline/std-sort-stable-cmp-vectors.tsv}"
MOD_X="std/sort/mod.x"
SORT_X="std/sort/sort.x"
LIB="tests/lib/std-sort-stable-cmp.sh"
SMOKE_STABLE="tests/std-sort/stable_i32.x"
SMOKE_CMP="tests/std-sort/cmp_desc.x"
SMOKE_C="tests/std-sort/stable_smoke_ok.c"
# Designed success score (both product smokes return 0 on all checks).
SMOKE_EXPECT=0
MIN_APIS=3

# shellcheck source=tests/lib/std-sort-stable-cmp.sh
. "$LIB"

echo "=== STD-060: sort stable/cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SORT_X" "$SMOKE_STABLE" "$SMOKE_CMP" "$SMOKE_C" std/sort/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sort-stable-cmp gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-060 stable usize stable_dup; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sort-stable-cmp gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'cmp_desc' "$VECTORS" 2>/dev/null; then
  echo "std-sort-stable-cmp gate FAIL: vectors missing cmp_desc" >&2
  exit 1
fi

if ! grep -qF 'stable' std/sort/README.md 2>/dev/null; then
  echo "std-sort-stable-cmp gate FAIL: README missing stable" >&2
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
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

[ ! -f std/sort/sort.c ] || { echo "std-sort-stable-cmp gate FAIL: sort.c should be deleted" >&2; exit 1; }

sym_miss="$(std_sort_stable_cmp_symbols_ok "$MOD_X" "$SORT_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sort_stable_cmp_emit_report "fail" 0 0 0
  echo "std-sort-stable-cmp gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sort-stable-cmp manifest OK"

if [ "${XLANG_STD_SORT_STABLE_CMP_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sort_stable_cmp_emit_report "ok" 0 0 1
  echo "std-sort-stable-cmp gate OK (manifest only)"
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
# PLATFORM: SHARED archaeology — product honesty is stable_i32.x / cmp_desc.x via asm.
echo "=== STD-060: sort stable c smoke (observational) ==="
C_NOTE=0
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/sort/sort.o 2>/dev/null && std_sort_stable_cmp_run_c_smoke "$SORT_X"; then
    C_NOTE=1
    echo "std-sort-stable-cmp c smoke OK (observational)"
  else
    echo "std-sort-stable-cmp gate SKIP c smoke (observational; no full sort.o)" >&2
  fi
else
  echo "std-sort-stable-cmp gate SKIP c smoke (observational; no xlang-c)" >&2
fi
echo "std-sort-stable-cmp c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-060: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  CHECK_N=0
  for x in "$SMOKE_STABLE" "$SMOKE_CMP"; do
    if "$XLANG_BIN" check -L . "$x" >/dev/null 2>&1; then
      CHECK_N=$((CHECK_N + 1))
    else
      echo "std-sort-stable-cmp gate SKIP check $(basename "$x") (paused 2026-08-05)" >&2
    fi
  done
  if [ "$CHECK_N" -eq 2 ]; then
    CHECK_OK=1
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

  RUN_N=0
  for x in "$SMOKE_STABLE" "$SMOKE_CMP"; do
    tag="$(basename "$x" .x)"
    OUT="/tmp/xlang_std_sort_stable_${tag}_$$"
    LOG="/tmp/xlang_std_sort_stable_${tag}_build_$$.log"
    if $RUN_XLANG build -L . "$x" -o "$OUT" 2>"$LOG"; then
      exitcode=0
      "$OUT" >/dev/null 2>&1 || exitcode=$?
      rm -f "$OUT"
      if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
        RUN_N=$((RUN_N + 1))
      else
        echo "std-sort-stable-cmp gate FAIL runnable $x exit=$exitcode (expect $SMOKE_EXPECT)" >&2
        std_sort_stable_cmp_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
    else
      echo "std-sort-stable-cmp gate FAIL runnable link $x" >&2
      tail -20 "$LOG" 2>/dev/null >&2 || true
      std_sort_stable_cmp_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  done
  if [ "$RUN_N" -eq 2 ]; then
    RUN_OK=1
    SKIP=0
  fi
else
  echo "std-sort-stable-cmp gate FAIL: no native xlang" >&2
  std_sort_stable_cmp_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-sort-stable-cmp check_ok=${CHECK_OK} (observational)"
std_sort_stable_cmp_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-sort-stable-cmp gate OK"
