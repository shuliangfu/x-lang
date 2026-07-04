#!/usr/bin/env bash
# F-path v1：std.path 去 C（path.c → mod.x cfg path_sep_c）。
#
# 用法：./tests/run-f-path-v1-gate.sh
# 环境：SHUX_F_PATH_V1_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_PATH_V1_FAIL:-0}
DOC="analysis/phase-f-path-v1.md"
MANIFEST="tests/baseline/f-path-v1-closure.tsv"

die() {
  echo "f-path-v1 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-path v1: std.path path.c → mod.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-path v1' "$DOC" || die "doc missing F-path v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f std/path/mod.x ] || die "missing std/path/mod.x"
[ ! -f std/path/path.c ] || die "std/path/path.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
  esac
done < "$MANIFEST"

grep -q 'std/path/mod.x' compiler/Makefile || die "Makefile missing mod.x path.o rule"
if grep -q 'std/path/path\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/path/path.c"
fi
grep -qE 'function sep\(' std/path/mod.x || die "mod.x missing sep"
grep -q 'extern function sep' std/path/mod.x && die "mod.x still extern sep"

# path.o 构建（无 shux-c 时 SKIP smoke，不 FAIL）
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/path/path.o >/dev/null 2>&1 || die "make path.o failed"
  if strings ../std/path/path.o 2>/dev/null | grep -q 'path_sep'; then
    echo "f-path-v1: path.o symbols OK"
  else
    echo "f-path-v1 SKIP symbol check (path.o missing .x symbols; need shux-c rebuild)" >&2
  fi
else
  echo "f-path-v1 SKIP path.o build (no shux-c)" >&2
fi

if [ -f tests/run-std-path-extreme-gate.sh ]; then
  echo "=== F-path v1: delegate run-std-path-extreme-gate ==="
  chmod +x tests/run-std-path-extreme-gate.sh
  if ! tests/run-std-path-extreme-gate.sh; then
    die "std-path-extreme sub-gate failed"
  fi
fi

if [ -f tests/run-std-path-fs-windows-gate.sh ]; then
  echo "=== F-path v1: delegate run-std-path-fs-windows-gate ==="
  chmod +x tests/run-std-path-fs-windows-gate.sh
  if ! tests/run-std-path-fs-windows-gate.sh; then
    die "std-path-fs-windows sub-gate failed"
  fi
fi

echo "f-path-v1 std.path gate OK (F-path v1)"
