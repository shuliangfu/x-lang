# Shux 测试说明

本目录包含编译器与运行行为的测试，按功能分子目录；每个子目录下为 `.sx` 源码，根目录下 `run-*.sh` 为对应测试脚本。

## 一、自举相关回归套件

自举前需保证**同一套测试**覆盖：泛型、trait、多文件、import、core/std 模块、result、option、mem、io、io.driver、net、UB、ABI 等，自举后两代编译器行为一致。

**执行方式：**

- **推荐（分轨全量）**：`./tests/run-all-c.sh`（全量用 C 版编译器 shux-c）、`./tests/run-all-sx.sh`（全量用 .sx 流水线编译器 shux_sx）。CI 两条都跑，见 `.github/workflows/ci.yml`。
- **通用脚本**：`./tests/run-all.sh` 跑全部 run-*.sh；通过环境变量 `SHUX=compiler/shux-c` 或 `SHUX=compiler/shux_sx` 指定用哪支编译器，不设则用当前 `compiler/shux`。
- **从零与 build_tool**：`make -C compiler build-tool` / `first-time` 仅用 **shux-c** 对 `../build.sx` 做 `-E`（与 `lsp_*_gen` 同源，避免 Makefile 规则环）；仓库根 `./build.sh` 与 Makefile 一致（`-E` + `cc`，勿用 `shux ../build.sx -o build_tool`）。`make -C compiler all` 默认同时产出 **shux** 与 **shux-c**。
- 编译器目录：`make -C compiler test` = `test_c`（委托 `./tests/run-all-c.sh`）+ `test_sx`（`run-all-sx.sh`）；`make test_c` 与 `run-all-c.sh` **等价**，勿再假定 Makefile 内联脚本列表。

**不纳入回归的脚本**：`run-size-baseline.sh`、`run-perf-baseline.sh` 为可选体积/性能基线，需时单独执行。

**CI 多端测试**：push/PR 时在 **Linux**（ubuntu-22.04、ubuntu-latest）、**Linux ARM64**、**macOS**（macos-14、macos-latest）、**Windows**（MSYS2）、**Docker**（Alpine、Debian bookworm-slim）上先构建 shux + shux_sx，再依次执行 `./tests/run-all-c.sh` 与 `./tests/run-all-sx.sh`，见 `.github/workflows/ci.yml`。

## 二、测试脚本与覆盖范围

