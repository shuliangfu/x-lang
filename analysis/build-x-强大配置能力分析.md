# build.x：强大配置能力 + 简单易写易用（对照 zig build.zig · 现状校准）

> **文档目的**  
> 1. 论证 SHUX **「配置即数据（shux.toml）+ 策略即代码（build.x）」** 正交分工，相对 zig 单体 `build.zig` 的架构优势与边界。  
> 2. **按仓库真实现状校准**愿景（避免把设计稿写成已交付）。  
> 3. 回答：**怎样把 build.x 做强，同时保持简单、易写、易用**（API 形态、默认路径、分层、分阶段、禁令）。  
>
> **配套**：[shux-toml-实现分析.md](shux-toml-实现分析.md) · [shux.toml](../shux.toml)（示例，**编译器尚未读取**）· [自举方法.md](自举方法.md) · [AGENTS.md](../AGENTS.md)（单一权威 / 双权威禁令）  
>
> **最后更新**：2026-07-21（全面重写：现状校准 + 强大且易用路径）。

---

## 0. 一句话结论

| 维度 | 结论 |
|------|------|
| **架构方向** | **坚持**「shux.toml = 参数权威；build.x = 策略权威」。比 zig「一切在代码里」更利于 IDE/CI 静态消费与零配置启动。 |
| **现状（诚实）** | **远未达到**文档早期宣称的「策略与 zig 同样强大」。`build.x` 实质只有 **3 个薄函数**；真干活的是 **C `build_runtime` + shell 脚本 + Makefile**；`shux.toml` 是 **示例/设计稿**，不参与构建。 |
| **强大怎么来** | 强大在 **std.Build 式 Step/DAG API + 执行器 + 缓存**，不在用户手写 `if step_id` 长 switch。 |
| **简单怎么来** | **90% 项目零 `build.x`**：只写 `shux.toml`（或连 toml 都没有，用默认）。`build.x` 只在「条件 / 代码生成 / 自定义步骤」时出现，且 API 像「10 行能编出 exe」。 |
| **时机** | 自举金标前 **不大改** 自举用 `build.x` 三函数；产品侧可先做 **默认构建路径 + toml MVP**；DAG 产品级在自举后。 |

**口诀**：**默认声明式、进阶可编程、配置不进代码、策略不写参数。**

---

## 1. 现状地图（以代码为准 · 2026-07-21）

### 1.1 实际存在的「构建系统」是多层叠床

```text
用户 / 维护者入口（多入口，未统一）
  ./shux-build.sh
  ./build.sh
  compiler/Makefile          ← 自举 / g05 / bstrict 主战场（~大体积）
  compiler/build_tool        ← 由 build.x -E + build_runtime 链出
  shux build                 ← driver/build.x：找 build.x 再编译跑
        │
        ▼
  根目录 build.x             ← 策略「门面」：仅 3 个函数（见下）
  build_runner.x             ← 解释 argv：asm | legacy | use_asm_only 回退
  seeds/build_runtime.from_x.c  ← 真正 step 命令字符串 + system()
  scripts/build_shux_asm.sh  ← asm 产品路径
  env / CLI                  ← 真实配置面（SHUX_FORCE_* / g05 / bstrict）
  shux.toml                  ← ⚠ 示例；编译器不读
```

### 1.2 `build.x` 真源（策略层极薄）

权威文件：仓库根 [`build.x`](../build.x)。

| 符号 | 实现 | 实际角色 |
|------|------|----------|
| `build_use_asm_only()` | `return 1` | **配置伪装成策略**：本应是 `[build].backend = "asm"` |
| `build_get_step_count()` | `return 7` | 固定 7 步线性列表长度 |
| `build_get_step_at(i)` | `0→0, 1→6, 2→1, …` | 固定 **重排索引**，不是 DAG |

**没有**：`ProjectConfig`、Step 类型、dependOn、WriteFile、多 target 展开、读 toml、用户级 `addExecutable`。

### 1.3 执行权威在哪（双轨）

| 路径 | 文件 | 做什么 |
|------|------|--------|
| SHUX 入口 | [`build_runner.x`](../build_runner.x) | `entry`：解析 `asm`/`legacy`；调 `build_run_asm_build` / `build_run_legacy_steps` |
| C 冷路径 | [`compiler/seeds/build_runtime.from_x.c`](../compiler/seeds/build_runtime.from_x.c) | `build_run_step(step_id)` 内 **巨型 snprintf + system**；含 legacy 循环与 `build_use_asm_only` 分支 |
| 驱动子命令 | [`compiler/src/driver/build.x`](../compiler/src/driver/build.x) | `cmd_build` → 无参时 `driver_build_build_x()`，有参时走编译路径 |

