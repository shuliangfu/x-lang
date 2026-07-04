#!/usr/bin/env bash
# STD-003：std.fs 跨平台对齐门禁（Linux / macOS / Windows 同一套 .x）
#
# 读取 tests/baseline/std-fs-crossplatform.tsv，按平台策略跑 must/skip/optional。
# 用法：./tests/run-std-fs-crossplatform-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

BASELINE="tests/baseline/std-fs-crossplatform.tsv"
MATRIX="${SHUX_STD_FS_CROSSPLATFORM_TSV:-$BASELINE}"

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
}

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

if [ ! -f "$MATRIX" ]; then
  echo "std-fs-crossplatform gate FAIL: missing $MATRIX" >&2
  exit 1
fi

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/io/io.o -q 2>/dev/null \
  || make -C compiler ../std/io/io.o

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "std-fs-crossplatform gate SKIP (no native shux; host=$(ci_host_summary))" >&2
  exit 0
fi

echo "=== STD-003: std.fs cross-platform ($(ci_host_summary) SHUX=$SHUX_BIN) ==="

run_x_case() {
  local script="$1"
  local src="tests/fs/${script}"
  local out="/tmp/shux_fs_xplat_${script%.x}"
  rm -f tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  "$SHUX_BIN" -L . "$src" -o "$out" >/tmp/shux_fs_xplat_compile.log 2>&1 || {
    cat /tmp/shux_fs_xplat_compile.log >&2
    return 1
  }
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f tests/fs/.crossplatform_tmp tests/fs/.mmap_ro_tmp
  return "$ec"
}

FAILS=0
while IFS=$'\t' read -r case_id script linux pol_mac pol_win notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  case "$pol" in
    skip)
      echo "std-fs xplat SKIP $case_id ($notes)"
      continue
      ;;
  esac

  if [ "$script" = "run-fs.sh" ]; then
    echo "── case $case_id: $script ──"
    chmod +x tests/run-fs.sh
    if SHUX="$SHUX_BIN" ./tests/run-fs.sh; then
      echo "std-fs xplat OK $case_id"
    else
      if [ "$pol" = "optional" ]; then
        echo "std-fs xplat WARN $case_id (optional)" >&2
      else
        echo "std-fs xplat FAIL $case_id" >&2
        FAILS=$((FAILS + 1))
      fi
    fi
    continue
  fi

  if [ ! -f "tests/fs/${script}" ]; then
    echo "std-fs xplat FAIL $case_id: missing tests/fs/${script}" >&2
    FAILS=$((FAILS + 1))
    continue
  fi

  echo "── case $case_id: tests/fs/${script} ──"
  if run_x_case "$script"; then
    echo "std-fs xplat OK $case_id"
  else
    if [ "$pol" = "optional" ]; then
      echo "std-fs xplat WARN $case_id (optional exit!=0)" >&2
    else
      echo "std-fs xplat FAIL $case_id (exit!=0)" >&2
      FAILS=$((FAILS + 1))
    fi
  fi
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "std-fs-crossplatform gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "std-fs-crossplatform gate OK"
