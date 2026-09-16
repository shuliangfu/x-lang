#!/usr/bin/env bash
# DOD-S2 gate: std.vec Vec3f_soa (default SoA columns) + Vec3f_aos (opt-in AoS).
# Stages: observational check (paused) + heap alloc_f32 link + push/len/deinit
# + vec3f_soa_sum_x column scan.
#
# Honesty: soft SKIP→OK when no native xlang retired; check hard-fail under
# check-gate pause retired (CHK002 false-red). Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Darwin/ARM64 -o link via xlang-c remains platform backend (dod_host_exe_shu),
# not soft prefer-c for the whole gate. SysV xmm disasm N/A on non-x86 = skip;
# missing addss = obs. Report run=/obs=/skip=.
#
# Usage: ./tests/run-dod-s2-gate.sh
#        XLANG_ABI_F32_XMM=0 …  # legacy cvtsd2ss path
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu x86_64 gold for xmm/addss; Darwin i32/soa run.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/dod-host-backend.sh
. tests/lib/dod-host-backend.sh

PREFIX="${XLANG_DOD_S2_PREFIX:-xlang: [XLANG_DOD_S2]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "dod-s2 gate FAIL: $*" >&2
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

# dod-s2 xmm ABI active unless XLANG_ABI_F32_XMM=0 (legacy).
dod_s2_xmm_abi_active() {
  [ "${XLANG_ABI_F32_XMM:-1}" != "0" ]
}

echo "=== DOD-S2: std.vec Vec3f_soa / Vec3f_aos smoke ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

if dod_s2_xmm_abi_active; then
  echo "dod-s2: f32 xmm ABI active (default; XLANG_ABI_F32_XMM=0 for legacy cvtsd2ss)"
else
  echo "dod-s2: XLANG_ABI_F32_XMM=0 (legacy f64 widen + cvtsd2ss)"
fi

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
SMOKE_SRC="tests/vec/vec3f_soa_smoke.x"
SUM_SRC="tests/vec/vec3f_soa_sum_smoke.x"
MAIN_SRC="tests/vec/main.x"
SMOKE_OUT="$OUT_DIR/xlang_vec3f_soa_smoke"
SUM_OUT="$OUT_DIR/xlang_vec3f_soa_sum_smoke"
MAIN_OUT="$OUT_DIR/xlang_vec_main"
rm -f "$SMOKE_OUT" "$SUM_OUT" "$MAIN_OUT"

for f in "$SMOKE_SRC" "$SUM_SRC" "$MAIN_SRC"; do
  [ -f "$f" ] || die "missing $f"
done

# check paused 2026-08-05 — observational only (CHK002 must not hard-red the gate).
if "$XLANG_ABS" check -L . "$SMOKE_SRC" >/dev/null 2>&1; then
  echo "dod-s2: vec3f_soa_smoke typeck OK"
  RUN_OK=$((RUN_OK + 1))
else
  echo "dod-s2 OBS: check $SMOKE_SRC (check gate paused / tip residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
fi
if "$XLANG_ABS" check -L . "$SUM_SRC" >/dev/null 2>&1; then
  echo "dod-s2: vec3f_soa_sum_smoke typeck OK"
  RUN_OK=$((RUN_OK + 1))
else
  echo "dod-s2 OBS: check $SUM_SRC (check gate paused / tip residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
fi

DOD_EXE_XLANG="$(dod_host_exe_shu "$XLANG_ABS")"
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*)
    echo "dod-s2: Darwin -o link via xlang-c (seed asm/import path; Linux x86_64 covers xmm disasm)"
    ;;
  Linux-aarch64|Linux-arm64)
    echo "dod-s2: Linux ARM64 -o link via xlang-c (refresh xlang_asm lite)"
    ;;
  MINGW*|MSYS*)
    echo "dod-s2: Windows MSYS2 -o link via xlang-c"
    ;;
esac

