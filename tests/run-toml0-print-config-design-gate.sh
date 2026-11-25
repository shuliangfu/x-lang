#!/usr/bin/env bash
# toml0 --print-config design static gate (knife 11.33).
# Does NOT wire CLI or claim load_toml runtime green.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DESIGN="analysis/xlang-toml-print-config-design.md"
SCHEMA="analysis/xlang-toml-project-config-schema.md"
PREFIX="xlang: [TOML0_PRINT_CONFIG_DESIGN]"

die() {
  echo "toml0-print-config-design gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$DESIGN" ] || die "missing $DESIGN"
[ -f "$SCHEMA" ] || die "missing $SCHEMA"

for kw in \
  '--print-config' \
  'source=<toml|env|cli|default>' \
  'source=default' \
  'source=toml' \
  'source=env' \
  'source=cli' \
  'T1' \
  'T5' \
  '11.31' \
  '11.32'
do
  grep -qF -- "$kw" "$DESIGN" || die "design missing '$kw'"
done

# Must stay aligned with Layer2 schema plant.
grep -qF 'build.backend' "$SCHEMA" || die "schema missing build.backend"
grep -qF 'ProjectConfig' "$DESIGN" || grep -qF '11.32' "$DESIGN" || die "design must cite Layer2/11.32"

echo "${PREFIX} status=ok static=1 cli_wired=0 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-print-config-design gate OK (static only)"
