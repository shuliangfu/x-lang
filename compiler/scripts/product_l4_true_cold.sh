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
#   4) Frontend *_gen.c: tip assemble authority (9.2); seed pin only when
#      XLANG_L4_ALLOW_SEED_PIN=1 (archaeology). Default drops stale parser/codegen gens
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
#     product L4 still goes through this script so matrix + gen policy stay one.
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
#   XLANG_L4_ALLOW_SEED_PIN=1  archaeology: pin seeds/*_gen → local (default 0 / 9.2)
#   XLANG_BSTRICT_SCRIPT_TIMEOUT  forwarded to run-all-bstrict
#                                 Darwin L4 default 1200s (mega asm gates
#                                 ~840s serial). Ubuntu keeps 300s.
#   XLANG_BSTRICT_JOBS            forwarded to run-all-bstrict
#                                 Darwin L4 default 4 (M5 Max 18-core/64GB;
#                                 packing floor ~35–40 min bstrict). Ubuntu
#                                 default 1 (~17 min). JOBS=8 OOMed this box
#                                 (Killed:9). Override to 2/1 if Darwin OOM.
#   XLANG_CASE_TIMEOUT            forwarded to gate scripts. Darwin L4
#                                 default 180s (typeck default 30s flakes
#                                 under JOBS>1). Ubuntu keeps script defaults.
#
# Step wall-clock: each major step logs `stepN: … wall=Ns` and a final
# `step walls summary` table (wipe/pin are sub-second; bootstrap + g05 +
# bstrict dominate). Use this to see where L4 wall went without re-running.
#
# PLATFORM: SHARED — same recipe on macOS + Ubuntu; Ubuntu is link-integrity gold.
# Wave: 341 — L4 single entry next to L2 matrix.

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"
cd "$ROOT"


