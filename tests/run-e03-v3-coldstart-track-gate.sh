#!/usr/bin/env bash
# E-03 v3: cold-start track — G-06 bootstrap_xlangc + G-02a SEED omit C frontend
# vs default DRIVER_SEED (mk). Honesty: soft XLANG_E03_V3_FAIL + top-level
# DOC/Makefile anchors retired — those were portable false-green after
# MG wave941 archive (missing DOC / deleted Makefile → soft die→exit0).
#
# Usage: ./tests/run-e03-v3-coldstart-track-gate.sh
# Env:
#   XLANG_E03_V3_MANIFEST_ONLY=1  — manifest + static checks only (no C-06)
#
# Live authority: archive DOC + build_xlang_asm.sh + bootstrap_xlangc_create.sh
# + mk/driver_seed_*.mk + ./xbuild (refuse compiler/Makefile resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-e-e03-v3-coldstart.md"
MF="tests/baseline/e03-coldstart-track.tsv"
BUILD="compiler/scripts/build_xlang_asm.sh"
BOOT_CREATE="compiler/scripts/bootstrap_xlangc_create.sh"
MK_COMPOSITES="compiler/mk/driver_seed_composites.mk"
MK_MODE="compiler/mk/driver_seed_mode_objs.mk"
XBUILD_SH="xlang-build.sh"
PREFIX="xlang: [XLANG_E03_V3]"

die() {
  echo "e03-v3 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} g06=${G06_OK:-0} seed=${SEED_OK:-0} mk=${MK_OK:-0} c06=${C06_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
G06_OK=0
SEED_OK=0
MK_OK=0
C06_OK=0
SKIP=1

echo "=== E-03 v3: cold-start / SEED track (honesty; archive DOC) ==="
# Refuse top-level DOC resurrect (live = archive/phase/).
if [ -f analysis/phase-e-e03-v3-coldstart.md ]; then
  die "top-level analysis/phase-e-e03-v3-coldstart.md resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use mk/driver_seed_*.mk + ./xbuild)"
fi

for f in "$DOC" "$MF" "$BUILD" "$BOOT_CREATE" "$MK_COMPOSITES" "$MK_MODE" "$XBUILD_SH"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'E-03 v3' "$DOC" || die "doc missing E-03 v3 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
DOC_OK=1

# G-06 cold start: bootstrap_xlangc create script + seed binary (or live asm/xlang).
[ -f "$BOOT_CREATE" ] || die "missing bootstrap_xlangc_create.sh"
if [ ! -x compiler/bootstrap_xlangc ] && [ ! -x compiler/xlang_asm ] && [ ! -x compiler/xlang ]; then
  die "need bootstrap_xlangc or xlang_asm/xlang for G-06 cold start"
fi
G06_OK=1
echo "e03-v3 track OK: G-06 bootstrap_xlangc cold start"

# G-02a: default SEED omit C frontend (X *_x.o path).
grep -q 'ensure_asm_driver_seed_c_objs' "$BUILD" || die "build_xlang_asm missing ensure_asm_driver_seed_c_objs"
grep -q 'ensure_asm_driver_seed_frontend_c_objs' "$BUILD" || die "build_xlang_asm missing ensure_asm_driver_seed_frontend_c_objs"
grep -q 'G-02a: omit C frontend seed' "$BUILD" || die "build_xlang_asm missing G-02a omit marker"
grep -q 'asm_seed_omit_c_frontend_seed' "$BUILD" || die "build_xlang_asm missing asm_seed_omit_c_frontend_seed"
SEED_OK=1
echo "e03-v3 track OK: G-02a SEED omit C frontend"

# Default DRIVER_SEED must not embed C frontend .o (live mk; Makefile retired).
grep -q 'DRIVER_SEED_X_FRONTEND_OBJS' "$MK_COMPOSITES" || die "mk missing DRIVER_SEED_X_FRONTEND_OBJS"
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MK_COMPOSITES" | grep -qE 'src/parser/parser\.o|src/lexer/lexer\.o|ast_seed\.o|preprocess_for_driver\.o'; then
  die "DRIVER_SEED_OBJS still embeds C frontend / soft-retired seed .o"
fi
MK_OK=1
echo "e03-v3 contrast OK: DRIVER_SEED_OBJS absent C frontend (mk)"

audit_track() {
  local id="$1" path="$2" expect_in="$3"
  case "$expect_in" in
    bootstrap_xlangc)
      case "$path" in
        *bootstrap_xlangc_create*) [ -f "$BOOT_CREATE" ] || die "$id: missing bootstrap_xlangc_create.sh" ;;
        *bootstrap_xlangc)
          if [ ! -x compiler/bootstrap_xlangc ] && [ ! -x compiler/xlang_asm ] && [ ! -x compiler/xlang ]; then
            die "$id: need bootstrap_xlangc or xlang_asm to create seed"
          fi
          ;;
        *) die "$id: unknown bootstrap_xlangc path $path" ;;
      esac
      echo "e03-v3 track OK: $id G-06 bootstrap_xlangc cold start"
      ;;
    SEED_OMIT)
      if grep -q 'ensure_asm_driver_seed_frontend_c_objs' "$BUILD" \
        && ! grep -q 'G-02a: omit C frontend seed' "$BUILD" 2>/dev/null; then
        die "$id: build_xlang_asm still compiles frontend .c without G-02a omit"
      fi
      echo "e03-v3 track OK: $id SEED omit C frontend (G-02a)"
      ;;
    absent)
      # path holds the fossil .o name that must stay out of DRIVER_SEED_OBJS.
      if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MK_COMPOSITES" | grep -qF "$path"; then
        die "$id: DRIVER_SEED_OBJS still hardcodes $path (expected absent; use *_LINK_O / *_x.o)"
      fi
      echo "e03-v3 contrast OK: $id absent from DRIVER_SEED_OBJS (mk)"
      ;;
    *)
      die "$id: unknown expect_in $expect_in"
      ;;
  esac
}

