#!/usr/bin/env bash
# F-env v1: std.env de-C (env.c → env.x + seeds/runtime_env_os.from_x.c).
#
# Usage: ./tests/run-f-env-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-env-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-025／STD-132 hard delegate. Soft XLANG_F_ENV_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/iter=/plat=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-env-v1.md"
MANIFEST="tests/baseline/f-env-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_ENV_V1]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-env-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} iter=${ITER_OK:-0} plat=${PLAT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
ITER_OK=0
PLAT_OK=0
SKIP=1

echo "=== F-env v1: std.env env.c → env.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-env v1' "$DOC" || die "doc missing F-env v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/env/env.x ] || die "missing std/env/env.x"
[ -f compiler/seeds/runtime_env_os.from_x.c ] || die "missing runtime_env_os.from_x.c"
[ ! -f std/env/env_os_glue.c ] || die "env_os_glue.c should be deleted"
[ ! -f std/env/env.c ] || die "env.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/env/env.o >/dev/null 2>&1 \
  || die "ensure env.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-env-iter-gate.sh ]; then
  echo "=== F-env v1: delegate run-std-env-iter-gate ==="
  chmod +x tests/run-std-env-iter-gate.sh
  if ! tests/run-std-env-iter-gate.sh; then
    die "std-env-iter sub-gate failed"
  fi
  ITER_OK=1
fi

if [ -f tests/run-std-env-platform-encoding-gate.sh ]; then
  echo "=== F-env v1: delegate run-std-env-platform-encoding-gate ==="
  chmod +x tests/run-std-env-platform-encoding-gate.sh
  if ! tests/run-std-env-platform-encoding-gate.sh; then
    die "std-env-platform-encoding sub-gate failed"
  fi
  PLAT_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} iter=${ITER_OK} plat=${PLAT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-env-v1 std.env gate OK (F-env v1; honesty)"