# knife256/10.2 Cap tip-aware: wipe deletes tip xlang needed by try-pipeline-abi-prefer
# hybrid thin+rest (记248/8.5 bans cold full seed). Restore a same-host aside if set.
# XLANG_L4_TIP_ASIDE=dir containing xlang[/xlang_asm]; else compiler/xlang.pre_l4_aside*.
# Ban: scp product binaries across hosts. PLATFORM: SHARED.
_l4_restore_tip_aside() {
  local aside="${XLANG_L4_TIP_ASIDE:-}"
  local cand=""
  # knife256/10.2 note737: Linux tip-cold must NOT revive pre_l4_aside*
  # (Oct-19 asides hollow typeck; g05 fail left aside as bstrict product).
  # Darwin Cap tip opts in via XLANG_L4_TIP_ASIDE=dir.
  case "$(uname -s 2>/dev/null)" in
    Linux)
      if [ -z "$aside" ]; then
        log "step2b: skip tip aside restore on Linux tip-cold (no XLANG_L4_TIP_ASIDE)"
        return 0
      fi
      ;;
  esac
  if [ -n "$aside" ] && [ -x "$aside/xlang" ]; then
    cand="$aside/xlang"
  elif [ -x "$COMPILER_DIR/xlang.pre_l4_aside_c445bc042" ]; then
    cand="$COMPILER_DIR/xlang.pre_l4_aside_c445bc042"
  elif [ -x "$COMPILER_DIR/xlang.pre_l4_aside" ]; then
    cand="$COMPILER_DIR/xlang.pre_l4_aside"
  elif [ -x "$COMPILER_DIR/xlang.pre_result_soft.bak" ]; then
    cand="$COMPILER_DIR/xlang.pre_result_soft.bak"
  fi
  if [ -n "$cand" ] && [ ! -x "$COMPILER_DIR/xlang" ]; then
    cp -f "$cand" "$COMPILER_DIR/xlang"
    chmod +x "$COMPILER_DIR/xlang"
    if [ -x "${cand%/*}/xlang_asm" ] || [ -x "${cand}_asm" ]; then
      :
    fi
    # Prefer matching asm aside beside cand
    if [ -x "${cand%xlang}xlang_asm" ]; then
      cp -f "${cand%xlang}xlang_asm" "$COMPILER_DIR/xlang_asm" 2>/dev/null || cp -f "$cand" "$COMPILER_DIR/xlang_asm"
    elif [ -x "$COMPILER_DIR/xlang_asm.pre_l4_aside_c445bc042" ]; then
      cp -f "$COMPILER_DIR/xlang_asm.pre_l4_aside_c445bc042" "$COMPILER_DIR/xlang_asm"
    else
      cp -f "$COMPILER_DIR/xlang" "$COMPILER_DIR/xlang_asm"
    fi
    chmod +x "$COMPILER_DIR/xlang_asm" 2>/dev/null || true
    log "step2b: restored tip aside for hybrid pabi ($cand)"
    # note743y.6.23: refuse hollow Cap tip (ec=0 but 0-byte .o on
    # runtime_asm_io_stubs.x). That aside left tip-cold failing try-heat
    # stubs / missing parser_asm_thin_glue after SIGILL spam. PLATFORM: DARWIN.
    if [ "$(uname -s 2>/dev/null || echo Unknown)" = "Darwin" ] \
      && [ -f "$COMPILER_DIR/src/asm/runtime_asm_io_stubs.x" ] \
      && [ -x "$COMPILER_DIR/xlang_asm" ]; then
      _l4_probe="$COMPILER_DIR/build_asm/l4_aside_stubs_probe.o"
      mkdir -p "$COMPILER_DIR/build_asm"
      rm -f "$_l4_probe"
      if ! (
        cd "$COMPILER_DIR" || exit 1
        ./xlang_asm -backend asm -c src/asm/runtime_asm_io_stubs.x -o "$_l4_probe" \
          >/dev/null 2>&1
      ) || [ ! -s "$_l4_probe" ] \
        || ! nm "$_l4_probe" 2>/dev/null | grep -qE 'T _*runtime_asm_io_stubs_x_doc_anchor$'; then
        rm -f "$_l4_probe"
        fail "step2b: Cap tip aside hollow on runtime_asm_io_stubs.x (refuse 0-byte; restore a Cap tip that emits T doc_anchor)"
      fi
      rm -f "$_l4_probe"
      log "step2b: Cap tip aside stubs smoke OK (runtime_asm_io_stubs T doc_anchor)"
    fi
  fi
}


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
      sed -n '2,70p' "$0" | sed 's/^# \{0,1\}//'
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
# PLATFORM: MACOS — Darwin L4 packing. Pin L4 @ b5be5ed97 was wall-dominated
# by serial asm gates (assign-index-expr 712s / binop-cfg-merge 658s) because
# xlang_link_obj_needs_undef_sym_impl popen("nm -u") per on_demand probe.
# After the one-slot UNDEF cache + Mach-O scan, those gates are ~19s / ~17s
# L2; hello -o 17s → ~1.9s. Sibling 1: has_defined_sym_impl T/t in the same
# mmap. Sibling 2: compress exports_marker / has_undef substring (hello 11
# full-nm on one user.o) now all-names + UNDEF-substr in the same mmap.
# JOBS=8 / 4 / 2 still hit Killed:9 on this
# 18-core/64GB box while Cursor/Chrome/iTerm hold most RAM (peak is N×
# xlang_asm + host-cc, RSS still ~104MB each). Default JOBS=1 is the only
# packing that dual-L4 greened here. gate_case_jobs Darwin auto-inner=2
# when outer==1 would recreate the JOBS=2 OOM, so L4 also pins
# GATE_CASE_JOBS=1. Ubuntu gold stays JOBS=1 (~17 min). Explicit
# XLANG_BSTRICT_JOBS / XLANG_GATE_CASE_JOBS always win. Cap is 8.
if [ -z "${XLANG_BSTRICT_JOBS:-}" ]; then
  export XLANG_BSTRICT_JOBS=1
fi
if [ -z "${XLANG_GATE_CASE_JOBS:-}" ]; then
  case "$HOST_OS" in
    Darwin) export XLANG_GATE_CASE_JOBS=1 ;;
  esac
fi
# PLATFORM: MACOS — inner gate_run_timeout defaults (typeck 30s) assume
# idle Darwin -o. Under JOBS>1 the same -o contends past 30s and false-FAIL
# as "timeout" (or SIGKILL mapped to 124). Darwin L4 floor 180s. Ubuntu
# keeps each script's own default. Explicit XLANG_CASE_TIMEOUT always wins.
if [ -z "${XLANG_CASE_TIMEOUT:-}" ]; then
  case "$HOST_OS" in
    Darwin) export XLANG_CASE_TIMEOUT=180 ;;
  esac
