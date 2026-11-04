# Win tip L2 P012 fmt local scope（刀 11.45）

> Gate：`tests/run-win-tip-l2-p012-fmt-local-scope-gate.sh`。
> Beat：`win_tip_l2_p012_fmt_local_scope`。
> 基线：Win tip L2 **1/5**＠`58e34910f`（tip PE 再验仍 1/5）**勿 regress**。
> 闸位 HOLD：Soft Cap Prefer `09fe`／钉 ecdb／tiphead 9ecd／Cap tip／code tip **不升**。
> 禁：假绿／unique-rename hollow／SoftCap-parity／CloudAgent／抬 tiphead。
> 只 LAN `windows-server`；bak PE＝`/c/xlang_tmp/p1145/xlang_asm.exe.bak_pre_1145`（手术前快照；当前 tip PE 已恢复 bak）。

## Locked repro（11.16 真位点）

| probe | Win tip PE | Darwin tip（对照） | Soft Cap Prefer 09fe |
|-------|------------|-------------------|----------------------|
| `let digits: u8[10];` + same local names in 2 fns | OK | OK | — |
| `let digits: u8[10] = [];` + same locals in 2 fns | OK | OK | OK |
| `let digits: u8[10] = [48,…,57];` + `num_digits` in 2 fns（**e_fmtstyle**） | **P012**＠f2 `num_digits` | **OK** both T | **P012**＠f2 `digits` |
| `[u8;10] = [nonempty]` same shape | **P012** | OK | — |
| one fn nonempty array only | CG002 `code_len=22`（非 P012） | — | CG002 |
| `examples/hello.x` → `core/fmt/mod.x:79` `num_digits` | **P012** | hello OK | P012 |

触发器＝**非空数组字面量初值** `T[N]=[lits]`（空 `[]`／无 init 不触发）。  
真位点挂在 `core/fmt/mod.x:79` local `num_digits`（非 hello 行号）。  
Unique-rename 清 P012 但 hollow → **假绿禁**。

## DIG smoking gun（Win tip PE disasm）

1. `parser_asm_parse_primary_into_slice_c` → call `__stale_prim_parser_asm_parse_primary_x_into_c`。
2. Stale parse_primary 在 `TOKEN_LBRACKET` 臂 call `__stale_prim_parser_asm_primary_array_x_into_c`。
3. **该符号本体仅 5 字节**：`jmp __stale_prim_parser_asm_primary_suffix_loop_x_into_c`（**不消费 `[…]`**）。
4. 非空 `[lit,…]` 经 body_let compound → parse_expr → primary → 上述 stub → 解析失败／软跳失败 → body let 泄漏进 module top-level → **P012**。
5. C twin `parser_asm_primary_parse_array_lit_c`（`t`）在 PE 内存在但 **不被** stale primary 路径调用。
6. Darwin tip 无此 tip-peel stale jmp → hello／e_fmtstyle OK。

## Planted override（未入 tip PE 产品链）

- 源：`compiler/seeds/win_tip_pe_overrides/stale_primary_array_x_into_override.c`
- 意图：strong `T __stale_prim_parser_asm_primary_array_x_into_c`（ABI twin `parser_asm_primary_array_x_into_c`）在 relink 时盖过 weak jmp stub。
- Win host-cc：`.o` 已出 strong T。

## Residual HOLD（本刀未 CLOSE 产品绿）

| 尝试 | 结果 |
|------|------|
| `g05` surgical relink + override `.o` | Soft Cap reinject `emit_let_init.o` 要 `asm_ctx_local_set_offset_by_name`（tip PE 无此 T）→ 初失败；加 stub 后 relink **exit0** 但产物混入 Soft Cap objs，行为漂移（P012 行号变 digits）；**已恢复 bak PE** |
| 双符号 W jmp stub + T override 共存 | call site 仍进 W stub；patch W→T 后仍 P012（混链 PE） |
| 裸 patch stub → `xor eax,eax; ret` | 仍 P012（证明需真解析而非 return0） |
| cave inject into bak | COFF sym 解析脚本未完成；**未改 bak 权威 PE** |

**下一步诚实粒**（勿假绿）：tip-only G05_OBJS（剥离 Soft Cap emit_let_init／mega 漂移）+ strong override 盖 stub，或等价 retarget stale array call → 真 `primary_array`／`parse_array_lit`（ABI 对齐）；复跑 e_fmtstyle＋hello＋全 L2，**勿 regress 1/5**。

## 非目标

- 不升 Soft Cap Prefer／tiphead／钉／Cap tip。
- Soft Cap Prefer f32=0 **≠** tip L2 抬分。
- 不改 `core/fmt` 唯一化假绿。
