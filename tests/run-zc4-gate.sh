#!/usr/bin/env bash
# ZC-4 门禁：StrView 零拷贝 + Arena64 concat（无 per-concat heap_alloc）。
# 用法：
#   ./tests/run-zc4-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-zc4-gate.sh
set -e
cd "$(dirname "$0")/.."

XLANG_BIN="${XLANG:-}"
case "$XLANG_BIN" in
  /*) XLANG_ABS="$XLANG_BIN" ;;
  "") XLANG_ABS="" ;;
  *) XLANG_ABS="$(pwd)/$XLANG_BIN" ;;
esac

zc4_native_exe() {
  local f="$1"
  local os arch
  [ -n "$f" ] && [ -x "$f" ] || return 1
  os="$(uname -s 2>/dev/null || echo unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  # Docker slim / Alpine 常无 file(1)；可 exec 即视为本机 native。
  if ! command -v file >/dev/null 2>&1; then
    case "$os" in
      Linux|Darwin) return 0 ;;
      *) return 0 ;;
    esac
  fi
  case "${os}-${arch}" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 从候选列表选首个 native 编译器；typeck 与 import std.string/heap 用户链均优先 xlang-c。
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

CHECK_XLANG="$(zc4_pick_native_shu ./compiler/xlang-c ./compiler/xlang ./compiler/xlang_asm)" || CHECK_XLANG=""

if [ -z "$CHECK_XLANG" ]; then
  if make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null; then
    if [ -x ./compiler/xlang-c ]; then
      CHECK_XLANG=./compiler/xlang-c
    fi
  fi
fi

if [ -z "$CHECK_XLANG" ]; then
  echo "zc4 gate SKIP (no working xlang-c/xlang)"
  exit 0
fi

# 编译/运行：import std.string/heap 时 xlang_asm co-emit 暂缺 .x 符号，须 xlang-c（CI 可 XLANG=xlang_asm 跑 typeck 上下文）
RUN_XLANG="$(zc4_pick_native_shu ./compiler/xlang-c ./compiler/xlang)" || RUN_XLANG=""
if [ -z "$RUN_XLANG" ]; then
  RUN_XLANG="$(zc4_pick_native_shu ./compiler/xlang_asm)" || RUN_XLANG="$CHECK_XLANG"
fi
if [ -n "$XLANG_ABS" ] && zc4_native_exe "$XLANG_ABS" ] && [ -z "${XLANG_ZC4_FORCE_COMPILE_ASM:-}" ]; then
  case "$XLANG_ABS" in *xlang_asm*) ;; *) RUN_XLANG="$XLANG_ABS" ;; esac
fi
[ -n "$RUN_XLANG" ] || RUN_XLANG="$CHECK_XLANG"

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
SUBVIEW_OUT="$OUT_DIR/xlang_zc4_subview"
CONCAT_OUT="$OUT_DIR/xlang_zc4_arena_concat"
SSO_OUT="$OUT_DIR/xlang_zc4_stack_str"
rm -f "$SUBVIEW_OUT" "$CONCAT_OUT" "$SSO_OUT"

echo "=== ZC-4: StrView subview + arena concat + SSO_STACK ==="

# 确保 C 运行时 object 含 ptr_at 与 Arena64
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/string/string.o
# F-03 v2：heap 已纯 .x，不再 ensure heap.o

SUBVIEW_SRC="tests/string/view_subview_smoke.x"
CONCAT_SRC="tests/string/arena_concat_smoke.x"
SSO_SRC="tests/string/stack_str_sso_smoke.x"

if ! "$CHECK_XLANG" check -L . "$SUBVIEW_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $SUBVIEW_SRC" >&2
  "$CHECK_XLANG" check -L . "$SUBVIEW_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_XLANG" check -L . "$CONCAT_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $CONCAT_SRC" >&2
  "$CHECK_XLANG" check -L . "$CONCAT_SRC" 2>&1 || true
  exit 1
fi
if ! "$CHECK_XLANG" check -L . "$SSO_SRC" >/dev/null 2>&1; then
  echo "zc4 FAIL: typeck $SSO_SRC" >&2
  "$CHECK_XLANG" check -L . "$SSO_SRC" 2>&1 || true
  exit 1
fi
echo "zc4: subview/arena_concat/stack_str typeck OK"

chmod +x tests/run-string.sh
XLANG="$CHECK_XLANG" ./tests/run-string.sh
echo "zc4: run-string OK"

if [ "$RUN_XLANG" != "$CHECK_XLANG" ] && [ -n "$RUN_XLANG" ]; then
  echo "zc4: compile via $(basename "$RUN_XLANG") (import std.string/heap; xlang_asm co-emit pending)"
fi

if ! XLANG="$RUN_XLANG" "$RUN_XLANG" -L . "$SUBVIEW_SRC" -o "$SUBVIEW_OUT" 2>/tmp/xlang_zc4_subview_build.log; then
  echo "zc4 FAIL: compile $SUBVIEW_SRC" >&2
  tail -8 /tmp/xlang_zc4_subview_build.log 2>/dev/null || true
  exit 1
fi
if ! XLANG="$RUN_XLANG" "$RUN_XLANG" -L . "$CONCAT_SRC" -o "$CONCAT_OUT" 2>/tmp/xlang_zc4_concat_build.log; then
  echo "zc4 FAIL: compile $CONCAT_SRC" >&2
  tail -8 /tmp/xlang_zc4_concat_build.log 2>/dev/null || true
  exit 1
fi
if ! XLANG="$RUN_XLANG" "$RUN_XLANG" -L . "$SSO_SRC" -o "$SSO_OUT" 2>/tmp/xlang_zc4_sso_build.log; then
  echo "zc4 FAIL: compile $SSO_SRC" >&2
  tail -8 /tmp/xlang_zc4_sso_build.log 2>/dev/null || true
  exit 1
fi

if [ ! -x "$SUBVIEW_OUT" ] || [ ! -x "$CONCAT_OUT" ] || [ ! -x "$SSO_OUT" ]; then
  echo "zc4: compile OK, run SKIP (no native exe; typeck-only on this host)"
  chmod +x tests/run-perf-string-arena.sh
  XLANG="$RUN_XLANG" ./tests/run-perf-string-arena.sh
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
XLANG="$RUN_XLANG" ./tests/run-perf-string-arena.sh
echo "zc4 gate OK"
