# Win tip L2 primary_x stale→live trampoline（刀 11.55）

> Gate：`tests/run-win-tip-l2-primary-x-stale-trampoline-gate.sh`。
> Beat：`win_tip_l2_primary_x_stale_trampoline`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`cb03960b…`**。

## 从 11.54 继承

- IF＋WH＋ident／paren／call `check` P001 共同根＝tip stale primary 分派。
- SC：`__stale_prim_…parse_primary_x…` **+0 jmp live** `parser_asm_parse_primary_x_into_c`；tip 无 live、跑全量 stale＋ident／paren／array／lbrace stub→suffix_loop。
- tip 缺 14× live `parser_asm_*_x_into_c`；源＝`pthin_expr_primary.x`。
- Soft Cap 只读对照完成；**禁** 拷 SC 体入 tip。
- 无 tip 产品修；PE `cb03960b…`。

## 本刀 DIG／修靶

1. tip-local 恢复／绑定 live `parser_asm_parse_primary_x_into_c`＋`primary_{ident,paren,array,lbrace,…}_x_into_c`（override／relink／seed；扩 `stale_primary_array_x_into_override.c` 族），使 stale parse_primary **+0 trampoline** 或 stub 指向 tip 本地真身。
2. 验收：WH0＋IF_min＋`return (1)`／`let…return x` 的 tip `check` 过；IF_min `-c` 非空；match10／NOIF／11.48 绿族不 regress。
3. 诚实 tip-only 小修仅当 tip 本地目标齐；否则 residual HOLD＋OPEN 下一粒。
4. 禁假绿／升闸／Soft Cap 混 tip／杀另账号 check／CloudAgent。

## Residual（开刀时）

- tip IF CG002／check P001；tip WH check P001；P012；缺 live primary_x；PE `cb03960b…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