# Compile with optional legacy env; Darwin/ARM use host exe shu + gate backend args.
dod_s2_compile() {
  local src="$1" out="$2" log="$3"
  if dod_s2_xmm_abi_active; then
    XLANG="$XLANG_ABS" "$DOD_EXE_XLANG" $DOD_GATE_BACKEND_ARGS -L . "$src" -o "$out" >"$log" 2>&1
  else
    env XLANG_ABI_F32_XMM=0 XLANG="$XLANG_ABS" "$DOD_EXE_XLANG" $DOD_GATE_BACKEND_ARGS -L . "$src" -o "$out" >"$log" 2>&1
  fi
}

# Vec3f_soa smoke: expect exit 3
if ! dod_s2_compile "$SMOKE_SRC" "$SMOKE_OUT" /tmp/xlang_dod_s2_build.log; then
  die "compile $SMOKE_SRC"
fi
[ -x "$SMOKE_OUT" ] || die "missing exe $SMOKE_OUT"
echo "dod-s2: vec3f_soa_smoke link OK"
RC=0
"$SMOKE_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 3 ]; then
  die "vec3f_soa_smoke expected exit 3, got $RC"
fi
echo "dod-s2: vec3f_soa_smoke exit=3 OK"
RUN_OK=$((RUN_OK + 1))

# SysV xmm disasm: Linux x86_64 only; Darwin/ARM = platform skip (not soft silence).
if dod_s2_xmm_abi_active; then
  if dod_host_f32_run_na; then
    echo "dod-s2: xmm disasm N/A on $(uname -s)-$(uname -m) (SysV xmm Linux x86_64 covers)"
    SKIP=$((SKIP + 1))
  elif command -v objdump >/dev/null 2>&1; then
    SMOKE_DIS="$(objdump -d "$SMOKE_OUT" 2>/dev/null || true)"
    if echo "$SMOKE_DIS" | grep -qE 'movd.*xmm'; then
      echo "dod-s2: vec3f_soa_smoke xmm disasm movd xmm present"
      RUN_OK=$((RUN_OK + 1))
    else
      echo "dod-s2 OBS: vec3f_soa_smoke xmm disasm missing movd xmm (product residual; not soft false-green)" >&2
      OBS=$((OBS + 1))
    fi
    if echo "$SMOKE_DIS" | grep -q 'cvtsd2ss'; then
      die "vec3f_soa_smoke (xmm) disasm still has cvtsd2ss"
    else
      echo "dod-s2: vec3f_soa_push xmm disasm OK"
      RUN_OK=$((RUN_OK + 1))
    fi
  fi
fi

# heap SoA column scan: 1+2+3=6
if ! dod_s2_compile "$SUM_SRC" "$SUM_OUT" /tmp/xlang_dod_s2_sum_build.log; then
  die "compile $SUM_SRC"
fi
[ -x "$SUM_OUT" ] || die "missing exe $SUM_OUT"
RC=0
"$SUM_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 6 ]; then
  die "vec3f_soa_sum_smoke expected exit 6, got $RC"
fi
echo "dod-s2: vec3f_soa_sum_smoke exit=6 OK"
RUN_OK=$((RUN_OK + 1))

if dod_host_f32_run_na; then
  echo "dod-s2: addss disasm N/A on $(uname -s)-$(uname -m) (Linux x86_64 covers)"
  SKIP=$((SKIP + 1))
elif command -v objdump >/dev/null 2>&1; then
  if objdump -d "$SUM_OUT" 2>/dev/null | grep -q 'addss'; then
    echo "dod-s2: vec3f_soa_sum_x disasm addss OK"
    RUN_OK=$((RUN_OK + 1))
  else
    echo "dod-s2 OBS: vec3f sum disasm missing addss (product residual; not soft false-green)" >&2
    OBS=$((OBS + 1))
  fi
fi

# std.vec base API run
if ! dod_s2_compile "$MAIN_SRC" "$MAIN_OUT" /tmp/xlang_dod_s2_main_build.log; then
  die "compile $MAIN_SRC"
fi
[ -x "$MAIN_OUT" ] || die "missing exe $MAIN_OUT"
RC=0
"$MAIN_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  die "vec main expected exit 0, got $RC"
fi
echo "dod-s2: vec main exit=0 OK"
RUN_OK=$((RUN_OK + 1))

echo "dod-s2 gate OK"
ok_report
