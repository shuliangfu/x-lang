#!/usr/bin/env bash
# STD-010：std.db.sqlite 接口预研 manifest 门禁
#
# 用法：./tests/run-std-sqlite-prereq-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SQLITE_DOC:-analysis/std-sqlite-prereq-v1.md}"
MANIFEST="${SHUX_STD_SQLITE_MANIFEST:-tests/baseline/std-sqlite-manifest.tsv}"
MOD_SU="${SHUX_STD_SQLITE_MOD:-std/db/sqlite/mod.sx}"
MIN_APIS=9
MIN_LAYERS=4
PREFIX="shux: [SHUX_STD_SQLITE]"

# shellcheck source=tests/lib/std-sqlite.sh
. tests/lib/std-sqlite.sh

echo "=== STD-010: std.db.sqlite prereq manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_SU" std/db/sqlite/README.md tests/lib/std-sqlite.sh tests/run-std-sqlite.sh; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in draft RFC runnable report SHUX_STD_SQLITE D1-connection DB_NOT_IMPL; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
    min_layers) MIN_LAYERS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
LAYER_N=0
echo "=== STD-010: manifest walk ==="
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_sqlite_has_api "$MOD_SU" "$anchor"; then
        echo "std-sqlite FAIL: missing API $anchor in $MOD_SU" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "std-sqlite FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$path")" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing ref $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-sqlite FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-sqlite FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sqlite gate FAIL: apis=${API_N} < min ${MIN_APIS}" >&2
  exit 1
fi
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "std-sqlite gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-sqlite gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-sqlite manifest OK (apis=${API_N}, layers=${LAYER_N})"

SHUX_BIN=""
if SHUX_BIN="$(std_sqlite_resolve_shu 2>/dev/null)"; then
  echo "=== STD-010: draft typeck smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  if ! std_sqlite_run_typeck "$SHUX_BIN" tests/std-sqlite/draft_typeck.sx draft_typeck; then
    echo "std-sqlite gate FAIL: typeck" >&2
    exit 1
  fi
else
  echo "std-sqlite gate SKIP typeck (no native shux)" >&2
fi

echo "=== STD-010: runnable report ==="
chmod +x tests/run-std-sqlite.sh tests/lib/std-sqlite.sh
if ! ./tests/run-std-sqlite.sh 2>&1 | tee /tmp/std_sqlite_smoke.log; then
  echo "std-sqlite gate FAIL: runner" >&2
  exit 1
fi
grep -qF "$PREFIX" /tmp/std_sqlite_smoke.log || {
  echo "std-sqlite gate FAIL: missing report prefix" >&2
  exit 1
}
grep -q 'std-sqlite OK' /tmp/std_sqlite_smoke.log || {
  echo "std-sqlite gate FAIL: runner did not OK" >&2
  exit 1
}
echo "std-sqlite prereq gate OK"
