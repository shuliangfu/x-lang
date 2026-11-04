#!/usr/bin/env bash
# toml0 ENV prefix design static gate (knife 11.35).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DESIGN="analysis/xlang-toml-env-prefix-design.md"
SCHEMA="analysis/xlang-toml-project-config-schema.md"
PRINT="analysis/xlang-toml-print-config-design.md"
DISC="analysis/xlang-toml-config-discovery-design.md"
PREFIX="xlang: [TOML0_ENV_PREFIX_DESIGN]"

die() {
  echo "toml0-env-prefix-design gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$DESIGN" ] || die "missing $DESIGN"
[ -f "$SCHEMA" ] || die "missing $SCHEMA"
[ -f "$PRINT" ] || die "missing $PRINT"
[ -f "$DISC" ] || die "missing $DISC"

for kw in \
  'XLANG_' \
  'XLANG_BUILD_BACKEND' \
  'XLANG_FEATURES_STD' \
  'source=env' \
  'E1' \
  'E5' \
  '11.31' \
  '11.32' \
  '11.33' \
  '11.34'
do
  grep -qF -- "$kw" "$DESIGN" || die "design missing '$kw'"
done

grep -qF 'build.backend' "$SCHEMA" || die "schema missing build.backend"
grep -qF 'source=env' "$PRINT" || die "print-config missing source=env"

echo "${PREFIX} status=ok static=1 cli_wired=0 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-env-prefix-design gate OK (static only)"
