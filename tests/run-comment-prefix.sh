#!/usr/bin/env bash
# 门禁：fmt 折行不得留下无 // 的注释续行（见 compiler/scripts/verify_comment_prefixes.py）。
set -e
cd "$(dirname "$0")/.."
python3 compiler/scripts/verify_comment_prefixes.py compiler core std examples build.sx build_runner.sx build_runtime_sx.sx
python3 compiler/scripts/scan_fmt_damage.py compiler core std examples build.sx build_runner.sx build_runtime_sx.sx tests
echo "comment/fmt damage gate OK"
