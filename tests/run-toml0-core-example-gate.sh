#!/usr/bin/env bash
# toml0 Core example static gate (knife 11.30).
#
# Verifies xlang.toml.core.example:
#   - present
#   - required Core keys present as text
#   - forbids array-of-string / inline table / [[array-of-tables]]
#
# Honesty: does NOT claim config_load_toml_buf runtime green.
# Current config.o load→get NOT_FOUND; Soft Cap CG002 blocks rebuild.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

CORE="xlang.toml.core.example"
PREFIX="xlang: [TOML0_CORE_EXAMPLE]"

die() {
  echo "toml0-core-example gate FAIL: $*" >&2
  echo "${PREFIX} status=fail host=$(ci_host_summary)"
  exit 1
}

[ -f "$CORE" ] || die "missing $CORE"

# Required Core anchors (text presence; schema freeze aid).
for kw in \
  'version =' \
  '[package]' \
  'name =' \
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

# Forbidden shapes for Core template (parser v1 gaps / Full-only).
# Strip full-line comments before shape scans (allow documenting bans in header).
STRIPPED=$(grep -vE '^[[:space:]]*#' "$CORE" || true)
if printf '%s
' "$STRIPPED" | grep -nE '\[\[' >/tmp/toml0_core_forbid.lines 2>/dev/null; then
  die "Core example contains [[array-of-tables]] (Full-only): $(head -3 /tmp/toml0_core_forbid.lines | tr '\n' ' ')"
fi
if printf '%s
' "$STRIPPED" | grep -nE '=[[:space:]]*\[' >/tmp/toml0_core_forbid.lines 2>/dev/null; then
  die "Core example contains array-of-string / bracket value: $(head -3 /tmp/toml0_core_forbid.lines | tr '\n' ' ')"
fi
if printf '%s
' "$STRIPPED" | grep -nE '=[[:space:]]*\{' >/tmp/toml0_core_forbid.lines 2>/dev/null; then
  die "Core example contains inline table: $(head -3 /tmp/toml0_core_forbid.lines | tr '\n' ' ')"
fi

# Full example must remain distinct and still may contain Full shapes.
[ -f xlang.toml ] || die "missing Full draft xlang.toml"
grep -qF 'Full' xlang.toml || die "Full xlang.toml missing Full marker"

echo "${PREFIX} status=ok static=1 runtime_load=deferred host=$(ci_host_summary)"
echo "toml0-core-example gate OK (static only)"
