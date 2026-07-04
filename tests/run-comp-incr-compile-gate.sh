#!/usr/bin/env bash
# COMP-007：增量编译策略 manifest 门禁
#
# 用法：./tests/run-comp-incr-compile-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_INCR_COMPILE_DOC:-analysis/comp-incr-compile-v1.md}"
MANIFEST="${SHUX_COMP_INCR_COMPILE_MANIFEST:-tests/baseline/comp-incr-compile.tsv}"
PROTOS="${SHUX_INCR_COMPILE_PROTOS:-tests/baseline/comp-incr-compile-prototype.tsv}"
BENCH="${SHUX_INCR_COMPILE_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
MIN_LAYERS=6
MIN_PROTOS=6
MIN_BENCHES=4

# shellcheck source=tests/lib/comp-incr-compile.sh
. tests/lib/comp-incr-compile.sh

echo "=== COMP-007: incremental compile manifest ==="
for f in "$DOC" "$MANIFEST" "$PROTOS" "$BENCH" \
  tests/lib/comp-incr-compile.sh tests/run-comp-incr-compile.sh \
  analysis/obs-compile-phase-timing-v1.md tests/run-obs-compile-phase-timing-gate.sh \
  compiler/src/pipeline/pipeline.x compiler/src/lsp/lsp_diag.c; do
  if [ ! -f "$f" ]; then
    echo "comp-incr-compile gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_protos) MIN_PROTOS="$c2" ;;
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
PROTO_N=0
BENCH_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    proto_ref)
      PROTO_N=$((PROTO_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing proto $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ -f "$src" ] && ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing proto src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-incr-compile FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-incr-compile FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-incr-compile FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r bench_id _fix _cmd _max _tgt _notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*|max_*|target_*) continue ;; esac
  BENCH_N=$((BENCH_N + 1))
  if ! grep -qF "$bench_id" "$DOC" 2>/dev/null; then
    echo "comp-incr-compile FAIL: doc missing bench $bench_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$BENCH"

while IFS=$'\t' read -r pid _cap status sym src _notes; do
  [ -z "${pid:-}" ] && continue
  case "$pid" in \#*|min_*) continue ;; esac
  if ! grep -qF "$pid" "$DOC" 2>/dev/null; then
    echo "comp-incr-compile FAIL: doc missing registry $pid" >&2
    MISS=$((MISS + 1))
  fi
  if [ "$status" = "done" ] && ! comp_incr_compile_proto_present "$src" "$sym"; then
    echo "comp-incr-compile FAIL: done proto $pid missing $sym" >&2
    MISS=$((MISS + 1))
  fi
done < "$PROTOS"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-incr-compile gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$PROTO_N" -lt "$MIN_PROTOS" ]; then
  echo "comp-incr-compile gate FAIL: protos=${PROTO_N} < min ${MIN_PROTOS}" >&2
  exit 1
fi
if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "comp-incr-compile gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi

for kw in incremental compile cache second report runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-incr-compile gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-incr-compile gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-incr-compile manifest OK (layers=${LAYER_N} protos=${PROTO_N} benches=${BENCH_N})"

if [ "${SHUX_COMP_INCR_COMPILE_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "comp-incr-compile gate OK (manifest only)"
  exit 0
fi

chmod +x tests/run-comp-incr-compile.sh
./tests/run-comp-incr-compile.sh

echo "comp-incr-compile gate OK"
