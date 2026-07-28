# Async 语言能力债清单

> **日期**：2026-07-28
> **状态**：活文档（随语言能力推进更新）
> **目的**：列出阻塞全面异步架构（T\*）的语言能力缺口，与 lang-trait 路线对齐，避免自举后开干时才发现语言债挡路。
> **关联**：[全面异步架构-分析与准备.md](全面异步架构-分析与准备.md) §3.4 G-trait/G-fp/G-name-gate · [async-io-trait-RFC.md](async-io-trait-RFC.md)

---

## 0. 一句话结论

全面异步的"可注入 Io/Executor"依赖 **trait 对象 / 静态分发** 与 **泛型 Future<T>**，两者当前都是语言债。name-gate 字符串表是 codegen 债，可独立于语言债先做 typeck 标志位迁移。自举期不实现这些能力，但必须把债列清，让自举收口后能按优先级推进。

---

## 1. 语言能力缺口总表

| ID | 缺口 | 阻塞 T\* 哪条 | 当前状态 | 优先级 |
|----|------|---------------|----------|--------|
| **L-trait** | trait 对象 / 静态分发不足以表达 Io 方法表 | T2 可注入 Io | trait 已有（Reader/Writer），但对象/动态分发弱 | **高** |
| **L-generic** | 泛型参数化（Future<T>、Io<T>） | T2/T3 无染色库 API | 泛型债；当前 Future 仅 i32×64 静态 | **高** |
| **L-fn-ptr** | 函数指针 / 类型统一未完成 | T2 spawn 优雅签名 | STD-041 已记 extern 冲突 | 中 |
| **L-name-gate** | await 目标靠字符串表识别 | T3 类型驱动识别 | `async_cps_callee_is_io` 字符串匹配 | 中（codegen 债，非语言债） |
| **L-async-syntax** | `async function` 染色 | T3 无强制染色 | 语法层分流 is_async 进 AST | 低（T\* 后期才去糖） |
| **L-kwarg** | 关键字参数（`type` 等保留字作参数名） | T2 Io 方法表清晰度 | 已记约束 | 低 |
| **L-expr-unsafe** | 表达式 unsafe 语义 | T2 Io 后端 unsafe 边界 | 已约束 `let rc; unsafe { rc = call(); }` | 低 |

---

## 2. 详细缺口分析

### 2.1 L-trait：trait 对象 / 静态分发

**现状**：
- `std/io/mod.x` 已有 `trait Reader { function read(self): i32; }` / `trait Writer`
- 但 trait 对象（动态分发）与静态分发能力弱，无法表达 `Io` trait 的多后端方法表

**T\* 需求**：
- `trait Io { function read(self, ...): i32; function write(self, ...): i32; function spawn(self, ...): i64; ... }`
- 多后端实现：`ThreadedIo` / `EventedIo` / `TestIo` 实现 `Io` trait
- 调用点：`fn read_file(io: Io, path: ...) { io.read(...) }` — 静态分发或动态分发

**阻塞点**：
- 当前 trait 无法承载"多后端同一接口"的静态分发
- 临时方案：C ABI vtable（`extern` 函数指针表），但与 `.x` 语义权威冲突

**推进路径**：
1. 自举期：落 `Io` trait 空接口骨架（见 [async-io-trait-RFC.md](async-io-trait-RFC.md)），不改链接默认
2. 自举后：lang-trait 主线推进 trait 对象 / 静态分发
3. T\* 阶段 2：用 trait 实现 ThreadedIo / EventedIo / TestIo

### 2.2 L-generic：泛型参数化

**现状**：
- Future 仅 `i32×64` 静态槽（`XlangFutureSlot { state: i32; value: i32; }`）
- 无法表达 `Future<T>`（T 为指针/结构体/多类型）

**T\* 需求**：
- `Future<i32>` / `Future<*u8>` / `Future<MyStruct>` — 通用无染色库 API
- `Io<T>` — 参数化 Io 后端（可选）

