# std 标准库：方法风格（类方法 / impl）重写分析

> **日期**：2026-08-08（全量重写）  
> **状态**：**延后 · 自举完成后再做**（用户 2026-08-08 确认：不在自举期优化/落地；主航道仍 BC/PC）  
> **结论一句话**：**方向正确，语言能力已可用；std 方法化挂自举后 P2c 渐进试点；自举期只保留本文决策，不改产品 API。**  
> **权威交叉**：
> - 进度 / 闸门：[`自举进度.md`](./自举进度.md) · skill `xlang-selfhost-product-gate` · [`AGENTS.md`](../AGENTS.md)
> - 语法：[`docs/02-类型定义.md`](../docs/02-类型定义.md) · [`docs/01-关键字.md`](../docs/01-关键字.md)
> - 方法 / 属性产品面：[`方法绑定-类型查询-全局内置-分析.md`](./方法绑定-类型查询-全局内置-分析.md)
> - std 清单：[`std标准库全量清单与优先级.md`](./std标准库全量清单与优先级.md) · [`std/标准库api命名规范.md`](../std/标准库api命名规范.md)
> - 完成后时序：[`自举完成后功能完善及优化时序表.md`](./自举完成后功能完善及优化时序表.md)（P2a 语言 · P2c std）
> - 异步 trait 骨架：[`async-io-trait-RFC.md`](./async-io-trait-RFC.md) · `std/io/io_trait.x` · `std/async/executor_trait.x`

---

## 0. 一句话总表

| 问题 | 结论 |
|------|------|
| 语言现在有没有 trait / impl / `value.method()`？ | **有**。文档、关键字、typeck method_call、探针与 `tests/trait/*` 均覆盖；2026-08-07 起 method_call 域大量 pure leave（wave247～260）。 |
| std 现在是不是方法风格？ | **几乎不是**。`std/**/*.x` ≈ **166** 文件、**~4100+** `export function`，容器/路径/字符串以 **模块绑定 + 自由函数** 为主（如 `vec.push(&v, x)`）。 |
| 能不能用「类方法」重写 std？ | **能，且值得**；但 **禁止自举期全量重写**；**禁止**为糊编译器债批量改 std（G.3）。 |
| 什么时候做？ | **默认：自举完成后 P2c**（语言面 P2a 再打磨后）。自举期只允许：**试点探针 / 空 trait 骨架 / 文档与命名契约**，不改产品默认调用面。 |
| 怎么做才不造双权威？ | 方法面 = **薄包装转调**现有自由函数权威体，或**一次性迁完**某一模块后删旧 export；禁止长期两套业务逻辑。 |
| 全量 vs 渐进？ | **渐进 + 选择性**。高频容器 / 字符串 / 路径优先；sys/atomic/math 等保持函数。 |

---

## 1. 项目当前全景（与「方法化」相关的切片）

### 1.1 自举与产品轨（2026-08-08）

| 项 | 状态 |
|----|------|
| 分支 | `self-hosting` |
| 产品 L4 钉盘 | **`36363b90f`**（双端 tip L4 + bstrict **129**；pin 蛋已刷） |
| Track MG | ✅ Makefile 物理删除 · `./xbuild` 产品入口 |
| Track BC | 🟡 Cap residual **present ≈ 41**（B′ pure leave 持续；**pipeline_x 离 host-cc 仍 ⬜**） |
| Track L (Stage 8) | 开 · **13/30** retired |
| 验证 | 自举期 **暂停** `xlang check` 闸门；日常 L2/L3；结案 / 升钉才 L4 |
| 纪律 | 根源治理 · 禁止双权威 · 单一实现（G.7）· 平台边界（G.8）· `.x` 英文注释（G.9） |

**含义**：主航道仍是 **BC residual / pipeline_x mega / PC**。std 方法化属于 **API ergonomics**，与 residual 无关，**不得**占用 BC 刀法与升钉节奏。

### 1.2 语言能力：trait / impl / 方法调用

**官方语法（可用）** — 见 `docs/02-类型定义.md`：

