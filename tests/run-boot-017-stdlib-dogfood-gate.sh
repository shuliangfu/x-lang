#!/usr/bin/env bash
# BOOT-017: stdlib .x frontend check timing dogfood gate.
#
# Honesty: soft XLANG_BOOT017_FAIL_ON_REGRESSION / soft SKIP→OK retired.
# Manifest + baseline coverage are hard. Timing prefers xlang_asm; tip
# check/SLOW residuals are observational (selfhost check gate paused) —
# report run=/obs=/skip=, not soft-swallowed silence. Missing native
# compiler skips timing with skip=1 (honest N/A), still hard on manifest.
#
# Usage: ./tests/run-boot-017-stdlib-dogfood-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology.
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: no auto-make; missing native → skip timing (skip=1), hard on manifest.

DOC="${XLANG_BOOT017_DOC:-analysis/archive/boot/boot-017-stdlib-dogfood-v1.md}"
MANIFEST="${XLANG_BOOT017_MANIFEST:-tests/baseline/boot-017-stdlib-dogfood.tsv}"
MATRIX="${XLANG_BOOT017_MATRIX:-tests/baseline/stdlib-check-matrix.tsv}"
BASELINE="${XLANG_BOOT017_BASELINE:-tests/baseline/stdlib-dogfood.tsv}"
LIB="tests/lib/boot-017-stdlib-dogfood.sh"
RUNNER="tests/run-boot-017-stdlib-dogfood.sh"
MIN_MODULES=55
PREFIX="xlang: [XLANG_BOOT017_STDLIB_DOGFOOD]"
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/boot-017-stdlib-dogfood.sh
. tests/lib/boot-017-stdlib-dogfood.sh

die() {
  echo "boot-017-stdlib-dogfood gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
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

echo "=== BOOT-017: stdlib dogfood manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" "$MATRIX"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done

for kw in PERF-004 分模块 XLANG_BOOT017_STDLIB_DOGFOOD stdlib-dogfood; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_modules) MIN_MODULES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-017-stdlib-dogfood FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref|file)
      if [ ! -f "$mod_path" ]; then
        echo "boot-017-stdlib-dogfood FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-017-stdlib-dogfood FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$MISS" -eq 0 ] || die "missing=${MISS}"

# Baseline must cover every matrix module row (hard; refuse soft under-coverage).
BASE_N=0
MOD_N=0
while IFS=$'\t' read -r item_id kind anchor _layer _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|read_path|matrix|report) continue ;; esac
  [ "$kind" = "module" ] || continue
  MOD_N=$((MOD_N + 1))
  if [ -f "$BASELINE" ] && awk -F'\t' -v m="$anchor" '$1==m && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
    BASE_N=$((BASE_N + 1))
  fi
done < "$MATRIX"

[ "$MOD_N" -ge "$MIN_MODULES" ] || die "matrix modules=${MOD_N}"
[ -f "$BASELINE" ] || die "missing baseline $BASELINE"
[ "$BASE_N" -ge "$MOD_N" ] || die "baseline rows=${BASE_N} < modules=${MOD_N}"
echo "boot-017-stdlib-dogfood manifest OK (modules=${MOD_N}, baseline=${BASE_N})"

REG="${XLANG_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
awk -F'\t' '$1=="stdlib-dogfood" && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$REG" 2>/dev/null \
  || die "perf-baseline-registry missing stdlib-dogfood"

if XLANG_BIN="$(resolve_shu)"; then
  echo "=== BOOT-017: per-module timing (XLANG=$XLANG_BIN; hard/obs) ==="
  chmod +x "$RUNNER" "$LIB"
  # Prefer asm path; do not force xlang-c rebuild as the dogfood authority.
  set +e
  set -o pipefail
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./"$RUNNER" 2>&1 | tee /tmp/boot017_stdlib_dogfood.log
  rrc=${PIPESTATUS[0]}
  set +o pipefail
  set -e
  [ "$rrc" -eq 0 ] || die "runner rc=$rrc"
  grep -qF "$PREFIX" /tmp/boot017_stdlib_dogfood.log || die "missing report prefix"
  # Propagate runner obs=/run= into gate report (honest residual, not soft silence).
  if grep -qE 'obs=[1-9]' /tmp/boot017_stdlib_dogfood.log 2>/dev/null; then
    OBS=1
  fi
  if grep -qE 'run=[1-9]' /tmp/boot017_stdlib_dogfood.log 2>/dev/null; then
    RUN_OK=1
  fi
  SKIP=0
else
  # Honest skip of timing only; manifest already hard-green.
  SKIP=1
  echo "boot-017-stdlib-dogfood gate: skip timing (no native xlang; not soft false-green)" >&2
fi

ok_report
echo "boot-017-stdlib-dogfood gate OK"
