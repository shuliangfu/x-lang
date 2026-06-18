#!/usr/bin/env bash
# STD-072：std.bytes 门禁
#
# 用法：./tests/run-std-bytes-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_BYTES_DOC:-analysis/std-bytes-v1.md}"
MANIFEST="${SHU_STD_BYTES_MANIFEST:-tests/baseline/std-bytes-manifest.tsv}"
VECTORS="${SHU_STD_BYTES_VECTORS:-tests/baseline/std-bytes-vectors.tsv}"
MOD_SU="std/bytes/mod.su"
LIB="tests/lib/std-bytes.sh"
SMOKE_SU="tests/std-bytes/roundtrip.su"
MIN_APIS=12

# shellcheck source=tests/lib/std-bytes.sh
. "$LIB"

echo "=== STD-072: std.bytes manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU" std/bytes/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-bytes gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-072 bytes_append_slice bytes_as_view BytesReader reserve; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-bytes gate FAIL: doc missing '$kw'" >&2
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
    echo "std-bytes gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-bytes gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_bytes_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_bytes_emit_report "fail" 0 0
  exit 1
fi
echo "std-bytes manifest OK"

if [ "${SHU_STD_BYTES_MANIFEST_ONLY:-0}" = "1" ]; then
  std_bytes_emit_report "ok" 0 1
  echo "std-bytes gate OK (manifest only)"
  exit 0
fi

SU_OK=0
SKIP=0

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-072: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-bytes gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_bytes_emit_report "fail" 0 0
    exit 1
  fi
  if std_bytes_run_smoke "$SHU_BIN" "$SMOKE_SU" "roundtrip"; then
    SU_OK=1
  else
    std_bytes_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-bytes gate SKIP .su smoke (no shu)" >&2
  SKIP=1
fi

std_bytes_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-bytes gate OK"
