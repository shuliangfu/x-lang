#!/usr/bin/env bash
# bootstrap_self.sh — archaeology bootstrap-self body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phony bootstrap-self:
#     1) cp TARGET → TARGET_stage1 (xlang₁ snapshot after bootstrap-driver-seed)
#     2) best-effort ensure satellite leaves (pipeline/driver/lsp/preprocess)
#        via residual make (thin-call edges remain; no dual $(CC) -c in recipe)
#     3) host-cc link TARGET_stage2 with BS_LINK_OBJS (mk expansion from Makefile)
#     4) stage2 compile return-value → run; expect exit 42
#        (if -o emitted C source, re-cc -x c then run)
#
#   Why shell-primary (not physical delete)?
#     Stage2 link bag is still B7D-adjacent residual; prereq graph
#     (bootstrap-driver-seed) + thin leaf edges + mk lists stay on make path.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_self.sh
#   bash scripts/bootstrap_self.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   TARGET              — product binary basename (default: xlang)
#   STAGE1              — stage1 snapshot (default: ${TARGET}_stage1)
#   STAGE2              — stage2 binary (default: ${TARGET}_stage2)
#   CC                  — host C compiler (default: cc)
#   CFLAGS              — optional base host CFLAGS (re-cc of host-emitted C only)
#   BS_LINK_CFLAGS      — optional; default loads via export-xnc-link-cflags (wave857;
#                          CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS)
#   BS_LINK_OBJS        — optional; default loads via export-bs-link-objs (wave856)
#   MAKE                — residual make for best-effort satellite leaves
#   BS_OUT_SELF         — stage2 -o path (default: /tmp/out_self)
#   BS_RV_SRC           — return-value probe (default: ../tests/return-value/main.x)
#
# wave843 (G.7 有则补全): Makefile fat stage2 link + smoke → this script.
# wave856: LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# wave857: LINK_CFLAGS shell-load via make export leaf (G.7; not physical delete).
# NOT physical delete — thin-call edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell orchestration; file(1) Mach-O/ELF/PE32* portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
STAGE1="${STAGE1:-${TARGET}_stage1}"
STAGE2="${STAGE2:-${TARGET}_stage2}"
CC="${CC:-cc}"
CFLAGS="${CFLAGS:-}"
BS_LINK_CFLAGS="${BS_LINK_CFLAGS:-}"
MAKE="${MAKE:-make}"
BS_OUT_SELF="${BS_OUT_SELF:-/tmp/out_self}"
BS_RV_SRC="${BS_RV_SRC:-../tests/return-value/main.x}"

log() { echo "bootstrap-self: $*" >&2; }
fail() { echo "bootstrap-self: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Makefile thin-call only (wave843): scan *recipe* lines (tab-indented) only —
  # comments between phonies must not false-positive on "$(CC)" / stage2 prose.
  _rec=$(awk '
    /^bootstrap-self:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_self\.sh' <<<"$_rec"; then
    fail "bootstrap-self must thin-call bootstrap_self.sh (wave843)"
  fi
  # Dual body: host-cc link of stage2, or inline cp/stage1 smoke
  if grep -qE '\$\(CC\).*_stage2|TARGET\)_stage2' <<<"$_rec"; then
    fail "bootstrap-self must not keep dual \$(CC) stage2 link body (wave843)"
  fi
  if grep -qE 'out_self|return-value/main\.x' <<<"$_rec"; then
    fail "bootstrap-self must not keep dual out_self smoke body (wave843; shell owns smoke)"
  fi
  if grep -qE 'cp.*TARGET.*_stage1|TARGET\)_stage1' <<<"$_rec"; then
    fail "bootstrap-self must not keep dual stage1 cp body (wave843; shell owns snapshot)"
  fi
  # wave856: Makefile must not re-export multi-token LINK bag (shell loads export leaf).
  if grep -qE 'BS_LINK_OBJS=' <<<"$_rec"; then
    fail "bootstrap-self must not export BS_LINK_OBJS (wave856; shell loads export leaf)"
  fi
  # wave857: no multi-token BS_LINK_FLAGS= / BS_LINK_CFLAGS= on recipe.
  if grep -qE 'BS_LINK_FLAGS=|BS_LINK_CFLAGS=' <<<"$_rec"; then
    fail "bootstrap-self must not export BS_LINK_FLAGS/BS_LINK_CFLAGS (wave857; shell loads export leaf)"
  fi
  if ! grep -qE '^export-bs-link-objs:' "$MF"; then
    fail "Makefile must define export-bs-link-objs (wave856)"
  fi
  if ! grep -qE '^export-xnc-link-cflags:' "$MF"; then
    fail "Makefile must define export-xnc-link-cflags (wave857)"
  fi
  log "CHECK OK (wave843+856+857 bootstrap-self shell-primary; LINK_OBJS+CFLAGS export leaves; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ "$MODE" != "" ]; then
  case "$MODE" in
    -h|--help)
      echo "usage: $0 [--check]" >&2
      exit 0
      ;;
    *)
      echo "usage: $0 [--check]" >&2
      exit 2
      ;;
  esac