`build_runner` 与 seed C **都实现了「按 step 顺序跑」**，且 `build_use_asm_only` 语义两边都懂 → **双权威隐患**（与 AGENTS.md 铁律冲突；中期必须收敛）。

### 1.4 `shux.toml` / std.config 真状态

| 项 | 状态 |
|----|------|
| 根目录 `shux.toml` | **设计示例**；文内自注「自举完成后再实现」 |
| `std/config` | TOML 解析 + merge **有 gate**，**未**接到 `main_cmd_build` |
| 真实配置面 | Makefile、env（`SHUX_*`）、CLI、硬编码 step 命令 |

### 1.5 与「zig 级 build」的差距（一表）

| 能力 | zig build.zig | SHUX 现状 | 差距 |
|------|---------------|-----------|------|
| 用户写 10 行出 exe | ✅ | ❌ 无 `addExecutable` 公共 API | 大 |
| 声明式默认（无 build 脚本） | ❌ 几乎总要 build.zig | 设计有 toml；**未实现** | 大 |
| DAG + 并发 | ✅ | 线性 7 步 + system | 大 |
| 配置静态可读 | 0.17 序列化补课 | toml **设计**可读 | 中（方向对、未接线） |
| 交叉 / profile | ✅ | 靠 Makefile/脚本 | 大 |
| 自举/compiler 构建 | 自己 dogfood | **Makefile + build_tool 专用** | 不同问题域 |

### 1.6 对旧版本文档的纠偏

| 旧表述倾向 | 校准 |
|------------|------|
| 「策略与 zig 同样强大」 | **目标**成立，**现状不成立**。现状策略表达力 ≈ 固定数组 + shell 外包。 |
| 「配置比 zig 简单 10 倍」 | **架构上**对；**用户今天**仍面对 Makefile/env，并不简单。 |
| 「`<1ms` / 15x 快」 | **未测**的架构推论，**不得**当验收 KPI；实现后应用基准再写。 |
| 示例 API 已像交付 | 均为 **愿景伪代码**；`ProjectConfig` 仅存在于分析文。 |
| 「自举期间 build.x 三函数不动」 | **对**（避免砸 bootstrap）；但 **产品默认路径**（`shux build` 编用户项目）可另线设计，勿与 compiler 自举 step 表绑死。 |

---

## 2. zig build.zig 设计剖析（保留 · 对照用）

### 2.1 哲学：构建即代码

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);
}
```

- 图灵完备；与源码同语言。  
- 一切参数也在代码里 → IDE/CI **必须执行**才见配置。  
- 0.17 configure/maker 两阶段：用序列化补「配置即数据」——证明正交拆分有价值，**不是**证明 SHUX 已交付。

### 2.2 值得学的（强大从哪来）

1. **`std.Build` 对象**：用户不手搓拓扑，只 `add*` + `dependOn`。  
2. **Step 类型族**：Compile / Run / WriteFile / Install —— 能力封装在库里。  
3. **标准选项**：`standardTargetOptions` / `standardOptimizeOption` —— 常见事一行。  
4. **命名 step**：`zig build test` / `zig build run`。  
5. **缓存与并行**：执行器成熟（SHUX 长期才追）。

### 2.3 要避开的

| 痛点 | SHUX 对策 |
|------|-----------|
| 改 target 也要改代码 | 参数进 `shux.toml` + CLI |
| 简单项目也要 10 行 build 脚本 | **默认零 build.x** |
| 配置不可静态读 | toml 权威 |
| 构建脚本膨胀成第二应用 | 行数阈值 + 「是配置还是策略」审查 |
| 包格式另起炉灶（ZON） | 依赖声明用 TOML（远期） |

---

## 3. 正交设计哲学（保留并收紧）

### 3.1 配置（数据）vs 策略（代码）

| 维度 | shux.toml | build.x |
|------|-----------|---------|
| 性质 | 声明式数据 | 命令式策略 |
| 表达 | 参数（what） | 逻辑（how / when / order） |
| 静态消费 | ✅ IDE/CI | ❌ 须执行（或将来序列化缓存，非默认） |
| 覆盖 | file → env → CLI | 只读 **已 merge** 的 `ProjectConfig` |
| 类比 | `Cargo.toml` | 加强版 `build.rs` + 可选 DAG（**不是** Cargo 的全部） |

### 3.2 三条铁律

1. **参数权威唯一**：`target` / `opt` / `backend` / `features` / `out-dir` 等 → **只** shux.toml（+ env/CLI merge）。  
2. **单向依赖**：build.x **可读** toml（经 `ProjectConfig`）；toml **永不**引用 build.x。  
3. **不重叠**：两边都能写的 → **写 toml**。build.x 出现重复字段 = bug。

### 3.3 边界图（目标态）

```text
shux.toml / 默认值 / env / CLI
        │  merge → ProjectConfig
        ▼
