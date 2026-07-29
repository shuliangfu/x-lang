#!/usr/bin/env bash
# phys_del_makefile_gate.sh — wave799 execute-gate + wave800 proof + wave801 STATUS
# flip prep + wave802 STATUS flip *apply harness* + wave803 STATUS flip *commit
# honesty* (inventory + post-apply contract; tree not flipped on this tip without
# real Windows proof + explicit human confirm).
#
# PLATFORM: SHARED shell orchestration (macOS / Ubuntu / Windows MSYS2).
# Windows min-gate body runs only on MSYS2 (tests/run-bootstrap-bstrict-windows-gate.sh).
#
# Authority (G.7):
#   Single shell authority that *refuses* physical delete of compiler/Makefile
#   until Windows hybrid min-gate is re-proven on this tip. Complements
#   leaf_pattern_residual.sh preflight keys (wave798). Does NOT delete Makefile.
#   STATUS flip of PHYS_DEL_WINDOWS_GATE_STATUS is confirm-gated leaf edit only
#   (wave802); never auto-flip from proof alone; ENDGAME stays 0 on flip.
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
# wave802 (G.7 有则补全 on this script):
#   --status-flip-apply: proof + XLANG_PHYS_DEL_STATUS_FLIP_APPLY confirm env
#   required to rewrite PHYS_DEL_WINDOWS_GATE_STATUS → reproven_green in leaf
#   (or XLANG_PHYS_DEL_LEAF_FILE override for harness tests). Without confirm:
#   refuse (exit 2). Never sets ENDGAME=1. Never rm Makefile. Tree on this tip
#   stays not_reproven unless a human runs apply after real Windows proof.
#
# wave803 (G.7 有则补全 on this script):
#   --status-flip-commit-honesty: machine-readable *commit checklist* for the
#   STATUS flip mac commit (co-change surfaces + post-apply contract). Does NOT
#   edit leaf. Does NOT delete Makefile. Pre-flip (tree not_reproven): inventory
#   only. Post-flip (temp leaf / future tip): require STATUS=reproven_green AND
#   ENDGAME=0 AND --delete still refused. Honesty greps that hard-require
#   not_reproven must co-change in the same flip commit (listed here).
#
# Modes:
#   status | --status          Dump readiness + host + Windows gate honesty + proof
#   --check | check            Machine-check gate wiring + refuse + proof + flip
#   --dry-run-delete           List what physical delete *would* touch; never rm
#   --run-windows-gate         Run min-gate (MSYS2 only; non-MSYS skip exit 0);
#                              on success write proof stamp (wave800)
#   --verify-windows-proof [path]
#                              Verify stamp vs HEAD tip (exit 0 match, 2 no/mismatch)
#   --status-flip-preview [path]
#                              Proof-gated plan for reviewed STATUS flip (wave801);
#                              never edits leaf; exit 0 plan ready, 2 no/bad proof
#   --status-flip-apply [path]
#                              Proof + confirm-gated STATUS key edit (wave802);
#                              without confirm exit 2; ENDGAME stays 0; not delete
#   --status-flip-commit-honesty
#                              Commit checklist / post-apply honesty (wave803);
#                              never edits; never deletes
#   --delete                   HARD refuse unless Windows green + confirm env
#                              (this tip keeps STATUS=not_reproven → always refuse)
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/phys_del_makefile_gate.sh
#   bash compiler/scripts/phys_del_makefile_gate.sh --check
#   bash compiler/scripts/phys_del_makefile_gate.sh --dry-run-delete
#   bash compiler/scripts/phys_del_makefile_gate.sh --verify-windows-proof [/path]
#   bash compiler/scripts/phys_del_makefile_gate.sh --status-flip-preview [/path]
#   bash compiler/scripts/phys_del_makefile_gate.sh --status-flip-apply [/path]
#   bash compiler/scripts/phys_del_makefile_gate.sh --status-flip-commit-honesty
#   ./xbuild phys-del-gate [--check|--dry-run-delete|--run-windows-gate|--verify-windows-proof|--status-flip-preview|--status-flip-apply|--status-flip-commit-honesty]
#
# Env:
#   XLANG_PHYS_DEL_WINDOWS_PROOF=/path/to/proof   default /tmp/xlang_phys_del_windows_proof.txt
#   XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND  (apply path only)
#   XLANG_PHYS_DEL_LEAF_FILE=/path/to/leaf_copy   (test override; default leaf script)
#   XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND  (delete path only; still refused)
#
# Wave: 799–803 Track MG · 11.3.1 · NOT physical delete · tree STATUS still not_reproven
#       · NOT Windows green claim without MSYS proof + reviewed apply

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
# wave802: STATUS flip *apply harness* (proof + confirm env; not delete; tree not auto-flipped)
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_NOTE=proof_and_confirm_gated_leaf_status_edit_not_delete
PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=0
PHYS_DEL_STATUS_FLIP_APPLY_REQUIRES_PROOF=1
PHYS_DEL_STATUS_FLIP_APPLY_REQUIRES_CONFIRM=1
PHYS_DEL_STATUS_FLIP_APPLY_CONFIRM_ENV=XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND
PHYS_DEL_STATUS_FLIP_APPLY_TARGET_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER=0
PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_APPLY_FORBIDDEN=apply_without_proof|apply_without_confirm|set_endgame_1|delete_makefile_from_apply|claim_apply_is_physical_delete|auto_flip_from_proof_alone
# wave803: STATUS flip *commit honesty* (inventory + post-apply contract; not edit; not delete)
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NOTE=commit_checklist_and_post_apply_contract_not_delete
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MODE=--status-flip-commit-honesty
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_TREE_STATUS=${win_status:-?}
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NEXT=msys_proof_then_apply_then_honesty_then_commit_then_delete_wave
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FORBIDDEN=claim_honesty_is_flip|claim_honesty_is_delete|set_endgame_1_in_flip_commit|skip_co_change_honesty_greps|delete_makefile_in_flip_commit
# Human runbook (dual-boot host currently often Ubuntu):
#   PLATFORM: WINDOWS repo root (authoritative, 2026-07-30):
#     C:\Users\shuliangfu\worker\xlang\x-lang
#     Git Bash: /c/Users/shuliangfu/worker/xlang/x-lang
#     FORBIDDEN: worker/shu/shux · worker/shu/xlang (legacy renamed away)
#   SOURCE SYNC: mac git commit+push only → Windows git pull --ff-only
#     (NEVER scp the working tree as project sync)
#   1) reboot dual-boot → Windows/MSYS2 or Git Bash (ssh windows-server)
#   2) cd /c/Users/shuliangfu/worker/xlang/x-lang
#      git pull --ff-only origin self-hosting   # tip must match mac push
#   3) ./xbuild phys-del-gate --run-windows-gate   # writes proof stamp on green
#      or: ./tests/run-bootstrap-bstrict-windows-gate.sh then:
#          XLANG_PHYS_DEL_WINDOWS_PROOF=/tmp/xlang_phys_del_windows_proof.txt \\
#            ./xbuild phys-del-gate --run-windows-gate
#   4) transfer PROOF ARTIFACT only (not source):
#        scp windows-server:/tmp/xlang_phys_del_windows_proof.txt /tmp/
#      or: ssh … 'cat /tmp/xlang_phys_del_windows_proof.txt' > /tmp/…
#   5) mac: ./xbuild phys-del-gate --verify-windows-proof  # tip SHA must match
#   6) mac: ./xbuild phys-del-gate --status-flip-preview   # plan only; no edit
#   7) mac: XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \\
#            ./xbuild phys-del-gate --status-flip-apply     # leaf STATUS only
#   8) mac: ./xbuild phys-del-gate --status-flip-commit-honesty  # wave803 checklist
#      then same commit: honesty greps + progress triad (ENDGAME stays 0)
#   9) NEVER rm compiler/Makefile on this tip while STATUS=not_reproven_this_tip
#  10) NEVER auto-edit leaf from preview / proof alone (confirm env required)
#  11) physical delete is a SEPARATE wave after STATUS flip commit
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
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1' <<<"$dump" \
    || badf "status missing PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1 (wave802)"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802' <<<"$dump" \
    || badf "status missing STATUS_FLIP_APPLY_HARNESS_WAVE=wave802"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=0' <<<"$dump" \
    || badf "status flip apply harness must keep TREE_APPLIED=0 on this tip"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0' <<<"$dump" \
    || badf "status flip apply harness must keep DELETE_ALLOWED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER=0' <<<"$dump" \
    || badf "status flip apply harness must keep ENDGAME_AFTER=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1' <<<"$dump" \
    || badf "status missing PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1 (wave803)"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803' <<<"$dump" \
    || badf "status missing STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0' <<<"$dump" \
    || badf "status flip commit honesty must keep DELETE_ALLOWED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0' <<<"$dump" \
    || badf "status flip commit honesty must keep ENDGAME_REQUIRED=0"

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
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1 (wave802)"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802"
  grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=0' <<<"$leaf" \
    || badf "leaf dump must keep STATUS_FLIP_APPLY_TREE_APPLIED=0"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1 (wave803)"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803' <<<"$leaf" \
    || badf "leaf dump missing PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803"
  grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0' <<<"$leaf" \
    || badf "leaf dump must keep STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0"

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

  # wave802: status-flip-apply — proof + confirm; temp leaf only in harness.
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" \
      --status-flip-apply "/tmp/xlang_phys_del_proof_missing_$$" \
      >/tmp/phys_del_apply_miss.$$ 2>&1; then
    badf "missing proof must not --status-flip-apply exit 0"
  else
    note "missing proof --status-flip-apply non-zero OK (wave802)"
  fi
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-apply "$bad_synth" \
      >/tmp/phys_del_apply_bad.$$ 2>&1; then
    badf "mismatched-tip proof must not --status-flip-apply exit 0"
  else
    note "mismatched-tip proof --status-flip-apply refuses OK (wave802)"
  fi
  # Good proof WITHOUT confirm env → refuse write (exit 2); tree leaf untouched.
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-apply "$synth" \
      >/tmp/phys_del_apply_noconfirm.$$ 2>&1; then
    badf "status-flip-apply without confirm env must not exit 0"
  else
    if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_REFUSED=missing_confirm_env' \
        /tmp/phys_del_apply_noconfirm.$$ 2>/dev/null \
      && ! grep -q 'missing_confirm_env\|APPLY_STATUS_I_UNDERSTAND' \
        /tmp/phys_del_apply_noconfirm.$$ 2>/dev/null; then
      # Still OK if stderr/stdout mention confirm; hard-require non-zero above.
      :
    fi
    note "good proof without confirm --status-flip-apply refuses OK (wave802)"
  fi
  leaf="$(leaf_dump)"
  if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$leaf"; then
    badf "status-flip-apply without confirm must not edit tree leaf STATUS"
  fi
  # Good proof + confirm on TEMP leaf copy only (never real tree).
  leaf_tmp="/tmp/xlang_phys_del_leaf_copy.$$"
  cp "$LEAF_SH" "$leaf_tmp"
  if ! XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \
      XLANG_PHYS_DEL_LEAF_FILE="$leaf_tmp" \
      bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-apply "$synth" \
      >/tmp/phys_del_apply_ok.$$ 2>&1; then
    cat /tmp/phys_del_apply_ok.$$ >&2 || true
    badf "synthetic proof + confirm on temp leaf must --status-flip-apply exit 0"
  else
    # Anchor KEY=value lines — leaf script body also *mentions* these strings in --check greps.
    if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=1' /tmp/phys_del_apply_ok.$$; then
      badf "status-flip-apply must print PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=1"
    elif ! grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green$' "$leaf_tmp"; then
      badf "temp leaf after apply must have STATUS=reproven_green"
    elif ! grep -qE '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=0$' "$leaf_tmp"; then
      badf "temp leaf after apply must keep ENDGAME=0"
    elif grep -qE '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=1$' "$leaf_tmp"; then
      badf "temp leaf after apply must not set ENDGAME=1"
    else
      note "synthetic proof + confirm temp-leaf --status-flip-apply OK (wave802 harness)"
    fi
  fi
  # Real tree leaf must remain not_reproven after harness apply on copy.
  leaf="$(leaf_dump)"
  if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$leaf"; then
    badf "wave802 harness must not leave tree leaf STATUS flipped"
  fi
  if grep -qE 'PHYS_DEL_WINDOWS_GATE_STATUS=green|PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green' <<<"$leaf"; then
    badf "wave802 harness mutated tree leaf toward green (forbidden)"
  fi

  # wave803: commit honesty — pre-flip inventory on tree; post-flip contract on temp leaf.
  if ! bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-commit-honesty \
      >/tmp/phys_del_hon_pre.$$ 2>&1; then
    cat /tmp/phys_del_hon_pre.$$ >&2 || true
    badf "tree --status-flip-commit-honesty must exit 0 (pre-flip inventory)"
  else
    if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=pre_flip' /tmp/phys_del_hon_pre.$$; then
      badf "pre-flip honesty must print PHASE=pre_flip"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CO_CHANGE=1' /tmp/phys_del_hon_pre.$$; then
      badf "pre-flip honesty must list CO_CHANGE surfaces"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0' /tmp/phys_del_hon_pre.$$; then
      badf "pre-flip honesty must keep DELETE_ALLOWED=0"
    else
      note "tree pre-flip --status-flip-commit-honesty OK (wave803 harness)"
    fi
  fi
  # Post-flip contract on the temp leaf already flipped by wave802 harness above.
  # Re-apply if leaf_tmp was cleaned early: rebuild temp green leaf for honesty.
  if [ ! -f "$leaf_tmp" ] || ! grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green$' "$leaf_tmp" 2>/dev/null; then
    leaf_tmp="/tmp/xlang_phys_del_leaf_copy.$$"
    cp "$LEAF_SH" "$leaf_tmp"
    if ! XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \
        XLANG_PHYS_DEL_LEAF_FILE="$leaf_tmp" \
        bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-apply "$synth" \
        >/tmp/phys_del_apply_ok2.$$ 2>&1; then
      cat /tmp/phys_del_apply_ok2.$$ >&2 || true
      badf "wave803 rebuild temp apply failed (need green leaf for post-flip honesty)"
    fi
  fi
  if ! XLANG_PHYS_DEL_LEAF_FILE="$leaf_tmp" \
      bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --status-flip-commit-honesty \
      >/tmp/phys_del_hon_post.$$ 2>&1; then
    cat /tmp/phys_del_hon_post.$$ >&2 || true
    badf "post-flip temp leaf --status-flip-commit-honesty must exit 0"
  else
    if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=post_flip' /tmp/phys_del_hon_post.$$; then
      badf "post-flip honesty must print PHASE=post_flip"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_POST_OK=1' /tmp/phys_del_hon_post.$$; then
      badf "post-flip honesty must print POST_OK=1"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME=0' /tmp/phys_del_hon_post.$$; then
      badf "post-flip honesty must keep ENDGAME=0"
    elif ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_STILL_REFUSED=1' /tmp/phys_del_hon_post.$$; then
      badf "post-flip honesty must keep DELETE_STILL_REFUSED=1"
    else
      note "temp post-flip --status-flip-commit-honesty OK (wave803 harness)"
    fi
  fi
  # Honesty mode must not mutate tree STATUS.
  leaf="$(leaf_dump)"
  if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$leaf"; then
    badf "wave803 honesty must not flip tree leaf STATUS"
  fi

  rm -f "$synth" "$bad_synth" "$leaf_tmp" /tmp/phys_del_vfy_ok.$$ /tmp/phys_del_vfy_bad.$$ \
    /tmp/phys_del_vfy_miss.$$ /tmp/phys_del_flip_miss.$$ /tmp/phys_del_flip_bad.$$ \
    /tmp/phys_del_flip_ok.$$ /tmp/phys_del_apply_miss.$$ /tmp/phys_del_apply_bad.$$ \
    /tmp/phys_del_apply_noconfirm.$$ /tmp/phys_del_apply_ok.$$ /tmp/phys_del_apply_ok2.$$ \
    /tmp/phys_del_hon_pre.$$ /tmp/phys_del_hon_post.$$

  # Non-MSYS: windows-gate script skip path must be honest (exit 0 skip).
  if ! is_msys; then
    note "host=$(host_label) — Windows min-gate not run here (expected dual-boot)"
  fi

  if [ "$bad" -ne 0 ]; then
    echo "phys-del-makefile-gate: CHECK FAILED" >&2
    exit 1
  fi
  echo "phys-del-makefile-gate: CHECK OK (wave799 execute-gate + wave800 proof + wave801 status-flip-prep + wave802 status-flip-apply + wave803 commit-honesty harness; refuse-delete; not Windows green; tree STATUS not flipped; not physical delete)"
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
  → XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND --status-flip-apply
  → --status-flip-commit-honesty (wave803 checklist + co-change greps)
  → commit STATUS flip (ENDGAME=0) → separate delete wave
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

