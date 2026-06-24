#!/usr/bin/env bash
# E-06 v1：bootstrap B-strict 段不得 cc -c E-03 软退役编译器前端 .c（链接 ld 除外）。
#
# 用法：./tests/run-e06-no-compiler-frontend-cc-gate.sh
# 环境：
#   SHUX_E06_FAIL=1              — 失败时硬退出
#   SHUX_E06_BUILD_LOG=/path     — 可选，审计 build_shux_asm 段日志
#   SHUX_E06_MANIFEST_ONLY=1     — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E06_FAIL:-0}
DOC="analysis/phase-e-e06-v2.md"
DOC_V1="analysis/phase-e-e06-v1.md"
MANIFEST="tests/baseline/e06-no-compiler-frontend-cc.tsv"
MF="compiler/Makefile"
BUILD="compiler/scripts/build_shux_asm.sh"
LOG="${SHUX_E06_BUILD_LOG:-}"

die() {
  echo "e06 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

# E-03 软退役前端 .c：build_shux_asm 严格段禁止 cc -c（asm_driver_seed 考古除外）。
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

echo "=== E-06 v5: Windows MSYS B-strict (SHUX_WIN_BSTRICT + build_shux_asm_is_msys) ==="
grep -q 'E-06 v5' analysis/phase-e-e06-v5.md || die "doc missing E-06 v5 marker"
grep -q 'build_shux_asm_is_msys' "$BUILD" || die "build_shux_asm missing build_shux_asm_is_msys"
grep -q 'bootstrap-driver-bstrict-windows' "$MF" || die "Makefile missing bootstrap-driver-bstrict-windows"
grep -q 'SHUX_WIN_BSTRICT' tests/run-bootstrap-bstrict-windows-gate.sh || die "windows gate missing SHUX_WIN_BSTRICT"

echo "=== E-06 v4: gen_driver fallback omit SEED C frontend when SX ready ==="
grep -q 'E-06 v4' analysis/phase-e-e06-v4.md || die "doc missing E-06 v4 marker"
grep -q 'asm_seed_omit_c_frontend_seed' "$BUILD" || die "build_shux_asm missing asm_seed_omit_c_frontend_seed"
grep -q 'asm_seed_gen_driver_c_frontend_link' "$BUILD" || die "build_shux_asm missing asm_seed_gen_driver_c_frontend_link"

echo "=== E-06 v3: strict relink SX-only (no SEED frontend cc -c on missing parser.o) ==="
grep -q 'E-06 v3' analysis/phase-e-e06-v3.md || die "doc missing E-06 v3 marker"
grep -q 'asm_seed_st_async_support_link' "$BUILD" || die "build_shux_asm missing asm_seed_st_async_support_link"

echo "=== E-06 v2: no cc -c compiler frontend .c (B-strict + SEED SX skip) ==="
for f in "$DOC" "$DOC_V1" "$MANIFEST" "$MF" "$BUILD"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-06 v2' "$DOC" || die "doc missing E-06 v2 marker"
grep -q 'asm_seed_use_sx_frontend' "$BUILD" || die "build_shux_asm missing asm_seed_use_sx_frontend"
grep -q 'ensure_asm_driver_seed_frontend_c_objs' "$BUILD" || die "build_shux_asm missing seed frontend split"
grep -q 'bootstrap-driver-bstrict' "$MF" || die "Makefile missing bootstrap-driver-bstrict"
grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN' "$MF" || die "Makefile bstrict missing SKIP_GEN"
grep -q 'build_shux_asm' "$BUILD" || die "build_shux_asm.sh missing"

MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in
    grep)
      if [ "$anchor" = "bootstrap-driver-bstrict" ]; then
        grep -q 'bootstrap-driver-bstrict' "$MF" || { echo "e06 missing bstrict target" >&2; MISS=$((MISS + 1)); }
        grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1' "$MF" || { echo "e06 missing SKIP_GEN=1" >&2; MISS=$((MISS + 1)); }
      elif [ "$anchor" = "compiler/scripts/build_shux_asm.sh" ]; then
        grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN' "$BUILD" || { echo "e06 build script missing SKIP_GEN" >&2; MISS=$((MISS + 1)); }
      else
        [ -f "$anchor" ] || { echo "e06 missing: $anchor" >&2; MISS=$((MISS + 1)); }
        grep -q "$notes" "$anchor" || { echo "e06 grep fail: $anchor need '$notes'" >&2; MISS=$((MISS + 1)); }
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