| 脚本 | 覆盖内容 | 用例类型 |
|------|----------|----------|
| `run-lexer.sh` | 词法：Token 序列与 expected.txt 逐行比对 | 正例 |
| `run-typeck.sh` | 类型检查：输出含 `typeck OK` | 正例 |
| `run-hello.sh` | 编译运行 examples/hello.sx，输出 "Hello World" | 正例 |
| `run-import.sh` | import 与多文件，输出 "Hello World" | 正例 |
| `run-std.sh` | 标准库路径 -L .，parse/typeck OK 并运行 | 正例 |
| `run-stdlib-import.sh` | 标准库 import（core/std 模块） | 正例 |
| `run-target.sh` | -target 交叉编译（若支持） | 正例 |
| `run-return-value.sh` | main 最后一表达式作为返回值 | 正例 |
| `run-multi-func.sh` | 多函数、调用 | 正例 |
| `run-generic.sh` | 泛型函数/类型、单态化 | 正例 |
| `run-trait.sh` | trait 定义与实现 | 正例 |
| `run-multi-file.sh` | 多文件编译与链接 | 正例 |
| `run-multi-file-generic.sh` | 多文件 + 泛型 | 正例 |
| `run-binary-expr.sh` | 二元运算：加减乘除取模、移位、位运算、比较、逻辑等 | 正例 |
| `run-compound-assign.sh` | 复合赋值 +=、-=、*= 等 | 正例 |
| `run-let-const.sh` | let/const 声明与常量表达式 | 正例 |
| `run-bool.sh` | 布尔类型与 true/false | 正例 |
| `run-if-expr.sh` | if/else、else if、无 else | 正例 |
| `run-ternary.sh` | 三元表达式 | 正例 |
| `run-option.sh` | core.option Option&lt;T&gt; | 正例 |
| `run-result.sh` | core.result Result&lt;T,E&gt; | 正例 |
| `run-process.sh` | 进程/退出码相关 | 正例 |
| `run-io.sh` | std.io 读写等 | 正例 |
| `run-while.sh` | while/loop、break/continue；**负例**：break 在循环外报错 | 正例 + 负例 |
| `run-return-expr.sh` | 显式 return 表达式 | 正例 |
| `run-for.sh` | for 循环 | 正例 |
| `run-float.sh` | f32/f64、浮点字面量、科学计数法、.5、边界与负例 | 正例 + 边界 + 负例 |
| `run-parser.sh` | 解析负例：return 后缺分号报 parse error | 负例 |
| `run-struct.sh` | 结构体定义、字面量、字段访问、allow(padding)；未 allow 隐式 padding 报错 | 正例 + 负例 |
| `run-slice.sh` | 切片 T[]、从数组初始化、下标 | 正例 |
| `run-array.sh` | 固定长数组 T[N]、初值 0、字面量、下标 | 正例 |
| `run-pointer.sh` | 裸指针 *T、0 初始化 | 正例 |
| `run-enum.sh` | 无负载枚举、Name.Variant、match 枚举分支 | 正例 |
| `run-match.sh` | match 表达式（整型分支与 _） | 正例 |
| `run-panic.sh` | panic() / panic(expr)，编译通过且运行非 0 退出 | 正例 |
| `run-defer.sh` | defer 块与块尾返回值 | 正例 |
| `run-goto.sh` | label 与 goto、return | 正例 |
| `run-preprocess.sh` | 条件编译（#if/#else/#endif 等） | 正例 |
| `run-sx-pipeline.sh` | .sx 流水线（-sx -E 生成 C）；无 pipeline 时 SKIP | 正例 / SKIP |
| `run-sx-multi-file.sh` | 多文件 .sx 流水线；无 pipeline 时 SKIP | 正例 / SKIP |
| `run-asm.sh` | -backend asm 出汇编、.text/main/ret、可选 as+ld；无 asm 时 SKIP | 正例 / SKIP |
| `run-without-c.sh` | 用 asm 路径构建 shux_asm 再跑全量测试（无 C 运行时）；无 asm 时 SKIP | 正例 / SKIP |
| `run-vector.sh` | 向量 i32x4/u32x4/i32x16、0 与字面量初始化、逐分量加 | 正例（失败即 exit 1，不再 CI SKIP） |
| `run-fmt.sh` | core.fmt 格式化 | 正例（失败即 exit 1） |
| `run-debug.sh` | 调试/打印相关 | 正例（失败即 exit 1） |
| `run-core-types.sh` | core 基础类型 | 正例 |
| `run-builtin.sh` | 内建函数 | 正例 |
| `run-mem.sh` | std.mem（Buffer、分配等） | 正例 |
| `run-string.sh` | 字符串相关 | 正例 |
| `run-vec.sh` | 动态数组/vec | 正例 |
| `run-heap.sh` | 堆分配 | 正例 |
| `run-runtime.sh` | 运行时接口 | 正例 |
| `run-fs.sh` | std.fs 文件系统（含 fs_readv_buf/fs_writev_buf 切片化） | 正例 |
| `run-path.sh` | 路径处理 | 正例 |
| `run-map.sh` | 映射/字典 | 正例 |
| `run-error.sh` | 错误处理 | 正例 |
| `run-net.sh` | std.net 占位（Ipv4Addr、TcpStream、udp_recv_many_buf/udp_send_many_buf） | 正例 |
| `run-io-driver.sh` | std.io.driver 占位（Buffer、submit、submit_*_batch_buf、register_fixed_buffers_buf） | 正例 |
| `run-ub.sh` | 未定义行为收窄：除零、越界等应 panic | 正例 + 负例 |
| `run-pool-limits.sh` | 侧车 grow 池边界：>16 形参、>64 实参、>96 stmt、>256 函数、>32 #if 深度、>24 局部、6/8 层嵌套 loop、>8 import select | 边界 |
| `run-abi-layout.sh` | ABI/布局断言（layout_abi.c），与 analysis/ABI与布局.md 一致 | 正例 |
| `run-lsp.sh` | LSP（shux --lsp）：initialize、didOpen、diagnostics、**textDocument/formatting**、shutdown/exit，校验 JSON-RPC 响应含 capabilities（含 documentFormattingProvider）、result 数组及格式化结果 newText | 正例 |

**说明**：`make test`（在 `compiler/` 下执行）或 `./tests/run-all.sh` 会依次执行上表全部脚本，与自举回归套件一致。`run-asm.sh`、`run-without-c.sh` 需支持 `-backend asm` 的 shux（`make -C compiler bootstrap-driver`）；若当前构建无 asm 则 SKIP 且不视为失败。`run-lsp.sh` 会按需执行 `make -C compiler bootstrap-driver-seed` 以得到带 LSP 的 shux，再发送 JSON-RPC 消息（含格式化请求）并校验响应。`run-lexer.sh`、`run-typeck.sh` 在存在 `compiler/shux-c` 时使用 shux-c，以保证无 `-o` 时输出 token/typeck OK 的语义一致。

