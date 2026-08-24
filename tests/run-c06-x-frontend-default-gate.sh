#!/usr/bin/env bash
# C-06：默认 bootstrap/relink 仅链 *_x.o 前端，不链 C parser/typeck/codegen.o。
#
# 用法：./tests/run-c06-x-frontend-default-gate.sh
# 环境：XLANG_C06_FAIL=1 失败时硬退出
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# Makefile deleted MG wave941 → compiler/mk/driver_seed_composites.mk +
# compiler/mk/driver_seed_mode_objs.mk（refuse resurrect）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_C06_FAIL:-0}
DOC="${XLANG_C06_DOC:-analysis/archive/phase/phase-c-c06-v1.md}"
MK_COMPOSITES="${XLANG_C06_MK_COMPOSITES:-compiler/mk/driver_seed_composites.mk}"
MK_MODE="${XLANG_C06_MK_MODE:-compiler/mk/driver_seed_mode_objs.mk}"

die() {
  echo "c06 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== C-06: x frontend default (no C parser.o in DRIVER_SEED_OBJS) ==="
for f in "$DOC" "$MK_COMPOSITES" "$MK_MODE"; do
  [ -f "$f" ] || die "missing $f"
done

if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)"
fi

grep -q 'C-06' "$DOC" || die "doc missing C-06 marker"
grep -q 'DRIVER_SEED_X_FRONTEND\|runtime_driver_no_c\|XLANG_LEGACY_C_FRONTEND' "$DOC" \
  || die "doc missing C-06 completion anchors"
grep -q 'DRIVER_SEED_X_FRONTEND_OBJS' "$MK_COMPOSITES" || die "missing DRIVER_SEED_X_FRONTEND_OBJS"
grep -q 'runtime_driver_no_c.o' "$MK_MODE" || die "missing runtime_driver_no_c default"
grep -q 'XLANG_LEGACY_C_FRONTEND' "$MK_MODE" || die "missing legacy escape hatch"
grep -q 'DRIVER_SEED_FRONTEND_EXTRA' "$MK_MODE" || die "missing DRIVER_SEED_FRONTEND_EXTRA"

# DRIVER_SEED_OBJS 不得直接含 C parser/typeck/codegen .o。
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MK_COMPOSITES" | grep -qE 'src/parser/parser\.o|src/typeck/typeck\.o|src/codegen/codegen\.o'; then
  die "DRIVER_SEED_OBJS still embeds C frontend .o"
fi

# Live x frontend objs must be present in the bag.
grep -q 'lexer_x.o\|parser_x.o\|typeck_x.o\|codegen_x.o' "$MK_COMPOSITES" \
  || die "mk missing *_x.o frontend objs"

echo "c06 x-frontend-default gate OK (mk DRIVER_SEED + archive DOC)"
