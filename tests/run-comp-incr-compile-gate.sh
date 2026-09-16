#!/usr/bin/env bash
# COMP-007: incremental compile strategy manifest gate (false-authority honesty).
#
# Honesty: soft SKIP→OK / prefer-c in run-comp-incr-compile.sh retired
# (2026-08-27). Prefer product xlang_asm via child; DOC→archive with ## Gate;
# refuse top-level DOC resurrect. Check benches = obs; ratio over-cap = obs
# (FAIL=1 still hard). Report inherits child run=/obs=/skip=.
#
# Usage: ./tests/run-comp-incr-compile-gate.sh
# wave honesty (2026-08-24 #7): DOC under analysis/archive/;
# monofile / lsp_diag.c retired — C2=lsp_diag.h, C4=labi_path_pure
# (xlang_rel_o_path_from_argv0); OBS DOC=analysis/archive/obs/.
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_COMP_INCR_COMPILE_DOC:-analysis/archive/comp/comp-incr-compile-v1.md}"
MANIFEST="${XLANG_COMP_INCR_COMPILE_MANIFEST:-tests/baseline/comp-incr-compile.tsv}"
PROTOS="${XLANG_INCR_COMPILE_PROTOS:-tests/baseline/comp-incr-compile-prototype.tsv}"
BENCH="${XLANG_INCR_COMPILE_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
OBS_DOC="${XLANG_OBS_PHASE_TIMING_DOC:-analysis/archive/obs/obs-compile-phase-timing-v1.md}"
LSP_SRC="${XLANG_COMP_INCR_LSP_SRC:-compiler/src/lsp/lsp_diag.h}"
PRELINK_SRC="${XLANG_COMP_INCR_PRELINK_SRC:-compiler/seeds/labi_path_pure.from_x.c}"
MIN_LAYERS=6
MIN_PROTOS=6
MIN_BENCHES=4
PREFIX="xlang: [XLANG_COMP_INCR_COMPILE]"

die() {
  echo "comp-incr-compile gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/comp-incr-compile-v1.md ]; then
  die "refuse top-level analysis/comp-incr-compile-v1.md (use archive/comp)"
fi

# shellcheck source=tests/lib/comp-incr-compile.sh
. tests/lib/comp-incr-compile.sh

echo "=== COMP-007: incremental compile manifest (monofile/lsp.c retired) ==="

# wave321 / E-02: refuse resurrect of retired authorities.
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (std prelink live = labi_path_pure)"
fi
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "lsp_diag.c resurrected (live = lsp_diag.h / lsp_diag.x)"
fi

for f in "$DOC" "$MANIFEST" "$PROTOS" "$BENCH" \
  tests/lib/comp-incr-compile.sh tests/run-comp-incr-compile.sh \
  "$OBS_DOC" tests/run-obs-compile-phase-timing-gate.sh \
  compiler/src/pipeline/pipeline.x "$LSP_SRC" "$PRELINK_SRC"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done

if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

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
  die "layers=${LAYER_N} < min ${MIN_LAYERS}"
fi
if [ "$PROTO_N" -lt "$MIN_PROTOS" ]; then
  die "protos=${PROTO_N} < min ${MIN_PROTOS}"
fi
if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  die "benches=${BENCH_N} < min ${MIN_BENCHES}"
fi

for kw in incremental compile cache second report runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done

if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "comp-incr-compile manifest OK (layers=${LAYER_N} protos=${PROTO_N} benches=${BENCH_N})"

if [ "${XLANG_COMP_INCR_COMPILE_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "comp-incr-compile gate OK (manifest only)"
  exit 0
fi

chmod +x tests/run-comp-incr-compile.sh
./tests/run-comp-incr-compile.sh

echo "comp-incr-compile gate OK"