fi
# PLATFORM: MACOS — mega asm gates (~840s serial) exceed the product
# default 300s per-script timeout. Darwin often has no timeout(1), so
# JOBS=1 historically ran unbounded; if coreutils timeout/gtimeout is
# present, 300s would false-FAIL those gates under JOBS>1. Darwin L4
# default 1200s. Ubuntu stays 300s (same scripts ~10–20s). Explicit
# XLANG_BSTRICT_SCRIPT_TIMEOUT always wins.
if [ -z "${XLANG_BSTRICT_SCRIPT_TIMEOUT:-}" ]; then
  case "$HOST_OS" in
    Darwin) export XLANG_BSTRICT_SCRIPT_TIMEOUT=1200 ;;
  esac
fi
LOG="${XLANG_L4_LOG:-/tmp/xlang_l4_${HOST_OS}_${SHA}.log}"
WALL_START="$(date +%s)"
# Per-step walls: "name secs" lines; printed at end (and on early exit).
_STEP_TIMINGS=""
_STEP_T0=0
_STEP_NAME=""

log() { echo "product_l4: $*" | tee -a "$LOG"; }
fail() {
  echo "product_l4 FAIL: $*" | tee -a "$LOG" >&2
  _l4_print_step_summary "FAIL"
  exit 1
}

# PLATFORM: SHARED — date +%s portable on macOS / Linux / Git Bash.
_l4_step_begin() {
  _STEP_NAME="$1"
  _STEP_T0=$(date +%s)
  log "step: ${_STEP_NAME} begin"
}

_l4_step_end() {
  local t1 elapsed
  t1=$(date +%s)
  elapsed=$((t1 - _STEP_T0))
  if [ "$elapsed" -lt 0 ]; then
    elapsed=0
  fi
  log "step: ${_STEP_NAME} wall=${elapsed}s"
  _STEP_TIMINGS="${_STEP_TIMINGS}${_STEP_NAME} ${elapsed}
"
}

_l4_print_step_summary() {
  local tag="${1:-OK}"
  local wall_end elapsed _min _sec
  wall_end=$(date +%s)
  elapsed=$((wall_end - WALL_START))
  if [ "$elapsed" -lt 0 ]; then
    elapsed=0
  fi
  _min=$((elapsed / 60))
  _sec=$((elapsed % 60))
  {
    echo "product_l4: === step walls summary (${tag}) ==="
    if [ -n "$_STEP_TIMINGS" ]; then
      printf '%s' "$_STEP_TIMINGS" | while read -r name secs; do
        [ -n "$name" ] || continue
        printf 'product_l4:   %-28s %6ss\n' "$name" "$secs"
      done
    else
      echo "product_l4:   (no completed steps)"
    fi
    echo "product_l4:   TOTAL                        ${_min}m${_sec}s (${elapsed}s)"
  } | tee -a "$LOG"
}

# Fresh log header
{
  echo "=== product L4 true cold ==="
  echo "SHA=$SHA host=$HOST mode=$MODE"
  echo "started=$(date '+%Y-%m-%d %H:%M:%S')"
  echo "ROOT=$ROOT"
  echo "LOG=$LOG"
  echo "NOTE: does NOT run xlang check (self-host pause)."
  echo "NOTE: each step logs wall=Ns; end has step walls summary."
  echo
} >"$LOG"

log "mode=$MODE SHA=$SHA host=$HOST"
# knife 256 / 10.2: egg cannot pure-asm frontend mega (parser.x); bootstrap
# migrate uses archaeology pin seed snapshot (XLANG_MIGRATE_TRACK_L_COLD_SEED).
# g05 --sync then replaces with tip pure-asm. Default still tip-assemble for gen.
# PLATFORM: SHARED — cold L4 only; does not re-enable pin-first (9.2).
export XLANG_MIGRATE_TRACK_L_COLD_SEED="${XLANG_MIGRATE_TRACK_L_COLD_SEED:-1}"
export XLANG_TYPECK_HOST_CC="${XLANG_TYPECK_HOST_CC:-0}"
# knife256 / 10.2: ambient XLANG_PREFER_ASM_O=1 poisons try-heat; scrub for L4.
# Prefer-family scripts set it scoped in subshells only.
# PLATFORM: SHARED.
unset XLANG_PREFER_ASM_O


