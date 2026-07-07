# 完全自举：不再需要 .c、.h、Makefile 的实现方案

## 目标

- **完全自举**：用 shux 编译自身全部 .x，得到新的 shux，且不依赖任何项目内的 .c/.h。
- **无 C 源码**：仓库中不再包含 .c、.h 文件（或仅保留「一次性」bootstrap 用最小 C，见下文）。
- **无 Makefile**：用 **build.x**（及由它编出的 build_tool）作为唯一构建配置与入口，与 Zig 的 **build.zig** 角色一致；根目录与 compiler 下的 Makefile 均可由「通过 build.x 构建」替代。

---

## 一、能否实现？结论

**能实现**，但需要完成下面几类工作，且要接受一个前提：**至少有一个「种子」shux 从哪里来**。

- **方案 A（推荐）**：仓库里**纳入预编译的 bootstrap shux 二进制**（如 `compiler/bootstrap_shuxc`，按平台放不同目录或单二进制多架构）。之后构建 = 用该二进制 + 纯脚本，不再需要任何 .c/.h/Makefile。
- **方案 B**：保留**唯一一个最小 C 文件 + 一个最小「不用 Makefile」的构建方式**（例如单条 `cc -o bootstrap_shuxc bootstrap.c`），只用于在干净环境里生成**第一个** shux，之后全部用该 shux 编 .x，不再用 C。这样「日常构建」不再需要 .c/.h/Makefile，只有「冷启动」需要一次 C。

下面按**方案 A（完全无 C、无 Makefile）** 来写实现路径。

---

## 二、当前 C 的职责与替代方式

要删掉所有 .c/.h，必须用 **.x + 少量 asm** 完全替代现有 C 提供的符号和入口。

### 2.1 入口与 argv（替代 main.c + runtime_asm_build.c）

| 当前 C | 作用 | 替代方式 |
|--------|------|----------|
| `main()` | 调 `entry(argc, argv)` | 用 **asm 提供 _start**：在 x86_64 Linux 下 `_start` 从栈取 argc/argv，调 `entry`，再 `exit`。不写任何 C。 |
| `driver_get_argv_i(argc, argv, i, buf, max)` | 从 `char** argv` 取第 i 个字符串到 buf | 用 **asm 实现**：根据 ABI 从 argv 指针取 `argv[i]`，拷贝到 buf，返回长度或 -1。 |

- 已有：`main.x` 里 `function entry(argc, argv)`。
- 需要新增：例如 `src/asm/crt0_x86_64.s`（或按平台 `crt0_arm64.s` 等）提供 `_start` 和 `driver_get_argv_i`，链接时用该 .o 替代原来的 main.o / runtime_asm_build.o。

### 2.2 驱动与复杂路径（替代 runtime.c 中部分逻辑）

| 当前 C | 作用 | 替代方式 |
|--------|------|----------|
| `run_compiler_sx_path(argc, argv)` | 处理带 -o、import 等「复杂」命令行路径 | 在 **main.x** 里实现完整驱动：解析 argv、-L、-o、-backend asm、调用 pipeline、写 .o/.s、必要时调 ld。复杂路径不再 fallback 到 C，全部 .x。 |
| `run_compiler_c_impl(argc, argv)` | 全功能 C 编译路径 | 同上：要么在 main.x 里实现等价逻辑，要么在「无 C」构建下改为 **桩**：直接返回 -1，强制所有逻辑走 .x 路径。 |

- 目标：main.x 不再 `extern` 这两个，而是自己实现或桩掉。

### 2.3 Pipeline 与解析（替代 runtime.c 中的 C 桥接）

| 当前 C | 作用 | 替代方式 |
|--------|------|----------|
| `pipeline_parse_into_buf(arena, module, buf, buf_len)` | 把 (buf, len) 组成 slice 后调 parser | 在 **pipeline.x** 里实现：接受 `(arena, module, buf: *u8, buf_len: i32)`，在 .x 内构造与 `u8[]` 兼容的视图（或 parser 增加 `parse_into(..., buf, len)` 重载），调现有 `parse_into`，返回 0/-1。 |

