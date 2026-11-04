# Win tip L2 binop sub codegen SEGV（刀 11.76）· **DIG residual HOLD**

> Gate：`tests/run-win-tip-l2-binop-sub-codegen-segv-gate.sh`（HOLD exit2）。
> Beat（更准名）：`win_tip_l2_binop_sub_codegen_segv`（OPEN 暂名 `win_tip_l2_*_t001` 已弃）。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate75／74／73／72／71／67／63–55。
> tip PE **`c6f6fb583b70…`**（`xlang_asm.exe`；**无本刀 PE 修**）。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## DIG（诚实根因）

- 表象：`core/fmt/mod.x` 作根 `-c`／`-o` → **SEGV 139**（`check` EXIT0）；hello／`std/io` `check` 仍绿；**hello `-o` 现 RUN0**（L2 fail-family 旧锁 P012 已漂移，本刀不宣称抬分）。
- 缩小矩阵（tip PE `c6f6fb583b70…`）：

| fixture | tip `check` | tip `-c` | Soft Cap Prefer `09fe` `-c` |
|---------|-------------|----------|----------------------------|
| `return -x`（unary） | 0 | **0** | **0** |
| `let u = x + 0` | 0 | **0** | **0** |
| `let u = 0 - x`／`return 0 - x` | 0 | **139** | **139** |
| `x - 0`／`x - 1`／`1 - x`／`a - b` | 0 | **139** | **139** |
| fmt `fmt_i32_to_buf` 含 `0 - x` | 0 | **139** | P012／XP001（异形，只读） |

- **真残钉死**：**二元 `-`（binop sub）** codegen 路径；**非** unary `-x`。crash 落在 tip `pipeline_elf_ctx_append_bytes`＠`0x1402adac7`（写环 insn＠`0x1402adbb7`：`movzbl (%rax),%eax; mov %al,(%rdx)`）。
- tip W trampoline 核查：`glue_emit_binop_sub_rbx_minus_rax_elf_c` W＠`0x14026b6ff` **e9→** live T＠`0x1401301f8`；`…_rax_minus_rbx…` W＠`0x14026b883` **e9→** `0x140130bd8` —— **正靶 trampoline，非 stale 错靶**（≠ 11.73／11.75 类 tip-peel）。
- Soft Cap Prefer `09fe` **同款 SEGV**（只读对照；≠混 tip；Prefer 非绿 oracle）→ **无 tip-only PE inject 产品修**。

## Residual HOLD

- 真残＝**binop `-` → elf `append_bytes` SEGV**（fmt／option 等表面含 `-` 的 codegen 失败同源）。
- **无 PE 修**；PE 仍 **`c6f6fb583b70…`**；闸位 HOLD；**勿假绿**。
- Soft Cap Prefer 同残；禁升 Soft Cap／钉／tiphead／Cap tip；禁 Soft Cap 体拷。
- 旁注（不抬分）：hello `-o` RUN0；opt CG002 现 `code_len=5037`（旧锁 `code_len=0` 已漂移）—— fail-family 闸需经理另批诚实改锁，本刀不改。
- 移交下一刀须经理另开（binop sub／elf ctx 根修，非本刀 tip-peel e9）。

## 验收（本刀）

- DIG＋gate 入仓；gate HOLD exit2（binop `-` `-c`→139；unary `-x` 绿；PE 未改）。
- 保绿：gate75 等仍可跑（本刀不改 PE）。
- hello tip `check`／`-o` 不 regress。
- L2 1/5＠`58e34910f` 未抬分宣称；**勿自 CLOSE**。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿（删 fmt `0-x`／改源冒充绿）；CloudAgent；`_dig` 入 git；勿自 CLOSE；勿开 11.77。
