# DIG SoftCap lit AST args field / push-into-`+0x478`

**2026-10-30 ~16:54 CST Asia/Shanghai** · tip `d1711fc86` · Isol alt_frame2 `9378df517f96` · `base_828` sha12 `0977d6fbb472` · lit sha `61afec45d7ff` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Prior plants `arglen_force1`／`fill_args_ast{18,20,28}` **红**（假 len／盲 node offs）。
- USER: call-mk **在**；**无** true imm→rdx。本拍 **无** 新 plant（不可隔离单点 push 环）。

## 1) DIG — AST args 字段钉死

### 1.1 SoftCap lit CallExpr args ≠ 裸 node 指针
源 `compiler/src/runtime_pipeline_abi_expr_sidecar_thin.x`：

| 常量 | 值 | 含义 |
|---|---|---|
| `W327_E_CALL_ARG_BASE` | **624 (0x270)** | CallExpr 节点上 arg 基索引 |
| `W327_E_CALL_NUM_ARGS` | **628 (0x274)** | CallExpr 节点上 arg 个数 |
| `W327_SC_EXPR_CALL_ARG_REFS` | **464** | sidecar grow_vec（全 arena call-arg refs） |

访问器：`pipeline_expr_call_num_args_at`／`pipeline_expr_call_arg_ref`（经 `w327_load`＋`w529_gv_at`）。

⇒ 盲猜 `node+0x18/20/28` **错误模型**；`fill_args_ast*` 红／AV 符合此 DIG。

### 1.2 Capless **从不**读 AST args、**从不** push `+0x478`
Isol Capless（`@576000`..`@57827f`）：

| 事实 | 证据 |
|---|---|
| `+0x478` 仅 STORE 空壳 | `@57662c` `@55d730(edx=0x568)` → `@576631` STORE；null fallback `@576647` |
| STORE→pre_last 间 **零** 其它 `+0x478` 使用 | 仅 `@578200` load→arg5 |
| Capless／`@2be519` **无** `[node+0x274]`／`+0x270` 字段读 | Capstone：Capless 仅栈 `[rbp+0x270]` 清零；`@2be519` 0 命中 |
| `@2be519` 入参 | rcx=CallExpr node；**r9=`+0x460`(0x10 alloc)** — **不**传 `+0x478` |
| Capless 无 E8 到 num_args／arg_ref 类填容器 | 无向 `+0x478` 的 mutate call |

### 1.3 pre_last 不补填
- `[rbp-0x30]` **唯一**写入＝arg5 初拷 `@567a60`（＝空 `+0x478`）。
- pre_last `@567a30`..`@568900`：**无** imm `0x274`／`0x270`；`@2a62c9` len=0 → 跳过 `@2a5ca8`。
- get-elem 成功后才进 `@23030e`／`@205068` 环产 arg 描述符；空容器永不到此。

### 1.4 根因（本拍结论）
1. SoftCap lit CallExpr **真 args**＝W327 **`+0x274`/`+0x270` + sidecar grow_vec**，非裸指针字段。
2. Capless 只 `@55d730(0x568)` **空 alloc** 进 `+0x478`，**缺失**「读 `num_args_at`／`arg_ref` → 转 emit-arg 描述符 → push 进 0x568」环。
3. 强制假 len／把 AST 裸 offs 塞进 `+0x478` **不可**变 USER（已红）。须 **语义 push**（或等价换成已填的 `@2a62c9`-兼容容器）。

## 2) Plant
本拍：**无** plant。完整 push 环不可塞进单点 27B cave；无现成「fill(container, CallExpr)」E8 可劫持。记录 N/A／红 frontier。

## 3) Next single-point
定位 Capless 侧（`@576631`..`@578200` 或应接 `+0x478` 的 `@2be519` 变体）**缺失的 push-into-`+0x478` helper**：读 `pipeline_expr_call_num_args_at`／`arg_ref`，把 SoftCap lit args 转成 `@2a5ca8` 可消费的 emit-arg 元素并 push；单点 plant 使 `@2a62c9` len≥1→get-elem＋保 call-mk（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 4) Scripts / notes
静态 Capstone on Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`（＋源 W327）；无新 Win 跑。
