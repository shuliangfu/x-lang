#!/usr/bin/env bash
# primary-campaign regression: suffix-chain ladder + IDENT/SELF heads + INT
# i64 head (the migrated parse_primary surface: literal arms, suffix loop,
# INT/IDENT heads). Honesty: hard die on missing native; product first.
#
# Usage: ./tests/run-primary-heads.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_PRIMARY_HEADS]"
RUN_OK=0

die() {
  echo "primary-heads FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} host=$(ci_host_summary)"
  exit 1
}

resolve_bin() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then echo "$abs"; return 0; fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then echo "$abs"; return 0; fi
  done
  return 1
}

run_pos() {
  local f="$1" want="$2" out ec
  out="/tmp/xlang_primary_heads_$(basename "$f" .x)"
  rm -f "$out"
  "$XLANG_BIN" -o "$out" "$f" >/dev/null 2>&1 || die "$f compile failed"
  ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  [ "$ec" -eq "$want" ] || die "$f run expected $want, got $ec"
  RUN_OK=$((RUN_OK + 1))
}

XLANG_BIN="$(resolve_bin)" || die "no native xlang/xlang_asm/xlang-c"

echo "=== primary heads (XLANG=$XLANG_BIN) ==="
run_pos tests/boundary/primary_suffix_ladder.x 46
echo "primary-heads OK suffix_ladder (46)"
run_pos tests/boundary/primary_ident_heads.x 106
echo "primary-heads OK ident_heads (106)"
run_pos tests/boundary/primary_int_i64.x 28
echo "primary-heads OK int_i64 (28)"

echo "${PREFIX} status=ok run=${RUN_OK} host=$(ci_host_summary)"
echo "primary-heads OK"
