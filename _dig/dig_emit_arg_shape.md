# DIG SoftCap emit-arg 元素形态／retarget 已填容器／单次 emit+push E8

**2026-10-30 ~17:00 CST Asia/Shanghai** · tip `fb8ecf0e1` · Isol alt_frame2 `9378df517f96` · LIVE `lab_LIVE_pret.exe`（DIG 对照 only）· PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Prior：push helper **不在** LIVE Capless-iso／**不在** 另一 Isol Cap `+0x478`；LIVE 绿＝Cap21c8 旁路；Capless 4×`@1ff2ef` 仅闸；**无** fill E8；plant 不可隔离整 push 环。
- 本拍问：emit-arg 元素该长什么样；能否 retarget `+0x478`→已填 `@2a62c9`-兼容容器；或单次 Isol-native emit+push E8 进 `+0x478` 使 len≥1 且保 call-mk。

## 1) DIG — emit-arg 元素形态（`@2a5ca8` 取出后谁消费）

### 1.1 `@2a5ca8` get-elem 管道
| step | RVA | role |
|---|---|---|
| unwrap container | `@2a5410` | 0x568-class → inner handle |
| inner field | `@2a52c7` | 取 vec 对象 |
| bounds | `@2a4750` | vec len |
| slot | `@2a4ec1` | 第 idx 槽（stride=`@2a47a4`→field2 via `@21b94b`） |
| decode ptr | `@21b5fa` | base-256 解出 **对象指针** |
| kind gate | `@23030e` | kind＝`@215c68`；须 **>0** 才返回该对象 |

返回值＝**运行时对象指针**（非 AST `i32` expr_ref；非 sidecar grow_vec 槽）。

### 1.2 pre_last 消费者 `@205068`
- 入参：`rcx=elem`，`edx=sub_idx`，`r8=buf`，`r9d=size`（1..255）。
- `@20374e(elem, sub_idx)` 取 kinded-slot；要求 `[slot+0x100] == size`；再 `@63b1e8` 拷进 buf。
- ⇒ emit-arg 元素＝带 **kinded 子槽＋`+0x100` size** 的描述符对象；SoftCap lit 单 imm 也须此形态，才进 imm→rdx 源。

### 1.3 AST sidecar **不兼容**
- `pipeline_expr_call_arg_ref` → **i32**（`W327_SC_EXPR_CALL_ARG_REFS` grow_vec）。
- 与 `@2a62c9`／`@2a5ca8` 期望的 0x568 内嵌对象-vec **异形**。盲 `node+offs`／sidecar 指针 retarget 已红（`fill_args_ast*`）。

## 2) DIG — retarget 已填容器？**否**

| 探针 | 结果 |
|---|---|
| Isol 全仓 `mov edx,0x568` | **仅** Capless `@576624`（空 alloc→`+0x478`） |
| Capless `+0x478` STORE | **仅** `@576631`／null fallback `@576647`；其后零 mutate |
| Capless 调 `@2a62c9`／`@2a5ca8`／`@2a4f6a`／`@2a4a37`／`@2a4b48` | **全 0** |
| 其它帧槽（`+0x460`＝`0x10` alloc 等） | 尺寸类 ≠ 0x568；非 `@2a62c9`-兼容 |
| LIVE Cap21c8 对照 | buf emit；**无** `0x568`／`+0x478`（旁路，禁移植） |

⇒ Capless 内 **无**「已填且兼容」的容器可单点 `mov [rbp+0x478],…` 替换空壳。

## 3) DIG — 单次 Isol-native emit+push E8？**无**

| API | 事实 |
|---|---|
| `@2a4f6a` | 对 **inner vec** grow 空槽＋`set_len+1`；**不**接收 CallExpr／expr_ref；**不**构造 `@205068` 描述符 |
| `@2a4a37`／`@2a4b48` | 通用 vec init（edx=stride）；调用点 `@2b2xxx` 用 `0x214`／`0x4c8`／`0x5c` 等，**无** 0x568 SoftCap lit args |
| num_args_at `@1ff2ef` × push `@2a4f6a` | **无**同窗（±0x800）共现；无 `fill(+0x478, CallExpr)` 单 E8 |
| Capless | 零 push／init／len／get-elem E8 |

⇒ 缺的是 **「AST arg → `@205068`-兼容对象」构造＋写入 0x568 inner」** 的 glue；现成单 E8 不存在。禁拼 arg-loop／LIVE Cap21c8。

## 4) Plant
**不可隔离。** 本拍无 `emit_push`／`retarget_filled` plant；无 `p_ret_*` 跑。Frontier 仍红。

## 5) Next single-point
Isol-native：**谁构造 `@205068`-兼容 emit-arg 对象**（kinded＋`+0x100` size；SoftCap lit imm／expr_ref→该对象），再单点写入 `+0x478` 的 inner（经 `@2a5410`／`@2a4f6a` 或等价 slot store）使 `@2a62c9` len≥1→`@2a5ca8`＋保 call-mk（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 6) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe` + LIVE DIG 对照；无新 Win 跑；PROD／钉未动。