```x
// Trait
trait TraitName {
  function method(self: TypeName, ...): RetType;
  // 方法声明之间用分号
}

// Trait impl
impl TraitName for TypeName {
  function method(self: TypeName, ...): RetType {
    // body
  }
}

// Inherent methods（不依赖 trait）
impl TypeName {
  function method(self: TypeName, ...): RetType {
    // body
  }
}

// 调用
value.method(args);
```

| 能力 | 成熟度 | 证据 / 备注 |
|------|--------|-------------|
| `trait` / `impl Trait for Type` | **产品可用** | `docs/01-关键字.md`；`tests/trait/main.x` 等；`xlang_trait_check_impls_complete_c` |
| `self` 接收者 | **可用**（须写类型：`self: Type`） | wave493：无标注 `self` 非标准；`self: Point` 绿 |
| `value.method()` | **可用 + 加固中** | typeck method_call pure leave wave247～253、260；探针 `mcall42` 等 |
| Inherent `impl Type { ... }` | **可用** | 探针 / 泛型 inherent wave491～498 |
| 泛型 inherent 方法 monomorphize | **链路已打通** | wave494 typeck 推断 · wave495～498 codegen multi-combo |
| UFCS / overload / mono-map / subst | **与 CALL 同机制加固** | wave247～252 等 pure leave |
| 动态分发 / trait object | **不作为默认** | 默认 monomorphized 静态调用；dyn 仍 soft/后期 |
| 属性 `.length`（字段式） | **产品面已定目标** | 见方法绑定分析文；语言级 `string` 自举后 |

**重要澄清（纠正旧文过乐观处）**：

1. **「method_call pure leave」≠「std 已方法化」**。那是 **typeck 实现迁出 Cap residual**，是自举 BC 债，不是库 API 迁移完成。  
2. **「可用」≠「std 可一次全切」**。测试矩阵、链接按需、`#[no_mangle]` 短名、模块 import 约定仍以自由函数为主。  
3. **探针语法偶有 `fn`/`->` 草稿**（如部分 wave 探针）— **产品 `.x` 权威语法是 `function` / `: Ret`**；写 std 必须跟文档与现网产品源。

### 1.3 std 现状（API 形态）

| 维度 | 现状 |
|------|------|
| 规模 | `std/` 下大量模块（runtime/io/fs/net/string/vec/map/…）；export 函数 **数千** |
| 调用习惯 | `const vec = import("std.vec"); vec.push(&v, x);` |
| 容器 | **单态化结构体** `Vec_i32` / `Vec_u8` / `Map_i32_i32` 等 + 自由函数，**不是** `Vec<T>` 唯一泛型类型 |
| 命名规范 | 已写明未来目标：`Vec_i32.push` 为未来语法，**现为** `push(&vec_i32, …)`（`std/标准库api命名规范.md` §5） |
| trait 在 std | **仅骨架 / 准备**：`std/io/io_trait.x` 的 `Io`、`std/async/executor_trait.x` 的 `Executor`；**不强制后端实现、不改链接默认**（自举期 INVARIANT） |
| 用户测试 | `tests/vec/*` 等一律 `vec.push(&v, …)`；**无** 生产级 `v.push(x)` 作为默认验收 |

示例（当前权威风格，摘自 `std/vec/mod.x` 语义）：

```x
const vec = import("std.vec");
let v: vec.Vec_i32 = vec.new();
vec.with_capacity(&v, 8);
vec.push(&v, 42);
let n = vec.length(&v);   // 或字段 v.length（视模块暴露）
```

方法风格目标形态：

```x
const vec = import("std.vec");
let v: vec.Vec_i32 = vec.Vec_i32.new();  // 或 inherent / 关联函数策略见 §4
v.push(42);                               // self 接收者
let n = v.length;                         // 属性优先（见方法绑定文）
```

### 1.4 与「方法绑定 / 属性」产品面的关系

[`方法绑定-类型查询-全局内置-分析.md`](./方法绑定-类型查询-全局内置-分析.md) 已定：

- 用户心智：**值带着类型的能力**；语义是静态类型决定成员。  
- **属性**（`.length` / `.capacity`）vs **方法**（可能分配 / 失败的 `.substring` 等）。  
- **命名全称**（`length` 而非产品面长期双名 `len`）。  
- 默认 **零成本静态**，禁止默认虚表式动态分发。

