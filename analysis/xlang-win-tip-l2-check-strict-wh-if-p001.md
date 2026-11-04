# Win tip L2 check-strict WH＋IF P001（刀 11.54）

> Gate：`tests/run-win-tip-l2-check-strict-wh-if-p001-gate.sh`。
> Beat：`win_tip_l2_check_strict_wh_if_p001`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`cb03960b…`**。

## 从 11.53 继承

- realign W tip≠SC；solo SC 形对 check／`-c` IF **均非充分**（已恢复）。
- tip `check`：**IF** P001＠byte 0/6；**WH** P001＠byte 38；NOIF OK。
- tip `-c`：IF CG002；WH／NOIF OK。
- if／while／strict／check 主路径 **maskEq** SC；根不在 realign 独差。

## DIG（本刀落档）

### 共同点矩阵（tip PE `cb03960b…`；Soft Cap **只读** lab `caf0…`）

| fixture | tip `-c` | tip `check` | 共同点 |
|---|---|---|---|
| IF_min `if(true)` | CG002 | P001＠0/6 | 需 primary（bool／ident） |
| WH0 `while(false)` | OK | P001＠38 | 需 primary；strict 才炸 |
| `return (1)` / `main()` | CG002／P001 | P001 | **paren／call** primary |
| `let x=1; return x` | OK | P001 | **ident** primary |
| `let _=1; return 1` / lit／binop | OK | OK | 无 ident／paren 头 |
| NOIF | OK | OK | — |

**共同点**：凡 tip `check` 需 **ident／paren／call／bool-as-primary／IF／WH cond** 的路径均 P001（或 `-c` CG002）；纯 lit／无 ident return OK。IF＋WH 同属 primary 分派失败族，非 if／while 独差。

### Call-graph（禁 Soft Cap 混 tip；只读对照）

1. tip＆SC：`parser_asm_parse_primary_into_slice_c` → call `__stale_prim_parser_asm_parse_primary_x_into_c`。
2. **SC** `__stale_prim_…parse_primary_x…` **+0 = `jmp` live `parser_asm_parse_primary_x_into_c`**（2044B 全实现；再 call live `primary_{ident,paren,…}_x_into_c`）。
3. **tip** 同名 stale **无 trampoline**：头＝`push rbp; mov rbp,rsp;…` 全量 dispatcher；+1321／+1468／+1615／+1944 call `__stale_prim_…primary_{ident,paren,array,lbrace}_x_into_c`。
4. tip 该四处 stub＝**8B `jmp` → `__stale_prim_…suffix_loop…`**（不消费 token；与 11.45 array stub 同形）。
5. SC 同名 stale **ident／lbrace** stub 已 `jmp` **live** `parser_asm_primary_{ident,lbrace}_x_into_c`；paren／array 仍 jmp suffix_loop，但因 stale parse_primary **+0 trampoline** 永不走到 stale stub。
6. tip **缺全部 14** 个 live `parser_asm_primary_*_x_into_c`／`parser_asm_parse_primary_x_into_c`（nm 无）；源在 `compiler/src/asm/pthin_expr_primary.x`，Win tip PE 未链入 live W。
7. tip vs SC stale parse_primary_x：**maskEq False**（仅头 5 字节 trampoline 差＋少数 RIP；call 相对位移同形但目标语义不同）。
8. Soft Cap if／while／strict／check 主路径仍 **maskEq**（11.53）；败因在 **primary_x live 缺失 → stale stub 误跳 suffix_loop**。

### tip-only 小修评估

- 诚实小修需 tip 本地 **live primary_x 目标** 或 tip-local override／relink（既有 `stale_primary_array_x_into_override.c` 仅 array；未覆盖 ident／paren／parse_primary trampoline）。
- **禁** 从 Soft Cap 拷贝 live 体／G05 混 tip。
- tip PE 无 live 可 `jmp` 重定向 → **5～8 字节 PE stub 独改不充分**。
- 本刀 **无 tip 产品字节**；PE 仍 `cb03960b…`。

### 结论

- **共同根已钉**：check-strict 下 IF＋WH（及 ident／paren／call）P001 ＝ tip stale primary 分派无 live trampoline／stub→suffix_loop；SC 靠 stale→live。
- **无 tip-only 产品修可落**（缺 tip 本地 live 目标）；**CLOSE residual HOLD**；移交 11.55 tip-local primary.x bind／override（禁 Soft Cap 字节）。

## Residual（CLOSE）

- tip IF：`-c` CG002；`check` P001。
- tip WH：`-c` OK；`check` P001＠38。
- tip 缺 14× live `parser_asm_primary_*_x_into_c`；stale parse_primary 无 trampoline。
- P012 未解；L2 基线 1/5＠`58e34910f`（本刀未复跑 L2；无 unlock）。
- PE `cb03960b…`；闸位 HOLD。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage；杀另账号 xlang(check)；`_dig`／临时入 git。

## CLOSE

**CLOSE residual HOLD** `win_tip_l2_check_strict_wh_if_p001`（刀 11.54）。
