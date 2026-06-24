#!/usr/bin/env bash
# nolibc-n07-bootstrap-audit.sh — NL-07 编译器 bootstrap 去 libc 准备层审计。
#
# 用法（source）：
#   . tests/lib/nolibc-n07-bootstrap-audit.sh
#   nolibc_n07_audit_manifest tests/baseline/nolibc-n07-bootstrap-prep.tsv || exit 1

# 审计 NL-07 preparation.tsv。
nolibc_n07_audit_manifest() {
  local manifest="${1:-tests/baseline/nolibc-n07-bootstrap-prep.tsv}"
  local miss=0
  local item_id category anchor check_type notes

  if [ ! -f "$manifest" ]; then
    echo "nolibc-n07: missing manifest $manifest" >&2
    return 1
  fi

  while IFS=$'\t' read -r item_id category anchor check_type notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$check_type" in
      exists)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n07 manifest missing file: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep)
        if [ ! -f "$anchor" ] || ! grep -q "$notes" "$anchor" 2>/dev/null; then
          echo "nolibc-n07 manifest grep fail: $anchor need '$notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      absent_grep)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n07 manifest missing: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        elif grep -q "$notes" "$anchor" 2>/dev/null; then
          echo "nolibc-n07 manifest absent_grep fail: $anchor still contains '$notes' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      gate_ref)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n07 manifest missing gate: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      grep_marker)
        if [ ! -f "$anchor" ]; then
          echo "nolibc-n07 manifest missing: $anchor ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -q 'F-no-libc NL-07 BEGIN' "$anchor" || ! grep -q 'F-no-libc NL-07 END' "$anchor"; then
          echo "nolibc-n07 manifest NL-07 markers missing in $anchor" >&2
          miss=$((miss + 1))
        else
          local block
          block=$(awk '/F-no-libc NL-07 BEGIN/,/F-no-libc NL-07 END/' "$anchor")
          if ! echo "$block" | grep -q 'nostdlib'; then
            echo "nolibc-n07 NL-07 block missing nostdlib target in $anchor" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
      *)
        echo "nolibc-n07 manifest unknown check_type: $check_type ($item_id)" >&2
        miss=$((miss + 1))
        ;;
    esac
  done < "$manifest"

  if [ "$miss" -gt 0 ]; then
    echo "nolibc-n07: $miss manifest item(s) failed" >&2
    return 1
  fi
  return 0
}

# 统计 build_shux_asm.sh 中非注释行含 -lc 的链接命令数。
nolibc_n07_count_lc_link_cmds() {
  local f="${1:-compiler/scripts/build_shux_asm.sh}"
  grep -E '\-lc' "$f" 2>/dev/null | grep -vE '^\s*#' | wc -l | tr -d ' '
}

# 统计 ensure_std_fs_io_heap_objs 内 cc -c ../std/{io,fs,heap}/*.c 行数。
nolibc_n07_count_ensure_std_c() {
  local f="${1:-compiler/scripts/build_shux_asm.sh}"
  awk '/ensure_std_fs_io_heap_objs\(\)/,/^\}/' "$f" | grep -cE '\.\./std/(io|fs|heap)/.*\.c' 2>/dev/null | tr -d ' '
}

# 统计 Makefile bootstrap-driver-seed 依赖行中 ../std/{fs,io,heap}.o 出现次数。
nolibc_n07_count_makefile_bootstrap_std_o() {
  local f="${1:-compiler/Makefile}"
  grep '^bootstrap-driver-seed:' "$f" 2>/dev/null | grep -oE '\.\./std/(fs/fs|io/io|heap/heap)\.o' | wc -l | tr -d ' '
}

# 对照 lc-track 基线；基线缺失时仅登记不失败。
nolibc_n07_audit_lc_baseline() {
  local baseline="${1:-tests/baseline/nolibc-n07-bootstrap-lc-track.tsv}"
  local hard_fail="${2:-0}"
  local miss=0
  local metric expect_val actual_val file _notes

  if [ ! -f "$baseline" ]; then
    echo "nolibc-n07: missing lc baseline $baseline" >&2
    return 1
  fi

  while IFS=$'\t' read -r metric expect_val file _notes; do
    [ -z "${metric:-}" ] && continue
    case "$metric" in \#*) continue ;; esac
    case "$metric" in
      lc_link_cmds)
        actual_val=$(nolibc_n07_count_lc_link_cmds "$file")
        ;;
      ensure_std_c_compile)
        actual_val=$(nolibc_n07_count_ensure_std_c "$file")
        ;;
      makefile_bootstrap_std_o)
        actual_val=$(nolibc_n07_count_makefile_bootstrap_std_o "$file")
        ;;
      *)
        continue
        ;;
    esac
    echo "nolibc-n07 track: $metric expect=${expect_val} actual=${actual_val} ($file)"
    if [ "$actual_val" != "$expect_val" ] 2>/dev/null; then
      if [ "$actual_val" -gt "$expect_val" ] 2>/dev/null; then
        echo "nolibc-n07 track WARN: $metric increased ($actual_val > $expect_val)" >&2
        miss=$((miss + 1))
      else
        echo "nolibc-n07 track OK: $metric decreased ($actual_val < $expect_val; NL-07 v2 progress)"
      fi
    fi
  done < "$baseline"

  if [ "$miss" -gt 0 ] && [ "$hard_fail" = "1" ]; then
    echo "nolibc-n07: lc baseline regression ($miss metric(s))" >&2
    return 1
  fi
  return 0
}
