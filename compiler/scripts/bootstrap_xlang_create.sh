#!/bin/sh
# Create bootstrap_xlang: copy current compiler/xlang for cold / no-fresh-xlang paths.
#
# Usage (cwd = compiler/): ./scripts/bootstrap_xlang_create.sh
# Prereq: ./xlang exists (from ./xbuild build, ./build_tool ./xlang, or cold seed).
# Preferred outer entry (wave731): repo-root ./xbuild / legacy alias ./build.sh
# (thin forward to xbuild). Host-cc residual only in scripts/build_tool.sh.
#
# PLATFORM: SHARED tip text · no dual build graph.
set -e
cd "$(dirname "$0")/.."
if [ ! -x "./xlang" ]; then
  echo "bootstrap_xlang_create: no ./xlang; run './xbuild build' (repo root) or './build_tool ./xlang' first."
  exit 1
fi
cp ./xlang ./bootstrap_xlang
chmod +x ./bootstrap_xlang
echo "bootstrap_xlang created (./bootstrap_xlang). Prefer: ./xbuild build | first-time (repo root). build_tool: ./xbuild build-tool."
