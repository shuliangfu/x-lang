#!/usr/bin/env bash
# ZC-4 门禁：StrView 零拷贝 + Arena64 concat（无 per-concat heap_alloc）。
# 用法：
#   ./tests/run-zc4-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-zc4-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

zc4_native_exe() {
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

# 从候选列表选首个 native 编译器；typeck 与 import std.string/heap 用户链均优先 shu-c。
zc4_pick_native_shu() {
  local cand abs
  for cand in "$@"; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if zc4_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

CHECK_SHU="$(zc4_pick_native_shu ./compiler/shu-c ./compiler/shu ./compiler/shu_asm)" || CHECK_SHU=""
# 编译/运行：import std.string/heap 时 shu_asm co-emit 暂缺 .su 符号，须 shu-c（CI 可 SHU=shu_asm 跑 typeck 上下文）
RUN_SHU="$(zc4_pick_native_shu ./compiler/shu-c ./compiler/shu)" || RUN_SHU=""
if [ -z "$RUN_SHU" ]; then
  RUN_SHU="$(zc4_pick_native_shu ./compiler/shu_asm)" || RUN_SHU="$CHECK_SHU"
fi
if [ -n "$SHU_ABS" ] && zc4_native_exe "$SHU_ABS" ] && [ -z "${SHU_ZC4_FORCE_COMPILE_ASM:-}" ]; then
  case "$SHU_ABS" in *shu_asm*) ;; *) RUN_SHU="$SHU_ABS" ;; esac
fi

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
SUBVIEW_OUT="$OUT_DIR/shu_zc4_subview"
CONCAT_OUT="$OUT_DIR/shu_zc4_arena_concat"
SSO_OUT="$OUT_DIR/shu_zc4_stack_str"
rm -f "$SUBVIEW_OUT" "$CONCAT_OUT" "$SSO_OUT"

echo "=== ZC-4: StrView subview + arena concat + SSO_STACK ==="

if [ -z "$CHECK_SHU" ]; then
  if make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null; then
    if [ -x ./compiler/shu-c ]; then
      CHECK_SHU=./compiler/shu-c
    fi
  fi
fi

if [ -z "$CHECK_SHU" ]; then
  echo "zc4 gate SKIP (no working shu-c/shu)"
  exit 0
fi

# 确保 C 运行时 object 含 ptr_at 与 Arena64
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/string/string.o
ensure_std_c_o ../std/heap/heap.o

SUBVIEW_SRC="tests/string/view_subview_smoke.su"
CONCAT_SRC="tests/string/arena_concat_smoke.su"
SSO_SRC="tests/string/stack_str_sso_smoke.su"

if ! "$CHECK_SHU" check -L . "$SUBVIEW_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $SUBVIEW_SRC" >&2
  "$CHECK_SHU" check -L . "$SUBVIEW_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_SHU" check -L . "$CONCAT_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $CONCAT_SRC" >&2
  "$CHECK_SHU" check -L . "$CONCAT_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_SHU" check -L . "$SSO_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $SSO_SRC" >&2
  "$CHECK_SHU" check -L . "$SSO_SRC" 2>&1 || true
  exit 1
fi
echo "zc4: subview/arena_concat/stack_str typeck OK"

chmod +x tests/run-string.sh
SHU="$CHECK_SHU" ./tests/run-string.sh
echo "zc4: run-string OK"

if [ "$RUN_SHU" != "$CHECK_SHU" ] && [ -n "$RUN_SHU" ]; then
  echo "zc4: compile via $(basename "$RUN_SHU") (import std.string/heap; shu_asm co-emit pending)"
fi

if ! SHU="$RUN_SHU" "$RUN_SHU" -L . "$SUBVIEW_SRC" -o "$SUBVIEW_OUT" 2>/tmp/shu_zc4_subview_build.log; then
  echo "zc4 FAIL: compile $SUBVIEW_SRC" >&2
  tail -8 /tmp/shu_zc4_subview_build.log 2>/dev/null || true
  exit 1
fi
if ! SHU="$RUN_SHU" "$RUN_SHU" -L . "$CONCAT_SRC" -o "$CONCAT_OUT" 2>/tmp/shu_zc4_concat_build.log; then
  echo "zc4 FAIL: compile $CONCAT_SRC" >&2
  tail -8 /tmp/shu_zc4_concat_build.log 2>/dev/null || true
  exit 1
fi
if ! SHU="$RUN_SHU" "$RUN_SHU" -L . "$SSO_SRC" -o "$SSO_OUT" 2>/tmp/shu_zc4_sso_build.log; then
  echo "zc4 FAIL: compile $SSO_SRC" >&2
  tail -8 /tmp/shu_zc4_sso_build.log 2>/dev/null || true
  exit 1
fi

if [ ! -x "$SUBVIEW_OUT" ] || [ ! -x "$CONCAT_OUT" ] || [ ! -x "$SSO_OUT" ]; then
  echo "zc4: compile OK, run SKIP (no native exe; typeck-only on this host)"
  chmod +x tests/run-perf-string-arena.sh
  SHU="$RUN_SHU" ./tests/run-perf-string-arena.sh
  echo "zc4 gate OK"
  exit 0
fi

RC=0
"$SUBVIEW_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "zc4 FAIL: view_subview_smoke expected exit 0, got $RC" >&2
  exit 1
fi
echo "zc4: view_subview_smoke exit=0 OK"

RC=0
"$CONCAT_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "zc4 FAIL: arena_concat_smoke expected exit 0, got $RC" >&2
  exit 1
fi
echo "zc4: arena_concat_smoke exit=0 OK"

RC=0
"$SSO_OUT" >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "zc4 FAIL: stack_str_sso_smoke expected exit 0, got $RC" >&2
  exit 1
fi
echo "zc4: stack_str_sso_smoke exit=0 OK"

chmod +x tests/run-perf-string-arena.sh
SHU="$RUN_SHU" ./tests/run-perf-string-arena.sh
echo "zc4 gate OK"
