#!/usr/bin/env bash
# STD-074：std.datetime 门禁
#
# 用法：./tests/run-std-datetime-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_DATETIME_DOC:-analysis/std-datetime-v1.md}"
MANIFEST="${SHU_STD_DATETIME_MANIFEST:-tests/baseline/std-datetime-manifest.tsv}"
VECTORS="${SHU_STD_DATETIME_VECTORS:-tests/baseline/std-datetime-vectors.tsv}"
MOD_SU="std/datetime/mod.su"
DT_C="std/datetime/datetime.c"
LIB="tests/lib/std-datetime.sh"
SMOKE_SU="tests/std-datetime/roundtrip.su"
SMOKE_C="tests/std-datetime/datetime_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-datetime.sh
. "$LIB"

echo "=== STD-074: std.datetime manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$DT_C" "$SMOKE_SU" "$SMOKE_C" std/datetime/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-datetime gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-074 RFC3339 DateTime Duration local_offset_min; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-datetime gate FAIL: doc missing '$kw'" >&2
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
    echo "std-datetime gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-datetime gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_datetime_symbols_ok "$MOD_SU" "$DT_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_datetime_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-datetime manifest OK"

if [ "${SHU_STD_DATETIME_MANIFEST_ONLY:-0}" = "1" ]; then
  std_datetime_emit_report "ok" 0 0 1
  echo "std-datetime gate OK (manifest only)"
  exit 0
fi

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-074: datetime c smoke ==="
make -C compiler ../std/datetime/datetime.o ../std/time/time.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shu_dt_smoke \
  "$SMOKE_C" std/datetime/datetime.o std/time/time.o 2>/dev/null; then
  if /tmp/shu_dt_smoke >/dev/null 2>&1; then
    C_OK=1
  fi
  rm -f /tmp/shu_dt_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_datetime_emit_report "fail" 0 0 0
  echo "std-datetime gate FAIL: c smoke" >&2
  exit 1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-074: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-datetime gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_datetime_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_datetime_run_smoke "$SHU_BIN" "$SMOKE_SU" "roundtrip"; then
    SU_OK=1
  else
    std_datetime_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-datetime gate SKIP .su smoke (no shu)" >&2
  SKIP=1
fi

std_datetime_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-datetime gate OK"
