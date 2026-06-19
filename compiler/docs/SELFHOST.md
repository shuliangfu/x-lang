# Shux 自举与「完全自举」约定

> **新人 1 小时全景**：[`analysis/doc-selfhost-architecture-v1.md`](../../analysis/doc-selfhost-architecture-v1.md)（DOC-002）  
> 本文档固定**验收命令**、**目标分层（A/B/C）**与**当前链接拓扑**，避免口头「自举」与实现漂移。更细的 asm 能力表见 [src/asm/README.md](../src/asm/README.md) §十一。

---

## 1. 三层目标（与 README 对齐）

| 代号 | 含义 | 「完成」判据（摘要） |
|------|------|---------------------|
| **A** | 用户用 `shux` 编译 `.sx` 为产物时**尽量不调用 cc 做编译** | `shux -backend asm -o x.o` 不生成 C；若 `-o` 为可执行名，driver 调 **ld/clang 仅链接**（见 `runtime.c` 中 `driver_asm_invoke_ld` / `invoke_ld`）。 |
| **B** | **构建编译器可执行文件**时不再依赖 **cc 编译 `pipeline_gen.c` 等大段 -E 产物** | 链接 `shux` / `shux_asm` 的命令行中**不出现**对 `pipeline_gen.c` 的 `cc -c`（允许保留 **cc 作链接器**、以及极小 C 桩如 `runtime_panic`）。 |
| **C** | 生成程序 / 构建链弱化 **libc**（freestanding） | Linux：`runtime_panic_x86_64.s`、`crt0_x86_64.s` 等；与 std 分层长期相关。 |

**「完全自举」**在仓库内建议默认指：**语义自举（shux 用 .sx 前端编自己）+ 目标 B 在目标平台上成立**。是否包含 C 冷启动种子不在此否定（仍允许 `shux-c` / `bootstrap.sh`）。

---

## 2. 固定验收命令（CI / 本地）

在 `compiler` 目录下：

| 目的 | 命令 |
|------|------|
| **语义自举 + 两代一致性** | `make bootstrap-verify`（或 `make bootstrap-self` 烟测） |
| **Stage2 SU（shux-sx → shux-sx2，-sx -E 全模块）** | `make verify-selfhost-stage2` / `verify-selfhost-stage2.sh`（须 `shux-sx`；CI `selfhost-stage2.yml` job `stage2`） |
| **Stage2 B-strict（shux_asm → shux_asm2）** | `make bootstrap-verify-stage2-bstrict` / `verify-selfhost-stage2-bstrict.sh`（二遍 `build_shux_asm`；CI job `stage2-bstrict`） |
| **Stage2 SHA256 金标准（A-09）** | `./tests/run-stage2-hash-gate.sh compiler/shux_asm_stage1 compiler/shux_asm2`（默认 track-only；`SHUX_STAGE2_HASH_STRICT=1` 硬失败） |
| **Windows B-hybrid shux_asm（A-08）** | `./tests/run-bootstrap-bstrict-windows-gate.sh`（MSYS2；`make bootstrap-driver-hybrid` + return-value 42） |
| **仅重编 SU 三件套 .o** | `make gen-su-driver-objs`（`pipeline_sx.o` + `driver_su.o` + `preprocess_su.o`；改 parser/main/preprocess 后 `make shux-sx` 会自动触发） |
| **全量 .sx 测试** | `make test_sx` |
| **C 前端回归** | `make test_c` |
| **asm 构建脚本（Goal 2）** | `SHUX=./shux ./scripts/build_shux_asm.sh`；成功应产出 `shux_asm`（或 Linux crt0 路径下等价信息） |
| **asm smoke（可选 CI job）** | 仓库根：`SHUX_CI_FORCE_ASM=1 ./tests/run-asm.sh`（workflow 中该 job 会先 `make bootstrap-driver`）；见 `.github/workflows/ci.yml` 之 `linux-asm-smoke` |
| **asm .o 段质量（非阻塞默认可选）** | `SHUX=./shux ./scripts/check_asm_o_quality.sh`；严格失败：`SHUX_ASM_QUALITY_STRICT=1 SHUX=./shux ./scripts/check_asm_o_quality.sh`；缺口列表见 `build_asm/.asm_empty_text_list` |
| **P0 push 前（bstrict 107 + perf P1）** | 仓库根：`SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh`（= `run-bootstrap-bstrict-ci.sh` + `run-perf-p1-gate.sh`） |
| **asm 计算门禁** | `run-asm-73-gate.sh`（8× binop + vector-var + call-inline **11 例**）；`make refresh-shux-asm-gate` 对齐 strict `shux_asm`；`run-bootstrap-bstrict-ci.sh` / `run-pre-push-p0.sh` |
| **asm 7.3 寄存器/spill/φ** | `run-asm-binop-block-var.sh`（x10–**x15**）+ `run-asm-binop-cfg-merge.sh`（if/while/for/嵌套/φ）；见 `compiler/src/asm/README.md` |

