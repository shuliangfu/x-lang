#!/usr/bin/env bash
# shux fmt 折行回归：注释不折、代码在 ; / , / 空格处折、数组逗号后补空格、fmt 后须能 check 通过。
set -e
cd "$(dirname "$0")/.."
ROOT=$(pwd)
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# fmt/check 用 RUN_SHUX（bootstrap 下为 shux-c，与 run-import 一致）
SHUX="$RUN_SHUX"
run_one_case() {
  local CASE=$1
  local TMP=$2
  local before
  cp "$CASE" "$TMP"
  before=$(wc -l <"$CASE" | tr -d ' ')

  out=$($SHUX fmt "$TMP" 2>&1) || { echo "fmt failed on $CASE: $out"; return 1; }

  python3 compiler/scripts/scan_fmt_damage.py "$TMP" || {
    echo "scan_fmt_damage failed on fmt output ($CASE)"
    return 1
  }
  python3 compiler/scripts/verify_comment_prefixes.py "$TMP" || {
    echo "verify_comment_prefixes failed on fmt output ($CASE)"
    return 1
  }

  if grep -E '^[[:space:]]*(refix|fix)\[' "$TMP" >/dev/null 2>&1; then
    echo "fmt split identifier inside prefix[...] ($CASE)"
    grep -nE '^(refix|fix)\[' "$TMP" || true
    return 1
  fi

  # 代码行：分号后应有空格（排除字符串内 "a;b" 与 for(;;)）
  if grep -E '[^[:space:];][[:space:]]*;[[:alnum:]_\[]' "$TMP" >/dev/null 2>&1; then
    echo "fmt missing space after semicolon before identifier ($CASE)"
    grep -nE '[^[:space:];][[:space:]]*;[[:alnum:]_\[]' "$TMP" | head -5 || true
    return 1
  fi

  chk=$($SHUX check -L "$ROOT" "$TMP" 2>&1) || {
    echo "$chk"
    echo "check failed after fmt ($CASE)"
    return 1
  }
  if [ -n "$chk" ]; then
    echo "expected silent check, got: $chk ($CASE)"
    return 1
  fi

  chk2=$($SHUX fmt --check "$TMP" 2>&1) || {
    echo "fmt --check failed after first fmt ($CASE): $chk2"
    return 1
  }
  if [ -n "$chk2" ]; then
    echo "expected silent fmt --check, got: $chk2 ($CASE)"
    return 1
  fi

  rm -f "$TMP"
  echo "  OK: $CASE (${before} lines)"
  return 0
}

if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler src/lsp/lsp_diag.o -q 2>/dev/null || true
  if [ -f compiler/build_asm/seed_host/asm_backend_partial.o ]; then
    make -C compiler relink-shux -q 2>/dev/null || true
  fi
fi

echo "fmt wrap regression:"
run_one_case tests/fmt/fmt_wrap_cases.x "$ROOT/tests/fmt/.fmt_wrap_out.x" || exit 1
run_one_case tests/fmt/fmt_comprehensive.x "$ROOT/tests/fmt/.fmt_comprehensive_out.x" || exit 1
run_one_case tests/fmt/fmt_semicolon_space.x "$ROOT/tests/fmt/.fmt_semicolon_space_out.x" || exit 1
run_one_case tests/fmt/fmt_operator_space.x "$ROOT/tests/fmt/.fmt_operator_space_out.x" || exit 1
run_one_case tests/fmt/fmt_array_comma_space.x "$ROOT/tests/fmt/.fmt_array_comma_space_out.x" || exit 1
echo "fmt wrap test OK (all cases)"
