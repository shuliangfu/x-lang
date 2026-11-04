#!/usr/bin/env bash
# toml0 config discovery design static gate (knife 11.34).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DESIGN="analysis/xlang-toml-config-discovery-design.md"
SCHEMA="analysis/xlang-toml-project-config-schema.md"
PRINT="analysis/xlang-toml-print-config-design.md"
CORE="xlang.toml.core.example"
PREFIX="xlang: [TOML0_CONFIG_DISCOVERY_DESIGN]"

die() {
  echo "toml0-config-discovery-design gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$DESIGN" ] || die "missing $DESIGN"
[ -f "$SCHEMA" ] || die "missing $SCHEMA"
[ -f "$PRINT" ] || die "missing $PRINT"
[ -f "$CORE" ] || die "missing $CORE"

for kw in \
  '--config PATH' \
  'xlang.toml' \
  '零文件模式' \
  'D1' \
  'D4' \
  'D5' \
  '11.31' \
  '11.32' \
  '11.33'
do
  grep -qF -- "$kw" "$DESIGN" || die "design missing '$kw'"
done

grep -qF 'xlang.toml.core.example' "$DESIGN" || die "design must cite Core example"
grep -qF 'source=default' "$PRINT" || die "print-config design missing source=default"

echo "${PREFIX} status=ok static=1 cli_wired=0 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-config-discovery-design gate OK (static only)"