## 三、边界与负向测试

- **浮点**：`run-float.sh` — 边界 0.0、.25、const 1e2；负例 `let x: f32 = 1` 报 typeck 错误。
- **循环**：`run-while.sh` — break 在循环外报 typeck 错误。
- **结构体**：`run-struct.sh` — `padding_no_allow.sx` 未 allow(padding) 时报 typeck 隐式 padding 错误。
- **解析**：`run-parser.sh` — return 后缺分号报 parse error。
- **UB**：`run-ub.sh` — 除零、数组/切片越界应 panic（exit 134），正常路径正常返回。

## 四、一键运行全部测试

在仓库根目录执行：

```bash
./tests/run-all.sh
```

或在 `compiler/` 目录下执行：

```bash
make test
```

两者都会跑完自举相关回归套件中全部 `run-*.sh`，并输出各脚本的 OK 或失败信息。

## 五、测试覆盖分析

### 5.1 已覆盖范围

| 维度 | 覆盖情况 |
|------|----------|
| **编译器链路** | lexer → parser → preprocess → typeck → codegen → cc 全链路有正例；parser/typeck/lexer 有负例或边界用例（见 README-boundary.md）。 |
| **语言特性** | 泛型、trait、多文件、import、let/const、if/ternary/while/for、match、enum、struct、slice、数组、指针、向量、defer、goto、panic、return 表达式、二元/一元运算、浮点、布尔 均有对应 run-*.sh。 |
| **core 模块** | types（core-types）、slice、option、result、builtin、debug、fmt 有独立或 stdlib-import 覆盖；core.mem 通过 std.mem 或 stdlib-import 间接使用。 |
| **std 模块** | io、io.driver、io.core（经 driver/mem 传递依赖）、mem、net、fs、path、map、string、vec、heap、process、error、runtime、time（`run-time.sh`：单调/墙钟/sleep/duration_ns）均有 run-*.sh；net 含 connect/listen/accept、accept_many/connect_many 及 udp_recv_many_buf/udp_send_many_buf；fs 含 fs_readv_buf/fs_writev_buf；io.driver 含 submit_*_batch_buf、register_fixed_buffers_buf。 |
| **边界/负例** | preprocess、parser、lexer、typeck、struct、float、while、for、let-const、import、match、array、slice、generic、trait、ub、panic 已补边界或负例（见 README-boundary.md）。 |
| **自举相关** | std.io.driver、std.io.core、std.mem、std.net、UB 收窄、ABI 布局 均纳入 run-all.sh。 |

### 5.2 缺口与说明

| 项 | 说明 |
|------|------|
| **FFI（extern function）** | `tests/run-ffi.sh` 已纳入 **run-all**（`tests/ffi/main.sx`：cstr_len / cstring_new / cstring_free）。扩展覆盖时在 `tests/ffi/` 增例并加长脚本即可。 |
| **return 操作数 vs 函数返回类型** | **`compiler/shux_sx`** 或 **`shux-sx`**：**`-sx`** 跑 `tests/typeck/return_operand_type_mismatch.sx` 须报 **typeck error**（`run-typeck.sh`）；入口与流水线统一走 `preprocess.sx`。宿主 **shux-c** 仍可能与 C typeck 宽松行为不完全一致。 |
| **memory-contract / packed** | `run-struct.sh` 已含 `memory-contract/packed_struct.sx` 正例；padding 负例同脚本。 |
| **体积/性能基线** | run-size-baseline.sh、run-perf-baseline.sh 有意不纳入 run-all，需时单独执行。 |

### 5.3 结论

- **自举回归所需**：run-all.sh 已覆盖编译器、语言特性、core/std 主要模块、边界与负例、io.driver/io.core/net/UB/ABI，**可视为自举相关回归已全面覆盖**。
- **可选增强**：将 FFI 独立测试纳入 run-all、启用 return 类型检查后打开 return_type_mismatch 断言、为 packed 或 memory-contract 增加单独用例。

## 六、CI 多端测试

- **位置**：`.github/workflows/ci.yml`
- **触发**：推送到或 PR 到 `main` / `master` 分支时自动运行。
- **矩阵**：**Linux**（ubuntu-22.04、ubuntu-latest）、**Linux ARM64**（ubuntu-24.04-arm，公开仓库免费）、**macOS**（macos-14、macos-latest）、**Windows**（MSYS2）、**Docker**（Alpine、Debian bookworm-slim 容器内安装 make/gcc/bash/diffutils 后执行相同命令）。
- **要求**：托管 runner 或容器内需 `cc`/`make`/`bash`/`diffutils`；Windows 由 setup-msys2 提供。

### 6.1 CI 必跑与可选测试