┌───────────────────────────────┐
│ 默认引擎（无 build.x）          │  单 crate：root + profile → Compile+Install
└───────────────────────────────┘
        │ 若存在 build.x
        ▼
┌───────────────────────────────┐
│ build.x：仅策略                 │  条件边、自定义 Step、codegen、外挂工具
│ 禁止返回「改 backend」类决策     │
└───────────────────────────────┘
        ▼
std.Build 执行器（拓扑 / 并行 / 缓存）
```

### 3.4 两个问题域必须拆开（易用关键）

| 问题域 | 用户 | 今天真实路径 | 长期 |
|--------|------|--------------|------|
| **A. 用户项目构建** | 应用/库作者 | 弱：`shux file.x -o`；几乎无统一 project build | `shux build` + toml + 可选 build.x |
| **B. 编译器自举构建** | 语言维护者 | Makefile + build_tool + 7-step + g05 | 可保留专用 `bootstrap.x` 或 `[workspace.bootstrap]`，**勿强迫应用作者理解 step 0..6** |

把 B 的 `build_get_step_at` 当成 A 的公共 API = **永久难用**。  
**决策**：产品文档与 API 以 **域 A** 为第一公民；域 B 单独命名空间。

---

## 4. 「强大」与「简单」同时成立的产品原则

### 4.1 三档用户体验（强制产品分层）

| 档 | 用户做什么 | 系统做什么 |
|----|------------|------------|
| **L0 零配置** | 目录里一个 `src/main.x` 或 `main.x` | `shux build` 用内置约定出 binary |
| **L1 只 toml** | 写 `shux.toml`：`[package]` + `[build]` + 可选 profile | 无 `build.x`；引擎展开默认 Compile/Install/Test |
| **L2 可编程** | 再加薄 `build.x` | 调 `std.build` API；读 `cfg`；加自定义 step |

**成功标准**：官方示例与 README **默认停在 L0/L1**；L2 教程单独一章。  
若新人第一课必须写 `build_get_step_at` → **失败**。

### 4.2 强大的定义（验收语言）

「强大」= 能表达 zig 常用策略，而不是「图灵完备」空话：

| # | 能力 | 最小验收 |
|---|------|----------|
| P1 | 多产物 | 同仓库 exe + lib |
| P2 | 依赖边 | test 依赖 exe 编完；run 依赖 install |
| P3 | 条件 | `if (cfg.is_windows) skip ...` / 按 feature 加文件 |
| P4 | 构建期生成 | WriteFile / 跑小工具生成 `.x` 再编 |
| P5 | 外挂命令 | Run step（fmt、codegen、打包） |
| P6 | 命名入口 | `shux build test` / `run` / `install` |
| P7 | 矩阵 | toml `[[target]]` × profile，引擎或 build.x 展开 |
| P8 | 缓存 | 未改输入不重编（可后置，但要有位） |

### 4.3 简单的定义（验收语言）

| # | 体验 | 最小验收 |
|---|------|----------|
| S1 | Hello 无需 build.x | `shux new` + `shux build` 绿 |
| S2 | 改 target 只改 toml 或 `--target` | 不改 build.x |
| S3 | 10 行 build.x 完成自定义 exe | 对标 zig 示例量级 |
| S4 | 报错指人 | 「字段 X 属于 shux.toml」/「缺少 root」 |
| S5 | `shux build --help` / `--print-config` | 列出生效配置与来源（file/env/cli/default） |
| S6 | 不用懂自举 step 编号 | 应用文档零 `step_id 0..6` |

### 4.4 API 设计铁律（易写）

1. **库厚、脚本薄**：复杂逻辑在 `std.build`（或 `compiler` 内 build 运行时），不在用户 `build.x`。  
2. **动词少**：优先 `add_executable` / `add_library` / `add_test` / `add_run` / `depend_on` / `install`。  
3. **默认合理**：不传 target → host；不传 optimize → profile 默认。  
4. **字符串路径为主**（v1）：降低对高级泛型/comptime 的依赖；能力随语言增强再升级。  
5. **禁止魔法全局改配置**：build.x 内 `set_backend("c")` 若与 toml 冲突 → 硬错误。  
6. **一种执行器**：用户 build.x 与默认引擎共用 `BuildGraph` 执行，禁止第三套 system 拼接。

### 4.5 目标 API 草图（域 A · 易写优先）

> 伪代码；符号名实现时可微调，但 **形态**应保持「短」。

**L1 等价（引擎内建，用户无 build.x）**

```toml
# shux.toml
[package]
name = "hello"

