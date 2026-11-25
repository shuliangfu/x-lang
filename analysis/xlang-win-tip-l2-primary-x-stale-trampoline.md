# Win tip L2 primary_x stale→live trampoline（刀 11.55）

> Gate：`tests/run-win-tip-l2-primary-x-stale-trampoline-gate.sh`。
> Beat：`win_tip_l2_primary_x_stale_trampoline`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。

## CLOSE residual HOLD（正式）

- **产品**：tip-local host-gcc override
  `compiler/seeds/win_tip_pe_overrides/stale_primary_paren_ident_x_into_override.c`
  ＋ inject
  `compiler/scripts/win_tip_pe_inject_primary_paren_ident_override.py`
  （paren-only helper 仍保留）。
- **PE**：bak `cb03960b…` → 产品 tip `e879bac3d9c07dc5b1f5896a112f641e`（`.text` RawSize＋0x400；
  JMP paren `0x1405e4d40`→`0x1406474c0`；ident `0x1405e329c`→cave；**禁** Soft Cap 字节）。
- **解锁**：`check` WH0／`return (1)`／`let…return x`／match10／call_main／vlet＝OK；
  WH0／match10／paren `-c`＝OK。
- **未解锁**：`IF_min` `check`／`-c` → **XT001** implicit tail／then 不覆盖（非再 P001）；
  Soft Cap IF 全绿。`if (1)` 得 T001 bool＝IF 语句入口在；残＝then-block 覆盖／stmt 路径。
- **ret_x `-c` CG002** `code_len=17`＝**Soft Cap 同形**（bak 空心 -c 假绿已排除）；非 tip 独 regress。
- Gate：**HOLD exit 2**（`wcrc=0 pcrc=0 xcrc=0 icrc=1`）。
- L2 **未**重跑（IF 未解；基线 1/5＠58e34910f 勿 regress）。
- 移交 **11.56** IF then-block XT001；闸位 HOLD；**勿假绿**。

## 从 11.54 继承

- IF＋WH＋ident／paren／call `check` P001 共同根＝tip stale primary 分派。
- SC：`__stale_prim_…parse_primary_x…` **+0 jmp live**；tip 无 live、跑全量 stale＋stub→suffix_loop。
- tip 缺 14× live `parser_asm_*_x_into_c`；**禁** 拷 SC 体入 tip。

## Residual（移交 11.56）

- tip IF_min XT001（then 不覆盖；SC OK）；P012；缺其余 live primary；L2 1/5＠`58e34910f`；
  tip PE 产品 `e879bac3…`（bak `cb03960b…`）。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
