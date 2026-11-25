# Win tip L2 P012 dual-fn scope／local table（刀 11.46）

> Gate：`tests/run-win-tip-l2-p012-dual-fn-scope-gate.sh`。
> Beat：`win_tip_l2_p012_dual_fn_scope`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；空数组 `= []` 必须 OK。
> 闸位 HOLD：Soft Cap Prefer `09fe`／钉 ecdb／tiphead 9ecd／Cap tip／code tip **不升**。
> 禁：假绿／unique-rename hollow／SoftCap-parity／CloudAgent／Soft Cap G05 混 tip／纯 cave。
> 只 LAN `windows-server`；权威 tip PE＝`compiler/xlang_asm.exe`（bak `/c/xlang_tmp/p1145/xlang_asm.exe.bak_pre_1145` md5 `8adfb6e0…`）。

## 机制 DIG（钉死）

### A. body_lets 不直接 top_level

| locus | finding |
|-------|---------|
| `parser.x` `parse_body_lets_into` | Body lets → `pipeline_onefunc_append_let`（sidecar），**不**直接 `top_level_let_alloc` |
| `append_block_lets_from_res` | 把 sidecar 拷进 **block** lets；不写 module top_level |
| hoist | 仅重排 body let 到循环顶；不 invent top_level |
| 唯一故意 body→top_level | `static let`／`static const` desugar → `parse_one_top_level_let_into` |
| P012 kind=2 守卫 | `asm_module_top_level_let_name_exists` **只**扫 module `top_level_lets` |

结论：P012＝某条路径把 **local 名写进／误解析为** module top_level，不是 hoist／append_block_lets 误写。

### B. 误走路径（Win tip PE）

1. **`*T` 参数** → `__stale_parser_asm_parse_star_type_x_into_c` → `parser_asm_is_pointee_type_token_c`（W＠`0x1405c1560`）。
2. Tip PE 该 W：**Win64 形参在 rcx，函数体却用未装载的 ebx 比较** → 调用点 ebx=0 → 恒返 0 → `*u8`／`*i32` 解析失败。
3. `set_onefunc_fail` soft-skip **未吃完函数体** → 体里 `let` 留给 module 循环 → 当 top-level 注册。
4. 第二 fn 同名 local → **P012**。单 fn 同失败常表现为 **CG002** `code_len=0`（无第二 fn 撞名）。

`num_top_level_lets` 证据（推断／对照，无 runtime dump API）：

| probe | 结果 | 含义 |
|-------|------|------|
| Q5：`*u8` fn + 模块 `let num_digits` | P012 | 第一 fn 失败后 body 名已在 top_level |
| R0 无参 dual nonempty scalar | 非本 P012 主链 | |
| S2 `u8` 值参 OK；S3 `*i32` code_len=0 | 指针类型门 | |
| 双 fn empty `u8[10]=[]` 无 `*` | OK（基线） | |
| 双 fn `*u8` + empty（patch 后） | **OK** | *T 链解开 |
| e_fmtstyle nonempty（patch 后） | **CG002** code_len=47（**无 P012**） | *T 链解开；非空数组／codegen 残 |
| hello→core.fmt（patch 后） | **仍 P012**＠fmt `num_digits` | 非空 lit／while 体仍 soft-fail 泄漏 |
| J1 双标量 `return a+b` | 仍 P012 | 另一 soft-fail→泄漏族（非本刀 *T） |

### C. tip 侧小修（已上 LAN tip PE；未 Soft Cap）

- **Byte patch** `parser_asm_is_pointee_type_token_c`：`mov %rcx,%rbx` + spill rbx（见 override 头注释）。
- 种子：`compiler/seeds/win_tip_pe_overrides/is_pointee_type_token_override.c`（强符号／pthin ords）。
- **勿** Soft Cap G05 混 tip；**勿**升 tiphead／钉。
- 空数组 dual／基线 1/5 控制：**勿 regress**（patch 后 empty／dual_ptr_empty 仍 OK）。

## 矩阵（patch 后 tip PE md5 `e1b269dc…`）

| probe | 结果 |
|-------|------|
| dual empty 无参 | OK |
| dual `*u8` + empty digits | OK |
| e_fmtstyle nonempty 双 fn | CG002（非 P012） |
| one_arr nonempty | CG002 |
| hello | P012 残（fmt 非空／while） |
| Darwin 同形 | OK（对照） |

## Residual／下一步诚实粒

- **P012 *T／is_pointee 链：已钉死并 tip 修补**；hello 产品 P012 **未清**（非空数组 primary／while 体 soft-skip 同族）。
- 下一优先：**CG002 nonempty array** 或 **fail-leave 吃干净函数体**（防 J1／fmt while 再泄漏）→ 刀 11.47。
- Soft Cap Prefer 同形 ≠ 抬 tip。

## 非目标／禁

- 不升 Soft Cap／tiphead／钉；不做 Soft Cap G05 整链塞 tip。
- 不 unique-rename `core/fmt`（hollow 假绿）。
