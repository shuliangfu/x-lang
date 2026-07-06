#!/usr/bin/env bash
# 测试 std.path：path_empty_len、path_join、path_basename、path_dirname、path_extension、path_stem、path_is_absolute、path_sep、path_clean
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
SHUX=${SHUX:-./compiler/shux}

$SHUX -L . tests/path/main.x -o /tmp/shux_path 2>&1
exitcode=0; /tmp/shux_path >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (path_empty_len), got $exitcode"; exit 1; }

$SHUX -L . tests/path/join_basename.x -o /tmp/shux_path_join 2>&1
exitcode=0; /tmp/shux_path_join >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (path_join/basename/dirname), got $exitcode"; exit 1; }

$SHUX -L . tests/path/extension_stem_abs_clean.x -o /tmp/shux_path_ext 2>&1
exitcode=0; /tmp/shux_path_ext >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (path_extension/stem/is_absolute/sep/clean), got $exitcode"; exit 1; }

$SHUX -L . tests/path/resolve.x -o /tmp/shux_path_resolve 2>&1
exitcode=0; /tmp/shux_path_resolve >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (path_resolve), got $exitcode"; exit 1; }

$SHUX -L . tests/path/extreme_clean.x -o /tmp/shux_path_extreme 2>&1
exitcode=0; /tmp/shux_path_extreme >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (path extreme_clean STD-140), got $exitcode"; exit 1; }

echo "path test OK"
