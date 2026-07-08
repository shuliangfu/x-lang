# SHUX X ABI 设计分析与时机决策

> **文档状态**：架构决策草案 | **作者**：God-View 分析 | **日期**：2026-07-08
> **背景**：SHUX 默认视 C ABI 为不安全（需 `unsafe` 包裹），用户提议设计自有 X ABI 以消除 SHUX-to-SHUX 调用的 unsafe 开销

---

## 1. 问题本质

### 1.1 当前信任模型

SHUX 当前 ABI 策略是**二元信任**：

```
┌─────────────────────────────────────────────────┐
│  safe 区域（默认）                                │
│  - 类型系统保证内存安全                            │
│  - Linear(T) use-once move 检查                   │
│  - 禁止 extern 调用（S0 报 error）                │
│                                                  │
│  unsafe { body } 区域                            │
│  - 允许 extern C ABI 调用                         │
│  - 允许裸指针解引用                                │
│  - 允许内联汇编（AST_EXPR_ASM）                    │
│  - 编译器放弃安全保证                              │
└─────────────────────────────────────────────────┘
```

**根因**：C ABI 是不透明契约 —— 它允许悬空指针、未定义布局、任意副作用。编译器无法验证跨 ABI 边界的安全性，只能用 `unsafe` 将责任转移给程序员。

### 1.2 痛点

