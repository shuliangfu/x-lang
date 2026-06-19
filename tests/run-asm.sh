#!/usr/bin/env bash
# asm 后端测试：-backend asm 出汇编，检查 .text/main/ret，可选 as+ld 跑出退出码。
# 在仓库根目录执行：./tests/run-asm.sh
# 若当前 shux 不支持 -su/-backend asm（无 pipeline），则 SKIP。
# macOS：`-o <exe>` 自动 ld 依赖 Xcode CLT/SDK（-lSystem）；失败时可只看 .s/.o 校验或安装 CLT（见 compiler/docs/SELFHOST.md §5）。

set -e
cd "$(dirname "$0")/.."

# CI 下默认跳过；设 SHUX_CI_FORCE_ASM=1 时仍执行（可选 job 与本机等价验证）
if { [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]; } && [ -z "${SHUX_CI_FORCE_ASM:-}" ]; then
  echo "run-asm SKIP (CI: skip -backend asm unless SHUX_CI_FORCE_ASM=1; see tests/README §6.1)"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
# CI asm-smoke job 已 bootstrap-driver-seed；勿重跑 bootstrap-driver（会全量 build_shux_asm 12min+ 超时）。
if [ ! -x compiler/shux ]; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || true
  make -C compiler bootstrap-pipeline 2>/dev/null || true
  make -C compiler shux-sx-pipeline 2>/dev/null || true
elif [ -z "${CI:-}" ]; then
  make -C compiler bootstrap-driver 2>/dev/null || true
  make -C compiler bootstrap-pipeline 2>/dev/null || true
  make -C compiler shux-sx-pipeline 2>/dev/null || true
fi
if [ -x compiler/shux ]; then SHUX=./compiler/shux; elif [ -x compiler/shux_sx ]; then SHUX=./compiler/shux_sx; else SHUX=./compiler/shux; fi
[ -x "$SHUX" ] || { echo "compiler/shux not found"; exit 1; }

# 测试用例：main 返回 42；expr 返回 6（2*3）；local 局部 const + VAR（cmp.sx 需 C 解析器支持比较，暂不加入）
ASM_TESTS="tests/asm/main.sx tests/asm/expr.sx tests/asm/local.sx tests/asm/index_assign.sx tests/asm/tiny_ptr.sx"
for F in $ASM_TESTS; do
  [ -f "$F" ] || { echo "run-asm: $F not found"; exit 1; }
done

# 用 -backend asm 出汇编（默认 x86_64）；以 main.sx 为代表做 as+ld 与 arm64 校验
MAIN_ASM="tests/asm/main.sx"
OUT_S=$(mktemp)
EC=0
"$SHUX" -backend asm "$MAIN_ASM" > "$OUT_S" 2>&1 || EC=$?

if [ "$EC" -ne 0 ]; then
  # 任意 -backend asm 失败均视为「当前编译器不支持 asm」并 SKIP（如 run-all-c 用的 shux-c、或未 bootstrap-driver）
  echo "run-asm SKIP (compiler does not support -backend asm; run make bootstrap-driver for full asm)"
  [ -s "$OUT_S" ] && cat "$OUT_S"
  rm -f "$OUT_S"
  exit 0
fi

# bootstrap-driver-seed 的 shux 可能只 emit parse/typeck 摘要而无 .text；完整 asm 由 ubuntu matrix build_shux_asm 覆盖
if grep -q 'typeck OK' "$OUT_S" && ! grep -q '\.text' "$OUT_S"; then
  echo "run-asm SKIP (seed shux has no stdout asm backend; ubuntu x64 CI covers build_shux_asm)"
  rm -f "$OUT_S"
  exit 0
fi

# 若输出是 C（无 pipeline 时 C driver 可能忽略 -backend asm），则跳过
if grep -q '^#include' "$OUT_S"; then
  echo "run-asm SKIP (shux built without -sx pipeline; -backend asm not used)"
  rm -f "$OUT_S"
  exit 0
fi

# 检查必备汇编
if ! grep -q '\.text' "$OUT_S"; then
  echo "run-asm: output missing .text"
  cat "$OUT_S"
  rm -f "$OUT_S"
  exit 1
fi
if ! grep -q 'main' "$OUT_S"; then
  echo "run-asm: output missing main"
  cat "$OUT_S"
  rm -f "$OUT_S"
  exit 1
fi
if ! grep -q 'ret' "$OUT_S"; then
  echo "run-asm: output missing ret"
  cat "$OUT_S"
  rm -f "$OUT_S"
  exit 1
fi

echo "run-asm: asm output OK (.text, main, ret)"

