#!/usr/bin/env bash
# F-04 v1：std.net TLS stub 去 C 门禁（tls_stub.x + 无 tls_stub.inc.c）。
#
# 用法：./tests/run-f04-std-net-tls-stub-gate.sh
# 环境：SHUX_F04_NET_TLS_STUB_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_TLS_STUB_FAIL:-0}
DOC="analysis/phase-f-f04-v1.md"
TLS_STUB="std/net/tls_stub.x"
NET_MOD="std/net/mod.x"

die() {
  echo "f04-net-tls-stub gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v1: std.net tls_stub remove tls_stub.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v1' "$DOC" || die "doc missing F-04 v1 marker"
[ -f "$TLS_STUB" ] || die "missing tls_stub.x"
[ ! -f std/net/tls_stub.inc.c ] || die "tls_stub.inc.c should be deleted"
grep -q 'net_tls_is_available_c' "$TLS_STUB" || die "tls_stub missing net_tls_is_available_c"
grep -q 'net_tls_last_error_c' "$TLS_STUB" || die "tls_stub missing net_tls_last_error_c"
grep -q 'import("std.net.tls_stub")' "$NET_MOD" || die "mod.x missing tls_stub import"
if grep -q 'extern function net_tls_is_available_c' "$NET_MOD" 2>/dev/null; then
  die "mod.x still extern net_tls_is_available_c"
fi
if grep -q 'tls_stub.inc.c' std/net/net.c 2>/dev/null; then
  die "net.c still includes tls_stub.inc.c"
fi
if grep -q 'tls_stub.inc.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references tls_stub.inc.c"
fi

MANIFEST="tests/baseline/f04-std-net-tls-stub.tsv"
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        target="$TLS_STUB"
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

if [ -f tests/run-std-net-tls-gate.sh ]; then
  echo "=== F-04 v1: delegate run-std-net-tls-gate.sh ==="
  chmod +x tests/run-std-net-tls-gate.sh
  if ! tests/run-std-net-tls-gate.sh; then
    die "std-net-tls sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v1: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.net tls stub gate OK (F-04 v1)"