本文的「类方法重写」是上述产品面在 **std 实现层** 的落地策略，不是另开第三套命名学。

---

## 2. 要不要把 std 重写成类方法？

### 2.1 结论

| 决策 | 内容 |
|------|------|
| **要不要** | **要**（方向正确）：提升可读性、链式体验、与 Rust/Zig 用户心智对齐，且命名规范已预留。 |
| **全量吗** | **不要**。全量 = 巨大回归面 + 与自举 / bstrict / 链接门控纠缠。 |
| **现在就动手改产品 API 吗** | **默认否**。主航道 BC/PC；std 方法化挂 **自举后 P2c**（可与 P2a 语言打磨并行规划，不可抢 residual）。 |
| **例外** | ① 空 trait 骨架（已有 Io/Executor）；② 自举后试点模块；③ 若用户**明确**要求某模块方法面 dogfood，则单模块双轨 + 最小矩阵，仍禁止批量改测试期望顶债。 |

### 2.2 为什么适合（收益）

1. **API 自然**：`v.push(x)` / `s.find(pat)` / `path.join(...)` 比自由函数更清晰。  
2. **语言能力到位**：impl / self / method_call / 泛型 inherent / overload 产品路径已存在。  
3. **零成本抽象**：方法应 monomorphize 为静态调用，与现有 freestanding 目标一致。  
4. **异步 / IO 抽象需要 trait**：`Io` / `Executor` / 未来 Reader·Writer 只能走 trait，与容器 inherent 方法互补。  
5. **与命名规范一致**：规范已写「未来 `Vec_i32.push`」。

### 2.3 为什么不能现在全量（成本与红线）

| 风险 | 说明 |
|------|------|
| **抢主航道** | BC residual / pipeline_x 离 host-cc 未完；全量改 std 会制造假绿与回归噪声。 |
| **G.3 假修** | 禁止批量改 std 顶 parser/typeck 债；方法化若踩 method_call 洞，应回 typeck 根修，而非改掉调用。 |
| **双权威** | 方法体复制一份逻辑 = G.7 违规；必须「薄包装转调」或「迁完删旧」。 |
| **测试海啸** | 数千 export + 大量 bstrict/manifest 以自由函数为契约；一刀切必红。 |
| **链接 / mangle / no_mangle** | 现网短名、`Track-L`、按需入链门控按符号表工作；方法符号命名与 import 面须单独设计（§5）。 |
| **单态容器现实** | `Vec_i32` / `Vec_u8` 多类型并行；inherent 要对每个结构体写 impl，或等泛型 `Vec<T>` 产品化后再收敛。 |
| **self 语义** | 今日多用 `*Vec_i32` 可变接收；方法要统一 **按值 / 指针 / 可变** 契约，避免 silent copy。 |

---

## 3. 什么适合方法化，什么保持函数

### 3.1 优先级矩阵（落地排序）

| 优先级 | 模块 / 类型 | 建议形态 | 理由 |
|--------|-------------|----------|------|
| **P0 试点** | `std.vec`（先 `Vec_i32` 再扩 u8/u64…） | **inherent** `impl Vec_i32 { … }` | 最高频；命名规范已预留；测试集中 |
| **P0 试点** | `std.string`：`String` / `StrView` | inherent + 视图方法 | 与「方法绑定」清单直接对齐；链式收益大 |
| **P1** | `std.path` | 视 API：若引入 `Path`/`PathBuf` 类型则 inherent；纯 `(ptr,len)` 缓冲 API **可保持函数** | 今日大量 out-buffer 风格，强行 `self` 不自然 |
| **P1** | `std.map` / `std.set` / `std.queue` | inherent（按单态类型） | 与 vec 同模式 |
| **P2** | `core.option` / `core.result`（及 std 再导出） | inherent 或 trait 增强 | ergonomics；须与语言级 ADT 时机协调 |
| **P2** | `std.io` Reader/Writer 面 | **trait** + 具体类型 impl | 可组合；与 async Io 分层 |
| **P2～P3** | `std.io.Io` / `std.async.Executor` | **trait**（骨架已有） | 自举后 ASYNC-2 注入模型；**非**容器方法化同波 |
| **P3** | fs / net 句柄型（`File` / `TcpStream`） | 句柄类型 inherent；批量/syscall 底层仍函数 | 方法适合 `read`/`write`；`accept_many` 类保持函数更清晰 |
| **保持函数** | `std.sys` / `std.atomic` / `std.mem` 底层 / `std.heap` 多数 | 自由函数 | C 风格、无明显「对象」；指针 + 长度更清楚 |
| **保持函数** | `std.math` / `std.hash` / `std.random` 纯工具 | 自由函数 | 无明确接收者；`min(a,b)` 不应变成方法 |
| **保持函数** | 多 out-buffer、多源拼接 | 自由函数或关联函数 | 如 `path.join(out, …, a, b)`、`fmt.format(buf, …)` |

