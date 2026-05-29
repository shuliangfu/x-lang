#!/usr/bin/env bash
# 门禁：fmt 折行不得留下无 // 的注释续行（见 compiler/scripts/verify_comment_prefixes.py）。
set -e
cd "$(dirname "$0")/.."
python3 compiler/scripts/verify_comment_prefixes.py compiler core std examples build.su build_runner.su build_runtime_su.su
python3 compiler/scripts/scan_fmt_damage.py compiler core std examples build.su build_runner.su build_runtime_su.su tests
echo "comment/fmt damage gate OK"