- 这样可删除 C 里的 `pipeline_parse_into_buf`，pipeline.x 不再 `extern` 它。
- **实现要点**：parser 当前只有 `parse_into(arena, module, source: u8[])`，.x 暂无从 `(buf, len)` 构造 `u8[]` 的写法。需在 **parser**（及 lexer 等）中增加 `(data: *u8, len: i32)` 重载链（如 `parse_into_buf`、`lexer_next_buf` 等），再在 pipeline.x 内调用。**当前可暂保留 C 的 pipeline_parse_into_buf**，待上述重载就绪后再切到 .x。

### 2.4 文件 I/O 与 libc

| 当前 C | 作用 | 替代方式 |
|--------|------|----------|
| `read_file`、`resolve_import_*`、`pipeline_fill_ctx_*` 等 | 读文件、解析路径、填充 ctx | 已有 **std.fs**（open/read/write/close 为 `extern`）。无 C 时这些符号由 **链接 libc**（-lc）提供即可，不写 C 源码。 |

- 即：不依赖「项目内的 .c」，但仍可链接系统 libc（-lc），满足「无 .c/.h、无 Makefile」目标。

### 2.5 其余 C（lexer/parser/typeck/codegen/ast/preprocess）

| 当前 | 替代方式 |
|------|----------|
| 这些模块同时存在 .c 与 .x | 构建时**只使用 .x**：用 shux 的 **-backend asm** 把 compiler 下所有 .x（含 lexer、parser、typeck、codegen、ast、preprocess、pipeline、main、asm 子树等）编成 .o，不再编译任何 .c。 |

- 删除 .c/.h 后，这些目录下只保留 .x；唯一「非 .x」是上面说的 asm 启动与 argv 辅助（.s）。

---

## 三、构建系统：如何替代 Makefile

### 3.1 无 Makefile 的构建流程

1. **种子编译器**  
   - 使用预置的 `compiler/bootstrap_shuxc`（或按平台选的二进制）。  
   - 不依赖 Makefile、不依赖任何 .c。

2. **一步：用 bootstrap shux 编出所有 .x 的 .o**  
   - 按依赖顺序对每个模块执行：  
     `./bootstrap_shuxc -backend asm -o build_asm/<module>.o -L .. -L src/... <path>.x`  
   - 模块列表与顺序与当前 `scripts/build_shux_asm.sh` 一致（token → ast → codegen → … → pipeline → main 等）。

3. **二步：链接**  
   - 链接：  
     - asm 提供的 crt0（_start + driver_get_argv_i）  
     - 所有 `build_asm/*.o`  
     - **-lc**（open/read/write/close 等）  
   - 得到新的 shux，无需任何 .o 来自 .c。

### 3.2 用 build.x 替代 Makefile（与 Zig build.zig 对齐）

- **build.x 的角色**：与 Zig 的 **build.zig** 一致——**仅用于配置构建**，用项目语言描述「怎么编、编什么、步骤顺序」，是唯一的构建配置入口，用于代替 Makefile。  
  - Zig：`zig build` 解释/执行 build.zig 中的配置。  
  - Shux：**build.x 只做构建配置**（步骤 ID、顺序、默认/asm 路径）；shux 将其编成 **build_tool**，执行 `./build_tool [shux路径] [asm]` 时按该配置运行；具体命令由 build_runtime 提供，配置与执行分离。

- **根目录 Makefile**：当前仅做 `make -C compiler` 委托，**可以完全由 build.x 替代**：  
  - 约定「构建入口」为：在 compiler 目录下执行 `shux ../build.x -o build_tool && ./build_tool ./shuxc`（或由脚本/文档提供一条等价命令）。  
  - 不再需要根目录 Makefile；需要时也可保留一个极简脚本（如 `./build`）仅负责调用上述命令。

