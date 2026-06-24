#!/usr/bin/env bash
# F-config v1：std.config 去 C（config.c → config.sx + config_io_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CONFIG_V1_FAIL:-0}
DOC="analysis/phase-f-config-v1.md"
MANIFEST="tests/baseline/f-config-v1-closure.tsv"
die() { echo "f-config-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-config v1: config.c → config.sx + io glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-config v1' "$DOC" || die "doc marker"
[ -f std/config/config.sx ] || die "missing config.sx"
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
grep -q 'config.sx' compiler/Makefile || die "Makefile missing config.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/config/config.o >/dev/null 2>&1 || die "make config.o failed"
else
  echo "f-config-v1 SKIP config.o build (no shux-c)" >&2
fi
for sub in run-std-config-gate.sh run-std-config-yaml-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-config-v1 gate OK"