# Reviewed mac path (wave802 apply harness; NOT run by preview):
# 1) XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND \\
#      ./xbuild phys-del-gate --status-flip-apply
#    → leaf PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip → reproven_green
#    → keep ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
# 2) update honesty --check greps that hard-require not_reproven (same flip commit)
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
  log "  next: --status-flip-apply with confirm env (wave802) → commit; then delete wave"
  exit 0
}

# wave802: proof + confirm-gated STATUS key edit. Never sets ENDGAME=1. Never rm Makefile.
# Exit: 0 = applied (or already green); 2 = missing/bad proof or missing confirm; 1 = harness error.
cmd_status_flip_apply() {
  local path tip_p tip_h rc_field win_status endgame cur_tip leaf_target tmp
  path="$(proof_path "${1:-}")"
  win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
  endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"
  cur_tip="$(tip_short)"
  leaf_target="${XLANG_PHYS_DEL_LEAF_FILE:-$LEAF_SH}"

  if [ ! -f "$path" ]; then
    log "status-flip-apply: no proof stamp at $path"
    log "  on MSYS2: ./xbuild phys-del-gate --run-windows-gate"
    log "  then scp + --verify-windows-proof + --status-flip-preview first"
    exit 2
  fi
  if ! grep -qE '^PHYS_DEL_WINDOWS_PROOF=1' "$path"; then
    log "status-flip-apply: file is not a PHYS_DEL_WINDOWS_PROOF=1 stamp: $path"
    exit 2
  fi
  rc_field="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_RC)"
  if [ "${rc_field:-}" != "0" ]; then
    log "status-flip-apply: stamp RC field is '${rc_field:-empty}' (need 0)"
    exit 2
  fi
  tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_FULL)"
  tip_h="$(tip_full)"
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    tip_p="$(proof_get "$path" PHYS_DEL_WINDOWS_PROOF_TIP_SHORT)"
  fi
  if [ -z "$tip_p" ] || [ "$tip_p" = "unknown" ]; then
    log "status-flip-apply: stamp missing TIP_FULL/SHORT"
    exit 2
  fi
  if ! { [ "$tip_p" = "$tip_h" ] || [ "$tip_p" = "$cur_tip" ] \
      || { [ "${#tip_p}" -ge 7 ] && [ "${tip_h#"$tip_p"}" != "$tip_h" ]; }; }; then
    log "status-flip-apply FAIL: tip mismatch stamp='$tip_p' HEAD='$tip_h' (short=$cur_tip)"
    log "  re-run min-gate on MSYS2 at this tip, or pull matching tip before apply"
    exit 2
  fi

  # Proof OK — still refuse write without explicit confirm (never auto-flip from proof).
  if [ "${XLANG_PHYS_DEL_STATUS_FLIP_APPLY:-}" != "APPLY_STATUS_I_UNDERSTAND" ]; then
    cat <<EOF
