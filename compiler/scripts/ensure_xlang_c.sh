#!/usr/bin/env bash
# ensure_xlang_c.sh — product xlang-c alias from bootstrap_xlangc (default non-LEGACY path)
#
# Authority (G.7 无才新增):
#   Default product $(XLANG_C) is a sync copy of ./bootstrap_xlangc (G-06 seed).
#   Historic dual body lived inline in Makefile:
#     if [ -z "$XLANG_SKIP_SUBSCRIPT_MAKE" ]; then cp -f bootstrap_xlangc $@; else echo skip; fi
#   LEGACY host-cc link stays scripts/legacy_xlang_c_link.sh (wave858) — different path
#   (XLANG_LEGACY_C_FRONTEND=1). select_bootstrap_xlangc.sh owns seed pick only
#   (bootstrap_xlangc target). ensure_cp_alias_o.sh owns .o path aliases — not binaries.
#
#   What this owns:
#     1) Honor XLANG_SKIP_SUBSCRIPT_MAKE=1 (soft-skip cp; preserve real C frontend)
#     2) Require SRC=bootstrap_xlangc (or env SRC) then cp -f → OUT (XLANG_C)
#     3) --check honesty: Makefile default $(XLANG_C) thin-calls this script
#
#   Why shell-primary (not physical delete)?
#     bootstrap_xlangc prereq + LEGACY ifeq graph still make residual; this is only
#     the default-path sync body. Thin edges + B2 + mk lists remain residual.
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_xlang_c.sh ensure
#   bash scripts/ensure_xlang_c.sh ensure xlang-c
#   bash scripts/ensure_xlang_c.sh ensure $@   # Makefile thin-call (wave887)
#   bash scripts/ensure_xlang_c.sh --check
#
# Env / args:
#   OUT arg ($2) or XLANG_C — output binary name (default: xlang-c)
#   SRC — source seed binary (default: bootstrap_xlangc)
#   XLANG_SKIP_SUBSCRIPT_MAKE=1 — skip cp (historic run-all C frontend preserve)
#
# wave876 (G.7 无才新增): Makefile fat if/cp body → this script.
# wave887 (G.7 有则补全): Makefile drops XLANG_C= inject; OUT from ensure $@.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — binary sync only; ABI / seed pick stays select_bootstrap_xlangc.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-ensure}"
OUT_ARG="${2:-}"

log() { echo "ensure-xlang-c: $*" >&2; }
fail() { echo "ensure-xlang-c: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Default non-LEGACY recipe: target is $(XLANG_C) literally in Makefile text.
  _rec=$(awk '
    /^\$\(XLANG_C\):/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'ensure_xlang_c\.sh' <<<"$_rec"; then
    fail '$(XLANG_C) must thin-call ensure_xlang_c.sh (wave876)'
  fi
  # Dual body: inline if/cp SKIP_SUBSCRIPT gate (shell owns).
  if grep -qE 'cp -f bootstrap_xlangc|XLANG_SKIP_SUBSCRIPT_MAKE' <<<"$_rec"; then
    fail '$(XLANG_C) must not keep dual if/cp SKIP_SUBSCRIPT body (wave876; shell owns)'
  fi
  if grep -qE 'if \[ -z ' <<<"$_rec"; then
    fail '$(XLANG_C) must not keep dual if-body (wave876; shell owns)'
  fi
  # wave887: no XLANG_C= recipe inject — OUT via ensure $@ (or env/CLI).
  if grep -qE 'XLANG_C=' <<<"$_rec"; then
    fail '$(XLANG_C) must not inject XLANG_C= (wave887; shell OUT=$@ / XLANG_C default)'
  fi
  # LEGACY path must remain wave858 shell (do not re-open host-cc here).
  if ! grep -q 'legacy_xlang_c_link\.sh' "$MF"; then
    fail "Makefile must keep legacy_xlang_c_link.sh for LEGACY path (wave858)"
  fi
  echo "ensure_xlang_c: --check OK (wave876/887; shell-primary default xlang-c alias; not physical delete)"
  exit 0
fi

case "$MODE" in
  ensure|run|"")
    ;;
  *)
    echo "usage: $0 {ensure|--check} [OUT]" >&2
    exit 2
    ;;
esac

OUT="${OUT_ARG:-${XLANG_C:-xlang-c}}"
SRC="${SRC:-bootstrap_xlangc}"

# Historic make soft-skip: run-all may build real C frontend then set
# XLANG_SKIP_SUBSCRIPT_MAKE=1 so this recipe does not overwrite xlang-c.
if [ -n "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  log "SKIP: XLANG_SKIP_SUBSCRIPT_MAKE=${XLANG_SKIP_SUBSCRIPT_MAKE} (preserve real C frontend at ./$OUT)"
  exit 0
fi

if [ ! -e "./$SRC" ] && [ ! -e "$SRC" ]; then
  fail "missing source $SRC (run make bootstrap_xlangc / select_bootstrap_xlangc first)"
fi

# Prefer cwd-relative product names (historic: cp -f bootstrap_xlangc $@).
_src="$SRC"
[ -e "./$SRC" ] && _src="./$SRC"
_out="$OUT"
case "$OUT" in
  /*) _out="$OUT" ;;
  *) _out="./$OUT" ;;
esac

cp -f "$_src" "$_out"
# PLATFORM: SHARED — keep executable bit when host umask strips it from cp.
chmod +x "$_out" 2>/dev/null || true
log "synced $_out ← $_src"
