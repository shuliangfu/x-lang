#!/usr/bin/env bash
# shux-lang-edition.sh — LANG-001 edition/feature gate 包装（注入 -D 后转发 shux）
#
# 用法：
#   ./scripts/shux-lang-edition.sh 2024 [shux args...]
#   ./scripts/shux-lang-edition.sh 2025 [shux args...]
#   ./scripts/shux-lang-edition.sh feature MATCH_STMT [shux args...]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ED="${1:-}"
shift || true

SHUX="${SHUX:-$ROOT/compiler/shux}"
DEFINES=()

case "$ED" in
  2024) DEFINES+=(-D SHUX_EDITION_2024) ;;
  2025) DEFINES+=(-D SHUX_EDITION_2025) ;;
  feature)
    FEAT="${1:-}"
    shift || true
    if [ -z "$FEAT" ]; then
      echo "shux-lang-edition FAIL: missing feature name" >&2
      exit 1
    fi
    DEFINES+=(-D "SHUX_FEATURE_${FEAT}")
    ;;
  *)
    echo "usage: $0 {2024|2025|feature NAME} [shux args...]" >&2
    exit 1
    ;;
esac

exec "$SHUX" "${DEFINES[@]}" "$@"
