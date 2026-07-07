# 用 .x 重写 C 逻辑——分析文档

## 一、目标

- **本目标仅要求 compiler 全部用 .x 实现**；std 有没有使用 C 不用管，只要 compiler 全部用 .x 写出来即可。
- 将编译器驱动与运行时中的 **C 逻辑尽量全部用 .x 重写**。
- **尽量完全避免在 compiler 里使用 C**：仅保留「不得不由 C 承担」的最小部分（如 asm crt0 替代 main 后可为零），后续再分析如何进一步缩小或替代。
- **构建方式完全对标 Zig**：使用 **build.x** 配置编译，由 `shux build` 执行，不再依赖 Makefile；构建逻辑与配置全部用 .x 写在 build.x 中。

本文档梳理：**当前 C 侧做了哪些事**、**哪些可以迁到 .x（含用 std）**、**哪些在可预见的范围内仍必须用 C**，便于后续制定迁移顺序与处理方案。**std 底层是否用 C 实现不在本目标范围内。**

---

## 二、当前 C 侧职责总览

### 2.1 入口与符号

| 文件 | 职责 |
|------|------|
| **main.c** | 仅 `main(argc, argv)` → `main_entry(argc, argv)`。有 main.x 时由 .x 提供 `main_entry`，否则 runtime.c 提供弱符号 `main_entry` 转调 `run_compiler_c`。 |

### 2.2 runtime.c 中的逻辑（按功能分类）

下面列出 **当前 C 实现、且与「用 .x 重写」相关** 的职责，并标注：**可否用 .x+std 替代**、**若必须保留在 C，原因是什么**。

---

## 三、C 逻辑分类：可迁 vs 暂必须保留

### 3.1 可直接用 .x + std 替代（无需 C 实现）

这些逻辑不依赖 OS 或 ABI 细节，用现有 std 即可在 .x 里实现。

| 类别 | C 侧现状 | .x 替代方式 | 说明 |
|------|----------|--------------|------|
| **驱动主流程** | `run_compiler_c` / `run_compiler_x_path`：解析 argv、resolve 依赖、读文件、调 pipeline、写 .c、调 cc、链接 | 在 **main.x**（或独立 driver 模块）用 std.fs / std.io / std.process 实现：读入口与依赖、调 parser/typeck/codegen/pipeline、写生成 C、spawn cc/ld | 驱动逻辑纯编排，不依赖 C 专有知识 |
| **resolve 路径** | `resolve_import_file_path_multi`、`import_path_to_file_path`、`get_entry_dir` | .x 内用 path/string + std.fs 存在性检查实现 | 纯路径与字符串处理 |
| **依赖加载与去重** | `find_loaded_index`、`load_one_import`、`resolve_and_load_imports`（含递归 load + typeck） | .x 内维护 `all_dep_mods` / `all_dep_paths`，用现有 typeck/pipeline 接口 | 当前 C 侧只是分配 buffer、调 parse/typeck，均可改为 .x 分配与调用 |
| **预处理** | `preprocess`、`preprocess_via_sx` | 已有 preprocess.x 时用 .x；条件编译符号由 .x 维护 | 仅入口与缓冲在 C，可迁到 .x |
| **读文件** | `read_file(path, out_len)`（打开、读入、malloc 缓冲） | **std.fs** 读文件（或 std.io 按需） | 驱动层不再需要 C 的 read_file |
| **Pipeline 编排** | 分配 arena/module、填充 ctx、调用 `pipeline_run_x_pipeline`、写 out_buf 到文件、再调 cc/ld | .x 内分配 arena/module/ctx，调 pipeline（.x 实现），用 std.fs 写文件、std.process spawn cc/ld | 编排与 I/O 均可在 .x 完成 |

结论：**驱动主流程、resolve、依赖加载、读文件、写文件、调 cc/ld** 都可以在 .x 里用 std 完成，**不需要在 C 里保留对应逻辑**。

