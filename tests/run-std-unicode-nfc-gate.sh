#!/usr/bin/env bash
# STD-037：std.unicode NFC 与非 BMP 门禁
#
# 用法：./tests/run-std-unicode-nfc-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_UNICODE_NFC_DOC:-analysis/std-unicode-nfc-v1.md}"
MANIFEST="${SHUX_STD_UNICODE_NFC_TSV:-tests/baseline/std-unicode-nfc.tsv}"
UNI_SU="std/unicode/mod.sx"
UNI_C="std/unicode/unicode.c"
LIB="tests/lib/std-unicode-nfc.sh"
NFC_SU="tests/unicode/nfc_gold.sx"
MAIN_SU="tests/unicode/main.sx"
MIN_APIS=3

# shellcheck source=tests/lib/std-unicode-nfc.sh
. "$LIB"

echo "=== STD-037: unicode NFC manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$UNI_SU" "$UNI_C" "$NFC_SU" "$MAIN_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-unicode-nfc gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-037 NFC is_supplementary nfc_buf U+1F600; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-unicode-nfc gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
      if ! grep -qE "function ${anchor}\\(" "$UNI_SU" 2>/dev/null; then
        echo "std-unicode-nfc gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-unicode-nfc gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-unicode-nfc gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_unicode_nfc_symbols_ok "$UNI_SU" "$UNI_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_unicode_nfc_emit_report "fail" 0 0 1
  echo "std-unicode-nfc gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-unicode-nfc manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

NFC_OK=0
MAIN_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-037: typeck + smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/unicode/unicode.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$NFC_SU" >/dev/null 2>&1; then
    echo "std-unicode-nfc gate FAIL: typeck $NFC_SU" >&2
    "$SHUX_BIN" check -L . "$NFC_SU" 2>&1 | tail -10 >&2 || true
    std_unicode_nfc_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_unicode_nfc_run_smoke "$SHUX_BIN" "$NFC_SU" "nfc_gold"; then
    NFC_OK=1
  else
    std_unicode_nfc_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_unicode_nfc_run_smoke "$SHUX_BIN" "$MAIN_SU" "main"; then
    MAIN_OK=1
  else
    std_unicode_nfc_emit_report "fail" "$NFC_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-unicode-nfc gate SKIP smoke (no native shux-c)" >&2
fi

std_unicode_nfc_emit_report "ok" "$NFC_OK" "$MAIN_OK" "$SKIP"
echo "std-unicode-nfc gate OK"
