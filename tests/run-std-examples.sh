#!/usr/bin/env bash
# STD-012：标准库示例工程 — 打印全量目录索引
#
# 用法：./tests/run-std-examples.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/std-examples.sh
. tests/lib/std-examples.sh

CATALOG="${SHU_STD_EXAMPLES_CATALOG:-tests/baseline/std-examples-catalog.tsv}"

echo "=== STD-012: std examples catalog (n=$(std_ex_catalog_count "$CATALOG")) ==="
std_ex_validate_paths "$CATALOG"
std_ex_print_index "$CATALOG"
echo "std-examples index OK"
