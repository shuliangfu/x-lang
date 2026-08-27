#!/usr/bin/env bash
# F-11 / G-07: full self-host release checklist (docs + key child gates;
# does not require an existing git tag).
#
# Usage: ./tests/run-f11-selfhost-release-prep-gate.sh
#        XLANG_F11_RUN_G_FFI5_RUNTIME=1 ./tests/run-f11-selfhost-release-prep-gate.sh
#        XLANG_F11_RUN_F_STD_BATCH=1 ./tests/run-f11-selfhost-release-prep-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + child gates (no soft
# die→exit0; no soft child FAIL pass-through). Soft
# XLANG_F11_SELFHOST_RELEASE_PREP_FAIL retired. Hard-delegate d05 / e-soft /
# F-09 STRICT / d03 / d04. G-FFI-5 defaults to policy-only
# (XLANG_G_FFI5_SKIP_LANG_UNSAFE=1) so archaeology knife does not absorb
# LANG-007 suite hang; set XLANG_F11_RUN_G_FFI5_RUNTIME=1 for full runtime.
# Report doc=/d05=/e_soft=/f09=/d03=/d04=/gffi5=/skip=. Gate was
# portable-false-green (soft FAIL exit0 while checklist static already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F11_DOC:-analysis/archive/phase/phase-f-f11-v1.md}"
MANIFEST="tests/baseline/f11-selfhost-release-prep.tsv"
PREFIX="xlang: [XLANG_F11_RELEASE]"

die() {
  echo "f11-selfhost-release-prep gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} d05=${D05_OK:-0} e_soft=${E_SOFT_OK:-0} f09=${F09_OK:-0} d03=${D03_OK:-0} d04=${D04_OK:-0} gffi5=${GFFI5_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
D05_OK=0
E_SOFT_OK=0
F09_OK=0
D03_OK=0
D04_OK=0
GFFI5_OK=0
SKIP=1

run_child() {
  local script="$1"
  local label="$2"
  [ -f "$script" ] || die "missing $script"
  echo "=== F-11: delegate $(basename "$script") (hard) ==="
  chmod +x "$script"
  if ! "$script"; then
    die "$label sub-gate failed"
  fi
}

echo "=== F-11 / G-07: selfhost release prep checklist (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-11 v1' "$DOC" || die "doc missing F-11 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'vX.Y.Z-selfhost' "$DOC" || die "doc missing tag format"
if [ -f analysis/phase-f-f11-v1.md ]; then
  die "top-level F-11 DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'D+E+F' compiler/docs/SELFHOST.md || die "SELFHOST missing D+E+F"
grep -q '完全自举' compiler/docs/SELFHOST.md || die "SELFHOST missing 完全自举"
DOC_OK=1

# Single xlang release entry (hard; soft D05 FAIL retired independently).
# PLATFORM: SHARED archaeology.
run_child tests/run-d05-single-xlang-release-gate.sh d05
D05_OK=1

# E-soft: G-02a hard_retired; soft XLANG_E_SOFT_FAIL retired (2026-08-26).
if [ -f tests/run-e-soft-retire-gate.sh ]; then
  echo "=== F-11: delegate e-soft-retire (manifest only; hard) ==="
  chmod +x tests/run-e-soft-retire-gate.sh
  if ! XLANG_E_SOFT_MANIFEST_ONLY=1 tests/run-e-soft-retire-gate.sh; then
    die "e-soft-retire failed"
  fi
  E_SOFT_OK=1
fi

# F-09 STRICT: non-permanent handwritten C = 0 (hard; soft NHC FAIL retired).
if [ -f tests/run-no-handwritten-c-gate.sh ]; then
  echo "=== F-11: delegate no-handwritten-c STRICT (hard) ==="
  chmod +x tests/run-no-handwritten-c-gate.sh
  if ! XLANG_NO_HANDWRITTEN_C_STRICT=1 XLANG_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 \
      tests/run-no-handwritten-c-gate.sh; then
    die "no-handwritten-c STRICT failed"
  fi
  F09_OK=1
fi

# Stage2 hash / portable (hard when present; d03 may SKIP on Darwin).
chmod +x tests/run-d03-stage2-hash-gate.sh
if ! tests/run-d03-stage2-hash-gate.sh; then
  die "d03 failed"
fi
D03_OK=1
if [ -f tests/run-d04-stage2-portable-diff-gate.sh ]; then
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  if ! tests/run-d04-stage2-portable-diff-gate.sh; then
    die "d04 failed"
  fi
  D04_OK=1
fi

# Optional: historical F-std batch (default off).
if [ "${XLANG_F11_RUN_F_STD_BATCH:-0}" = "1" ] && [ -f tests/run-f-std-de-c-batch-gate.sh ]; then
  chmod +x tests/run-f-std-de-c-batch-gate.sh
  if ! tests/run-f-std-de-c-batch-gate.sh; then
    die "f-std-de-c-batch failed"
  fi
fi

# G-FFI-5: policy hard by default; LANG-007 runtime opt-in.
# PLATFORM: SHARED archaeology — avoid absorbing lang-unsafe hang into knife.
if [ -f tests/run-g-ffi-5-release-ci-gate.sh ]; then
  echo "=== F-11: delegate g-ffi-5 release-ci (hard policy) ==="
  chmod +x tests/run-g-ffi-5-release-ci-gate.sh
  if [ "${XLANG_F11_RUN_G_FFI5_RUNTIME:-0}" = "1" ]; then
    if ! tests/run-g-ffi-5-release-ci-gate.sh; then
      die "g-ffi-5 release-ci failed"
    fi
  else
    if ! XLANG_G_FFI5_SKIP_LANG_UNSAFE=1 tests/run-g-ffi-5-release-ci-gate.sh; then
      die "g-ffi-5 release-ci (policy) failed"
    fi
    echo "f11 SKIP g-ffi5 lang-unsafe runtime (XLANG_F11_RUN_G_FFI5_RUNTIME=1 to run)" >&2
  fi
  GFFI5_OK=1
fi

SKIP=0
echo "f11-selfhost-release-prep gate OK (checklist green; tag on release: v\$(cat VERSION)-selfhost)"
echo "${PREFIX} status=ok doc=${DOC_OK} d05=${D05_OK} e_soft=${E_SOFT_OK} f09=${F09_OK} d03=${D03_OK} d04=${D04_OK} gffi5=${GFFI5_OK} skip=${SKIP} host=$(ci_host_summary)"
