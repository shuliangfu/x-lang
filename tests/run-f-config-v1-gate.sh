#!/usr/bin/env bash
# F-config v1：std.config 去 C（config.c → config.x + config_io_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_CONFIG_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-config-v1.md"
MANIFEST="tests/baseline/f-config-v1-closure.tsv"
die() { echo "f-config-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-config v1: config.c → config.x + io glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-config v1' "$DOC" || die "doc marker"
[ -f std/config/config.x ] || die "missing config.x"
[ ! -f std/config/config_io_glue.c ] || die "config_io_glue.c should be deleted (F-ZC)"
[ ! -f std/config/config.c ] || die "config.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/config/config.o >/dev/null 2>&1 || die "ensure config.o failed (xlang_compiler_make)"
else
  echo "f-config-v1 SKIP config.o build (no xlang-c)" >&2
fi
for sub in run-std-config-gate.sh run-std-config-yaml-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-config-v1 gate OK"
