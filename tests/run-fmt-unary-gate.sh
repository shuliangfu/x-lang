#!/usr/bin/env bash
# fmt 一元负号 gate：return -1 / x = -1 / 调用参数 -1 须保持 -1，不被格式化为 - 1。
# 同时验证二元减法 a - b 仍被规整为两侧空格。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}

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
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    if [ -x ./compiler/shux ]; then SHUX=./compiler/shux; fi
    ;;
esac

FMT_TMP="${TMPDIR:-/tmp}/shux_fmt_unary_gate.x"
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) FMT_TMP="/tmp/shux_fmt_unary_gate.x" ;;
esac

# 故意混排：一元负号紧贴（-1）、二元减法无空格（a-1）、二元减法两侧空格（a - 1）
printf 'function neg(i: i32): i32 { return -i; }\nfunction main(): i32 {\n  let a: i32 = -1;\n  let b: i32 = a-1;\n  let c: i32 = a - 1;\n  let d: i32 = neg(-1);\n  if (a < 0) { return -1; }\n  return b + c + d;\n}\n' >"$FMT_TMP"

set +e
fmt_out=$($SHUX fmt "$FMT_TMP" 2>&1)
fmt_st=$?
set -e
if [ "$fmt_st" -ne 0 ]; then
  echo "fmt failed (exit $fmt_st): $fmt_out" >&2
  exit 1
fi

# 读取格式化后的内容
content=$(cat "$FMT_TMP")

# 一元负号必须紧贴：-1 / -i 不能变成 - 1 / - i
if echo "$content" | grep -qE 'return - 1|return - i'; then
  echo "FAIL: 一元负号被错误格式化为两侧空格" >&2
  echo "--- content ---" >&2
  echo "$content" >&2
  exit 1
fi
if echo "$content" | grep -qE '= - 1|neg\(- 1\)'; then
  echo "FAIL: 一元负号 -1 被错误格式化为 - 1" >&2
  echo "--- content ---" >&2
  echo "$content" >&2
  exit 1
fi

# 二元减法 a-1 应被规整为 a - 1（两侧空格）
if echo "$content" | grep -qE '[a-zA-Z_][a-zA-Z0-9_]*-[0-9]'; then
  echo "FAIL: 二元减法未被规整为两侧空格（仍有 a-1 紧贴形式）" >&2
  echo "--- content ---" >&2
  echo "$content" >&2
  exit 1
fi

# 确认一元 -1 仍存在（未被改成 - 1）
if ! echo "$content" | grep -qE 'return -1;'; then
  echo "FAIL: return -1; 不见了" >&2
  echo "--- content ---" >&2
  echo "$content" >&2
  exit 1
fi

# check 仍须通过
chk_out=$($SHUX check "$FMT_TMP" 2>&1) || true
if [ -n "$chk_out" ]; then
  echo "expected silent check after fmt, got: $chk_out" >&2
  exit 1
fi

rm -f "$FMT_TMP"
echo "fmt unary minus gate OK"
