# DIG SoftCap Capless `@1ff2ef`／`@201eeb|@201f36` parent／slot → `+0x478` 单点？

**2026-10-30 ~17:15 CST Asia/Shanghai** · tip `da135b3e8`（本拍前）· Isol alt_frame2 `9378df517f96` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop / CloudAgent.

## 0) Gate
- Prior（`dig_elem_fill_callers.md`）：`@20a948` 死；`@5d276c` 编码器≠Capless；SoftCap ensure→status 非 emit-arg；Capless 零 fill；plant 不可隔离。
- Frontier＝Capless 已调 `@1ff2ef`／`@201eeb|@201f36` 父／slot 能否 **单点** 接 `+0x478` 填充（`@2a62c9` len≥1＋保 call-mk）。

## 1) Capless 调用现场（rcx 父）

| 目标 | Capless E8 | rcx | 其它 |
|---|---|---|---|
| `@1ff2ef` | `@57698f`／`@577539`／`@577b0a`／`@577c47` | `[rbp+0x490]` CallExpr | edx=`[rbp+0x4a0]` |
| `@201eeb` | `@576d85` | 同 CallExpr | edx=`[rbp+0x468]`；kind闸 `0x2c` |
| `@201f36` | `@576f5e` | 同 CallExpr | edx=`[rbp+0x424]`；r8=`[rbp+0x60]` buf |

时序：`+0x478` **空壳** STORE `@576631`（`@55d730(0x568)`）**早于** 上述调用；至 `@578200` load→call-mk 间 **零** `+0x478` mutate。

## 2) `@1ff2ef`：闸＝num_args；**无** ensure 副作用（纠先验）

Capless-reachable CFG（入口 `@1ff2ef`→ret `@1ff32e`）：
- **仅** E8→`@1fe37d`；读 `[obj+0x274]`→eax；**ensure `@1f70cf` ∉ 路径**。
- ensure 在 **sibling** `@1ff36f`／`@1ff5c7`（SoftMega-ish 用），≠ Capless 所调入口。
- 返回后 Capless：`mov [local],eax`＋`cmp/jcc` 或喂 `@22424f` 计数；**从不** fill／unwrap／push／碰 `+0x478`。

⇒ 「`@1ff2ef` ensure 副作用可接 fill」**证伪**（Capless 路径无 ensure）。

## 3) `@201eeb`／`@201f36`：字段 memcpy／size 闸；**≠** kinded slot／`+0x478`

| API | 角色 | chain∩fill／push／unwrap |
|---|---|---|
| `@201eeb` | `@1fe37d`→kind`0x2c`？→`[+0x14c]`；另 `@63b200` **r8d=0x100＝拷贝长度** | **0** |
| `@201f36` | buf 零填 size`0x100` 或 `memcpy(buf, node+0x20, [+0x120])` | **0** |

`0x100`＝memcpy **size 常量**，**不是** kinded `[slot+0x100]`。  
输出＝栈 buf／节点字段，**不是** `@2a62c9` 兼容 vec；retarget 进 `+0x478`＝错 ABI。

## 4) Capless E8∩fill 带

`E8∩{fill／ensure／unwrap／push／@2a5410／@2a4f6a／@205068}`＝**仅** `@55d730` 空 alloc。  
`Capless→slot_apis(@20374e/@1f70cf/@1f93e3…)`＝**0**。  
无可劫持 E8；ensure→fill→unwrap→push＝mega／arg-loop（禁）。

## 5) Plant
**不可隔离。** 无 `slot_478`／`f36_push`；无 `p_ret_*`。  
父＝SoftCap lit CallExpr **有**，但：
- `@1ff2ef` 不 ensure、不产 filled slot；
- `@201*` 不写 kinded／不 push `+0x478`；
- 空壳 `+0x478` 与三闸 **无边**。

## 6) Next single-point
Isol-native：**是否存在** SoftCap lit 已走通、能产出 `@2a62c9`-兼容 **已填 vec** 的单点（或单 E8 fill+push），**不**经 Capless mega 胶；否则证伪「Isol SoftCap lit 根本无已填 args 容器可接」。禁 tip@121278／join／epi／LIVE／mega／arg-loop。未绿勿收刀／勿升 PROD／钉。

## 7) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`；`_dig/dig_slot_478.py`＋`.log`；无新 Win 跑；PROD／钉未动。
