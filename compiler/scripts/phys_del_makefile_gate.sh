#!/usr/bin/env bash
# phys_del_makefile_gate.sh — wave799 execute-gate + wave800 proof + wave801 STATUS flip prep
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
# wave800 (G.7 有则补全 on this script):
#   Machine-checkable *evidence* stamp after MSYS min-gate green.
#   Proof ≠ STATUS flip. Proof ≠ physical delete. Mac/Ubuntu can --verify a
#   stamp scp'd from Windows (tip SHA must match HEAD).
#
# wave801 (G.7 有则补全 on this script):
#   --status-flip-preview: after verified proof, print the *exact* leaf key plan
#   a reviewed mac commit would apply. Preview never edits files. Preview ≠ flip.
#   Preview ≠ physical delete. ENDGAME stays 0 until a separate delete wave.
#
# Modes:
#   status | --status          Dump readiness + host + Windows gate honesty + proof
#   --check | check            Machine-check gate wiring + refuse + proof + flip-prep
#   --dry-run-delete           List what physical delete *would* touch; never rm
#   --run-windows-gate         Run min-gate (MSYS2 only; non-MSYS skip exit 0);
#                              on success write proof stamp (wave800)
#   --verify-windows-proof [path]
#                              Verify stamp vs HEAD tip (exit 0 match, 2 no/mismatch)
#   --status-flip-preview [path]
#                              Proof-gated plan for reviewed STATUS flip (wave801);
#                              never edits leaf; exit 0 plan ready, 2 no/bad proof
#   --delete                   HARD refuse unless Windows green + confirm env
#                              (this tip keeps STATUS=not_reproven → always refuse)
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/phys_del_makefile_gate.sh
#   bash compiler/scripts/phys_del_makefile_gate.sh --check
#   bash compiler/scripts/phys_del_makefile_gate.sh --dry-run-delete
#   bash compiler/scripts/phys_del_makefile_gate.sh --verify-windows-proof [/path]
#   bash compiler/scripts/phys_del_makefile_gate.sh --status-flip-preview [/path]
#   ./xbuild phys-del-gate [--check|--dry-run-delete|--run-windows-gate|--verify-windows-proof|--status-flip-preview]
#
# Env:
#   XLANG_PHYS_DEL_WINDOWS_PROOF=/path/to/proof   default /tmp/xlang_phys_del_windows_proof.txt
#   XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND  (delete path only; still refused)
#
# Wave: 799–801 Track MG · 11.3.1 · NOT physical delete · NOT STATUS flip · NOT Windows green claim

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$COMPILER_DIR/.." && pwd)"
LEAF_SH="$SCRIPT_DIR/leaf_pattern_residual.sh"
WIN_GATE_REL="tests/run-bootstrap-bstrict-windows-gate.sh"
WIN_GATE="$ROOT/$WIN_GATE_REL"
MAKEFILE="$COMPILER_DIR/Makefile"
PROOF_DEFAULT="/tmp/xlang_phys_del_windows_proof.txt"
MODE="${1:-status}"
MODE_ARG2="${2:-}"

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

tip_full() {
  git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown
}

tip_short() {
  git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown
}

proof_path() {
  # Optional override path; else env; else default /tmp stamp (scp-friendly).
  if [ -n "${1:-}" ]; then
    printf '%s' "$1"
  elif [ -n "${XLANG_PHYS_DEL_WINDOWS_PROOF:-}" ]; then
    printf '%s' "$XLANG_PHYS_DEL_WINDOWS_PROOF"
  else
    printf '%s' "$PROOF_DEFAULT"
  fi
}

proof_get() {
  # $1 = proof file, $2 = key
  local f="$1" k="$2" v
  [ -f "$f" ] || { printf ''; return 0; }
  v="$(grep -E "^${k}=" "$f" 2>/dev/null | head -1 | sed "s/^${k}=//" || true)"
  printf '%s' "$v"
}

