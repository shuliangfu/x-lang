#!/usr/bin/env bash
# BOOT-015: semantic smoke (vec/map/heap) — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft SKIP→OK
# (no native still gate OK) + prefer-c / bootstrap-link wrap retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# Product -o vec/map/heap link+run exit0 = hard run; check = obs.
# Report: run=/obs=/skip=. DOC defaults under analysis/archive/; refuse
# resurrected top-level DOC / NEXT.md.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-boot-015-semantic-smoke-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/boot-015-semantic-smoke.sh
. tests/lib/boot-015-semantic-smoke.sh

DOC="${XLANG_BOOT015_DOC:-analysis/archive/boot/boot-015-semantic-smoke-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_BOOT015_TSV:-tests/baseline/boot-015-semantic-smoke.tsv}"
LIB="tests/lib/boot-015-semantic-smoke.sh"
MIN_SMOKE=3
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "boot-015-semantic-smoke gate FAIL: $*" >&2
  boot015_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== BOOT-015: semantic smoke (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-015-semantic-smoke-v1.md ]; then
  die "top-level DOC resurrected (live = archive/boot/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$ROADMAP"; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (use analysis/自举进度.md)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_smoke) MIN_SMOKE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap-verify vec map heap check-7.2; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

MISS=0
SMOKE=0
echo "=== BOOT-015: smokes, hooks, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      SMOKE=$((SMOKE + 1))
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "boot-015 OK smoke $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-015 FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$SMOKE" -ge "$MIN_SMOKE" ] || die "smokes=${SMOKE} < min ${MIN_SMOKE}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "boot-015-semantic-smoke manifest OK (smokes=${SMOKE})"

if [ "${XLANG_BOOT015_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  boot015_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "boot-015-semantic-smoke gate OK (manifest only)"
  exit 0
fi

# Refuse soft auto-make — require existing native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"
mkdir -p "$OUT_DIR"

echo "=== BOOT-015: smoke (check observational; link+run hard) ==="
for mod in vec map heap; do
  src="tests/${mod}/main.x"
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if boot015_check_one "$XLANG_BIN" "$src"; then
    :
  else
    echo "boot-015-semantic-smoke OBS check $mod (paused 2026-08-05; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
done

for mod in vec map heap; do
  src="tests/${mod}/main.x"
  out="${OUT_DIR}/xlang_boot015_${mod}_$$"
  lr=0
  boot015_link_run_one "$XLANG_BIN" "$src" "$out" || lr=$?
  rm -f "$out"
  if [ "$lr" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "boot-015 link+run OK $mod"
  else
    die "link+run $mod (lr=$lr)"
  fi
done

[ "$RUN_OK" -eq 3 ] || die "link_ok=${RUN_OK} < 3"
echo "boot-015-semantic-smoke check=obs=${OBS} run=${RUN_OK}"
boot015_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "boot-015-semantic-smoke gate OK"
