#!/usr/bin/env bash
# E-05 v1/v2：编译器 include/src 头文件清单门禁（文件保留；active vs soft_retired 登记）。
#
# 用法：./tests/run-e05-include-soft-gate.sh
# 环境：
#   SHUX_E05_FAIL=1              — 失败时硬退出
#   SHUX_E05_MANIFEST_ONLY=1     — 仅 manifest
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E05_FAIL:-0}
DOC="analysis/phase-e-e05-v2.md"
DOC_V1="analysis/phase-e-e05-v1.md"
MF="tests/baseline/e05-include-inventory.tsv"
README="compiler/include/README.md"

die() {
  echo "e05 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== E-05 v2: compiler header inventory + runtime NO_C include guard ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V1" ] || die "missing $DOC_V1"
[ -f "$MF" ] || die "missing $MF"
[ -f "$README" ] || die "missing $README"
grep -q 'E-05 v2' "$DOC" || die "doc missing E-05 v2 marker"
grep -q 'E-05 v1/v2 inventory' "$README" || die "include/README missing E-05 inventory marker"

MISS=0
ACT=0
RET=0
while IFS=$'\t' read -r item_id _e_task path status _replacement check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      if [ ! -f "$path" ]; then
        echo "e05 manifest missing file: $path ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        case "$status" in
          active*|active) ACT=$((ACT + 1)) ;;
          soft_retired*) RET=$((RET + 1)) ;;
        esac
      fi
      ;;
    not_exists)
      if [ -f "$path" ]; then
        echo "e05 manifest should not exist: $path ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        RET=$((RET + 1))
      fi
      ;;
    grep)
      if [ ! -f "$path" ] || ! grep -q "$notes" "$path" 2>/dev/null; then
        echo "e05 grep fail: $path need '$notes' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    gate_ref)
      [ -f "$path" ] || { echo "e05 missing gate: $path" >&2; MISS=$((MISS + 1)); }
      ;;
    *)
      echo "e05 unknown check_type: $check_type ($item_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MF"

[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"
echo "e05 inventory: active_headers=${ACT} soft_retired_or_absent=${RET} (on disk unless not_exists)"

# E-05 v2：C 前端头须在 SHUX_NO_C_FRONTEND 守卫之后；preprocess/target_cpu/lsp_diag 仍无条件 include
guard_line=$(grep -n '#if !defined(SHUX_NO_C_FRONTEND)' compiler/src/runtime.inc | head -1 | cut -d: -f1)
[ -n "$guard_line" ] || die "runtime.c missing SHUX_NO_C_FRONTEND guard"
for hdr in 'lexer/lexer.h' 'parser/parser.h' 'typeck/typeck.h' 'codegen/codegen.h' 'ast.h'; do
  ln=$(grep -n "#include \"$hdr\"" compiler/src/runtime.inc | head -1 | cut -d: -f1 || true)
  if [ -n "$ln" ] && [ "$ln" -le "$guard_line" ]; then
    die "runtime.c unguarded include $hdr (line $ln, guard $guard_line)"
  fi
done
for h in preprocess.h target_cpu.h lsp/lsp_diag.h; do
  grep -q "#include \"$h\"" compiler/src/runtime.inc || die "runtime.c must still include $h"
done
echo "e05 v2: runtime.c NO_C include guard OK"

if [ "${SHUX_E05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e05 include soft-retire gate OK (manifest only)"
  exit 0
fi

if [ -f tests/run-e01-extern-h-soft-gate.sh ]; then
  echo "=== E-05: delegate E-01 extern .h ==="
  chmod +x tests/run-e01-extern-h-soft-gate.sh
  SHUX_E01_MANIFEST_ONLY=1 SHUX_E01_FAIL="$FAIL" ./tests/run-e01-extern-h-soft-gate.sh || die "E-01 delegate failed"
fi

# shellcheck source=tests/lib/phase-e-soft-audit.sh
. tests/lib/phase-e-soft-audit.sh
phase_e_soft_audit_no_extern_h_include || die "build still -include lsp_*_extern.h"

echo "e05 include inventory gate OK (E-05 v2 manifest; E-01 not_exists headers absent)"
