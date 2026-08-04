#!/bin/sh
# Compatibility shim (wave893) — body authority is scripts/verify-selfhost-stage2.sh.
# PLATFORM: SHARED — zero logic; exec only. CI/tests may still call this path.
set -e
exec bash "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/scripts/verify-selfhost-stage2.sh" "$@"
