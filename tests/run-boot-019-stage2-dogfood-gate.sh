#!/usr/bin/env bash
# BOOT-019: Stage2 parser/typeck dogfood — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft SKIP→OK
# (no native still gate OK) + soft bootstrap-link wrap + prefer-c retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# Subset runner: 6 smoke link+run hard; check = obs.
# Report: run=/obs=/skip=. DOC defaults under analysis/archive/; refuse
# resurrected top-level DOC / NEXT.md.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-boot-019-stage2-dogfood-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. tests/lib/boot-019-stage2-dogfood.sh

DOC="${XLANG_BOOT019_DOC:-analysis/archive/boot/boot-019-stage2-dogfood-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_BOOT019_TSV:-tests/baseline/boot-019-stage2-dogfood.tsv}"
RUNNER="tests/run-bootstrap-stage2-dogfood-parser-typeck.sh"
LIB="tests/lib/boot-019-stage2-dogfood.sh"
MIN_SMOKE=6
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "boot-019-stage2-dogfood gate FAIL: $*" >&2
  boot019_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== BOOT-019: Stage2 dogfood (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-019-stage2-dogfood-v1.md ]; then
  die "top-level DOC resurrected (live = archive/boot/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" "$ROADMAP"; do
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

for kw in bootstrap-verify parser typeck check-7.2 Stage2; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

MISS=0
SMOKE=0
echo "=== BOOT-019: smokes, hooks, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      SMOKE=$((SMOKE + 1))
      if [ ! -f "$anchor" ]; then
        echo "boot-019 FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "boot-019 OK smoke $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-019 FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "boot-019 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      else
        :
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "boot-019 FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$SMOKE" -ge "$MIN_SMOKE" ] || die "smokes=${SMOKE} < min ${MIN_SMOKE}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "boot-019-stage2-dogfood manifest OK (smokes=${SMOKE})"

if [ "${XLANG_BOOT019_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  boot019_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "boot-019-stage2-dogfood gate OK (manifest only)"
  exit 0
fi

# Refuse soft auto-make — require existing native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"
mkdir -p "$OUT_DIR"

echo "=== BOOT-019: bootstrap subset runner (check observational; link+run hard) ==="
chmod +x "$RUNNER"
set +e
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" BOOT019_SKIP_LINK= \
  "$RUNNER" >/tmp/boot019_subset.log 2>&1
runner_ec=$?
set -e
if [ "$runner_ec" -ne 0 ]; then
  tail -20 /tmp/boot019_subset.log >&2 || true
  die "subset runner exit=$runner_ec"
fi
grep -q 'bootstrap-stage2-dogfood parser/typeck OK' /tmp/boot019_subset.log \
  || die "subset runner missing OK banner"

# Observational check count (may be 0 on Darwin while check gate paused).
CHK_OK=$(grep -c 'bootstrap-stage2-dogfood check OK' /tmp/boot019_subset.log || true)
CHK_OBS=$(grep -c 'bootstrap-stage2-dogfood OBS check\|bootstrap-stage2-dogfood SKIP check' /tmp/boot019_subset.log || true)
LINK_OK=$(grep -c 'bootstrap-stage2-dogfood link+run OK' /tmp/boot019_subset.log || true)
[ "$LINK_OK" -ge 6 ] || {
  tail -20 /tmp/boot019_subset.log >&2 || true
  die "link_ok=${LINK_OK} < 6"
}
RUN_OK=$LINK_OK
# check residual = obs (paused); refuse soft SKIP→OK narrative.
if [ "$CHK_OBS" -gt 0 ] || [ "$CHK_OK" -lt 6 ]; then
  # Any check miss / OBS line counts as observational residual.
  OBS=$((OBS + 1))
  echo "boot-019-stage2-dogfood OBS check (paused; check_ok=${CHK_OK} check_obs_lines=${CHK_OBS}; refuse soft SKIP→OK)" >&2
fi

echo "boot-019-stage2-dogfood check=obs=${OBS} run=${RUN_OK}"
boot019_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "boot-019-stage2-dogfood gate OK"
