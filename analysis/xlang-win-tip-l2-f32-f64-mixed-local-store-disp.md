# Win tip L2 f32+f64 mixed local store disp（刀 11.77）· **DIG WIP · PAUSED**

> **用户当面令（2026-11-05）**：暂停 11.77 DIG／自举刀；本文件仅 WIP 线索落盘。**未 gate／未 plant／未 CLOSE**。续办改：Windows L2 全绿 → 三端 L4 全绿 → 再续自举。

> Gate：**未入仓**（暂停令禁 gate）；续开刀时再补。
> Beat（更准名）：`win_tip_l2_f32_f64_mixed_local_store_disp`（OPEN 暂名 `win_tip_l2_*_t001` 已弃）。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate76（HOLD）＋75／74／73／72／71／67／63–55。
> tip PE **`c6f6fb583b70…`**（`xlang_asm.exe`；**无本刀 PE 修**）。
> 禁 Soft Cap G05／Prefer 体拷混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。
> **绕开**已 HOLD 的 `binop_sub`（本刀不挖二元 `-`）。

## DIG（诚实根因）

- 表象：`tests/float/f32_f64.x` tip `-o` build0 → run **SEGV 139**；Soft Cap Prefer `09fe` **run0**（对照绿 → 残在 tip PE）。
- 缩小矩阵（tip PE `c6f6fb583b70…` vs Soft Cap Prefer `09fe`）：

| fixture | tip `-o` | Soft Cap Prefer `-o` |
|---------|----------|----------------------|
| `let x: f32 = 0.0; return 0` | build0 **run0** | build0 run0 |
| `let x: f32 = 0.0; let y: f64 = 1.5; return 0` | build0 **run139** | build0 **run0** |
| 两 `f32` 局部 | run0 | run0 |
| 仅 `f64` 局部 | 双方常 CG002（异形，非本刀主残） | 同左 |

- **真残钉死（产物 disasm）**：
  - tip `main`：`movabs $0x3ff8000000000000,%rax`（f64 1.5）后 **`mov %rax, 0x7fffbfc0(%rbp)`** → SEGV（rax 位型当地址）。
  - Soft Cap Prefer：同 imm 后 **`mov %rax, -0x20(%rbp)`**（正确局部槽）。
  - tip 的 f32 存 `mov %eax, -0x18(%rbp)` 正确；**混排 f32+f64 时 f64 槽 disp 砸穿**。
- 与历史 Prefer-M2 let-store smash 同款签名（`48 89 85 c0…`／p1061／p1065）；tip `glue_block_body_emit_let_init` 已有 inline `|off|≥0x1001→0x18` clamp，**仍发出砸 disp** → smash 未走／未吃到该 clamp，或后级路径另喂 encoder。
- Soft Cap Prefer `emit_let_init` 在无 name 枝 **`e9`→Prefer 外节**（`0x14a225000` 类）——对照绿依赖 Prefer 外科节；**禁 Soft Cap 体拷**。
- tip-peel 扫描：float／let／slot／store 相关 **无** tip W `e9→错靶` 可注；`backend_enc_store_rax_to_rbp_arch`／`glue_emit_assign_var_store_*` tip＝SC 头；**无 tip-only PE inject 产品修**。

## Residual HOLD

- 真残＝**同函数 f32+f64 局部 → tip f64 store disp 砸穿 SEGV**（fail-family f32 锁同源）。
- **无 PE 修**；PE 仍 **`c6f6fb583b70…`**；闸位 HOLD；**勿假绿**。
- Soft Cap Prefer 绿＝Prefer 节对照，≠ tip 可 peel；禁升 Soft Cap／钉／tiphead／Cap tip。
- 旁注（不抬分／不挖）：binop_sub 仍 SEGV HOLD；scalar-only `let i32=lit` tip＋SC 同款 CG002 `code_len=17`（另档）；option 全量 tip CG002／SC T001 异形。
- 移交下一刀须经理另开（let-store／f64 槽／Prefer-M2 tip.x 诚实根修，非本刀 tip-peel e9）。

## 验收（本刀）

- DIG＋gate 入仓；gate HOLD exit2（f32+f64 `-o` tip run139；solo f32 run0；PE 未改；SC 只读对照可选）。
- 保绿：gate75 等仍可跑（本刀不改 PE）。
- hello tip `check`／`-o` 不 regress。
- L2 1/5＠`58e34910f` 未抬分宣称；**勿自 CLOSE**；**勿开 11.78**。

## 非目标／禁

- Soft Cap Prefer／G05 体拷混 tip；回滚 11.67 wrap；假绿（删 f64 局部冒充绿）；CloudAgent；`_dig` 入 git；勿自 CLOSE；勿挖 binop_sub。
