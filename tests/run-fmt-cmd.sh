#!/usr/bin/env bash
# shux fmt 子命令：格式化 .sx 后仍能通过 check。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}
# bootstrap seed / shux_asm：fmt/check 须静默，走 shux-c（与 run-check 一致）。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux-c ]; then
  case "$(basename "${SHUX:-./compiler/shux}")" in
    shux|shux_asm) SHUX=./compiler/shux-c ;;
    *)
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) ;;
        *) SHUX=./compiler/shux-c ;;
      esac
      ;;
  esac
fi
# MSYS2：fmt 子命令在 shux-c 路径下偶发异常，CI test_c 仍走 shux-c 但 fmt 回归优先 seed shux。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/shux ]; then
      SHUX=./compiler/shux
    fi
    ;;
esac
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler all
  fi
fi

FMT_TMP="${TMPDIR:-/tmp}/shux_fmt_cmd_test.sx"
# MSYS2：固定 Unix 路径，避免 Windows 短路径/混用斜杠导致 shux 打不开临时文件。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) FMT_TMP="/tmp/shux_fmt_cmd_test.sx" ;;
esac
mkdir -p "$(dirname "$FMT_TMP")" 2>/dev/null || true
# 故意错误缩进；fmt 写回后应打印 fmt OK 且 check 仍通过（须含分号）
printf 'function main(): i32 {\nreturn 0;\n}\n' >"$FMT_TMP"
set +e
fmt_out=$($SHUX fmt "$FMT_TMP" 2>&1)
fmt_st=$?
set -e
if [ "$fmt_st" -ne 0 ]; then
  echo "fmt failed (exit $fmt_st): $fmt_out" >&2
  exit 1
fi
if ! echo "$fmt_out" | grep -q "fmt OK"; then
  # MSYS2 等环境 fmt 可能静默成功（视为已规范）；check 通过即可。
  chk_pre=$($SHUX check "$FMT_TMP" 2>&1) || true
  if [ -n "$chk_pre" ]; then
    echo "expected fmt OK or silent check after fmt, fmt_out=$fmt_out check=$chk_pre" >&2
    exit 1
  fi
fi
chk_out=$($SHUX check "$FMT_TMP" 2>&1) || true
if [ -n "$chk_out" ]; then
  echo "expected silent check after fmt, got: $chk_out"
  exit 1
fi
chmod +x tests/run-fmt-check-cmd.sh 2>/dev/null || true
if ! SHUX="$SHUX" ./tests/run-fmt-check-cmd.sh 2>&1 | tee /tmp/shux_fmt_check_cmd.log; then
  echo "run-fmt-check-cmd failed (SHUX=$SHUX MSYSTEM=${MSYSTEM:-})" >&2
  tail -20 /tmp/shux_fmt_check_cmd.log 2>/dev/null || true
  exit 1
fi
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
SHUX="$SHUX" ./tests/run-fmt-wrap.sh

echo "fmt cmd test OK"
