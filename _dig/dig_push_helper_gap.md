# DIG Capless push-into-`+0x478` helper 缺口（何处／何缺）

**2026-10-30 ~16:57 CST Asia/Shanghai** · tip `bbde58e57` · Isol alt_frame2 `9378df517f96` · LIVE `lab_LIVE_pret.exe` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Prior：AST args＝W327 `+0x274`/`+0x270`+sidecar；Capless 仅空 `@55d730(0x568)`→`+0x478`；`fill_args_ast*` 废。
- 本拍问：缺失的 push helper **在哪**（LIVE SoftCap？另一 Cap path？）；`num_args_at`／`arg_ref`→emit-arg 缺口；可否单点 plant。

## 1) DIG — helper 不在 LIVE Capless-iso，也不在另一 Isol Cap 的 `+0x478`

### 1.1 LIVE SoftCap Capless-iso ≅ Isol Capless（同空壳）
| | Isol Capless | LIVE Capless-iso |
|---|---|---|
| `mov edx,0x568` | `@576624`→`@55d730` | `@29686c`→`@2818c1` |
| STORE `+0x478` | `@576631`／null `@576647` | `@296879`／null `@29688f` |
| SoftCap-site | `@2be519`（r9=`+0x460`） | `@28e9c0`（r9=`+0x460`） |
| `+0x478` 引用 | STORE×2 + LOAD `@578200`→pre_last | STORE×2 + LOAD `@298448` |
| imm `0x274` in frame | **0** | **0** |

⇒ LIVE SoftCap **Capless 路径同样从不 push**。禁 LIVE SoftCap 移植也不会从 Capless-iso 抄到 fill 环。

### 1.2 LIVE 真 emit＝Cap`@0024e6` kind`0x30`→Cap21c8 `@0021c8`（旁路 Capless）
- Cap21c8：`rcx=node`／`edx=idx`／`r8`／`r9=buf`；**无** `0x568`／`+0x478`／`0x274`；直接写 buf。
- Isol tip SoftCap＝**Capless-only**（无 Cap`@0024e6` 类 `push;sub rsp,0x180`＋kind`0x30`）。
- ⇒ LIVE 绿靠 **另一 dispatch**，不是「Capless 内已有 push helper」。禁移植该树。

### 1.3 Isol 其它 `[rbp+0x478]` STORE ≠ SoftCap lit args 容器
- `@4d84b4`：从 `[rbp+0x568]+0x800458` **spill 保存／恢复**，非 `@55d730(0x568)` args 容器。
- `@465f8e`：非有效 Capless 同构（无 `0x568` alloc 邻域）。
- SoftCap lit 唯一 args 容器 STORE＝Capless `@576631`。

### 1.4 Capless **已调** `num_args_at`，但只做闸，不 push
- Isol `@1ff2ef`＝`pipeline_expr_call_num_args_at`（`[node+0x274]`）。
- Capless STORE→LOAD 间 **4×** E8 `@1ff2ef`（`@57698f`／`@577539`／`@577b0a`／`@577c47`）：结果进局部闸（≥0／≤`0x60`／spill 计数），**零**写入 `+0x478`。
- `@200ff7` 一次：读其它字段闸，非 fill。
- 全仓 `mov rcx,[rbp+0x478]`→call：**仅** `@578200`→pre_last `@567a30`。**无** `fill(container, CallExpr)` E8。

### 1.5 缺口钉死（num_args／arg_ref→emit-arg）
应有环（Capless `@576631` 后、pre_last 前）：

1. `n = num_args_at(arena, CallExpr)` — accessor **已在**（`@1ff2ef`），Capless 已会调但未接到容器；
2. `arg_ref(arena, CallExpr, i)` — Isol 有 sidecar 路径（`@1fed89`／`@1ff101` 一带）；
3. 将每个 AST arg **转成** `@2a5ca8` 可消费的 emit-arg 元素；
4. **push** 进 `[rbp+0x478]` 的 `0x568` 对象（使 `@2a62c9` len≥1）。

**缺的是 3→4 的组合 glue／单 helper**，不是缺 num_args 符号。LIVE Cap21c8 用另一 ABI 完成等价 emit，不经此容器。

## 2) Plant
**不可隔离。** 完整 push 环不可塞单点 cave；无现成 `fill(+0x478, CallExpr)` E8 可劫持；LIVE Cap21c8／arg-loop **禁**。本拍无 plant／无 `p_ret_*` 跑。

## 3) Next single-point
Isol-native：**emit-arg 元素形态**（`@2a5ca8` 取出后谁消费／何大小）＋是否存在「已填的 `@2a62c9`-兼容容器」可在 Capless 内 **retarget** `+0x478` 指针（单点 mov，禁 LIVE／mega／arg-loop）；或定位单一 `emit_one_arg+push` 对可 E8 一次（SoftCap lit 单 imm）。

## 4) Evidence
静态 Capstone：Isol `xlang_isol1060_alt_frame2.exe` + LIVE `lab_LIVE_pret.exe`；无新 Win 跑。
