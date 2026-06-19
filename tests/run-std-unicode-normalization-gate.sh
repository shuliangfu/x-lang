#!/usr/bin/env bash
# STD-082：std.unicode NFD/NFKC/NFKD 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_UNICODE_NORM_DOC:-analysis/std-unicode-normalization-v1.md}"
MANIFEST="${SHUX_STD_UNICODE_NORM_MANIFEST:-tests/baseline/std-unicode-normalization-manifest.tsv}"
MOD_SU="std/unicode/mod.sx"
UNI_C="std/unicode/unicode.c"
LIB="tests/lib/std-unicode-normalization.sh"
SMOKE_SU="tests/std-unicode-normalization/roundtrip.sx"
SMOKE_C="tests/std-unicode-normalization/normalization_smoke_ok.c"
MIN_APIS=6

# shellcheck source=tests/lib/std-unicode-normalization.sh
. "$LIB"

echo "=== STD-082: std.unicode normalization manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$UNI_C" "$SMOKE_SU" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-unicode-normalization gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-082 nfd_buf nfkc_buf nfkd_buf norm_form; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-unicode-normalization gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-unicode-normalization gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-unicode-normalization gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_unicode_norm_symbols_ok "$MOD_SU" "$UNI_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_unicode_norm_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-unicode-normalization manifest OK"

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-082: unicode normalization c smoke ==="
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/unicode/unicode.o
if cc -std=c11 -O1 -o /tmp/shux_unicode_norm_smoke "$SMOKE_C" std/unicode/unicode.o 2>/dev/null; then
  if /tmp/shux_unicode_norm_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shux_unicode_norm_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_unicode_norm_emit_report "fail" 0 0 0
  echo "std-unicode-normalization gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-082: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-unicode-normalization gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_unicode_norm_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_unicode_norm_run_smoke "$SHUX_BIN" "$SMOKE_SU" "roundtrip"; then SU_OK=1; else
    std_unicode_norm_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_unicode_norm_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-unicode-normalization gate OK"
