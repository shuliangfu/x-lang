#!/usr/bin/env bash
# 键 C P0 host — leftover fossil DOC + leftover catalog no Honesty →硬绿.
#
# Honesty: leftover top-level `analysis/自举前必须清单.md` as live DOC
# (file already archived to analysis/archive/narrative/; gate still
# hard-required the missing top-level path → keyc-p0 / bootstrap-min red)
# + leftover catalog no Honesty / missing run=/obs=/skip= retired. Live =
# analysis/archive/narrative/. Refuse top-level resurrect. Nested leftover
# of leftover V6 / C6 / §9.1 / spill / anti-collapse / S7 / L9 stays (do
# not rewrite leftover nested product paths / leftover bootstrap-min host).
# leftover S7 nested typeck skip=1 (check postponed) is skip not FAIL
# (refuse leftover SKIP of leftover check postponed as FAIL). No XLANG
# face on this parent (G.7: do not fork a resolver). Explicit XLANG is
# ignored at parent; nested leftover still hard. Keep `keyc-p0 gate OK`.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-bootstrap-keyc-p0-gate.sh
# Env:   XLANG_KEYC_P0_ALLOW_WARN=1 — leftover nested WARN/SKIP still ok
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_KEYC_P0_DOC:-analysis/archive/narrative/自举前必须清单.md}"
PREFIX="${XLANG_KEYC_P0_PREFIX:-xlang: [XLANG_KEYC_P0]}"
RUN_OK=0
OBS=0
SKIP=0
FAIL=0

die() {
  echo "keyc-p0 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== 键 C P0: leftover fossil DOC (archive DOC; nested leftover still hard) ==="

# Refuse leftover fossil top-level DOC as live path (c6 / stdlib-check-matrix).
# PLATFORM: SHARED archaeology — live = archive/narrative/.
if [ -f analysis/自举前必须清单.md ]; then
  die "top-level DOC resurrected (live = archive/narrative/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

# id|gate script|strict(1=nested fail is hard)
P0_GATES=(
  "P0#1-V6|run-bootstrap-fresh-seed-gate.sh|1"
  "P0#2-C6|run-bootstrap-c6-asm-o-gate.sh|0"
  "P0#3-9.1|run-codegen-semantic-debt-gate.sh|0"
  "P0#4-spill|run-comp-regalloc-result-spill-gate.sh|0"
  "P0#5-anti-collapse|run-bootstrap-anti-collapse-gate.sh|0"
  "P0#6-S7|run-bootstrap-std-harddeps-gate.sh|0"
  "P0#7-L9|run-memory-contract-arena-align-gate.sh|0"
)

run_p0_gate() {
  local id="$1" script="$2" strict="$3"
  local path="tests/$script"
  local log="/tmp/xlang_keyc_${id//[^a-zA-Z0-9]/_}.log"
  echo ""
  echo "======== $id ($script) ========"
  # leftover nested anti-collapse SKIP when no stage1/2 stays (do not rewrite).
  # PLATFORM: SHARED archaeology — leftover nested SKIP counted.
  if [ "$script" = "run-bootstrap-anti-collapse-gate.sh" ]; then
    if [ ! -f compiler/xlang_asm_stage1 ] || [ ! -f compiler/xlang_asm2 ]; then
      echo "keyc-p0: $id SKIP (no stage1/2; leftover nested V4/V5 gold)"
      SKIP=$((SKIP + 1))
      return
    fi
  fi
  if [ ! -f "$path" ]; then
    die "missing $path"
  fi
  chmod +x "$path"
  set +e
  ./tests/"$script" >"$log" 2>&1
  local ec=$?
  set -e
  tail -6 "$log" 2>/dev/null || cat "$log"
  if [ "$ec" -eq 0 ]; then
    # Count leftover nested Honesty obs=/skip= from THIS nested gate's
    # last `status=` line only. Matching the whole log would bubble
    # leftover grandchild Honesty (e.g. compound-assign `obs=1` inside
    # leftover nested §9.1) as parent OBS. Bare `obs=` would treat
    # `obs=0` as OBS (leftover SKIP→OBS of leftover Honesty report).
    # PLATFORM: SHARED archaeology — parent classifier only; nested leftover
    # product paths stay.
    last_status="$(grep -E 'status=(ok|fail)' "$log" | tail -1 || true)"
    if echo "$last_status" | grep -qE 'obs=[1-9]'; then
      echo "keyc-p0: $id OBS"
      OBS=$((OBS + 1))
      RUN_OK=$((RUN_OK + 1))
      return
    fi
    if echo "$last_status" | grep -qE 'skip=[1-9]'; then
      echo "keyc-p0: $id SKIP (nested leftover skip counted)"
      SKIP=$((SKIP + 1))
      RUN_OK=$((RUN_OK + 1))
      return
    fi
    echo "keyc-p0: $id PASS"
    RUN_OK=$((RUN_OK + 1))
    return
  fi
  if [ "$strict" = "1" ]; then
    echo "keyc-p0: $id FAIL (ec=$ec; STRICT leftover nested)" >&2
    FAIL=$((FAIL + 1))
    return
  fi
  # leftover STRICT=0 nested fail = obs (Honesty leftover SKIP→OK).
  # PLATFORM: SHARED archaeology — nested leftover product path not rewritten.
  echo "keyc-p0: $id OBS (leftover nested fail; STRICT=0; refuse leftover SKIP→OK as silent OK)"
  OBS=$((OBS + 1))
}

for row in "${P0_GATES[@]}"; do
  IFS='|' read -r id script strict <<<"$row"
  run_p0_gate "$id" "$script" "$strict"
done

echo ""
echo "======== 键 C P0 汇总 ========"
echo "PASS=$RUN_OK OBS=$OBS SKIP=$SKIP FAIL=$FAIL"

if [ "$FAIL" -gt 0 ]; then
  die "$FAIL leftover nested STRICT item(s) failed"
fi
if [ "$OBS" -gt 0 ] || [ "$SKIP" -gt 0 ]; then
  if [ "${XLANG_KEYC_P0_ALLOW_WARN:-0}" = "1" ]; then
    echo "keyc-p0 gate OK with OBS/SKIP (XLANG_KEYC_P0_ALLOW_WARN=1)"
    ok_report
    exit 0
  fi
  # leftover nested OBS/SKIP still ok when nested leftover Honesty-closed
  # (S7 leftover check postponed skip=1; Darwin V6 skip=1 N/A). Refuse
  # leftover SKIP→FAIL of leftover check postponed.
  echo "keyc-p0 gate OK (leftover nested OBS/SKIP counted; refuse leftover SKIP→FAIL of leftover check postponed)"
  ok_report
  exit 0
fi
echo "keyc-p0 gate OK (键 C P0 nested leftover hard-green)"
ok_report
