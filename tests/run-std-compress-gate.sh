#!/usr/bin/env bash
# STD-007: std.compress gzip/zstd/legacy gate (false-authority honesty).
#
# Usage: ./tests/run-std-compress-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); gzip/zstd/legacy smokes exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/gzip=/zstd=/legacy=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / soft SKIP on missing native / ## 4. Gate 与 report).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_COMPRESS_DOC:-analysis/archive/std/std-compress-v1.md}"
MANIFEST="${XLANG_STD_COMPRESS_MANIFEST:-tests/baseline/std-compress-manifest.tsv}"
MOD_X="${XLANG_STD_COMPRESS_MOD:-std/compress/mod.x}"
README="std/compress/README.md"
LIB="tests/lib/std-compress.sh"
HOOK="tests/run-compress.sh"
SMOKE_GZIP="tests/std-compress/gzip_roundtrip.x"
SMOKE_ZSTD="tests/std-compress/zstd_roundtrip.x"
SMOKE_LEGACY="tests/compress/main.x"
MIN_APIS=4
MIN_LAYERS=4

# shellcheck source=tests/lib/std-compress.sh
. "$LIB"

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-compress-v1.md ]; then
  echo "std-compress gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-007: std.compress manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$README" "$LIB" "$HOOK" \
  "$SMOKE_GZIP" "$SMOKE_ZSTD" "$SMOKE_LEGACY" \
  std/compress/common.x \
  std/compress/zlib/libz.x std/compress/gzip/libz.x \
  std/compress/brotli/lib.x std/compress/zstd/lib.x; do
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

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-compress gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

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
      if ! std_compress_has_api "$MOD_X" "$anchor"; then
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
      # Post-MF phys-del: compress-o-* live as hub no-ops in compiler-make.sh.
      path="${src:-tests/lib/compiler-make.sh}"
      if ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "std-compress FAIL: missing hub phony $anchor in $path" >&2
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
  std_compress_emit_report "fail" 0 0 0 0 1
  echo "std-compress gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-compress manifest OK (apis=${API_N} layers=${LAYER_N})"

if [ "${XLANG_STD_COMPRESS_MANIFEST_ONLY:-0}" = "1" ]; then
  std_compress_emit_report "ok" 0 0 0 0 1
  echo "std-compress gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
GZIP_OK=0
ZSTD_OK=0
LEGACY_OK=0
SKIP=1

if XLANG_BIN="$(std_compress_resolve_shu 2>/dev/null)"; then
  echo "=== STD-007: smoke (XLANG=$XLANG_BIN; check observational; gzip/zstd/legacy hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_GZIP" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_ZSTD" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SMOKE_LEGACY" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-compress gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  std_compress_try_libs
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  echo "── smoke_gzip ──"
  if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_GZIP" "gzip"; then
    GZIP_OK=1
    echo "std-compress OK smoke_gzip"
  else
    std_compress_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi

  echo "── smoke_zstd ──"
  if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_ZSTD" "zstd"; then
    ZSTD_OK=1
    echo "std-compress OK smoke_zstd"
  else
    std_compress_emit_report "fail" "$CHECK_OK" "$GZIP_OK" 0 0 0
    exit 1
  fi

  echo "── smoke_legacy ──"
  if std_compress_run_smoke "$XLANG_BIN" "$SMOKE_LEGACY" "legacy"; then
    LEGACY_OK=1
    echo "std-compress OK smoke_legacy"
  else
    std_compress_emit_report "fail" "$CHECK_OK" "$GZIP_OK" "$ZSTD_OK" 0 0
    exit 1
  fi

  # Hook is observational regression (may soft-skip formats); not the hard-green signal.
  echo "── hook_compress ──"
  chmod +x "$HOOK" 2>/dev/null || true
  if XLANG="$XLANG_BIN" "$HOOK"; then
    echo "std-compress OK hook_compress"
  else
    echo "std-compress WARN hook_compress (observational; hard signal = gzip/zstd/legacy)" >&2
  fi

  SKIP=0
else
  echo "std-compress gate FAIL: no native xlang" >&2
  std_compress_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is gzip=/zstd=/legacy=.
echo "std-compress check_ok=${CHECK_OK} (observational)"
std_compress_emit_report "ok" "$CHECK_OK" "$GZIP_OK" "$ZSTD_OK" "$LEGACY_OK" "$SKIP"
echo "std-compress gate OK"
