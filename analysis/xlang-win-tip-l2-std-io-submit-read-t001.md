# Win tip L2 std.io submit_read T001（刀 11.74）· **DIG residual HOLD**

> Gate：`tests/run-win-tip-l2-std-io-submit-read-t001-gate.sh`（HOLD exit2）。
> Beat（建议更准名）：`win_tip_l2_import_module_enum_dot_t001`（OPEN 名 `win_tip_l2_std_io_submit_read_t001`）。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；保绿 gate73＋72／71／67／63–55。
> tip PE **`3dd483308a46…`**（`xlang_asm.exe`；无本刀 PE 修）。
> 禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／回滚 11.67 wrap／升钉。

## DIG（诚实根因）

- 表象：直接 tip `check std/io/mod.x` → **T001** `no impl for type with method submit_read`；`driver.submit_read()` 不可解析；fn `#4 read` XT001。hello／fmt／`io.write_stdout` 路径仍绿。
- 缩小：`const driver = import("std.io.driver"); return driver.driver_read_ptr_len();` 同款 T001（非 submit_read 特例）。
- **对照**：`import("std.io.core").xlang_io_submit_read(...)` tip **EXIT0**；自包含无 enum 模块 `lib.foo()` tip／Soft Cap Prefer **EXIT0**。
- **真残钉死**：被 import 的模块内只要存在 **`enum`／`export enum`**，调用方 `import_alias.fn()` 被走 **method_call／trait-impl** 路径 → T001；模块单独 `check` 仍 EXIT0。
  - `only_fn`：绿
  - `+ export struct Buffer`：绿
  - `+ enum`／`export enum`（1～4 变体）：**T001**
  - Soft Cap Prefer `09fe` **同款 T001**（只读对照；≠混 tip；Prefer 非绿 oracle）
- `std/io/driver.x` 含 `export enum IO_Result` → 解释 mod.x／凡 `driver.*` 调用 T001。
- **无 tip-peel e9 靶**；与 Prefer 同残 → **无 tip-only PE inject 产品修**（禁假绿／禁删 enum）。

## Residual HOLD

- 真残＝**import 模块含 enum → 模块点号调用误 method_call**；submit_read 为表象。
- **无 PE 修**；PE 仍 `3dd483308a46…`；闸位 HOLD；**勿假绿**。
- Soft Cap Prefer 同残；禁升 Soft Cap／钉／tiphead／Cap tip。
- 移交下一刀须经理另开（enum／module.dot typeck 根修，非本刀 tip PE）。

## 验收（本刀）

- DIG＋gate 入仓；gate HOLD exit2（enum fixture T001；only_fn 绿；PE 未改）。
- 保绿：gate73 仍可跑（本刀不改 PE）。
- hello tip `check` 仍 EXIT0（不 regress 11.73）。
- L2 1/5＠`58e34910f` 未抬分宣称；**勿自 CLOSE**。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿（删 driver enum／改 std 源冒充绿）；CloudAgent；`_dig` 入 git；勿自 CLOSE；勿开 11.75。
