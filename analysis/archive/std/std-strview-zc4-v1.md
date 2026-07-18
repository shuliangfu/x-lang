# STD-016 std.string StrView 与 ZC-4 深度整合 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`tests/run-zc4-gate.sh`、`analysis/zc-semantics`（ZC-4 层）

---

## 1. 目标

统一 **StrView 零拷贝视图**与 **ZC-4**（Arena64 / SSO_STACK / subview）的 API 与**生命周期契约**，供 std/fs/path/json 等模块选型。

验收：**生命周期文档** + **manifest gate** + **整合烟测**（`view_lifecycle.x`）+ 复用 ZC-4 烟测。

---

## 2. StrView 模型

| 字段 | 含义 |
|------|------|
| `ptr` | 只读字节起始地址（不拥有内存） |
| `len` | 有效字节数 |

**不分配堆**；所有 `string_view_*` 只读操作零拷贝。

---

## 3. 生命周期规则（v1）

| 来源 | 有效区间 | 禁止 |
|------|----------|------|
| **栈缓冲** `string_view(&buf[0], n)` | `buf` 所在栈帧 | 返回上层后使用视图 |
| **String** `string_view_from_string(s)` | `*s` 存活且未 `append/clear/replace` | 修改 `s` 后仍读旧视图 |
| **StackStr** `stack_str_view(s)` | `s` 所在栈帧 | 栈变量离开作用域后使用 |
| **Arena64** `string_view_concat_arena` | `arena64_deinit` 之前 | deinit 后读 concat 结果 |
| **fs mmap / read 缓冲** | 映射/缓冲释放前 | unmap/free 后使用 |

子视图 `string_view_subview` **不延长**父视图生命周期；父失效则子失效。

---

## 4. ZC-4 API 地图

| API | ZC 层级 | 说明 |
|-----|---------|------|
| `string_view` | ZC-4 | 包装已有 `(ptr,len)` |
| `string_view_from_string` | ZC-4 | String → StrView（STD-016） |
| `string_view_subview` | ZC-4 | 零拷贝切片 |
| `string_view_concat_arena` | ZC-4 | Arena bump 拼接（无 per-concat heap） |
| `stack_str_view` | ZC-4 | SSO_STACK 32B → StrView |
| `string_data_ptr` + `string_len` | ZC-4 | String 零拷贝输出（与 from_string 同契约） |

---

## 5. 验收

- manifest：`tests/baseline/std-strview-zc4.tsv`
- 烟测：`tests/string/view_lifecycle.x` + ZC-4 三件套（subview / arena / SSO）
- 门禁：`tests/run-std-strview-zc4-gate.sh`（`SHUX_STD_STRVIEW_ZC4`）
- 深度回归：`tests/run-zc4-gate.sh`（runnable 时）

---

## 6. 演进

- 与 TYPE-002 region 域整合后，栈/Arena 生命周期可类型化约束。
- `StrView` 携带 provenance 元数据（arena 句柄）待语言能力就绪。