自举完成后，编译器自身大量使用 `extern function ...` 调用 `.x` 模块函数（如 [parser.x:29-31](file:///home/shu/shux/compiler/src/parser/parser.x#L29-L31) 的 `std_fs_open/read/close`）。这些调用**实际是 SHUX-to-SHUX**，却要付 C ABI 的 unsafe 代价：

1. **语义浪费**：调用方与被调用方都遵循 SHUX 类型系统，却因 ABI 标记为 C 而被迫包裹 unsafe
2. **优化屏障**：C ABI 边界阻止跨模块内联、常量折叠、指令重排
3. **认知负担**：开发者必须区分"真正不安全的 C FFI"与"只是跨模块的 SHUX 调用"，但语法上无法区分

---

## 2. X ABI 的必要性

### 2.1 核心价值

X ABI 不是"为了安全"，而是**为了在 SHUX-to-SHUX 边界上消除虚假的 unsafe 开销**。

| 维度 | C ABI（现状） | X ABI（提议） |
|------|--------------|--------------|
| 信任来源 | 外部契约，编译器不可验 | SHUX 类型系统，编译器可验 |
| 调用约定 | System V / AArch64 AAPCS | SHUX 自定义（可寄存器分配优化） |
| 内存布局 | 允许 padding、对齐不确定 | 严格对齐、零 padding、扁平布局 |
| 副作用 | 任意（编译器必须保守） | 默认 pure，显式标记 mutable |
| 内联 | 禁止（ABI 边界） | 允许（编译器可打破调用约定） |
| unsafe 要求 | 必须 | 不需要（编译期契约保证） |

### 2.2 什么时候不需要 X ABI

- **纯 C FFI**：调用 libc、系统调用、第三方 C 库 —— 必须保持 C ABI + unsafe
- **自举种子链**：bootstrap_shuxc 从 C seed 编译，早期阶段无 X ABI 运行时

### 2.3 纠正 Gemini 分析的偏差

Gemini 分析方向正确，但有几处与 SHUX 实际架构不符：

1. **"x-shujs 宿主环境"**：SHUX 是系统级语言，无 JS 运行时。Gemini 混淆了项目
2. **"arena_alloc 接口"**：SHUX 已有 Arena 分配器（ASTArena 等），不是新概念
3. **"借用检查（Borrow Checking）"**：SHUX 当前是 Linear(T) use-once move 语义（见 [typeck.x:279](file:///home/shu/shux/compiler/src/typeck/typeck.x#L279) `pipeline_typeck_linear_use_var_c`），不是 Rust 式借用检查。X ABI 应基于现有 Linear 语义扩展，而非引入全新 borrow checker
4. **过度理想化**：X ABI 不能完全消除 unsafe —— 与 OS、硬件、C 库交互仍需 unsafe 层

---

## 3. X ABI 设计要点

### 3.1 语法提议（X ABI 默认，C ABI 显式标记）

**设计原则**：SHUX 是自举语言，SHUX-to-SHUX 调用是常态，应默认安全；C FFI 是例外，需显式标记。与 Rust 对称但相反 —— Rust 默认 Rust ABI（罕见用），SHUX 默认 X ABI（常态用）。

```shux
// X ABI（默认）—— SHUX-to-SHUX 跨模块调用，不需要 unsafe
extern function shux_mod_func(a: i32, b: *ArenaBuffer) -> Result;

// C ABI（显式标记）—— 调用 C 库/系统调用，必须 unsafe
extern "C" function c_library_func(a: i32) -> i32;

// 显式 X ABI 标记（可选，用于强调或未来扩展其他 ABI）
extern "x" function shux_mod_func(a: i32, b: *ArenaBuffer) -> Result;
```

**默认 X ABI 的理由**：
1. **减少标注负担**：大多数 extern 是 SHUX-to-SHUX，省去 `#[abi(x)]` 冗余
2. **C FFI 显眼**：`extern "C"` 清晰标记需要 unsafe 的危险边界，code review 时一眼可见
3. **符合自举哲学**：SHUX 代码默认安全，C 互操作是需警惕的例外
4. **向前友好**：未来若引入其他 ABI（如 `extern "wasm"`），默认 X ABI 不需要回溯修改

### 3.2 语义契约

X ABI 函数必须满足以下编译期可验条件：

1. **参数类型受限**：只接受 SHUX 类型系统内的类型（i32/i64/bool/枚举/struct/切片/Arena 指针）。禁止 `*void`、裸函数指针
2. **所有权协议**：基于现有 Linear(T) 语义 —— 传值 = move，传 `*T` = 借用（调用方保证有效）
3. **严格布局**：所有 struct 参数采用扁平化 8 字节对齐布局，无 padding
4. **副作用标记**：默认 pure（无全局副作用）；需修改全局状态须显式 `#[mutable]`
5. **禁止异常**：X ABI 函数不能用 `?` 传播或 try/catch（错误用 Result 返回值）

### 3.2.1 ABI 判定标准（按语义契约，不按实现语言）

**关键区分**：`_c` 后缀不等于 C ABI。判定标准是**参数类型是否在 SHUX 类型系统内**。

| 类型 | 示例 | ABI | 理由 |
|------|------|-----|------|
| C 运行时/系统调用 | `std_fs_open`, `fs_posix_read_c`, `close` | **C ABI** | 调用外部 C 库，参数是原始类型（`*u8`/`i32`） |
| SHUX 模块 C 桥接 | `pipeline_typeck_*_c`, `ast_*_c` | **X ABI** | 操作 SHUX 类型（`*ASTArena`/`*Module`/`expr_ref`），语义在 SHUX 类型系统内 |

`pipeline_typeck_*_c` 虽然用 C 写（在 pipeline_glue.c 中），但参数是 SHUX 类型，编译器可验证安全性 —— 属于 X ABI。未来 G-02a 完成后这些会被 .x 实现替代，若现在标为 C ABI，后续迁移还要改回来。

### 3.2.2 过渡期语义降级（自举前）

**关键问题**：现有 compiler 代码中少量 `extern function ...` 实际调用 C 运行时（如 [parser.x:29-31](file:///home/shu/shux/compiler/src/parser/parser.x#L29-L31) 的 `std_fs_open/read/close`）。若 P1 激活 X ABI 语义时未标注 `extern "C"`，这些调用会因契约不匹配报 typeck error，导致编译器自身无法编译 —— **bootstrap 陷阱**。

**过渡策略**：自举前 P0 阶段必须完成 `extern "C"` 标注：

| 阶段 | `extern function`（无标记） | `extern "C"` |
|------|---------------------------|--------------|
| 自举前（P0 槽位） | 解析为 X ABI，生成 C ABI 调用（语义降级） | 解析为 C ABI，要求 unsafe |
| 自举后（P1 语义） | 真正走 X ABI 路径（契约验证） | C ABI，要求 unsafe |

**工作量评估**（2026-07-08 实测）：

| 分类 | 数量 | 处理方式 |
|------|------|---------|
| 总 `extern function` | ~1230 个 | — |
| 需标注 `extern "C"`（C 运行时/系统调用） | **~14 个** | P0 阶段改为 `extern "C"` |
| 保持 `extern function`（默认 X ABI） | ~1216 个 | 无需修改 |

**需标注 `extern "C"` 的分布**：
- `parser.x`: 3 个（`std_fs_open/read/close`）
- `main.x`: 2 个（`fs_posix_write_c/close_c`）
- `pipeline.x`: 2 个（`fs_posix_read_c/close_c`）
- `driver/emit.x`: 3 个（`fs_posix_read_c/write_c/close_c`）
- `asm_libroot/std/fs/mod.x`: 4 个（`fs_open_read_c/posix_read_c/posix_write_c/close`）

**结论**：P0 阶段工作量极小（~14 个机械替换），**必须在自举前完成**，否则 P1 会断链。

### 3.3 codegen 策略

```
X ABI 调用生成：
  - 参数：优先寄存器传参（x86_64: rdi/rsi/rdx/rcx/r8/r9；arm64: x0-x7）
  - 返回值：单值用 rax/x0；多值用 struct return sret
  - 栈帧：可选省略（leaf function 优化）
  - 内联：LTO/WPO 阶段可跨 X ABI 边界内联

C ABI 调用生成（不变）：
  - 严格遵循 System V / AAPCS
  - 生成 stack escape 检查
  - 禁止内联
```

### 3.4 与现有 unsafe 的关系

X ABI 不取代 unsafe，而是**细化信任边界**：

```
信任层级：
  1. safe（默认）        — SHUX 类型系统保证
  2. X ABI 调用          — 编译期契约保证，不需要 unsafe
  3. unsafe { C ABI }    — 程序员保证
  4. unsafe { asm }      — 程序员保证
```

---

## 4. 时机分析：自举前 vs 自举后

### 4.1 自举前加 X ABI

**优势**：
- 自举后的编译器代码可以直接用 X ABI，减少 unsafe 块
- ABI 设计与编译器实现同步演进

**风险**：
- **工作量巨大**：需改 parser（新语法）、typeck（契约验证）、codegen（调用约定生成）三层
- **语义不稳定**：X ABI 设计在自举过程中会反复调整，导致 bootstrap 链断裂
- **自举延期**：2026 年 7 月目标可能无法达成（当前 G-02a 才 ~70%）
- **bootstrap 陷阱**：X ABI 需要编译器支持，但编译器自身正在用 C ABI 自举 —— 鸡生蛋问题

**结论**：❌ 不建议自举前完整实现 X ABI

### 4.2 自举后加 X ABI

**优势**：
- 自举完成后有稳定编译器基线，X ABI 可渐进式实现
- 不影响 2026 年 7 月自举目标
- 可在 G-02a 完成（compiler 物理零 C）后，用纯 SHUX 编译器实现 X ABI

**劣势**：
- 自举后的编译器代码已用 unsafe + C ABI 写完，需回头迁移
- 但迁移成本低：将调用 C 实现的 `extern function` 改为 `extern "C"`，其余保持不变（默认 X ABI）

**结论**：✅ 建议自举后实现 X ABI

### 4.3 折中方案：自举前预留语法槽位 + 完成 C ABI 标注（X ABI 默认）

**立即做**（自举前 P0，两步）：

**P0a 语法槽位**：
- parser 识别 `extern "C"` 和 `extern "x"` 显式标记；`extern function`（无标记）默认解析为 X ABI
- typeck：`extern "C"` 要求 unsafe 调用；`extern function`（X ABI）**语义降级为 C ABI**（不强制 unsafe，但也不做 X ABI 契约验证）
- codegen：X ABI 标记的函数**按 C ABI 生成**（行为完全一致，保证自举不破坏）

**P0b C ABI 标注**（必须自举前完成，避免 P1 bootstrap 陷阱）：
- 将 ~14 个调用 C 运行时/系统调用的 `extern function` → `extern "C"`
- 分布：parser.x(3) + main.x(2) + pipeline.x(2) + driver/emit.x(3) + asm_libroot/std/fs/mod.x(4)
- 判定标准：按语义契约（参数类型是否在 SHUX 类型系统内），不按实现语言
- `pipeline_typeck_*_c` 等 C 桥接保持 `extern function`（默认 X ABI），因为操作 SHUX 类型

**自举后做**（P1-P4）：
- P1：激活 X ABI 契约验证（参数类型受限、Linear 所有权、布局检查）
- P2：实现 X ABI 专用调用约定、跨 ABI 内联
- P3：X ABI 语义稳定后，`extern function` 真正走 X ABI codegen 路径
- P4：语义收紧（禁止 `*void`、严格布局）

**优势**：
- 默认 X ABI 符合自举语言哲学（SHUX 代码默认安全）
- `extern "C"` 显式标记 C FFI 边界，code review 友好
- P0b 工作量极小（~14 个机械替换），避免 P1 断链
- 无 bootstrap 陷阱（P0b 后代码正确反映 ABI 意图）

---

## 5. 建议方案

### 5.1 决策

**采纳折中方案：X ABI 默认 + 自举前预留语法槽位 + 自举后实现语义**

### 5.2 实施路线图

| 阶段 | 时机 | 内容 | 风险 |
|------|------|------|------|
| **P0a 语法槽位** | G-02a 完成后（~2 周内） | parser 识别 `extern "C"` / `extern "x"`；`extern function` 默认 X ABI；typeck/codegen 降级为 C ABI 生成 | 低 — 行为与现状一致 |
| **P0b C ABI 标注** | P0a 后立即（自举前必须） | 将 ~14 个调用 C 运行时的 `extern function` → `extern "C"`（5 个文件，机械替换） | 低 — 机械替换 + 双平台验证 |
| **P1 语义原型** | 自举完成后（~8 月） | 激活 X ABI 契约验证（参数类型受限、Linear 所有权）；`extern function` 走 X ABI typeck 路径 | 中 — typeck 规则需仔细设计 |
| **P2 codegen 优化** | P1 稳定后 | X ABI 专用调用约定、跨 ABI 内联、纯函数优化；`extern function` 走 X ABI codegen 路径 | 高 — 需性能基准验证 |
| **P3 语义收紧** | 长期 | X ABI 契约强制化（禁止 `*void`、严格布局）；`extern "C"` 成为 FFI 唯一入口 | 中 — 可能暴露历史代码问题 |

### 5.3 不做的事

1. **不引入 Rust 式 borrow checker** —— SHUX 是 Linear(T) 语义，X ABI 应基于现有 move 语义扩展
2. **不消除 unsafe** —— unsafe 仍用于 `extern "C"` FFI、裸指针、内联汇编
3. **不在自举前实现 X ABI 语义** —— 避免自举延期和 bootstrap 陷阱
4. **不回溯修改 P0 前的代码** —— 现有 `extern function` 在 P0 后默认 X ABI（语义降级），P3 才分类迁移

---

## 6. 与现有架构的契合点

### 6.1 Arena 分配器

X ABI 与 Arena 天然契合：
- Arena 指针 `*ASTArena` 作为 X ABI 参数，编译器可验证 Arena 生命周期（Arena 在调用期间不被释放）
- Arena 内分配的对象通过 pool index 传递，避免裸指针

### 6.2 Linear(T) 语义

现有 [typeck.x:279](file:///home/shu/shux/compiler/src/typeck/typeck.x#L279) `pipeline_typeck_linear_use_var_c` 已实现 use-once move 检查。X ABI 可复用：
- 传值参数 = move（调用后原变量失效）
- 传 `*T` = 借用（调用期间原变量有效但只读）

### 6.3 WPO/LTO 优化

现有 [build_asm/pipeline_wpo.o](file:///home/shu/shux/compiler/build_asm/) 已支持全程序优化。X ABI 的跨模块内联可复用 WPO 基础设施。

---

## 7. 结论

| 问题 | 答案 |
|------|------|
| 要不要 X ABI？ | ✅ 要 —— 消除 SHUX-to-SHUX 调用的虚假 unsafe 开销 |
| 默认 ABI 是什么？ | **X ABI 默认** —— `extern function` 无标记 = X ABI；`extern "C"` 显式标记 C FFI |
| `extern "C"` 标注何时做？ | **自举前必须完成**（P0b），否则 P1 激活 X ABI 语义时 bootstrap 断链 |
| 自举前还是自举后？ | P0a/b 自举前（语法槽位 + C ABI 标注），P1-P3 自举后（语义实现） |
| 立即做什么？ | G-02a 完成后，P0a 识别 `extern "C"` 语法 + P0b 标注 ~14 个 C 运行时调用 |
| 不做什么？ | 不在自举前实现 X ABI 语义；不引入 borrow checker；不消除 unsafe；不把 `_c` 后缀等同于 C ABI |

**核心原则**：X ABI 是编译期契约的载体，不是运行时检查的替代。它的价值在于让编译器**证明** SHUX-to-SHUX 调用的安全性，从而消除不必要的 unsafe 包裹和优化屏障。**默认 X ABI** 体现了自举语言的自信 —— SHUX 代码默认安全，C 互操作才是需警惕的例外。
