#!/usr/bin/env bash
# E-03 v3：shux-c OBJS_CORE 与 build_shux_asm SEED 冷启动 track gate（对照默认 bootstrap）。
#
# 用法：./tests/run-e03-v3-coldstart-track-gate.sh
# 环境：
#   SHUX_E03_V3_FAIL=1              — 失败时硬退出
#   SHUX_E03_V3_MANIFEST_ONLY=1     — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E03_V3_FAIL:-0}
DOC="analysis/phase-e-e03-v3-coldstart.md"
MF="tests/baseline/e03-coldstart-track.tsv"
MAKEFILE="compiler/Makefile"
BUILD="compiler/scripts/build_shux_asm.sh"

die() {
  echo "e03-v3 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-03 v3: cold-start / SEED track (OBJS_CORE vs default DRIVER_SEED) ==="
for f in "$DOC" "$MF" "$MAKEFILE" "$BUILD"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-03 v3' "$DOC" || die "doc missing E-03 v3 marker"
grep -q 'ensure_asm_driver_seed_c_objs' "$BUILD" || die "build_shux_asm missing ensure_asm_driver_seed_c_objs"
grep -q '^OBJS_CORE' "$MAKEFILE" || die "Makefile missing OBJS_CORE"
grep -q '^DRIVER_SEED_OBJS' "$MAKEFILE" || die "Makefile missing DRIVER_SEED_OBJS"

# 从 Makefile 提取 OBJS_CORE / DRIVER_SEED_OBJS 单行
OBJS_CORE_LINE=$(grep '^OBJS_CORE' "$MAKEFILE" | head -1)
DRIVER_SEED_LINE=$(sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MAKEFILE" | head -1)

audit_track() {
  local id="$1" path="$2" expect_in="$3"
  case "$expect_in" in
    OBJS_CORE)
      case "$path" in
        *parser.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/parser/parser\.o' || die "$id: OBJS_CORE missing parser.o" ;;
        *typeck.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/typeck/typeck\.o' || die "$id: OBJS_CORE missing typeck.o" ;;
        *codegen.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/codegen/codegen\.o' || die "$id: OBJS_CORE missing codegen.o" ;;
        *preprocess.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/preprocess\.o' || die "$id: OBJS_CORE missing preprocess.o" ;;
        *lexer.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/lexer/lexer\.o' || die "$id: OBJS_CORE missing lexer.o" ;;
        *ast.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/ast/ast\.o' || die "$id: OBJS_CORE missing ast.o" ;;
        *lsp_diag.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/lsp/lsp_diag\.o' || die "$id: OBJS_CORE missing lsp_diag.o" ;;
        *runtime_abi.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/runtime_abi\.o' || die "$id: OBJS_CORE missing runtime_abi.o" ;;
        *runtime_proc_abi.o*) echo "$OBJS_CORE_LINE" | grep -q 'src/runtime_proc_abi\.o' || die "$id: OBJS_CORE missing runtime_proc_abi.o" ;;
        *) die "$id: unknown OBJS_CORE track path $path" ;;
      esac
      echo "e03-v3 track OK: $id still in OBJS_CORE (shux-c cold start)"
      ;;
    bootstrap_shuxc)
      case "$path" in
        *bootstrap_shuxc_create*) [ -f compiler/scripts/bootstrap_shuxc_create.sh ] || die "$id: missing bootstrap_shuxc_create.sh" ;;
        *bootstrap_shuxc)
          if [ ! -x compiler/bootstrap_shuxc ] && [ ! -x compiler/shux_asm ] && [ ! -x compiler/shux ]; then
            die "$id: need bootstrap_shuxc or shux_asm to create seed"
          fi
          ;;
        *) die "$id: unknown bootstrap_shuxc path $path" ;;
      esac
      echo "e03-v3 track OK: $id G-06 bootstrap_shuxc cold start"
      ;;
    SEED_OMIT)
      if grep -q 'ensure_asm_driver_seed_frontend_c_objs' "$BUILD" \
        && ! grep -q 'G-02a: omit C frontend seed' "$BUILD" 2>/dev/null; then
        die "$id: build_shux_asm still compiles frontend .c in ensure_asm_driver_seed_frontend_c_objs"
      fi
      echo "e03-v3 track OK: $id SEED omit C frontend (G-02a)"
      ;;
    SEED_DIR)
      grep -q 'ensure_asm_driver_seed_c_objs' "$BUILD" || die "$id: missing seed function"
      case "$path" in
        *preprocess.c*) grep -q 'src/preprocess.c' "$BUILD" || die "$id: SEED missing preprocess.c" ;;
        *lexer.c*) grep -q 'src/lexer/lexer.c' "$BUILD" || die "$id: SEED missing lexer.c" ;;
        *ast_seed*) grep -q 'ast_seed.o' "$BUILD" || die "$id: SEED missing ast_seed" ;;
        *parser.c*) grep -q 'src/parser/parser.c' "$BUILD" || die "$id: SEED missing parser.c" ;;
        *) die "$id: unknown SEED track path $path" ;;
      esac
      echo "e03-v3 track OK: $id still in build_shux_asm SEED (archaeology)"
      ;;
    absent)
      if echo "$DRIVER_SEED_LINE" | grep -q "$path"; then
        die "$id: DRIVER_SEED_OBJS still hardcodes $path (expected absent; use *_LINK_O vars)"
      fi
      echo "e03-v3 contrast OK: $id absent from DRIVER_SEED_OBJS line"
      ;;
    *)
      die "$id: unknown expect_in $expect_in"
      ;;
  esac
}

MISS=0
while IFS=$'\t' read -r track_id layer path check_type expect_in notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in
    grep)
      [ -f "$path" ] || { echo "e03-v3 missing: $path" >&2; MISS=$((MISS + 1)); continue; }
      grep -q "$notes" "$path" || { echo "e03-v3 grep fail: $path need '$notes'" >&2; MISS=$((MISS + 1)); }
      ;;
    gate_ref)
      [ -f "$path" ] || { echo "e03-v3 missing gate: $path" >&2; MISS=$((MISS + 1)); }
      ;;
    track-only)
      audit_track "$track_id" "$path" "$expect_in" || MISS=$((MISS + 1))
      ;;
    absent)
      audit_track "$track_id" "$expect_in" "absent" || MISS=$((MISS + 1))
      ;;
    *)
      echo "e03-v3 unknown check_type: $check_type ($track_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MF"

[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"

if [ "${SHUX_E03_V3_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e03-v3 coldstart track gate OK (manifest only)"
  exit 0
fi

if [ -f tests/run-c06-sx-frontend-default-gate.sh ]; then
  echo "=== E-03 v3: delegate C-06 sx frontend default (contrast) ==="
  chmod +x tests/run-c06-sx-frontend-default-gate.sh
  SHUX_C06_FAIL="$FAIL" ./tests/run-c06-sx-frontend-default-gate.sh || die "C-06 delegate failed"
fi

echo "e03-v3 coldstart track gate OK (OBJS_CORE/SEED track-only; default DRIVER_SEED soft-retired)"