write_proof_stamp() {
  # $1 = path, $2 = gate rc (must be 0 for a valid green stamp)
  local path="$1" rc="${2:-0}"
  local full short utc host msys_env
  full="$(tip_full)"
  short="$(tip_short)"
  utc="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date)"
  host="$(host_label)"
  msys_env="${MSYSTEM:-none}"

  umask 022
  cat >"$path" <<EOF
PHYS_DEL_WINDOWS_PROOF=1
PHYS_DEL_WINDOWS_PROOF_SCHEMA=wave800
PHYS_DEL_WINDOWS_PROOF_TIP_FULL=$full
PHYS_DEL_WINDOWS_PROOF_TIP_SHORT=$short
PHYS_DEL_WINDOWS_PROOF_HOST=$host
PHYS_DEL_WINDOWS_PROOF_MSYSTEM=$msys_env
PHYS_DEL_WINDOWS_PROOF_GATE_CMD=$WIN_GATE_REL
PHYS_DEL_WINDOWS_PROOF_RC=$rc
PHYS_DEL_WINDOWS_PROOF_UTC=$utc
PHYS_DEL_WINDOWS_PROOF_NOTE=evidence_only_not_status_flip_manual_review_required
PHYS_DEL_WINDOWS_PROOF_FORBIDDEN=claim_proof_is_status_green|claim_proof_is_physical_delete|auto_flip_leaf_from_proof
EOF
  log "wrote Windows min-gate proof stamp: $path (tip=$short rc=$rc host=$host)"
  log "proof is EVIDENCE only — does NOT flip PHYS_DEL_WINDOWS_GATE_STATUS; does NOT delete Makefile"
}

