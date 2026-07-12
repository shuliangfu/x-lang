#!/bin/bash
# x_bootstrap_safe_lint.sh — G-02f / Phase 0：bootstrap-safe .x 子集的最小 lint gate
#
# 当前版本只做已知高风险形态拦截，不追求完备 AST 语义分析。
#
# 用法：
#   sh scripts/x_bootstrap_safe_lint.sh <x-file>...

set -eu

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
usage:
  sh scripts/x_bootstrap_safe_lint.sh <x-file>...

checks (v1):
  1) forbid && / ||
  2) warn or fail on nested-if heuristic (small thin leafs only warn)
  3) flag unsafe->while heuristic within 16 lines
  4) flag oversized function bodies (>220 lines)
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ $# -lt 1 ]; then
  usage >&2
  exit 2
fi

status=0

lint_one() {
  file="$1"
  if [ ! -f "$file" ]; then
    echo "x_bootstrap_safe_lint: missing file: $file" >&2
    return 1
  fi

  perl -ne '
    our $bad = 0;
    my $line = $.;
    if (/&&|\|\|/) {
      print STDERR "'"$file"':" . $line . ": lint: forbidden logical operator &&/|| in bootstrap-safe subset\n";
      $bad = 1;
    }
    END { exit($bad ? 3 : 0) }
  ' "$file" || status=1

  awk -v file="$file" '
    BEGIN {
      bad = 0
      warn = 0
      last_if = -100000
      last_if_depth = -1
      last_unsafe = -100000
      func_start = 0
      func_name = ""
      depth = 0
      nested_hits_in_func = 0
    }
    {
      line = NR
      line_depth = depth
      if ($0 ~ /^[[:space:]]*function[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(/) {
        if (func_start > 0) {
          span = line - func_start
          if (span > 220) {
            printf "%s:%d: lint: oversized function body (%d lines): %s\n", file, func_start, span, func_name > "/dev/stderr"
            bad = 1
          }
        }
        func_start = line
        func_name = $0
        nested_hits_in_func = 0
        last_unsafe = -100000
      }
      if ($0 ~ /^[[:space:]]*if[[:space:]]*\(/) {
        if (line - last_if <= 12 && line_depth > last_if_depth) {
          nested_hits_in_func++
          if (nested_hits_in_func >= 3) {
            printf "%s:%d: lint: nested-if heuristic hard fail (previous if at line %d, depth %d -> %d, hits=%d)\n", file, line, last_if, last_if_depth, line_depth, nested_hits_in_func > "/dev/stderr"
            bad = 1
          } else {
            printf "%s:%d: lint: nested-if heuristic warning (previous if at line %d, depth %d -> %d, hits=%d)\n", file, line, last_if, last_if_depth, line_depth, nested_hits_in_func > "/dev/stderr"
            warn = 1
          }
        }
        last_if = line
        last_if_depth = line_depth
      }
      if ($0 ~ /unsafe[[:space:]]*\{/) {
        last_unsafe = line
      }
      if ($0 ~ /^[[:space:]]*while[[:space:]]*\(/ && line - last_unsafe <= 16) {
        printf "%s:%d: lint: unsafe-while heuristic hit (unsafe at line %d)\n", file, line, last_unsafe > "/dev/stderr"
        bad = 1
      }
      opens = gsub(/\{/, "{", $0)
      closes = gsub(/\}/, "}", $0)
      depth += opens - closes
      if (depth < 0) {
        depth = 0
      }
    }
    END {
      if (func_start > 0) {
        span = NR + 1 - func_start
        if (span > 220) {
          printf "%s:%d: lint: oversized function body (%d lines): %s\n", file, func_start, span, func_name > "/dev/stderr"
          bad = 1
        }
      }
      if (!bad && warn) {
        printf "%s: lint: warnings present but below hard-fail threshold\n", file > "/dev/stderr"
      }
      exit(bad ? 4 : 0)
    }
  ' "$file" || status=1
}

for f in "$@"; do
  lint_one "$f"
done

if [ "$status" -ne 0 ]; then
  echo "x_bootstrap_safe_lint: FAIL" >&2
  exit 1
fi

echo "x_bootstrap_safe_lint: OK"
exit 0
