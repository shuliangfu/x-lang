# TU Contract: runtime_asm_build

## 1. 当前权威源
- x 源：`src/asm/runtime_asm_build.x`（G-02f-24 真迁 .x — main 保留 seed）
- seed 源：`seeds/runtime_asm_build.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 DIRECT 函数，seed/rest 提供 main（argv 语言限制）

## 3. 导出符号合同
- thin/.x 导出：2（2 个 DIRECT）
- seed/rest 导出：1（main）
- only_x：0

### 3.1 必须由 thin/.x 提供
- `asm_driver_skip_codegen_dep_0_get`（DIRECT，转发 `driver_skip_codegen_dep_0_get`）
- `asm_driver_set_current_dep_path_for_codegen`（DIRECT，转发 `driver_set_current_dep_path_for_codegen`）

### 3.2 当前仍由 seed/rest 提供
- `main`（入口函数，调用 `shux_forward_main_to_main_entry`）

## 4. ABI Manifest
- _impl 残余列表：无
- DIRECT 符号列表：`asm_driver_skip_codegen_dep_0_get`、`asm_driver_set_current_dep_path_for_codegen`
- thin+rest 宏边界：`SHUX_RUNTIME_ASM_BUILD_FROM_X`
- 前向声明：无（rest 函数 main 不调用 thin 函数）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 2 thin T + main T + 3 外部 U；Ubuntu merged 3 T/W，U 仅 3 个 extern "C" 依赖）
- smoke/probe：pending

## 6. 备注
- main 保留 seed：.x 无法表达 `char **argv`（Clang 强制 main 第二参数为 `char **`）。shux-c -E 生成的 `uint8_t *argv` 被 Clang 拒绝。.x 中 main 函数定义已删除，main 完全由 seed 提供
- 纯 DIRECT 模式：2 个转发函数由 .x 提供，seed 在 rest 模式下不提供这 2 个函数
- 依赖：外部 TU `driver_skip_codegen_dep_0_get` / `driver_set_current_dep_path_for_codegen` / `shux_forward_main_to_main_entry`（driver/runtime TU）