`./build_tool ./shux` / `./build_tool ./shux asm` 的行为见根目录 [build.sx](../../build.sx) 与 [build_runtime.c](../src/build_runtime.c)（`build_run_asm_build` 调用 `scripts/build_shux_asm.sh`）。

---

## 3. 目标 B 的「Done」定义（可勾选）

- **B-strict（强）**：`./build_tool ./shux asm` 或 `build_shux_asm.sh` 成功产出的 `shux_asm` / `./shux`，其链接输入中**不得**包含由 `cc -c pipeline_gen.c` 得到的 `pipeline_sx.o`（以及同类的 `driver_gen.c` 大 TU），且 `shux` 仍能通过 `make test_sx` 或约定子集。
- **B-partial（当前 Linux 可达）**：使用 **crt0 + `build_asm/*.o` + runtime_panic** 路径链出 `shux_asm` 时，**未**执行 `cc -c pipeline_gen.c`。脚本成功时会打印说明（见 `build_shux_asm.sh`）。
- **B-hybrid（默认 macOS / 回退）**：拓扑 **`pipeline_sx`**（见 §4）：用 `shux-c -E` 生成 `pipeline_gen.c` / `driver_gen.c` 等再 `cc -c` 链入——**不满足 B-strict**，但保证可工作的 `shux_asm`，直至各模块 `-backend asm -o` 的 `__text` 非空且链接拓扑切换为 **`full_asm`**。

验收时写明采用 **B-strict / B-partial / B-hybrid** 之一。

### 3.1 去掉 `cc -c pipeline_gen.c`（drop-cc）的前置条件

- **当前**：非 Linux 或未导出拓扑时等价 **`pipeline_sx`**；Linux 且 `check_asm_o_quality.sh` 认定全部 `__text` 非空时，脚本**自动打上** `full_asm` 拓扑标签（§4）；**driver 回退分支仍可能执行** `ensure_asm_gen_driver_su_objs`（`shux-c -E` + `cc -c`），直至 **`full_asm` 单一链接线**（如 `SHUX_ASM_EXPERIMENTAL_SKIP_GEN`）落地并默认跳过 gen_driver。
- **已满足部分**：Linux **crt0** 路径成功时，本次 `shux_asm` **未**使用 `pipeline_gen.c`（**B-partial**）。
- **M7 默认**：`make bootstrap-driver` / `make bootstrap-driver-bstrict` / `./build_tool ./shux`（asm 路径）均设置 **`SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1`**，产出 `shux_asm` 并覆盖 `compiler/shux`；仅冷启动与语义自举仍依赖 **`make bootstrap-driver-seed`**（`shux-sx` 为 seed 副本）。B-hybrid 回退：`make bootstrap-driver-hybrid`。

---

## 4. 链接拓扑（单一真相）

环境变量 **`SHUX_ASM_LINK_TOPOLOGY`**（`build_shux_asm.sh` 识别）：

| 值 | 含义 |
|----|------|
| **`pipeline_sx`**（__text 未全绿 / B-hybrid 回退） | `-E` 生成 `pipeline_sx.o`、`driver_su.o`、LSP/preprocess 等 **gen_driver**，与 **C seed** 及 **runtime_driver** 链接；**不**把 `build_asm/*.o` 并入（避免重复符号）。非 Linux 且未设 `SKIP_GEN` 时走此路径。 |
| **`full_asm`**（Linux/macOS 自动选择） | 当 **`SHUX_ASM_LINK_TOPOLOGY` 未导出**且 `check_asm_o_quality.sh` 写出 **`1`**（全部 `BUILD` 对应 `.o` 的 **`__text` 非空**）时自动设为 **`full_asm`**。配合 **`SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1`**（`make bootstrap-driver-bstrict` 默认）→ **`asm_only_strict`** 最终链，**无** `pipeline_sx.o` / `cc -c pipeline_gen.c`（M11 macOS 生产 B-strict）。 |

