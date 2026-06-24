#!/usr/bin/env bash
# F-security v1：std.security 去 C（security.c → security.sx；F-ZC 纯 .sx 无 os glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SECURITY_V1_FAIL:-0}
DOC="analysis/phase-f-security-v1.md"
MANIFEST="tests/baseline/f-security-v1-closure.tsv"
die() { echo "f-security-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-security v1: security.sx (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-security v1' "$DOC" || die "doc marker"
[ -f std/security/security.sx ] || die "missing security.sx"
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
grep -q 'security_mlock_c' std/security/security.sx || die "security.sx missing mlock"
grep -q 'security_f_zero_c_marker_c' std/security/security.sx || die "security.sx missing zero-c marker"
grep -q 'security.sx' compiler/Makefile || die "Makefile missing security.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/security/security.o >/dev/null 2>&1 || die "make security.o failed"
else
  echo "f-security-v1 SKIP security.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-security-gate.sh ]; then
  chmod +x tests/run-std-security-gate.sh
  tests/run-std-security-gate.sh || die "std-security gate failed"
fi
echo "f-security-v1 gate OK"