MISS=0
while IFS=$'\t' read -r track_id layer path check_type expect_in notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in
    grep)
      case "$path" in
        analysis/phase-e-e03-v3-coldstart.md|compiler/Makefile)
          # Archived DOC / retired Makefile — live checks above.
          continue
          ;;
      esac
      [ -f "$path" ] || { echo "e03-v3 missing: $path" >&2; MISS=$((MISS + 1)); continue; }
      # expect_in column carries the grep needle when check_type=grep
      needle="${expect_in:-$notes}"
      grep -q "$needle" "$path" || { echo "e03-v3 grep fail: $path need '$needle'" >&2; MISS=$((MISS + 1)); }
      ;;
    gate_ref)
      [ -f "$path" ] || { echo "e03-v3 missing gate: $path" >&2; MISS=$((MISS + 1)); }
      ;;
    track-only)
      audit_track "$track_id" "$path" "$expect_in" || MISS=$((MISS + 1))
      ;;
    absent)
      # TSV: path=DRIVER_SEED_OBJS (label), expect_in=fossil .o name
      audit_track "$track_id" "$expect_in" "absent" || MISS=$((MISS + 1))
      ;;
    *)
      echo "e03-v3 unknown check_type: $check_type ($track_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MF"

[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"

if [ "${XLANG_E03_V3_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "e03-v3 coldstart track gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} g06=${G06_OK} seed=${SEED_OK} mk=${MK_OK} c06=${C06_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== E-03 v3: delegate C-06 x frontend default (contrast; hard) ==="
chmod +x tests/run-c06-x-frontend-default-gate.sh
./tests/run-c06-x-frontend-default-gate.sh || die "C-06 delegate failed"
C06_OK=1
SKIP=0

echo "e03-v3 coldstart track gate OK (G-06／G-02a／mk DRIVER_SEED; soft FAIL retired)"
echo "${PREFIX} status=ok doc=${DOC_OK} g06=${G06_OK} seed=${SEED_OK} mk=${MK_OK} c06=${C06_OK} skip=${SKIP} host=$(ci_host_summary)"
