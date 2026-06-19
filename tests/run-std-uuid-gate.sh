#!/usr/bin/env bash
# STD-075：std.uuid 门禁
#
# 用法：./tests/run-std-uuid-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_UUID_DOC:-analysis/std-uuid-v1.md}"
MANIFEST="${SHUX_STD_UUID_MANIFEST:-tests/baseline/std-uuid-manifest.tsv}"
VECTORS="${SHUX_STD_UUID_VECTORS:-tests/baseline/std-uuid-vectors.tsv}"
MOD_SU="std/uuid/mod.sx"
UUID_C="std/uuid/uuid.c"
LIB="tests/lib/std-uuid.sh"
SMOKE_SU="tests/std-uuid/roundtrip.sx"
SMOKE_C="tests/std-uuid/uuid_smoke_ok.c"
MIN_APIS=7

# shellcheck source=tests/lib/std-uuid.sh
. "$LIB"

echo "=== STD-075: std.uuid manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$UUID_C" "$SMOKE_SU" "$SMOKE_C" std/uuid/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-uuid gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-075 new_v4 new_v7 parse format eq as_bytes; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-uuid gate FAIL: doc missing '$kw'" >&2
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
    echo "std-uuid gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-uuid gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_uuid_symbols_ok "$MOD_SU" "$UUID_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_uuid_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-uuid manifest OK"

if [ "${SHUX_STD_UUID_MANIFEST_ONLY:-0}" = "1" ]; then
  std_uuid_emit_report "ok" 0 0 1
  echo "std-uuid gate OK (manifest only)"
  exit 0
fi

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-075: uuid c smoke ==="
make -C compiler ../std/uuid/uuid.o ../std/random/random.o ../std/time/time.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shux_uuid_smoke \
  "$SMOKE_C" std/uuid/uuid.o std/random/random.o std/time/time.o 2>/dev/null; then
  if /tmp/shux_uuid_smoke >/dev/null 2>&1; then
    C_OK=1
  fi
  rm -f /tmp/shux_uuid_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_uuid_emit_report "fail" 0 0 0
  echo "std-uuid gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-075: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-uuid gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_uuid_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_uuid_run_smoke "$SHUX_BIN" "$SMOKE_SU" "roundtrip"; then
    SU_OK=1
  else
    std_uuid_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-uuid gate SKIP .sx smoke (no shux)" >&2
  SKIP=1
fi

std_uuid_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-uuid gate OK"
