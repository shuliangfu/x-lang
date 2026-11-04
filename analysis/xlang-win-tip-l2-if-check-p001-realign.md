# Win tip L2 IF check P001／arm realign（刀 11.53）

> Gate：`tests/run-win-tip-l2-if-check-p001-realign-gate.sh`。
> Beat：`win_tip_l2_if_check_p001_realign`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE **`cb03960b…`**。

## 从 11.52 继承

- typeck／codegen／if_x／emit／onefunc **maskEq** SC（802vs2356 为 T／t 误读）。
- tip≠SC：`parser_asm_realign_lex_after_if_arm_into_c` W（tip jmp→`lex_set_pos_c` vs SC `mov eax,1;ret`）；solo 改 SC 形 **非充分**（`-c` IF 仍 CG002；已恢复）。
- tip `check IF_min`→**P001**；`-c`／`build`→**CG002**；SC 均 OK。

## DIG（本刀落档）

### 探针矩阵（tip PE `cb03960b…`；SC lab `caf0…`）

| fixture | tip `-c` | tip `check` | SC `-c`/`check` |
|---|---|---|---|
| IF_min | **CG002** `code_len=0` | **P001** skip byte **0**（num_funcs=-1）＋byte **6**（name=main）`[strict]` | OK |
| WH0 | OK | **P001** skip byte **38**（`while (`）`[strict]` ×2 | OK |
| NOIF | OK | OK | OK |

**纠正开刀继承**：tip **WH `check` 亦 P001**（非仅 IF）；`-c` WH 仍绿。

### realign 再证伪（含 check）

- T 真身 `parser_asm_realign_lex_after_if_arm_c`／`parser_realign_lex_after_if_stmt_onefunc_glue`／ctrl_realign_*／`lex_set_pos_c`：**maskEq** SC。
- 唯 W `parser_asm_realign_lex_after_if_arm_into_c` tip≠SC；patch tip→SC 形后：**check IF/WH 仍 P001**、`-c` IF 仍 CG002；已 **restore** `cb03960b…`。
- realign 只服务 IF arm；**不能解释 WH check P001** → solo realign **非充分且非根**。

### check／strict／if／while 代码对照（只读 Soft Cap）

- `driver_cmd_check`／`driver_run_compiler_check`／`pipeline_strict_parse_into_init`／`xlang_skip_commit_default_onefunc_c`／parse_if_*／scan_sync_after_if／while parse 相关共 **18** 符号：**全部 maskEq**。
- `pipeline_parse_into_with_init_buf_scalars` 表面 mask 差＝`c705` RIP imm 未遮罩噪声，非语义。
- tip-only 符号空；SC-only 多组 `parser_asm_primary_*`／`parse_type_ref_*` **W**（tip 无同名 live；走 slice／`__stale_*` 路径）——**本刀未证其为根，移交 11.54**。
- 旁路：`parser_asm_is_pointee_type_token_c` tip `mov rbx,rcx` vs SC `mov rax,rcx`（随后 `mov eax,0x3b`）；SC check 仍绿 → **非 tip 败因**；勿 Soft Cap 混 tip 改此。

### 结论

- **根因未钉到可 tip-only 产品修**：check-strict 对 **WH＋IF** 均 parse_skip，而严格／if／while／check 主路径代码≈SC；realign W 差为已知 tip≠SC 但 **非充分／非 WH 解释**。
- 无 tip 产品字节保留；PE 仍 **`cb03960b…`**。
- **CLOSE residual HOLD**；移交 11.54 dig check-strict 控制流／数据／primary 分派不对称。

## Residual（CLOSE）

- tip IF：`-c` CG002；`check` P001。
- tip WH：`-c` OK；`check` P001＠byte 38。
- P012 未解；L2 基线 1/5＠`58e34910f`（本刀未复跑 L2）。
- PE `cb03960b…`；闸位 HOLD。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage；杀另账号 xlang(check)；`_dig`／临时入 git。

## CLOSE

**CLOSE residual HOLD** `win_tip_l2_if_check_p001_realign`（刀 11.53）。
