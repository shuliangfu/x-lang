#!/usr/bin/env bash
# toml0 cfg_trim epilogue protect (knife 11.38).
# PASS while product std/config/config.o still has BOTH out_len store branches empty
# (cbz → b same target; 11.31 residual). FAIL if Soft Cap tip rebuild clears the pattern
# without a named Soft Cap tiphead knife — do not silent-ACCEPT runtime load green.
#
# Honesty: green here means residual STILL LOCKED, not that load is product-ready.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [TOML0_CFG_TRIM_EPILOGUE_PROTECT]"
CFG_O="std/config/config.o"

die() {
  echo "toml0-cfg-trim-epilogue-protect gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$CFG_O" ] || die "missing $CFG_O (refuse rebuild)"
[ -f std/config/README.md ] || die "missing README"
grep -qF '11.31' std/config/README.md || die "README must cite 11.31"
grep -qF 'cfg_trim' std/config/README.md || die "README must cite cfg_trim"
command -v otool >/dev/null 2>&1 || die "otool required (Darwin protect; host=$(ci_host_summary))"
nm "$CFG_O" 2>/dev/null | grep -qE 'T _*cfg_trim$' || die "missing T cfg_trim in $CFG_O"

EMPTY="$(otool -tv "$CFG_O" 2>/dev/null | python3 -c '
import re, sys
text = sys.stdin.read().splitlines()
body = []
in_fn = False
for line in text:
    if re.match(r"^_cfg_trim:\s*$", line):
        in_fn = True
        body.append(line)
        continue
    if in_fn:
        if re.match(r"^_[A-Za-z]", line) and not line.startswith("_cfg_trim:"):
            break
        body.append(line)
if not body:
    print(0)
    sys.exit(0)
empty = 0
imm_re = re.compile(r"\bcbz\s+w\d+,\s*(0x[0-9a-fA-F]+)\b")
b_re = re.compile(r"\bb\s+(0x[0-9a-fA-F]+)\b")
i = 0
while i < len(body) - 1:
    m = imm_re.search(body[i])
    if m:
        tgt = m.group(1).lower()
        m2 = b_re.search(body[i + 1])
        if m2 and m2.group(1).lower() == tgt:
            empty += 1
            i += 2
            continue
    i += 1
print(empty)
')"
[ -n "${EMPTY}" ] || die "empty count empty"
[ "${EMPTY}" -ge 2 ] || die "empty_dual_branch=${EMPTY} want>=2 (residual CLEARED? reopen Soft Cap tiphead)"

echo "${PREFIX} status=ok residual_locked=1 empty_dual_branch=${EMPTY} runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-cfg-trim-epilogue-protect gate OK (residual locked; not product load green)"
