# Future 泛型化 RFC

> **日期**：2026-07-28
> **状态**：设计草案（不实现，自举后落地）
> **目的**：为全面异步架构（T\*）的通用无染色库 API 设计 Future<T> 泛型化路径，消除当前 i32×64 静态槽限制。
> **关联**：[全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §3.4 G-future · [async-language-debt.md](async-language-debt.md) L-generic

---

## 0. 一句话结论

当前 Future 是 `i32×64 静态槽`（[future.x](file:///Users/shuliangfu/worker/xlang/x-lang/std/async/future.x)），无法承载指针/结构体/多类型返回，阻塞通用无染色库 API。本 RFC 设计 `Future<T>` 泛型化路径，依赖语言泛型能力（L-generic），自举期不实现，只定接口形状与迁移策略。

---

## 1. 现状

### 1.1 当前实现

**文件**：`std/async/future.x`

**结构**：
```xlang
allow(padding) struct XlangFutureSlot {
  state: i32;
  value: i32;  // ← 仅 i32
}

let g_xlang_futures: XlangFutureSlot[64] = [];  // ← 静态 64 槽
let g_xlang_future_count: i32 = 0;

export const XLANG_FUTURE_MAX: i32 = 64;
```

**API**（C ABI）：
- `xlang_async_future_create_c(): i64` — 创建，返回 handle（>0）
- `xlang_async_future_poll_c(handle: i64): i32` — 轮询（PENDING/READY）
- `xlang_async_future_complete_c(handle: i64, value: i32): void` — 完成（仅 i32）
- `xlang_async_future_take_c(handle: i64, out: *i32): i32` — 取值（仅 i32）
- `xlang_async_future_wait_c(handle: i64, max_rounds: i32): i32` — 等待
- `xlang_async_future_reset_c(): void` — 重置

### 1.2 限制

| 限制 | 影响 |
|------|------|
| value 仅 i32 | 无法返回指针/结构体/i64/u8[] 等 |
| 64 槽静态 | 超出 `XLANG_FUTURE_MAX` 直接返回 0（创建失败） |
| 全局单例 g_xlang_futures | 无法多实例隔离；测试不友好 |
| 无 cancel 集成 | Future 与 Context cancel 未联动 |
| 无组合子 | 缺 `join`/`select`/`race` 等 |

---

## 2. 目标态 Future<T>

### 2.1 接口形状（依赖 L-generic）

```xlang
// 泛型结构体（依赖语言泛型）
struct Future<T> {
  handle: i64;
  // 内部槽位由 Io 后端管理
}

// 泛型 API
function future_create<T>(): Future<T>;
function future_poll<T>(f: Future<T>): PollState;
function future_complete<T>(f: Future<T>, value: T): void;
function future_take<T>(f: Future<T>, out: *T): i32;
function future_wait<T>(f: Future<T>, max_rounds: i32): PollState;
```

### 2.2 多 payload 类型支持

| payload 类型 | 存储方式 |
|--------------|----------|
| `i32` / `u32` | 内联（当前方式） |
| `i64` / `u64` | 内联（扩展 slot.value 为 i64） |
| `*T`（指针） | 内联（指针大小） |
| `struct T`（小） | 内联（≤16 字节） |
| `struct T`（大） | 指针 + arena 所有权 |

### 2.3 动态扩容

- 槽位从静态 64 改为 arena 分配（已有 mmap-based 堆，NL-07 验证）
- 无上限（受内存约束）
- 每个 Io 后端可有自己的 Future 池

### 2.4 cancel 集成

```xlang
function future_cancel<T>(f: Future<T>, ctx: Context): i32;
// → 绑定 ctx，ctx cancel 时 future 也 cancel
// → 中止 in-flight Io（需 Io 层统一 cancel 契约）
```

### 2.5 组合子

| 组合子 | 语义 |
|--------|------|
| `future_join<T, U>(f: Future<T>, g: Future<U>): Future<(T, U)>` | 全部完成 |
| `future_select<T, U>(f: Future<T>, g: Future<U>): Future<T \| U>` | 任一完成 |
| `future_race<T>(futures: Future<T>[]): Future<T>` | 最先完成 |
| `future_map<T, U>(f: Future<T>, fn: Fn(T) -> U): Future<U>` | 映射 |

---

## 3. 迁移路径

### 3.1 阶段 0（自举期，不实现）

- 落本 RFC（接口形状）
- 落 `Future<T>` 空泛型骨架（依赖 L-generic，语言债）
- 保留当前 `XlangFutureSlot` 作 fallback

### 3.2 阶段 1（自举收尾期，L-usable）

- 扩展 slot.value 为 i64（支持 i64/u64/指针）
- 引入 arena 分配（动态扩容）
- 保留 64 槽静态作 fast path

### 3.3 阶段 2（L-inject）

- `Future<T>` 泛型落地（依赖 L-generic）
- 多 payload 类型支持
- cancel 集成
- 组合子（join/select/race/map）

### 3.4 阶段 3（L-full）

- 旧 C ABI `xlang_async_future_*_c` 降级为内部实现
- 用户面只暴露 `Future<T>` 泛型 API
- 删除 `XLANG_FUTURE_MAX` 静态限制

---

## 4. 与 Io/Executor 的关系

```
Io 后端 → 提交 IO 操作 → 返回 Future<T>
用户 → future_poll / future_wait / future_take
Io 后端 → complete(io_result) → Future<T> 就绪
```

**关键**：Future<T> 是 Io 后端与用户之间的契约，不是独立组件。Future 的存储与生命周期由 Io 后端管理。

---

## 5. 风险

| 风险 | 缓解 |
|------|------|
| 泛型语言债拖延 | 与 lang-generic 主线对齐，不另开 Future 项目 |
| 动态扩容引入内存碎片 | arena 分配，与 mmap-based 堆一致 |
| cancel 半吊子 | Io 层统一 cancel 契约 + 测试 |
| 组合子语义分叉 | 对齐 Rust/async-std 语义，不发明新语义 |

---

## 6. 不做项（本阶段）

- 不实现泛型 Future<T>（依赖 L-generic）
- 不删除当前 `XlangFutureSlot`（作 fallback）
- 不改 `xlang_async_future_*_c` C ABI（产品链依赖）

---

## 7. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：Future<T> 接口形状、多 payload、动态扩容、cancel 集成、组合子、迁移路径 |
