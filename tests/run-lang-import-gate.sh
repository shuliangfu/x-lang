#!/usr/bin/env bash
# LANG-002: import resolution cross-platform consistency gate.
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c LINK (force
# xlang-c over resolved XLANG) retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing native =
# hard die (import smoke is the live face). observe policy = obs
# (product debt — not soft silence). DOC authority = archive/lang.
# Report run=/hooks=/obs=/skip=.
#
# Usage: ./tests/run-lang-import-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_LANG_IMPORT_DOC:-analysis/archive/lang/lang-import-v1-rfc.md}"
MATRIX="${XLANG_LANG_IMPORT_TSV:-tests/baseline/lang-import-crossplatform.tsv}"
PREFIX="xlang: [XLANG_LANG_IMPORT]"
RUN_OK=0
HOOKS_OK=0
OBS=0
SKIP=0

die() {
  echo "lang-import gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} hooks=${HOOKS_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} hooks=${HOOKS_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== LANG-002: import cross-platform manifest (archive DOC) ==="
if [ -f analysis/lang-import-v1-rfc.md ]; then
  die "top-level DOC resurrected (live = archive/lang/)"
fi
for f in \
  "$DOC" \
  "$MATRIX" \
  tests/import/main.x \
  tests/import/missing_module.x \
  tests/parser/import_std_async.x; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
echo "lang-import manifest OK (host=$(ci_host_summary))"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Link follows resolved product path (prefer asm); refuse force-xlang-c.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make ../std/async/scheduler.o -q 2>/dev/null \
  || xlang_compiler_make ../std/async/scheduler.o

run_x_case() {
  local script="$1"
  local want_ec="${2:-0}"
  local src=""
  if [ -f "tests/import/${script}" ]; then
    src="tests/import/${script}"
  elif [ -f "tests/parser/${script}" ]; then
    src="tests/parser/${script}"
  else
    echo "lang-import FAIL: missing ${script}" >&2
    return 1
  fi
  local out="/tmp/xlang_lang_import_${script%.x}"
  if ! "$LINK_XLANG" -L . "$src" -o "$out" >/tmp/xlang_lang_import_compile.log 2>&1; then
    cat /tmp/xlang_lang_import_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want_ec" ]; then
    echo "lang-import FAIL ${script}: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== LANG-002: import smoke (CHECK/LINK via $(basename "$LINK_XLANG")) ==="

while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  echo "── $case_id: $notes ──"
  case "$policy" in
    hook)
      hook="tests/${script}"
      chmod +x "$hook" 2>/dev/null || true
      if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$LINK_XLANG" "$hook"; then
        echo "lang-import OK $case_id"
        HOOKS_OK=1
      else
        echo "lang-import FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    run)
      if run_x_case "$script" "${want_ec:-0}"; then
        echo "lang-import OK $case_id"
        HOOKS_OK=1
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    observe)
      # Product-debt smoke: keep matrix row; count obs (not soft silence).
      if run_x_case "$script" "${want_ec:-0}"; then
        echo "lang-import OK $case_id"
        HOOKS_OK=1
      else
        echo "lang-import OBS $case_id ($script; observational product debt)" >&2
        OBS=1
      fi
      ;;
    *)
      die "unknown policy $policy"
      ;;
  esac
done < "$MATRIX"

[ "$FAILS" -eq 0 ] || die "${FAILS} case(s)"
ok_report
echo "lang-import gate OK"
