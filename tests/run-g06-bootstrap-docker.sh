#!/usr/bin/env bash
# run-g06-bootstrap-docker.sh — G-06 冷启动：phase1 stub + bootstrap-driver-seed（实时输出）
#
# 用法（仓库根）：
#   ./tests/run-g06-bootstrap-docker.sh
#
# 步骤：
#   1) 恢复 *_gen seed
#   2) make bootstrap-driver-seed（无 partial seed 时 Makefile 自动生成 phase1 弱桩）
#   3) 若产出真 partial（含强符号 seed_mega），写入 seeds/
#
# 日志：/tmp/shux-g06-bootstrap.log

set -euo pipefail
cd "$(dirname "$0")/.."

progress() { echo "[$(date +%H:%M:%S)] $*"; }
LOG="${SHUX_G06_BOOTSTRAP_LOG:-/tmp/shux-g06-bootstrap.log}"

INNER='
set -e
progress() { echo "[$(date +%H:%M:%S)] $*"; }

cd /src/compiler
chmod +x scripts/*.sh 2>/dev/null || true

progress "make clean (drop host-built .o) ..."
make clean

copy_seed() { cat "$1" > "$2"; }

for f in lexer_gen parser_gen typeck_gen codegen_gen pipeline_gen driver_gen preprocess_gen \
  lsp_io_gen lsp_gen lsp_diag_gen lsp_io_std_heap_gen \
  driver_fmt_gen driver_check_gen driver_test_gen driver_compile_gen driver_build_gen driver_run_gen driver_emit_gen; do
  copy_seed "seeds/${f}.linux.x86_64.c" "${f}.c"
done
copy_seed seeds/bootstrap_shuxc.linux.x86_64 bootstrap_shuxc
copy_seed seeds/bootstrap_shuxc.linux.x86_64 shux-c
chmod +x bootstrap_shuxc shux-c

if [ -s seeds/asm_backend_partial.linux.x86_64.o ]; then
  progress "partial seed exists — copy to build_asm/seed_host"
  mkdir -p build_asm/seed_host
  cat seeds/asm_backend_partial.linux.x86_64.o > build_asm/seed_host/asm_backend_partial.o
else
  progress "partial seed missing — Makefile will gen phase1 backend stub"
fi

progress "prebuild pipeline_glue_standalone.o ..."
progress "regen pipeline_gen.c (force) ..."
make pipeline_gen.c SHUX_FORCE_REGEN_GEN=1
progress "prebuild pipeline_glue_standalone.o ..."
make build_asm/pipeline_glue_standalone.o SHUX_FORCE_REGEN_GEN=1

progress "bootstrap-driver-seed ..."
make bootstrap-driver-seed SHUX_FORCE_REGEN_GEN=1
progress "bootstrap-driver-seed OK"
./shux-c -h | head -3

PARTIAL=build_asm/seed_host/asm_backend_partial.o
if [ -s "$PARTIAL" ] && nm "$PARTIAL" 2>/dev/null | awk "/ T / { s=\$3; sub(/^_/,\"\",s); if (s==\"backend_asm_codegen_ast_seed_mega\") found=1 } END { exit !found }"; then
  progress "capture real partial seed (seed_mega)"
  mkdir -p seeds
  cat "$PARTIAL" > seeds/asm_backend_partial.linux.x86_64.o
  ls -la seeds/asm_backend_partial.linux.x86_64.o
elif [ -s "$PARTIAL" ] && [ "$(wc -c <"$PARTIAL" | tr -d " ")" -ge 50000 ] && \
  nm "$PARTIAL" 2>/dev/null | awk "/ T / { s=\$3; sub(/^_/,\"\",s); if (s ~ /^backend_/) n++ } END { exit (n+0<180) }"; then
  progress "capture real partial seed (backend T>=180, no seed_mega yet)"
  mkdir -p seeds
  cat "$PARTIAL" > seeds/asm_backend_partial.linux.x86_64.o
  ls -la seeds/asm_backend_partial.linux.x86_64.o
else
  progress "WARN: partial still phase1 stub (asm.sx -E not yet green)"
fi
'

progress "run-g06-bootstrap-docker: LOG $LOG (tail -f $LOG)"
chmod +x tests/lib/progress-run.sh tests/lib/docker-linux-run.sh

export SHUX_DOCKER_MEMORY="${SHUX_DOCKER_MEMORY:-16g}"
export SHUX_DOCKER_SHM="${SHUX_DOCKER_SHM:-4g}"

./tests/lib/progress-run.sh "G-06 bootstrap-driver-seed" "$LOG" -- \
  ./tests/lib/docker-linux-run.sh compiler "$INNER"

progress "run-g06-bootstrap-docker OK"
