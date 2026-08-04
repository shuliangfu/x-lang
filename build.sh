#!/bin/sh
# build.sh — legacy product-entry alias (wave731 · 11.4.1)
#
# Authority (G.7): body is ONLY ./xbuild → xlang-build.sh. This script must
# not assemble build_tool or invoke host-cc. Host-cc residual for build_tool
# lives solely in compiler/scripts/build_tool.sh until stage 12 (zero-cc).
#
# Usage (repo root):
#   ./build.sh                 # same as ./xbuild build (g05 relink)
#   ./build.sh first-time      # pass-through any xbuild target
#   ./build.sh bootstrap-driver-bstrict
#
# PLATFORM: SHARED thin forward · no second build graph.
# Wave: 731 Track MG · pairs with 11.4 residual de-make/de-cc outer entries.

set -e
ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
if [ "$#" -eq 0 ]; then
  set -- build
fi
exec sh "$ROOT/xbuild" "$@"
