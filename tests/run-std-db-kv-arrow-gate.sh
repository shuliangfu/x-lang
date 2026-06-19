#!/usr/bin/env bash
# std.db kv + arrow 门禁：manifest + typeck + C 烟测 + 可选 .sx 链接运行
set -e
cd "$(dirname "$0")/.."

MOD_KV="std/db/kv/mod.sx"
MOD_ARROW="std/db/arrow/mod.sx"
MOD_DB="std/db/mod.sx"
MOD_SQLITE="std/db/sqlite/mod.sx"
KV_C="std/db/kv/kv.c"
ARROW_C="std/db/arrow/arrow.c"
MMAP_C="std/sys/mmap.inc.c"
SMOKE_KV="tests/std-db/kv_tick_smoke.sx"
SMOKE_ARROW="tests/std-db/arrow_column_smoke.sx"
COOKBOOK_DB="examples/cookbook/db_kv_arrow.sx"
README="std/db/README.md"

echo "=== std.db kv+arrow: manifest ==="
for f in "$MOD_KV" "$MOD_ARROW" "$MOD_DB" "$MOD_SQLITE" "$KV_C" "$ARROW_C" "$MMAP_C" "$README"; do
  if [ ! -f "$f" ]; then
    echo "std-db-kv-arrow gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in std.db.kv std.db.arrow mmap LSM WAL compact null_bitmap adopt SIMD SST; do
  if ! grep -qF "$kw" "$README" 2>/dev/null; then
    echo "std-db-kv-arrow gate FAIL: README missing '$kw'" >&2
    exit 1
  fi
done
echo "std-db-kv-arrow manifest OK"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ] && [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux
fi

if [ -n "$SHUX_BIN" ] && [ -x "$SHUX_BIN" ]; then
  if "$SHUX_BIN" check -L . "$SMOKE_KV" >/dev/null 2>&1 \
     && "$SHUX_BIN" check -L . "$SMOKE_ARROW" >/dev/null 2>&1; then
    echo "std-db-kv-arrow typeck OK"
  else
    echo "std-db-kv-arrow gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_KV" 2>&1 | tail -5 >&2 || true
    "$SHUX_BIN" check -L . "$SMOKE_ARROW" 2>&1 | tail -5 >&2 || true
    exit 1
  fi
fi

make -C compiler ../std/db/kv/kv.o ../std/db/arrow/arrow.o >/dev/null 2>&1

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cc -c -o "$TMP/kv.o" "$KV_C"
cc -c -o "$TMP/arrow.o" "$ARROW_C"

KV_PATH="$TMP/kv_smoke.dat"
cat >"$TMP/kv_smoke_main.c" <<EOF
#include <stdint.h>
extern int32_t db_kv_smoke_c(uint8_t *path);
int main(void) {
  uint8_t p[] = "$KV_PATH";
  return db_kv_smoke_c(p) == 0 ? 0 : 1;
}
EOF
if ! cc -o "$TMP/kv_c_smoke" "$TMP/kv_smoke_main.c" "$TMP/kv.o" 2>/dev/null; then
  echo "std-db-kv-arrow gate FAIL: kv C smoke compile" >&2
  exit 1
fi
"$TMP/kv_c_smoke" || { echo "std-db-kv-arrow gate FAIL: kv C smoke run" >&2; exit 1; }
echo "std-db-kv-arrow kv C smoke OK"

cat >"$TMP/arrow_smoke_main.c" <<'EOF'
#include <stdint.h>
extern int32_t arrow_smoke_c(void);
int main(void) { return arrow_smoke_c() == 0 ? 0 : 1; }
EOF
if ! cc -o "$TMP/arrow_c_smoke" "$TMP/arrow_smoke_main.c" "$TMP/arrow.o" 2>/dev/null; then
  echo "std-db-kv-arrow gate FAIL: arrow C smoke compile" >&2
  exit 1
fi
"$TMP/arrow_c_smoke" || { echo "std-db-kv-arrow gate FAIL: arrow C smoke run" >&2; exit 1; }
echo "std-db-kv-arrow arrow C smoke OK"

mkdir -p tests/std-db
RUN_OK=0
SHUX_LINK=""
if [ -x ./compiler/shux-c ]; then
  SHUX_LINK=./compiler/shux-c
elif [ -n "$SHUX_BIN" ] && [ -x "$SHUX_BIN" ]; then
  SHUX_LINK="$SHUX_BIN"
fi
KV_O="std/db/kv/kv.o"
ARROW_O="std/db/arrow/arrow.o"
if [ -n "$SHUX_LINK" ]; then
  if "$SHUX_LINK" -L . "$SMOKE_KV" -o "$TMP/kv_smoke" "$KV_O" 2>/dev/null && [ -x "$TMP/kv_smoke" ]; then
    if "$TMP/kv_smoke"; then
      RUN_OK=$((RUN_OK + 1))
      echo "std-db-kv-arrow kv .sx run OK"
    else
      echo "std-db-kv-arrow gate FAIL: kv .sx run" >&2
      exit 1
    fi
  fi
  if "$SHUX_LINK" -L . "$SMOKE_ARROW" -o "$TMP/arrow_smoke" "$ARROW_O" 2>/dev/null && [ -x "$TMP/arrow_smoke" ]; then
    if "$TMP/arrow_smoke"; then
      RUN_OK=$((RUN_OK + 1))
      echo "std-db-kv-arrow arrow .sx run OK"
    else
      echo "std-db-kv-arrow gate FAIL: arrow .sx run" >&2
      exit 1
    fi
  fi
  if [ -f "$COOKBOOK_DB" ] \
     && "$SHUX_LINK" -L . "$COOKBOOK_DB" -o "$TMP/db_kv_arrow" "$KV_O" "$ARROW_O" 2>/dev/null \
     && [ -x "$TMP/db_kv_arrow" ]; then
    if "$TMP/db_kv_arrow"; then
      RUN_OK=$((RUN_OK + 1))
      echo "std-db-kv-arrow cookbook DB-03 run OK"
    else
      echo "std-db-kv-arrow gate FAIL: cookbook DB-03 run" >&2
      exit 1
    fi
  fi
fi

if [ "$RUN_OK" = "0" ]; then
  echo "std-db-kv-arrow SKIP .sx run (no shux link or compile failed)" >&2
fi

echo "std-db-kv-arrow gate OK"
