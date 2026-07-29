#!/usr/bin/env bash
# phys_del_makefile_gate.sh — wave799 · physical-delete *execute* gate
#
# PLATFORM: SHARED shell orchestration (macOS / Ubuntu / Windows MSYS2).
# Windows min-gate body runs only on MSYS2 (tests/run-bootstrap-bstrict-windows-gate.sh).
#
# Authority (G.7):
#   Single shell authority that *refuses* physical delete of compiler/Makefile
#   until Windows hybrid min-gate is re-proven on this tip. Complements
#   leaf_pattern_residual.sh preflight keys (wave798). Does NOT delete Makefile.
#   Does NOT flip PHYS_DEL_WINDOWS_GATE_STATUS (that stays a code-reviewed leaf key).
#
# Modes:
#   status | --status          Dump readiness + host + Windows gate honesty
#   --check | check            Machine-check gate wiring + refuse contract
#   --dry-run-delete           List what physical delete *would* touch; never rm
#   --run-windows-gate         Run min-gate (MSYS2 only; non-MSYS skip exit 0)
#   --delete                   HARD refuse unless Windows green + confirm env
#                              (this tip keeps STATUS=not_reproven → always refuse)
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/phys_del_makefile_gate.sh
#   bash compiler/scripts/phys_del_makefile_gate.sh --check
#   bash compiler/scripts/phys_del_makefile_gate.sh --dry-run-delete
#   ./xbuild phys-del-gate [--check|--dry-run-delete|--run-windows-gate]
#
# Env (delete path only — still refused while gate not green):
#   XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND
#   XLANG_PHYS_DEL_WINDOWS_PROOF=/path/to/proof  (optional future stamp)
#
# Wave: 799 Track MG · 11.3.1 · NOT physical delete · NOT Windows green claim

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$COMPILER_DIR/.." && pwd)"
LEAF_SH="$SCRIPT_DIR/leaf_pattern_residual.sh"
WIN_GATE_REL="tests/run-bootstrap-bstrict-windows-gate.sh"
WIN_GATE="$ROOT/$WIN_GATE_REL"
MAKEFILE="$COMPILER_DIR/Makefile"
MODE="${1:-status}"

log() { echo "phys-del-makefile-gate: $*" >&2; }
die() { echo "phys-del-makefile-gate FAIL: $*" >&2; exit 1; }

leaf_dump() {
  if [ ! -f "$LEAF_SH" ]; then
    die "missing leaf_pattern_residual.sh"
  fi
  bash "$LEAF_SH" 2>/dev/null
}

leaf_get() {
  # $1 = key name
  local k="$1"
  local v
  v="$(leaf_dump | grep -E "^${k}=" | head -1 | sed "s/^${k}=//" || true)"
  printf '%s' "$v"
}

is_msys() {
  # PLATFORM: WINDOWS — MSYS2 / MinGW shell only.
  case "${MSYSTEM:-}${OSTYPE:-}" in
    *MSYS*|*MINGW*|*msys*|*mingw*) return 0 ;;
  esac
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  return 1
}

host_label() {
  if is_msys; then
    echo "MSYS2/Windows"
  else
    uname -s 2>/dev/null || echo unknown
  fi
}

