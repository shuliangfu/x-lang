#!/usr/bin/env bash
# BOOT-029：std.sys freestanding write 门禁
#
# 用法：./tests/run-std-sys-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SYS_DOC:-analysis/std-sys-v0.md}"
MANIFEST="${SHUX_STD_SYS_TSV:-tests/baseline/std-sys-manifest.tsv}"
MOD_X="std/sys/mod.x"
SMOKE_X="tests/sys/sys_write_freestanding.x"
MIN_APIS=5
PREFIX="shux: [SHUX_BOOT029_STD_SYS]"

LINUX_MOD="std/sys/linux.x"
MACOS_MOD="std/sys/macos.x"
FREEBSD_MOD="std/sys/freebsd.x"
SMOKE_LINUX="tests/sys/linux_syscall_nr_smoke.x"
SMOKE_MACOS="tests/sys/macos_posix_write_smoke.x"
SMOKE_FREEBSD="tests/sys/freebsd_posix_write_smoke.x"

echo "=== BOOT-029: std.sys manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$LINUX_MOD" "$MACOS_MOD" "$FREEBSD_MOD" "$SMOKE_X" "$SMOKE_LINUX" "$SMOKE_MACOS" "$SMOKE_FREEBSD" std/sys/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sys gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in BOOT-029 os_write shux_sys_write freestanding linux.x macos.x macos_write; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-sys gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

API_N=0
MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-sys FAIL: missing api $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
        echo "std-sys FAIL: missing symbol $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      [ -f "$anchor" ] || { echo "std-sys FAIL: missing $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sys gate FAIL: api count $API_N < $MIN_APIS" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "${PREFIX} status=fail"
  exit 1
fi
echo "std-sys manifest OK"

CHECK_OK=0
RUN_LINUX=0
RUN_MACOS=0
SKIP_LINUX=1
SKIP_MACOS=1

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ] && [ -x ./compiler/shux ]; then
  SHUX_BIN=./compiler/shux
fi

if [ -n "$SHUX_BIN" ] && [ -x "$SHUX_BIN" ]; then
  TYPECK_FAIL=0
  # 公共烟测：os_write_stdout 双平台 #[cfg] 均有定义。
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    TYPECK_FAIL=1
  fi
  HOSTOS="$(uname -s 2>/dev/null)"
  # Linux：mod 层 linux_syscall_* + std.sys.linux 子模块烟测。
  if [ "$HOSTOS" = "Linux" ]; then
    if ! "$SHUX_BIN" check -L . "$SMOKE_LINUX" >/dev/null 2>&1; then
      TYPECK_FAIL=1
    fi
  fi
  # Darwin：再验 macOS mod 层 macos_write_* 烟测（Linux host 无此 #[cfg] 符号）。
  if [ "$HOSTOS" = "Darwin" ]; then
    if ! "$SHUX_BIN" check -L . "$SMOKE_LINUX" >/dev/null 2>&1; then
      TYPECK_FAIL=1
    fi
    if ! "$SHUX_BIN" check -L . "$SMOKE_MACOS" >/dev/null 2>&1; then
      TYPECK_FAIL=1
    fi
  fi
  if [ "$HOSTOS" = "FreeBSD" ]; then
    if ! "$SHUX_BIN" check -L . "$SMOKE_FREEBSD" >/dev/null 2>&1; then
      TYPECK_FAIL=1
    fi
  fi
  if [ "$TYPECK_FAIL" -eq 0 ]; then
    CHECK_OK=1
    echo "std-sys typeck OK"
  else
    echo "std-sys gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -5 >&2 || true
    if [ "$HOSTOS" = "Linux" ]; then
      "$SHUX_BIN" check -L . "$SMOKE_LINUX" 2>&1 | tail -5 >&2 || true
    fi
    if [ "$HOSTOS" = "Darwin" ]; then
      "$SHUX_BIN" check -L . "$SMOKE_LINUX" 2>&1 | tail -5 >&2 || true
      "$SHUX_BIN" check -L . "$SMOKE_MACOS" 2>&1 | tail -5 >&2 || true
    fi
    echo "${PREFIX} status=fail"
    exit 1
  fi
fi

if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ] \
   && [ -n "$SHUX_BIN" ] && "$SHUX_BIN" -freestanding -backend asm "$SMOKE_X" -o /tmp/shux_sys_write_smoke 2>/dev/null \
   && [ -x /tmp/shux_sys_write_smoke ]; then
  SKIP_LINUX=0
  set +e
  OUT=$(/tmp/shux_sys_write_smoke 2>/dev/null)
  EX=$?
  set -e
  rm -f /tmp/shux_sys_write_smoke
  EXPECTED=$(printf 'Hello Shu!\n')
  if [ "$EX" -eq 0 ] && [ "$OUT" = "$EXPECTED" ]; then
    RUN_LINUX=1
    echo "std-sys freestanding run OK"
  else
    echo "std-sys gate FAIL: freestanding run exit=$EX out='$OUT'" >&2
    echo "${PREFIX} status=fail"
    exit 1
  fi
else
  echo "std-sys gate SKIP freestanding run (need Linux x86_64 + shux -freestanding -backend asm)" >&2
fi

if [ "$(uname -s 2>/dev/null)" = "Darwin" ] && [ -n "$SHUX_BIN" ] \
   && "$SHUX_BIN" "$SMOKE_MACOS" -o /tmp/shux_macos_write_smoke 2>/dev/null \
   && [ -x /tmp/shux_macos_write_smoke ]; then
  SKIP_MACOS=0
  set +e
  OUT=$(/tmp/shux_macos_write_smoke 2>/dev/null)
  EX=$?
  set -e
  rm -f /tmp/shux_macos_write_smoke
  EXPECTED=$(printf 'Hello Shu!\n')
  if [ "$EX" -eq 0 ] && [ "$OUT" = "$EXPECTED" ]; then
    RUN_MACOS=1
    echo "std-sys macOS posix write run OK"
  else
    echo "std-sys gate FAIL: macOS run exit=$EX out='$OUT'" >&2
    echo "${PREFIX} status=fail"
    exit 1
  fi
else
  echo "std-sys gate SKIP macOS run (need Darwin + shux -o exe)" >&2
fi

echo "${PREFIX} status=ok check=${CHECK_OK} run_linux=${RUN_LINUX} run_macos=${RUN_MACOS} skip_linux=${SKIP_LINUX} skip_macos=${SKIP_MACOS}"
echo "std-sys gate OK"
