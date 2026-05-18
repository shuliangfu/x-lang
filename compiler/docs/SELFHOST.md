# Shulang 自举与「完全自举」约定

本文档固定**验收命令**、**目标分层（A/B/C）**与**当前链接拓扑**，避免口头「自举」与实现漂移。更细的 asm 能力表见 [src/asm/README.md](../src/asm/README.md) §十一。

---

## 1. 三层目标（与 README 对齐）

| 代号 | 含义 | 「完成」判据（摘要） |
|------|------|---------------------|
| **A** | 用户用 `shu` 编译 `.su` 为产物时**尽量不调用 cc 做编译** | `shu -backend asm -o x.o` 不生成 C；若 `-o` 为可执行名，driver 调 **ld/clang 仅链接**（见 `runtime.c` 中 `driver_asm_invoke_ld` / `invoke_ld`）。 |
| **B** | **构建编译器可执行文件**时不再依赖 **cc 编译 `pipeline_gen.c` 等大段 -E 产物** | 链接 `shu` / `shu_asm` 的命令行中**不出现**对 `pipeline_gen.c` 的 `cc -c`（允许保留 **cc 作链接器**、以及极小 C 桩如 `runtime_panic`）。 |
| **C** | 生成程序 / 构建链弱化 **libc**（freestanding） | Linux：`runtime_panic_x86_64.s`、`crt0_x86_64.s` 等；与 std 分层长期相关。 |

**「完全自举」**在仓库内建议默认指：**语义自举（shu 用 .su 前端编自己）+ 目标 B 在目标平台上成立**。是否包含 C 冷启动种子不在此否定（仍允许 `shu-c` / `bootstrap.sh`）。

---

## 2. 固定验收命令（CI / 本地）

在 `compiler` 目录下：

| 目的 | 命令 |
|------|------|
| **语义自举 + 两代一致性** | `make bootstrap-verify`（或 `make bootstrap-self` 烟测） |
| **全量 .su 测试** | `make test_su` |
| **C 前端回归** | `make test_c` |
| **asm 构建脚本（Goal 2）** | `SHU=./shu ./scripts/build_shu_asm.sh`；成功应产出 `shu_asm`（或 Linux crt0 路径下等价信息） |
| **asm smoke（可选 CI job）** | 仓库根：`SHU_CI_FORCE_ASM=1 ./tests/run-asm.sh`（workflow 中该 job 会先 `make bootstrap-driver`）；见 `.github/workflows/ci.yml` 之 `linux-asm-smoke` |
| **asm .o 段质量（非阻塞默认可选）** | `SHU=./shu ./scripts/check_asm_o_quality.sh`；严格失败：`SHU_ASM_QUALITY_STRICT=1 SHU=./shu ./scripts/check_asm_o_quality.sh`；缺口列表见 `build_asm/.asm_empty_text_list` |

`./build_tool ./shu` / `./build_tool ./shu asm` 的行为见根目录 [build.su](../../build.su) 与 [build_runtime.c](../src/build_runtime.c)（`build_run_asm_build` 调用 `scripts/build_shu_asm.sh`）。

---

## 3. 目标 B 的「Done」定义（可勾选）

- **B-strict（强）**：`./build_tool ./shu asm` 或 `build_shu_asm.sh` 成功产出的 `shu_asm` / `./shu`，其链接输入中**不得**包含由 `cc -c pipeline_gen.c` 得到的 `pipeline_su.o`（以及同类的 `driver_gen.c` 大 TU），且 `shu` 仍能通过 `make test_su` 或约定子集。
- **B-partial（当前 Linux 可达）**：使用 **crt0 + `build_asm/*.o` + runtime_panic** 路径链出 `shu_asm` 时，**未**执行 `cc -c pipeline_gen.c`。脚本成功时会打印说明（见 `build_shu_asm.sh`）。
- **B-hybrid（默认 macOS / 回退）**：拓扑 **`pipeline_su`**（见 §4）：用 `shu-c -E` 生成 `pipeline_gen.c` / `driver_gen.c` 等再 `cc -c` 链入——**不满足 B-strict**，但保证可工作的 `shu_asm`，直至各模块 `-backend asm -o` 的 `__text` 非空且链接拓扑切换为 **`full_asm`**。

验收时写明采用 **B-strict / B-partial / B-hybrid** 之一。

### 3.1 去掉 `cc -c pipeline_gen.c`（drop-cc）的前置条件

- **当前**：非 Linux 或未导出拓扑时等价 **`pipeline_su`**；Linux 且 `check_asm_o_quality.sh` 认定全部 `__text` 非空时，脚本**自动打上** `full_asm` 拓扑标签（§4）；**driver 回退分支仍可能执行** `ensure_asm_gen_driver_su_objs`（`shu-c -E` + `cc -c`），直至 **`full_asm` 单一链接线**（如 `SHU_ASM_EXPERIMENTAL_SKIP_GEN`）落地并默认跳过 gen_driver。
- **已满足部分**：Linux **crt0** 路径成功时，本次 `shu_asm` **未**使用 `pipeline_gen.c`（**B-partial**）。
- **预留环境变量**：`SHU_ASM_EXPERIMENTAL_SKIP_GEN` 保留给将来在 `full_asm` + 全 `__text` 非空时跳过 `gen_driver` 的实验分支（**未默认启用**）。