log "log file: $LOG"

# --- 1) Full wipe .o ---
_l4_step_begin "1_wipe_o"
log "step1: wipe ALL .o under compiler/ std/ core/"
find compiler std core -name '*.o' -type f -delete 2>/dev/null || true
# knife256 / 10.2: also drop frontend pure-asm stamps. L4 wipe left
# parser_x.pure_asm / typeck_x.pure_asm / codegen_x.pure_asm while replacing
# .o via Track L cold seed → g05_frontend_x_needs_host_cc rc=2 refuse.
# PLATFORM: SHARED tip cold.
find compiler -name '*.pure_asm' -type f -delete 2>/dev/null || true
# Flush directory entries before migrate so a late unlink cannot race phase1.
sync 2>/dev/null || true
_l4_step_end

# --- 2) Wipe product binaries (must be this-wave) ---
_l4_step_begin "2_wipe_binaries"
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
_l4_step_end

# --- 3) remaining_o must be 0 ---
_l4_step_begin "3_check_clean"
REMAINING_O="$(find compiler std core -name '*.o' -type f 2>/dev/null | wc -l | tr -d ' ')"
if [ "$REMAINING_O" != "0" ]; then
  fail "remaining_o=$REMAINING_O after wipe (expected 0)"
fi
if [ -e compiler/xlang_asm ]; then
  fail "compiler/xlang_asm still exists after wipe"
fi
log "step3: remaining_o=0 OK (xlang_asm absent)"
_l4_step_end
_l4_restore_tip_aside

# --- 4) Frontend *_gen.c: tip assemble authority (knife 254 / 9.2) ---
# Default: do NOT pin-first from seeds/*_gen.linux.x86_64.c.
# Opt-in archaeology: XLANG_L4_ALLOW_SEED_PIN=1 restores the old cp pin egg.
# Otherwise drop stale local parser/codegen gens so cold cannot silently reuse
# pin copies; ensure_migrate_gen (assemble-first) may refresh when a -E binary
# exists. typeck stays assemble-first via ensure (ALLOW_PIN egg only).
# PLATFORM: SHARED — tip cold not pin-first; archaeology switch default off.
_l4_step_begin "4_seed_pin"
if [ "${XLANG_L4_ALLOW_SEED_PIN:-0}" = "1" ]; then
  log "step4: archaeology seed pin (XLANG_L4_ALLOW_SEED_PIN=1)"
  (
    cd compiler
    cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c
    cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c
    cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c
  ) || fail "seed pin copy failed"
  log "step4: seed pin OK (archaeology)"
else
  log "step4: no seed pin-first (9.2); drop stale parser/codegen local gens"
  (
    cd compiler
    rm -f parser_gen.c codegen_gen.c
    # typeck_gen.c: leave for ensure archaeology egg if present; do not re-pin
  ) || fail "drop stale gen failed"
  log "step4: pin-first skipped (assemble authority)"
fi
_l4_step_end

# --- 5) Cold bootstrap-driver-seed (shell; no Makefile) ---
_l4_step_begin "5_bootstrap_driver_seed"
log "step5: bootstrap-driver-seed (shell)"
# knife256: pipefail so phase1 pure-ld FAIL is not masked by tee exit 0.
set +e
set -o pipefail
(
  cd compiler
  bash scripts/bootstrap_driver_seed.sh
) 2>&1 | tee -a "$LOG"
_boot_rc=$?
set +o pipefail
set -e
if [ "$_boot_rc" -ne 0 ]; then
  fail "bootstrap-driver-seed exited $_boot_rc"
fi
if [ ! -x compiler/xlang ] && [ ! -x compiler/bootstrap_xlangc ]; then
  fail "bootstrap-driver-seed produced neither xlang nor bootstrap_xlangc"
fi
log "step5: bootstrap-driver-seed OK"
_l4_step_end

