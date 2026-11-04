# Win tip L2 IF check P001／arm realign（刀 11.53）

> Gate：`tests/run-win-tip-l2-if-check-p001-realign-gate.sh`。
> Beat：`win_tip_l2_if_check_p001_realign`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`cb03960b…`**。

## 从 11.52 继承

- typeck／codegen／if_x／emit／onefunc **maskEq** SC（802vs2356 为 T／t 误读）。
- tip≠SC：`parser_asm_realign_lex_after_if_arm_into_c` W（tip jmp vs SC `mov eax,1;ret`）；solo 改 SC 形 **非充分**。
- tip `check IF_min`→**P001**；`-c`／`build`→**CG002**；SC 均 OK；WH／NOIF OK。

## 本刀 DIG／修靶

1. 钉 check-strict 对 IF 的 parse skip 调用链 vs `-c` 宽松路径；对照 SC。
2. realign／fail-leave／scan_sync／append_if 运行时 hits；tip-only 小修若证据够。
3. 验收：IF_min `-c` 非空且 `check` 过；match10／WH0 不 regress。
4. 禁假绿／升闸／Soft Cap 混 tip。

## Residual（开刀时）

- tip IF CG002／check P001；P012；PE `cb03960b…`；L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage。
