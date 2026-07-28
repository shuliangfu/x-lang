# Name-gate → typeck 标志位迁移设计

> **日期**：2026-07-28
> **状态**：设计草案（不实现，自举后落地）
> **目的**：消除 `async_cps_callee_is_io` 字符串表脆弱性，迁移到 typeck 标志位识别 IO await。
> **关联**：[全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §3.4 G-name-gate · [async-language-debt.md](async-language-debt.md) L-name-gate

---

## 0. 一句话结论

当前 `async_cps_callee_is_io`（[async_cps_codegen.x:89](file:///Users/shuliangfu/worker/xlang/x-lang/compiler/src/async/async_cps_codegen.x)）靠逐字节匹配函数名识别 IO await，脆弱且无法区分"用户函数恰好叫 read"与"真 IO"。本设计迁移到 typeck 标志位（`is_io_await` 属性），自举期不实现，只定迁移路径与共存策略。

---

## 1. 现状

### 1.1 name-gate 实现

**文件**：`compiler/src/async/async_cps_codegen.x`

**函数**：
```xlang
#[no_mangle]
export function async_cps_callee_is_io(callee: *u8): i32 {
  let name: *u8 = async_cps_load_func_name(callee);
  if (name == 0) { return 0; }
  // 逐字节匹配：shux_io_ / read / write / submit_read / submit_write / ...
}
```

**调用点**：
- `async_cps_codegen.x:697` — `async_cps_await_is_io` 调用
- `async_liveness.x:69` — `async_liveness_callee_is_io_read` 类似 name-gate

### 1.2 问题

| 问题 | 影响 |
|------|------|
| 字符串匹配脆弱 | 重命名 IO 函数会静默破坏 await 识别 |
| 无法区分同名用户函数 | 用户函数叫 `read` 会被误识别为 IO |
| 新增 IO 函数需手动追加 | name-gate 表维护成本高 |
| 跨模块扩展脆弱 | 每个新 Io 后端方法都要改 name-gate |
| 阻塞 T\* Io 注入 | 新 `io.read()` / `io.wait()` 方法名不在表内 |

---

## 2. 目标态：typeck 标志位

### 2.1 设计

在 typeck 阶段为函数标记 `is_io_await: bool` 属性：

```xlang
// typeck 阶段（语义分析）标记
struct FuncTypeckInfo {
  // ... 现有字段
  is_io_await: i32;  // ← 新增：1=IO await 目标，0=普通函数
}
```

### 2.2 标记规则

typeck 在解析 await 表达式时，按以下规则标记 `is_io_await`：

| 规则 | 标记 |
|------|------|
| 函数声明带 `#[io_await]` 属性 | `is_io_await=1` |
| 函数签名匹配 Io trait 方法（见 [async-io-trait-RFC.md](async-io-trait-RFC.md)） | `is_io_await=1` |
| 函数名在 name-gate 表内（过渡期回退） | `is_io_await=1` |
| 其他 | `is_io_await=0` |

### 2.3 codegen 使用

```xlang
// async_cps_codegen.x 替换
export function async_cps_callee_is_io(callee: *u8): i32 {
  // 阶段 1: 优先查 typeck 标志位
  let info: *FuncTypeckInfo = async_cps_load_func_typeck_info(callee);
  if (info != 0 && info.is_io_await == 1) {
    return 1;
  }
  // 阶段 1 回退: name-gate 字符串表（过渡期）
  return async_cps_callee_is_io_name_gate_fallback(callee);
}
```

---

## 3. 迁移路径

### 3.1 阶段 0（自举期，不实现）

- 落本设计（接口形状与共存策略）
- **不动** `async_cps_callee_is_io`（产品链依赖）
- 文档：标注 name-gate 为"过渡期实现，T\* 阶段 1 替换"

### 3.2 阶段 1（自举收尾期，L-usable）

1. typeck 新增 `is_io_await` 字段
2. typeck 在 `#[io_await]` 属性函数上标记 `is_io_await=1`
3. codegen `async_cps_callee_is_io` 优先查 typeck 标志位，回退 name-gate
4. **共存期**：name-gate 不删，作 fallback
5. 现有 IO 函数加 `#[io_await]` 属性

### 3.3 阶段 2（L-inject）

1. Io trait 方法自动标记 `is_io_await=1`（见 [async-io-trait-RFC.md](async-io-trait-RFC.md)）
2. 新增 `io.read()` / `io.write()` 等方法名不在 name-gate 表内，靠 typeck 标志位识别
3. name-gate 表不再扩展

### 3.4 阶段 3（L-full）

1. 删除 `async_cps_callee_is_io` 的 name-gate fallback
2. 删除 `async_liveness_callee_is_io_read` 等同类 name-gate
3. 完全靠 typeck 标志位

---

## 4. 共存期纪律

| 项 | 规则 |
|----|------|
| 新增 IO 函数 | 必须加 `#[io_await]` 属性，**不**依赖 name-gate |
| 现有 IO 函数 | 阶段 1 补 `#[io_await]` 属性 |
| name-gate 表 | 只读，不扩展 |
| typeck 标志位 | 优先；缺失时回退 name-gate |
| 测试 | 共存期跑 `run-async.sh` 确保无回归 |

---

## 5. 与 Io trait 的关系

阶段 2 Io trait 落地后，typeck 自动识别 Io trait 方法为 `is_io_await=1`：

```xlang
// typeck 伪代码
if func.implements_trait(Io) && func.name in Io.methods {
    func.is_io_await = 1;
}
```

**关键**：name-gate 是"按名字猜语义"；typeck 标志位是"按类型知语义"。后者是 T\* 的必要条件。

---

## 6. 风险

| 风险 | 缓解 |
|------|------|
| typeck 标志位遗漏 | 共存期 name-gate fallback 兜底 |
| `#[io_await]` 属性漏标 | 阶段 1 集中补标 + 测试覆盖 |
| 迁移破坏现有 async | 共存期 + `run-async.sh` 回归锚 |
| typeck 改动砸 bootstrap | 阶段 1 在自举收尾期做，L4 验证 |

---

## 7. 不做项（本阶段）

- 不动 `async_cps_callee_is_io`（产品链依赖）
- 不加 `#[io_await]` 属性（依赖 typeck 改动）
- 不删 name-gate 表（共存期 fallback）

---

## 8. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：name-gate 现状、typeck 标志位设计、共存策略、迁移路径 |
