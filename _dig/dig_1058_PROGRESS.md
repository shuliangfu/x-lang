# 10.58 PROGRESS — Win shadow／栈参 arg_idx≥4

**2026-10-29 15:27 CST (Asia/Shanghai)** · SoftCap isol→WORK · 未 push · 钉 ecdb5cc1e 不升

## DIG 结论
1. **根因（非题面字面「先 push 再 sub 盖栈」）**：SoftCap `arch_x86_64_enc_enc_mov_rax_to_arg_reg` Win 分支把 **arg_idx=4/5** 当成 **r8/r9** 再发（与 arg2/arg3 共用 3B `49 89 c0/c1`），`sub rsp,0x20` 后第5+实参写进 GPR，**从不**写 `[rsp+0x20+]`。
2. **Callee 正确**：`take5` 读 `[rbp+0x30]`（= caller `[rsp+0x20]` after call）；缺的是 caller store。
3. **对照 I（7945801 `48139a4fa0b8`）**：同名函数走栈构建 `48 89 84 24 disp32`（`mov %rax,disp(%rsp)`）；SoftCap 无等价路径，仅 GPR 表。I 本拍因 seeds 路径未完整编出对照 PE，但编码形态已对齐题面正解。
4. **10.54 表修复副作用**：当时把 arg4/5 LEA 钉到 r8/r9 槽，**保留**了本 bug；本拍在 TABLE+30 另植栈存 opcode，改 arg4/5 长度 3→5。

## Isol cave（最小）
- 基：PROD SoftCap `59560be0128f`
- TABLE `0x140519d36+30` 植：`48 89 44 24 20` \| `48 89 44 24 28`
- `+225` arg4：LEA→TABLE+30，`r8d=5`
- `+261` arg5：LEA→TABLE+35，`r8d=5`
- 不动 arg0–3／SysV 第二枝／Darwin／Ubuntu 源
- ISOL／WORK sha12 **`7a2cf5da581a`**
- bak：`C:/xlang_tmp/p1058/bak/xlang_59560be0128f.exe`

## 结果（XLANG_WPO_NO_FOLD=1）

| probe | expect | Win PROD旧 | Win ISOL/WORK | Darwin | Ubuntu |
|-------|--------|------------|---------------|--------|--------|
| reg4 | 7 | 7 | **7** | 7 | 7 |
| stack5 | 7 | 0 | **7** | 7 | 7 |
| stack6 | 7 | 215/210 | **7** | 7 | 7 |
| stack5_sum | 7 | 6 | **7** | 7 | 7 |

Win stack5 main 现：`mov %rax,0x20(%rsp)` 后 `call take5`；stack6 另有 `0x28(%rsp)`。rcx/rdx/r8/r9 未毁。

### 10.54 回归（ISOL≡PROD 逐项）
i32_call/opaque/sanity=7；i32_two=3；f32_ignore=7；f32_as/opaque=1；f64_ignore=7；local=1；call0=7 → **10/10 未毁**。

## 状态
- ✅ ISOL 绿 → ✅ 已升 **WORK**（`compiler/xlang.exe` = `7a2cf5da581a`）
- 未 push；未升钉；未碰 tip／mega／LEGACY
- 产物：`C:/xlang_tmp/p1058/p1058_isol_stack_arg_fix.exe`、`p1058_work_stack_arg.exe`、`compiler/p1058_isol_stack_arg_fix.exe`

## 下一步
1. Manager 批后 WORK→PROD 记进度（commit+push `dev`，进度 10.58✅）— **本拍不擅自 push**
2. 可选：arg_idx>5 扩 TABLE（`+0x30/+0x38`…）与取消 clamp=5；本探针仅到 6 参已够
3. 可选：对照 I 全量 seeds 编 stack5 侧验（非门禁）


## CLOSE
Manager ✅ · WORK→PROD · see dig_1058_CLOSE.md · 2026-10-29 15:31 CST
