# DIG SoftCap Isol-native `@205068`-兼容 emit-arg 构造／写入 Capless `+0x478` inner

**2026-10-30 ~17:05 CST Asia/Shanghai** · tip `b70d21231` · Isol alt_frame2 `9378df517f96` · LIVE `lab_LIVE_pret.exe`（DIG 对照 only）· PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Prior：emit-arg＝运行时对象（`@21b5fa`＋kind>0；`@205068` 要 kinded `+0x100` size）；retarget 已填容器 **否**；单次 emit+push E8 **无**；Capless 空壳 `+0x478`；LIVE 绿＝Cap21c8 旁路。
- 本拍问：谁／哪条 Isol-native 路径构造 `@205068`-兼容 kinded emit-arg；如何写入 Capless `+0x478` inner。

## 1) DIG — `@205068` 消费／kinded 布局（复证＋加深）

| API | 角色 |
|---|---|
| `@205068` | 消费：`rcx=elem`，`edx=sub_idx`，`r8=buf`，`r9d=size`；经 `@20374e` 取 slot；要求 `[slot+0x100]==size`；`@63b1e8` 拷出 |
| `@20374e` | kinded-slot getter：`[elem+0]` 计数 → `@1f77e1` 表 → `@1f61f7(table+0x10, idx)`→slot |
| `@1f9619`／`@1f9768`／`@1f99b2`／`@1fa9d9` | **fill**（buf→slot）：`@1f70cf` ensure＋`@1f93e3` 取／建 slot，写 `[slot+0x100]`＋`@63b200` |
| `@207462`／`@20760b`／`@207aef` | 同族 HELPER fill（读已有 `[+0x100]` 再调 fill） |

⇒ Isol **有** kinded fill／consume API；**不是** AST sidecar／裸 imm。

## 2) DIG — Capless **零** 触及构造／fill／push

Capless `@576000`..`@578280` E8 ∩ 关键 API：

| API | Capless 命中 |
|---|---|
| `@205068`／`@20374e`／`@1f9619` 族／`@1f70cf` | **0** |
| `@2a4f6a` push／`@2a5ca8` get-elem／`@2a5410` unwrap | **0** |
| 已知 | 仅 `num_args`×4／`name_lookup`×1／SoftCap-site×1／`alloc`×2／`pre_last`×1 |

Capless `[+0x100]`「命中」`@576ec3`＝**伪阳性**（data／对齐垃圾，非 store）。

## 3) DIG — 谁构造？**fill 族＋parent ensure；不在 SoftCap Capless**

1. **Fill-builders**（写 kinded `+0x100`）仅 7 fn：`@1f9619`／`@1f9768`／`@1f99b2`／`@1fa9d9`／`@207462`／`@20760b`／`@207aef`。
2. 其调用点：`@20a948` 薄包装、`@5d276c`／`@36xxxx`／`@39xxxx` 等 — **均非** Capless SoftCap lit CallExpr 路径。
3. Parent ensure `@1f70cf` 调用方全集中在 `@1f9xxx`/`@1faxxx`/`@1fcxxx` 同族 — **无** Capless／无 SoftCap lit CallExpr。
4. `C7 [+0x100], imm∈1..255` 全仓仅 3 处（`@44d5ea` imm=1 等）— **非** SoftCap lit 工厂；`@55d730`→size store 窗内 **0**。
5. 真 `0x568→@55d730` 仅 **2**：Capless 空壳 `@576624`；另 `@59c3a2` 进 `@58e9a0` 帧 — **≠** SoftCap args 容器、不可 retarget `+0x478`。

⇒ **Isol-native SoftCap Capless 路径不构造 `@205068`-兼容 emit-arg。** 构造／fill API 存在于其它子系统，与 Capless `+0x478` **无边**。

## 4) DIG — 如何写入 `+0x478` inner？**理论链有、Capless 无调用点**

应有链（均已存在为独立 API，Capless **从未**串）：

1. 构造 parent kinded `elem`（`@1f70cf`／同族；SoftCap lit **无** Isol 调用方）
2. fill slot：`@1f9619`(elem, sub_idx, buf, size) 使 `[slot+0x100]==size`
3. unwrap 0x568：`@2a5410` → inner vec（调用方全在 `@2a5xxx`–`@2a7xxx`）
4. push：`@2a4f6a`(inner) 使 `@2a62c9` len≥1

Capless 只做步骤 0：`@55d730(0x568)` STORE `+0x478`，其后零 mutate。  
**无** 单 E8／单 cave 可劫持的 `mk_emitarg`／`kinded_push`；拼 1–4＝mega／arg-loop（禁）。LIVE Cap21c8 旁路（禁移植）。

## 5) Plant
**不可隔离。** 无 `mk_emitarg`／`kinded_push` plant；无 `p_ret_*` 跑。Frontier 仍红。

## 6) Next single-point
Isol-native：**谁构造 SoftCap lit 可用的 parent kinded `elem`**（`@1f70cf`／`@205068` 的 rcx）— 或 `@5d276c`／`@20a948` 等 fill 调用方是否已有「填好的 emit-arg 对象／vec」可 **单点** 喂入 Capless `+0x478`（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。未绿勿收刀／勿升 PROD／钉。

## 7) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`；脚本 `/tmp/dig_mk_emitarg{,2,3,4}.py`＋log；无新 Win 跑；PROD／钉未动。
