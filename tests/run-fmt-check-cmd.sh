#!/usr/bin/env bash
# shu fmt --check（deno fmt --check 语义）：已格式化 exit 0 且无输出；需格式化 exit 1 并列出文件。
set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu}
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler shu-c 2>/dev/null || make -C compiler shu
fi

cp tests/return-value/main.su /tmp/shu_fmt_check_ok.su
out_ok=$($SHU fmt --check /tmp/shu_fmt_check_ok.su 2>&1)
if [ -n "$out_ok" ]; then
  echo "expected silent success on formatted file, got: $out_ok"
  exit 1
fi

printf 'function main(): i32 {\nreturn 0\n}\n' >/tmp/shu_fmt_check_bad.su
set +e
$SHU fmt --check /tmp/shu_fmt_check_bad.su >/dev/null 2>&1
bad_st=$?
set -e
if [ "$bad_st" -eq 0 ]; then
  echo "expected fmt --check to fail on bad indent"
  exit 1
fi
set +e
bad_out=$($SHU fmt --check /tmp/shu_fmt_check_bad.su 2>&1)
set -e
echo "$bad_out" | grep -q "not formatted" || {
  echo "expected summary listing unformatted files, got: $bad_out"
  exit 1
}
echo "$bad_out" | grep -q "/tmp/shu_fmt_check_bad.su" || {
  echo "expected path in fmt --check summary"
  exit 1
}

echo "fmt --check cmd test OK"
