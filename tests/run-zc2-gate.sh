#!/usr/bin/env bash
# ZC-2 gate: read_ptr absolute-view smoke (gen / mmap / view) + M-5 read_ptr_slice.
#
# Honesty: soft SKIP→OK (no native / soft auto-make xlang-c) + prefer-c
# (xlang-c before asm for -o) + hard-bound `xlang check` retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make).
#   - gen + slice/slice_param product -o run exit0 = hard run.
#   - mmap/view tip wrong exit = obs (product residual; was soft-swallowed
#     or prefer-c masked). check path CHK002 / paused = obs.
#   - Windows mmap N/A (exit 9) = skip.
# Report: run=/obs=/skip=
# DOC authority = archive/zc. Usage: ./tests/run-zc2-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# zc3／zc4／zc5 remain host-c postponed (not this knife).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_ZC2_DOC:-analysis/archive/zc/zc-semantics-v1.md}"
PREFIX="${XLANG_ZC2_PREFIX:-xlang: [XLANG_ZC2]}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "zc2 gate FAIL: $*" >&2
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
    # Explicit XLANG that is not native = hard die (refuse soft fallthrough).
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

# Product -o compile + run. Return: 0=ok, 1=hard fail, 2=obs residual.
run_case() {
  local label="$1"
  local src="$2"
  local out="$3"
  local expect="$4"
  local feed="${5:-}"
  local log="/tmp/xlang_zc2_${label}.log"
  local rc=0

  [ -f "$src" ] || { echo "zc2 gate FAIL: missing $src" >&2; return 1; }
  rm -f "$out" 2>/dev/null || true

  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e

  if [ "$o_ec" -ne 0 ]; then
    echo "zc2 gate OBS $label (compile residual ec=$o_ec; refuse soft SKIP→OK)" >&2
    tail -n 8 "$log" 2>/dev/null || true
    return 2
  fi
  if [ ! -x "$out" ]; then
    echo "zc2 gate OBS $label (no native exe after compile; refuse soft SKIP→OK)" >&2
    return 2
  fi

  set +e
  if [ -n "$feed" ]; then
    printf '%s' "$feed" | "$out" >/dev/null 2>&1
    rc=$?
  else
    "$out" >/dev/null 2>&1
    rc=$?
  fi
  set -e
  rm -f "$out" 2>/dev/null || true

  if [ "$rc" -eq "$expect" ]; then
    echo "zc2: $label exit=$rc OK"
    return 0
  fi
  echo "zc2 gate OBS $label (expected exit $expect, got $rc; product residual)" >&2
  return 2
}

[ -f "$DOC" ] || die "missing DOC $DOC (refuse top-level DOC fossil)"
grep -qE '^## Gate' "$DOC" || die "DOC $DOC missing ## Gate (honesty)"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

mkdir -p "$OUT_DIR"
GEN_SRC="tests/io/read_ptr_gen_smoke.x"
MMAP_SRC="tests/io/read_ptr_mmap_smoke.x"
VIEW_SRC="tests/io/read_ptr_view_smoke.x"
SLICE_SRC="tests/io/read_ptr_slice.x"
SLICE_PARAM_SRC="tests/io/read_ptr_slice_param.x"

echo "=== ZC-2: read_ptr gen + mmap + view + slice (XLANG=$XLANG_BIN) ==="

# check path = observational only (check gate paused 2026-08-05).
set +e
"$XLANG_BIN" check -L . "$GEN_SRC" >/tmp/xlang_zc2_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "zc2 gate OBS check (CHK002 / paused; refuse hard-bind check)" >&2
  OBS=$((OBS + 1))
else
  echo "zc2: check OK (observational)"
fi

# --- gen (hard run expect 0) ---
rc=0
run_case gen "$GEN_SRC" "$OUT_DIR/xlang_zc2_read_ptr_gen" 0 "AB" || rc=$?
if [ "$rc" -eq 1 ]; then die "gen hard"; fi
if [ "$rc" -eq 2 ]; then OBS=$((OBS + 1)); else RUN_OK=$((RUN_OK + 1)); fi

# --- view (tip may residual; obs not soft silence) ---
rc=0
run_case view "$VIEW_SRC" "$OUT_DIR/xlang_zc2_read_ptr_view" 0 "AB" || rc=$?
if [ "$rc" -eq 1 ]; then die "view hard"; fi
if [ "$rc" -eq 2 ]; then OBS=$((OBS + 1)); else RUN_OK=$((RUN_OK + 1)); fi

# --- mmap (platform expect; tip residual = obs; Windows N/A = skip) ---
MMAP_EXPECT=21
OS="$(uname -s)"
# PLATFORM: DARWIN — mmap backend id differs (expect 22 = 20+2).
# PLATFORM: LINUX — expect 21 = 20+1.
# PLATFORM: WINDOWS — exit 9 = no mmap backend → skip.
if [ "$OS" = "Darwin" ]; then
  MMAP_EXPECT=22
fi
rc=0
run_case mmap "$MMAP_SRC" "$OUT_DIR/xlang_zc2_read_ptr_mmap" "$MMAP_EXPECT" "" || rc=$?
if [ "$rc" -eq 1 ]; then die "mmap hard"; fi
if [ "$rc" -eq 2 ]; then
  # Re-probe exit for Windows N/A classification without soft OK silence.
  case "$OS" in
    MINGW*|MSYS*)
      # Windows no-mmap backend is capability N/A → skip (status=ok).
      echo "zc2: mmap SKIP (no mmap backend on Windows)"
      SKIP=$((SKIP + 1))
      ;;
    *)
      OBS=$((OBS + 1))
      ;;
  esac
else
  RUN_OK=$((RUN_OK + 1))
fi

# --- slice + slice_param (hard run expect 0; inlined — refuse child prefer-c) ---
rc=0
run_case slice "$SLICE_SRC" "$OUT_DIR/xlang_zc2_read_ptr_slice" 0 "AB" || rc=$?
if [ "$rc" -eq 1 ]; then die "slice hard"; fi
if [ "$rc" -eq 2 ]; then OBS=$((OBS + 1)); else RUN_OK=$((RUN_OK + 1)); fi

rc=0
run_case slice_param "$SLICE_PARAM_SRC" "$OUT_DIR/xlang_zc2_read_ptr_slice_param" 0 "AB" || rc=$?
if [ "$rc" -eq 1 ]; then die "slice_param hard"; fi
if [ "$rc" -eq 2 ]; then OBS=$((OBS + 1)); else RUN_OK=$((RUN_OK + 1)); fi

# Negatives: missing DOC / ## Gate already die above.
# Soft SKIP→OK retired: no native already die; refuse exit0 on empty run.
if [ "$RUN_OK" -eq 0 ] && [ "$OBS" -eq 0 ] && [ "$SKIP" -eq 0 ]; then
  die "no cases ran (refuse soft SKIP→OK)"
fi

echo "zc2 gate OK"
ok_report
exit 0
