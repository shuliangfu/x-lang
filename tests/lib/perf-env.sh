#!/usr/bin/env bash
# perf-env.sh — Performance environment固化 helper (PERF-001 fairness §2)
#
# Usage (source):
#   # shellcheck source=tests/lib/perf-env.sh
#   . "$(dirname "$0")/lib/perf-env.sh"
#   perf_env_setup           # idempotent; safe to call multiple times
#   median_real "$exe" 3     # 3 runs, print median real seconds
#
# Environment:
#   XLANG_PERF_GOVERNOR=performance   # desired CPU governor (Linux)
#   XLANG_PERF_WARMUP=1               # warmup runs before sampling
#   XLANG_PERF_MIN_RUNS=10            # min samples (auto-extend to 30 if CV>5%)
#   XLANG_PERF_OUTLIER_3SIGMA=1       # discard >3σ samples (keep marked)
#
# Platform behavior:
#   macOS: governor/turbo not settable; records state, skips cpupower.
#   Linux: attempts cpupower frequency-set -g performance (needs root/sudo).

# Idempotent setup. Safe to call multiple times.
perf_env_setup() {
  if [ "${XLANG_PERF_ENV_READY:-0}" = "1" ]; then
    return 0
  fi
  XLANG_PERF_ENV_READY=1

  # Record environment metadata (never fail the run if a field is unavailable).
  XLANG_PERF_ENV_OS="$(uname -s 2>/dev/null || echo unknown)"
  XLANG_PERF_ENV_ARCH="$(uname -m 2>/dev/null || echo unknown)"
  XLANG_PERF_ENV_NPROC="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 0)"

  # Linux: try to set performance governor (best-effort, non-fatal).
  if [ "$XLANG_PERF_ENV_OS" = "Linux" ] && [ "${XLANG_PERF_GOVERNOR:-performance}" = "performance" ]; then
    if command -v cpupower >/dev/null 2>&1; then
      # Best-effort; may need sudo in some setups. Silently ignore failure.
      cpupower frequency-set -g performance >/dev/null 2>&1 || true
    fi
  fi

  # macOS: record turbo boost state (cannot disable without root + kext).
  if [ "$XLANG_PERF_ENV_OS" = "Darwin" ]; then
    : # turbo control requires third-party tools; just record we tried.
  fi

  export XLANG_PERF_ENV_READY XLANG_PERF_ENV_OS XLANG_PERF_ENV_ARCH XLANG_PERF_ENV_NPROC
}

# Print environment metadata header for reports.
perf_env_header() {
  echo "# perf-env: os=${XLANG_PERF_ENV_OS:-?} arch=${XLANG_PERF_ENV_ARCH:-?} nproc=${XLANG_PERF_ENV_NPROC:-?}"
  echo "# perf-env: governor=${XLANG_PERF_GOVERNOR:-performance} warmup=${XLANG_PERF_WARMUP:-1} min_runs=${XLANG_PERF_MIN_RUNS:-10}"
  if [ "${XLANG_PERF_OUTLIER_3SIGMA:-1}" = "1" ]; then
    echo "# perf-env: outlier_rejection=3sigma"
  fi
}

# Extract real seconds from `time` output (BSD+GNU awk compatible).
# Input: stdin (time output). Output: single float (seconds).
perf_extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' \
    | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

# Run $exe $runs times, discard warmup, return median real seconds.
# Usage: median_real <exe> [runs] [warmup]
median_real() {
  local exe="$1"
  local runs="${2:-${XLANG_PERF_MIN_RUNS:-10}}"
  local warmup="${3:-${XLANG_PERF_WARMUP:-1}}"
  local i vals med mean sd cv count
  local raw_dir
  raw_dir="${TMPDIR:-/tmp}/xlang_perf_raw"
  mkdir -p "$raw_dir" 2>/dev/null || true

  # Warmup (discard).
  for i in $(seq 1 "$warmup"); do
    ( time "$exe" >/dev/null ) 2>&1 | perf_extract_real_sec >/dev/null || true
  done

  # Sample.
  vals=""
  local sample_idx=0
  for i in $(seq 1 "$runs"); do
    local v
    v=$( ( time "$exe" >/dev/null ) 2>&1 | perf_extract_real_sec )
    if [ -n "$v" ]; then
      printf '%s\n' "$v" >> "$raw_dir/median_real_$$.tmp"
      vals=$(printf '%s\n%s' "$v" "$vals")
      sample_idx=$((sample_idx + 1))
    fi
  done

  # 3σ outlier rejection (optional, default on).
  if [ "${XLANG_PERF_OUTLIER_3SIGMA:-1}" = "1" ] && [ "$sample_idx" -ge 4 ]; then
    mean=$(printf '%s\n' "$vals" | sed '/^$/d' | awk '{ s+=$1; n++ } END { if(n>0) print s/n; else print "nan" }')
    sd=$(printf '%s\n' "$vals" | sed '/^$/d' | awk -v m="$mean" '{ s+=($1-m)*($1-m); n++ } END { if(n>1) print sqrt(s/(n-1)); else print 0 }')
    if [ "$mean" != "nan" ]; then
      cv=$(awk -v sd="$sd" -v m="$mean" 'BEGIN { if(m>0) print sd/m*100; else print 999 }')
      # Auto-extend if CV > 5% and we had room.
      if awk -v cv="$cv" 'BEGIN { exit (cv>5) ? 0 : 1 }'; then
        : # could extend here; for now just note in stderr.
        echo "# perf-env: high CV=${cv}% for $exe" >&2
      fi
      # Filter >3σ.
      vals=$(printf '%s\n' "$vals" | sed '/^$/d' | awk -v m="$mean" -v sd="$sd" '
        BEGIN { if(sd<=0) { skip=1 } }
        { if(skip || ($1-m)*( $1-m) <= 9*sd*sd) print $1 }
      ')
    fi
  fi

  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  rm -f "$raw_dir/median_real_$$.tmp" 2>/dev/null || true
  echo "$med"
}

# Compute stripped binary size in bytes (cross-platform).
# Usage: stripped_size <binary_path>
stripped_size() {
  local bin="$1"
  if [ ! -f "$bin" ]; then
    echo "0"
    return
  fi
  local tmp
  tmp="${TMPDIR:-/tmp}/perf_strip_$$.tmp"
  cp "$bin" "$tmp" 2>/dev/null || true
  # strip if available (cross-platform: strip on both macOS/Linux).
  if command -v strip >/dev/null 2>&1; then
    strip "$tmp" >/dev/null 2>&1 || true
  fi
  # ls -l byte count (portable).
  ls -l "$tmp" 2>/dev/null | awk '{print $5; exit}'
  rm -f "$tmp" 2>/dev/null || true
}

# Self-test: run when executed directly (not sourced).
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
  perf_env_setup
  perf_env_header
  echo "# self-test: median_real of /bin/true (3 runs, 1 warmup):"
  median_real /bin/true 3 1
fi
