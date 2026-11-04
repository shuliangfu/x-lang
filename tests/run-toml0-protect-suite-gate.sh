#!/usr/bin/env bash
# toml0 protect suite (knife 11.39): run residual-lock / design-static gates in one place.
# Green = all subgates green; does NOT mean runtime load product-ready.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [TOML0_PROTECT_SUITE]"
die() {
  echo "toml0-protect-suite gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

GATES=(
  tests/run-toml0-env-prefix-design-gate.sh
  tests/run-toml0-load-hold-protect-gate.sh
  tests/run-toml0-host-c-obs-io-stubs-gate.sh
  tests/run-toml0-cfg-trim-epilogue-protect-gate.sh
  tests/run-toml0-yaml-host-c-obs-io-stubs-gate.sh
  tests/run-toml0-smoke-exit-matrix-protect-gate.sh
)
for g in "${GATES[@]}"; do
  [ -f "$g" ] || die "missing $g"
  [ -x "$g" ] || die "not executable $g"
  bash "$g" || die "subgate failed: $g"
done

echo "${PREFIX} status=ok subgates=${#GATES[@]} runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-protect-suite gate OK (residual/design locks; not product load green)"