PHYS_DEL_STATUS_FLIP_APPLY_READY=1
PHYS_DEL_STATUS_FLIP_APPLY_WAVE=wave802
PHYS_DEL_STATUS_FLIP_APPLY_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_APPLY_PROOF_PATH=$path
PHYS_DEL_STATUS_FLIP_APPLY_PROOF_RC=0
PHYS_DEL_STATUS_FLIP_APPLY_CURRENT_STATUS=${win_status:-?}
PHYS_DEL_STATUS_FLIP_APPLY_TARGET=reproven_green
PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=0
PHYS_DEL_STATUS_FLIP_APPLY_REFUSED=missing_confirm_env
PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME=0
PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_APPLY_LEAF_TARGET=$leaf_target
PHYS_DEL_STATUS_FLIP_APPLY_NOTE=set_XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND
PHYS_DEL_STATUS_FLIP_APPLY_FORBIDDEN=apply_without_confirm|set_endgame_1|delete_makefile_from_apply
EOF
    log "status-flip-apply REFUSED: missing confirm env (proof OK tip=$cur_tip)"
    log "  set XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND to edit leaf STATUS only"
    log "  ENDGAME stays 0; not physical delete; tree not edited"
    exit 2
  fi

  if [ ! -f "$leaf_target" ]; then
    die "status-flip-apply: leaf file missing: $leaf_target"
  fi

  # Idempotent: already green in target leaf.
  if grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green$' "$leaf_target" \
    && ! grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip$' "$leaf_target"; then
    cat <<EOF