**宿主策略（摘要）**：

- **Linux x86_64（非 Alpine）**：优先 **crt0** 链 `shux_asm`（可达 **B-partial**，无 `pipeline_gen.c`）。
- **macOS / Windows / Alpine 等**：**M7/M11 默认** `make bootstrap-driver-bstrict` → **`full_asm` + `asm_only_strict`**（__text 全绿时）；B-hybrid 回退：`make bootstrap-driver-hybrid` 或无 `SKIP_GEN` 的 `build_shux_asm.sh`。

### 4.1 空 `__text` 清单（逐项修 emitter / typeck / import）

- 跑完 `scripts/build_shux_asm.sh` 或单独 `scripts/check_asm_o_quality.sh` 后查看：
  - `compiler/build_asm/.asm_text_quality`：`1` = 全非空，`0` = 存在缺失或空段。
  - `compiler/build_asm/.asm_empty_text_list`：**一行一条**，形如 `MISSING foo.o`、`EMPTY foo.o`。按文件名对应 `asm_build_list.sx` 的 `// BUILD:` 源 `.sx`，在 **解析/类型/asm 后端**侧消除「仅占位无代码」的编译结果。
  - **质检脚本**对 **Mach-O** 读段名 `__text`，对 **ELF（Linux）** 读 `.text`；若仅在 Linux 上曾出现「24 条全 EMPTY」而 macOS 仅少数条，多半是段名误判而非 asm 未落码——以 `check_asm_o_quality.sh` 实现为准。
- 近期已修：`let` 带显式数组类型时令 `LetDecl.type_ref`/索引赋值可走通 typeck，避免整块 parser 等在 asm 中空 `__text`（见 `parser.sx` 中 `let_type_refs`）。
- **macOS arm64 实测（2026-05）**：`check_asm_o_quality.sh` → **24/24** 非空；`make bootstrap-driver-bstrict` → **`LINK_MODE=asm_only_strict`** + **`full_asm`**（M11），最终链无 `pipeline_gen.c`。B-hybrid 仅作 `bootstrap-driver-hybrid` 回退。
- **实验链 `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1`**（2026-05-23 起演进）：Darwin 上 **两阶段**——① **bootstrap 首遍**链 `pipeline_sx.o`（`-E-extern` 瘦 TU）+ `parser_sx.o`/`typeck_su.o`/`codegen_su.o`/`lexer_su.o` + `seed_host/asm_backend_partial.o` + C seed（**不**并 `build_asm/*.o`，避免 `__shux_asm_mod_stub` 重复）；② **第二遍**用 bootstrap `shux_asm` 重编 `pipeline.o`/`typeck.o`/`parser.o`/`backend.o`，再 **strict 重链**（`run_bootstrap_trampoline` + `strict_core partial`，**无** `pipeline_sx.o`）。验收：`SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 ./scripts/build_shux_asm.sh` → `LINK_MODE=asm_only_strict` + `run_shux_asm_smoke.sh`。
- **B-strict 下一跳**：**pipeline.sx** 第二遍 ✅；**typeck/backend** EMIT_HEAVY 第二遍 ✅；**parser**（2026-06-10）：`driver_run_asm_backend` 首遍 parse 保留 module（勿 memset 后 strict 重 parse）；**305 func** 进 module（`run-parser-parse-count-gate.sh` MIN=150）；`build_asm/parser.o` 第二遍 __text 93B/4509B（EMIT_HEAVY）；真 parse 机码仍在 **`parser_sx.o`** tail。
- **dep 预跑 lib_root 回归（2026-05-22）**：`runtime_one_ctx_for_dep_prerun` 曾调用 `ast_pipeline_dep_ctx_reset` 抹掉 `pipeline_fill_ctx_path_buffers` 写入的 lib_root sidecar，导致 dep 预跑 `resolve_path_su` **rc=-7**、多数 `build_asm/*.o` EMPTY；已改为仅 `ast_pipeline_dep_ctx_set_ndep(0)` 且先 reset 再 fill。
- **Darwin asm-only 链剩余阻塞（2026-05-21 实测）**：
  1. **大模块 parse 截断**：如 `typeck.sx` 解析后 `module.num_funcs=47`（约从 `check_expr_impl` 起后续函数未入 module），`.o` 缺 `typeck_su_ast` 等导出符号。
  2. **跨模块符号名**：`backend.o` 引用 `arch_arm64_*`，而 `arm64.o` 导出 `_arch_arm64_*` 或 `append_byte` 等待定。
  3. Linux 仍可在上述问题解决后试全量 `build_asm/*.o` 实验链；成功时打印 `Target-B-experimental`。**B-partial（crt0）** 仅在 **Linux** 且 crt0 链接成功时成立。
