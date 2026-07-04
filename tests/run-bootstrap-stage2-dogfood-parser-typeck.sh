#!/usr/bin/env bash
# BOOT-019 子集：两代 shux 上对 parser/typeck dogfood 做 check（可选 link+run）。
#
# 用于扩展 bootstrap-verify / check-7.2 Stage2 扩面；不替代全量 run-parser/run-typeck。
# 用法：
#   SHUX=./compiler/shux_stage2 ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
#   BOOT019_SKIP_LINK=1 …  # 仅 typeck
set -e
cd "$(dirname "$0")/.."

SHUX="${SHUX:-./compiler/shux}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"

# shellcheck source=tests/lib/boot-019-stage2-dogfood.sh
. tests/lib/boot-019-stage2-dogfood.sh

if [ ! -x "$SHUX" ]; then
  echo "bootstrap-stage2-dogfood FAIL: SHUX not executable: $SHUX" >&2
  exit 127
fi

# MSYS2 / 非 x86_64：链接回退 shux-c（与 BOOT-015 一致）。
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/shux-c ]; then
    export SHUX_LINK_SHUX=./compiler/shux-c
  fi
fi
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shux-c ]; then
      export SHUX_LINK_SHUX=./compiler/shux-c
    fi
    ;;
esac

# parser 子集：语法/多函数/表达式
PARSER_SMOKES=(
  tests/parser/semicolon_required.x
  tests/parser/two_functions.x
  tests/parser/binary_expr_return.x
)
# typeck 子集：Option/Result/泛型
TYPECK_SMOKES=(
  tests/option/main.x
  tests/result/main.x
  tests/generic/main.x
)

CHECK_FAIL=0
CHECK_OK=0
LINK_OK=0
LINK_SKIP=0

run_smoke_list() {
  local label="$1"
  shift
  local src
  for src in "$@"; do
    if ! boot019_check_one "$SHUX" "$src"; then
      echo "bootstrap-stage2-dogfood FAIL: check $label $src" >&2
      CHECK_FAIL=$((CHECK_FAIL + 1))
      continue
    fi
    CHECK_OK=$((CHECK_OK + 1))
    echo "bootstrap-stage2-dogfood check OK $label $(basename "$src")"
    if [ -n "${BOOT019_SKIP_LINK:-}" ]; then
      LINK_SKIP=$((LINK_SKIP + 1))
      continue
    fi
    local base
    base=$(basename "$src" .x)
    local out="${OUT_DIR}/shux_boot019_${base}"
    local expect lr=0
    expect=$(boot019_expected_exit "$src")
    boot019_link_run_one "$SHUX" "$src" "$out" "$expect" || lr=$?
    if [ "$lr" -eq 0 ]; then
      LINK_OK=$((LINK_OK + 1))
      echo "bootstrap-stage2-dogfood link+run OK $label $(basename "$src")"
    elif [ "$lr" -eq 2 ]; then
      LINK_SKIP=$((LINK_SKIP + 1))
      if [ -n "${BOOT019_REQUIRE_LINK:-}" ]; then
        echo "bootstrap-stage2-dogfood FAIL: link $src (BOOT019_REQUIRE_LINK=1)" >&2
        CHECK_FAIL=$((CHECK_FAIL + 1))
      else
        echo "bootstrap-stage2-dogfood SKIP link $label $(basename "$src") (check OK)"
      fi
    else
      CHECK_FAIL=$((CHECK_FAIL + 1))
    fi
  done
}

run_smoke_list parser "${PARSER_SMOKES[@]}"
run_smoke_list typeck "${TYPECK_SMOKES[@]}"

if [ "$CHECK_FAIL" -gt 0 ]; then
  boot019_emit_report "fail" 0 "$LINK_OK" "$LINK_SKIP"
  exit 1
fi

boot019_emit_report "ok" "$CHECK_OK" "$LINK_OK" "$LINK_SKIP"
echo "bootstrap-stage2-dogfood parser/typeck OK (SHUX=$SHUX check_ok=$CHECK_OK)"
