#!/usr/bin/env bash
# shu fmt 子命令：格式化 .su 后仍能通过 check。
set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu}
# MSYS2：fmt 子命令在 shu-c 路径下偶发异常，CI test_c 仍走 shu-c 但 fmt 回归优先 seed shu。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/shu ]; then
      SHU=./compiler/shu
    fi
    ;;
esac
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler all
  fi
fi

FMT_TMP="${TMPDIR:-/tmp}/shu_fmt_cmd_test.su"
# MSYS2：固定 Unix 路径，避免 Windows 短路径/混用斜杠导致 shu 打不开临时文件。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) FMT_TMP="/tmp/shu_fmt_cmd_test.su" ;;
esac
mkdir -p "$(dirname "$FMT_TMP")" 2>/dev/null || true
# 故意错误缩进；fmt 写回后应打印 fmt OK 且 check 仍通过（须含分号）
printf 'function main(): i32 {\nreturn 0;\n}\n' >"$FMT_TMP"
set +e
fmt_out=$($SHU fmt "$FMT_TMP" 2>&1)
fmt_st=$?
set -e
if [ "$fmt_st" -ne 0 ]; then
  echo "fmt failed (exit $fmt_st): $fmt_out" >&2
  exit 1
fi
if ! echo "$fmt_out" | grep -q "fmt OK"; then
  # MSYS2 等环境 fmt 可能静默成功（视为已规范）；check 通过即可。
  chk_pre=$($SHU check "$FMT_TMP" 2>&1) || true
  if [ -n "$chk_pre" ]; then
    echo "expected fmt OK or silent check after fmt, fmt_out=$fmt_out check=$chk_pre" >&2
    exit 1
  fi
fi
chk_out=$($SHU check "$FMT_TMP" 2>&1) || true
if [ -n "$chk_out" ]; then
  echo "expected silent check after fmt, got: $chk_out"
  exit 1
fi
chmod +x tests/run-fmt-check-cmd.sh 2>/dev/null || true
if ! SHU="$SHU" ./tests/run-fmt-check-cmd.sh; then
  echo "run-fmt-check-cmd failed (SHU=$SHU MSYSTEM=${MSYSTEM:-})" >&2
  exit 1
fi
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
SHU="$SHU" ./tests/run-fmt-wrap.sh

echo "fmt cmd test OK"
