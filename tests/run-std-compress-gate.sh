#!/usr/bin/env bash
# STD-007：std.compress gzip/zstd manifest + runnable 门禁
#
# 用法：./tests/run-std-compress-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_COMPRESS_DOC:-analysis/std-compress-v1.md}"
MANIFEST="${SHUX_STD_COMPRESS_MANIFEST:-tests/baseline/std-compress-manifest.tsv}"
MOD_SU="${SHUX_STD_COMPRESS_MOD:-std/compress/mod.sx}"
MIN_APIS=4
MIN_LAYERS=4

# shellcheck source=tests/lib/std-compress.sh
. tests/lib/std-compress.sh

echo "=== STD-007: std.compress manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_SU" std/compress/compress_common.h \
  std/compress/zlib/zlib.c std/compress/gzip/gzip.c std/compress/brotli/brotli.c \
  tests/lib/std-compress.sh; do
  if [ ! -f "$f" ]; then
    echo "std-compress gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report M1-gzip M2-zstd; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-compress gate FAIL: doc missing '$kw'" >&2
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
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-compress FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-compress FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_compress_has_api "$MOD_SU" "$anchor"; then
        echo "std-compress FAIL: missing API $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-compress FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "std-compress FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    target)
      path="${src:-compiler/Makefile}"
      if ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "std-compress FAIL: missing make target $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ "$kind" = "script" ] && [ -f "tests/lib/$anchor" ]; then
        path="tests/lib/$anchor"
      fi
      if [ ! -f "$path" ]; then
        echo "std-compress FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-compress FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-compress FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-compress gate FAIL: apis=${API_N} < min_apis=${MIN_APIS}" >&2
  exit 1
fi
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "std-compress gate FAIL: layers=${LAYER_N} < min_layers=${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-compress gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-compress manifest OK (apis=${API_N} layers=${LAYER_N})"

if SHUX_BIN="$(std_compress_resolve_shu)"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  std_compress_try_libs
  echo "=== STD-007: runnable report (SHUX=$SHUX_BIN) ==="
  FAILS=0
  GZIP_R="skip"
  ZSTD_R="skip"
  while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      smoke)
        echo "── $item_id ──"
        if std_compress_run_smoke "$SHUX_BIN" "$anchor" "$item_id"; then
          echo "std-compress OK $item_id"
          case "$item_id" in
            smoke_gzip) GZIP_R="ok" ;;
            smoke_zstd) ZSTD_R="ok" ;;
          esac
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
      hook_script)
        hook="tests/$anchor"
        echo "── $item_id ──"
        chmod +x "$hook" 2>/dev/null || true
        if SHUX="$SHUX_BIN" "$hook"; then
          echo "std-compress OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"
  if [ "$FAILS" -gt 0 ]; then
    echo "std-compress gate FAIL: ${FAILS} runnable(s)" >&2
    exit 1
  fi
  echo "std-compress gate report gzip=${GZIP_R} zstd=${ZSTD_R}"
  echo "std-compress gate OK"
else
  echo "std-compress gate SKIP bench (no native shux)" >&2
  echo "std-compress gate OK"
fi