[build]
root = "src/main.x"          # 或约定 src/main.x
default-target = "host"

[profile.release]
opt-level = 3
```

**L2 显式 build.x（仍短）**

```x
// build.x — 用户项目策略（读已 merge 的 cfg，不解析 CLI）
import("std.build");

export function build(b: *Build, cfg: *ProjectConfig): i32 {
  let exe = b.add_executable("hello", cfg.build.root);
  // target/optimize 已在 cfg；add_* 默认吃 cfg，无需再抄一遍
  b.install(exe);

  let t = b.add_test("tests/main.x");
  t.depend_on(exe);

  let run = b.add_run(exe);
  b.default_step(run);   // shux build 默认
  return 0;
}
```

**条件与生成（强大仍可读）**

```x
export function build(b: *Build, cfg: *ProjectConfig): i32 {
  let exe = b.add_executable("app", "src/main.x");
  if (cfg.feature_enabled("simd")) {
    exe.add_source("src/simd_accel.x");
  }
  if (cfg.host_os_is_windows()) {
    // 跳过 POSIX-only 工具 step —— 条件在策略层
  } else {
    let gen = b.add_run_cmd("tools/gen_tables", &["--out", "gen/tables.x"]);
    exe.depend_on(gen);
  }
  b.install(exe);
  return 0;
}
```

**域 B（维护者）单独入口，避免污染上面的心智**

```x
// bootstrap_build.x 或 build.x 内 #[cfg(bootstrap)] 模块 — 名称待定
// 可保留 step 表 / g05 调用；文档标注「仅 shux 仓库」
```

---

## 5. 配置简单：shux.toml 侧（与实现文对齐）

细节路线见 [shux-toml-实现分析.md](shux-toml-实现分析.md)。此处只钉与 build.x 的接口。

### 5.1 为何必须先 toml（才能「简单」）

没有 merge 后的 `ProjectConfig`，build.x 只能：

- 硬编码 `return 1`（`build_use_asm_only`），或  
- 自己读 env（再次配置即代码）  

两者都破坏「简单 + 正交」。

### 5.2 三层 merge（框架级，一次实现）

```text
defaults → shux.toml → env (SHUX_BUILD_*) → CLI (shux build --*)
```

- 新字段默认自动获得 env/CLI 形态（命名约定写进 toml 实现文）。  
- build.x **只**见最终 `ProjectConfig`。

### 5.3 静态消费

IDE/CI 读 toml 即可列 target/feature；**不**需要先编译 build.x。  
（若将来对 build.x 图做 LSP 智能提示，可再加可选序列化缓存——**不得**成为改 target 的前置。）

---

## 6. 策略强大：build.x 升级内容（域 A 优先）

### 6.1 当前能力（极薄）

见 §1.2。价值：证明「策略用 .x 写」链路可跑；**不能**当产品构建系统。

### 6.2 目标能力包（按优先级）

| 优先级 | 包 | 内容 | 依赖 |
|--------|----|------|------|
| **M0** | 默认引擎 | 无 build.x：root + profile → 编装 | toml MVP 或内置 default |
| **M1** | 薄 build.x | `build(b, cfg)` + add_executable/install/run/test | Build 对象 + 执行器 v0（可先线性） |
| **M2** | 依赖边 | depend_on；命名 step | 拓扑排序 |
| **M3** | Run / WriteFile | 外挂与生成 | 沙箱/cwd 约定 |
| **M4** | 矩阵展开 | 读 cfg.targets × profiles | toml 阶段 2 |
| **M5** | 并行 + 缓存 | 执行器增强 | 内容哈希 |
| **M6** | 包依赖 | `[dependencies]` | registry 路线 |

**不要**一上来复制 zig 全量 Step 类树；**M0→M2** 就能覆盖绝大多数「强大」叙事。

### 6.3 执行器与 step 命令的权威迁移

今天：`build_run_step` 内硬编码 cc 命令（域 B）。  

目标：

| 命令知识 | 权威 |
|----------|------|
| 如何把 `.x` 编成用户产物 | **编译器 driver / link_abi**（单一） |
| 步骤图怎么连 | **BuildGraph**（std.build 或 compiler build 运行时） |
| 用户是否多一个 gen 步骤 | **build.x** |
| 是否 release / 哪个 target | **ProjectConfig** |

禁止在用户 build.x 里拼 `cc -Wall ...` 长命令（难用且双权威）。

### 6.4 双权威收敛（G.7）

| 现状 | 目标 |
|------|------|
| `build_runner.x` 与 `build_runtime.from_x.c` 双份 legacy/asm 逻辑 | **一个** `entry` 策略；C 仅 FFI：`run_step` / `system`  primitive |
| `build_use_asm_only` 在 .x | 删除；改读 `cfg.build.backend` |
| step 顺序写在 build.x，命令写在 C | 域 B 可暂留；域 A 不走 step_id 表 |

---

## 7. 优越性对比（重写：架构 vs 现状）

### 7.1 架构潜力（方向）

| 维度 | zig | SHUX 目标架构 | 方向胜方 |
|------|-----|---------------|----------|
| 简单项目 | 常要写 build.zig | L0/L1 零脚本 | SHUX |
| 静态读配置 | 需执行/序列化 | toml 天生 | SHUX |
| 策略表达 | 强 | 同级（待做） | 平（目标） |
| 配置覆盖 | `b.option` 分散 | 三层 merge | SHUX |
| 生态格式 | ZON | TOML | SHUX |

### 7.2 工程现状（2026-07-21）

| 维度 | 谁更可用 |
|------|----------|
| 日常编 compiler | **Makefile / g05**（SHUX 自己） |
| 用户 `zig build` 级体验 | **zig 远胜** |
| 文档完整度（愿景） | SHUX 分析文多；**实现少** |

**对外话术纪律**：只宣称「架构选择」；**禁止**宣称「已比 zig build 更强/更快」直至 M2+ 有基准与示例。

---

## 8. 分阶段路线（可执行 · 与自举对齐）

### 8.1 阶段 S0 — 自举并行（现在）

**目标**：不砸 bootstrap；把边界写清。

| 做 | 不做 |
|----|------|
| 本文 + toml 实现文交叉链接 | 改 `build_get_step_*` 语义 |
| 记录 `build_use_asm_only` 越界债 | 大改 build_runtime 命令串 |
| 保证 `build_tool` / g05 路径绿 | 上线 DAG |
| 域 A/B 命名在文档固定 | 强迫应用使用 step_id |

### 8.2 阶段 S1 — 配置 MVP（自举后或编译器稳后）

**目标**：简单（S1–S2）先成立。

1. `config_load_project_or_default` 接 `main_cmd_build`。  
2. `[build].backend` 取代 `build_use_asm_only`。  
3. `--print-config`；无 toml 时 100% 旧行为。  
4. **M0 默认引擎**：约定 root 文件 → 调用现有 `shux -o` 链路（不必等完整 DAG）。

**验证**：hello 目录仅 toml（或零文件约定）可 `shux build`。

### 8.3 阶段 S2 — 薄 build.x + 执行器 v0（强大起步）

1. 引入 `std.build`（或 `shux.build`）**最小 API**：Build、add_executable、install、add_run、add_test。  
2. 用户 `export function build(b, cfg)`；无该函数则 M0。  
3. 执行器 v0：**线性或简单拓扑**，可先单线程。  
4. 收敛 build_runner / C 重复的 **用户路径** 逻辑。

**验证**：官方 `examples/build_basic` ≤15 行 build.x；S3 满足。

### 8.4 阶段 S3 — DAG / 生成 / 矩阵（强大对齐 zig 常用集）

1. depend_on + 命名 step（`shux build test`）。  
2. WriteFile / Run。  
3. `[[target]]` × profile 展开（数据在 toml，循环在引擎或 build.x）。  
4. 域 B：bootstrap 脚本化策略可选迁 `bootstrap_build.x`，与用户 API 隔离。

### 8.5 阶段 S4 — 并行、缓存、包（产品级）

并行调度、输入哈希缓存、`[dependencies]` 解析。  
对照 zig 做 **基准** 后再写性能表。

---

## 9. 关键设计决策（更新）

| 决策 | 选择 | 理由 |
|------|------|------|
| 架构 | toml + build.x 正交 | 静态消费 + 可编程 |
| 默认路径 | **无 build.x** | 简单优先 |
| 第一公民 | **用户项目构建（域 A）** | 易用；自举是维护者域 |
| 配置权威 | shux.toml + merge | 消灭 `build_use_asm_only` 类越界 |
| build.x 入口 | `build(b: *Build, cfg: *ProjectConfig)` | 单一、可测、不读 CLI |
| 厚库薄脚本 | 能力在 std.build | 防膨胀成第二 zig |
| step_id 表 | **仅域 B 遗留** | 不进用户教程 |
| 双权威 | 收敛 runner；C 仅 primitive | AGENTS.md G.7 |
| 性能数字 | 实现后实测 | 禁止空口 15x |
| 自举期 | 三函数冻结策略语义 | 安全 |

---

## 10. 风险与对策

| 风险 | 对策 |
|------|------|
| build.x 膨胀成 build.zig | L0/L1 默认；500 行审计；配置归 toml |
| 自举与用户 API 缠死 | 域 A/B 分离；文档分册 |
| 双权威回归 | 改步骤只改一处；gate 查符号 |
| 过早 DAG | M0–M2 先线性可用 |
| 用户仍要学 Makefile | S1 后 README 入口改为 `shux build` |
| toml 与 build.x 职责吵架 | `--print-config` + 明确错误文案 |
| 语言能力不足（泛型/FP） | v1 字符串/句柄 API；随语言升级 |

---

## 11. 与现有文档 / 代码索引

| 路径 | 角色 |
|------|------|
| [shux.toml](../shux.toml) | 配置设计示例（未接线） |
| [shux-toml-实现分析.md](shux-toml-实现分析.md) | 配置层实现阶段 |
| [build.x](../build.x) | 当前策略门面（3 函数） |
| [build_runner.x](../build_runner.x) | .x 执行入口 |
| [compiler/seeds/build_runtime.from_x.c](../compiler/seeds/build_runtime.from_x.c) | C 执行后端（step 命令权威·待收敛） |
| [compiler/src/driver/build.x](../compiler/src/driver/build.x) | `shux build` 子命令 |
| [std/config](../std/config/) | TOML 解析能力 |
| [compiler/Makefile](../compiler/Makefile) | 自举主路径（域 B） |
| [自举方法.md](自举方法.md) · [自举进度.md](自举进度.md) | 何时允许动产品构建链 |

---

## 12. 检查清单（做强且易用时每波打勾）

### 易用

- [ ] 新用户无 build.x 能 `shux build`  
- [ ] 改 target/opt 不改 build.x  
- [ ] 示例 build.x ≤ 15 行出 exe  
- [ ] `--print-config` 标明来源  
- [ ] 用户文档不出现自举 step_id  

### 强大

- [ ] add_executable / test / run / depend_on  
- [ ] 条件与 feature 可分支  
- [ ] 至少一种构建期生成  
- [ ] 命名 step  
- [ ] （后）矩阵与缓存  

### 纪律

- [ ] 无配置字段只存在于 build.x  
- [ ] 无第二套执行器拼 cc  
- [ ] seed/.x 策略同语义或 C 降为 FFI  
- [ ] 未实测不写性能倍数  

---

## 13. 一句话总结

**正交分工（toml 数据 + build.x 策略）在架构上优于 zig「配置即代码」，但今天 SHUX 仍停留在「固定 7 步 + C system + Makefile」——强大与简单都尚未交付。交付路径是：先默认引擎与 toml 让 90% 用户零脚本，再提供薄而稳的 `std.build` API 让 10% 场景可编程；自举 step 表退出用户心智；双权威收敛；用示例行数与门禁而非口号验收「既强大又易写易用」。**

---

## 14. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-21 | 初版：正交架构 vs zig、能力升级路线（偏愿景） |
| 2026-07-21 | **全面重写**：§1 现状校准；域 A/B 拆分；强大/简单双验收；M0–M6 与 S0–S4；API 草图；纠偏性能与「已等价 zig」表述；检查清单 |