**阻塞点**：
- 语言泛型能力不足（参数化类型、泛型函数、泛型结构体）
- 临时方案：`*void` + 手动类型转换，丢失类型安全

**推进路径**：
1. 自举期：落 Future 泛型化设计 RFC（见 [async-future-generic-RFC.md](async-future-generic-RFC.md)），不实现
2. 自举后：lang-generic 主线推进
3. T\* 阶段 2：Future<T> 落地

### 2.3 L-fn-ptr：函数指针统一

**现状**：
- STD-041 已记 extern 冲突；函数指针类型统一未完成
- 影响 `spawn` 优雅签名（当前 `xlang_async_spawn_i32` 等强类型 C ABI）

**T\* 需求**：
- `spawn(fn(T) -> U, arg: T): Future<U>` — 通用 spawn
- 函数指针类型统一，避免每类型一个 C ABI

**推进路径**：与 L-generic 合并推进

### 2.4 L-name-gate：await 目标识别（codegen 债）

**现状**：
- `compiler/src/async/async_cps_codegen.x:89` `async_cps_callee_is_io(callee: *u8): i32`
- 逐字节匹配函数名：`shux_io_` / `read` / `write` / `submit_read` / `submit_write`
- 字符串表脆弱：新增 IO 函数需手动追加；无法区分"用户函数恰好叫 read"与"真 IO"

**T\* 需求**：
- typeck 标志位识别 IO await（`is_io_await` 属性，而非名字匹配）

**推进路径**：
1. 自举期：落 name-gate → typeck 迁移设计（见 [async-name-gate-typeck-migration.md](async-name-gate-typeck-migration.md)），不实现
2. T\* 阶段 1：typeck 标志位实现，name-gate 作回退
3. T\* 阶段 2：name-gate 删除

### 2.5 L-async-syntax：async 染色

**现状**：
- `async function` 与普通 `function` 分流；`is_async` 进 AST
- 含 await 的函数必须是 async

**T\* 需求**：
- 用户库函数默认不因"内部会挂起"而必须标 `async`
- `async`/`await` 保留为可选糖/显式控制流

**推进路径**：T\* 阶段 3（L-full）才动；阶段 1/2 保留染色

---

## 3. 优先级与依赖关系

```
L-trait ─┐
         ├─→ T2 可注入 Io（阶段 2）
L-generic ┘
         ┌─→ T3 无染色库 API（阶段 3）
L-fn-ptr ┘

L-name-gate（codegen 债）─→ T3 类型驱动（阶段 1 设计，阶段 2 实现）

L-async-syntax ─→ T3 去染色（阶段 3）
```

**关键**：L-trait + L-generic 是 T\* 阶段 2 的硬阻塞；L-name-gate 是阶段 1 可独立推进的 codegen 债。

---

## 4. 自举期准备（不实现，只记录）

| 准备项 | 落地形式 | 状态 |
|--------|---------|------|
| Io trait 空接口骨架 | `std/io/io_trait.x`（薄代码） | 待落地 |
| Executor trait 空接口骨架 | `std/async/executor_trait.x`（薄代码） | 待落地 |
| Future 泛型化设计 | `analysis/async-future-generic-RFC.md` | 待落盘 |
| Io/Executor trait 接口 RFC | `analysis/async-io-trait-RFC.md` | 待落盘 |
| name-gate 迁移设计 | `analysis/async-name-gate-typeck-migration.md` | 待落盘 |

---

## 5. 风险

| 风险 | 缓解 |
|------|------|
| 语言债拖延阻塞 T\* | lang-trait / lang-generic 主线与自举并行推进，不互相阻塞 |
| 临时 C ABI vtable 成第三权威 | 临时方案必须标注"过渡期"，trait 落地后立即替换 |
| name-gate 迁移破坏现有 async | typeck 标志位与 name-gate 共存期，渐进替换 |

---

## 6. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-28 | 初版：列出 L-trait/L-generic/L-fn-ptr/L-name-gate/L-async-syntax 五类语言债与推进路径 |
