#!/usr/bin/env bash
# lang-const-eval.sh — LANG-006 CTFE shared runner (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die (CTFE face is
# live). Report run=/skip= via caller gate.
#
# Usage:
#   ./tests/lib/lang-const-eval.sh           # full cases (needs native xlang)
#   ./tests/lib/lang-const-eval.sh case_id   # single case (manifest item_id)
# PLATFORM: SHARED archaeology.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
# shellcheck source=dod-native-exe.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/dod-native-exe.sh"
set -e
cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.."

MANIFEST="${XLANG_LANG_CONST_EVAL_MANIFEST:-tests/baseline/lang-const-eval.tsv}"
ONE="${1:-}"

# Resolve product xlang; prefer asm. Explicit bad XLANG → return 1.
# Missing native → return 1 (caller hard-dies; refuse soft SKIP→OK).
lang_const_eval_resolve_shu() {
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

# Compile+run .x and check exit code.
lang_const_eval_run_x() {
  local xlang="$1"
  local src="$2"
  local want="$3"
  local tag="$4"
  local out="/tmp/xlang_lang_const_${tag}"
  if [ ! -f "$src" ]; then
    echo "lang-const-eval FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$out" >/tmp/xlang_lang_const_compile.log 2>&1; then
    cat /tmp/xlang_lang_const_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "$want" ]; then
    echo "lang-const-eval FAIL $tag: exit=$ec want=$want" >&2
    return 1
  fi
  return 0
}

# Parse "exit N" from manifest notes.
lang_const_eval_want_exit() {
  local notes="$1"
  case "$notes" in
    *exit\ [0-9]*) echo "$notes" | sed -n 's/.*exit \([0-9][0-9]*\).*/\1/p' | head -1 ;;
    *) echo "0" ;;
  esac
}

# Main: full or single-case runnable. Returns 0 ok / 1 fail / 2 no-native.
lang_const_eval_main() {
  local ONE="${1:-}"
  local XLANG_BIN=""
  if ! XLANG_BIN="$(lang_const_eval_resolve_shu)"; then
    echo "lang-const-eval: no native xlang/xlang_asm/xlang-c" >&2
    return 2
  fi
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

  local FAILS=0
  local RAN=0
  while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      case)
        if [ -n "$ONE" ] && [ "$item_id" != "$ONE" ]; then
          continue
        fi
        local want
        want="$(lang_const_eval_want_exit "${notes:-}")"
        RAN=$((RAN + 1))
        echo "── lang-const-eval $item_id (want=$want) ──"
        if lang_const_eval_run_x "$XLANG_BIN" "$src" "$want" "$item_id"; then
          echo "lang-const-eval OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
      script)
        if [ -n "$ONE" ] && [ "$item_id" != "$ONE" ]; then
          continue
        fi
        RAN=$((RAN + 1))
        echo "── lang-const-eval hook $item_id ──"
        chmod +x "$src" 2>/dev/null || true
        if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$src"; then
          echo "lang-const-eval OK $item_id"
        else
          FAILS=$((FAILS + 1))
        fi
        ;;
    esac
  done < "$MANIFEST"

  if [ -n "$ONE" ] && [ "$RAN" -eq 0 ]; then
    echo "lang-const-eval FAIL: unknown item_id=$ONE" >&2
    return 1
  fi

  if [ "$FAILS" -gt 0 ]; then
    echo "lang-const-eval runner FAIL: ${FAILS} case(s)" >&2
    return 1
  fi
  echo "lang-const-eval runner OK (${RAN} runnable)"
  return 0
}

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  lang_const_eval_main "${1:-}"
  exit $?
fi