---

### 3.2 与「.x 与 C 共享结构体」相关的部分（迁移后可消除）

| 类别 | C 侧现状 | 为何仍涉及 C | 用 .x 重写后的目标 |
|------|----------|--------------|----------------------|
| **PipelineDepCtx 布局** | runtime.c 中 `struct ast_PipelineDepCtx` 与 ast.x 的 `PipelineDepCtx` **逐字段对齐**；C 分配 pctx 并传给 `pipeline_run_x_pipeline` | 当前由 C 分配 ctx、填充部分字段（如 dep_modules、dep_paths）、再传指针给 .x | **ctx 完全在 .x 内分配与填充**；C 不再分配、不再声明该结构体，**不再需要与 .x 保持布局一致** |
| **codegen_set_dep_slots_for_sx_pipeline** 等 | C 把 dep_modules/dep_paths 写入全局槽或 pctx，供 .x codegen 使用 | 因当前「谁分配 ctx、谁填 dep」在 C | 驱动在 .x 后，ctx 与 dep 信息全部在 .x 内维护，**不再需要 C 提供的 dep 槽** |

结论：**一旦驱动与 pipeline 调用全在 .x，ctx 由 .x 分配，C 不再需要 PipelineDepCtx 的拷贝，也不再需要填 dep 槽**。这是「用 .x 重写 C 逻辑」带来的直接收益。

---

### 3.3 必须由 C（或系统层）提供的部分

以下在可预见范围内仍会依赖 C（或需要 C/asm 的一层薄封装），**不是业务逻辑，而是与 OS/工具链/ABI 的边界**。