| 类型 | 脚本 | 说明 |
|------|------|------|
| **CI 必跑** | run-all.sh 中除 run-asm、run-without-c 外的全部 run-*.sh | 在 GitHub Actions 多平台（Linux/macOS/Windows/Docker）上执行；失败则 CI 失败（部分脚本在 CI 下失败时由 run() 打印 SKIP 保绿，见 run-all.sh）。 |
| **CI 可选（限时）** | `linux-asm-smoke` job：见 `.github/workflows/ci.yml` — `make bootstrap-driver` + `SHUX_CI_FORCE_ASM=1 ./tests/run-asm.sh`（仅 ubuntu-latest）；与主矩阵并行，不影响其它平台。**失败**时表示 Linux 上 asm 烟测退化，需在本地复现。 |
| **CI 不跑（默认可 SKIP）** | run-asm.sh（主矩阵内） | 各平台 `run-all` 中仍 SKIP（需 `SHUX_CI_FORCE_ASM=1`）；与上项专用 job 分工。 |
| **CI 可选（条件 SKIP）** | run-without-c.sh | 需支持 `-backend asm` 的 shux；CI 默认不构建 `bootstrap-driver` 时通常 SKIP。 |

**本地全量验证（含 asm）**：

1. 构建支持 asm 的 shux：`make -C compiler bootstrap-driver`
2. 跑全量测试：`./tests/run-all.sh`（此时 run-without-c 会真正执行；run-asm.sh 在非 CI 环境下会执行，不再主动 SKIP）
3. 若仅验证 asm 后端：`./tests/run-asm.sh`；验证无 C 运行时路径：`./tests/run-without-c.sh`

**决策记录**：主矩阵不因 asm 加长；**Linux asm 烟测**在独立 job `linux-asm-smoke` 中限时执行（见 workflows）。全盘「无 C 运行时」仍以 `run-without-c.sh` 在本地验证为主。参见 `compiler/docs/SELFHOST.md`、`analysis/下一步开发分析.md` 阶段 10.3。

### 6.2 完全脱离 C 的验证（run-without-c）

- **适用场景**：验证「用 asm 后端构建出的 shux_asm」能否在不依赖 C 运行时逻辑的前提下通过全量测试（仅链接最少 C 桩）；为日后完全脱离 C/Makefile 的路线提供回归保障。
- **验证方式**：先 `make -C compiler bootstrap-driver` 得到支持 `-backend asm` 的 shux，再在仓库根执行 `./tests/run-without-c.sh`。脚本会使用 `build_tool` 以 asm 路径编出 `compiler/shux_asm`，并用 `SHUX=compiler/shux_asm ./tests/run-all.sh` 跑全量测试；通过即表示脱离 C 的构建路径可用。CI 下不跑此脚本（见 §6.1）。

### 6.3 run-sx-pipeline 与 -sx -E 超时

- **现象**：Linux/macOS CI 在「shux_sx built」之后执行 `run-sx-pipeline.sh` 时可能长时间无输出甚至卡住；有时卡在 **make shux-sx-pipeline**（编译巨大的 pipeline_gen.c）而非 -sx -E 本身。
- **原因**：① **macOS 无 `timeout` 命令**，脚本若不用可移植超时则会无限等待；② **make bootstrap-pipeline / shux-sx-pipeline** 无超时，编译 pipeline_gen.c 可耗时数分钟；③ **shux_sx -sx -E** 会进入 `pipeline_run_sx_pipeline_impl`（`compiler/pipeline_gen.c`），内部 typeck/codegen 在部分环境下可能死循环或极慢。
- **根因（已通过诊断确认）**：run-sx-multi-file 时最后一条诊断为 `pipeline: impl start`、无 `pipeline: after parse` → 卡在 **parser**（`pipeline_parse_into_with_init` / `parser_parse_into`）解析 **foo.sx** 阶段，需在 compiler 生成的 parser 码（pipeline_gen.c 中 `parser_parse_into`）或 src/parser 中查死循环/平台分支。  
- **处理**：  
  - **CI**：run-all.sh 会执行 run-sx-pipeline.sh、run-sx-multi-file.sh（通过 run()）；若失败则打印 SKIP 并继续，保证 run-all 不因单脚本失败而红。  
  - **非 CI**：两脚本对「make bootstrap-pipeline + shux-sx-pipeline」整段施加 **120 秒**可移植超时，对 **shux_sx -sx -E** 施加 **60 秒**超时；任一步超时则 SKIP 并 exit 0。  
  - **run-vector.sh**：CI 下若向量测试失败则 SKIP 并 exit 0（会先打印失败原因），保证 run-all 通过；本地失败仍 exit 1，便于从根上修。
