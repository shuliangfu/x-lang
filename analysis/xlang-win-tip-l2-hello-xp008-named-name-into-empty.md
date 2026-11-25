# Win tip L2 hello XP008 named name_into empty（刀 11.70）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-hello-xp008-named-name-into-empty-gate.sh`（HOLD exit2 until A_val／*A／context green）。
> Beat：`win_tip_l2_hello_xp008_named_name_into_empty`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.69** 绿族／HOLD 勿 regress。
> tip PE **`059417e5772c…`**（unchanged；无 tip PE 修）。

## DIG（诚实根因）

- Fixture `min_A_val.x`＝`struct A { a: i32; } export function id(x: A): A { return x; }`：
  - tip `check` red：`expected  , found )`（return type mismatch）；SC `check` green。
  - nested／`*IoBatchBuf`／array-let／IF／11.67 wrap greens **不 regress**。
- Live dig（ASLR-safe `.p1170` RWX；hook `name_into`＠`0x1402A9187`；rip-rel `_open`/`_write`/`_close`；**dig-only 未入 tip PE／未入 git**）：
  - 17× `name_into`：全部 **kind＠0＝0**（非 NAMED=8）；**L84＝1**（非 ≤0）；name4＝`)` (0x29) 或 ` ` (0x20)；ret＝1。
  - equal_named 成对：`)` vs ` ` → 与 diag `expected  , found )` 对齐。
  - **订正 11.69「len＠0x84≤0 空名」**：本 fixture 主失败＝**错名 1 字节 `)`／空格**，非经典空 len；name_into Prefer 忠实读槽，非 reader 误线。
- Prefer／调度：
  - `same_kind`＠`0x140453aaf`：比较 **kind ARG（r9d）＝8** 才进 `equal_named`＠`0x140453322` — **不读 slot kind＠0**。
  - 故 type-ref 路径宣称 NAMED(8)，而 type-table slot 仍 kind0＋垃圾 name 字节亦可进 equal_named。
  - `init_named_at`＠`0x1402A9CA1`（写 kind＝8＠0、len＠0x84、memcpy name→+4）：min_A_val 上仅观察到 path-builder 调用点 `0x140647a67`；parser／type 侧调用点（`0x1405c9040`／`0x1405ca62a`／`0x1405cb803`／`0x1405d6a57` 等）**未命中** → struct `A` **未**经 init_named 入槽。
- 对照：name_into／init_named／same_kind／equal_named 与 Soft Cap **结构对齐**；无 tip-peel e9；force name_into／always-eq＝假绿禁入（11.69 已证）。

## 修

- **无 PE 修**；未 Soft Cap 混 tip；未动 11.59–11.67 plants；未回滚 wrap；PE 仍 `059417e5…`。

## 验收

- gate70 HOLD exit2（A_val／*A／context 仍红）；nested＝0 不 regress；XP008／ctx_ptr 仍红；P012 未新开；L2 1/5＠`58e34910f`。
- 移交 **11.71** DIG：为何 struct／NAMED 注册路径跳过 `init_named_at`（kind-arg8 vs slot-kind0）。

## Residual（移交 11.71）

- type-ref kind ARG＝8 进 equal_named，但 type-table slot 未 init_named（kind0＋`)/ ` 垃圾名）→ A_val／`*A`／ctx_ptr／cast／field T001；hello XP008／context 同残；PE `059417e5…`；L2 1/5＠`58e34910f`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿／CloudAgent；force equal_named／force name_into 入 tip；升钉／tiphead；CheckSubscriptionUsage 空转；`_dig` 入 git。
