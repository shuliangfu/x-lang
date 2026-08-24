#!/usr/bin/env bash
# F-cli v1：std.cli 去 C（cli.c → cli.x）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_CLI_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-cli-v1.md"
MANIFEST="tests/baseline/f-cli-v1-closure.tsv"
die() { echo "f-cli-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-cli v1: cli.c → cli.x ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-cli v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/cli/cli.x ] || die "missing cli.x"
[ ! -f std/cli/cli.c ] || die "cli.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/cli/cli.o >/dev/null 2>&1 || die "ensure cli.o failed (xlang_compiler_make)"
else
  echo "f-cli-v1 SKIP cli.o build (no xlang-c)" >&2
fi
if [ -f tests/run-std-cli-gate.sh ]; then
  chmod +x tests/run-std-cli-gate.sh
  tests/run-std-cli-gate.sh || die "std-cli gate failed"
fi
echo "f-cli-v1 gate OK"
