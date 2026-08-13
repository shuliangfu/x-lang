#!/usr/bin/env bash
# STD-061 thin 129 alias.
# Authority is tests/run-perf-simd-shuffle-select.sh (r04_simd_shuffle_select*).
# Historical name xlangffle-select is not a second product bench or second perf body.
# PLATFORM: SHARED — consume-side wrapper only; zero business logic.
set -e
cd "$(dirname "$0")/.."
exec ./tests/run-perf-simd-shuffle-select.sh "$@"