# Returns: present 0/1, tip_match 0/1/n_a via globals set for status dump.
proof_inspect() {
  local path rc_proof tip_p tip_h
  path="$(proof_path "${1:-}")"
  PROOF_PATH_RESOLVED="$path"
  PROOF_PRESENT=0
  PROOF_TIP_MATCH=n_a
  PROOF_RC_FIELD=
  PROOF_HOST_FIELD=
  if [ ! -f "$path" ]; then
    return 0
  fi
  if ! grep -qE '^PHYS_DEL_WINDOWS_PROOF=1' "$path" 2>/dev/null; then
    PROOF_PRESENT=0
    return 0
  fi
  PROOF_PRESENT=1
  PROOF_RC_FIELD="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_RC)"
  PROOF_HOST_FIELD="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_HOST)"
  tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_FULL)"
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_SHORT)"
  fi
  tip_h="$(tip_full)"
  if [ -n "$tip_p" ] && { [ "$tip_p" = "$tip_h" ] || [ "$tip_p" = "$(tip_short)" ]; }; then
    PROOF_TIP_MATCH=1
  else
    # Also accept short prefix match (7+ chars of full SHA).
    if [ -n "$tip_p" ] && [ "${#tip_p}" -ge 7 ] && [ "${tip_h#"$tip_p"}" != "$tip_h" ]; then
      PROOF_TIP_MATCH=1
    else
      PROOF_TIP_MATCH=0
    fi
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

  proof_inspect
  # shellcheck disable=SC2034
  local _p="$PROOF_PRESENT" _m="$PROOF_TIP_MATCH"

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
# wave800: Windows min-gate proof stamp harness (evidence only; not STATUS green)
PHYS_DEL_WINDOWS_PROOF_HARNESS=1
PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800
PHYS_DEL_WINDOWS_PROOF_HARNESS_NOTE=evidence_stamp_after_msys_min_gate_not_status_flip
PHYS_DEL_WINDOWS_PROOF_DEFAULT_PATH=$PROOF_DEFAULT
PHYS_DEL_WINDOWS_PROOF_PATH_RESOLVED=$PROOF_PATH_RESOLVED
PHYS_DEL_WINDOWS_PROOF_PRESENT=$PROOF_PRESENT
PHYS_DEL_WINDOWS_PROOF_TIP_MATCH=$PROOF_TIP_MATCH
PHYS_DEL_WINDOWS_PROOF_RC_FIELD=${PROOF_RC_FIELD:-}
PHYS_DEL_WINDOWS_PROOF_HOST_FIELD=${PROOF_HOST_FIELD:-}
PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP=0
PHYS_DEL_WINDOWS_PROOF_DELETE_ALLOWED=0
PHYS_DEL_WINDOWS_PROOF_FORBIDDEN=claim_proof_is_status_green|claim_proof_is_physical_delete|auto_flip_leaf_from_proof
# wave801: STATUS flip prep / preview (plan only after verified proof; not flip; not delete)
PHYS_DEL_STATUS_FLIP_PREP=1
PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801
PHYS_DEL_STATUS_FLIP_PREP_NOTE=preview_only_after_verified_proof_not_flip_not_delete
PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0
PHYS_DEL_STATUS_FLIP_PREP_REQUIRES_PROOF=1
PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_PREP_ENDGAME_AFTER_FLIP=0
PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_PREP_FORBIDDEN=auto_edit_leaf|claim_preview_is_flip|claim_preview_is_delete|flip_endgame_with_status
# Human runbook (dual-boot host currently often Ubuntu):
#   1) reboot dual-boot → Windows/MSYS2 (ssh windows-server)
#   2) git pull --ff-only origin self-hosting
#   3) ./xbuild phys-del-gate --run-windows-gate   # writes proof stamp on green
#      or: ./tests/run-bootstrap-bstrict-windows-gate.sh then:
#          XLANG_PHYS_DEL_WINDOWS_PROOF=/tmp/xlang_phys_del_windows_proof.txt \\
#            ./xbuild phys-del-gate --run-windows-gate
#   4) scp windows-server:/tmp/xlang_phys_del_windows_proof.txt /tmp/
#   5) mac: ./xbuild phys-del-gate --verify-windows-proof  # tip SHA must match
#   6) mac: ./xbuild phys-del-gate --status-flip-preview   # plan only; no edit
#   7) on green evidence + review: mac commit flips PHYS_DEL_WINDOWS_GATE_STATUS
#      (ENDGAME stays 0); then separate physical delete wave
#   8) NEVER rm compiler/Makefile on this tip while STATUS=not_reproven_this_tip
#   9) NEVER auto-edit leaf from preview / proof alone
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
  grep -q 'PHYS_DEL_EXECUTE_GATE=1' <<<"$dump" || badf "status missing PHYS_DEL_EXECUTE_GATE=1"
  grep -q 'PHYS_DEL_EXECUTE_GATE_WAVE=wave799' <<<"$dump" || badf "status missing WAVE=wave799"
  grep -q 'PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1' <<<"$dump" || badf "must refuse delete"
  grep -q 'PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0' <<<"$dump" || badf "DELETE_ALLOWED must be 0 this tip"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS=1' <<<"$dump" \
    || badf "status missing PHYS_DEL_WINDOWS_PROOF_HARNESS=1 (wave800)"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800' <<<"$dump" \
    || badf "status missing PROOF_HARNESS_WAVE=wave800"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP=0' <<<"$dump" \
    || badf "proof must keep STATUS_FLIP=0"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_DELETE_ALLOWED=0' <<<"$dump" \
    || badf "proof must keep DELETE_ALLOWED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP=1' <<<"$dump" \
    || badf "status missing PHYS_DEL_STATUS_FLIP_PREP=1 (wave801)"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801' <<<"$dump" \
    || badf "status missing STATUS_FLIP_PREP_WAVE=wave801"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0' <<<"$dump" \
    || badf "status flip prep must keep APPLIED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED=0' <<<"$dump" \
    || badf "status flip prep must keep DELETE_ALLOWED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS=reproven_green' <<<"$dump" \
    || badf "status flip prep target must be reproven_green"

  # Cross-check leaf honesty (Windows still not green; endgame 0).
  local leaf
  leaf="$(leaf_dump)"
  grep -q 'PHYS_DEL_PREFLIGHT=1' <<<"$leaf" || badf "leaf preflight not live"
  grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$leaf" \
    || badf "leaf must keep WINDOWS_GATE_STATUS=not_reproven_this_tip"
  grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0' <<<"$leaf" \
    || badf "leaf must keep ENDGAME_PHYSICAL_DELETE_MAKEFILE=0"
  if grep -qE 'PHYS_DEL_WINDOWS_GATE_STATUS=green|PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green|ENDGAME_PHYSICAL_DELETE_MAKEFILE=1' <<<"$leaf"; then
    badf "leaf falsely claims Windows green or physical delete complete"
  fi
  grep -q 'PHYS_DEL_EXECUTE_GATE=1' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_EXECUTE_GATE=1 (wire wave799 keys)"
  grep -q 'PHYS_DEL_EXECUTE_GATE_WAVE=wave799' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_EXECUTE_GATE_WAVE=wave799"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS=1' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_WINDOWS_PROOF_HARNESS=1 (wave800)"
  grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP=1' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_PREP=1 (wave801)"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801"
  grep -q 'PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0' <<<"$leaf" \
    || badf "leaf dump must keep STATUS_FLIP_PREP_APPLIED=0"

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

  # wave800: synthetic proof round-trip (PLATFORM: SHARED — no MSYS required).
  local synth="/tmp/xlang_phys_del_proof_synth.$$"
  local bad_synth="/tmp/xlang_phys_del_proof_bad.$$"
  write_proof_stamp "$synth" 0
  if ! XLANG_PHYS_DEL_WINDOWS_PROOF="$synth" bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" \
      --verify-windows-proof "$synth" >/tmp/phys_del_vfy_ok.$$ 2>&1; then
    cat /tmp/phys_del_vfy_ok.$$ >&2 || true
    badf "synthetic proof with matching tip must --verify exit 0"
  else
    note "synthetic matching proof --verify OK (wave800 harness)"
  fi
  # Wrong tip must fail (exit 2). Portable: rewrite without sed -i (GNU vs BSD).
  sed \
    -e 's/^PHYS_DEL_WINDOWS_PROOF_TIP_FULL=.*/PHYS_DEL_WINDOWS_PROOF_TIP_FULL=deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/' \
    -e 's/^PHYS_DEL_WINDOWS_PROOF_TIP_SHORT=.*/PHYS_DEL_WINDOWS_PROOF_TIP_SHORT=deadbee/' \
    "$synth" >"$bad_synth"
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --verify-windows-proof "$bad_synth" \
      >/tmp/phys_del_vfy_bad.$$ 2>&1; then
    badf "mismatched-tip proof must not --verify exit 0"
  else
    note "mismatched-tip proof --verify refuses OK (wave800)"
  fi
  # Missing proof → exit 2 (not harness crash).
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" \
      --verify-windows-proof "/tmp/xlang_phys_del_proof_missing_$$" \
      >/tmp/phys_del_vfy_miss.$$ 2>&1; then
    badf "missing proof must not --verify exit 0"
  else
    note "missing proof --verify non-zero OK (wave800)"
  fi

  # wave801: status-flip-preview requires verified proof; never edits leaf.
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" \
      --status-flip-preview "/tmp/xlang_phys_del_proof_missing_$$" \
      >/tmp/phys_del_flip_miss.$$ 2>&1; then
    badf "missing proof must not --status-flip-preview exit 0"
  else
    note "missing proof --status-flip-preview non-zero OK (wave801)"
  fi
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-preview "$bad_synth" \
      >/tmp/phys_del_flip_bad.$$ 2>&1; then
    badf "mismatched-tip proof must not --status-flip-preview exit 0"
  else
    note "mismatched-tip proof --status-flip-preview refuses OK (wave801)"
  fi
  if ! bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-preview "$synth" \
      >/tmp/phys_del_flip_ok.$$ 2>&1; then
    cat /tmp/phys_del_flip_ok.$$ >&2 || true
    badf "synthetic matching proof must --status-flip-preview exit 0"
  else
    if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREVIEW_READY=1' /tmp/phys_del_flip_ok.$$; then
      badf "status-flip-preview must print PHYS_DEL_STATUS_FLIP_PREVIEW_READY=1"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_PREVIEW_APPLIED=0' /tmp/phys_del_flip_ok.$$; then
      badf "status-flip-preview must keep APPLIED=0"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_PREVIEW_TARGET=reproven_green' /tmp/phys_del_flip_ok.$$; then
      badf "status-flip-preview must name TARGET=reproven_green"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_PREVIEW_ENDGAME=0' /tmp/phys_del_flip_ok.$$; then
      badf "status-flip-preview must keep ENDGAME=0"
    else
      note "synthetic matching proof --status-flip-preview OK (wave801 harness)"
    fi
  fi
  # Preview must not have mutated leaf STATUS.
  leaf="$(leaf_dump)"
  if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$leaf"; then
    badf "status-flip-preview must not edit leaf STATUS (still not_reproven required)"
  fi
  if grep -qE 'PHYS_DEL_WINDOWS_GATE_STATUS=green|PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green' <<<"$leaf"; then
    badf "status-flip-preview mutated leaf toward green (forbidden)"
  fi

  rm -f "$synth" "$bad_synth" /tmp/phys_del_vfy_ok.$$ /tmp/phys_del_vfy_bad.$$ \
    /tmp/phys_del_vfy_miss.$$ /tmp/phys_del_flip_miss.$$ /tmp/phys_del_flip_bad.$$ \
    /tmp/phys_del_flip_ok.$$

  # Non-MSYS: windows-gate script skip path must be honest (exit 0 skip).
  if ! is_msys; then
    note "host=$(host_label) — Windows min-gate not run here (expected dual-boot)"
  fi

  if [ "$bad" -ne 0 ]; then
    echo "phys-del-makefile-gate: CHECK FAILED" >&2
    exit 1
  fi
  echo "phys-del-makefile-gate: CHECK OK (wave799 execute-gate + wave800 proof + wave801 status-flip-prep; refuse-delete; not Windows green; not STATUS flip; not physical delete)"
  exit 0
}

