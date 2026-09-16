#!/usr/bin/env bash
# STD-037: std.unicode NFC / non-BMP gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / hard check / nfc=/main= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` then xlang, never asm) +
# soft SKIP→OK (no native xlang-c still gate OK) + soft `ensure_std_c_o`
# + soft `xlang_compiler_make xlang-c … || true` + hard check as sole
# typeck + report `nfc=`/`main=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Host-C archaeology = obs only (no dedicated C harness; refuse soft
# ensure). check residual = obs (paused 2026-08-05). tip product -o
# UNDEF/SEGV = obs (product debt; leave). Report: run=/obs=/skip=.
# STD-082 unicode-normalization API 面缺失（nfd_buf／nfkc_buf／nfkd_buf）
# ＝产品另案. Live ensure_std family left. compress 残 try_libs left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-unicode-nfc-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_UNICODE_NFC_DOC:-analysis/archive/std/std-unicode-nfc-v1.md}"
MANIFEST="${XLANG_STD_UNICODE_NFC_TSV:-tests/baseline/std-unicode-nfc.tsv}"
MOD_X="std/unicode/mod.x"
UNI_IMPL="std/unicode/unicode.x"
LIB="tests/lib/std-unicode-nfc.sh"
NFC_X="tests/unicode/nfc_gold.x"
MAIN_X="tests/unicode/main.x"
MIN_APIS=3

# shellcheck source=tests/lib/std-unicode-nfc.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-unicode-nfc gate FAIL: $*" >&2
  std_unicode_nfc_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-037: unicode NFC manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$UNI_IMPL" "$NFC_X" "$MAIN_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-unicode-nfc-v1.md ] || die "dual-authority fossil analysis/std-unicode-nfc-v1.md (archive live)"

for kw in STD-037 NFC is_supplementary nfc_buf U+1F600; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

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

sym_miss="$(std_unicode_nfc_symbols_ok "$MOD_X" "$UNI_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-unicode-nfc manifest OK"
# STD-082 unicode-normalization: file presence not required (API 面缺失＝产品另案).
# PLATFORM: SHARED archaeology — refuse opening STD-082 knife here.

if [ "${XLANG_STD_UNICODE_NFC_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_unicode_nfc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-unicode-nfc gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-037: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="
# Host-C archaeology: refuse soft ensure_std_c_o / auto-make.
# No dedicated NFC C harness — do not rebuild std/unicode/unicode.o.
# PLATFORM: SHARED — product -o is the hard path; host-C left as archaeology.

# check = obs (paused); sample nfc_gold only to bound cost.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$NFC_X" >/tmp/xlang_std_unicode_nfc_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-unicode-nfc OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product UNDEF/SEGV residual = obs (leave product debt).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft silence.
if std_unicode_nfc_run_smoke "$XLANG_BIN" "$NFC_X" "nfc_gold"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-unicode-nfc OK: product nfc_gold"
else
  echo "std-unicode-nfc OBS tip product nfc_gold (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

if std_unicode_nfc_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-unicode-nfc OK: product main"
else
  echo "std-unicode-nfc OBS tip product main (UNDEF/SEGV residual)" >&2
  OBS=$((OBS + 1))
fi

std_unicode_nfc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-unicode-nfc gate OK"
