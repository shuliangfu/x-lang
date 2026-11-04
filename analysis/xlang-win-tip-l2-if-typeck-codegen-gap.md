# Win tip L2 IF typeck／codegen tip≠SC（刀 11.52）

> Gate：`tests/run-win-tip-l2-if-typeck-codegen-gap-gate.sh`。
> Beat：`win_tip_l2_if_typeck_codegen_gap`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> 只 LAN `windows-server`；tip PE 起点／终点 **`cb03960b…`**（realign 试补丁已恢复 bak）。
> Soft Cap 只读对照：`/c/xlang_tmp/prod_softcap/lab_SoftCap_76795.exe`（md5 `caf0924b…`）。

## 从 11.51 继承

- IF vs WHILE 结构差已钉；type_ref／advance inject 非充分。
- 开刀假设：tip≠SC 在 typeck stmt_order（802 vs 2356）／codegen mega。

## DIG（本刀钉死）

### 纠正：802 vs 2356 为 T／t 误读

| 符号 | tip `t` 真身 | tip `T` tramp | SC 同形 | maskEq 真身 |
|------|-------------|----------------|---------|-------------|
| `typeck_check_block_stmt_order_one` | **2356** | 802 | 同 | **True** |
| `typeck_check_block_one_while` | 620 | 256 | 同 | **True** |
| `typeck_check_block_one_if` | 1024 | 417 | 同 | **True** |
| `typeck_check_block_impl`／`final`／`one_region` | 同长 | — | 同 | **True** |
| `pipeline_asm_emit_block_if_stmt_elf` | 2542 | — | 同 | **True** |
| `pipeline_backend_asm_codegen_ast_to_elf_mega_body_c` | 3830 | — | 同 | **True** |
| `pipeline_block_stmt_order_rebuild_sparse_ifs` | 1166 | — | 同 | **True** |
| onefunc／append_if／fill_*／if_stmt_x／block_ptr／cond | — | — | — | **True**（onefunc 焦点集仅 shrink_hi 1B 噪） |

`backend_asm_codegen_ast_seed_mega` 粗 mask 曾报 2 diffs＝`E8` rel32／假阳性（disp8=`0xE8`）；**非** IF 充分差。

⇒ **本刀靶「typeck／codegen 真身 tip≠SC」不成立**；不能用「拷 SC typeck」做 tip 产品修。

### tip≠SC 仍钉到的邻域（移交）

| 项 | tip | Soft Cap |
|----|-----|----------|
| `parser_asm_realign_lex_after_if_arm_into_c` **W** | `jmp`→`lex_set_pos` 簇＠`0x1406012c2` | `mov eax,1; ret` |
| tip-only 把 realign 改成 SC 形 | IF **仍 CG002**；WH／NOIF／match10 OK → **非充分**（已恢复） |
| `xlang check IF_min` | **P001** parse skip strict | OK |
| `xlang check NOIF` | OK | OK |
| `xlang -c`／`build` IF_min | **CG002** `code_len=0` | OK |
| WH0／NOIF `-c` | OK | OK |

### Residual（锁形）

- tip IF_*：`-c`→CG002；`check`→P001；P012 未解。
- tip PE：`cb03960b…`（无产品 tip 修）。
- 基线 L2 **1/5**＠`58e34910f` 未重跑（无解锁）。

## 正式 CLOSE residual HOLD

typeck／codegen IF 路径真身 **maskEq** SC；开刀假设证伪。邻域 tip≠SC＝**IF arm realign W stub**＋**check P001 vs -c CG002**。**无** Soft Cap G05；**无**假绿；移交 11.53。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48；CloudAgent；CheckSubscriptionUsage；假绿。
