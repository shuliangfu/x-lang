#!/usr/bin/env bash
# fmt comment-prefix / fmt-damage scan (verify_comment_prefixes + scan_fmt_damage).
#
# Honesty: leftover catalog no Honesty + missing run=/obs=/skip= report
# retired. No XLANG face (python3 scanners). G.7: do not fork a resolver.
# Nested leftover of leftover run-check.sh (check postponed; do not rewrite
# that host). Also a bstrict catalog leaf. Keep `comment/fmt damage gate OK`.
# Missing python3 / scanner / scan fail stays hard (refuse leftover SKIP→OK).
# Explicit XLANG is ignored (no XLANG face).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-comment-prefix.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="${XLANG_COMMENT_PREFIX:-xlang: [COMMENT_PREFIX]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "comment-prefix FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== comment-prefix (python3 scanners; no XLANG face) ==="
command -v python3 >/dev/null 2>&1 || die "missing python3 (refuse leftover SKIP→OK)"
[ -f compiler/scripts/verify_comment_prefixes.py ] || die "missing compiler/scripts/verify_comment_prefixes.py"
[ -f compiler/scripts/scan_fmt_damage.py ] || die "missing compiler/scripts/scan_fmt_damage.py"

python3 compiler/scripts/verify_comment_prefixes.py compiler core std examples build.x build_runner.x build_runtime_x.x \
  || die "verify_comment_prefixes"
RUN_OK=$((RUN_OK + 1))

python3 compiler/scripts/scan_fmt_damage.py compiler core std examples build.x build_runner.x build_runtime_x.x tests \
  || die "scan_fmt_damage"
RUN_OK=$((RUN_OK + 1))

echo "comment/fmt damage gate OK"
ok_report
