#!/usr/bin/env bash
# CORE-017: core.mem volatile/fence gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make xlang-c +
# bootstrap-link wrap + check SKIP narrative retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make). Product -o
# volatile_fence.x exit0 = hard run; check = obs. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-mem-volatile-fence-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

MOD_X="core/mem/mod.x"
MANIFEST="tests/baseline/core-mem-volatile-fence.tsv"
SMOKE_X="tests/core-mem/volatile_fence.x"
SMOKE_EXPECT=0

PREFIX="${XLANG_CORE017_MEM_VOLATILE_PREFIX:-xlang: [XLANG_CORE017_MEM_VOLATILE]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-mem-volatile gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== CORE-017: core.mem volatile/fence (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
for f in "$MOD_X" "$MANIFEST" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

MIN_APIS=6
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        die "missing api $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"
if [ "$API_N" -lt "$MIN_APIS" ]; then
  die "api count $API_N < min $MIN_APIS"
fi
echo "core-mem-volatile manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "core-mem-volatile OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core017_mem_vf_$$"
trap 'rm -f "$exe"' EXIT
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$exe" >/tmp/xlang_core017_mem_vf_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core017_mem_vf_o.log 2>/dev/null || true
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$run_ec (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))

echo "core-mem-volatile-fence gate OK"
ok_report