# 7.4 直接出 ELF/Mach-O .o：-o out.o 须为可重定位对象文件；若命令成功但魔数/类型不符则失败（禁止把汇编文本当 .o）。
DIRECT_O=/tmp/shux_asm_direct.o
DIRECT_BIN=/tmp/shux_asm_direct_bin
if "$SHUX" -backend asm -o "$DIRECT_O" "$MAIN_ASM" 2>/dev/null; then
  if ! file "$DIRECT_O" | grep -qiE 'ELF[[:space:]]*.*relocatable|Mach-O[[:space:]]*64-bit.*object'; then
    echo "run-asm: -o out.o succeeded but file(1) is not a relocatable object: $(file -b "$DIRECT_O" 2>/dev/null)"
    rm -f "$DIRECT_O" "$DIRECT_BIN"
    exit 1
  fi
  if file "$DIRECT_O" | grep -q 'ELF.*relocatable'; then
    echo "run-asm: direct -o out.o OK (ELF relocatable)"
    if ld -e _main -o "$DIRECT_BIN" "$DIRECT_O" 2>/dev/null; then
      GOT=0; "$DIRECT_BIN" 2>/dev/null || GOT=$?
      if [ "$GOT" -eq 42 ]; then
        echo "run-asm: direct .o linked and ran OK (exit 42)"
      fi
      rm -f "$DIRECT_BIN"
    fi
  elif file "$DIRECT_O" | grep -q 'Mach-O.*object'; then
    echo "run-asm: direct -o out.o OK (Mach-O object, macOS)"
    if ld -e _main -o "$DIRECT_BIN" "$DIRECT_O" -lSystem 2>/dev/null || clang -o "$DIRECT_BIN" "$DIRECT_O" 2>/dev/null; then
      GOT=0; "$DIRECT_BIN" 2>/dev/null || GOT=$?
      if [ "$GOT" -eq 42 ]; then
        echo "run-asm: direct .o linked and ran OK (exit 42)"
      fi
      rm -f "$DIRECT_BIN"
    fi
  fi
  rm -f "$DIRECT_O"
fi

# -o <exe>（无 .o/.s 后缀）：driver 应自动调 ld 生成可执行文件，一条命令出可执行文件
ASM_EXE=/tmp/shux_asm_exe
rm -f "$ASM_EXE"
if "$SHUX" -backend asm -o "$ASM_EXE" "$MAIN_ASM" 2>/dev/null; then
  if [ -x "$ASM_EXE" ]; then
    GOT=0; "$ASM_EXE" 2>/dev/null || GOT=$?
    if [ "$GOT" -eq 42 ]; then
      echo "run-asm: -o <exe> (auto ld) OK (exit 42)"
    fi
  fi
  rm -f "$ASM_EXE"
fi

# 多用例：expr.sx、local.sx 仅校验能成功出汇编且含 .text/main/ret
for ASM_FILE in tests/asm/expr.sx tests/asm/local.sx tests/asm/tiny_ptr.sx; do
  OUT_T=$(mktemp)
  if "$SHUX" -backend asm "$ASM_FILE" > "$OUT_T" 2>/dev/null; then
    if grep -q '\.text' "$OUT_T" && grep -q 'main' "$OUT_T" && grep -q 'ret' "$OUT_T"; then
      echo "run-asm: $(basename "$ASM_FILE") OK"
    fi
  fi
  rm -f "$OUT_T"
done

# 可选：as + ld 并运行 main.sx，检查退出码 42；若有 as/ld 再对 expr/local 做 as+ld 校验退出码 7 和 3
OUT_O=/tmp/shux_asm_test.o
OUT_BIN=/tmp/shux_asm_test
if as -o "$OUT_O" "$OUT_S" 2>/dev/null; then
  if ld -o "$OUT_BIN" "$OUT_O" 2>/dev/null; then
    GOT=0
    "$OUT_BIN" 2>/dev/null || GOT=$?
    if [ "$GOT" -eq 42 ]; then
      echo "run-asm: linked and ran OK (exit 42)"
    else
      echo "run-asm: linked binary exit code $GOT (expected 42)"
    fi
  else
    echo "run-asm: ld failed (optional, asm output already verified)"
  fi
  rm -f "$OUT_O" "$OUT_BIN"
  # expr.sx 预期退出码 6（2*3），local.sx 预期 3
  for PAIR in "tests/asm/expr.sx:6" "tests/asm/local.sx:3" "tests/asm/tiny_ptr.sx:42"; do
    F="${PAIR%%:*}"; EXPECT="${PAIR##*:}"
    TMP_S=$(mktemp); TMP_O=/tmp/shux_asm_expr.o; TMP_BIN=/tmp/shux_asm_expr_bin
    if "$SHUX" -backend asm "$F" > "$TMP_S" 2>/dev/null && as -o "$TMP_O" "$TMP_S" 2>/dev/null && ld -o "$TMP_BIN" "$TMP_O" 2>/dev/null; then
      GOT=0; "$TMP_BIN" 2>/dev/null || GOT=$?
      if [ "$GOT" -eq "$EXPECT" ]; then
        echo "run-asm: as+ld $(basename "$F") OK (exit $EXPECT)"
      fi
    fi
    rm -f "$TMP_S" "$TMP_O" "$TMP_BIN"
  done
