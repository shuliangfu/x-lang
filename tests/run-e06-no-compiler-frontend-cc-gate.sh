#!/usr/bin/env bash
# E-06: bootstrap B-strict must not cc -c E-03 soft-retired compiler frontend .c
# (link ld excluded). Honesty: soft XLANG_E06_FAIL + top-level DOC/Makefile
# anchors retired — those were portable false-green after MG wave941 archive.
#
# Usage: ./tests/run-e06-no-compiler-frontend-cc-gate.sh
# Env:
#   XLANG_E06_BUILD_LOG=/path     — optional audit of build_xlang_asm section
#   XLANG_E06_MANIFEST_ONLY=1     — manifest + static checks only (no delegates)
#
# Live authority: archive DOC + build_xlang_asm.sh + bootstrap_driver_bstrict.sh
# + xlang-build.sh (refuse compiler/Makefile resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC_V1="analysis/archive/phase/phase-e-e06-v1.md"
DOC_V2="analysis/archive/phase/phase-e-e06-v2.md"
DOC_V3="analysis/archive/phase/phase-e-e06-v3.md"
DOC_V4="analysis/archive/phase/phase-e-e06-v4.md"
DOC_V5="analysis/archive/phase/phase-e-e06-v5.md"
MANIFEST="tests/baseline/e06-no-compiler-frontend-cc.tsv"
BUILD="compiler/scripts/build_xlang_asm.sh"
BSTRICT="compiler/scripts/bootstrap_driver_bstrict.sh"
XBUILD_SH="xlang-build.sh"
LOG="${XLANG_E06_BUILD_LOG:-}"
PREFIX="xlang: [XLANG_E06]"

die() {
  echo "e06 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} bstrict=${BSTRICT_OK:-0} build=${BUILD_OK:-0} c03=${C03_OK:-0} c06=${C06_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# E-03 soft-retired frontend .c: build_xlang_asm strict segment bans cc -c
# (asm_driver_seed archaeology excepted).
FORBIDDEN_FRONTEND_C=(
  'src/parser/parser\.c'
  'src/typeck/typeck\.c'
  'src/codegen/codegen\.c'
  'src/codegen/autovec\.c'
  'src/preprocess\.c'
  'src/lexer/lexer\.c'
  'src/ast/ast\.c'
  'src/lsp/lsp_diag\.c'
)

DOC_OK=0
BSTRICT_OK=0
BUILD_OK=0
C03_OK=0
C06_OK=0
SKIP=1

echo "=== E-06: no compiler frontend cc (honesty; archive DOC) ==="
# Refuse top-level DOC resurrect (live = archive/phase/).
for top in analysis/phase-e-e06-v1.md analysis/phase-e-e06-v2.md \
  analysis/phase-e-e06-v3.md analysis/phase-e-e06-v4.md analysis/phase-e-e06-v5.md; do
  if [ -f "$top" ]; then
    die "top-level $top resurrected (live = archive/phase/)"
  fi
done
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + bootstrap_driver_bstrict.sh)"
fi

for f in "$DOC_V1" "$DOC_V2" "$DOC_V3" "$DOC_V4" "$DOC_V5" "$MANIFEST" "$BUILD" "$BSTRICT" "$XBUILD_SH"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-06 v1' "$DOC_V1" || die "doc missing E-06 v1 marker"
grep -q 'E-06 v2' "$DOC_V2" || die "doc missing E-06 v2 marker"
grep -q 'E-06 v3' "$DOC_V3" || die "doc missing E-06 v3 marker"
grep -q 'E-06 v4' "$DOC_V4" || die "doc missing E-06 v4 marker"
grep -q 'E-06 v5' "$DOC_V5" || die "doc missing E-06 v5 marker"
grep -qE '^## Gate' "$DOC_V2" || die "phase-e-e06-v2.md missing ## Gate honesty section"
DOC_OK=1

echo "=== E-06 v5: Windows MSYS B-strict track ==="
grep -q 'build_xlang_asm_is_msys' "$BUILD" || die "build_xlang_asm missing build_xlang_asm_is_msys"
grep -q 'bootstrap-driver-bstrict' "$XBUILD_SH" || die "xlang-build.sh missing bootstrap-driver-bstrict"
grep -q 'XLANG_WIN_BSTRICT' tests/run-bootstrap-bstrict-windows-gate.sh || die "windows gate missing XLANG_WIN_BSTRICT"

echo "=== E-06 v4: gen_driver fallback omit SEED C frontend when X ready ==="
grep -q 'asm_seed_omit_c_frontend_seed' "$BUILD" || die "build_xlang_asm missing asm_seed_omit_c_frontend_seed"
grep -q 'asm_seed_gen_driver_c_frontend_link' "$BUILD" || die "build_xlang_asm missing asm_seed_gen_driver_c_frontend_link"

echo "=== E-06 v3: strict relink X-only support ==="
grep -q 'asm_seed_st_async_support_link' "$BUILD" || die "build_xlang_asm missing asm_seed_st_async_support_link"