---

## 4. 链接拓扑（单一真相）

环境变量 **`SHU_ASM_LINK_TOPOLOGY`**（`build_shu_asm.sh` 识别）：

| 值 | 含义 |
|----|------|
| **`pipeline_su`**（默认／非 Linux） | `-E` 生成 `pipeline_su.o`、`driver_su.o`、LSP/preprocess 等 **gen_driver**，与 **C seed**（`asm_driver_seed`）及 **runtime_driver** 链接；**不**把 `build_asm/*.o` 并入（避免与 `pipeline_su.o` 重复符号及 macOS `ld` 异常）。**未手动导出拓扑时**：非 **Linux** 宿主一律保持此值（crt0+B-partial 仅 Linux glibc‑类路径已实现）。 |
| **`full_asm`**（Linux 自动选择） | 当 **`SHU_ASM_LINK_TOPOLOGY` 未导出**且 `check_asm_o_quality.sh` 写出 `build_asm/.asm_text_quality` 为 **`1`**（`asm_build_list` 中每条 `BUILD` 对应 `.o` 的 **`__text` 均非空**）时，`build_shu_asm.sh` **自动设为 `full_asm`**，用于标注与§3 对齐的 Target‑B‑strict 就绪度；driver 回退路径若仍调用 `ensure_asm_gen_driver_su_objs`，脚本会打印说明——**跳过 `cc -c pipeline_gen.c` 仍以 crt0 成功链接为准**。 |

**宿主策略（摘要）**：

- **Linux x86_64（非 Alpine）**：优先 **crt0** 链 `shu_asm`（可达 **B-partial**，无 `pipeline_gen.c`）。
- **macOS / Windows / Alpine 等**：仅 **pipeline_su** 混合链（**B-hybrid**）；不要将 `full_asm` 与同机构 `build_asm/*.o` 盲目并入回退链接。

### 4.1 空 `__text` 清单（逐项修 emitter / typeck / import）

- 跑完 `scripts/build_shu_asm.sh` 或单独 `scripts/check_asm_o_quality.sh` 后查看：
  - `compiler/build_asm/.asm_text_quality`：`1` = 全非空，`0` = 存在缺失或空段。
  - `compiler/build_asm/.asm_empty_text_list`：**一行一条**，形如 `MISSING foo.o`、`EMPTY foo.o`。按文件名对应 `asm_build_list.su` 的 `// BUILD:` 源 `.su`，在 **解析/类型/asm 后端**侧消除「仅占位无代码」的编译结果。
  - **质检脚本**对 **Mach-O** 读段名 `__text`，对 **ELF（Linux）** 读 `.text`；若仅在 Linux 上曾出现「24 条全 EMPTY」而 macOS 仅少数条，多半是段名误判而非 asm 未落码——以 `check_asm_o_quality.sh` 实现为准。
- 近期已修：`let` 带显式数组类型时令 `LetDecl.type_ref`/索引赋值可走通 typeck，避免整块 parser 等在 asm 中空 `__text`（见 `parser.su` 中 `let_type_refs`）。

---

## 5. 目标 A（driver 调 ld）

`-backend asm` 且 `-o` 指向**可执行文件名**（非 `.o`/`.obj`/`.s`）时，由 **C runtime** 内 `driver_asm_invoke_ld` / `invoke_ld` 调用系统 **ld**（macOS 上 Mach-O 路径含 `-lSystem` 等）。详见 [runtime.c](../src/runtime.c) 中 `output_want_exe`、`driver_asm_invoke_ld` 注释。本地烟测见仓库根目录 [tests/run-asm.sh](../../tests/run-asm.sh)（约第 103 行起：`-o <exe>` 自动 ld）。

**macOS 特别注意**：裸 `ld … -lSystem` 依赖 Xcode Command Line Tools / SDK（`Library/Developer/CommandLineTools` 或 Xcode.app）。若报错 `library 'System' not found`，请先安装 CLT（`xcode-select --install`）或仅用烟测脚本校验 `-backend asm` 出 `.s`/`.o`（不强求 `-o <exe>` 自动链接）。亦可尝试由脚本中的 `clang -o exe file.o` 回退路径链接。

---

## 6. 目标 C（freestanding / 弱化 libc）

- **入口**：Linux x86_64 使用 [src/asm/crt0_x86_64.s](../src/asm/crt0_x86_64.s) 替代 `main` C 桩。
- **Panic**：`runtime_panic_x86_64.s`（syscall exit）或各平台 `runtime_panic.c` / `runtime_panic_arm64.c`。
- **后续**：自有 syscall 封装、std 与 core 拆分见项目宗旨与 [src/asm/README.md](../src/asm/README.md)。

---

## 7. 与 `build_shu_asm.sh` 的对应关系

1. 编译：`asm_build_list.su` 中 `// BUILD:` 顺序 `-backend asm -o build_asm/*.o`。
2. **Linux**：优先 **crt0** 链接；成功即 **B-partial**（无 `pipeline_gen` 参与该次链接）。
3. **否则**：`pipeline_su` 拓扑（`-E` + `cc -c` gen_driver + seed + `runtime_driver`）。
4. 脚本结束时会根据是否走 crt0 / gen_driver 打印 **目标 B** 语义说明，便于日志与 CI 审计。
