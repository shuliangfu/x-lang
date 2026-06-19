#!/usr/bin/env bash
# std-sqlite-docs-sync.sh — STD-154 docs/07 与 std.sqlite 命名同步辅助
#
# 用法（source 后）：
#   std_sqlite_docs_sync_symbols_ok DOC07 README_SQLITE README_STD TSV
#   std_sqlite_docs_sync_forbidden_ok DOC07
#   std_sqlite_docs_sync_emit_report status miss skip

STD154_PREFIX="${SHUX_STD154_SQLITE_DOCS_PREFIX:-shux: [SHUX_STD154_SQLITE_DOCS]}"

# 校验 manifest；echo 缺失数。
std_sqlite_docs_sync_symbols_ok() {
  local doc07="$1"
  local readme_sqlite="$2"
  local readme_std="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor target
  while IFS=$'\t' read -r item_id kind anchor target _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      section)
        local f="analysis/std-sqlite-docs-sync-v1.md"
        if ! grep -qF "$anchor" "$f" 2>/dev/null; then
          echo "std-sqlite-docs-sync FAIL: missing section '$anchor' in RFC" >&2
          miss=$((miss + 1))
        fi
        ;;
      keyword)
        case "$target" in
          docs07)
            if ! grep -qF "$anchor" "$doc07" 2>/dev/null; then
              echo "std-sqlite-docs-sync FAIL: docs/07 missing '$anchor'" >&2
              miss=$((miss + 1))
            fi
            ;;
        esac
        ;;
      file)
        case "$target" in
          docs07) [ -f "$doc07" ] || { echo "std-sqlite-docs-sync FAIL: missing $doc07" >&2; miss=$((miss + 1)); } ;;
          readme)
            if [ "$anchor" = "std/db/sqlite/README.md" ]; then
              [ -f "$readme_sqlite" ] || { echo "std-sqlite-docs-sync FAIL: missing $readme_sqlite" >&2; miss=$((miss + 1)); }
            elif [ "$anchor" = "std/README.md" ]; then
              [ -f "$readme_std" ] || { echo "std-sqlite-docs-sync FAIL: missing $readme_std" >&2; miss=$((miss + 1)); }
              if ! grep -qF "std.sqlite" "$readme_std" 2>/dev/null; then
                echo "std-sqlite-docs-sync FAIL: std/README.md missing std.sqlite" >&2
                miss=$((miss + 1))
              fi
            fi
            ;;
        esac
        ;;
      script)
        if [ ! -f "tests/$anchor" ]; then
          echo "std-sqlite-docs-sync FAIL: missing tests/$anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 禁止：sqlite 仅出现在预研表、不在已完善主表。
std_sqlite_docs_sync_forbidden_ok() {
  local doc07="$1"
  if ! grep -qF "## std 已完善" "$doc07" 2>/dev/null; then
    echo "std-sqlite-docs-sync FAIL: missing 已完善 section" >&2
    return 1
  fi
  local main_line
  main_line=$(awk '/## std 已完善/{f=1} f && /\| `std\.sqlite`/{print; exit}' "$doc07")
  if [ -z "$main_line" ]; then
    echo "std-sqlite-docs-sync FAIL: std.sqlite not in 已完善 main table" >&2
    return 1
  fi
  if echo "$main_line" | grep -qF 'STD-010 RFC'; then
    echo "std-sqlite-docs-sync FAIL: main table still has prereq-only text" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_sqlite_docs_sync_emit_report() {
  local status="$1"
  local miss="$2"
  local skip="$3"
  echo "${STD154_PREFIX} status=${status} miss=${miss} skip=${skip}"
}
