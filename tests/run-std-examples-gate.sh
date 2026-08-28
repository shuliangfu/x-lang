#!/usr/bin/env bash
# STD-012: std examples manifest + runnable gate — honesty leftover wrap →硬绿.
#
# Honesty: leftover bootstrap-link wrap + lib RUN_XLANG remap in
# std_ex_run_x_smoke retired (product path is `"$xlang" -L . -o`).
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse leftover wrap / RUN_XLANG remap /
# soft SKIP→OK / soft auto-make / prefer-c). Product hello.x +
# io_batch_rw.x -o exit0 = hard run (run=2). check = obs.
# Report: run=/obs=/skip=. G.7: complete existing run_smoke; drop unused
# compiler-make.sh. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-examples-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_EXAMPLES_DOC:-analysis/archive/std/std-examples-v1.md}"
MANIFEST="${XLANG_STD_EXAMPLES_MANIFEST:-tests/baseline/std-examples-manifest.tsv}"
CATALOG="${XLANG_STD_EXAMPLES_CATALOG:-tests/baseline/std-examples-catalog.tsv}"
LIB="tests/lib/std-examples.sh"
SMOKE_HELLO="examples/hello.x"
SMOKE_IO="examples/cookbook/io_batch_rw.x"
MIN_EX=30

# shellcheck source=tests/lib/std-examples.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-examples gate FAIL: $*" >&2
  std_ex_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-012: std examples manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-examples-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$CATALOG" "$LIB" "$SMOKE_HELLO" "$SMOKE_IO"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_examples) MIN_EX="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
IDX=0
echo "=== STD-012: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    example_index)
      IDX=$((IDX + 1))
      if ! awk -F'\t' -v e="$anchor" '$1==e && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CATALOG"; then
        echo "std-examples FAIL: catalog missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing index $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

COUNT=$(std_ex_catalog_count "$CATALOG")
[ "$COUNT" -ge "$MIN_EX" ] || die "catalog count=${COUNT} < min ${MIN_EX}"
std_ex_validate_paths "$CATALOG" || die "catalog paths"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"

for kw in examples catalog cookbook runnable; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

echo "std-examples manifest OK (catalog=${COUNT} index=${IDX})"

if [ "${XLANG_STD_EXAMPLES_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_ex_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-examples gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-012: smoke (XLANG=$XLANG_BIN; check obs; hello+io product -o hard) ==="

if ! std_ex_check_example "$XLANG_BIN" "$SMOKE_HELLO"; then
  echo "std-examples OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap / RUN_XLANG remap (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_ex_run_x_smoke "$XLANG_BIN" "$SMOKE_HELLO" "/tmp/xlang_std_ex_hello_$$"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-examples OK: hello"
else
  die "hello.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_ex_run_x_smoke "$XLANG_BIN" "$SMOKE_IO" "/tmp/xlang_std_ex_io_$$"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-examples OK: io_batch"
else
  die "io_batch_rw.x exit!=0 (refuse soft SKIP→OK)"
fi

std_ex_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-examples gate OK"