cmd_dry_run_delete() {
  cat <<EOF
# phys-del-makefile-gate --dry-run-delete (wave799/800)
# NEVER deletes. Lists intended endgame surface after Windows green + reviewed wave.
HOST=$(host_label)
WINDOWS_GATE_STATUS=$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)
ENDGAME_PHYSICAL_DELETE_MAKEFILE=$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)
DELETE_ALLOWED=0
PROOF_IS_NOT_DELETE=1

WOULD_TOUCH_PRIMARY:
  - compiler/Makefile   # product/cold thin-call edges + residual std graph (11.3 endgame)

WOULD_NOT_TOUCH_THIS_WAVE_ALONE:
  - compiler/mk/*.mk              # B7B list authority residual (migrate with catalog)
  - seeds / .x product sources
  - tests/probes/wave713/         # untracked local; leave alone
  - proof stamp files             # evidence only; not a delete surface

BLOCKERS_STILL_NAMED:
  $(leaf_get PHYS_DEL_PREFLIGHT_BLOCKERS)

NEXT_HUMAN:
  reboot dual-boot to Windows/MSYS2 → ./xbuild phys-del-gate --run-windows-gate
  → scp proof → mac --verify-windows-proof → --status-flip-preview
  → reviewed STATUS flip commit (ENDGAME=0) → separate delete wave
EOF
}

# wave801: proof-gated plan for reviewed STATUS flip. Never edits leaf keys.
# Exit: 0 = plan ready (proof tip+RC OK); 2 = missing/bad proof; 1 = harness error.
cmd_status_flip_preview() {
  local path tip_p tip_h rc_field win_status endgame cur_tip
  path="$(proof_path "${1:-}")"
  win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
  endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"
  cur_tip="$(tip_short)"

  if [ ! -f "$path" ]; then
    log "status-flip-preview: no proof stamp at $path"
    log "  on MSYS2: ./xbuild phys-del-gate --run-windows-gate"
    log "  then scp to this host and: ./xbuild phys-del-gate --status-flip-preview"
    exit 2
  fi
  if ! grep -qE '^PHYS_DEL_WINDOWS_PROOF=1' "$path"; then
    log "status-flip-preview: file is not a PHYS_DEL_WINDOWS_PROOF=1 stamp: $path"
    exit 2
  fi
  rc_field="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_RC)"
  if [ "${rc_field:-}" != "0" ]; then
    log "status-flip-preview: stamp RC field is '${rc_field:-empty}' (need 0)"
    exit 2
  fi
  tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_FULL)"
  tip_h="$(tip_full)"
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_SHORT)"
  fi
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    log "status-flip-preview: stamp missing TIP_FULL/SHORT"
    exit 2
  fi
  if ! { [ "$tip_p" = "$tip_h" ] || [ "$tip_p" = "$cur_tip" ] \
      || { [ "${#tip_p}" -ge 7 ] && [ "${tip_h#"$tip_p"}" != "$tip_h" ]; }; }; then
    log "status-flip-preview FAIL: tip mismatch stamp='$tip_p' HEAD='$tip_h' (short=$cur_tip)"
    log "  re-run min-gate on MSYS2 at this tip, or pull matching tip before preview"
    exit 2
  fi

  # Machine-readable plan (agents/CI). Preview never mutates leaf / Makefile.
  cat <<EOF
PHYS_DEL_STATUS_FLIP_PREVIEW_READY=1
PHYS_DEL_STATUS_FLIP_PREVIEW_WAVE=wave801
PHYS_DEL_STATUS_FLIP_PREVIEW_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_PREVIEW_PROOF_PATH=$path
PHYS_DEL_STATUS_FLIP_PREVIEW_PROOF_RC=0
PHYS_DEL_STATUS_FLIP_PREVIEW_CURRENT_STATUS=${win_status:-?}
PHYS_DEL_STATUS_FLIP_PREVIEW_TARGET=reproven_green
PHYS_DEL_STATUS_FLIP_PREVIEW_APPLIED=0
PHYS_DEL_STATUS_FLIP_PREVIEW_ENDGAME=0
PHYS_DEL_STATUS_FLIP_PREVIEW_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_PREVIEW_NOTE=plan_only_reviewed_mac_commit_required
PHYS_DEL_STATUS_FLIP_PREVIEW_FORBIDDEN=auto_edit_leaf|claim_preview_is_flip|claim_preview_is_delete|set_endgame_1_in_status_flip

# Reviewed mac commit plan (wave802+; NOT applied by this command):
# 1) leaf_pattern_residual.sh dump keys:
#      PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip
#        → PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green
#      keep ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
#      update honesty --check greps that hard-require not_reproven
# 2) phys_del_makefile_gate.sh --check greps: accept reproven_green after flip wave
# 3) progress triad only (自举进度 + C迁移 + Makefile迁移表); LEAF_PATTERN_RESIDUAL.md
# 4) dual-end L2: leaf --check + phys-del --check (mac + Ubuntu)
# 5) physical delete is a SEPARATE wave after STATUS flip; never same commit as flip
# 6) never edit leaf from proof/preview alone; never set ENDGAME=1 in status-flip wave

CURRENT_HOST=$(host_label)
CURRENT_ENDGAME=${endgame:-?}
PROOF_HOST=$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_HOST)
PROOF_UTC=$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_UTC)
EOF
  log "status-flip-preview READY for tip=$cur_tip (proof=$path)"
  log "  TARGET STATUS=reproven_green; ENDGAME stays 0; APPLIED=0 (no leaf edit)"
  log "  next: human-reviewed mac commit for STATUS flip only; then delete wave"
  exit 0
}

cmd_run_windows_gate() {
  local path rc
  path="$(proof_path)"
  if ! is_msys; then
    log "skip --run-windows-gate (host is not MSYS2; dual-boot reboot required)"
    log "cmd: cd repo && ./xbuild phys-del-gate --run-windows-gate"
    log "or:  cd repo && ./$WIN_GATE_REL"
    log "after green on MSYS2 a proof stamp is written to: $path"
    log "then scp to mac and: ./xbuild phys-del-gate --verify-windows-proof"
    exit 0
  fi
  # PLATFORM: WINDOWS — only path that can re-prove hybrid min-gate.
  log "running Windows hybrid min-gate: $WIN_GATE_REL"
  cd "$ROOT"
  set +e
  bash "$WIN_GATE"
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    log "Windows min-gate FAILED rc=$rc — no green proof stamp written"
    exit "$rc"
  fi
  write_proof_stamp "$path" 0
  log "Windows min-gate exit=0 + proof stamp written: $path"
  log "Next: scp proof to mac → ./xbuild phys-del-gate --verify-windows-proof"
  log "Then reviewed mac commit flips PHYS_DEL_WINDOWS_GATE_STATUS; then physical delete wave."
  log "This script does NOT flip leaf keys and does NOT delete Makefile."
}

cmd_verify_windows_proof() {
  # Exit codes: 0 = stamp valid for this tip; 2 = missing/mismatch/bad; 1 = harness error.
  local path tip_p tip_h rc_field
  path="$(proof_path "${1:-}")"
  if [ ! -f "$path" ]; then
    log "verify: no proof stamp at $path"
    log "  on MSYS2: ./xbuild phys-del-gate --run-windows-gate"
    log "  then scp to this host and re-run --verify-windows-proof"
    exit 2
  fi
  if ! grep -qE '^PHYS_DEL_WINDOWS_PROOF=1' "$path"; then
    log "verify: file is not a PHYS_DEL_WINDOWS_PROOF=1 stamp: $path"
    exit 2
  fi
  rc_field="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_RC)"
  if [ "${rc_field:-}" != "0" ]; then
    log "verify: stamp RC field is '${rc_field:-empty}' (need 0)"
    exit 2
  fi
  tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_FULL)"
  tip_h="$(tip_full)"
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_SHORT)"
  fi
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    log "verify: stamp missing TIP_FULL/SHORT"
    exit 2
  fi
  if [ "$tip_p" = "$tip_h" ] || [ "$tip_p" = "$(tip_short)" ] \
      || { [ "${#tip_p}" -ge 7 ] && [ "${tip_h#"$tip_p"}" != "$tip_h" ]; }; then
    log "verify OK: proof tip matches HEAD ($(tip_short)) path=$path"
    log "  NOTE: evidence only — leaf PHYS_DEL_WINDOWS_GATE_STATUS still requires reviewed flip"
    log "  NOTE: does NOT authorize physical delete"
    # Machine-readable success line for agents/CI.
    echo "PHYS_DEL_WINDOWS_PROOF_VERIFY=1"
    echo "PHYS_DEL_WINDOWS_PROOF_VERIFY_TIP=$(tip_short)"
    echo "PHYS_DEL_WINDOWS_PROOF_VERIFY_PATH=$path"
    echo "PHYS_DEL_WINDOWS_PROOF_VERIFY_STATUS_FLIP=0"
    exit 0
  fi
  log "verify FAIL: tip mismatch stamp='$tip_p' HEAD='$tip_h' (short=$(tip_short))"
  log "  re-run min-gate on MSYS2 at this tip, or pull the matching tip before verify"
  exit 2
}

cmd_delete() {
  local win_status endgame
  win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
  endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"

  log "REFUSED physical delete of compiler/Makefile"
  log "  PHYS_DEL_WINDOWS_GATE_STATUS=${win_status:-?}"
  log "  ENDGAME_PHYSICAL_DELETE_MAKEFILE=${endgame:-?}"
  log "  host=$(host_label) is_msys=$(is_msys && echo 1 || echo 0)"
  log "  reason: Windows hybrid min-gate not re-proven on this tip (wave778/798–801)"
  log "  runbook: reboot → MSYS2 → --run-windows-gate → scp proof → --verify → --status-flip-preview → reviewed STATUS flip → delete wave"
  log "  forbidden: delete_makefile_before_windows_green|claim_proof_is_physical_delete|claim_preview_is_delete"

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
  # Hard stop: execute-gate never performs rm. Future delete wave may extend carefully.
  die "execute-gate never rm Makefile (delete body deferred to post-Windows-green wave; proof/preview is not delete)"
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
  --verify-windows-proof|verify-windows-proof|verify-proof)
    cmd_verify_windows_proof "$MODE_ARG2"
    ;;
  --status-flip-preview|status-flip-preview|prepare-status-flip|flip-preview)
    cmd_status_flip_preview "$MODE_ARG2"
    ;;
  --delete|delete)
    cmd_delete
    ;;
  -h|--help|help)
    sed -n '2,50p' "$0"
    ;;
  *)
    die "unknown mode '$MODE' (status|--check|--dry-run-delete|--run-windows-gate|--verify-windows-proof|--status-flip-preview|--delete)"
    ;;
esac
