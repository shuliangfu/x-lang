#!/usr/bin/env bash
# toml0 ProjectConfig Layer2 Core schema static gate (knife 11.32).
#
# Verifies analysis/xlang-toml-project-config-schema.md lists Core logical keys
# and stays aligned with xlang.toml.core.example anchors.
# Does NOT claim load_toml runtime green (11.31 HOLD).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

SCHEMA="analysis/xlang-toml-project-config-schema.md"
CORE="xlang.toml.core.example"
PREFIX="xlang: [TOML0_PROJECT_CONFIG_SCHEMA]"

die() {
  echo "toml0-project-config-schema gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$SCHEMA" ] || die "missing $SCHEMA"
[ -f "$CORE" ] || die "missing $CORE"

# Schema must name Core logical keys.
for kw in \
  'package.name' \
  'package.edition' \
  'build.root' \
  'build.default-target' \
  'build.out-dir' \
  'build.backend' \
  'build.link-std' \
  'build.freestanding' \
  'build.optimization' \
  'profile.dev.opt-level' \
  'profile.dev.debug' \
  'profile.release.opt-level' \
  'profile.release.lto' \
  'features.std' \
  'features.async' \
  'array-of-string' \
  'inline table'
do
  grep -qF -- "$kw" "$SCHEMA" || die "schema missing '$kw'"
done

# Honesty markers.
grep -qF '11.31' "$SCHEMA" || die "schema must cite 11.31 load residual"
grep -qF '不升 Soft Cap' "$SCHEMA" || grep -qiF 'Soft Cap' "$SCHEMA" || die "schema must mention Soft Cap hold"

# Core example still has TOML anchors (11.30 contract).
for kw in \
  'version =' \
  '[package]' \
  '[build]' \
  'default-target' \
  'out-dir' \
  'backend' \
  '[features]' \
  '[profile.dev]' \
  '[profile.release]'
do
  grep -qF -- "$kw" "$CORE" || die "Core example missing '$kw'"
done

echo "${PREFIX} status=ok static=1 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-project-config-schema gate OK (static only)"
