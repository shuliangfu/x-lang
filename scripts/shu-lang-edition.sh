#!/usr/bin/env bash
# shu-lang-edition.sh — LANG-001 edition/feature gate 包装（注入 -D 后转发 shu）
#
# 用法：
#   ./scripts/shu-lang-edition.sh 2024 [shu args...]
#   ./scripts/shu-lang-edition.sh 2025 [shu args...]
#   ./scripts/shu-lang-edition.sh feature MATCH_STMT [shu args...]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ED="${1:-}"
shift || true

SHU="${SHU:-$ROOT/compiler/shu}"
DEFINES=()

case "$ED" in
  2024) DEFINES+=(-D SHU_EDITION_2024) ;;
  2025) DEFINES+=(-D SHU_EDITION_2025) ;;
  feature)
    FEAT="${1:-}"
    shift || true
    if [ -z "$FEAT" ]; then
      echo "shu-lang-edition FAIL: missing feature name" >&2
      exit 1
    fi
    DEFINES+=(-D "SHU_FEATURE_${FEAT}")
    ;;
  *)
    echo "usage: $0 {2024|2025|feature NAME} [shu args...]" >&2
    exit 1
    ;;
esac

exec "$SHU" "${DEFINES[@]}" "$@"
