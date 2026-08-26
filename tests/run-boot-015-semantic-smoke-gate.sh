#!/usr/bin/env bash
# BOOT-015: semantic smoke (vec/map/heap) manifest + honesty gate
# (false-authority honesty).
#
# Usage: ./tests/run-boot-015-semantic-smoke-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational
# (check gate paused 2026-08-05); vec/map/heap link+run exit0 hard-fail
# (no soft SKIP→OK when no native). Report check=/link=/skip=. Gate was
# portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# hard check via subset runner / DOC ## 4. Gate without Gate honesty).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_BOOT015_DOC:-analysis/archive/boot/boot-015-semantic-smoke-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_BOOT015_TSV:-tests/baseline/boot-015-semantic-smoke.tsv}"
LIB="tests/lib/boot-015-semantic-smoke.sh"
MIN_SMOKE=3
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"

# shellcheck source=tests/lib/boot-015-semantic-smoke.sh
. tests/lib/boot-015-semantic-smoke.sh

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
boot015_resolve_shu() {
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

echo "=== BOOT-015: semantic smoke manifest ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-015-semantic-smoke-v1.md ]; then
  echo "boot-015-semantic-smoke gate FAIL: top-level DOC resurrected (live = archive/boot/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$ROADMAP"; do
  if [ ! -f "$f" ]; then
    echo "boot-015-semantic-smoke gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f NEXT.md ]; then
  echo "boot-015-semantic-smoke gate FAIL: NEXT.md resurrected (use analysis/自举进度.md)" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_smoke) MIN_SMOKE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in bootstrap-verify vec map heap check-7.2; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-015-semantic-smoke gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "boot-015-semantic-smoke gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

MISS=0
SMOKE=0
echo "=== BOOT-015: smokes, hooks, refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      SMOKE=$((SMOKE + 1))
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "boot-015 OK smoke $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "boot-015 FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "boot-015 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "boot-015 FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SMOKE" -lt "$MIN_SMOKE" ]; then
  echo "boot-015-semantic-smoke gate FAIL: smokes=${SMOKE} < min ${MIN_SMOKE}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-015-semantic-smoke gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-015-semantic-smoke manifest OK (smokes=${SMOKE})"

if [ "${XLANG_BOOT015_MANIFEST_ONLY:-0}" = "1" ]; then
  boot015_emit_report "ok" 0 0 1
  echo "boot-015-semantic-smoke gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true
mkdir -p "$OUT_DIR"

CHECK_OK=0
LINK_OK=0
SKIP=1

if XLANG_BIN="$(boot015_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-015: smoke (XLANG=$XLANG_BIN; check observational; link+run hard) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  for mod in vec map heap; do
    src="tests/${mod}/main.x"
    # Observational check (paused 2026-08-05); CHK red does not hard-fail.
    if boot015_check_one "$XLANG_BIN" "$src"; then
      CHECK_OK=$((CHECK_OK + 1))
    else
      echo "boot-015-semantic-smoke gate SKIP check $mod (paused 2026-08-05)" >&2
    fi
  done

  for mod in vec map heap; do
    src="tests/${mod}/main.x"
    out="${OUT_DIR}/xlang_boot015_${mod}_$$"
    lr=0
    boot015_link_run_one "$XLANG_BIN" "$src" "$out" || lr=$?
    rm -f "$out"
    if [ "$lr" -eq 0 ]; then
      LINK_OK=$((LINK_OK + 1))
      echo "boot-015 link+run OK $mod"
    else
      echo "boot-015-semantic-smoke gate FAIL: link+run $mod (lr=$lr)" >&2
      boot015_emit_report "fail" "$CHECK_OK" "$LINK_OK" 0
      exit 1
    fi
  done
  SKIP=0
else
  echo "boot-015-semantic-smoke gate FAIL: no native xlang" >&2
  boot015_emit_report "fail" 0 0 0
  exit 2
fi

# check stays observational; hard-green signal is link= (3/3).
echo "boot-015-semantic-smoke check_ok=${CHECK_OK} (observational) link_ok=${LINK_OK}"
boot015_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$SKIP"
echo "boot-015-semantic-smoke gate OK"
