#!/usr/bin/env bash
# xlang-lang-edition.sh — LANG-001 edition/feature gate 包装（注入 -D 后转发 xlang）
#
# 用法：
#   ./scripts/xlang-lang-edition.sh 2024 [xlang args...]
#   ./scripts/xlang-lang-edition.sh 2025 [xlang args...]
#   ./scripts/xlang-lang-edition.sh feature MATCH_STMT [xlang args...]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ED="${1:-}"
shift || true

XLANG="${XLANG:-$ROOT/compiler/xlang}"
DEFINES=()

case "$ED" in
  2024) DEFINES+=(-D XLANG_EDITION_2024) ;;
  2025) DEFINES+=(-D XLANG_EDITION_2025) ;;
  feature)
    FEAT="${1:-}"
    shift || true
    if [ -z "$FEAT" ]; then
      echo "xlang-lang-edition FAIL: missing feature name" >&2
      exit 1
    fi
    DEFINES+=(-D "XLANG_FEATURE_${FEAT}")
    ;;
  *)
    echo "usage: $0 {2024|2025|feature NAME} [xlang args...]" >&2
    exit 1
    ;;
esac

exec "$XLANG" "${DEFINES[@]}" "$@"
