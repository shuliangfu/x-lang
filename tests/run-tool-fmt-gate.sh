#!/usr/bin/env bash
# TOOL-001: formatter style lock manifest — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no xlang) + prefer-c only + soft auto-make retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - manifest + ## Gate + cases/rules = hard.
#   - fmt hooks (run-fmt-cmd) = hard run.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tool-fmt-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-fmt.sh
. tests/lib/tool-fmt.sh

DOC="${XLANG_TOOL_FMT_DOC:-analysis/archive/tool/tool-fmt-style-v1.md}"
MANIFEST="${XLANG_TOOL_FMT_MANIFEST:-tests/baseline/tool-fmt-style.tsv}"
MIN_CASES=5
MIN_RULES=6

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tool-fmt gate FAIL: $*" >&2
  tool_fmt_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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

echo "=== TOOL-001: formatter style manifest (archive DOC) ==="
if [ -f analysis/tool-fmt-style-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tool/)"
fi
for f in "$DOC" "$MANIFEST" compiler/src/driver/fmt.x compiler/seeds/fmt_check_cmd.from_x.c \
  tests/lib/tool-fmt.sh tests/run-fmt-cmd.sh; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 c3 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
    min_rules) MIN_RULES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
RULE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "tool-fmt FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "tool-fmt FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-fmt FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-fmt FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-fmt FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$CASE_N" -ge "$MIN_CASES" ] || die "cases=${CASE_N} < min ${MIN_CASES}"
[ "$RULE_N" -ge "$MIN_RULES" ] || die "rules=${RULE_N} < min ${MIN_RULES}"
for kw in formatter style idempotent runnable semicolon_space; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "tool-fmt manifest OK (cases=${CASE_N} rules=${RULE_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== TOOL-001: fmt hooks (XLANG=$XLANG_BIN) ==="

chmod +x tests/run-fmt-cmd.sh tests/run-fmt-check-cmd.sh tests/run-fmt-wrap.sh
set +e
XLANG="$XLANG_BIN" ./tests/run-fmt-cmd.sh >/tmp/xlang_tool_fmt_hooks.log 2>&1
hook_ec=$?
set -e
if [ "$hook_ec" -ne 0 ]; then
  tail -n 20 /tmp/xlang_tool_fmt_hooks.log 2>/dev/null || true
  die "fmt hooks failed (ec=$hook_ec; refuse soft SKIP→OK)"
fi
RUN_OK=$((RUN_OK + 1))
echo "tool-fmt hooks OK"

echo "tool-fmt gate OK"
tool_fmt_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
