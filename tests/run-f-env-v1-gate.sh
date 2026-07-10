#!/usr/bin/env bash
# F-env v1：std.env 去 C（env.c → env.x + runtime_env_os.inc）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_ENV_V1_FAIL:-0}
DOC="analysis/phase-f-env-v1.md"
MANIFEST="tests/baseline/f-env-v1-closure.tsv"
die() { echo "f-env-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-env v1: env.c → env.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-env v1' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/env/env.x ] || die "missing env.x"
[ -f compiler/src/asm/runtime_env_os.inc ] || die "missing runtime_env_os.inc"
[ ! -f std/env/env_os_glue.c ] || die "env_os_glue.c should be deleted"
[ ! -f std/env/env.c ] || die "env.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'runtime_env_os' compiler/Makefile || die "Makefile missing runtime_env_os"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/env/env.o >/dev/null 2>&1 || die "make env.o failed"
else
  echo "f-env-v1 SKIP env.o build (no shux-c)" >&2
fi
for sub in run-std-env-iter-gate.sh run-std-env-platform-encoding-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-env-v1 gate OK"
