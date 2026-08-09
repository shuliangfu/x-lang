#!/usr/bin/env bash
# product_l4_true_cold.sh — G.7 single authority for L4 true-cold product gate
#
# Why this exists (root fix, wave341):
#   Skill / 自举验证.md §7 documented multi-line L4 recipes that agents and
#   humans re-typed with drift (make vs shell, partial .o wipe, set -e matrix
#   abort on rv=42, bstrict re-bootstrap covering cold binaries). Daily L2
#   already has one entry (`./xbuild l2-matrix` → product_l2_matrix.sh).
#   L4 must have the same single product entry so dual-end cold is one command.
#
# Contract (AGENTS.md + skill §3.1 · 构建级别=L4):
#   1) Wipe ALL *.o under compiler/ std/ core/ (no selective delete)
#   2) Delete product binaries that must be this-wave rebuilds
#   3) remaining_o must be 0 before rebuild
#   4) Pin linux.x86_64 seed gens into host-local *_gen.c (typeck_gen is
#      gitignored and otherwise survives .o wipe with stale void-main)
#   5) bootstrap-driver-seed (shell; Makefile deleted wave941)
#   6) g05_prepare_and_relink --sync → this-wave xlang_asm
#   7) product L2 matrix (product_l2_matrix.sh — never ad-hoc set -e /tmp/rv)
#   8) full bstrict with XLANG_BSTRICT_SKIP_BUILD=1 (do not re-bootstrap)
#   Does NOT run `xlang check` (self-host pause 2026-08-05)
#
# Authority (G.7):
#   Prefer:
#     ./xbuild l4
#     ./xbuild l4-cold
#     bash compiler/scripts/product_l4_true_cold.sh
#   Do NOT reimplement multi-line L4 wipe/rebuild/matrix in chat or docs as a
#   second body. Update this script when the L4 recipe changes.
#   Related (not a second L4 product entry):
#     XLANG_L4_COLD=1 tests/run-all-bstrict.sh  — bstrict-internal purge path;
#     product L4 still goes through this script so matrix + seed pin stay one.
#
# Usage (repo root):
#   ./xbuild l4
#   bash compiler/scripts/product_l4_true_cold.sh
#   bash compiler/scripts/product_l4_true_cold.sh --no-bstrict   # rebuild+matrix only
#   bash compiler/scripts/product_l4_true_cold.sh --rebuild-only # purge+seed+g05 only
#   bash compiler/scripts/product_l4_true_cold.sh --help
#
# Env:
#   XLANG_L4_LOG       log path (default: /tmp/xlang_l4_<host>_<sha>.log)
#   XLANG_L4_NO_BSTRICT=1  same as --no-bstrict
#   XLANG_L4_REBUILD_ONLY=1 same as --rebuild-only
#   XLANG_BSTRICT_SCRIPT_TIMEOUT  forwarded to run-all-bstrict (default there)
#
# PLATFORM: SHARED — same recipe on macOS + Ubuntu; Ubuntu is link-integrity gold.
# Wave: 341 — L4 single entry next to L2 matrix.

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"
cd "$ROOT"

MODE="full" # full | no-bstrict | rebuild-only
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-bstrict|no-bstrict)
      MODE="no-bstrict"
      shift
      ;;
    --rebuild-only|rebuild-only)
      MODE="rebuild-only"
      shift
      ;;
    --full|full)
      MODE="full"
      shift
      ;;
    -h|--help|help)
      sed -n '2,60p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "product_l4_true_cold: unknown arg: $1 (use --help)" >&2
      exit 2
      ;;
  esac
done

if [ -n "${XLANG_L4_REBUILD_ONLY:-}" ]; then
  MODE="rebuild-only"
elif [ -n "${XLANG_L4_NO_BSTRICT:-}" ] && [ "$MODE" = "full" ]; then
  MODE="no-bstrict"
fi

SHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
HOST_OS="$(uname -s 2>/dev/null || echo unknown)"
HOST_ARCH="$(uname -m 2>/dev/null || echo unknown)"
HOST="${HOST_OS}-${HOST_ARCH}"
LOG="${XLANG_L4_LOG:-/tmp/xlang_l4_${HOST_OS}_${SHA}.log}"
WALL_START="$(date +%s)"

log() { echo "product_l4: $*" | tee -a "$LOG"; }
fail() {
  echo "product_l4 FAIL: $*" | tee -a "$LOG" >&2
  exit 1
}

# Fresh log header
{
  echo "=== product L4 true cold ==="
  echo "SHA=$SHA host=$HOST mode=$MODE"
  echo "started=$(date '+%Y-%m-%d %H:%M:%S')"
  echo "ROOT=$ROOT"
  echo "LOG=$LOG"
  echo "NOTE: does NOT run xlang check (self-host pause)."
  echo
} >"$LOG"

log "mode=$MODE SHA=$SHA host=$HOST"
log "log file: $LOG"

# --- 1) Full wipe .o ---
log "step1: wipe ALL .o under compiler/ std/ core/"
find compiler std core -name '*.o' -type f -delete 2>/dev/null || true

# --- 2) Wipe product binaries (must be this-wave) ---
log "step2: wipe product binaries (xlang / xlang_asm / xlang-c / bootstrap…)"
rm -f \
  compiler/xlang \
  compiler/xlang_asm \
  compiler/xlang_asm2 \
  compiler/xlang-c \
  compiler/bootstrap_xlangc \
  compiler/xlang-x \
  compiler/xlang-seed-phase1 \
  compiler/xlang-no-c-frontend \
  compiler/bootstrap_xlang \
  2>/dev/null || true