fi

# ---------------------------------------------------------------------------
# Preflight: link env from Makefile thin-call (G.7: bag stays mk expansion)
# ---------------------------------------------------------------------------
# wave856: full LINK bag needs make expansion (nested $(...) / Darwin filters).
# G.7 有则补全 on bootstrap_driver_seed_export-*-link pattern — shell loads via
# make export leaf when env unset; Makefile recipes drop multi-token BS_LINK_OBJS=.
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
_load_link_objs_via_make() {
  # $1 = make export target (export-*-link-objs)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BS_LINK_OBJS:-}" ]; then
  BS_LINK_OBJS=$(_load_link_objs_via_make export-bs-link-objs) \
    || fail "failed to expand export-bs-link-objs (wave856 LINK_OBJS shell-load)"
fi
if [ -z "${BS_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from export-bs-link-objs (wave856)"
fi

# wave857: composed LINK_CFLAGS need make expansion (DRIVER_SEED_LINK_FLAGS /
# ASM_GLUE / MAIN_LINK / platform ifeq). G.7 有则补全 on wave856 export-leaf pattern.
# PLATFORM: SHARED — KEY=value from export target; no second flag inventory.
_load_link_cflags_via_make() {
  # $1 = make export target (export-*-link-cflags)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_CFLAGS=*) val=${line#LINK_CFLAGS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BS_LINK_CFLAGS:-}" ]; then
  BS_LINK_CFLAGS=$(_load_link_cflags_via_make export-xnc-link-cflags) \
    || fail "failed to expand export-xnc-link-cflags (wave857 LINK_CFLAGS shell-load)"
fi
if [ -z "${BS_LINK_CFLAGS:-}" ]; then
  fail "empty LINK_CFLAGS from export-xnc-link-cflags (wave857)"
fi
if [ ! -x "./$TARGET" ] && [ ! -f "./$TARGET" ]; then
  fail "missing $TARGET (build prereq first: make bootstrap-driver-seed)"
fi

# ---------------------------------------------------------------------------
# Snapshot xlang₁ and ensure satellite leaves (best-effort; residual make)
# PLATFORM: SHARED — leaves already thin (wave785 B7c; no dual $(CC) -c)
# ---------------------------------------------------------------------------
log "snapshot $TARGET → $STAGE1"
cp "$TARGET" "$STAGE1"

log "best-effort ensure satellite leaves (pipeline/driver/lsp/preprocess)"
# wave937: shell-primary (was $MAKE -s pipeline_x.o driver_x.o ...). Best-effort
# ensure via try-heat / driver_leaf_x_to_o.sh; failures soft-skipped (|| true).
bash scripts/ensure_host_cc_seed_o.sh try-heat pipeline_x.o 2>/dev/null || true
bash scripts/ensure_host_cc_seed_o.sh try-heat driver_x.o 2>/dev/null || true
bash scripts/ensure_host_cc_seed_o.sh try-heat preprocess_x.o 2>/dev/null || true
bash scripts/ensure_host_cc_seed_o.sh try-heat lsp_io_x.o 2>/dev/null || true
bash scripts/ensure_host_cc_seed_o.sh try-heat lsp_x.o 2>/dev/null || true
bash scripts/driver_leaf_x_to_o.sh ensure lsp_io_std_heap_x.o 2>/dev/null || true

# ---------------------------------------------------------------------------
# host-cc link stage2 (bag from Makefile; B7D-adjacent residual, not g05 product)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this archaeology path
# ---------------------------------------------------------------------------
log "link ./$STAGE2"
# shellcheck disable=SC2086
$CC $BS_LINK_CFLAGS -o "./$STAGE2" $BS_LINK_OBJS

# ---------------------------------------------------------------------------
# Smoke: stage2 → return-value; expect exit 42
# PLATFORM: SHARED — file(1) classifies Mach-O / ELF / PE32*; else re-cc -x c
# ---------------------------------------------------------------------------
rm -f "$BS_OUT_SELF" "${BS_OUT_SELF}.bin"
log "stage2 compile $BS_RV_SRC → $BS_OUT_SELF"
./"$STAGE2" "$BS_RV_SRC" -o "$BS_OUT_SELF"

ft=$(file -b "$BS_OUT_SELF" 2>/dev/null || true)
BIN="$BS_OUT_SELF"
case "$ft" in
  *Mach-O*|*ELF*|*PE32*) ;;
  *)
    log "re-cc -x c $BS_OUT_SELF (host-emitted C, not native binary)"
    # shellcheck disable=SC2086
    $CC $CFLAGS -x c -std=c11 -Wall -Wextra -o "${BS_OUT_SELF}.bin" "$BS_OUT_SELF"
    BIN="${BS_OUT_SELF}.bin"
    ;;
esac

set +e
"$BIN"
EX=$?
set -e
if [ "$EX" -eq 42 ]; then
  echo "bootstrap-self OK (xlang1 -> xlang2)"
  exit 0
fi
fail "stage2 or out_self exit=$EX (want 42)"