- **compiler/Makefile**：在「完全自举、无 C」方案中，由 **build.x 描述的步骤** 替代（包括编 C、生成 pipeline_gen.c/driver_gen.c、编 .x、链接）；无 C 时则由 **build.x + bootstrap_shuxc** 直接编所有 .x 并链接，不再需要 compiler/Makefile。  
- 因此：**根目录与 compiler 的 Makefile 都可以被「通过 build.x 构建」取代**，build.x 即我们的 build.zig。

### 3.3 为何当前 build_tool 仍依赖 build_runtime.c？如何彻底去掉？

- **当前状态**：build_tool 由「build.x → shux -E → build_gen.c」与 **build_runtime.c** 链接而成。build.x 只提供**配置**（步骤顺序、getter）；**执行逻辑**（main、拼命令、system()、对 pipeline_gen.c/driver_gen.c/preprocess_gen.c 的 patch）全部在 **build_runtime.c** 里。
- **为何还没去掉**：实现步骤第四、五步是「bootstrap_shuxc + build.sh」和「删除 .c/.h、Makefile」；第 5 步暂不执行。把「执行」从 C 迁到 .x 需要先让 build_tool 能单独用 .x 编出来并链 crt0 + libc，再在 .x 里实现 run_step（拼命令、调 system）和 patch（读文件、字符串替换、写回），工作量较大，故先保留 build_runtime.c。
- **要完全摆脱 build_runtime.c 需要**：
  1. **build_tool 不再链任何 .c**：build_tool = build_runner.x（或 build.x 扩展）+ crt0.o + -lc。
  2. **在 .x 中实现**：入口（等价 main）、从 argv 取参数（extern driver_get_argv_i 由 crt0 提供）、每条步骤的**命令串**（可放在 .x 的只读数据或字面量里）、调用 **system()**（extern 链 libc）、以及对 pipeline_gen.c/driver_gen.c/preprocess_gen.c 的 **patch**（读文件 → 字符串替换 → 写回，用 std.fs 或 extern libc 的 fopen/fread/fwrite/fclose）。
  3. 完成后即可删除 build_runtime.c；build.x（或拆成 build_config.x + build_runner.x）即成为唯一构建配置与执行入口，与「完全摆脱 C」目标一致。

---

## 四、实现步骤（建议顺序）

1. ✅ **提供 asm 入口与 argv**  
   - 新增 `src/asm/crt0_x86_64.s`（及可选 arm64/riscv64）：  
     - `_start`：从栈取 argc/argv，调 `entry`，再 `exit`（syscall 或 libc）。  
     - `driver_get_argv_i`：按 ABI 从 argv 取第 i 个字符串写入 buf，返回长度或 -1。  
   - 在链接脚本/构建脚本中，用该 .o 替代原来的 main.o / runtime_asm_build.o。  
   - **已完成**：`crt0_x86_64.s` 已存在，Makefile 已增加 `crt0_x86_64.o` 目标（仅 Linux）；链接 asm 版 shux 时可用该 .o。

2. ✅ **在 pipeline.x 中实现 parse_into 的 buf 包装**  
   - 去掉 `extern function pipeline_parse_into_buf(...)`。  
   - 在 pipeline.x 中实现 `function pipeline_parse_into_buf(arena, module, buf, buf_len)`：在 .x 内构造可供 `parse_into` 使用的 slice（或直接调 parser 的等价接口），返回 0/-1。  
   - 若当前 `parse_into` 只接受 `u8[]` 且 .x 无法从 (ptr, len) 构造，则在 parser 中增加「接受 (buf, len) 的 parse_into 重载」或在 pipeline 里用现有类型拼出 slice。  
   - **已完成**：已去掉 extern，pipeline.x 内实现为调 `parser.parse_into_buf`；parser/lexer 已增加完整 (data, len) 链（parse_into_buf、parse_one_function_buf、lexer_next_buf 等），C 端 `pipeline_parse_into_buf` 已用 `#if 0` 禁用。