PHYS_DEL_STATUS_FLIP_APPLY_READY=1
PHYS_DEL_STATUS_FLIP_APPLY_WAVE=wave802
PHYS_DEL_STATUS_FLIP_APPLY_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_APPLY_PROOF_PATH=$path
PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=1
PHYS_DEL_STATUS_FLIP_APPLY_ALREADY=1
PHYS_DEL_STATUS_FLIP_APPLY_NEW_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME=0
PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_APPLY_LEAF_TARGET=$leaf_target
EOF
    log "status-flip-apply: already reproven_green in $leaf_target (idempotent)"
    exit 0
  fi

  if ! grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip$' "$leaf_target"; then
    die "status-flip-apply: leaf lacks PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip ($leaf_target)"
  fi

  tmp="${leaf_target}.phys_del_status_flip.$$"
  # PLATFORM: SHARED — only the STATUS line; never touch ENDGAME in this path.
  sed 's/^PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip$/PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green/' \
    "$leaf_target" >"$tmp" || {
    rm -f "$tmp"
    die "status-flip-apply: sed rewrite failed"
  }
  if ! grep -qE '^PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green$' "$tmp"; then
    rm -f "$tmp"
    die "status-flip-apply: STATUS flip did not take effect"
  fi
  if ! grep -qE '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=0$' "$tmp"; then
    rm -f "$tmp"
    die "status-flip-apply safety: ENDGAME must remain 0 after STATUS flip"
  fi
  if grep -qE '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=1$' "$tmp"; then
    rm -f "$tmp"
    die "status-flip-apply safety: must not set ENDGAME=1"
  fi
  mv "$tmp" "$leaf_target"

  cat <<EOF
