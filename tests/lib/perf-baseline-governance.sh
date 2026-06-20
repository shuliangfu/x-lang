#!/usr/bin/env bash
# perf-baseline-governance.sh — ENG-001 性能 baseline 注册表共享工具
#
# 用法（source）：
#   # shellcheck source=tests/lib/perf-baseline-governance.sh
#   . tests/lib/perf-baseline-governance.sh
#
# 环境：
#   SHUX_PERF_BASELINE_REGISTRY — 默认 tests/baseline/perf-baseline-registry.tsv

PERF_BASELINE_REGISTRY="${SHUX_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"

# 读取 registry 某 baseline_id 的列（2=path 3=version 4=gate 5=update_env）。
perf_baseline_registry_get() {
  local id="$1" col="$2"
  awk -F'\t' -v i="$id" -v c="$col" '
    $0 !~ /^#/ && $1 == i { print $c; exit }
  ' "$PERF_BASELINE_REGISTRY" 2>/dev/null
}

# 校验 version 格式 v1.YYYY-MM-DD。
perf_baseline_version_valid() {
  local v="$1"
  printf '%s' "$v" | grep -qE '^v1\.[0-9]{4}-[0-9]{2}-[0-9]{2}$'
}

# manifest：registry 存在且每行 path/gate 存在、version 合法。
perf_baseline_registry_validate() {
  local reg="$1" n=0 miss=0
  if [ ! -f "$reg" ]; then
    echo "perf-baseline-governance FAIL: missing $reg" >&2
    return 1
  fi
  while IFS=$'\t' read -r bid path ver gate upd notes; do
    [ -z "${bid:-}" ] && continue
    case "$bid" in \#*) continue ;; esac
    n=$((n + 1))
    if [ ! -f "$path" ]; then
      echo "perf-baseline-governance FAIL: missing baseline $path ($bid)" >&2
      miss=$((miss + 1))
    fi
    if ! perf_baseline_version_valid "$ver"; then
      echo "perf-baseline-governance FAIL: bad version '$ver' for $bid" >&2
      miss=$((miss + 1))
    fi
    if [ ! -f "tests/${gate}" ] && [ ! -f "$gate" ]; then
      echo "perf-baseline-governance FAIL: missing gate tests/${gate} ($bid)" >&2
      miss=$((miss + 1))
    fi
  done < "$reg"
  if [ "$miss" -gt 0 ]; then
    return 1
  fi
  echo "perf-baseline-governance registry OK (${n} baselines)"
  return 0
}

# 若 baseline 文件相对 base_ref 有变更，registry 中 version 须变化。
# SHUX_ENG_BASELINE_BASE_REF 默认 origin/main，回退 HEAD~1 / HEAD。
perf_baseline_diff_requires_version_bump() {
  local base_ref="${SHUX_ENG_BASELINE_BASE_REF:-}"
  if [ -z "$base_ref" ]; then
    if git rev-parse origin/main >/dev/null 2>&1; then
      base_ref="origin/main"
    elif git rev-parse HEAD~1 >/dev/null 2>&1; then
      base_ref="HEAD~1"
    else
      echo "perf-baseline-governance: diff check SKIP (no base ref)"
      return 0
    fi
  fi
  if ! git rev-parse "$base_ref" >/dev/null 2>&1; then
    echo "perf-baseline-governance: diff check SKIP (invalid base $base_ref)"
    return 0
  fi
  local fail=0
  while IFS=$'\t' read -r bid path ver _rest; do
    [ -z "${bid:-}" ] && continue
    case "$bid" in \#*) continue ;; esac
    if ! git diff --name-only "$base_ref" HEAD -- "$path" 2>/dev/null | grep -qxF "$path"; then
      continue
    fi
    local old_ver new_ver
    old_ver="$(git show "${base_ref}:${PERF_BASELINE_REGISTRY}" 2>/dev/null \
      | awk -F'\t' -v i="$bid" '$1==i {print $3; exit}')"
    new_ver="$(perf_baseline_registry_get "$bid" 3)"
    if [ -z "$old_ver" ]; then
      echo "perf-baseline-governance WARN: new baseline $bid in registry (OK)"
      continue
    fi
    if [ "$old_ver" = "$new_ver" ]; then
      echo "perf-baseline-governance FAIL: $path changed but version still $ver (bump registry)" >&2
      fail=1
    else
      echo "perf-baseline-governance version bump OK $bid: $old_ver -> $new_ver"
    fi
  done < "$PERF_BASELINE_REGISTRY"
  # registry 本身若改了但无 version 列变化且 baseline 变了 — 上面已覆盖
  return "$fail"
}
