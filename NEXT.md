# Shulang 下一步开发清单

> 根目录清单：按顺序推进，每完成一项将 ⬜ 改为 ✅ 并保存。详细背景见 `analysis/下一步开发分析.md`、`analysis/接下来做什么-性能压榨与新std.md`。

---

## 一、高优先级

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | 修 -su -E 平台差异（Linux/Windows/Debian 上 -su -E 只出 "0" 的问题） | runtime.c：-su -E 时 setvbuf(stdout, _IONBF) 避免缓冲截断；全平台通过需结合 CI 日志再查 |
| ✅ | 提交 import 两种方式测试（const_binding / const_select + run-import.sh） | 已提交并纳入 CI，run-import 覆盖三种 import |

---

## 二、标准库（新 std，小步快跑）

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | std.time：最小 API（单调时间、墙上时钟、sleep_ms） | 已有 mod.su、time.c、README、run-time.sh，按需链接 |
| ✅ | std.random：最小 API（fill_bytes、u32） | 已有 mod.su、random.c、README、run-random.sh，按需链接 |
| ✅ | std.env（或扩 std.process）：getenv 等独立/扩展 | 已有 mod.su、env.c、README、run-env.sh，与 process 独立，文档清晰 |

---

## 三、自举与 .su 迁移

**进展备忘：** C 前端 `parser.c` 块级 **`MAX_CONST_DECLS` / `MAX_LET_DECLS` 均为 256**；`parser.su` 中 **`OneFuncResult`、AST/`ast.su::Block`、`parse_into`/dummy/diag** 等与 const/let 槽位相关的上限已统一到 **256**；诊断路径 `diag_parse_one_after_collect_imports` 的 dummy 已与结构体对齐。**`make bootstrap-parse-file`**：**第一段** `.su` 与 **shu** 均写 **`return 0`**；**第二段** 均写 **`return (1 + 2) * 3 + -1`**，**.su standalone** 经 **`parse()`** 内在堆上分配 Arena 并调 **`parse_expr_into`**（与宿主完整前端一致，不再用语义等价的字面量替身）。

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | `shu check` / `shu fmt` / `shu test` 子命令 | check/fmt/test.su + runtime.c；run-check/fmt-cmd/test-cmd 纳入 run-all |
| ✅ | parser `index+as`（`arr[i] as i32`） | parser.c 与 parser.su 对齐；run-while `index_as_cast` 在 shu/shu-c 均通过 |
| ✅ | `.su typeck` break/continue 循环外检查 | 与 typeck.c 一致；run-while `break_outside` 通过 |
| ✅ | dep 全局槽（`driver_dep_slot_for_path`）+ collect 传递闭包 | check 含 import 通过；hello 等多 dep 经 collect 展开子 import；run-all-su 全绿 |
| ✅ | 放宽单函数 let 上限（避免 parser.su 做 while/for 时「too many let」） | 与 `MAX_LET_DECLS`/`OneFuncResult` 对齐到 256；`make bootstrap-parser` 通过 |
| ✅ | 修 bootstrap-parser / codegen（OneFuncResult、数组初始化等） | `make bootstrap-parser`、`make bootstrap-parse-file` 通过 |
| ✅ | parser.su：**回归与文档**与通用 `parse_expr_into` 对齐；新语法按需扩 | **while/for** 见时序表 2.6/2.7 ✅。**`parse_expr_into`** 已承载 2.8～2.10 主路径；验收：`make bootstrap-parse-file`（见上「进展备忘」）与 `run-binary-expr.sh`、**`-su` return 负例**（`tests/typeck/return_operand_type_mismatch.su`，`run-typeck.sh`） |
| ⬜ | 更多 typeck/codegen 逻辑迁入 .su（10.4.2） | 自举仍过；**bootstrap shu** 多 dep（hello.su）preamble 与 codegen skip 已对齐；**codegen.su** dep 前缀与 std.io trivial handle 跳过；待继续收窄 `write_io_net_abi_inline` / `pipeline_glue.c` |
| ⬜ | pipeline_glue / LSP 去 C（`-E-extern` 自动 extern、统一 parse_into API） | **diagnostic/hover/references** 已走 `parse_into_buf`；**definition** 仍 C `parse()`；`-E-extern` 仍靠 codegen.c 内嵌块 |
| ⬜ | Target B macOS asm-only（`SHU_ASM_EXPERIMENTAL_SKIP_GEN`） | macOS **24/24** `__text` 非空（`SHU_ASM_ENTRY_MODULE_ONLY`）；Darwin 实验链仍 **undefined symbol**（缺独立 pipeline_glue TU），见 `SELFHOST.md` §4.1 |

---

## 四、可选与收尾

| 状态 | 项 | 验收 |
|------|----|------|
| ✅ | CI 可选跑 asm（bootstrap-driver + run-asm） | 主编译 Linux job：`build_shu_asm.sh` + `check_asm_o_quality.sh`；另见 workflows `linux-asm-smoke`（`bootstrap-driver` + `SHU_CI_FORCE_ASM=1 ./tests/run-asm.sh`） |
| ✅ | 测试与语言缺口：FFI 回归、return 类型断言、packed 等 | **FFI**：`run-ffi.sh` 已在 run-all。**return**：`-su` 下 `shu_su`/`shu-su` 对齐见 `run-typeck.sh` 与 tests/README §5.2。**packed/memory-contract**：仍以文档与 struct 负例为主；深测可单列脚本（README 已说明） |
| ⬜ | 自举前基建：FFI 规范、UB 清单、Result 寄存器化、io.driver 占位 | 见 analysis/自举前-目标与缺口分析.md |

---

## 使用说明

- **顺序**：建议先做「一」再做「二」，三、四可按需穿插。
- **性能**：无 benchmark/业务瓶颈报告前，不单开长周期性能专项；需要时再榨 std.net（如 multishot）或编译器 IR/阶段 8（参见 `analysis/接下来做什么-性能压榨与新std.md`）。**触发条件**：`tests/run-perf-baseline.sh` 建立基线 + 明确热点后再立项。
- **打勾**：完成一项后，把该项的 `⬜` 改成 `✅` 并保存本文件。
- **更新**：若某条验收标准变更，直接改表中「验收」列即可。
