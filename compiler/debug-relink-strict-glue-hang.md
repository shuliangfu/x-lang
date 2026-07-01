[OPEN]

# Debug Session: relink-strict-glue-hang

## Goal
- 定位并修复 `relink_shux_asm_strict_glue` 阶段卡死或链接失败（未定义符号）的根因，并在 `bootstrap-verify-bstrict` 路径下闭环验证。

## Symptom
- 现象：`relink_shux_asm_strict_glue.sh` 在链接/重链接阶段出现卡死或报未定义符号（ARM64/RISC-V emit/enc、cfg_eval 等相关）。
- 期望：脚本应稳定生成可用的 strict_glue 产物，并使 bstrict 自举链路继续推进。

## Repro (Candidate)
- `scripts/relink_shux_asm_strict_glue.sh`
- `verify-selfhost-stage2-bstrict.sh` 或 `bootstrap-verify-bstrict`（以实际触发命令为准）

## Hypotheses
- H1：链接命令行中目标/对象文件集合存在变体（缺失 `seed_link_compat.o` 或 `cfg_eval` 对象），导致符号解析路径发散，偶发卡住或持续失败。
- H2：多架构 dispatch（x86_64 环境下引用 arm64/riscv64 helper）中存在“应当弱兜底但未兜底”的符号，导致链接器在 LTO/死代码消除边界处表现异常（未定义/重复/选择不确定）。
- H3：重链接脚本引用了错误的 `cfg_eval.o` 路径或对象版本（同名产物冲突），导致最终链接的对象不包含 `cfg_eval_expr_c` 等符号。
- H4：链接过程实际并非“卡死”，而是进入了极慢路径（例如被迫进行全量符号扫描或重复尝试），需要通过插桩确认耗时阶段（spawn ld/collect2 前后、输入对象规模、重复尝试次数）。
- H5：产物/中间文件未被及时刷新（例如 `asm_backend_partial.o`、`pipeline_sx.o`），导致链接输入与预期不一致，引发不稳定结果。

## Evidence
- 待采集：通过 Debug Server 收集关键阶段事件（构建 strict_glue 的命令行、关键输入对象列表、耗时点、错误码/信号）。

## Next Actions
- 仅做插桩：为 `relink_shux_asm_strict_glue.sh` 的关键步骤（产物刷新、链接命令行生成、实际 ld 调用、退出码）增加结构化日志上报。