3. ✅ **在 main.x 中消除对 C 的 extern**  
   - 实现或桩掉 `run_compiler_sx_path`、`run_compiler_c_impl`（见 2.2）。  
   - 保证 `driver_get_argv_i` 只由 asm 提供，main.x 继续 `extern function driver_get_argv_i(...)`，链接时由 crt0 的 .o 提供。  
   - **已完成**：`run_compiler_sx_path` 在 main.x 内实现为转调 `run_compiler_sx_path_impl`；`run_compiler_c_impl` 在 main.x 内桩为直接返回 1。C 端在 `SHUX_USE_SX_DRIVER` 下不再定义二者，避免重复符号。

4. ✅ **引入 bootstrap shux 与 build.sh**  
   - 在仓库中加入预编译的 **bootstrap_shuxc**（例如 `compiler/bootstrap_shuxc`，或按 `uname -m` 选不同文件）。  
   - 实现 **build.sh**：仅用 bootstrap_shuxc + asm 后端编所有 .x → build_asm/*.o，再链接 crt0 + build_asm/*.o + -lc，产出 shux。  
   - **部分完成**：根目录已实现 `build.sh`（以 build.x 为入口，无 shux 时优先用 `compiler/bootstrap_shuxc`）。**本地生成 bootstrap_shuxc**：在 compiler 目录执行 `./scripts/bootstrap_shuxc_create.sh`（需先有 `./shuxc`），得到 `./bootstrap_shuxc` 后即可用 build.sh 不再依赖 make；预编二进制入库仍可选。

5. **删除 .c、.h、Makefile**（暂不执行，仅作文档保留）  
   - 确认上述构建能稳定产出可用的 shux 后，再删除：  
     - 所有 compiler 下的 .c、.h；  
     - Makefile。  
   - 保留：.x、.s（crt0）、std、脚本、bootstrap_shuxc。  
   - **说明**：为防止日后遇阻，本步先不执行、不删文档；先完成其余未完成项（含 build.x 支持无 C/asm 路径等），再视情况执行本步。

### 脱离对 C 的依赖测试（第 5 步前必做）

- **目标**：在不删除任何 .c 文件的前提下，验证「运行时不依赖 C 逻辑」的路径可用，并确认今后开发不会遇阻；通过后再考虑执行第 5 步删除 .c。
- **做法**：  
  1. **构建**：用 asm 路径产出 `shux_asm`（`./build_tool ./shuxc asm`，即用 .x → asm → .o + 最少 C 桩 `runtime_asm_build.o`/`runtime_driver.o` 链接）。  
  2. **测试**：用 `shux_asm` 跑全量测试：`SHUX=compiler/shuxc_asm ./tests/run-all.sh`。  
  3. **一键脚本**：`./tests/run-without-c.sh` 会先构建 shux_asm，再以 SHUX=shux_asm 执行 run-all.sh；全部通过即视为「脱离 C 依赖测试」通过。  
- **通过标准**：run-all.sh 全部用例通过，且无因「缺 C 路径」导致的失败。  
- **后续**：若测试完全无问题，且分析认为今后开发（新语法、新模块、asm 后端扩展）不会遇阻，再执行第 5 步删除 .c/.h/Makefile；若有失败或风险，先补齐再删。

- **今后开发是否遇阻（简要分析）**：  
  - **asm 后端**：所有参与构建的 .x（parser、typeck、codegen、pipeline、main、asm 子树等）须能被 `-backend asm` 正确编译；新增语法或内建函数需在 asm 后端补齐，否则无 C 构建会失败。  
  - **链接阶段**：当前 asm 构建仍链入 `runtime_asm_build.o` 与 `runtime_driver.o`；若今后改为仅链 crt0 + build_asm/*.o + -lc，需保证无未定义符号（如 typeck 的 float64_bits_lo/hi 等可迁 .x 或小 asm）。  
  - **build_tool**：若进一步去掉 build_runtime.c，需在 .x 中实现命令拼接、system()、patch 逻辑，并保证 build_tool 仍能稳定产出 shux。  
  - 上述均可在「不删 .c」的前提下逐步推进；run-without-c 测试通过是删除 C 的必要条件，非充分条件，需再结合上述分析判断。

---

## 五、风险与前提

- **asm 后端能力**：当前 asm 后端必须能正确编译「所有」参与构建的 .x（parser、typeck、codegen、pipeline、main、asm 子树等）。若有未支持语法，需先在后端补齐，否则无法做到「全部 .x 编成 .o、无 C」。  
- **种子二进制**：方案 A 依赖预置的 bootstrap_shuxc；需为每个目标平台准备一个（或一个多架构包）。方案 B 则保留一次性的最小 C 冷启动。  
- **libc**：完全无 C 源码后，仍会链接 -lc（open/read/write/close 等）；若未来要「连 libc 也不链」，则需在 .x/asm 中实现最小 syscall 封装，并替换 std.fs 的 extern。

---

## 六、简短结论

- **能不能实现？** 能：用 **.x + asm（crt0 + driver_get_argv_i）+ 脚本 + bootstrap shux** 可以做到**完全自举、不再需要 .c、.h、Makefile**。  
- **要怎么实现？** 按第四节顺序：  
  1）asm crt0 与 driver_get_argv_i；  
  2）pipeline.x 实现 pipeline_parse_into_buf；  
  3）main.x 去掉对 run_compiler_* 的 C 依赖；  
  4）引入 bootstrap_shuxc + build.sh；  
  5）验证通过后再删除所有 .c、.h、Makefile。

本文档可作为「完全自举、无 C、无 Makefile」的正式实现路线图，按步骤执行即可逐步达成目标。

---

## 七、现状总览：已完成 vs 未完成

### 7.1 已完成项

| 项目 | 说明 |
|------|------|
| **步骤 1：asm 入口** | `crt0_x86_64.s` 已存在（仅 Linux），提供 `_start` 与 `driver_get_argv_i`；Makefile 有 `crt0_x86_64.o` 目标。 |
| **步骤 2：pipeline parse_into buf** | pipeline.x 内实现为调 `parser.parse_into_buf`；parser/lexer 已有 (data, len) 链；C 端 `pipeline_parse_into_buf` 已 `#if 0`。 |
| **步骤 3：main.x 去 C extern** | `run_compiler_sx_path` / `run_compiler_c_impl` 在 main.x 实现或桩；C 在 `SHUX_USE_SX_DRIVER` 下不定义二者。 |
| **步骤 4（部分）** | `build.sh` 已实现（build_tool + shux；无 shux 时可用 `bootstrap_shuxc`）；**bootstrap_shuxc 二进制尚未纳入仓库**。 |
| **build.x 配置化** | build.x 仅做步骤顺序配置；build_tool 支持默认构建与 `asm` 路径（`./build_tool ./shuxc asm`）。 |
| **脱离 C 依赖测试** | `tests/run-without-c.sh` 已提供：构建 shux_asm 后用其跑 run-all.sh。 |

### 7.2 未完成 / 部分完成项（已实现部分见下）

| 项目 | 说明 | 当前状态 |
|------|------|----------|
| **步骤 4（缺口）** | 预置 bootstrap_shuxc 未入库 | **已提供** `compiler/scripts/bootstrap_shuxc_create.sh`：首次 `make` 或 `build_tool` 后执行该脚本即可生成 `compiler/bootstrap_shuxc`，供 build.sh 无 shux 时使用；预编二进制入库仍可选。 |
| **步骤 5** | 未执行 | 仍保留；按设计测试通过后再删 .c/.h/Makefile。 |
| **asm 链接仍用 C 桩** | 改为 crt0 + build_asm/*.o + -lc | **已实现**：Linux 下 `build_shux_asm.sh` 优先尝试 **crt0_x86_64.o + typeck_f64_bits.o + runtime_panic.o + build_asm/*.o + -lc -lm**，成功则 shux_asm 不再链 runtime_driver.o。**typeck_f64_bits 零 C**：新增 `src/typeck/typeck_f64_bits_x86_64.s`，Linux 下 Makefile 由该 .s 生成 typeck_f64_bits.o，不再用 typeck_f64_bits.c。 |
| **build_tool 仍依赖 C** | 入口与编排迁 .x | **已实现**：根目录 `build_runner.x` 提供 entry；`build_runtime_sx.x` 提供 build_run_step 与三处 patch（pipeline_gen.c / driver_gen.c / preprocess_gen.c），仅链 libc。Linux 下 `make build-tool-sx` 产出 build_tool = crt0 + build_runner.o + build_tool.o + **build_runtime_sx.o**（无 build_runtime.c）。非 Linux 下生成 C 与系统头冲突时仍可用原 build-tool（链 build_runtime.c）。 |
| **脱离 C 测试能否通过** | asm 编全 + 链接成功 | 依赖 asm 后端与 crt0 路径；run-without-c.sh 可验证。 |

### 7.3 是否已实现「完全自举」？

- **若「完全自举」仅指**：用现有 shux 编译自身 .x 得到新的 shux  
  → **已实现**：`./build_tool ./shuxc`（默认 C 展开路径）或 `./build_tool ./shuxc asm`（asm 路径）均可产出新 shux；但**仍依赖**由 C 编出的「当前 shux」和（默认路径下）C 生成的 pipeline_gen.c/driver_gen.c 等。

- **若「完全自举」指**：**不再使用任何项目内 .c**（无 C 源码、无 C 编译、无 C 链接）  
  → **尚未实现**。当前进展与缺口：  
  1）**bootstrap_shuxc**：脚本已提供，入库或等效「种子」仍可选。  
  2）**asm 链接无 C**：Linux 已实现 crt0 + typeck_f64_bits（.s）+ runtime_panic（.s 或 .c）+ build_asm/*.o + -lc -lm；若 runtime_panic 也用 .s 则 asm 路径可零 C。  
  3）**build_tool 无 C**：已迁入 `build_runtime_sx.x`（run_step + 三处 patch + driver 的 run_compiler_c 追加），Linux 下 `make build-tool-sx` 仅链 crt0 + .x 生成 .o + -lc。  
  4）**第 5 步**：在测试与分析通过后删除 .c/.h/Makefile。

### 7.4 建议后续顺序

1. **跑通脱离 C 依赖测试**：修齐 asm 后端与链接，使 `./tests/run-without-c.sh` 全绿。  
2. ~~**（可选）asm 链接改用 crt0**~~：**已做**——build_shux_asm.sh 在 Linux 下优先用 crt0 + typeck_f64_bits.o（来自 typeck_f64_bits_x86_64.s）+ runtime_panic.o；typeck 符号已零 C。  
3. **（可选）bootstrap_shuxc 入库**：本地已可用 `compiler/scripts/bootstrap_shuxc_create.sh` 生成；为发行/CI 可纳入预编二进制。  
4. **在测试与风险分析通过后执行第 5 步**：删除 .c/.h/Makefile。  
5. **build_tool 完全无 C**：将 build_run_step 与 patch 逻辑迁入 .x（见 §7.5），仅链 crt0 + libc。

### 7.5 实现「完全自举、不依赖 C 的一切」：步骤与检查清单

**目标**：构建与自举过程不再使用项目内任何 .c（无 C 源码、无 C 编译、无 C 链接）。

**已完成**

| 项 | 说明 |
|----|------|
| bootstrap_shuxc | `compiler/scripts/bootstrap_shuxc_create.sh` 可在首次 make/build_tool 后生成 `compiler/bootstrap_shuxc`，供 build.sh 无 shux 时使用。 |
| asm 链接（Linux） | crt0_x86_64.o + **typeck_f64_bits_x86_64.s → typeck_f64_bits.o** + runtime_panic.o + build_asm/*.o + -lc -lm；typeck 双精度位取已零 C。 |
| build_tool 入口 | `build_runner.x` 提供 `entry(argc, argv)`，由 crt0 调用；argv[2]=asm 时调 build_run_asm_build，否则按步骤调 build_run_step（仍由 C 提供）。 |

**待完成（实现完全无 C 的必做项）**

| 顺序 | 项 | 说明 |
|------|----|------|
| 1 | **runtime_panic 零 C（可选）** | Linux 下已有 `src/asm/runtime_panic_x86_64.s` 时，asm 链接即不再依赖 runtime_panic.c；若无 .s 需补写并让 Makefile 在 Linux 下用 .s 生成 runtime_panic.o。 |
| 2 | **build_tool 完全无 C** | **已实现**：`build_runtime_sx.x` 含字面量（分支内 let）、run_step（拼命令 + system）、三处 patch（fopen/fread/fwrite/strstr/替换循环）。链接为 crt0 + build_runner.o + build_tool.o + build_runtime_sx.o + -lc。仅 Linux 下 `make build-tool-sx` 使用；生成 C 与系统头类型一致时可在其他平台启用。 |
| 3 | **bootstrap_shuxc 入库（可选）** | 将预编 bootstrap_shuxc 纳入仓库或发布包，使新 clone 无需先有 C 编出的 shux。 |
| 4 | **第 5 步：删 .c/.h/Makefile** | 在 run-without-c.sh 及自举测试通过、且 build_tool 无 C 后，删除项目内 .c/.h 与 Makefile，仅保留 .x + asm(.s) + 脚本。 |

**检查清单（完全无 C 达成时）**

- [ ] `./tests/run-without-c.sh` 全绿（asm 编全 + 链接成功，用 shux_asm 跑测试）。  
- [ ] build_tool 仅由 crt0 + .x 生成 .o + -lc 链接，不链任何 .c 生成 .o。  
- [ ] 构建 shux_asm 时不再链接 runtime_driver.o / typeck_f64_bits.c；Linux 下 typeck_f64_bits 来自 .s。  
- [ ] 仓库或 CI 具备「无 C 种子」：bootstrap_shuxc 或等效，使从零可构建出 shux。

### 7.6 完善情况与已知缺口

**已与 C 端对齐的项**

| 项 | 说明 |
|----|------|
| build_runner.x | entry、asm 路径纯 .x（SHUX=path + system）、默认路径调 build_run_step。 |
| build_runtime_sx.x | 字面量（分支内 let）、run_step 0～6、preprocess_gen.c 两处替换、driver_gen.c 五处替换 + **run_compiler_c 包装追加**、pipeline_gen.c 重命名 _impl / parser 签名 / slice .→-> 等替换。 |
| typeck_f64_bits | Linux 下用 typeck_f64_bits_x86_64.s，不再用 .c。 |
| Makefile | Linux 下 build-tool-sx 只链 build_runtime_sx.o，不链 build_runtime.c。 |

**尚未与 C 端完全一致的项（可选/按需补）**

| 项 | C 端行为 | 当前 .x 行为 |
|----|----------|----------------|
| pipeline_gen.c 追加块 | 若缺 source_data/source_len 则追加 (data,len,ctx) 包装；若缺 pipeline_sizeof_arena 则追加 size getters；若缺 pipeline_debug_module_funcs 则追加 debug 函数；若缺 parser_parse_into 的 extern 则插入。 | 仅做「必要替换」：重命名 _impl、parser 签名、slice .→->，**未**做上述「若缺则追加」。若 -E 生成的 pipeline_gen.c 已含这些块则无影响；否则可能需仍用 C 端 patch 或后续在 .x 中补同样逻辑。 |
| 非 Linux 平台 | build-tool 可链 build_runtime.c 正常编。 | build-tool-sx 仅 Linux；在 macOS 等编 build_runtime_sx_gen.c 会与系统头（FILE* / const char*）冲突，需适配代码生成或编译选项后再启用。 |

**结论**：日常 Linux 下「build_tool 完全无 C」路径已可用；driver 的 run_compiler_c 已补全。pipeline 的「若缺则追加」与跨平台生成 C 的兼容为可选完善项。
