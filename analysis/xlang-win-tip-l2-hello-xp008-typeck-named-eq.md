# Win tip L2 hello XP008 typeck named eq（刀 11.69）· **CLOSE residual HOLD**

> Gate：`tests/run-win-tip-l2-hello-xp008-typeck-named-eq-gate.sh`（HOLD exit2 until A_val／*A／context green）。
> Beat：`win_tip_l2_hello_xp008_typeck_named_eq`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.59–**11.68** 绿族／HOLD 勿 regress。
> tip PE **`059417e5772c…`**（unchanged；无 tip PE 修）。

## DIG（诚实根因）

- 矩阵（tip plant `059417e5…` vs Soft Cap Prefer 只读；dig-only probes ＠`/c/xlang_tmp/p1169`，**未入 tip PE／未入 git**）：
  - tip：`id(x:A):A`／`id(p:*A):*A`／cast `*A`／`ctx_ptr`／`min_ptr_field`／`nested_field`＝**FAIL**；diag A_val＝`expected  , found )`（空 type name）；field＝T001；`*i32`／nested size-only／gate67／63–61＝**OK**。
  - SC：上列全部 OK。
  - bak_pre_1167：A_val OK（alloc_dyn→TYPE_DYN）；其余 `*Named`／field 仍 FAIL（预存）。
- Locus Prefer：
  - tip `typeck_type_refs_equal_named`＠`0x140453322`；`same_kind`＠`0x140453aaf`；`equal_impl`＠`0x140453c29`；`type_refs_equal`＠`0x140453c91`。
  - tip `pipeline_type_named_name_into`＠`0x1402A9187`（len＠**0x84**／bytes＠**+4**／max 0x40／cap 0xff）；writer `init_named` 同布局；TYPE_NAMED helper＠`0x1402b9b93`＝**8**。
  - tip `same_kind`：kind **8→equal_named**；kind **0x11(DYN)** 落 always-1 fallthrough（解释 bak A_val OK）。
  - SC `typeck_type_refs_equal_named`＠`0x14027ba63` 同构调 `pipeline_type_named_name_into`＠`0x140172070`。
  - tip scratch64＠`0x14047cc47` stride **shl 0x7 (128)** vs SC **shl 0x8 (256)**＝真实 ABI 漂移，但短名 `A` 非本刀根。
- Dig-only probes（假绿禁入 tip；证据用）：
  1. **equal_named→always1**：A_val／a_ptr／cast／ctx_ptr／gate **绿**；`min_ptr_field`／`nested_field` 仍 T001。
  2. **scratch stride 128→256**：无绿（且 tip BSS scratch 仅 0x800，不可诚实扩）。
  3. **name_into force "A"/len=1**：A_val／a_ptr／cast／ctx_ptr／**min_ptr_field**／gates **绿**；`nested_field` 仍 T001（强制同名破坏 Outer/Inner/field 名匹配）。
  4. **name_into 改读 len＠0**（非 0x84）：仍 FAIL（证实主路径确用 0x84）。
- **诚实根因**：A_val／`*A`／ctx_ptr／cast 失败＝`equal_named`←**`name_into` 返回空名**（slot＠0x84 len≤0）；field T001 大半为 empty-name／layout 级联（force name_into 可清 `min_ptr_field`）。11.67 wrap 保 NAMED 暴露了 tip 历史未走通的 named-eq／name 槽路径；bak DYN always-equal 掩盖。Prefer：reader／writer／same_kind 体与 SC **结构对齐** → 残在 **runtime name 槽数据／IDENT type-ref 入参**（非 e9 误线）。未见可注 tip-peel e9；force equal／force name＝**假绿**，禁入 tip。

## 修

- **无 PE 修**；未 Soft Cap 混 tip；未动 11.59–11.67 plants；未回滚 wrap；PE 仍 `059417e5…`。

## 验收

- gate69 HOLD exit2（A_val／*A／context 仍红）；gate67／63–61 OK；nested T001＝0 不 regress。
- 移交 **11.70** tip NAMED `name_into` 空槽／writer vs IDENT type-ref 入参。

## Residual（移交 11.70）

- tip NAMED name_len＠0x84 运行时空 → equal_named 空名；user-struct field 级联 T001；hello XP008／context 同残；PE `059417e5…`；L2 1/5＠`58e34910f`；P012 未新开。

## 非目标／禁

- Soft Cap G05 混 tip；回滚 11.67 wrap；假绿／CloudAgent；force equal_named／force name_into 入 tip；升钉／tiphead；CheckSubscriptionUsage 空转；`_dig` 入 git。