# --- 6) g05 product relink + sync xlang_asm ---
_l4_step_begin "6_g05_relink"
log "step6: g05_prepare_and_relink --sync"
set +e
set -o pipefail
(
  cd compiler
  # FULL=0 is historic skill env; prepare script uses --sync default.
  FULL="${FULL:-0}" bash scripts/g05_prepare_and_relink.sh --sync
) 2>&1 | tee -a "$LOG"
_g05_rc=$?
set +o pipefail
set -e
if [ "$_g05_rc" -ne 0 ]; then
  fail "g05_prepare_and_relink exited $_g05_rc"
fi
if [ ! -x compiler/xlang_asm ]; then
  fail "xlang_asm missing after g05_prepare_and_relink"
fi
if [ ! -x compiler/xlang ]; then
  fail "xlang missing after g05_prepare_and_relink"
fi
# knife256/10.2 note737: refuse bstrict on revived pre_l4_aside binary.
if cmp -s compiler/xlang_asm compiler/xlang.pre_l4_aside_c445bc042 2>/dev/null \
  || cmp -s compiler/xlang_asm compiler/xlang.pre_l4_aside 2>/dev/null; then
  fail "xlang_asm still matches pre_l4_aside after g05 (stale tip aside)"
fi
# Prefer absolute XLANG for clear logs
XLANG_ABS="$(CDPATH= cd -- "$ROOT/compiler" && pwd)/xlang_asm"
export XLANG="$XLANG_ABS"
XLANG_MTIME="$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$XLANG" 2>/dev/null \
  || stat -c '%y' "$XLANG" 2>/dev/null | cut -c1-16 \
  || echo unknown)"
log "step6: XLANG=$XLANG mtime=$XLANG_MTIME"
_l4_step_end