- **bootstrap shux 双轨（2026-05-22）**：`parser.sx` stmt_order 用 `out.num_lets`；`codegen.sx` 发射 break/continue；`typeck.sx` 循环外 break/continue + `PipelineDepCtx.typeck_loop_depth`（C 镜像须同步 `lsp_diag_pipeline_sizes.c` 等）；`collect_deps_transitive` 在 `pr_ok!=0` 时仍展开 `num_imports>0` 的子 dep（修复 hello/import("std.io") `n_deps=1`）。验收：`run-while`/`run-check`/`run-all-c`/`run-all-sx` 全绿；**bootstrap `shux`（driver 链）** 对多 dep std.io 的 codegen preamble 仍与 `shu_su` 有差异，待 10.4.2 收窄 runtime。

### 4.2 run-all 自举层级（L3 / L4 / L5）

| 层级 | 命令 | 含义 |
|------|------|------|
| **L3** | `SHUX=./compiler/shux-c ./tests/run-all.sh` | C 前端发布基线 |
| **L4** | `SHUX=./compiler/shux SHUX_RUN_ALL_BOOTSTRAP_SHUX=1 ./tests/run-all.sh` | M1：seed 做 check/typeck/smoke，多数 `-o` 经 `SHUX_LINK_SHUX=shux-c` |
| **L5** | 同上，但 `run_shu_for_script` 白名单外脚本也用 seed | 真 parity：缩小白名单；已用 seed 链路的子集含 `run-multi-file`、`run-multi-func`、`run-toplevel-let`、`run-let-const` 等 |

**L5 相关实现（2026-05）**：`user_asm_seed_bridge.c` 在 `asm_codegen_elf_o` 前编入各 dep；`asm_export_func_symbol_name` + `pipeline_module_num_funcs`；用户 `-o` exe 不再对本地 import 强制 `asm_entry_module_only`。**std.io 族**：pipeline/bridge 跳过整库 asm emit；`runtime_asm_io_stubs.o` + `io.o` 链入；ARM64 支持 9+ 参 call（`io_register_buffers_4`）。`SHUX=./compiler/shux ./tests/run-io.sh` 除 `read_ptr.sx` 外已通过。

**`run_shu_for_script` 白名单（bootstrap 下仍用 seed `SHU`，其余 `-o` 用 `SHUX_LINK_SHUX`/`shux-c`）**：

| 仍用 seed | 仍用 shux-c（示例） |
|-----------|-------------------|
| run-lexer/typeck/check/import/stdlib-import | run-io（bootstrap run-all 仍 shux-c；seed 直跑除 read_ptr 外已绿）、run-heap 等 |
| run-std/hello/target/fmt-cmd/test-cmd | run-binary-expr / run-csv：seed 单测与 L4 run-all 均已绿（2026-05-27） |
| run-multi-file/multi-func/toplevel-let/let-const | 待逐类收敛至 L5 |

本地验收（约 70s）：`SHUX=./compiler/shux SHUX_RUN_ALL_BOOTSTRAP_SHUX=1 ./tests/run-all.sh` → `all tests OK`。

### 4.3 平台与 B 目标矩阵（M4）

| 宿主 | 构建目标 | 命令 | 链形态 | 用户态 driver |
|------|----------|------|--------|----------------|
| **Linux x86_64（glibc）** | **B-partial（crt0）** | `make -C compiler bootstrap-driver-crt0` | `crt0` + `build_asm/*.o`，无 `pipeline_gen.c` | 无 `runtime_driver`（烟测 return-value 等子集） |
| **Linux / macOS** | **B-strict（M7 release 默认）** | `make bootstrap-driver`（= `bootstrap-driver-bstrict`） | `asm_only_strict`（`SKIP_GEN`） | 有（import/hello 门禁） |
| **macOS arm64** | **B-strict + full_asm（M11 生产默认）** | `make bootstrap-driver-bstrict` | `asm_only_strict` + `build_asm/pipeline.o` | 有 |
| **Alpine / Windows / 实验** | **B-hybrid** | `make bootstrap-driver-hybrid` 或 `build_shux_asm.sh` 无 SKIP_GEN | `pipeline_sx` + gen_driver | 有 |

