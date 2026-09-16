#!/usr/bin/env bash
# doc-cookbook.sh — DOC-001 / DOC-006 shared cookbook helpers.
#
# Usage (after source):
#   doc_cb_check_recipe XLANG_BIN path/to/recipe.x   # observational check
#   doc_cb_run_recipe XLANG_BIN path/to/recipe.x     # product -o + run
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# Observational `xlang check` path (check gate paused 2026-08-05).
# Return 0 on check OK; 1 on miss/fail. Callers must treat as obs, not soft silence.
doc_cb_check_recipe() {
  local xlang="$1"
  local src="$2"
  if [ ! -f "$src" ]; then
    return 1
  fi
  if "$xlang" check -L . "$src" >/dev/null 2>&1; then
    return 0
  fi
  "$xlang" check -L . "$src" 2>&1 | tail -5 >&2 || true
  return 1
}

# Product-path smoke: compile with -o and run. Return 0 on exit 0.
# Refuse soft SKIP — caller must hard-die when no native XLANG.
# PLATFORM: SHARED — Ubuntu gold still required for release claims.
doc_cb_run_recipe() {
  local xlang="$1"
  local src="$2"
  local out err ec rec
  if [ ! -f "$src" ]; then
    echo "doc-cookbook FAIL: missing recipe $src" >&2
    return 1
  fi
  out="/tmp/xlang_doc_cb_run_$$.out"
  err="/tmp/xlang_doc_cb_run_$$.err"
  set +e
  "$xlang" -L . "$src" -o "$out" >"$err" 2>&1
  ec=$?
  set -e
  if [ "$ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "doc-cookbook FAIL: product -o $src (ec=$ec)" >&2
    if [ -s "$err" ]; then
      tail -8 "$err" >&2 || true
    fi
    rm -f "$out"
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  rec=$?
  set -e
  rm -f "$out"
  if [ "$rec" -ne 0 ]; then
    echo "doc-cookbook FAIL: run $src exit=$rec" >&2
    return 1
  fi
  return 0
}
