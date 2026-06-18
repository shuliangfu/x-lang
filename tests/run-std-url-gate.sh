#!/usr/bin/env bash
# STD-076：std.url 门禁
#
# 用法：./tests/run-std-url-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_URL_DOC:-analysis/std-url-v1.md}"
MANIFEST="${SHU_STD_URL_MANIFEST:-tests/baseline/std-url-manifest.tsv}"
VECTORS="${SHU_STD_URL_VECTORS:-tests/baseline/std-url-vectors.tsv}"
MOD_SU="std/url/mod.su"
URL_C="std/url/url.c"
LIB="tests/lib/std-url.sh"
SMOKE_SU="tests/std-url/roundtrip.su"
SMOKE_C="tests/std-url/url_smoke_ok.c"
MIN_APIS=6

# shellcheck source=tests/lib/std-url.sh
. "$LIB"

echo "=== STD-076: std.url manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$URL_C" "$SMOKE_SU" "$SMOKE_C" std/url/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-url gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-076 parse build query_encode resolve IPv6; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-url gate FAIL: doc missing '$kw'" >&2
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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-url gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-url gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_url_symbols_ok "$MOD_SU" "$URL_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_url_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-url manifest OK"

if [ "${SHU_STD_URL_MANIFEST_ONLY:-0}" = "1" ]; then
  std_url_emit_report "ok" 0 0 1
  echo "std-url gate OK (manifest only)"
  exit 0
fi

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-076: url c smoke ==="
make -C compiler ../std/url/url.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shu_url_smoke \
  "$SMOKE_C" std/url/url.o 2>/dev/null; then
  if /tmp/shu_url_smoke >/dev/null 2>&1; then
    C_OK=1
  fi
  rm -f /tmp/shu_url_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_url_emit_report "fail" 0 0 0
  echo "std-url gate FAIL: c smoke" >&2
  exit 1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-076: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-url gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_url_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_url_run_smoke "$SHU_BIN" "$SMOKE_SU" "roundtrip"; then
    SU_OK=1
  else
    std_url_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-url gate SKIP .su smoke (no shu)" >&2
  SKIP=1
fi

std_url_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-url gate OK"
