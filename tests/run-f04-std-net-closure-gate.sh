#!/usr/bin/env bash
# F-04 v15：std.net 宿主路径闭合门禁（v1～v14 聚合 + manifest）。
#
# 用法：./tests/run-f04-std-net-closure-gate.sh
# 环境：SHUX_F04_NET_CLOSURE_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_CLOSURE_FAIL:-0}
DOC="analysis/phase-f-f04-v15.md"
MANIFEST="tests/baseline/f04-std-net-closure.tsv"

die() {
  echo "f04-net-closure gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v15: std.net hosted path closure ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v15' "$DOC" || die "doc missing F-04 v15 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"

while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|script|manifest)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
  esac
done < "$MANIFEST"

grep -q 'runtime_net_workers' compiler/Makefile || die "Makefile missing runtime_net in net.o"
if grep -q 'std/net/net\.c' compiler/Makefile 2>/dev/null; then
  die "Makefile still references std/net/net.c"
fi

if [ -f tests/run-f04-std-net-slice-v14-gate.sh ]; then
  echo "=== F-04 v15: delegate v14 slice gate ==="
  chmod +x tests/run-f04-std-net-slice-v14-gate.sh
  if ! SHUX_F04_NET_SLICE_V14_FAIL="$FAIL" tests/run-f04-std-net-slice-v14-gate.sh; then
    die "v14 sub-gate failed"
  fi
fi

for sub in run-f04-std-net-dns-alpn-gate.sh run-f04-std-net-tcp-pool-gate.sh \
  run-f04-std-net-tls-stub-gate.sh run-f04-std-net-ws-gate.sh; do
  if [ -f "tests/$sub" ]; then
    echo "=== F-04 v15: delegate $sub ==="
    chmod +x "tests/$sub"
    case "$sub" in
      *dns-alpn*) env_var=SHUX_F04_NET_DNS_ALPN_FAIL ;;
      *tcp-pool*) env_var=SHUX_F04_NET_TCP_POOL_FAIL ;;
      *tls-stub*) env_var=SHUX_F04_NET_TLS_STUB_FAIL ;;
      *ws*) env_var=SHUX_STD_NET_WS_FAIL ;;
      *) env_var=SHUX_F04_NET_CLOSURE_FAIL ;;
    esac
    if ! env "$env_var=$FAIL" "tests/$sub"; then
      die "$sub failed"
    fi
  fi
done

echo "f04 std.net closure gate OK (F-04 v15)"
