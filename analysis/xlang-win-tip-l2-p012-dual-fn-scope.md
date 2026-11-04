# Win tip L2 P012 dual-fn scope／local table（刀 11.46）

> Gate：`tests/run-win-tip-l2-p012-dual-fn-scope-gate.sh`。
> Beat：`win_tip_l2_p012_dual_fn_scope`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组 `= []` 必须 OK。
> 闸位 HOLD：Soft Cap Prefer `09fe`／钉 ecdb／tiphead 9ecd／Cap tip／code tip **不升**。
> 禁：假绿／unique-rename hollow／SoftCap-parity／CloudAgent／Soft Cap G05 混链入 tip／纯 cave。
> 只 LAN `windows-server`；权威 tip PE＝`compiler/xlang_asm.exe`（bak `/c/xlang_tmp/p1145/xlang_asm.exe.bak_pre_1145`）。

## 从 11.45 继承的矩阵（bak tip PE）

| probe | bak tip PE | 含义 |
|-------|------------|------|
| 双 fn `u8[10]=[]` + 同名 local | **OK** | 空数组不触发泄漏 |
| 双 fn scalar `num_digits` | **OK** | 非数组 lit 不触发 |
| 单 fn nonempty `u8[10]=[48…57]` | **CG002** `code_len=22` | parse 已过；codegen 另债 |
| 双 fn nonempty（**e_fmtstyle**） | **P012**＠f2 `num_digits`（行 8） | 真位点同 `core/fmt:79` |
| `examples/hello.x` → core.fmt | **P012** | L2 hello 红 |
| Darwin tip 同形 e_fmtstyle／hello | **OK** | 对照 |

11.45 tip-only dig_slim+override W→T：empty/rv OK；one_arr CG002；e_fmtstyle 仍 P012 且 locus 漂移 **digits@7** → **未入 tip 产品链**；bak 已恢复。

## 机制 DIG（本刀焦点）

1. P012 kind=2 ＝ `parser_report_duplicate_name_p012_c`／文案 “module already declares…”；守卫＝`asm_module_top_level_let_name_exists`（`runtime_pipeline_abi.x`）在 top-level let 注册前。
2. 函数体 local 不应进 `pipeline_module_top_level_let_*`。Win tip 在 **非空数组 lit 初值** 路径上，body let 解析失败／软跳后，后续同名 binding 被当成 **module top-level** → 第二 fn 触发 P012。
3. Body 路径：`parser_asm_parse_body_let_bracket_compound_init_ref_x_into_c` rewind 到 `[` → `parser_parse_expr_ptr_into_c` → primary →（Win）`__stale_prim_…primary_array…` 5B jmp→suffix_loop（11.45 DIG）。**仅盖 stub 不够**：双 fn P012 仍在 → 另有 **scope／local table／fail-leave 注册** 债。
4. Top-level 权威：`parser_asm_parse_one_top_level_let_x_into_c`（`pthin_let_alias.x`）dup 检查在 commit 前；若 body fail-leave 误走 skip／register top-level，即本刀靶心。

## 非目标／禁

- 不升 Soft Cap／tiphead／钉；不做 Soft Cap G05 整链塞 tip。
- 不 unique-rename `core/fmt`（hollow 假绿）。
- Soft Cap Prefer 同形亦 P012 ≠ tip 抬分证据。

## Residual／下一步诚实粒

- 对照 Darwin：同源 `pthin_let_alias`／body_let 为何不泄漏。
- Win tip：body-let fail-leave 是否调用 `skip_one_top_level_let`／`pack_commit_let`／误 `top_level_let_alloc`。
- 可复现最小矩阵 locked by gate；产品绿前 **勿 CLOSE ACCEPT**。

## Read-only path audit（OPEN 11.46 起步）

| locus | finding |
|-------|---------|
| `parser.x` `parse_body_lets_into` | Body lets → `pipeline_onefunc_append_let`（sidecar pool），**不**直接 `top_level_let_alloc` |
| Array lit 分支 | 自扫 INT／FLOAT／`,`／`]`；plain 成功则 `init_handled=1`；非 plain／`as` → `parser_parse_body_let_bracket_compound_init_ref` → `parse_expr` → primary（Win＝stale jmp） |
| P012 kind=2 守卫 | `asm_module_top_level_let_name_exists` 仅扫 **module top_level_lets** |
| 矛盾 | 单 fn nonempty＝**CG002**（parse 过）；双 fn＝**P012** → 第一 fn 成功后某路径把 local 名写入 top_level（或第二 fn 误走 top-level let parse） |
| Tip PE 符号 | 仍有 `parser_parse_body_lets_into`＋`__stale_prim_…primary_array…`＋`asm_module_top_level_let_name_exists` |
| 下一步 DIG | （1）Win tip 第一 fn 后 dump `num_top_level_lets`；（2）对照 `append_block_lets_from_res`／hoist；（3）勿 Soft Cap G05 混 tip |
