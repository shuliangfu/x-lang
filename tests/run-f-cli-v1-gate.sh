#!/usr/bin/env bash
# F-cli v1：std.cli 去 C（cli.c → cli.sx）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CLI_V1_FAIL:-0}
DOC="analysis/phase-f-cli-v1.md"
MANIFEST="tests/baseline/f-cli-v1-closure.tsv"
die() { echo "f-cli-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-cli v1: cli.c → cli.sx ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-cli v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/cli/cli.sx ] || die "missing cli.sx"
[ ! -f std/cli/cli.c ] || die "cli.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'cli.sx' compiler/Makefile || die "Makefile missing cli.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/cli/cli.o >/dev/null 2>&1 || die "make cli.o failed"
else
  echo "f-cli-v1 SKIP cli.o build (no shux-c)" >&2
fi
if [ -f tests/run-std-cli-gate.sh ]; then
  chmod +x tests/run-std-cli-gate.sh
  tests/run-std-cli-gate.sh || die "std-cli gate failed"
fi
echo "f-cli-v1 gate OK"
