# DIG SoftCap parent kinded `elem` 构造／`@5d276c`／`@20a948` fill 调用方 → Capless `+0x478`

**2026-10-30 ~17:10 CST Asia/Shanghai** · tip `570820caa`（本拍前）· Isol alt_frame2 `9378df517f96` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop / CloudAgent.

## 0) Gate
- Prior（`dig_mk_emitarg.md`）：Isol 有 fill `@1f9619` 族／consume `@205068`；Capless 零触及；写 `+0x478`＝`@2a5410`＋`@2a4f6a` 理论链、无调用点；plant 不可隔离。
- 本拍问：parent kinded `elem` 谁造；`@5d276c`／`@20a948` 谁调 fill；能否 **单点** 接到 Capless `+0x478`。

## 1) Parent kinded `elem` 谁造

| API／路径 | 角色 |
|---|---|
| `@1f70cf` | ensure kinded on parent（`rcx=parent`） |
| fill-fam `@1f9xxx`/`@1faxxx`/`@207xxx` | 内调 ensure＋写 `[slot+0x100]` |
| `@1fb*`/`@1fd*`/`@1ff*`/`@200*`/`@202*`/`@203*` | 同族 kinded 子系统 ensure 调用方（31 OUTSIDE fill-fam） |
| SoftCap-reachable | **仅** SoftMega-ish `@58f80f`／`@59447a` → `@1ff5c7` → ensure |
| Capless | **零** 直调 ensure／fill |

`@1ff5c7`：ensure＋`@1fe37d`＋`@1ff36f`；**返回 eax status**（调用方 `cdqe`／`setle`）；**无** fill／unwrap／push；所在 fn **无** `0x478` disp。  
⇒ SoftCap 能碰到 ensure，但 **不** 产出 `@205068`-兼容 filled emit-arg，也 **不** 写入 Capless `+0x478`。

## 2) `@20a948` fill 包装

- 入口族 `@20a948`／`@20a98a`…：薄包装 → `@1f9619`／`@1f9768`。
- **E8 callers = 0**；ImageBase `0x14020a948` 等 **data-refs = 0** → **死代码**。
- 无法「钩现有调用方」单点接到 Capless；从 Capless 新调＝自备 elem＋buf＋size＝mega／arg-loop（禁）。

## 3) `@5d276c` fill 调用方

- `@5d276c` **确实** fill：`@5d29a4→@1f9619`／`@5d2c53→@1f9768`（另 `@2059*`／`@206*` 辅助）。
- 调用链：`@5cf8f6→@5d2c98→@5d276c`；`@5cfa07→@5d2eb0→@5d276c`。
- 尾部写 `[rdx+0x124]` via `@205b5c` —— **编码器子系统**，≠ Capless SoftCap lit CallExpr。
- SoftCap／Capless 上溯：**无**。

## 4) Capless 已调 kinded 邻域 vs fill 链

Capless E8→`0x1f6–0x210`／`5d`：`@1ff2ef`（num_args；副作用 ensure）、`@20cd98`、`@201d9f`／`@200ff7`／`@201eeb`／`@201f36`…（多经 `@1fe37d`；部分 `@63b200` memcpy）。  
**∩ fill／`@2a5410`／`@2a4f6a`／`@205068`／`@20a948`／`@5d276c` = 0**（`@1ff2ef` 仅 ensure，非 fill）。

## 5) Plant
**不可隔离。** 无 `elem_fill`／`fill_5d`／`fill_20a` 单点；无 `p_ret_*`。  
死包装／错子系统／ensure≠filled emit-arg；拼满链＝mega／arg-loop（禁）。

## 6) Next single-point
Capless 已在路上的 `@1ff2ef`（ensure 副作用）／`@201eeb|@201f36`（`@63b200`）：其 parent／slot **是否已是** SoftCap lit 可用的 kinded 容器，能否 **单点** 把结果接到 `+0x478`（或证伪「Capless 父对象根本无 kinded slot」）。禁 tip@121278／join／epi／LIVE／mega／arg-loop。未绿勿收刀／勿升 PROD／钉。

## 7) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`；脚本＋log `_dig/dig_elem_fill_callers{,2,3,4}.py`／`.log`；无新 Win 跑；PROD／钉未动。