### 3.2 属性 vs 方法（std 落地时统一）

| 类别 | 形态 | std 例子 |
|------|------|----------|
| O(1) 布局信息 | **字段或属性** | `v.length` / `v.cap`（产品面倾向全称 `capacity`） |
| 可能失败 / 分配 / 边界 | **方法** | `v.push`、`s.replace`、`m.insert` |
| 构造 | **关联函数**（模块函数或 `Type.new`） | `Vec_i32.new()` / 暂保留 `vec.new()` |
| 无明显 self | **自由函数** | `hash(bytes)`、`sleep_ms(n)` |

---

## 4. 推荐架构：双轨过渡 + 单一权威体

### 4.1 权威原则（强制）

```text
用户可见两种「入口」可以并存一段时间
        │
        ▼
  业务逻辑只允许一份权威实现
        │
   ┌────┴────┐
   │ 方法入口 │              │ 自由函数入口 │
   │  thin →  │──────────────│  权威体      │
   └─────────┘              └──────────────┘
```

- **允许**：`impl Vec_i32 { function push(self: *Vec_i32, x: i32): i32 { return push(self, x); } }` 一类 **零逻辑** 转调（注意命名冲突时方法内直接写权威函数名或内部 `push_impl`）。  
- **禁止**：方法与自由函数各写一套 push 增长逻辑。  
- **终局**：某一模块方法面稳定且文档 / cookbook / 测试迁完后，自由函数可标 deprecated 或仅作 `#[doc(hidden)]` 兼容层，**仍只转调**，不复活第二逻辑。

### 4.2 推荐语法模板（产品 `.x`）

**Inherent（容器首选）**：

```x
// PLATFORM: SHARED — monomorphized container methods; no dyn dispatch.
allow(padding) struct Vec_i32 {
  ptr: *i32;
  length: i32;
  cap: i32;
  al: heap.Allocator;
}

// Authority remains free function push / reserve / ... (existing exports).
// Methods are thin sugar for ergonomics.

impl Vec_i32 {
  /**
   * Append one element; grows capacity as needed.
   * @param self *Vec_i32 — vector receiver (mutable)
   * @param x i32 — element
   * @return i32 — 0 success, -1 OOM / grow failure
   * PLATFORM: SHARED
   */
  function push(self: *Vec_i32, x: i32): i32 {
    return push(self, x); // or call unambiguous internal name if shadowing
  }

  /**
   * Element count.
   * Prefer field `self.length` when only reading layout.
   */
  function len(self: *Vec_i32): i32 {
    return self.length;
  }
}

// Call site
// v.push(1);
```

**Trait（多态 / 注入面）**：

```x
export trait Reader {
  function read(self: *Self, buf: *u8, len: i32): i32;
}

impl Reader for File {
  function read(self: *File, buf: *u8, len: i32): i32 {
    return file_read(self, buf, len); // authority
  }
}
```

> `Self` / 默认方法 / 对象安全等若与现网 typeck 能力有缺口，**先扩语言（P2a）再铺 std**，禁止在 std 里用半残语法硬上。

### 4.3 接收者约定（建议写进命名规范）

