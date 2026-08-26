#!/usr/bin/env bash
# E-05 v1/v2：编译器 include/src 头文件清单门禁（文件保留；active vs soft_retired 登记）。
#
# 用法：./tests/run-e05-include-soft-gate.sh
# 环境：
# 2026-08-26: soft XLANG_E05_FAIL retired (die always hard).
#   XLANG_E05_MANIFEST_ONLY=1     — 仅 manifest
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# monofile seeds/runtime.from_x.c retired wave321 — NO_C include guard lives in
# rt_* dispatch/run slices（refuse monofile resurrect）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_E05_DOC:-analysis/archive/phase/phase-e-e05-v2.md}"
DOC_V1="${XLANG_E05_DOC_V1:-analysis/archive/phase/phase-e-e05-v1.md}"
MF="tests/baseline/e05-include-inventory.tsv"
README="compiler/include/README.md"
# Live slices that still carry XLANG_NO_C_FRONTEND guards around C-frontend paths.
RT_NO_C="${XLANG_E05_RT_NO_C:-compiler/seeds/rt_dispatch_impl.from_x.c compiler/seeds/rt_run_compiler_parsed.from_x.c compiler/seeds/rt_run_x_emit.from_x.c compiler/seeds/rt_run_asm_backend.from_x.c}"

die() {
  echo "e05 gate FAIL: $*" >&2
  exit 1
}

e05_any_has() {
  local needle="$1"
  local f
  for f in $RT_NO_C; do
    if grep -qF "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

echo "=== E-05 v2: compiler header inventory + live rt_* NO_C guards ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V1" ] || die "missing $DOC_V1"
[ -f "$MF" ] || die "missing $MF"
[ -f "$README" ] || die "missing $README"
grep -q 'E-05 v2' "$DOC" || die "doc missing E-05 v2 marker"
grep -q 'E-05 v1/v2 inventory' "$README" || die "include/README missing E-05 inventory marker"

if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (NO_C guard live = rt_* slices)"
fi

MISS=0
ACT=0
RET=0
while IFS=$'\t' read -r item_id _e_task path status _replacement check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  # Skip top-level DOC rows that moved to archive (gate already pinned DOC path).
  case "$path" in
    analysis/phase-e-e05-*) continue ;;
  esac
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

# Live NO_C guards must still exist on rt_* product slices.
for f in $RT_NO_C; do
  [ -f "$f" ] || die "missing live seed $f"
done
e05_any_has 'XLANG_NO_C_FRONTEND' || die "live rt_* seeds missing XLANG_NO_C_FRONTEND guard"
# Always-on product headers still present (monofile include list retired with runtime.from_x.c).
[ -f compiler/src/preprocess.h ] || die "missing compiler/src/preprocess.h"
[ -f compiler/include/target_cpu.h ] || die "missing compiler/include/target_cpu.h"
[ -f compiler/src/lsp/lsp_diag.h ] || die "missing compiler/src/lsp/lsp_diag.h"
echo "e05 v2: live rt_* NO_C include guard OK"

if [ "${XLANG_E05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e05 include soft-retire gate OK (manifest only)"
  exit 0
fi

if [ -f tests/run-e01-extern-h-soft-gate.sh ]; then
  echo "=== E-05: delegate E-01 extern .h ==="
  chmod +x tests/run-e01-extern-h-soft-gate.sh
  # Hard-delegate; soft XLANG_E01_FAIL retired with honesty wave.
  XLANG_E01_MANIFEST_ONLY=1 ./tests/run-e01-extern-h-soft-gate.sh || die "E-01 delegate failed"
fi

# shellcheck source=tests/lib/phase-e-soft-audit.sh
. tests/lib/phase-e-soft-audit.sh
phase_e_soft_audit_no_extern_h_include || die "build still -include lsp_*_extern.h"

echo "e05 include inventory gate OK (E-05 v2 manifest; archive DOC; live rt_* NO_C)"