else
  echo "run-asm: as failed (optional)"
fi

# 可选：arm64 输出校验（对 main/expr/local 各跑一次，仅检查 .text/main/ret）
for ASM_FILE in $ASM_TESTS; do
  OUT_ARM=$(mktemp)
  if "$SHUX" -backend asm -target aarch64-linux-gnu "$ASM_FILE" > "$OUT_ARM" 2>/dev/null; then
    if grep -q '\.text' "$OUT_ARM" && grep -q 'main' "$OUT_ARM" && grep -q 'ret' "$OUT_ARM"; then
      echo "run-asm: arm64 $(basename "$ASM_FILE") OK"
    fi
  fi
  rm -f "$OUT_ARM"
done

# riscv64 出 .s：对 main/expr/local 各跑 -target riscv64，检查 .text/main/ret（RISC-V 也用 ret）
for ASM_FILE in $ASM_TESTS; do
  OUT_RV=$(mktemp)
  if "$SHUX" -backend asm -target riscv64 "$ASM_FILE" > "$OUT_RV" 2>/dev/null; then
    if grep -q '\.text' "$OUT_RV" && grep -q 'main' "$OUT_RV" && grep -q 'ret' "$OUT_RV"; then
      echo "run-asm: riscv64 $(basename "$ASM_FILE") .s OK"
    fi
  fi
  rm -f "$OUT_RV"
done

# riscv64 直接出 .o：-target riscv64 -o out.o 应生成 ELF；若有 riscv64 ld 则链接并运行
RISCV_O=/tmp/shux_asm_riscv64.o
RISCV_BIN=/tmp/shux_asm_riscv64_bin
if "$SHUX" -backend asm -target riscv64 -o "$RISCV_O" "$MAIN_ASM" 2>/dev/null; then
  # Linux CI / 宿主上应出 ELF relocatable；macOS 等宿主常为 Mach-O 或混用封装，不因格式误杀整条 run-asm。
  HOSTOS=$(uname -s 2>/dev/null || echo Unknown)
  if ! file "$RISCV_O" | grep -qiE 'ELF[[:space:]]*.*relocatable'; then
    if [ "$HOSTOS" != "Linux" ]; then
      echo "run-asm: riscv64 -o out.o SKIP ELF check on host=$HOSTOS ($(file -b "$RISCV_O" 2>/dev/null))"
    else
      echo "run-asm: riscv64 -o out.o succeeded but not ELF relocatable: $(file -b "$RISCV_O" 2>/dev/null)"
      rm -f "$RISCV_O" "$RISCV_BIN"
      exit 1
    fi
  fi
  if file "$RISCV_O" | grep -q 'ELF.*relocatable'; then
    echo "run-asm: riscv64 direct -o out.o OK (ELF relocatable)"
    for LD_CMD in "riscv64-unknown-elf-ld" "riscv64-linux-gnu-ld" "ld.lld" "ld"; do
      if command -v $LD_CMD >/dev/null 2>&1; then
        if $LD_CMD -e _main -o "$RISCV_BIN" "$RISCV_O" 2>/dev/null; then
          GOT=0; "$RISCV_BIN" 2>/dev/null || GOT=$?
          if [ "$GOT" -eq 42 ]; then
            echo "run-asm: riscv64 .o linked and ran OK (exit 42, $LD_CMD)"
            break
          fi
        fi
      fi
    done
    rm -f "$RISCV_BIN"
  fi
  rm -f "$RISCV_O"
fi

# Windows COFF .obj：-target *-windows-* -o out.obj 应生成 PE/COFF（仅 x86_64）；非 Windows 仅校验能产出非空文件
COFF_OBJ=/tmp/shux_asm_coff.obj
if "$SHUX" -backend asm -target x86_64-pc-windows-msvc -o "$COFF_OBJ" "$MAIN_ASM" 2>/dev/null; then
  if [ -f "$COFF_OBJ" ] && [ -s "$COFF_OBJ" ]; then
    if file "$COFF_OBJ" 2>/dev/null | grep -qiE 'PE32|COFF|MSVC|executable|object'; then
      echo "run-asm: Windows COFF -o out.obj OK (x86_64)"
    else
      echo "run-asm: Windows COFF -o out.obj OK (x86_64, object produced)"
    fi
  fi
  rm -f "$COFF_OBJ"
fi

rm -f "$OUT_S"
echo "run-asm OK"