| 操作 | 建议 `self` 类型 | 说明 |
|------|------------------|------|
| 就地修改容器 | `self: *T` | 与今日 `push(v: *Vec_i32, …)` 一致 |
| 只读查询 | `self: T` 或 `self: *T`（只读） | 须统一模块内风格；避免有的按值有的指针 |
| 消费 self（move） | 暂慎用 | 等 linear / 所有权产品面更成熟（安全路线） |
| 静态构造 | **无 self**：`new()` 自由函数或关联函数 | 不要 `0.push` 式伪方法 |

### 4.4 与 import 绑定的关系

| 风格 | 例子 | 说明 |
|------|------|------|
| 今日默认 | `const vec = import("std.vec"); vec.push(&v, x);` | 保持兼容 |
| 方法 | `v.push(x)` | 类型上已有 impl 即可；**不强制** `vec.` 前缀 |
| UFCS 后备 | `Vec_i32.push(&v, x)` 或模块路径 | 解析与重载冲突时的逃生舱 |

---

## 5. 工程约束与爆炸半径

### 5.1 动手前五问（G.1，针对方法化）

1. **谁产生？** 用户源 → parser（impl/trait）→ typeck method_call → codegen mono/mangle → 链接符号。  
2. **谁存储？** hoisted impl 方法、resolved_func_index、`.o` 符号表、bstrict manifest。  
3. **谁消费？** 用户程序、compiler 自举源（**compiler 几乎不用 std 方法面**）、测试矩阵。  
4. **同模式爆炸半径？** 每个 `Vec_*` / 测试 `vec.push` / cookbook / README / API gate tsv。  
5. **最小回归集？** 该模块 gate + 方法探针 + 产品矩阵 + **不得**只改期望糊绿。

### 5.2 链接与符号

- 现网大量 `#[no_mangle]` / Track-L 短名服务 **C ABI 与按需链接**。  
- 方法化后：  
  - **默认**：方法可走正常 mangle；权威 no_mangle 自由函数仍给 runtime/C 邻居。  
  - **禁止**：为每个方法再注册一套平行 no_mangle 短名而不走 G.7 检索。  
- 改 export 面后：Ubuntu 产品链 + 相关 std gate；SHARED 双端。

### 5.3 与自举 / 假绿纪律

| 禁止 | 正确 |
|------|------|
| 自举期全库 `impl` 化 | 挂 P2c；自举期只文档 + 骨架 |
| 方法红就改测试期望 | 修 typeck/codegen 或回退方法面 |
| 方法体复制自由函数逻辑 | thin wrap 或迁完删旧 |
| 用方法化「证明」method_call pure leave 完成 | 两回事；leave 只看 residual inventory |
| 只在 mac 绿宣称 std 方法面完成 | Ubuntu 金标 + 模块 gate |

### 5.4 与异步 trait 骨架的分工

| 轨 | 内容 | 时机 |
|----|------|------|
| **容器方法化** | inherent methods | 自举后 P2c 试点 |
| **Io / Executor trait** | 注入执行模型 | 自举后 ASYNC-2（时序表 P2f） |
| **现在** | 空 trait + 锚点函数，不改链接 | 已存在；保持 INVARIANT |

两轨 **不要** 绑成一个「大 std 重写」commit。

---

## 6. 落地路线（可执行）

### 6.1 阶段 0 — 自举期（现在 · 只准备 · **冻结实现**）

- [x] 语言：trait / impl / method_call 产品能力存在（持续 pure leave 加固）  
- [x] 命名规范写明未来方法形态  
- [x] Io / Executor 空 trait 骨架  
- [x] **本文**决策真源 + `analysis/README` 入口  
- [x] **用户确认（2026-08-08）**：自举完成后再优化/落地方法面；本阶段 **零产品 API 改动**  
- [ ] **不做**（冻结至自举完成）：改 `std.vec` / `std.string` 等默认 API；批量改 tests；开方法化试点 PR 

### 6.2 阶段 1 — 自举完成后 · 试点（P2c 前段）

**闸门**：P0 基线稳 + 产品 bstrict 绿 + method_call 无已知产品红。

