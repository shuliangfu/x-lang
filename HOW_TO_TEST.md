# 全量测试指南

## 环境要求
- GCC 或 Clang（支持 C11）
- Make
- Python 3
- Perl
- Linux 需 `liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev`
- macOS 无额外依赖

## 构建步骤（按顺序，不能跳过）

```bash
cd /path/to/shux

# 1. 编译器构建（必须用 SHUX_LEGACY_C_FRONTEND=1）
make -C compiler shux-c SHUX_LEGACY_C_FRONTEND=1 -B

# 2. 预编译所有 std .o 文件（必须用 SHUX_COMPILE_STD_USE_C=1）
make -C compiler std-objs SHUX_COMPILE_STD_USE_C=1

# 3. 预编译 core/slice/slice.o
make -C compiler ../core/slice/slice.o
```

## 全量测试

```bash
# 方式 A：非 CI 模式（遇错即停，推荐开发用）
./tests/run-all.sh

# 方式 B：CI 模式（跑完所有再汇总）
CI=1 ./tests/run-all.sh
```

## 验证结果
- 成功：输出 `all tests OK`，退出码 0
- CI 模式失败：末尾输出 `run-all: N test(s) failed; failed scripts: ...`

## 从零开始（clean rebuild）

```bash
cd /path/to/shux
find . -name '*.o' -not -path './.git/*' -delete
make -C compiler shux-c SHUX_LEGACY_C_FRONTEND=1 -B
make -C compiler std-objs SHUX_COMPILE_STD_USE_C=1
make -C compiler ../core/slice/slice.o
CI=1 ./tests/run-all.sh
```

## 常见错误及修复

### `make all` 覆盖 shux-c
run-all.sh 内部会跑 `make -C compiler all`，默认 target 会把 shux-c 覆盖成
bootstrap_shuxc（.x pipeline，3.9MB），导致 62+ 测试失败。
run-all.sh 自己会在后面用 `make -B SHUX_LEGACY_C_FRONTEND=1 shux-c` 恢复，
但如果 std .o 是被覆盖期间用错误 shux-c 编译的，需要删掉重建：

```bash
find std core -name '*.o' -delete
make -C compiler shux-c SHUX_LEGACY_C_FRONTEND=1 -B
make -C compiler std-objs SHUX_COMPILE_STD_USE_C=1
make -C compiler ../core/slice/slice.o
```

### Linux ntohl/ntohs 编译失败
std/net 模块用了 `extern function ntohl(...)` 等声明。在 Linux 上 `ntohl` 在
`arpa/inet.h` 中声明，但直接 `#include <arpa/inet.h>` 会与 shux 的
`extern function bind(...)` 等声明冲突（签名不同）。
解决方向：不全局 include，改为在生成的 C 里只声明 ntohl/ntohs 的原型，
或让 shux 的 extern 声明与系统签名对齐。

### macOS net 测试失败（bind EPERM）
macOS 受管沙箱禁止 `bind()` 系统调用（纯 C 也 `Operation not permitted`）。
这不是代码问题，需要在能联网的环境（如 ubuntu-server）跑。

## 构建产物说明
- `compiler/shux-c` — 真正的 C 前端编译器（约 1MB），用 SHUX_LEGACY_C_FRONTEND=1 构建
- `compiler/shux` — bootstrap-driver-seed（约 373KB），用于 typeck/check
- `std/*/*.o` — std 库预编译目标文件，用 SHUX_COMPILE_STD_USE_C=1 构建
- `core/slice/slice.o` — slice 构造薄封装，用 Makefile 规则构建

## 测试范围
run-all.sh 包含 90 个测试脚本，覆盖：
- 词法/语法/类型检查（lexer/parser/typeck）
- 核心运行时（hello/io/fs/net/tar/string/heap/vec 等）
- 语言特性（match/struct/enum/trait/generic/async）
- 标准库（base64/crypto/json/csv/http/compress 等）
- 边界检查（ub/pool-limits/abi-layout）

自举前必须清单（run-bootstrap-checklist-gate.sh）和内核测试
（tests/kernel/*-gate.sh）不在 run-all.sh 中，是独立 gate。
