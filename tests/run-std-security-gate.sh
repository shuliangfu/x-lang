#!/usr/bin/env bash
# STD-079: std.security gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# security.o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product roundtrip.x -o exit0 = hard run.
# check residual / host-C archaeology = obs (paused 2026-08-05). Report:
# run=/obs=/skip=.
# formal_mod: mod.x prefix + security.x --bare-impl (was std_x bare →
# std_security_* UNDEF). API anchors: hkdf / err_ok (naming-spec; not fossil
# hkdf_sha256 / security_err_ok).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-security-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SECURITY_DOC:-analysis/archive/std/std-security-v1.md}"
MANIFEST="${XLANG_STD_SECURITY_MANIFEST:-tests/baseline/std-security-manifest.tsv}"
VECTORS="${XLANG_STD_SECURITY_VECTORS:-tests/baseline/std-security-vectors.tsv}"
MOD_X="std/security/mod.x"
SEC_X="std/security/security.x"
LIB="tests/lib/std-security.sh"
SMOKE_X="tests/std-security/roundtrip.x"
SMOKE_C="tests/std-security/security_smoke_ok.c"
MIN_APIS=10
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-security.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-security gate FAIL: $*" >&2
  std_security_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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

echo "=== STD-079: std.security manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SEC_X" "$SMOKE_X" "$SMOKE_C" std/security/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-079 ct_compare hkdf secure_zero sensitive_lock mem_eq; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null && ! grep -qF -- "$kw" "$MANIFEST" 2>/dev/null; then
    die "doc/manifest missing '$kw'"
  fi
done

grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_security_symbols_ok "$MOD_X" "$SEC_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-security manifest OK"

if [ "${XLANG_STD_SECURITY_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_security_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-security gate OK (manifest only)"
  exit 0
fi

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is roundtrip.x via asm.
# Refuse soft auto-make of xlang-c; security.o rebuild for host-C is best-effort.
echo "=== STD-079: security c smoke (observational) ==="
C_NOTE=0
if dod_native_exe ./compiler/xlang-c || dod_native_exe ./compiler/xlang || dod_native_exe ./compiler/xlang_asm; then
  xlang_compiler_make ../std/security/security.o >/dev/null 2>&1 || true
  if std_security_run_c_smoke "$SEC_X" 2>/tmp/xlang_sec_c_smoke.err; then
    C_NOTE=1
    echo "std-security c smoke OK (observational)"
  else
    echo "std-security OBS c smoke (archaeology link/run; refuse soft SKIP→OK)" >&2
    tail -n 8 /tmp/xlang_sec_c_smoke.err 2>/dev/null || true
  fi
else
  echo "std-security OBS c smoke (archaeology; no compiler)" >&2
fi
if [ "$C_NOTE" -eq 0 ]; then
  OBS=$((OBS + 1))
fi
echo "std-security c_smoke_note=${C_NOTE}"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-079: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_security_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-security OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std079_security_$$"
LOG="/tmp/xlang_std079_security_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-security OK: product -o"

std_security_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-security gate OK"