# --- 3) remaining_o must be 0 ---
REMAINING_O="$(find compiler std core -name '*.o' -type f 2>/dev/null | wc -l | tr -d ' ')"
if [ "$REMAINING_O" != "0" ]; then
  fail "remaining_o=$REMAINING_O after wipe (expected 0)"
fi
if [ -e compiler/xlang_asm ]; then
  fail "compiler/xlang_asm still exists after wipe"
fi
log "step3: remaining_o=0 OK (xlang_asm absent)"

# --- 4) Pin product seed gens (Linux gold source; mac develops same pin) ---
# PLATFORM: SHARED pin semantic; host-local typeck_gen.c is gitignored and
# survives .o wipe → must re-pin or void-main stale seed rejects cold.
log "step4: pin seeds/*_gen.linux.x86_64.c → compiler/*_gen.c"
(
  cd compiler
  cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c
  cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c
  cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c
) || fail "seed pin copy failed"
log "step4: seed pin OK"

# --- 5) Cold bootstrap-driver-seed (shell; no Makefile) ---
log "step5: bootstrap-driver-seed (shell)"
(
  cd compiler
  bash scripts/bootstrap_driver_seed.sh
) 2>&1 | tee -a "$LOG"
if [ ! -x compiler/xlang ] && [ ! -x compiler/bootstrap_xlangc ]; then
  fail "bootstrap-driver-seed produced neither xlang nor bootstrap_xlangc"
fi
log "step5: bootstrap-driver-seed OK"

# --- 6) g05 product relink + sync xlang_asm ---
log "step6: g05_prepare_and_relink --sync"
(
  cd compiler
  # FULL=0 is historic skill env; prepare script uses --sync default.
  FULL="${FULL:-0}" bash scripts/g05_prepare_and_relink.sh --sync
) 2>&1 | tee -a "$LOG"
if [ ! -x compiler/xlang_asm ]; then
  fail "xlang_asm missing after g05_prepare_and_relink"
fi
if [ ! -x compiler/xlang ]; then
  fail "xlang missing after g05_prepare_and_relink"
fi
# Prefer absolute XLANG for clear logs
XLANG_ABS="$(CDPATH= cd -- "$ROOT/compiler" && pwd)/xlang_asm"
export XLANG="$XLANG_ABS"
XLANG_MTIME="$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$XLANG" 2>/dev/null \
  || stat -c '%y' "$XLANG" 2>/dev/null | cut -c1-16 \
  || echo unknown)"
log "step6: XLANG=$XLANG mtime=$XLANG_MTIME"

if [ "$MODE" = "rebuild-only" ]; then
  WALL_END="$(date +%s)"
  ELAPSED=$((WALL_END - WALL_START))
  log "mode=rebuild-only → skip matrix + bstrict"
  log "product_l4_true_cold REBUILD_ONLY OK SHA=$SHA remaining_o0 XLANG=$XLANG (${ELAPSED}s)"
  echo "product_l4_true_cold REBUILD_ONLY OK SHA=$SHA host=$HOST XLANG=$XLANG log=$LOG"
  exit 0
fi

# --- 7) Product L2 matrix (G.7 body — never ad-hoc set -e chain) ---
log "step7: product L2 matrix (./xbuild l2-matrix body)"
set +e
bash compiler/scripts/product_l2_matrix.sh --xlang "$XLANG" 2>&1 | tee -a "$LOG"
MATRIX_RC=$?
set -e
if [ "$MATRIX_RC" -ne 0 ]; then
  fail "product L2 matrix failed (rc=$MATRIX_RC); see $LOG"
fi
log "step7: product L2 matrix OK"

if [ "$MODE" = "no-bstrict" ]; then
  WALL_END="$(date +%s)"
  ELAPSED=$((WALL_END - WALL_START))
  log "mode=no-bstrict → skip full bstrict"
  log "product_l4_true_cold MATRIX_OK SHA=$SHA (${ELAPSED}s) log=$LOG"
  echo "product_l4_true_cold MATRIX_OK SHA=$SHA host=$HOST XLANG=$XLANG log=$LOG"
  exit 0
fi

# --- 8) Full bstrict; do not re-bootstrap over this-wave xlang_asm ---
log "step8: run-all-bstrict (XLANG_BSTRICT_SKIP_BUILD=1)"
set +e
XLANG_BSTRICT_SKIP_BUILD=1 \
  XLANG="$XLANG" \
  bash tests/run-all-bstrict.sh 2>&1 | tee -a "$LOG"
BSTRICT_RC=$?
set -e
if [ "$BSTRICT_RC" -ne 0 ]; then
  fail "run-all-bstrict failed (rc=$BSTRICT_RC); see $LOG"
fi

WALL_END="$(date +%s)"
ELAPSED=$((WALL_END - WALL_START))
_min=$((ELAPSED / 60))
_sec=$((ELAPSED % 60))
log "step8: run-all-bstrict OK"
log "product_l4_true_cold OK SHA=$SHA host=$HOST mode=full wall=${_min}m${_sec}s log=$LOG"
echo "product_l4_true_cold OK SHA=$SHA host=$HOST XLANG=$XLANG wall=${_min}m${_sec}s log=$LOG"
exit 0
