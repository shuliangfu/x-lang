#!/usr/bin/env bash
# STD-006：std.crypto 最小安全集 manifest + runnable 门禁
#
# 用法：./tests/run-std-crypto-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CRYPTO_DOC:-analysis/std-crypto-min-v1.md}"
MANIFEST="${SHUX_STD_CRYPTO_MANIFEST:-tests/baseline/std-crypto-manifest.tsv}"
VECTORS="${SHUX_STD_CRYPTO_VECTORS:-tests/baseline/std-crypto-vectors.tsv}"
CRYPTO_MOD="${SHUX_STD_CRYPTO_MOD:-std/crypto/mod.sx}"
RAND_MOD="${SHUX_STD_RANDOM_MOD:-std/random/mod.sx}"
MIN_APIS=5
MIN_LAYERS=3

# shellcheck source=tests/lib/std-crypto.sh
. tests/lib/std-crypto.sh

echo "=== STD-006: std.crypto manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$CRYPTO_MOD" "$RAND_MOD" \
  std/crypto/core.sx compiler/src/asm/runtime_crypto_inc_glue.c std/random/random.sx compiler/src/asm/runtime_random_fill.c tests/lib/std-crypto.sh; do
  if [ ! -f "$f" ]; then
    echo "std-crypto gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report K1-hash K3-sig; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-crypto gate FAIL: doc missing '$kw'" >&2
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
echo "=== STD-006: manifest walk ==="
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      mod="$CRYPTO_MOD"
      if [ "$anchor" = "fill_bytes" ]; then
        mod="$RAND_MOD"
      fi
      if ! std_crypto_has_api "$mod" "$anchor"; then
        echo "std-crypto FAIL: missing API $anchor in $mod" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "std-crypto FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ "$kind" = "script" ] && [ -f "tests/lib/$anchor" ]; then
        path="tests/lib/$anchor"
      fi
      if [ ! -f "$path" ]; then
        echo "std-crypto FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-crypto FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-crypto FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-crypto gate FAIL: apis=${API_N} < min_apis=${MIN_APIS}" >&2
  exit 1
fi
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "std-crypto gate FAIL: layers=${LAYER_N} < min_layers=${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-crypto gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-crypto manifest OK (apis=${API_N} layers=${LAYER_N})"

if [ "${SHUX_STD_CRYPTO_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "std-crypto gate OK (manifest only)"
  exit 0
fi

SHUX_BIN=""
if SHUX_BIN="$(std_crypto_resolve_shu)"; then
  make -C compiler -q 2>/dev/null || make -C compiler
  echo "=== STD-006: runnable report (SHUX=$SHUX_BIN) ==="
  FAILS=0
  while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      smoke)
        echo "── $item_id ──"
        if std_crypto_run_smoke "$SHUX_BIN" "$anchor" "$item_id"; then
          echo "std-crypto OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
      hook_script)
        hook="tests/$anchor"
        echo "── $item_id ──"
        if std_crypto_run_hook "$SHUX_BIN" "$hook"; then
          echo "std-crypto OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"
  if [ "$FAILS" -gt 0 ]; then
    echo "std-crypto gate FAIL: ${FAILS} runnable(s)" >&2
    exit 1
  fi
  echo "std-crypto gate OK"
else
  echo "std-crypto gate SKIP bench (no native shux)" >&2
  echo "std-crypto gate OK"
fi