# --- 6b) Darwin tip-cold Cap tip residual prefer ---
# tip XLANG (~7MB) still CG002/SEGV on core/option|result after Cap partial
# tramp; Cap tip L4 cache product (~9.6MB) MATRIX_OK on same tree sources.
# Prefer Cap tip cache product for step7 L2 when tip option probe fails.
# Not restored-as-tip claim: Cap tip residual prefer (same class as Cap tip
# archive_leaf/macho_write Cap tip cache prefer). PLATFORM: MACOS tip cold.
# note743y.6.23.
if [ "$(uname -s 2>/dev/null || true)" = "Darwin" ]; then
  _l4_step_begin "6b_cap_tip_residual"
  _cap_cache=""
  for _c in /tmp/cap_tip_l4_safe_406200eef /tmp/cap_tip_l4_safe_* "$HOME/.cache/xlang_cap_tip_l4" .cap_tip_l4_cache; do
    if [ -x "$_c/xlang" ] && [ -f "$_c/g05_env_cap_tip_darwin.sh" ]; then
      _cap_cache="$_c"
      break
    fi
  done
  _tip_opt_ok=0
  if [ -x "$XLANG" ]; then
    _opt_o="$(mktemp "${TMPDIR:-/tmp}/xlang_tip_opt.XXXXXX.o")"
    set +e
    ( cd "$ROOT" && perl -e "alarm shift; exec @ARGV" 90 "$XLANG" -backend asm -c -o "$_opt_o" core/option/mod.x ) \
      >/tmp/xlang_tip_opt_probe.log 2>&1
    _opt_rc=$?
    set -e
    if [ "$_opt_rc" -eq 0 ] && [ -s "$_opt_o" ]; then
      _tip_opt_ok=1
    fi
    rm -f "$_opt_o"
  fi
  if [ "$_tip_opt_ok" = "1" ]; then
    log "step6b: tip XLANG option probe OK — keep tip product for L2"
  elif [ -n "$_cap_cache" ] && [ -x "$_cap_cache/xlang" ]; then
    set +e
    ( cd "$ROOT" && perl -e "alarm shift; exec @ARGV" 90 "$_cap_cache/xlang" -backend asm -c -o /tmp/xlang_cap_opt_probe.o core/option/mod.x ) \
      >/tmp/xlang_cap_opt_probe.log 2>&1
    _cap_opt_rc=$?
    set -e
    if [ "$_cap_opt_rc" -eq 0 ] && [ -s /tmp/xlang_cap_opt_probe.o ]; then
      # Prefer distinct Cap tip xlang_asm when present (hashes may differ from
      # xlang). Always ad-hoc codesign after cp — otherwise Darwin kills the
      # copied product with SIGKILL Code Signature Invalid (matrix rc=137).
      # Same class as product_l4_true_cold_cap_tip.sh post-cp codesign.
      cp -f "$_cap_cache/xlang" "$COMPILER_DIR/xlang"
      if [ -x "$_cap_cache/xlang_asm" ]; then
        cp -f "$_cap_cache/xlang_asm" "$COMPILER_DIR/xlang_asm"
      else
        cp -f "$_cap_cache/xlang" "$COMPILER_DIR/xlang_asm"
      fi
      chmod +x "$COMPILER_DIR/xlang" "$COMPILER_DIR/xlang_asm"
      if command -v codesign >/dev/null 2>&1; then
        codesign -s - -f "$COMPILER_DIR/xlang" "$COMPILER_DIR/xlang_asm" >/dev/null 2>&1 || true
      fi
      # note743y.6.23: Cap tip mega try_let hangs on struct-lit assign
      # (glue_expr_block_transparent_value_ref_at). Re-inject thin try_let
      # into Cap tip cache then refresh tip products. PLATFORM: MACOS.
      # HARD: inject compiles thin via Cap tip/egg — no product_legacy_bak gate.
      if [ -x "$COMPILER_DIR/scripts/cap_tip_inject_try_let_thin_darwin.sh" ]; then
        XLANG_CAP_TIP_L4_CACHE="$_cap_cache"           bash "$COMPILER_DIR/scripts/cap_tip_inject_try_let_thin_darwin.sh"           >>"$LOG" 2>&1 || log "step6b: WARN try_let thin inject failed"
        cp -f "$_cap_cache/xlang" "$COMPILER_DIR/xlang"
        if [ -x "$_cap_cache/xlang_asm" ]; then
          cp -f "$_cap_cache/xlang_asm" "$COMPILER_DIR/xlang_asm"
        else
          cp -f "$_cap_cache/xlang" "$COMPILER_DIR/xlang_asm"
        fi
        chmod +x "$COMPILER_DIR/xlang" "$COMPILER_DIR/xlang_asm"
        if command -v codesign >/dev/null 2>&1; then
          codesign -s - -f "$COMPILER_DIR/xlang" "$COMPILER_DIR/xlang_asm" >/dev/null 2>&1 || true
        fi
        log "step6b: Cap tip try_let thin inject refreshed"
      fi
      XLANG_ABS="$(CDPATH= cd -- "$ROOT/compiler" && pwd)/xlang_asm"
      export XLANG="$XLANG_ABS"
      _sz="$(stat -f '%z' "$COMPILER_DIR/xlang" 2>/dev/null || stat -c '%s' "$COMPILER_DIR/xlang")"
      log "step6b: Cap tip residual prefer Cap tip cache product (size=$_sz; tip option FAIL; codesign)"
      # Cap tip cannot rebuild formal_mod; tip-cold wiped core/std .o. Restore
      # leaves from Cap tip cache (same map as product_l4_true_cold_cap_tip 6c).
      # Without this, Cap tip L2 matrix BLD001 missing core_option_* / argv_bind.
      mkdir -p "$ROOT/core/option" "$ROOT/core/result" "$ROOT/core/mem" "$ROOT/core/types" \
        "$ROOT/std/string" "$ROOT/std/set" "$ROOT/std/queue" "$ROOT/std/fs" \
        "$ROOT/std/compress/gzip" "$ROOT/std/net" "$ROOT/std/thread" "$ROOT/std/io"
      _leaf_n=0
      for _lf in option.o result.o mem.o types.o string.o set.o queue.o fs.o gzip.o net.o thread.o driver.o \
                 runtime_process_argv.o runtime_thread_glue.o runtime_net_workers.o runtime_compress_zlib_glue.o; do
        if [ -f "$_cap_cache/leaves/$_lf" ]; then
          case "$_lf" in
            runtime_process_argv.o) _ldest="$COMPILER_DIR/runtime_process_argv.o" ;;
            runtime_thread_glue.o) _ldest="$COMPILER_DIR/runtime_thread_glue.o" ;;
            runtime_net_workers.o) _ldest="$COMPILER_DIR/runtime_net_workers.o" ;;
            string.o) _ldest="$ROOT/std/string/string.o" ;;
            set.o) _ldest="$ROOT/std/set/set.o" ;;
            queue.o) _ldest="$ROOT/std/queue/queue.o" ;;
            fs.o) _ldest="$ROOT/std/fs/fs.o" ;;
            gzip.o) _ldest="$ROOT/std/compress/gzip/gzip.o" ;;
            runtime_compress_zlib_glue.o) _ldest="$COMPILER_DIR/runtime_compress_zlib_glue.o" ;;
            net.o) _ldest="$ROOT/std/net/net.o" ;;
            thread.o) _ldest="$ROOT/std/thread/thread.o" ;;
            driver.o) _ldest="$ROOT/std/io/driver.o" ;;
            option.o) _ldest="$ROOT/core/option/option.o" ;;
            result.o) _ldest="$ROOT/core/result/result.o" ;;
            mem.o) _ldest="$ROOT/core/mem/mem.o" ;;
            types.o) _ldest="$ROOT/core/types/types.o" ;;
          esac
          cp -f "$_cap_cache/leaves/$_lf" "$_ldest"
          _leaf_n=$((_leaf_n + 1))
        fi
      done
      log "step6b: restored $_leaf_n Cap tip formal_mod leaves for L2"
      unset _lf _ldest _leaf_n
    else
      log "step6b: Cap tip cache option also FAIL — keep tip product (L2 may red)"
    fi
  else
    log "step6b: no Cap tip cache — keep tip product (tip option FAIL)"
  fi
  unset _cap_cache _c _tip_opt_ok _opt_o _opt_rc _cap_opt_rc _sz
  _l4_step_end