PHYS_DEL_STATUS_FLIP_APPLY_READY=1
PHYS_DEL_STATUS_FLIP_APPLY_WAVE=wave802
PHYS_DEL_STATUS_FLIP_APPLY_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_APPLY_PROOF_PATH=$path
PHYS_DEL_STATUS_FLIP_APPLY_PROOF_RC=0
PHYS_DEL_STATUS_FLIP_APPLY_PREV_STATUS=not_reproven_this_tip
PHYS_DEL_STATUS_FLIP_APPLY_NEW_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_APPLY_APPLIED=1
PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME=0
PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_APPLY_LEAF_TARGET=$leaf_target
PHYS_DEL_STATUS_FLIP_APPLY_NOTE=commit_leaf_on_mac_then_separate_delete_wave
PHYS_DEL_STATUS_FLIP_APPLY_FORBIDDEN=set_endgame_1|delete_makefile_in_same_commit_as_flip
EOF
  log "status-flip-apply APPLIED STATUS=reproven_green leaf=$leaf_target tip=$cur_tip"
  log "  ENDGAME stays 0; DELETE is a separate wave; commit this leaf edit on mac only"
  log "  next: ./xbuild phys-del-gate --status-flip-commit-honesty (wave803) then commit"
  exit 0
}

# wave803: STATUS flip *commit honesty* — inventory + post-apply contract.
# Never edits leaf. Never deletes Makefile.
# Exit: 0 = pre_flip inventory ready OR post_flip contract OK; 1 = contract fail.
cmd_status_flip_commit_honesty() {
  local win_status endgame leaf_target cur_tip del_refused
  leaf_target="${XLANG_PHYS_DEL_LEAF_FILE:-$LEAF_SH}"
  cur_tip="$(tip_short)"

  if [ ! -f "$leaf_target" ]; then
    die "status-flip-commit-honesty: leaf file missing: $leaf_target"
  fi

  # Prefer KEY=value lines from the leaf *file* (supports temp flipped copies).
  win_status="$(grep -E '^PHYS_DEL_WINDOWS_GATE_STATUS=' "$leaf_target" | head -1 | sed 's/^PHYS_DEL_WINDOWS_GATE_STATUS=//' || true)"
  endgame="$(grep -E '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=' "$leaf_target" | head -1 | sed 's/^ENDGAME_PHYSICAL_DELETE_MAKEFILE=//' || true)"

  # --delete must still hard-refuse after STATUS flip while ENDGAME=0.
  del_refused=0
  if bash "$SCRIPT_DIR/phys_del_makefile_gate.sh" --delete \
      >/tmp/phys_del_hon_del_out.$$ 2>/tmp/phys_del_hon_del_err.$$; then
    del_refused=0
  else
    del_refused=1
  fi
  rm -f /tmp/phys_del_hon_del_out.$$ /tmp/phys_del_hon_del_err.$$

  if [ "${win_status:-}" = "not_reproven_this_tip" ]; then
    # Pre-flip: print commit checklist only (tree honesty greps still require not_reproven).
    cat <<EOF
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_READY=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=pre_flip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_LEAF=$leaf_target
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CURRENT_STATUS=${win_status:-?}
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_TARGET_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME=${endgame:-?}
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_STILL_REFUSED=$del_refused
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CO_CHANGE=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CO_CHANGE_LIST=compiler/scripts/leaf_pattern_residual.sh|compiler/scripts/phys_del_makefile_gate.sh|--check_greps_hard_require_not_reproven|analysis/自举进度.md|analysis/C迁移追踪.md|analysis/Makefile迁移表.md|compiler/docs/LEAF_PATTERN_RESIDUAL.md
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MUST_UPDATE=PHYS_DEL_WINDOWS_GATE_STATUS→reproven_green|PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED→1|honesty_--check_expect_reproven_green|progress_triad_wave_note
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MUST_NOT=ENDGAME_PHYSICAL_DELETE_MAKEFILE=1|rm_compiler/Makefile|claim_physical_delete_done|skip_dual_end_L2
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NOTE=run_apply_then_same_commit_update_honesty_greps_ENDGAME_stays_0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FORBIDDEN=claim_honesty_is_flip|claim_honesty_is_delete|set_endgame_1_in_flip_commit|delete_makefile_in_flip_commit
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NEXT=msys_proof_then_apply_then_this_mode_then_commit_then_delete_wave
EOF
    log "status-flip-commit-honesty PHASE=pre_flip tip=$cur_tip (inventory only; no edit)"
    log "  flip commit must co-change honesty greps that hard-require not_reproven"
    log "  ENDGAME stays 0; physical delete is a SEPARATE wave"
    if [ "$del_refused" -ne 1 ]; then
      die "pre-flip honesty: --delete must still refuse (got exit 0)"
    fi
    exit 0
  fi

  if [ "${win_status:-}" = "reproven_green" ]; then
    # Post-flip contract (temp leaf after apply, or future tip after real apply).
    if [ "${endgame:-}" != "0" ]; then
      cat <<EOF
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_READY=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=post_flip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_POST_OK=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FAIL=endgame_not_0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME=${endgame:-?}
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
EOF
      log "status-flip-commit-honesty FAIL: ENDGAME must stay 0 after STATUS flip (got '${endgame:-empty}')"
      exit 1
    fi
    if [ "$del_refused" -ne 1 ]; then
      cat <<EOF
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_READY=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=post_flip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_POST_OK=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FAIL=delete_not_refused
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
EOF
      log "status-flip-commit-honesty FAIL: --delete must still refuse while ENDGAME=0"
      exit 1
    fi
    cat <<EOF
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_READY=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_PHASE=post_flip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_POST_OK=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_TIP=$cur_tip
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_LEAF=$leaf_target
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_STILL_REFUSED=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CO_CHANGE=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_CO_CHANGE_LIST=compiler/scripts/leaf_pattern_residual.sh|compiler/scripts/phys_del_makefile_gate.sh|--check_greps_hard_require_not_reproven|analysis/自举进度.md|analysis/C迁移追踪.md|analysis/Makefile迁移表.md|compiler/docs/LEAF_PATTERN_RESIDUAL.md
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MUST_UPDATE=PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED→1|honesty_--check_expect_reproven_green|progress_triad_wave_note
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MUST_NOT=ENDGAME_PHYSICAL_DELETE_MAKEFILE=1|rm_compiler/Makefile|claim_physical_delete_done|same_commit_as_physical_delete
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NOTE=STATUS_green_ENDGAME_0_delete_still_refused_commit_honesty_greps_then_separate_delete_wave
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FORBIDDEN=set_endgame_1_in_flip_commit|delete_makefile_in_flip_commit|claim_honesty_is_delete
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NEXT=commit_then_separate_physical_delete_wave
EOF
    log "status-flip-commit-honesty PHASE=post_flip POST_OK=1 tip=$cur_tip leaf=$leaf_target"
    log "  STATUS=reproven_green ENDGAME=0 --delete still refused (expected)"
    log "  same commit must update honesty greps + progress triad; then SEPARATE delete wave"
    exit 0
  fi

  log "status-flip-commit-honesty: unexpected STATUS='${win_status:-empty}' in $leaf_target"
  log "  expected not_reproven_this_tip (pre_flip) or reproven_green (post_flip)"
  exit 1
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
  local win_status endgame leaf_target
  # wave803: honor XLANG_PHYS_DEL_LEAF_FILE so post-flip honesty can prove
  # STATUS=reproven_green + ENDGAME=0 still refuses delete (temp leaf copies).
  leaf_target="${XLANG_PHYS_DEL_LEAF_FILE:-$LEAF_SH}"
  if [ -f "$leaf_target" ]; then
    win_status="$(grep -E '^PHYS_DEL_WINDOWS_GATE_STATUS=' "$leaf_target" | head -1 | sed 's/^PHYS_DEL_WINDOWS_GATE_STATUS=//' || true)"
    endgame="$(grep -E '^ENDGAME_PHYSICAL_DELETE_MAKEFILE=' "$leaf_target" | head -1 | sed 's/^ENDGAME_PHYSICAL_DELETE_MAKEFILE=//' || true)"
  else
    win_status="$(leaf_get PHYS_DEL_WINDOWS_GATE_STATUS)"
    endgame="$(leaf_get ENDGAME_PHYSICAL_DELETE_MAKEFILE)"
  fi

  log "REFUSED physical delete of compiler/Makefile"
  log "  PHYS_DEL_WINDOWS_GATE_STATUS=${win_status:-?}"
  log "  ENDGAME_PHYSICAL_DELETE_MAKEFILE=${endgame:-?}"
  log "  host=$(host_label) is_msys=$(is_msys && echo 1 || echo 0)"
  log "  reason: Windows hybrid min-gate not re-proven on this tip (wave778/798–803)"
  log "  runbook: reboot → MSYS2 → --run-windows-gate → scp proof → --verify → --status-flip-preview → confirm --status-flip-apply → commit-honesty → commit → delete wave"
  log "  forbidden: delete_makefile_before_windows_green|claim_proof_is_physical_delete|claim_preview_is_delete|claim_apply_is_physical_delete|claim_honesty_is_delete"

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
  --status-flip-apply|status-flip-apply|apply-status-flip|flip-apply)
    cmd_status_flip_apply "$MODE_ARG2"
    ;;
  --status-flip-commit-honesty|status-flip-commit-honesty|commit-honesty|flip-commit-honesty)
    cmd_status_flip_commit_honesty
    ;;
  --delete|delete)
    cmd_delete
    ;;
  -h|--help|help)
    sed -n '2,80p' "$0"
    ;;
  *)
    die "unknown mode '$MODE' (status|--check|--dry-run-delete|--run-windows-gate|--verify-windows-proof|--status-flip-preview|--status-flip-apply|--status-flip-commit-honesty|--delete)"
    ;;
esac
