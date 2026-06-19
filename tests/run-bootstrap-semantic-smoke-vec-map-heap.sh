#!/usr/bin/env bash
# BOOT-015 子集：两代 shux 上对 std.vec / std.map / std.heap 做 check（可选 link+run）。
#
# 用于扩展 bootstrap-verify / check-7.2 语义烟测；不替代全量 run-vec/map/heap。
# 用法：
#   SHUX=./compiler/shux_asm ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh
#   BOOT015_SKIP_LINK=1 …  # 仅 typeck
set -e
cd "$(dirname "$0")/.."

SHUX="${SHUX:-./compiler/shux}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"

# shellcheck source=tests/lib/boot-015-semantic-smoke.sh
. tests/lib/boot-015-semantic-smoke.sh

if [ ! -x "$SHUX" ]; then
  echo "bootstrap-semantic-smoke FAIL: SHUX not executable: $SHUX" >&2
  exit 127
fi

# MSYS2 / 非 x86_64：链接回退 shux-c（与 run-bootstrap-shux-gate 一致）。
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

CHECK_FAIL=0
LINK_OK=0
LINK_SKIP=0
for mod in vec map heap; do
  src="tests/${mod}/main.sx"
  if ! boot015_check_one "$SHUX" "$src"; then
    echo "bootstrap-semantic-smoke FAIL: check $mod" >&2
    CHECK_FAIL=$((CHECK_FAIL + 1))
    continue
  fi
  echo "bootstrap-semantic-smoke check OK $mod"
  if [ -n "${BOOT015_SKIP_LINK:-}" ]; then
    LINK_SKIP=$((LINK_SKIP + 1))
    continue
  fi
  out="${OUT_DIR}/shux_boot015_${mod}"
  lr=0
  boot015_link_run_one "$SHUX" "$src" "$out" || lr=$?
  if [ "$lr" -eq 0 ]; then
    LINK_OK=$((LINK_OK + 1))
    echo "bootstrap-semantic-smoke link+run OK $mod"
  elif [ "$lr" -eq 2 ]; then
    LINK_SKIP=$((LINK_SKIP + 1))
    if [ -n "${BOOT015_REQUIRE_LINK:-}" ]; then
      echo "bootstrap-semantic-smoke FAIL: link $mod (BOOT015_REQUIRE_LINK=1)" >&2
      CHECK_FAIL=$((CHECK_FAIL + 1))
    else
      echo "bootstrap-semantic-smoke SKIP link $mod (check OK)"
    fi
  else
    CHECK_FAIL=$((CHECK_FAIL + 1))
  fi
done

if [ "$CHECK_FAIL" -gt 0 ]; then
  boot015_emit_report "fail" 0 "$LINK_OK" "$LINK_SKIP"
  exit 1
fi

boot015_emit_report "ok" 3 "$LINK_OK" "$LINK_SKIP"
echo "bootstrap-semantic-smoke vec/map/heap OK (SHUX=$SHUX)"