# 提取 build_shux_asm 段（排除 shux-c / bootstrap-driver-seed 的 OBJS_CORE 编译）
extract_build_shux_asm_log_section() {
  local log="$1"
  awk '/^build_shux_asm: using SHUX=/,0' "$log" 2>/dev/null || true
}

audit_log_no_frontend_cc() {
  local log="$1"
  local section line src
  section=$(extract_build_shux_asm_log_section "$log")
  if [ -z "$section" ]; then
    echo "e06 note: no build_shux_asm section in $log (skip log audit)"
    return 0
  fi
  while IFS= read -r line; do
    case "$line" in
      *"cc -c"*|*"gcc -c"*)
        if echo "$line" | grep -q 'asm_driver_seed'; then
          if echo "$section" | grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1'; then
            for src in "${FORBIDDEN_FRONTEND_C[@]}"; do
              if echo "$line" | grep -qE "cc -c .*${src}.*asm_driver_seed|cc -c .*asm_driver_seed.*${src}|cc -c .*${src}.*->.*asm_driver_seed"; then
                die "E-06 v2: SKIP_GEN build must not cc -c $src into asm_driver_seed (SHUX_LEGACY_SEED_FRONTEND_CC=1 for archaeology)"
              fi
            done
          fi
          echo "e06 track: SEED cc -c in build_shux_asm ($(echo "$line" | sed 's/^[[:space:]]*//' | cut -c1-80))"
          continue
        fi
        for src in "${FORBIDDEN_FRONTEND_C[@]}"; do
          if echo "$line" | grep -qE "cc -c .*${src}|gcc -c .*${src}"; then
            die "build_shux_asm log forbidden cc -c: $src (line: ${line:0:120})"
          fi
        done
        ;;
    esac
  done <<< "$section"
  # C-03 / E-06：pipeline_gen.c 禁止 cc -c（SEED 行除外）
  local filtered
  filtered=$(echo "$section" | grep -v 'asm_driver_seed' || true)
  if echo "$filtered" | grep -qE '(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'; then
    die "build_shux_asm log contains cc -c pipeline_gen.c (see C-03)"
  fi
  echo "e06 OK: audited build_shux_asm log section (no forbidden frontend cc -c outside SEED)"
}

if [ "${SHUX_E06_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e06 no-compiler-frontend-cc gate OK (manifest only)"
  exit 0
fi

echo "=== E-06: delegate C-03 pipeline_gen ==="
chmod +x tests/run-c03-no-pipeline-gen-gate.sh
SHUX_C03_MANIFEST_ONLY=1 SHUX_C03_FAIL="$FAIL" ./tests/run-c03-no-pipeline-gen-gate.sh || die "C-03 delegate failed"

echo "=== E-06: delegate C-06 sx frontend default ==="
chmod +x tests/run-c06-sx-frontend-default-gate.sh
SHUX_C06_FAIL="$FAIL" ./tests/run-c06-sx-frontend-default-gate.sh || die "C-06 delegate failed"

if [ -n "$LOG" ] && [ -f "$LOG" ]; then
  echo "=== E-06: audit build log $LOG ==="
  audit_log_no_frontend_cc "$LOG"
else
  echo "e06 note: no SHUX_E06_BUILD_LOG (run bootstrap-driver-bstrict first for full audit)"
fi

echo "e06 no-compiler-frontend-cc gate OK (B-strict segment; E-06 v2/v3/v4/v5 SEED SX skip + Windows B-strict track)"
