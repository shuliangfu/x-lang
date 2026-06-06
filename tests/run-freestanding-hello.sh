#!/usr/bin/env bash
# S4 freestanding 烟测：`-freestanding` 按需链 crt0_user +（可选）runtime_panic +（可选）freestanding_io + --gc-sections
# Alpine/musl：若 shu 尚无 -backend asm（bootstrap 未就绪），回退 musl crt0 syscall 直连烟测。
# 用法（仓库根）：./tests/run-freestanding-hello.sh
# 非 Linux 宿主：skip exit 0（macOS CI 不跑）。

set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "run-freestanding-hello: skip (host is not Linux; freestanding crt0 仅 x86_64 Linux)"
  exit 0
fi

if [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "run-freestanding-hello: skip (freestanding S4 桩仅 x86_64 Linux; host=$(uname -m))"
  exit 0
fi

if [ -z "${SHU:-}" ] && [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ASM_DIR="compiler/src/asm"

# 静态 nostdlib 可执行文件不应动态依赖 libc.so（musl 上 ldd 常报 not a dynamic executable）。
# 按需 runtime 符号：want_io/want_panic 为 0=不得出现，1=必须出现。
freestanding_trim_ok() {
  local prog="$1"
  local want_io="$2"
  local want_panic="${3:-0}"
  if ! command -v nm >/dev/null 2>&1; then
    return 0
  fi
  if [ "$want_io" = "0" ]; then
    if nm "$prog" 2>/dev/null | grep -q 'shulang_sys_write'; then
      echo "run-freestanding-hello: FAIL $prog should not link shulang_sys_write (trim io)"
      exit 1
    fi
  elif [ "$want_io" = "1" ]; then
    if ! nm "$prog" 2>/dev/null | grep -q 'shulang_sys_write'; then
      echo "run-freestanding-hello: FAIL $prog missing shulang_sys_write"
      exit 1
    fi
  fi
  if [ "$want_panic" = "0" ]; then
    if nm "$prog" 2>/dev/null | grep -q 'shulang_panic_'; then
      echo "run-freestanding-hello: FAIL $prog should not link shulang_panic_ (trim panic)"
      exit 1
    fi
  elif [ "$want_panic" = "1" ]; then
    if ! nm "$prog" 2>/dev/null | grep -q 'shulang_panic_'; then
      echo "run-freestanding-hello: FAIL $prog missing shulang_panic_"
      exit 1
    fi
  fi
  echo "run-freestanding-hello: trim OK ($prog io=$want_io panic=$want_panic)"
}
freestanding_no_libc() {
  local prog="$1"
  if command -v ldd >/dev/null 2>&1; then
    if ldd "$prog" 2>&1 | grep -qi 'libc\.so'; then
      echo "run-freestanding-hello: FAIL $prog linked against libc.so"
      ldd "$prog" || true
      exit 1
    fi
  fi
}

# Alpine/musl 回退：手工汇编 crt0/panic +（按需）io + C 桩 _main
freestanding_musl_link_smoke() {
  local rv="$TMP/return42"
  local hello="$TMP/hello"
  cc -c -o "$TMP/crt0_user.o" "$ASM_DIR/crt0_user_x86_64.s"
  cat >"$TMP/return42_main.c" <<'EOF'
/** musl 烟测桩：等价 tests/freestanding/return42/main.su（crt0_user 经 call main 进入） */
int main(void) { return 42; }
EOF
  cc -c -o "$TMP/return42_main.o" "$TMP/return42_main.c"
  ld -nostdlib -static --gc-sections -o "$rv" \
    "$TMP/crt0_user.o" "$TMP/return42_main.o"
  freestanding_no_libc "$rv"
  freestanding_trim_ok "$rv" 0 0
  EX=0
  "$rv" >/dev/null 2>&1 || EX=$?
  if [ "$EX" -ne 42 ]; then
    echo "run-freestanding-hello: musl return42 expected exit 42, got $EX"
    exit 1
  fi
  echo "run-freestanding-hello: musl return42 OK (exit 42, nostdlib static)"

  cat >"$TMP/hello_main.c" <<'EOF'
/** musl 烟测桩：等价 tests/freestanding/hello/main.su（crt0_user 经 call main 进入） */
extern long shulang_sys_write(int fd, const void *buf, unsigned long len);
int main(void) {
  static const char msg[] = "Hello Shu!\n";
  if (shulang_sys_write(1, msg, 11) != 11) {
    return 1;
  }
  return 0;
}
EOF
  cc -c -o "$TMP/freestanding_io.o" "$ASM_DIR/freestanding_io_x86_64.s"
  cc -c -o "$TMP/hello_main.o" "$TMP/hello_main.c"
  ld -nostdlib -static --gc-sections -o "$hello" \
    "$TMP/crt0_user.o" "$TMP/freestanding_io.o" "$TMP/hello_main.o"
  freestanding_no_libc "$hello"
  freestanding_trim_ok "$hello" 1 0
  set +e
  OUT=$("$hello" 2>/dev/null)
  EX=$?
  set -e
  if [ "$EX" -ne 0 ]; then
    echo "run-freestanding-hello: musl hello expected exit 0, got $EX"
    exit 1
  fi
  EXPECTED=$(printf 'Hello Shu!\n')
  if [ "$OUT" != "$EXPECTED" ]; then
    echo "run-freestanding-hello: musl hello stdout mismatch (expected 'Hello Shu!\\n', got '$OUT')"
    exit 1
  fi
  echo "run-freestanding-hello: musl hello OK (stdout 'Hello Shu!', syscall write)"
}

# 探测 shu 是否具备 -freestanding + -backend asm 链入能力
SHU_ASM=0
if [ -n "${SHU:-}" ] && [ -x "$SHU" ]; then
  if "$SHU" -freestanding -backend asm tests/freestanding/return42/main.su -o "$TMP/probe" 2>/dev/null; then
    SHU_ASM=1
    rm -f "$TMP/probe"
  fi
fi

if [ "$SHU_ASM" != "1" ]; then
  echo "run-freestanding-hello: shu -backend asm unavailable; musl crt0 syscall link smoke"
  freestanding_musl_link_smoke
  echo "run-freestanding-hello OK (musl link smoke)"
  exit 0
fi

# return42：仅 syscall exit（完整 shu asm 路径）
RV="$TMP/return42"
"$SHU" -freestanding -backend asm tests/freestanding/return42/main.su -o "$RV" 2>/dev/null
freestanding_no_libc "$RV"
EX=0
"$RV" >/dev/null 2>&1 || EX=$?
if [ "$EX" -ne 42 ]; then
  echo "run-freestanding-hello: return42 expected exit 42, got $EX"
  exit 1
fi
echo "run-freestanding-hello: return42 OK (exit 42)"
freestanding_trim_ok "$RV" 0 0

# panic_div：除零 → shulang_panic_，须按需链 runtime_panic.o
PANIC="$TMP/panic_div"
"$SHU" -freestanding -backend asm tests/freestanding/panic_div/main.su -o "$PANIC" 2>/dev/null
freestanding_no_libc "$PANIC"
freestanding_trim_ok "$PANIC" 0 1
EX=0
"$PANIC" >/dev/null 2>&1 || EX=$?
if [ "$EX" -ne 134 ]; then
  echo "run-freestanding-hello: panic_div expected exit 134, got $EX"
  exit 1
fi
echo "run-freestanding-hello: panic_div OK (exit 134, shulang_panic_)"

# hello：shulang_sys_write → stdout
HELLO="$TMP/hello"
"$SHU" -freestanding -backend asm tests/freestanding/hello/main.su -o "$HELLO" 2>/dev/null
freestanding_no_libc "$HELLO"
set +e
OUT=$("$HELLO" 2>/dev/null)
EX=$?
set -e
if [ "$EX" -ne 0 ]; then
  echo "run-freestanding-hello: hello expected exit 0, got $EX"
  exit 1
fi
EXPECTED=$(printf 'Hello Shu!\n')
if [ "$OUT" != "$EXPECTED" ]; then
  echo "run-freestanding-hello: hello stdout mismatch (expected 'Hello Shu!\\n', got '$OUT')"
  exit 1
fi
echo "run-freestanding-hello: hello OK (stdout 'Hello Shu!', syscall write)"
freestanding_trim_ok "$HELLO" 1 0

echo "run-freestanding-hello OK"
