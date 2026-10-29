# 10.60 OPEN — Win single-stmt `return` bypasses RETURN node

**2026-10-29 15:31 CST (Asia/Shanghai)** · after 10.58✅ closeout

## 题面
Windows 单句函数体 `return` 不走 RETURN 节点（w1521 在 call_dispatch 补转交）；Windows 单句 return 走正常 RETURN 路径才 ✅。

## 约束
- Win 串；改动隔离；禁牵坏 Darwin／Ubuntu
- 禁 CloudAgent／升钉 ecdb5cc1e／10.74／mega／HARD BAN／LEGACY／假绿
- SoftCap PROD sha12 `7a2cf5da581a`（10.58）为基；未绿勿 push
- 债：10.58 arg_idx>5（clamp=5）— 本刀顺手可挖，非门禁

## 首拍计划
1. 最小探针：单句 `return expr`／`return call()`／多句对照；Win SoftCap 编跑＋反汇编看是否缺 RETURN／走 call_dispatch 转交
2. DIG：对照 LIVE／I／w1521 call_dispatch 补转交 vs SoftCap emit_return／block_body 单句路径
3. 最小 isol；禁 mega；有牵再跑双端门

## 基线
- PROD Soft Cap sha12 `7a2cf5da581a`；钉盘 ecdb5cc1e 不升
- 终局：analysis/终局待办.md · 10.60

## 首拍基线（PROD Soft Cap `7a2cf5da581a`，XLANG_WPO_NO_FOLD=1）

| probe | expect | Win PROD | 反汇编要点 |
|-------|--------|----------|------------|
| ret_lit `return 7` | 7 | 7 | 单句：mov imm→epilogue→ret；**无** jmp-RETURN 标号 |
| ret_call `return id(7)` | 7 | 7 | call 后直接 epilogue；无独立 RETURN 节点痕迹 |
| ret_call_only `return seven()` | 7 | 7 | 同上 |
| ret_multi let+return | 7 | 7 | add 后 **jmp** 到 epilogue（正常 RETURN 标号路径） |

i32 单句 run 看似绿，但 codegen **缺 RETURN 标号／jmp**（多句才有）。题面指向 w1521 在 call_dispatch 补的 **sret／转交** 旁路——下一拍用大结构体／`return f()` sret 探针逼显。

### 债（自 10.58）
arg_idx>5：SoftCap clamp=5，else 恒 `[rsp+0x28]`；扩表+解 clamp／动态 stub 非小代价，本刀非门禁。

## tip after 10.58 push
`84ed5ecc1` · SoftCap PROD `7a2cf5da581a`


## 本拍进展（15:40 CST）
见 `_dig/dig_1060_PROGRESS.md`：DIG 已写清；sret 探针表（Win CG002／双端 tip exit=1）；isol-A=block_final kind41→emit_return。

## tip mid-step push（~20:46 CST Asia/Shanghai）
硬约定：DIG／isol／tip 步进即推。tip isol-A／C 已落＋双端 `p_ret_*`＋i32 绿；DIG 记 SoftCap mid-insn／epi／`p_ret` AV。SoftCap **未绿** → 勿升 PROD／钉盘 ecdb5cc1e **不升**／勿收刀。