| 类别 | C 侧现状 | 为何难以完全去掉 C | 后续可考虑的方案 |
|------|----------|---------------------|------------------|
| **程序入口 main()** | main.c 中 `main(argc, argv)` 调 `main_entry` | 操作系统/ABI 规定可执行文件入口为 `_start`，通常由 C 运行时 crt0 提供并再调 main | **方案 A**：保留 C 的 main → main_entry（数行）。**方案 B**：用**我们写的汇编 crt0** 直接出机器码，链接时以我们的 crt0 为 `_start`，在 asm 里按 ABI 取 argc/argv 后直接调 `main_entry`，**完全不必使用 C** |
| **调用外部 cc/ld** | `invoke_cc`、`invoke_ld`：fork/exec 或 posix_spawn，传 argv，等退出码 | 进程创建与执行是 OS API（libc 或 syscall），.x 需通过某种 FFI 调用 | **方案 A**：.x 用 **std.process**（当前底层为 C：process.c）spawn 子进程；**不再在 runtime.c 里实现 invoke_cc/invoke_ld**，驱动在 .x 里用 std.process 调 cc/ld。**方案 B**：若 std.process 尚未满足需求，可暂时保留 C 的 invoke_cc/invoke_ld，由 .x extern 调用，仍算「最小 C」 |
| **std 库底层实现** | std/io/io.c、std/fs/fs.c、std/process/process.c 等 | 文件 open/read/write、进程 spawn 等；当前用 C 实现这些 .o | **不在本目标内**：std 有没有使用 C 不用管；只要 compiler 全部用 .x 实现即可。驱动只通过 std 的 .x API 使用，不在 runtime.c 再写一套 I/O/process |
| **根据 argv0 解析 std/*.o 路径** | `get_io_o_path`、`get_std_fs_o_path`、`get_repo_root` 等一长串 get_*_o_path | 用于链接时把 std/io/io.o、std/fs/fs.o 等传给 ld | **用标准库完全去掉 C**：用 std.fs、std.path 实现「根据可执行路径或 cwd 找 std/*.o」；若 std 尚未提供 realpath/getcwd/可执行路径等 API，在 **std** 里补（std 用不用 C 不管），compiler 只调 std 的 .x API，**compiler 侧完全不必用 C** |
| **Pipeline 对 C 的 extern 调用** | pipeline.x 中：`driver_dep_arena_buf`、`driver_dep_module_buf`、`driver_skip_codegen_dep_0_get`、`driver_set_current_dep_path_for_codegen`、`driver_diagnostic_*` 等 | 当前由 C 分配 dep 槽、设置 skip/当前路径、打诊断 | **驱动迁到 .x 后**：dep 槽、当前路径、skip 等由 .x 状态管理，**pipeline 不再 extern 这些**，或改为调用 .x 内函数 |
| **Codegen 对 C 的 extern 调用** | codegen.x 中：`driver_get_current_dep_prefix_for_codegen`、`driver_current_dep_path_is_std_io_core`、`codegen_sx_import_path_to_c_prefix`、`codegen_sx_path_is_std_io_core`、`codegen_sx_use_buf_wrapper` 等 | 当前由 C 提供「当前 dep 路径→C 前缀」、io core 判断等 | **驱动与 ctx 在 .x 后**：前缀与路径从 ctx 或 .x 内状态读取，**codegen 不再依赖 C 的 driver_* / codegen_sx_*** |
| **类型检查对 C 的 extern** | typeck.x 中：`typeck_float64_bits_lo/hi`（若仍有） | 若 f64 位拆分为 C 实现 | 可保留为极少 C 函数，或日后用 .x+extern 调 libc/编译器内置 |

---

### 3.4 LSP：可用标准库在 .x 里完全去掉 C

| 类别 | C 侧现状 | 用 .x + 标准库替代 |
|------|----------|----------------------|
| **LSP** | lsp_io.c（stdin/stdout 读写、JSON 提取、响应拼接）、lsp_diag.c（诊断、definition/references/hover，调 C parser/typeck）、lsp_wrapper.c | **能。** 用 **std.io** 做 stdin/stdout 与按 Content-Length 读 LSP 消息；用 std 或 .x 内实现做 JSON 解析/拼接（提取 text、position、uri，拼 response）；用现有 **.x 的 parser/typeck** 做诊断、definition、references、hover（不再调 C parser）；用 std.mem 或 .x 内分配做 body 缓冲。**LSP 可全部用标准库在 .x 里实现，不写 C。** |

### 3.5 仅与「C 前端」共存的逻辑（可选保留）

| 类别 | 说明 |
|------|------|
| **run_compiler_c** | 纯 C 前端：C 的 parser/typeck/codegen，无 .x pipeline。用于 bootstrap 或非自举构建。 |
| **parse()、typeck_module、codegen_* 等 C 接口** | 被 run_compiler_c 使用。若项目长期保留「C 前端」构建，则保留；若目标为「仅 .x 前端」，可逐步删。LSP 改用 .x parser/typeck 后不再依赖这些 C 接口。 |

这部分**不阻碍「用 .x 重写驱动」**：重写后，默认路径是 .x 驱动 + .x pipeline；C 前端可作为可选路径或逐步废弃。

---

## 四、必须保留在 C 的清单（最小集）

在「驱动与 pipeline 编排全部迁到 .x、ctx 在 .x 分配、用 std 做 I/O 与进程」的前提下，**理论上仍需 C（或 asm）的最小集合**如下。

1. **程序入口**（二选一即可，不必同时用 C）
   - **选项 A**：`main(int argc, char **argv)`（main.c）：保留数行调 `main_entry`。
   - **选项 B**：用**我们写的汇编 crt0** 直接出机器码，作为可执行文件的 `_start`，按 ABI 取 argc/argv 后跳转 `main_entry`，则**完全不必保留 main.c**。

2. **std 库的底层实现**（与本目标无关）
   - std/io/io.c、std/fs/fs.c、std/process/process.c 等：封装 open/read/write/spawn 等 OS 接口。  
   - **std 有没有使用 C 不用管**；本目标只要求 compiler 全部用 .x 实现。驱动只通过 std 的 .x API 使用，不在 runtime.c 再写一套 I/O/process。

3. **路径解析、get_*_o_path**
   - **用标准库完全去掉 C**：用 std.fs、std.path 实现；若 std 暂无 realpath/getcwd/可执行路径等 API，在 std 里补，compiler 只调 std 的 .x API，**compiler 侧完全不必用 C**。

4. **（若保留 C 前端）**
   - C 的 parser/typeck/codegen 与 run_compiler_c：与「用 .x 重写驱动」独立；可后续单独决定是否保留或裁剪。

**不再需要**在 C 中保留的（迁移后）：
- PipelineDepCtx 的 C 结构体定义与分配
- 所有 driver_*、pipeline_*、get_dep_*、resolve_and_load_imports、read_file、invoke_cc、invoke_ld、get_*_o_path 等驱动与编排逻辑
- 上述逻辑全部在 .x 中用 std 与现有 parser/typeck/codegen/pipeline 实现

---

## 五、.x 侧需要补齐或约定的能力

要完全用 .x 重写上述 C 逻辑，.x 侧需满足：

1. **std 可用**
   - std.fs：读/写文件、路径存在性等（当前已有）。
   - std.process：spawn 子进程、传 argv、取退出码（当前已有）。
   - 若需「当前工作目录」「可执行文件所在目录」：std.path 或 std.env 等是否已提供；若无，可先用 1～2 个 C extern 顶住，再在 std 里补。

2. **驱动入口**
   - main.x 的 `main_entry` 成为唯一「总控」：解析 argv、区分 -o / -E、无 -o 时写 stdout 等；所有 resolve、load、pipeline、写 C、调 cc/ld 均在 .x 内完成。

3. **ctx 与 pipeline 的归属**
   - PipelineDepCtx 仅定义在 ast.x；分配与填充全部在 .x（pipeline 或 main.x）。
   - C 不再分配、不再声明 PipelineDepCtx；`pipeline_run_x_pipeline` 的 ctx 参数由 .x 传入（.x 侧分配好的指针）。

4. **codegen / pipeline 对「当前 dep、前缀」的获取**
   - 从 ctx（或 .x 内显式传入的状态）读取，不再通过 C 的 driver_get_current_dep_prefix_for_codegen 等；相应 extern 可删除或改为 .x 内部函数。

---

## 五.1 构建：build.x（对标 Zig build.zig）

**约定：完全按照 Zig 的方式，使用 build.x 配置编译。**

- **入口**：项目根目录（或指定目录）下的 **build.x**，由 `shux build` 执行。
- **职责**：build.x 是一段 .x 源码，在其中用 std.fs、std.process、std.path 等：
  - 声明要编译的 .x 入口与依赖；
  - 调用 shux 将 .x 编译为 C/asm；
  - 调用 cc/ld 链接，产出可执行文件或库；
  - 可选：测试、安装、清理等步骤。
- **不再使用 Makefile**：日常构建统一为 `shux build`；Makefile 逐步弃用，仅 bootstrap 时如需可保留一次性最小脚本。
- **与 Zig 的对应**：Zig 的 `zig build` 执行 `build.zig`，我们用 `shux build` 执行 `build.x`，构建逻辑全部用本语言描述。

---

## 六、后续可做的步骤（建议顺序）

1. **在 main.x 中实现「完整驱动」**  
   用 std.fs / std.process 实现：读入口与 import 文件、resolve 路径、分配 arena/module/ctx、按依赖顺序调 pipeline、写生成 C、spawn cc/ld。  
   - 与 C 的 `run_compiler_x_path` 行为对齐，便于对比测试。

2. **去掉 runtime.c 中的驱动逻辑**  
   删除或条件编译掉：resolve_and_load_imports、read_file（驱动用）、invoke_cc、invoke_ld、get_*_o_path、pctx 分配与填充、对 pipeline_run_x_pipeline 的调用等；保留 main.c 的 main → main_entry。

3. **ctx 改为 .x 分配**  
   pipeline 或 main.x 分配 PipelineDepCtx（或等价缓冲区），调用 pipeline 时传入；删除 runtime.c 中的 `struct ast_PipelineDepCtx` 及所有对其的分配与填充。

4. **清理 pipeline/codegen 对 C driver 的 extern**  
   将 driver_*、codegen_sx_* 中与「当前 dep、前缀、路径」相关的调用改为从 ctx 或 .x 状态读取；删除 C 侧对应实现。

5. **（可选）std 补全**  
   路径解析等已用 std.fs/std.path 在 compiler 侧完全去掉 C；若 std 尚未提供相关 API，在 std 里补即可（std 用不用 C 不管）。

6. **（可选）用 asm crt0 替代 main.c**  
   用我们写的汇编实现 crt0（_start），直接出机器码；按目标平台 ABI 取 argc/argv 后调用 `main_entry`。完成后可删除 main.c，实现**程序入口零 C**。

7. **实现 build.x 与 `shux build`**  
   完全对标 Zig：实现 `shux build`（执行当前目录或指定目录下的 build.x）；在 compiler 或独立工具中解析 build.x，按其中声明的步骤调 shux/cc/ld。项目提供根目录 build.x，用于构建 shux 自身。**实现后即可不再使用 Makefile**：日常构建统一为 `shux build`；仅首次 bootstrap（尚无 shux 可执行文件时）如需可保留一次性最小脚本，之后全部依赖 build.x。

---

## 七、总结表：哪些用 C、哪些用 .x

| 能力 | 当前 | 目标 | 必须用 C？ |
|------|------|------|------------|
| 程序入口 main | C (main.c) | asm crt0 → main_entry | 否（直接使用 asm crt0） |
| 驱动主流程（argv、resolve、load、pipeline、写 C、cc/ld） | C (runtime.c) | .x (main.x + std) | 否 |
| 读/写文件、spawn 进程 | C (read_file, invoke_cc 等) | std.fs / std.process | 否 |
| PipelineDepCtx 分配与填充 | C | .x | 否 |
| dep 槽、当前路径、skip 等 | C (driver_* 等) | .x 状态 / ctx | 否 |
| 路径解析、get_*_o_path | C | .x + std.fs/path（用标准库完全去掉 C） | 否 |
| std 库底层（io/fs/process 的 .c） | C | 不要求；std 用不用 C 不管 | 否（不在本目标内） |
| LSP | C (lsp_io.c, lsp_diag.c 等) | .x + std.io/string（用标准库完全去掉 C） | 否 |
| **构建** | Makefile | **build.x**（对标 Zig build.zig，`shux build` 执行） | 否 |
| C 前端（run_compiler_c） | C | 可选保留或单独裁剪 | 与「compiler 用 .x 重写」无关 |

结论：**本目标仅要求 compiler 全部用 .x 实现；std 有没有使用 C 不用管（std 的 C 是内置的，不用管）。** 程序入口用 asm crt0 可直接避免 C，**可以不用 main.c 入口**；路径解析、get_*_o_path 用标准库即可在 compiler 侧完全去掉 C；**LSP 也能用标准库在 .x 里写，完全不用 C**（std.io + .x parser/typeck + JSON 拼接）；其余 compiler 内 C 逻辑（驱动、ctx、dep、invoke_cc/ld 等）均可迁到 .x。

**构建：完全对标 Zig，使用 build.x 配置编译。** 我们采用与 Zig 一致的方式：**用 build.x 作为唯一构建配置**，由 `shux build` 执行。build.x 是一段 .x 源码，在其中用 std.fs、std.process、std.path 等声明要编译的 .x、依赖关系、调用 shux/cc/ld 的步骤、产物路径等；不再使用 Makefile，日常构建统一为 `shux build`。Bootstrap 时只需「用已有 shux 执行一次 build.x」或一次性最小种子；之后全部依赖 build.x。
