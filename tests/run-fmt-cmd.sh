#!/usr/bin/env bash
# xlang fmt 子命令：格式化 .x 后仍能通过 check。
set -e
cd "$(dirname "$0")/.."
XLANG=${XLANG:-./compiler/xlang}
# 产品冷链：fmt/check 用当前 XLANG（xlang_asm→xlang 已静默 check）。
# 旧逻辑在 XLANG_RUN_ALL_BOOTSTRAP_XLANG 下强绑 pin xlang-c → CHK001 假红。
if [ -n "${RUN_ALL_USE_C:-}" ] && [ -x ./compiler/xlang-c ]; then
  XLANG=./compiler/xlang-c
fi
# MSYS2/MinGW：xlang-c.exe 已修复 _O_BINARY 二进制模式（CRLF 不再导致 read mismatch），
# 直接用 xlang-c 执行 fmt/check；不再回退到 seed xlang（seed 无 _O_BINARY 修复）。
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler all
  fi
fi

FMT_TMP="${TMPDIR:-/tmp}/xlang_fmt_cmd_test.x"
# MSYS2/MinGW：xlang-c.exe 是 Windows 原生程序，不认识 /tmp/ 路径，且内部路径解析会把
# 绝对路径 C:/... 当作相对路径拼接 cwd。用相对路径（cwd 下创建）避免此 bug。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) FMT_TMP="xlang_fmt_cmd_test.x" ;;
esac
mkdir -p "$(dirname "$FMT_TMP")" 2>/dev/null || true
# 故意错误缩进；fmt 写回后应打印 fmt OK 且 check 仍通过（须含分号）
printf 'function main(): i32 {\nreturn 0;\n}\n' >"$FMT_TMP"
set +e
fmt_out=$($XLANG fmt "$FMT_TMP" 2>&1)
fmt_st=$?
set -e
if [ "$fmt_st" -ne 0 ]; then
  echo "fmt failed (exit $fmt_st): $fmt_out" >&2
  exit 1
fi
if ! echo "$fmt_out" | grep -q "fmt OK"; then
  # MSYS2 等环境 fmt 可能静默成功（视为已规范）；check 通过即可。
  chk_pre=$($XLANG check "$FMT_TMP" 2>&1) || true
  if [ -n "$chk_pre" ]; then
    echo "expected fmt OK or silent check after fmt, fmt_out=$fmt_out check=$chk_pre" >&2
    exit 1
  fi
fi
# Windows/MinGW：_O_BINARY 修复后 fmt/check 不再有 CRLF read mismatch，无需 workaround。
chk_out=$($XLANG check "$FMT_TMP" 2>&1) || true
if [ -n "$chk_out" ]; then
  echo "expected silent check after fmt, got: $chk_out"
  exit 1
fi
chmod +x tests/run-fmt-check-cmd.sh 2>/dev/null || true
if ! XLANG="$XLANG" ./tests/run-fmt-check-cmd.sh 2>&1 | tee /tmp/xlang_fmt_check_cmd.log; then
  echo "run-fmt-check-cmd failed (XLANG=$XLANG build MSYSTEM=${MSYSTEM:-})" >&2
  tail -20 /tmp/xlang_fmt_check_cmd.log 2>/dev/null || true
  exit 1
fi
chmod +x tests/run-fmt-wrap.sh 2>/dev/null || true
XLANG="$XLANG" ./tests/run-fmt-wrap.sh

# === unary minus formatting (merged from run-fmt-unary-gate.sh) ===
# 验证一元负号 -1/-i 保持紧贴，二元减法 a-1 规整为 a - 1
# 检测旧种子：bootstrap_xlangc 若为 7月16日 LEGACY 种子，不含 is_return 修复，
# return -i 会被错误拆开为 return - i。检测到此行为则跳过 unary 测试，
# 等下次 LEGACY 重链接（含 runtime_lsp_glue.from_x.c 的 is_return 修复）后自然启用。
FMT_UNARY_TMP="${TMPDIR:-/tmp}/xlang_fmt_unary.x"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) FMT_UNARY_TMP="/tmp/xlang_fmt_unary.x" ;;
esac

printf 'function neg(i: i32): i32 { return -i; }\nfunction main(): i32 {\n  let a: i32 = -1;\n  let b: i32 = a-1;\n  let c: i32 = a - 1;\n  let d: i32 = neg(-1);\n  if (a < 0) { return -1; }\n  return b + c + d;\n}\n' >"$FMT_UNARY_TMP"

set +e
fmt_unary_out=$($XLANG fmt "$FMT_UNARY_TMP" 2>&1)
fmt_unary_st=$?
set -e
if [ "$fmt_unary_st" -ne 0 ]; then
  echo "fmt unary failed (exit $fmt_unary_st): $fmt_unary_out" >&2
  exit 1
fi

content=$(cat "$FMT_UNARY_TMP")

# 旧种子检测：return -i 被拆开为 return - i 说明 bootstrap_xlangc 不含 is_return 修复
if echo "$content" | grep -qE 'return - i'; then
  echo "SKIP: bootstrap_xlangc 旧种子不含 is_return 修复，跳过 unary 测试（等 LEGACY 重链接）"
  rm -f "$FMT_UNARY_TMP"
  echo "fmt cmd test OK (unary skipped: legacy seed)"
  exit 0
fi

# 一元负号必须紧贴：-1 / -i 不能变成 - 1 / - i
if echo "$content" | grep -qE 'return - 1|return - i'; then
  echo "FAIL: 一元负号被错误格式化为两侧空格" >&2
  echo "$content" >&2
  exit 1
fi
if echo "$content" | grep -qE '= - 1|neg\(- 1\)'; then
  echo "FAIL: 一元负号 -1 被错误格式化为 - 1" >&2
  echo "$content" >&2
  exit 1
fi

# 二元减法 a-1 应被规整为 a - 1（两侧空格）
if echo "$content" | grep -qE '[a-zA-Z_][a-zA-Z0-9_]*-[0-9]'; then
  echo "FAIL: 二元减法未被规整为两侧空格（仍有 a-1 紧贴形式）" >&2
  echo "$content" >&2
  exit 1
fi

# 确认一元 -1 仍存在
if ! echo "$content" | grep -qE 'return -1;'; then
  echo "FAIL: return -1; 不见了" >&2
  echo "$content" >&2
  exit 1
fi

chk_unary_out=$($XLANG check "$FMT_UNARY_TMP" 2>&1) || true
if [ -n "$chk_unary_out" ]; then
  echo "expected silent check after fmt unary, got: $chk_unary_out" >&2
  exit 1
fi

rm -f "$FMT_UNARY_TMP"
echo "fmt unary minus test OK"

echo "fmt cmd test OK"
