# 10.58 OPEN — Win caller shadow space stomps pushed stack args

**2026-10-29 15:20 CST(Asia/Shanghai)** · after 10.54✅ closeout

## 题面
Windows 调用方 shadow space 盖住先 push 的参数值；调用前压栈的值不被 shadow space 覆盖才 ✅。

## 约束
- Win 串；改动隔离；禁牵坏 Mac／Ubuntu
- 禁 CloudAgent／升钉 ecdb5cc1e／10.74／mega／HARD BAN／LEGACY／tip 叶子
- SoftCap PROD sha12 `59560be0128f`（10.54 升）为基；未绿勿 push

## 首拍计划
1. 最小探针：≥5 个 i32／混合栈参函数（第 5+ 参走栈）；Win Soft Cap PROD 编跑，对照 Darwin／Ubuntu（应绿）
2. DIG：调用点序——先 push 栈参再 `sub rsp,0x20` 会盖住已压值；查 SoftCap emit_call／call_args／shadow 预留顺序 vs LIVE／I
3. 最小 cave／thin；禁 mega；有牵再跑双端门

## 基线
- PROD Soft Cap sha12 `59560be0128f`；钉盘 ecdb5cc1e 不升
- 终局：analysis/终局待办.md · 10.58

## 首拍基线（PROD Soft Cap `59560be0128f`，XLANG_WPO_NO_FOLD=1）

| probe | expect | Win PROD | Darwin tip | Ubuntu tip |
|-------|--------|----------|------------|------------|
| reg4 (4×i32 GPR) | 7 | 7 OK | 7 | 7 |
| stack5 第5参 return e | 7 | **run=0** | 7 | 7 |
| stack6 e+f | 7 | **run=210** | 7 | 7 |
| stack5_sum a..e | 7 | **run=6** | 7 | 7 |

Win `stack5` main 反汇编：`sub rsp,0x20` 后把第5实参 `mov %rax,%r8`（盖掉第3参），**从未** `mov`/`push` 到 `[rsp+0x20]` 栈槽。→ SoftCap 栈参发射错位／shadow 预留与第5+参写入顺序／目标错；非双端回归。

## 首拍 DIG 结论（下一步）
1. 对照 LIVE／I：`glue_emit_one_call_arg`／call_args 对 arg_idx≥4 应写 shadow 上方栈槽，勿覆 r8
2. 查 SoftCap 是否把 Win 栈参当 SysV 第5 GPR（r8）或 shadow store 偏移错
3. 最小 isol cave；禁 mega；勿牵 Mac／Ubuntu
