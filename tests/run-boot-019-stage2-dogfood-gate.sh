#!/usr/bin/env bash
# BOOT-019: Stage2 parser/typeck dogfood manifest + honesty gate
# (false-authority honesty).
#
# Usage: ./tests/run-boot-019-stage2-dogfood-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational
# (check gate paused 2026-08-05); 6 smoke link+run hard-fail
# (no soft SKIP→OK when no native). Report check=/link=/skip=. Gate was
# portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# hard check via subset runner / DOC ## 4. Gate without Gate honesty).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_BOOT019_DOC:-analysis/archive/boot/boot-019-stage2-dogfood-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_BOOT019_TSV:-tests/baseline/boot-019-stage2-dogfood.tsv}"
RUNNER="tests/run-bootstrap-stage2-dogfood-parser-typeck.sh"
LIB="tests/lib/boot-019-stage2-dogfood.sh"
MIN_SMOKE=6
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"

# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. tests/lib/boot-019-stage2-dogfood.sh

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
boot019_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== BOOT-019: Stage2 dogfood manifest ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-019-stage2-dogfood-v1.md ]; then
  echo "boot-019-stage2-dogfood gate FAIL: top-level DOC resurrected (live = archive/boot/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER" "$ROADMAP"; do
  if [ ! -f "$f" ]; then
    echo "boot-019-stage2-dogfood gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f NEXT.md ]; then
  echo "boot-019-stage2-dogfood gate FAIL: NEXT.md resurrected (use analysis/自举进度.md)" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_smoke) MIN_SMOKE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap-verify parser typeck check-7.2 Stage2; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-019-stage2-dogfood gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "boot-019-stage2-dogfood gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

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

if [ "$SMOKE" -lt "$MIN_SMOKE" ]; then
  echo "boot-019-stage2-dogfood gate FAIL: smokes=${SMOKE} < min ${MIN_SMOKE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-019-stage2-dogfood gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-019-stage2-dogfood manifest OK (smokes=${SMOKE})"

if [ "${XLANG_BOOT019_MANIFEST_ONLY:-0}" = "1" ]; then
  boot019_emit_report "ok" 0 0 1
  echo "boot-019-stage2-dogfood gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true
mkdir -p "$OUT_DIR"

CHECK_OK=0
LINK_OK=0
SKIP=1

if XLANG_BIN="$(boot019_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-019: bootstrap subset runner (XLANG=$XLANG_BIN; check observational; link+run hard) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh" 2>/dev/null || true
  chmod +x "$RUNNER"
  if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" BOOT019_SKIP_LINK= "$RUNNER" >/tmp/boot019_subset.log 2>&1; then
    grep -q 'bootstrap-stage2-dogfood parser/typeck OK' /tmp/boot019_subset.log
    # Observational check count (may be 0 on Darwin while check gate paused).
    CHECK_OK=$(grep -c 'bootstrap-stage2-dogfood check OK' /tmp/boot019_subset.log || true)
    LINK_OK=$(grep -c 'bootstrap-stage2-dogfood link+run OK' /tmp/boot019_subset.log || true)
    if [ "$LINK_OK" -lt 6 ]; then
      echo "boot-019-stage2-dogfood gate FAIL: link_ok=${LINK_OK} < 6" >&2
      tail -20 /tmp/boot019_subset.log >&2 || true
      boot019_emit_report "fail" "$CHECK_OK" "$LINK_OK" 0
      exit 1
    fi
    SKIP=0
  else
    tail -20 /tmp/boot019_subset.log >&2 || true
    boot019_emit_report "fail" 0 0 0
    exit 1
  fi
else
  echo "boot-019-stage2-dogfood gate FAIL: no native xlang" >&2
  boot019_emit_report "fail" 0 0 0
  exit 2
fi

# check stays observational; hard-green signal is link= (6/6).
echo "boot-019-stage2-dogfood check_ok=${CHECK_OK} (observational) link_ok=${LINK_OK}"
boot019_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$SKIP"
echo "boot-019-stage2-dogfood gate OK"