echo "=== E-06 v2: SKIP_GEN + X frontend (live bstrict script) ==="
grep -q 'asm_seed_use_x_frontend' "$BUILD" || die "build_xlang_asm missing asm_seed_use_x_frontend"
grep -q 'ensure_asm_driver_seed_frontend_c_objs' "$BUILD" || die "build_xlang_asm missing seed frontend split"
grep -q 'XLANG_ASM_EXPERIMENTAL_SKIP_GEN' "$BUILD" || die "build_xlang_asm missing SKIP_GEN"
grep -q 'XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1' "$BSTRICT" || die "bootstrap_driver_bstrict missing SKIP_GEN=1"
BUILD_OK=1
BSTRICT_OK=1

MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in
    grep)
      case "$anchor" in
        analysis/phase-e-e06-*|analysis/phase-c-c03-*|compiler/Makefile|bootstrap-driver-bstrict)
          # Archived DOC / retired Makefile target — live checks above.
          continue
          ;;
      esac
      if [ "$anchor" = "compiler/scripts/build_xlang_asm.sh" ]; then
        grep -q 'XLANG_ASM_EXPERIMENTAL_SKIP_GEN\|asm_seed_use_x_frontend' "$BUILD" \
          || { echo "e06 build script missing SKIP_GEN/X frontend" >&2; MISS=$((MISS + 1)); }
      elif [ -f "$anchor" ]; then
        grep -q "$notes" "$anchor" || { echo "e06 grep fail: $anchor need '$notes'" >&2; MISS=$((MISS + 1)); }
      else
        echo "e06 missing: $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    gate_ref)
      [ -f "$anchor" ] || { echo "e06 missing gate: $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
    *)
      echo "e06 unknown check_type: $check_type ($track_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"

extract_build_xlang_asm_log_section() {
  local log="$1"
  awk '/^build_xlang_asm: using XLANG=/,0' "$log" 2>/dev/null || true
}

audit_log_no_frontend_cc() {
  local log="$1"
  local section line src
  section=$(extract_build_xlang_asm_log_section "$log")
  if [ -z "$section" ]; then
    echo "e06 note: no build_xlang_asm section in $log (skip log audit)"
    return 0
  fi
  while IFS= read -r line; do
    case "$line" in
      *"cc -c"*|*"gcc -c"*)
        if echo "$line" | grep -q 'asm_driver_seed'; then
          if echo "$section" | grep -q 'XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1'; then
            for src in "${FORBIDDEN_FRONTEND_C[@]}"; do
              if echo "$line" | grep -qE "cc -c .*${src}.*asm_driver_seed|cc -c .*asm_driver_seed.*${src}|cc -c .*${src}.*->.*asm_driver_seed"; then
                die "E-06 v2: SKIP_GEN build must not cc -c $src into asm_driver_seed (XLANG_LEGACY_SEED_FRONTEND_CC=1 for archaeology)"
              fi
            done
          fi
          echo "e06 track: SEED cc -c in build_xlang_asm ($(echo "$line" | sed 's/^[[:space:]]*//' | cut -c1-80))"
          continue
        fi
        for src in "${FORBIDDEN_FRONTEND_C[@]}"; do
          if echo "$line" | grep -qE "cc -c .*${src}|gcc -c .*${src}"; then
            die "build_xlang_asm log forbidden cc -c: $src (line: ${line:0:120})"
          fi
        done
        ;;
    esac
  done <<< "$section"
  # C-03 / E-06: pipeline_gen.c ban (SEED lines excluded)
  local filtered
  filtered=$(echo "$section" | grep -v 'asm_driver_seed' || true)
  if echo "$filtered" | grep -qE '(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'; then
    die "build_xlang_asm log contains cc -c pipeline_gen.c (see C-03)"
  fi
  echo "e06 OK: audited build_xlang_asm log section (no forbidden frontend cc -c outside SEED)"
}

if [ "${XLANG_E06_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "e06 no-compiler-frontend-cc gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} bstrict=${BSTRICT_OK} build=${BUILD_OK} c03=${C03_OK} c06=${C06_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== E-06: delegate C-03 pipeline_gen ==="
chmod +x tests/run-c03-no-pipeline-gen-gate.sh
XLANG_C03_MANIFEST_ONLY=1 ./tests/run-c03-no-pipeline-gen-gate.sh || die "C-03 delegate failed"
C03_OK=1

echo "=== E-06: delegate C-06 x frontend default ==="
chmod +x tests/run-c06-x-frontend-default-gate.sh
./tests/run-c06-x-frontend-default-gate.sh || die "C-06 delegate failed"
C06_OK=1

if [ -n "$LOG" ] && [ -f "$LOG" ]; then
  echo "=== E-06: audit build log $LOG ==="
  audit_log_no_frontend_cc "$LOG"
else
  echo "e06 note: no XLANG_E06_BUILD_LOG (run bootstrap-driver-bstrict first for full audit)"
fi

SKIP=0
echo "e06 no-compiler-frontend-cc gate OK (B-strict segment; E-06 v2/v3/v4/v5 + C-03/C-06)"
echo "${PREFIX} status=ok doc=${DOC_OK} bstrict=${BSTRICT_OK} build=${BUILD_OK} c03=${C03_OK} c06=${C06_OK} skip=${SKIP} host=$(ci_host_summary)"