print_status() {
  local preflight win_status endgame force heat next blockers cmd host
  preflight="$(leaf_get PHYS_DEL_PREFLIGHT)"
  win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
  endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"
  force="$(leaf_get PHYS_DEL_PREFLIGHT_FORCE_DEP_THIN)"
  heat="$(leaf_get PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL)"
  next="$(leaf_get PHYS_DEL_PREFLIGHT_NEXT)"
  blockers="$(leaf_get PHYS_DEL_PREFLIGHT_BLOCKERS)"
  cmd="$(leaf_get PHYS_DEL_PREFLIGHT_WIN_GATE_CMD)"
  host="$(host_label)"

  cat <<EOF
PHYS_DEL_EXECUTE_GATE=1
PHYS_DEL_EXECUTE_GATE_WAVE=wave799
PHYS_DEL_EXECUTE_GATE_NOTE=refuse_delete_without_windows_green_not_physical_delete
PHYS_DEL_EXECUTE_GATE_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_EXECUTE_GATE_HOST=$(host_label)
PHYS_DEL_EXECUTE_GATE_IS_MSYS=$(is_msys && echo 1 || echo 0)
PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1
PHYS_DEL_EXECUTE_GATE_WIN_GATE_CMD=${cmd:-$WIN_GATE_REL}
PHYS_DEL_EXECUTE_GATE_MAKEFILE_PRESENT=$([ -f "$MAKEFILE" ] && echo 1 || echo 0)
PHYS_DEL_EXECUTE_GATE_PREFLIGHT=${preflight:-?}
PHYS_DEL_EXECUTE_GATE_WINDOWS_STATUS=${win_status:-?}
PHYS_DEL_EXECUTE_GATE_ENDGAME=${endgame:-?}
PHYS_DEL_EXECUTE_GATE_FORCE_DEP_THIN=${force:-?}
PHYS_DEL_EXECUTE_GATE_HEAT_RESIDUAL=${heat:-?}
PHYS_DEL_EXECUTE_GATE_BLOCKERS=${blockers:-?}
PHYS_DEL_EXECUTE_GATE_NEXT=${next:-?}
PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0
PHYS_DEL_EXECUTE_GATE_FORBIDDEN=claim_execute_gate_is_physical_delete|claim_execute_gate_is_windows_green|delete_makefile_before_windows_green
# Human runbook (dual-boot host currently often Ubuntu):
#   1) reboot dual-boot → Windows/MSYS2 (ssh windows-server)
#   2) git pull --ff-only origin self-hosting
#   3) ./tests/run-bootstrap-bstrict-windows-gate.sh   # or: ./xbuild phys-del-gate --run-windows-gate
#   4) on green: mac commit flips PHYS_DEL_WINDOWS_GATE_STATUS + physical delete wave
#   5) NEVER rm compiler/Makefile on this tip while STATUS=not_reproven_this_tip
EOF
}

cmd_check() {
  local bad=0
  note() { echo "phys-del-makefile-gate: $*" >&2; }
  badf() { echo "phys-del-makefile-gate: BAD: $*" >&2; bad=1; }

  [ -f "$LEAF_SH" ] || badf "missing leaf_pattern_residual.sh"
  [ -f "$WIN_GATE" ] || badf "missing $WIN_GATE_REL"
  [ -f "$MAKEFILE" ] || badf "compiler/Makefile missing (unexpected mid-migration)"
  [ -x "$0" ] || chmod +x "$0" 2>/dev/null || true

  local dump
  dump="$(print_status)"
  printf '%s\n' "$dump" | grep -q 'PHYS_DEL_EXECUTE_GATE=1' || badf "status missing PHYS_DEL_EXECUTE_GATE=1"
  printf '%s\n' "$dump" | grep -q 'PHYS_DEL_EXECUTE_GATE_WAVE=wave799' || badf "status missing WAVE=wave799"
  printf '%s\n' "$dump" | grep -q 'PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1' || badf "must refuse delete"
  printf '%s\n' "$dump" | grep -q 'PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0' || badf "DELETE_ALLOWED must be 0 this tip"

  # Cross-check leaf honesty (Windows still not green; endgame 0).
  local leaf
  leaf="$(leaf_dump)"
  printf '%s\n' "$leaf" | grep -q 'PHYS_DEL_PREFLIGHT=1' || badf "leaf preflight not live"
  printf '%s\n' "$leaf" | grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' \
    || badf "leaf must keep WINDOWS_GATE_STATUS=not_reproven_this_tip"
  printf '%s\n' "$leaf" | grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0' \
    || badf "leaf must keep ENDGAME_PHYSICAL_DELETE_MAKEFILE=0"
  if printf '%s\n' "$leaf" | grep -qE 'PHYS_DEL_WINDOWS_GATE_STATUS=green|ENDGAME_PHYSICAL_DELETE_MAKEFILE=1'; then
    badf "leaf falsely claims Windows green or physical delete complete"
  fi
  printf '%s\n' "$leaf" | grep -q 'PHYS_DEL_EXECUTE_GATE=1' \
    || badf "leaf dump missing PHYS_DEL_EXECUTE_GATE=1 (wire wave799 keys)"
  printf '%s\n' "$leaf" | grep -q 'PHYS_DEL_EXECUTE_GATE_WAVE=wave799' \
    || badf "leaf dump missing PHYS_DEL_EXECUTE_GATE_WAVE=wave799"

  # Refuse contract: --delete must fail hard on this tip.
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --delete >/tmp/phys_del_refuse_out.$$ 2>/tmp/phys_del_refuse_err.$$; then
    badf "--delete exited 0 (must refuse while Windows not green)"
  else
    if ! grep -qE 'REFUSED|refuse|Windows' /tmp/phys_del_refuse_err.$$ 2>/dev/null; then
      badf "--delete fail message must mention refuse/Windows"
    else
      note "--delete hard-refuse OK (expected)"
    fi
  fi
  rm -f /tmp/phys_del_refuse_out.$$ /tmp/phys_del_refuse_err.$$

  # Non-MSYS: windows-gate script skip path must be honest (exit 0 skip).
  if ! is_msys; then
    note "host=$(host_label) — Windows min-gate not run here (expected dual-boot)"
  fi

  if [ "$bad" -ne 0 ]; then
    echo "phys-del-makefile-gate: CHECK FAILED" >&2
    exit 1
  fi
  echo "phys-del-makefile-gate: CHECK OK (wave799 execute-gate; refuse-delete; not Windows green; not physical delete)"
  exit 0
}

