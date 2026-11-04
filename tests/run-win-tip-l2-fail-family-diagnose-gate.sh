#!/usr/bin/env bash
# Knife 11.44: Win tip L2 fail-family diagnose gate.
# Locks baseline shape (pass>=1 rv OK; opt/si CG002 or documented; hello P012;
# f32 run 139 on tip PE). NOT product green. Soft Cap Prefer contrast optional.
set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PREFIX="xlang: [WIN_TIP_L2_FAIL_FAMILY_DIAGNOSE]"

die() { echo "${PREFIX} FAIL: $*" >&2; exit 1; }

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    ;;
  *)
    # Allow Darwin/Linux skip: diagnose authority is Win tip PE.
    echo "${PREFIX} status=skip host=${uname_s} reason=win_tip_pe_only"
    echo "win-tip-l2-fail-family-diagnose gate SKIP (Windows tip PE only)"
    exit 0
    ;;
esac

if [ -x ./compiler/xlang_asm.exe ]; then
  XLANG=./compiler/xlang_asm.exe
elif [ -x ./compiler/xlang_asm ]; then
  XLANG=./compiler/xlang_asm
elif [ -x ./compiler/xlang.exe ]; then
  XLANG=./compiler/xlang.exe
else
  die "missing tip PE XLANG (xlang_asm.exe)"
fi

TMP="${XLANG_MATRIX_TMP:-/tmp/xlang_win_l2_ff_$$}"
mkdir -p "$TMP"

# --- rv baseline: must stay OK (no regress below 1/5) ---
rm -f "$TMP/rv.exe"
set +e
"$XLANG" -o "$TMP/rv.exe" tests/return-value/main.x >"$TMP/rv.build" 2>&1
brc=$?
set -e
[ "$brc" -eq 0 ] && [ -x "$TMP/rv.exe" ] || die "rv BUILD fail (baseline regress); log=$(head -3 "$TMP/rv.build" | tr '\n' ' ')"
set +e
"$TMP/rv.exe" >"$TMP/rv.out" 2>"$TMP/rv.err"
rrc=$?
set -e
[ "$rrc" -eq 42 ] || die "rv RUN=$rrc expect 42 (baseline regress)"

# --- opt: tip PE CG002 code_len=0 ---
rm -f "$TMP/opt.exe"
set +e
"$XLANG" -o "$TMP/opt.exe" tests/option/main.x >"$TMP/opt.build" 2>&1
opt_brc=$?
set -e
grep -q 'CG002' "$TMP/opt.build" || die "opt expected CG002 on tip PE; got: $(head -3 "$TMP/opt.build" | tr '\n' ' ')"
grep -q 'code_len=0' "$TMP/opt.build" || die "opt expected elf ctx code_len=0"
[ "$opt_brc" -ne 0 ] || die "opt unexpectedly build OK (would raise baseline; refuse silent green)"

# --- hello / core.fmt P012 local-let mis-scope ---
rm -f "$TMP/hello.exe"
set +e
"$XLANG" -o "$TMP/hello.exe" examples/hello.x >"$TMP/hello.build" 2>&1
hello_brc=$?
set -e
grep -q 'P012' "$TMP/hello.build" || die "hello expected P012; got: $(head -3 "$TMP/hello.build" | tr '\n' ' ')"
[ "$hello_brc" -ne 0 ] || die "hello unexpectedly build OK"

rm -f "$TMP/cfm.exe"
set +e
"$XLANG" -o "$TMP/cfm.exe" core/fmt/mod.x >"$TMP/cfm.build" 2>&1
cfm_brc=$?
set -e
grep -q 'P012' "$TMP/cfm.build" || die "core.fmt alone expected P012 (local let mis-scope)"
grep -q 'num_digits' "$TMP/cfm.build" || die "core.fmt P012 locus should cite num_digits"
[ "$cfm_brc" -ne 0 ] || die "core.fmt unexpectedly build OK"

# --- f32: tip PE SEGV 139 ---
rm -f "$TMP/f32.exe"
set +e
"$XLANG" -o "$TMP/f32.exe" tests/float/f32_f64.x >"$TMP/f32.build" 2>&1
f32_brc=$?
set -e
[ "$f32_brc" -eq 0 ] && [ -x "$TMP/f32.exe" ] || die "f32 BUILD fail (unexpected; tip usually build0 run139)"
set +e
"$TMP/f32.exe" >"$TMP/f32.out" 2>"$TMP/f32.err"
f32_rrc=$?
set -e
# 139 = 128+11 SIGSEGV on many shells; also accept 11
if [ "$f32_rrc" -ne 139 ] && [ "$f32_rrc" -ne 11 ]; then
  die "f32 RUN=$f32_rrc expect 139/11 SEGV on tip PE (if 0: tip PE cleared — update gate honestly, do not soft SKIP)"
fi

# --- optional Soft Cap Prefer contrast (f32 green); never counts as tip L2 green ---
SC_NOTE="softcap_contrast=skip"
if [ -n "${XLANG_SOFTCAP_PROD:-}" ] && [ -x "${XLANG_SOFTCAP_PROD}" ]; then
  rm -f "$TMP/scf32.exe"
  set +e
  "$XLANG_SOFTCAP_PROD" -o "$TMP/scf32.exe" tests/float/f32_f64.x >"$TMP/scf32.build" 2>&1
  scb=$?
  set -e
  if [ "$scb" -eq 0 ] && [ -x "$TMP/scf32.exe" ]; then
    set +e
    "$TMP/scf32.exe" >"$TMP/scf32.out" 2>"$TMP/scf32.err"
    scr=$?
    set -e
    [ "$scr" -eq 0 ] || die "Soft Cap Prefer contrast f32 RUN=$scr expect 0 (control)"
    SC_NOTE="softcap_contrast=f32_run0"
  else
    die "Soft Cap Prefer contrast f32 BUILD failed"
  fi
fi

SHA="$(git rev-parse --short=9 HEAD 2>/dev/null || echo unknown)"
echo "${PREFIX} status=ok residual_locked=1 tip_l2_shape=1of5 rv=42 opt=CG002 hello=P012 core_fmt=P012_num_digits f32_run=${f32_rrc} ${SC_NOTE} sha=${SHA} host=Windows tip_pe=$(basename "$XLANG")"
echo "win-tip-l2-fail-family-diagnose gate OK (baseline locked; NOT product L2 green)"
exit 0
