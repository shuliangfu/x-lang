#!/usr/bin/env bash
# STD-047 thin 129 alias.
# Authority is tests/run-std-simd-shuffle-select-gate.sh (shuffle/select/select_lane).
# Historical name xlangffle-select is not a second product API or second gate body.
# PLATFORM: SHARED — consume-side wrapper only; zero business logic.
set -e
cd "$(dirname "$0")/.."
exec ./tests/run-std-simd-shuffle-select-gate.sh "$@"
