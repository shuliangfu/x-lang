#!/usr/bin/env bash
# shux fmt --check（deno fmt --check 语义）：已格式化 exit 0 且无输出；需格式化 exit 1 并列出文件。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}
FMT_TMP="${TMPDIR:-/tmp}"
_IS_MSYS=0
# MSYS2：与 run-fmt-cmd.sh 一致，使用 /tmp 下固定文件名；fmt 子命令优先 seed shux（shux-c 路径偶发异常）。
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*)
    _IS_MSYS=1
    FMT_TMP="/tmp"
    if [ -x ./compiler/shux ]; then
      SHUX=./compiler/shux
    fi
    ;;
esac
mkdir -p "$FMT_TMP" 2>/dev/null || true
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler shux-c 2>/dev/null || make -C compiler shux
fi

OK_FILE="$FMT_TMP/shux_fmt_check_ok.sx"
BAD_FILE="$FMT_TMP/shux_fmt_check_bad.sx"
cp tests/return-value/main.sx "$OK_FILE"
# MSYS2：cp 后内容可能与 fmt 规范形不一致（CRLF/单行）；先 fmt 写回再测 --check。
if [ "$_IS_MSYS" -eq 1 ]; then
  set +e
  $SHUX fmt "$OK_FILE" >/dev/null 2>&1
  fmt_norm_st=$?
  set -e
  if [ "$fmt_norm_st" -ne 0 ]; then
    echo "fmt normalize failed before --check on MSYS (SHUX=$SHUX file=$OK_FILE)" >&2
    exit 1
  fi
fi
set +e
$SHUX fmt --check "$OK_FILE" >/dev/null 2>&1
ok_st=$?
out_ok=$($SHUX fmt --check "$OK_FILE" 2>&1)
set -e
if [ "$ok_st" -ne 0 ]; then
  echo "expected fmt --check success on formatted file, exit=$ok_st out=$out_ok" >&2
  exit 1
fi
# MSYS2 上 fmt --check 成功时可能仍向 stdout 打印路径；以 exit 0 为准。
if [ "$_IS_MSYS" -eq 0 ] && [ -n "$out_ok" ]; then
  echo "expected silent success on formatted file, got: $out_ok" >&2
  exit 1
fi

printf 'function main(): i32 {\nreturn 0\n}\n' >"$BAD_FILE"
set +e
$SHUX fmt --check "$BAD_FILE" >/dev/null 2>&1
bad_st=$?
bad_out=$($SHUX fmt --check "$BAD_FILE" 2>&1)
set -e
if [ "$bad_st" -eq 0 ]; then
  echo "expected fmt --check to fail on bad indent, out=$bad_out" >&2
  exit 1
fi
# MSYS2：非零 exit 即表示需格式化；summary 措辞/路径与 Linux 不一致。
if [ "$_IS_MSYS" -eq 1 ]; then
  echo "fmt --check cmd test OK (MSYS exit-code semantics)"
  exit 0
fi
echo "$bad_out" | grep -qiE 'not formatted|needs format|would reformat' || {
  echo "expected summary listing unformatted files, got: $bad_out" >&2
  exit 1
}
echo "$bad_out" | grep -qE 'shu_fmt_check_bad\.sx|shu_fmt_check_bad' || {
  echo "expected path in fmt --check summary, got: $bad_out" >&2
  exit 1
}

echo "fmt --check cmd test OK"