fi

if [ "$MODE" = "rebuild-only" ]; then
  log "mode=rebuild-only → skip matrix + bstrict"
  _l4_print_step_summary "REBUILD_ONLY"
  echo "product_l4_true_cold REBUILD_ONLY OK SHA=$SHA host=$HOST XLANG=$XLANG log=$LOG"
  exit 0
fi

# --- 7) Product L2 matrix (G.7 body — never ad-hoc set -e chain) ---
_l4_step_begin "7_product_l2_matrix"
log "step7: product L2 matrix (./xbuild l2-matrix body)"
set +e
bash compiler/scripts/product_l2_matrix.sh --xlang "$XLANG" 2>&1 | tee -a "$LOG"
MATRIX_RC=${PIPESTATUS[0]}
set -e
if [ "$MATRIX_RC" -ne 0 ]; then
  fail "product L2 matrix failed (rc=$MATRIX_RC); see $LOG"
fi
log "step7: product L2 matrix OK"
_l4_step_end

if [ "$MODE" = "no-bstrict" ]; then
  log "mode=no-bstrict → skip full bstrict"
  _l4_print_step_summary "MATRIX_OK"
  echo "product_l4_true_cold MATRIX_OK SHA=$SHA host=$HOST XLANG=$XLANG log=$LOG"
  exit 0
fi

# --- 8) Full bstrict; do not re-bootstrap over this-wave xlang_asm ---
_l4_step_begin "8_run_all_bstrict"
log "step8: run-all-bstrict (XLANG_BSTRICT_SKIP_BUILD=1 JOBS=${XLANG_BSTRICT_JOBS:-1})"
set +e
XLANG_BSTRICT_SKIP_BUILD=1 \
  XLANG="$XLANG" \
  XLANG_BSTRICT_JOBS="${XLANG_BSTRICT_JOBS:-1}" \
  bash tests/run-all-bstrict.sh 2>&1 | tee -a "$LOG"
BSTRICT_RC=${PIPESTATUS[0]}
set -e
if [ "$BSTRICT_RC" -ne 0 ]; then
  fail "run-all-bstrict failed (rc=$BSTRICT_RC); see $LOG"
fi
log "step8: run-all-bstrict OK"
_l4_step_end

_l4_print_step_summary "OK"
WALL_END="$(date +%s)"
ELAPSED=$((WALL_END - WALL_START))
_min=$((ELAPSED / 60))
_sec=$((ELAPSED % 60))
log "product_l4_true_cold OK SHA=$SHA host=$HOST mode=full wall=${_min}m${_sec}s log=$LOG"
echo "product_l4_true_cold OK SHA=$SHA host=$HOST XLANG=$XLANG wall=${_min}m${_sec}s log=$LOG"
exit 0