分轨脚本：`./tests/run-bootstrap-bstrict-linux.sh`（仅 Linux）、`./tests/run-bootstrap-bstrict-ci.sh`（含 gate + 白名单 + Linux crt0 + stage2 预检）。

### 4.4 CI 与本地验收（Linux / macOS）

| 平台 | CI job | 自举相关步骤 |
|------|--------|----------------|
| **Linux** | `.github/workflows/ci.yml` → `linux` | `test_c`、`test_sx`、`./tests/run-bootstrap-bstrict-ci.sh`（含 M4 crt0 + M5 stage2 预检）、`bootstrap-verify` |
| **macOS** | `ci.yml` → `mac` | 同上（`run-bootstrap-bstrict-linux` 自动 skip） |
| **可选** | `selfhost-stage2.yml` | `verify-selfhost-stage2.sh`（shux-sx）+ `verify-selfhost-stage2-bstrict.sh`（shux_asm→shux_asm2） |

本地与 CI 对齐：`make -C compiler test` 或 `./tests/run-bootstrap-bstrict-ci.sh`。

---

## 5. 目标 A（driver 调 ld）

`-backend asm` 且 `-o` 指向**可执行文件名**（非 `.o`/`.obj`/`.s`）时，由 **C runtime** 内 `driver_asm_invoke_ld` / `invoke_ld` 调用系统 **ld**（macOS 上 Mach-O 路径含 `-lSystem` 等）。详见 [runtime.c](../src/runtime.c) 中 `output_want_exe`、`driver_asm_invoke_ld` 注释。本地烟测见仓库根目录 [tests/run-asm.sh](../../tests/run-asm.sh)（约第 103 行起：`-o <exe>` 自动 ld）。

**macOS 特别注意**：裸 `ld … -lSystem` 依赖 Xcode Command Line Tools / SDK（`Library/Developer/CommandLineTools` 或 Xcode.app）。若报错 `library 'System' not found`，请先安装 CLT（`xcode-select --install`）或仅用烟测脚本校验 `-backend asm` 出 `.s`/`.o`（不强求 `-o <exe>` 自动链接）。亦可尝试由脚本中的 `clang -o exe file.o` 回退路径链接。

---

## 6. 目标 C（freestanding / 弱化 libc）

- **入口**：Linux x86_64 使用 [src/asm/crt0_x86_64.s](../src/asm/crt0_x86_64.s) 替代 `main` C 桩。
- **Panic**：`runtime_panic_x86_64.s`（syscall exit 134，已落地）或各平台 `runtime_panic.c` / `runtime_panic_arm64.c`。
- **freestanding_io_x86_64.s**（S4）：`shux_sys_write(fd,buf,len)` → Linux write(2) syscall；**`-freestanding`** 时按用户 `.o` 未定义符号**按需**链入。
- **用户 freestanding**：`crt0_user_x86_64.s` + **`-freestanding`**；按需链 `freestanding_io.o` / `runtime_panic.o`；`ld -nostdlib -static --gc-sections`。
- **B-BOOT-FS**：`tests/run-perf-coldstart.sh` 在 Linux x86_64 + `shux_asm` 上测 `fs_return42`（最小体积）与 `fs_hello`（syscall write）冷启动与 stripped 体积；CI job `S4 freestanding coldstart`。
- **后续**：自有 syscall 封装、std 与 core 拆分见项目宗旨与 [src/asm/README.md](../src/asm/README.md)。

---

## 7. 与 `build_shux_asm.sh` 的对应关系

1. 编译：`asm_build_list.sx` 中 `// BUILD:` 顺序 `-backend asm -o build_asm/*.o`。
2. **Linux**：优先 **crt0** 链接；成功即 **B-partial**（无 `pipeline_gen` 参与该次链接）。
3. **否则**：`pipeline_sx` 拓扑（`-E` + `cc -c` gen_driver + seed + `runtime_driver`）。
4. 脚本结束时会根据是否走 crt0 / gen_driver 打印 **目标 B** 语义说明，便于日志与 CI 审计。
