#!/usr/bin/env bash
# F-04 v2：std.net tcp_pool 去 C 门禁（tcp_pool.x + 无 tcp_pool.inc.c）。
#
# 用法：./tests/run-f04-std-net-tcp-pool-gate.sh
# 环境：SHUX_F04_NET_TCP_POOL_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_TCP_POOL_FAIL:-0}
DOC="analysis/phase-f-f04-v2.md"
TCP_POOL="std/net/tcp_pool.x"
NET_MOD="std/net/mod.x"
MANIFEST="tests/baseline/f04-std-net-tcp-pool.tsv"

die() {
  echo "f04-net-tcp-pool gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v2: std.net tcp_pool remove tcp_pool.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v2' "$DOC" || die "doc missing F-04 v2 marker"
[ -f "$TCP_POOL" ] || die "missing tcp_pool.x"
[ ! -f std/net/tcp_pool.inc.c ] || die "tcp_pool.inc.c should be deleted"
grep -q 'net_tcp_pool_create_c' "$TCP_POOL" || die "tcp_pool missing create"
grep -q 'net_tcp_pool_smoke_c' "$TCP_POOL" || die "tcp_pool missing smoke"
grep -q 'import("std.net.tcp_pool")' "$NET_MOD" || die "mod.x missing tcp_pool import"
if grep -q 'extern function net_tcp_pool_create_c' "$NET_MOD" 2>/dev/null; then
  die "mod.x still extern net_tcp_pool_create_c"
fi
if grep -q 'tcp_pool.inc.c' std/net/net.c 2>/dev/null; then
  die "net.c still includes tcp_pool.inc.c"
fi

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$TCP_POOL"
        case "$mod_path" in
          std/net/mod.x) target="$NET_MOD" ;;
        esac
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
    esac
  done < "$MANIFEST"
fi

if [ -f tests/baseline/next-yellow-clear.tsv ]; then
  grep -q 'tcp_pool_new' "$NET_MOD" || die "next-yellow tcp_pool_new missing in mod.x"
fi

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
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  export SHUX="$SHUX_BIN"
  if [ -f tests/net/tcp_pool_smoke.x ]; then
    echo "=== F-04 v2: typecheck tcp_pool_smoke.x (SHUX=$SHUX_BIN) ==="
    if ! "$SHUX_BIN" check -L . tests/net/tcp_pool_smoke.x >/dev/null 2>&1; then
      die "typeck tcp_pool_smoke.x failed"
    fi
  fi
else
  echo "f04-tcp-pool: SKIP runtime sub-gates (no native shux on this host)"
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v2: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.net tcp_pool gate OK (F-04 v2)"
