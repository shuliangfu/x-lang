#!/usr/bin/env bash
# TST-001：P0 模块边界测试波次 1 门禁（io/fs/net/string）
#
# manifest + case 计数 + typeck + 链接烟测
# 用法：./tests/run-tst-001-boundary-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TST001_DOC:-analysis/tst-001-boundary-wave1-v1.md}"
MANIFEST="${SHUX_TST001_TSV:-tests/baseline/tst-001-boundary-wave1.tsv}"
LIB="tests/lib/tst-001-boundary.sh"
MIN_CASES=8

# shellcheck source=tests/lib/tst-001-boundary.sh
. tests/lib/tst-001-boundary.sh

echo "=== TST-001: boundary wave 1 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "tst-001-boundary gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases_per_mod) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

for kw in std.io std.fs std.net std.string boundary case 边界; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "tst-001-boundary gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

miss="$(tst001_verify_manifest "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  tst001_emit_report "fail" 0 0 0 0 1
  echo "tst-001-boundary gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi

BOUNDARY_N=0
while IFS=$'\t' read -r item_id kind path min_cases _mod _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|doc|gate) continue ;; esac
  case "$kind" in
    boundary)
      BOUNDARY_N=$((BOUNDARY_N + 1))
      want="${min_cases:-$MIN_CASES}"
      if ! tst001_count_cases "$path" "$want" >/dev/null; then
        tst001_emit_report "fail" 0 0 0 0 1
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$BOUNDARY_N" -lt 4 ]; then
  echo "tst-001-boundary gate FAIL: modules=${BOUNDARY_N} want 4" >&2
  exit 1
fi
echo "tst-001-boundary manifest OK (modules=${BOUNDARY_N} min_cases=${MIN_CASES})"

stdlib_cm_native_shu() {
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

IO_OK=0
FS_OK=0
NET_OK=0
STR_OK=0
SKIP=1
SHUX_BIN=""

for cand in ./compiler/shux-c ./compiler/shux; do
  if stdlib_cm_native_shu "$cand"; then
    SHUX_BIN="$cand"
    break
  fi
done

if [ -n "$SHUX_BIN" ]; then
  echo "=== TST-001: typeck + smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  make -C compiler -q ../std/net/net.o ../std/fs/fs.o 2>/dev/null \
    || make -C compiler ../std/net/net.o ../std/fs/fs.o 2>/dev/null || true
  for su in tests/io/boundary.sx tests/fs/boundary.sx tests/net/boundary.sx tests/string/boundary.sx; do
    if ! "$SHUX_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "tst-001-boundary gate FAIL: typeck $su" >&2
      "$SHUX_BIN" check -L . "$su" 2>&1 | tail -8 >&2 || true
      tst001_emit_report "fail" "$IO_OK" "$FS_OK" "$NET_OK" "$STR_OK" 0
      exit 1
    fi
  done
  if tst001_run_boundary "$SHUX_BIN" tests/io/boundary.sx /tmp/shux_tst001_io; then
    IO_OK=1
  else
    tst001_emit_report "fail" 0 0 0 0 0
    exit 1
  fi
  if tst001_run_boundary "$SHUX_BIN" tests/fs/boundary.sx /tmp/shux_tst001_fs; then
    FS_OK=1
  else
    tst001_emit_report "fail" "$IO_OK" 0 0 0 0
    exit 1
  fi
  if tst001_run_boundary "$SHUX_BIN" tests/net/boundary.sx /tmp/shux_tst001_net; then
    NET_OK=1
  else
    tst001_emit_report "fail" "$IO_OK" "$FS_OK" 0 0 0
    exit 1
  fi
  if tst001_run_boundary "$SHUX_BIN" tests/string/boundary.sx /tmp/shux_tst001_str; then
    STR_OK=1
  else
    tst001_emit_report "fail" "$IO_OK" "$FS_OK" "$NET_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "tst-001-boundary gate SKIP smoke (no native shux-c)" >&2
fi

tst001_emit_report "ok" "$IO_OK" "$FS_OK" "$NET_OK" "$STR_OK" "$SKIP"
echo "tst-001-boundary gate OK"
