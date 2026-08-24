#!/usr/bin/env bash
# F-security v1：std.security 去 C（security.c → security.x；F-ZC 纯 .x 无 os glue）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_SECURITY_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-security-v1.md"
MANIFEST="tests/baseline/f-security-v1-closure.tsv"
die() { echo "f-security-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-security v1: security.x (F-ZC zero C) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-security v1' "$DOC" || die "doc marker"
[ -f std/security/security.x ] || die "missing security.x"
[ ! -f std/security/security_os_glue.c ] || die "security_os_glue.c should be deleted (F-ZC)"
[ ! -f std/security/security.c ] || die "security.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'security_mlock_c' std/security/security.x || die "security.x missing mlock"
grep -q 'security_f_zero_c_marker_c' std/security/security.x || die "security.x missing zero-c marker"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/security/security.o >/dev/null 2>&1 || die "ensure security.o failed (xlang_compiler_make)"
else
  echo "f-security-v1 SKIP security.o build (no xlang-c)" >&2
fi
if [ -f tests/run-std-security-gate.sh ]; then
  chmod +x tests/run-std-security-gate.sh
  tests/run-std-security-gate.sh || die "std-security gate failed"
fi
echo "f-security-v1 gate OK"