cmd_dry_run_delete() {
  cat <<EOF
# phys-del-makefile-gate --dry-run-delete (wave799)
# NEVER deletes. Lists intended endgame surface after Windows green + reviewed wave.
HOST=$(host_label)
WINDOWS_GATE_STATUS=$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)
ENDGAME_PHYSICAL_DELETE_MAKEFILE=$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)
DELETE_ALLOWED=0

WOULD_TOUCH_PRIMARY:
  - compiler/Makefile   # product/cold thin-call edges + residual std graph (11.3 endgame)

WOULD_NOT_TOUCH_THIS_WAVE_ALONE:
  - compiler/mk/*.mk              # B7B list authority residual (migrate with catalog)
  - seeds / .x product sources
  - tests/probes/wave713/         # untracked local; leave alone

BLOCKERS_STILL_NAMED:
  $(leaf_get PHYS_DEL_PREFLIGHT_BLOCKERS)

NEXT_HUMAN:
  reboot dual-boot to Windows/MSYS2 → $WIN_GATE_REL → green → mac commit delete wave
EOF
}

cmd_run_windows_gate() {
  if ! is_msys; then
    log "skip --run-windows-gate (host is not MSYS2; dual-boot reboot required)"
    log "cmd: cd repo && ./$WIN_GATE_REL"
    exit 0
  fi
  # PLATFORM: WINDOWS — only path that can re-prove hybrid min-gate.
  log "running Windows hybrid min-gate: $WIN_GATE_REL"
  cd "$ROOT"
  bash "$WIN_GATE"
  log "Windows min-gate exit=0. Next: mac commit must flip PHYS_DEL_WINDOWS_GATE_STATUS after dual review; then physical delete wave."
  log "This script does NOT flip leaf keys and does NOT delete Makefile."
}

cmd_delete() {
  local win_status endgame
  win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
  endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"

  log "REFUSED physical delete of compiler/Makefile"
  log "  PHYS_DEL_WINDOWS_GATE_STATUS=${win_status:-?}"
  log "  ENDGAME_PHYSICAL_DELETE_MAKEFILE=${endgame:-?}"
  log "  host=$(host_label) is_msys=$(is_msys && echo 1 || echo 0)"
  log "  reason: Windows hybrid min-gate not re-proven on this tip (wave778/798/799)"
  log "  runbook: reboot → MSYS2 → ./$WIN_GATE_REL → mac commit green + delete wave"
  log "  forbidden: delete_makefile_before_windows_green"

  # Even if someone forges leaf keys later, require explicit confirm AND green.
  if [ "${win_status:-}" != "green" ] && [ "${win_status:-}" != "reproven_green" ]; then
    die "Windows gate status is not green (got '${win_status:-empty}')"
  fi
  if [ "${endgame:-}" != "1" ]; then
    die "ENDGAME_PHYSICAL_DELETE_MAKEFILE is not 1 (got '${endgame:-empty}') — flip only in reviewed delete wave"
  fi
  if [ "${XLANG_PHYS_DEL_CONFIRM:-}" != "DELETE_MAKEFILE_I_UNDERSTAND" ]; then
    die "set XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND only after Windows green + review"
  fi
  # Hard stop: wave799 never performs rm. Future delete wave may extend carefully.
  die "wave799 execute-gate never rm Makefile (delete body deferred to post-Windows-green wave)"
}

case "$MODE" in
  status|--status|"")
    print_status
    ;;
  --check|check|-c)
    cmd_check
    ;;
  --dry-run-delete|dry-run-delete|dry-run)
    cmd_dry_run_delete
    ;;
  --run-windows-gate|run-windows-gate|windows-gate)
    cmd_run_windows_gate
    ;;
  --delete|delete)
    cmd_delete
    ;;
  -h|--help|help)
    sed -n '2,40p' "$0"
    ;;
  *)
    die "unknown mode '$MODE' (status|--check|--dry-run-delete|--run-windows-gate|--delete)"
    ;;
esac
