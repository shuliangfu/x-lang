#!/usr/bin/env bash
# A-10：L5 run-all parity — bstrict 白名单与 run-all.sh 同步 + shux_asm 白名单烟测。
#
# 1) 校验 run-all-bstrict.sh 中每项均在 run-all.sh L5 whitelist 内
# 2) 跑 run-all-bstrict.sh（123 项，compiler/shux_asm）
#
# 用法：./tests/run-l5-run-all-parity-gate.sh
# 环境：SHUX_BSTRICT_SKIP_BUILD=1 — 复用已有 shux_asm（bootstrap-ci 已构建时）
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

echo "=== A-10: L5 whitelist sync (bstrict ⊆ run-all) ==="
python3 <<'PY'
import re, sys
btext = open("tests/run-all-bstrict.sh").read()
chunk = btext.split("BSTRICT_SCRIPTS=(")[1].split(")")[0]
bstrict = sorted(set(re.findall(r"run-[\w-]+\.sh", chunk)))
all_text = open("tests/run-all.sh").read()
m = re.search(
    r'run_all_l5_whitelist_case\(\).*?case "\$1" in\s*\n\s*(.*?)\n\s*return 0',
    all_text,
    re.S,
)
if not m:
    sys.stderr.write("l5-parity-gate FAIL: cannot parse run_all_l5_whitelist_case\n")
    sys.exit(1)
whitelist = set(re.findall(r"run-[\w-]+\.sh", m.group(1)))
missing = [s for s in bstrict if s not in whitelist]
extra = sorted(whitelist - set(bstrict))
if missing:
    sys.stderr.write("l5-parity-gate FAIL: bstrict scripts not in run-all whitelist:\n")
    for s in missing:
        sys.stderr.write(f"  {s}\n")
    sys.exit(1)
print(f"l5-parity-gate: sync OK (bstrict={len(bstrict)} whitelist={len(whitelist)} extra_in_whitelist_only={len(extra)})")
if extra:
    print(f"l5-parity-gate: note — whitelist-only (not in bstrict yet): {', '.join(extra[:8])}{'...' if len(extra)>8 else ''}")
PY

if [ ! -x compiler/shux_asm ] && [ -z "${SHUX_BSTRICT_SKIP_BUILD:-}" ]; then
  echo "l5-parity-gate: need shux_asm (make -C compiler bootstrap-driver-bstrict)" >&2
  exit 127
fi

echo "=== A-10: run-all-bstrict (L5 shux_asm whitelist) ==="
chmod +x tests/run-all-bstrict.sh
export SHUX_BSTRICT_SKIP_BUILD="${SHUX_BSTRICT_SKIP_BUILD:-1}"
./tests/run-all-bstrict.sh

echo "l5-run-all-parity-gate OK"
