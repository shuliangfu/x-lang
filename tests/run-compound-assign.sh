#!/usr/bin/env bash
# 复合赋值运算符：+= -= *= /= %= &= |= ^= <<= >>=
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
LINK_SHU="$RUN_SHU"

$LINK_SHU tests/compound-assign/main.su -o /tmp/shu_compound_assign 2>&1
exitcode=0
/tmp/shu_compound_assign >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 0 ]; then
  echo "compound-assign: expected exit 0, got $exitcode"
  exit 1
fi
echo "compound-assign test OK"
