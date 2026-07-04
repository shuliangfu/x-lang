#!/usr/bin/env bash
# nolibc-n06-std-track.sh — NL-06 freestanding std 替换 manifest 审计（F-no-libc）。
#
# 用法（source）：
#   . tests/lib/nolibc-n06-std-track.sh
#   nolibc_n06_audit_manifest tests/baseline/nolibc-n06-freestanding-replacements.tsv || exit 1

# 审计 NL-06 replacements.tsv：exists / grep / gate_ref / smoke_import / grep_track。
nolibc_n06_audit_manifest() {
  local manifest="${1:-tests/baseline/nolibc-n06-freestanding-replacements.tsv}"
  local miss=0
  local item_id category anchor check_type notes

  if [ ! -f "$manifest" ]; then
    echo "nolibc-n06: missing manifest $manifest" >&2
    return 1
  fi

  while IFS=$'\t' read -r item_id category anchor check_type notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$check_type" in
      exists|legacy_c)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n06 manifest missing file: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep)
        if [ ! -f "$anchor" ] || ! grep -q "$notes" "$anchor" 2>/dev/null; then
          echo "nolibc-n06 manifest grep fail: $anchor need '$notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      gate_ref)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n06 manifest missing gate: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke_import)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n06 manifest missing smoke: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -q "import(\"$notes\")" "$anchor" 2>/dev/null; then
          echo "nolibc-n06 smoke import fail: $anchor must import(\"$notes\") ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep_track)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n06 manifest missing track file: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -q "$notes" "$anchor" 2>/dev/null; then
          echo "nolibc-n06 track: $anchor no longer references '$notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      absent)
        if [ -f "$anchor" ]; then
          echo "nolibc-n06 manifest absent fail: $anchor should be deleted ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$manifest"

  if [ "$miss" -gt 0 ]; then
    echo "nolibc-n06: $miss manifest item(s) failed" >&2
    return 1
  fi
  return 0
}

# 统计 manifest 中 x_replacement 条目数（供 gate 日志）。
nolibc_n06_count_x_replacements() {
  local manifest="${1:-tests/baseline/nolibc-n06-freestanding-replacements.tsv}"
  awk -F'\t' '$2=="x_replacement" { c++ } END { print c+0 }' "$manifest"
}

# 统计 legacy_c 条目数。
nolibc_n06_count_legacy_c() {
  local manifest="${1:-tests/baseline/nolibc-n06-freestanding-replacements.tsv}"
  awk -F'\t' '$2=="legacy_c" { c++ } END { print c+0 }' "$manifest"
}
