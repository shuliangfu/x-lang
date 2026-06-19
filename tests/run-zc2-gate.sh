#!/usr/bin/env bash
# ZC-2 门禁：read_ptr_gen 校验 + 常规文件 mmap 绝对视图 smoke + M-5 read_ptr_slice 回归。
# 用法：
#   ./tests/run-zc2-gate.sh
#   SHUX=./compiler/shux_asm ./tests/run-zc2-gate.sh
set -e
cd "$(dirname "$0")/.."

SHUX_BIN="${SHUX:-}"
case "$SHUX_BIN" in
  /*) SHUX_ABS="$SHUX_BIN" ;;
  "") SHUX_ABS="" ;;
  *) SHUX_ABS="$(pwd)/$SHUX_BIN" ;;
esac

zc2_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if [ -z "$SHUX_ABS" ] || ! zc2_native_exe "$SHUX_ABS"; then
  SHUX_ABS=""
  for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux-c; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if zc2_native_exe "$abs"; then
      SHUX_ABS="$abs"
      break
    fi
  done
fi

CHECK_SHUX="$SHUX_ABS"
if [ -z "$CHECK_SHUX" ] && [ -x ./compiler/shux-c ]; then
  CHECK_SHUX=./compiler/shux-c
fi

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
GEN_OUT="$OUT_DIR/shux_zc2_read_ptr_gen"
MMAP_OUT="$OUT_DIR/shux_zc2_read_ptr_mmap"
VIEW_OUT="$OUT_DIR/shux_zc2_read_ptr_view"
rm -f "$GEN_OUT" "$MMAP_OUT" "$VIEW_OUT"

echo "=== ZC-2: read_ptr gen + mmap absolute view ==="

if [ -z "$CHECK_SHUX" ]; then
  if make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null; then
    [ -x ./compiler/shux-c ] && CHECK_SHUX=./compiler/shux-c
  fi
fi

if [ -z "$CHECK_SHUX" ]; then
  echo "zc2 gate SKIP (no working shux-c/shux)"
  exit 0
fi

make -C compiler -q ../std/process/process.o ../std/io/io.o ../std/fs/fs.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o ../std/fs/fs.o

GEN_SRC="tests/io/read_ptr_gen_smoke.sx"
MMAP_SRC="tests/io/read_ptr_mmap_smoke.sx"
VIEW_SRC="tests/io/read_ptr_view_smoke.sx"

if ! "$CHECK_SHUX" check -L . "$GEN_SRC" >/dev/null 2>&1; then
  echo "zc2 FAIL: typeck $GEN_SRC" >&2
  "$CHECK_SHUX" check -L . "$GEN_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_SHUX" check -L . "$MMAP_SRC" >/dev/null 2>&1; then
  echo "zc2 FAIL: typeck $MMAP_SRC" >&2
  "$CHECK_SHUX" check -L . "$MMAP_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_SHUX" check -L . "$VIEW_SRC" >/dev/null 2>&1; then
  echo "zc2 FAIL: typeck $VIEW_SRC" >&2
  "$CHECK_SHUX" check -L . "$VIEW_SRC" 2>&1 || true
  exit 1
fi
echo "zc2: read_ptr_gen/mmap/view typeck OK"

chmod +x tests/run-io-read-ptr-slice.sh
SHUX="$CHECK_SHUX" ./tests/run-io-read-ptr-slice.sh
echo "zc2: read_ptr_slice regression OK"

RUN_SHUX="$CHECK_SHUX"
# -o 链接依赖 std/io 内 read_ptr_*；shux_asm 实验链可能缺这些符号，编译/链接优先 shux-c/shux。
LINK_SHUX=""
for cand in ./compiler/shux-c ./compiler/shux; do
  case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
  if zc2_native_exe "$abs"; then
    LINK_SHUX="$abs"
    break
  fi
done
if [ -n "$LINK_SHUX" ]; then
  RUN_SHUX="$LINK_SHUX"
elif [ -n "$SHUX_ABS" ] && zc2_native_exe "$SHUX_ABS"; then
  RUN_SHUX="$SHUX_ABS"
fi

if ! SHUX="$RUN_SHUX" "$RUN_SHUX" -L . "$GEN_SRC" -o "$GEN_OUT" 2>/tmp/shux_zc2_gen_build.log; then
  echo "zc2 FAIL: compile $GEN_SRC" >&2
  tail -8 /tmp/shux_zc2_gen_build.log 2>/dev/null || true
  exit 1
fi
if ! SHUX="$RUN_SHUX" "$RUN_SHUX" -L . "$MMAP_SRC" -o "$MMAP_OUT" 2>/tmp/shux_zc2_mmap_build.log; then
  echo "zc2 FAIL: compile $MMAP_SRC" >&2
  tail -8 /tmp/shux_zc2_mmap_build.log 2>/dev/null || true
  exit 1
fi
if ! SHUX="$RUN_SHUX" "$RUN_SHUX" -L . "$VIEW_SRC" -o "$VIEW_OUT" 2>/tmp/shux_zc2_view_build.log; then
  echo "zc2 FAIL: compile $VIEW_SRC" >&2
  tail -8 /tmp/shux_zc2_view_build.log 2>/dev/null || true
  exit 1
fi

if [ ! -x "$GEN_OUT" ] || [ ! -x "$MMAP_OUT" ] || [ ! -x "$VIEW_OUT" ]; then
  echo "zc2: compile OK, run SKIP (no native exe)"
  echo "zc2 gate OK"
  exit 0
fi

RC=0
echo -n "AB" | "$GEN_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "zc2 FAIL: read_ptr_gen_smoke expected exit 0, got $RC" >&2
  exit 1
fi
echo "zc2: read_ptr_gen_smoke exit=0 OK"

RC=0
echo -n "AB" | "$VIEW_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "zc2 FAIL: read_ptr_view_smoke expected exit 0, got $RC" >&2
  exit 1
fi
echo "zc2: read_ptr_view_smoke exit=0 OK"

RC=0
"$MMAP_OUT" >/dev/null 2>&1 || RC=$?
MMAP_EXPECT=21
if [ "$(uname -s)" = "Darwin" ]; then
  MMAP_EXPECT=22
fi
# Windows/MSYS：无 Linux mmap / macOS mmap 后端，backend 校验失败（exit 9）为 N/A。
case "$(uname -s)" in
  MINGW*|MSYS*)
    if [ "$RC" = "9" ]; then
      echo "zc2: read_ptr_mmap_smoke N/A (no mmap backend on Windows)"
      echo "zc2 gate OK"
      exit 0
    fi
    ;;
esac
if [ "$RC" != "$MMAP_EXPECT" ]; then
  echo "zc2 FAIL: read_ptr_mmap_smoke expected exit $MMAP_EXPECT (20+backend), got $RC" >&2
  exit 1
fi
echo "zc2: read_ptr_mmap_smoke exit=$RC OK (backend=$((RC - 20)))"
echo "zc2 gate OK"