1. **选一个类型**：`Vec_i32` only（禁止一次五个 `Vec_*`）。  
2. 为 `push` / `pop` / `clear` / `is_empty` / `reserve` 加 **inherent 薄包装**。  
3. 新增 **并行** 测试文件（如 `tests/vec/method_push.x`），**旧测试不删不改期望**。  
4. 验收：Ubuntu 模块 gate + 产品矩阵；mac 同测 SHARED。  
5. cookbook 加一篇「方法风格可选」。  

**成功标准**：新测试绿；旧自由函数测试全绿；权威逻辑无分叉（diff 方法体 ≈ 单行转调）。

### 6.3 阶段 2 — 扩大试点

1. `Vec_u8` 等同构类型（可脚本生成 impl，但 **逻辑仍转调**）。  
2. `String` / `StrView`：对齐方法绑定文清单（`length` 属性、`subview`、`find`…）。  
3. `Map_*` / `Set_*` / `Queue_*` 按同构复制流程。  

### 6.4 阶段 3 — 句柄与 IO trait

1. File / TcpStream 等句柄 inherent。  
2. Reader/Writer trait 定稿。  
3. 与 ASYNC-2 Io/Executor 注入对齐（**不**在容器试点波做）。  

### 6.5 阶段 4 — 收敛

1. 文档默认示例切方法风格。  
2. 自由函数标 deprecated（若语言有）或文档「兼容层」。  
3. 评估是否删除冗余 export（**须**链接 / 外部 crate 影响分析；宁可晚删）。  

### 6.6 明确不在路线内

- 自举期全量 std 方法化  
- 默认动态分发  
- 为方法化引入第二套堆 / 分配器  
- 语言级 `string` 与库 `String` 方法面混成第三权威（语言级 string 时机见基础类型缺口文）  
- 用方法化顺手「清理」无关 API 或改错误码语义  

---

## 7. 试点检查清单（合入用）

- [ ] 仅一个模块 / 一个单态类型（或明确列出的同构批）  
- [ ] 方法体 **无** 第二套业务逻辑（G.7）  
- [ ] 每个新方法英文 JSDoc（G.9）  
- [ ] PLATFORM 标注（G.8）；SHARED → 双端  
- [ ] 新探针 + **旧测试仍绿**  
- [ ] 相关 std gate / manifest 更新策略写清（扩测而非改期望）  
- [ ] 未动 method_call 假修；若红则归 typeck/codegen 层  
- [ ] 未抢 BC residual commit；独立主题 commit  

---

## 8. 与旧版本文档的差异（2026-08-08 重写说明）

| 旧文 | 问题 | 新文 |
|------|------|------|
| 「已经可以正常写类方法」为主叙事 | 易误解为 **std 已方法化 / 可全量开工** | 拆开：语言可用 vs std 仍是函数 vs 时机在 P2c |
| 把 wave247～253 pure leave 当库成熟标志 | leave = 编译器 residual，不是 API 迁移 | 明确两码事 |
| 泛化「值得做 + 渐进」 | 缺项目闸门、G.3/G.7、链接、单态容器现实 | 补全景、红线、模板、阶段、检查清单 |
| 未提 Io/Executor 骨架与命名规范预留 | 与仓库真实准备脱节 | 对齐现有文件与规范 |
| 聊天式收尾 | 非 analysis 决策文风格 | 改为可执行决策真源 |

---

## 9. 总结

1. **语言**：trait / impl / inherent methods / `value.method()` **已是产品能力**，typeck method_call 仍在 BC 轨加固，但 **不是** 规划中的空中楼阁。  
2. **std**：**现实是自由函数主导**；方法化是 **正确的 API 演进方向**，命名规范与方法绑定文已预留。  
3. **时机**：**自举完成后 P2c 渐进试点**；自举期只准备、不抢 residual、不全量重写。  
4. **做法**：**接收者明确**的容器 / 字符串 / 句柄优先；**trait** 留给 Io/Executor/Reader；底层与纯函数保持函数风格。  
5. **铁律**：**一份权威逻辑** + 薄方法糖 + 双轨测试 + Ubuntu 金标；禁止双实现、禁止批量改 std 顶编译器债。  

**下一步（若开工）**：只开 `Vec_i32` 方法试点 RFC 级 PR 清单（方法表 + 转调表 + 新测试路径），不预先改其它模块。
