# xlang.toml 实现分析（路线图 · 现状校准 · 增强）

> **文档目的**  
> 1. 说明如何把「CLI + Makefile + env」迁到 **声明式 `xlang.toml`**，并与 **`build.x` 策略层**正交。  
> 2. **按仓库真实现状校准**：哪些已有、哪些示例过宽、哪些能力假绿。  
> 3. 补齐旧文不足：**MVP schema 子集**、发现路径、键容量、env 命名表、诊断、双问题域、与 build 默认引擎的接口、验收门禁。  
>
> **配套**  
> - 示例（**未接线**）：[`xlang.toml`](../xlang.toml)  
> - 策略层：[`build-x-强大配置能力分析.md`](build-x-强大配置能力分析.md)  
> - 解析库：[`std/config/`](../std/config/) · gate `tests/run-std-config-gate.sh`  
> - 自举：[`自举方法.md`](自举方法.md) · [`自举进度.md`](自举进度.md) · skill 产品闸门  
>
> **最后更新**：2026-07-21（全面重写：校准 + 增强 + 可执行 MVP）。

---

## 0. 一句话结论

| 维度 | 结论 |
|------|------|
| **时机** | **产品接线**（`main_cmd_build` 读 toml）放在 **编译器产品路径稳定后**（优先自举金标 / tip 可 L4）；**不是**「一个字段都不能提前」。可提前做：schema 冻结、golden 解析测、std/config 扩容/数组。 |
| **鸡生蛋** | 仅 **冷启动编出第一份 xlang 二进制** 不能依赖 toml。二进制已存在后的 `xlang build` / 用户项目 **可以且应该** 读 toml。 |
| **分层** | L1 `std/config` → L2 `ProjectConfig` → L3 CLI merge → L4 消费方（compile / link / test / **默认构建引擎** / 可选 build.x）。 |
| **与 build.x** | toml = **参数权威**；build.x = **策略权威**。删除 `build_use_asm_only` 类越界（详见 build-x 文）。 |
| **简单优先** | **MVP schema ≪ 示例全文**。90% 用户：`[package]` + `[build].root` + 可选 profile；完整示例是 **语言仓库 / 远期** 超集。 |
| **当前阻塞（实现前必解）** | ① `CFG_MAX_ENTRIES=64` 装不下完整示例键空间；② 示例用了 **array-of-string** / **inline table**，解析器 v1 **未支持**；③ 无 `ProjectConfig`、无 driver 接线。 |

**口诀**：**先子集可跑、后来源可查、配置不进 build.x、自举冷启动仍 Makefile。**

---

## 1. 现状地图（以代码为准 · 2026-07-21）

### 1.1 真实配置面（无 toml 消费）

| 维度 | 当前驱动 | 权威触点（示意） |
|------|----------|------------------|
| 编译单文件 | `xlang file.x -o` / CLI | `main.x` · `driver/compile.x` |
| backend | env `XLANG_FORCE_LINK_BACKEND` 等 | link / backend 路径 |
| freestanding | CLI `-freestanding` · 全局 | `compile.x` · 零 libc 策略文 |
| target / cfg | `#[cfg]` + 有限 override | `cfg_eval.x` · `ir/target` |
| opt / LTO | CLI / Makefile 碎片 | `DriverCompileState.opt_level*` |
| 自举 / g05 / bstrict | **Makefile + 大量 `XLANG_*` env + shell** | `compiler/Makefile`（~3k 行）· `tests/run-all-bstrict.sh` |
| 项目策略 | `build.x` 三函数 + `build_runtime` system | 见 build-x 文 §1 |
| **xlang.toml** | **仅示例**；编译器 **零读取** | 根目录文件头自注 |

### 1.2 已有可复用能力（诚实成熟度）

| 能力 | 位置 | 成熟度 | 说明 |
|------|------|--------|------|
| TOML 子集解析 | `std/config` | ✅ gate 绿 | 扁平键、`[section]`、`[a.b]`、`[[array]]`、str/i32/bool |
| 多源 merge | `load_toml` / `load_env_prefix` / `merge` / `set_string` | ✅ | 有 `get_*_meta` **来源** |
| YAML | 同模块 | ✅ 旁路 | **产品权威用 TOML**；YAML 不进 xlang.toml |
| CLI 子命令 | `main_cmd_build` 等 | ✅ 骨架 | **尚未** load project |
| feature cfg | `cfg_eval.x` | ⚠️ 部分 | 需稳定「表注入」API |
| target 三元组 | ir/target · driver | ⚠️ 部分 | 与 toml triple 字符串需归一化表 |
| profile 概念 | — | ❌ | 无 debug/release 一等公民 |
| 默认项目构建引擎 | — | ❌ | 见 build-x M0 |

### 1.3 std/config 硬限制（旧文低估 · 必写进路线）

| 限制 | 代码事实 | 对 xlang.toml 影响 |
|------|----------|-------------------|
| **`CFG_MAX_ENTRIES = 64`** | `std/config/config.x` | 完整示例扁平键 **很可能 >64** → 中途 `CFG_ERR_FULL` |
| **`CFG_KEY_MAX = 128` / `CFG_VAL_MAX = 256`** | 同 | 长 path / 多 feature 列表受限 |
| **`CFG_FILE_MAX = 65536`** | 同 | 一般够用；超大生成 toml 需警惕 |
| **无 array-of-string** | README 限制 | 示例 `target = ["a","b"]`、`default = ["std","async"]`、`exclude = []` **当前解析不了** |
| **无 inline table** | README 限制 | 示例 `env = { "TEMP" = "..." }`、`dep = { version = "..." }` **当前解析不了** |
| **无类型 schema** | 仅 kv 存储 | 错类型要在 Layer 2 报友好错 |
| **无「未知键」策略** | — | 需产品决策：warn / error / ignore |

**阶段 0（实现接线前）建议先做**：

1. 提高 `CFG_MAX_ENTRIES`（建议 **256 或 512**，按实测键数 + 余量）。  
2. 明确 **MVP schema 只用** 标量 + `[section]` + 可选 `[[target]]` 平铺；**或** 先扩展 array-of-string。  
3. 为「根目录完整示例」加 **golden 解析测试**：今日应 **红** 或标 `KNOWN_UNSUPPORTED`，避免文档假绿。

### 1.4 示例 `xlang.toml` 与解析器的裂缝

| 示例写法 | 解析器 v1 | MVP 建议 |
|----------|-----------|----------|
| `target = ["x86_64-linux", …]` | ❌ array-of-string | 暂用单 `default-target`；或多行 `[[build.target]]` / 逗号字符串 `targets = "a,b"`（过渡） |
| `[features] default = ["std","async"]` | ❌ | `default-std = true` 等布尔；或扩展解析器 |
| `env = { "TEMP" = "..." }` | ❌ inline table | `[[target.env]]` 两列表 或 `env.TEMP = "..."` 平铺 |
| `dependencies` inline table | ❌ | 阶段 4 再定；占位注释即可 |
| 自举专用 `tool.xlang` / `l4-cold-test` | 可解析（标量） | **仅 xlang 语言仓库**；用户模板不要拷贝 |

### 1.5 两个问题域（旧文混为一谈 · 增强）

| 域 | 谁的 toml | 目的 | 是否阻塞用户体验 |
|----|-----------|------|------------------|
| **A. 用户项目** | 应用/库的 `xlang.toml` | `xlang build/run/test` 简单强大 | **第一优先** |
| **B. 语言仓库** | 本仓库根 `xlang.toml` 超集 | 自举工具字段、bstrict、seed-pin | 维护者；**勿逼用户理解** |

**决策**：schema 分 **Core（A）** 与 **Workspace-Tooling（B，`[tool.xlang]` / 可选 `[workspace]`）**。  
Core 稳定后才把 B 字段当一等公民；Makefile 仍可长期服务 B 的冷启动。

### 1.6 对旧版本文的纠偏

| 旧表述 | 校准 |
|--------|------|
| 「全部字段自举后实现」一刀切 | 改为：**接线**在稳定后；**解析扩容 / schema 冻结 / golden** 可并行 |
| Layer1「零改动」 | 与完整示例矛盾；MVP 零改动 **仅当** schema 避开数组/inline **且** 提高 entries 或极简键集 |
| 阶段 1 就接 `[[target]]` 矩阵 | 过重；MVP 用 host + 单 `--target` |
| Makefile 阶段 4 才退化 | 可维持；但 **用户路径** 不依赖 Makefile 退化 |
| 未写发现路径 / print-config / 键容量 | 本文补齐 |
| 与 build.x 默认引擎（L0 零配置） | 旧文几乎只谈 compiler flags；本文与 build-x **M0** 对齐 |

---

## 2. 设计目标

### 2.1 核心目标

1. **声明式默认**：有 `xlang.toml`（或约定 root）即可 `xlang build`。  
2. **可覆盖**：`defaults < file < env < CLI`（CLI 最高）。  
3. **可静态读**：IDE/CI **不执行** build.x 也能读 target/feature/version。  
4. **可追溯**：`xlang build --print-config` 打印每个生效键的 **值 + 来源**（toml/env/cli/default）。  
5. **零回归**：无 toml 时行为 = 今日 CLI-only。  
6. **正交 build.x**：参数不进策略文件；策略不改 backend/opt。  
7. **简单**：Core schema 一页纸能讲完。

### 2.2 非目标（v1 / Core）

| 非目标 | 说明 |
|--------|------|
| 包管理下载/lockfile | `[dependencies]` 仅注释或解析后 ignore + warn |
| workspace 多包 | 单 package |
| 在线 registry | 远期 |
| 用 toml 替代 bootstrap 冷启动 | 永不（鸡生蛋） |
| 完整 lint 引擎配置化 | `[lint]` 可后置；先 warn 未实现键 |
| 保证示例全文一次 parse 成功 | 先扩解析器或缩示例 |

### 2.3 成功标准（产品语言）

| ID | 标准 |
|----|------|
| T1 | `examples/hello` 级目录：最小 toml 或零 toml 约定 → `xlang build` 出可跑 binary |
| T2 | 改 `default-target` / `opt` **只改 toml 或 CLI**，不改 build.x |
| T3 | `--print-config` 来源正确（测 env 覆盖 file） |
| T4 | 无 toml：bstrict / 产品矩阵不回归 |
| T5 | 未知键策略有文档且测试覆盖 |
| T6 | Core schema 文档与 `xlang.toml.core.example` **解析 gate 绿** |

---

## 3. Schema 设计

### 3.1 分层：Core vs Full

```text
Core（MVP / 用户默认模板）
  version?
  [package] name, edition?
  [build] root, default-target, out-dir, backend?, link-std?, freestanding?
  [profile.dev] / [profile.release]  最小 opt-level / debug
  [features]  仅 bool 键（无 default 数组）

Full（语言仓库 + 远期）
  + [build].target 多目标 / self-host / …
  + [[target]] 矩阵 + linker-args + env
  + [tool.xlang] prove-level / seed-pin / windows-hybrid
  + [test] gate / parallel / timeout / exclude
  + [lint] / [fmt] / [docs]
  + [dependencies]*
```

**决策**：仓库根 [`xlang.toml`](../xlang.toml) 保持 **Full 设计稿** 可以，但必须在文件头标明：

- 哪些键 **Core 已实现**  
- 哪些键 **需要解析器扩展**  
- 哪些键 **仅 tool 域、用户勿抄**

并新增 **`xlang.toml.core.example`**（或 `docs/examples/xlang.toml`）给用户拷贝——**只含 Core**。

### 3.2 Core 字段表（MVP 权威）

| 键 | 类型 | 默认 | 消费方 | 阶段 |
|----|------|------|--------|------|
| `version` | string | 无 | metadata / `--version` 展示（可选） | 1+ |
| `[package].name` | string | 目录名 | 产物名 / 包 | 1 |
| `[package].edition` | string | 实现默认 | parser 开关（后置） | 3 |
| `[build].root` | string | `src/main.x` 或 `main.x` 探测 | **默认引擎 M0** | **1** |
| `[build].default-target` | string | `host` | target 选择 | 1 |
| `[build].out-dir` | string | `build` | 输出路径 | 1 |
| `[build].backend` | string | `asm` | link backend；**取代** `build_use_asm_only` | 1 |
| `[build].link-std` | bool | true | link_abi | 1 |
| `[build].freestanding` | bool | false | 或放 features；与 `-freestanding` 对齐 | 1 |
| `[build].optimization` | i32/string | profile 决定 | 若无 profile 时的快捷 | 1–2 |
| `[features].*` | bool | false | cfg_eval 注入 | 1 |
| `[profile.release].opt-level` | i32 | 3 | codegen / cc flags | 2 |
| `[profile.release].lto` | bool/string | false | link | 2 |
| `[profile.dev].opt-level` | i32 | 0 | | 2 |
| `[profile.dev].debug` | bool | true | | 2 |

### 3.3 Full 增量字段（摘要 · 映射 env）

完整映射仍服务语言仓库；**实现顺序低于 Core**。

| toml | 今日近似 env/机制 | 域 | 阶段 |
|------|-------------------|----|------|
| `[build].self-host` | g05 / bootstrap env | B | 3 |
| `[build].link-rt` | freestanding 反面 | A | 2 |
| `[build].target` 多值 | 需数组支持 | A | 2+ |
| `[[target]].*` | Makefile 交叉碎片 | A | 2–3 |
| `[tool.xlang].prove-level` | `XLANG_L4_COLD` 等 | B | 3 |
| `[tool.xlang].seed-pin` | seeds pin 策略 | B | 3 |
| `[tool.xlang].windows-hybrid` | Windows hybrid | B | 3 |
| `[test].*` | bstrict 脚本 | B→A | 3 |
| `[lint]` / `[fmt]` | check/fmt 硬编码 | A | 3 |
| `[dependencies]` | 无 | A | 4 |
| `[docs]` | 无 | A | 4+ |

### 3.4 与「假 features」去重

今日示例把 **产品 feature**（`async`/`simd`）和 **工程开关**（`l4-cold-test`/`bootstrap-seed`）都塞进 `[features]`。

**增强决策**：

| 类别 | 放置 |
|------|------|
| 语言/库 `#[cfg(feature=…)]` | `[features]` |
| 仅影响 CI/自举/证明 | **`[tool.xlang]`** 或 `[test]`，**禁止**进默认 feature 集 |

避免 `default = ["std","async","l4-cold-test"]` 这种污染。

### 3.5 命名与 env 派生（稳定表）

| toml 路径 | 内部 snake | 建议 env（override） |
|-----------|------------|----------------------|
| `build.backend` | `build.backend` | `XLANG_BUILD_BACKEND`（兼容旧 `XLANG_FORCE_LINK_BACKEND` **别名**） |
| `build.default-target` | `build.default_target` | `XLANG_BUILD_DEFAULT_TARGET` |
| `build.out-dir` | `build.out_dir` | `XLANG_BUILD_OUT_DIR` |
| `build.root` | `build.root` | `XLANG_BUILD_ROOT` |
| `build.freestanding` | `build.freestanding` | `XLANG_BUILD_FREESTANDING` / 与 CLI 对齐 |
| `features.<name>` | `features.<name>` | `XLANG_FEATURE_<NAME>`（大写、`-`→`_`） |
| profile 选择 | — | 无 env 首选；CLI `--release` / `--profile` |

**纪律**：新增 Core 键必须 **同 PR** 更新本表 + `--help` + 测试。

### 3.6 发现路径（旧文缺失）

```text
1. CLI --config PATH          → 唯读该文件（不存在则硬错）
2. 否则从 cwd 起向父目录找 xlang.toml（上限 N=16）
3. 找不到 → ProjectConfig = defaults（零文件模式）
4. 不读取「git root 特例」除非与父目录行走重合
```

**工作区根**：选中 toml 所在目录为 `project_root`；`root` / `out-dir` 相对 **该目录**。

### 3.7 未知键 / 弃用键策略

| 模式 | 行为 | 默认 |
|------|------|------|
| `strict = true`（`[tool.xlang].strict-config` 或 CLI） | 未知键 **error** | 语言仓库 CI 可开 |
| 默认 | 未知键 **warn** 一次 | 用户友好 |
| 已弃用键 | warn + 映射到新键 | 迁移期 |

---

## 4. 实现分层（增强版 4+1）

```text
┌──────────────────────────────────────────────────────────┐
│ Layer 4b  策略（可选 build.x）                              │
│   只读 ProjectConfig；构造 Step；不改 backend/opt          │
├──────────────────────────────────────────────────────────┤
│ Layer 4a  默认构建引擎 M0（无 build.x）                     │
│   root + profile → compile/link/install                    │
├──────────────────────────────────────────────────────────┤
│ Layer 3   CLI：parse flags → merge 进 Config / ProjectConfig│
│   --print-config / --release / --target / --features …   │
├──────────────────────────────────────────────────────────┤
│ Layer 2   ProjectConfig：类型化 + 校验 + profile 继承      │
│   compiler/src/driver/project_config.x（名可议）           │
├──────────────────────────────────────────────────────────┤
│ Layer 1   std/config：TOML/env 存储 + meta 来源            │
└──────────────────────────────────────────────────────────┘
         ↑ 冷启动 bootstrap：Makefile（不经 L1–4）
```

### 4.1 Layer 1 — 解析

**复用** `std/config` API：

```text
config_new → load_toml_file(path) → load_env_prefix("XLANG_", 1)
→（Layer3）merge CLI overlay 或 set_string
→ get_* / get_*_meta
```

**实现前补丁（强烈建议独立小步，不碰 main）**：

| 补丁 | 优先级 | 验收 |
|------|--------|------|
| `CFG_MAX_ENTRIES` ≥ 256 | P0 | 完整示例键可装下（在数组支持后） |
| array-of-string **或** Core 改写示例 | P0 | core example gate 绿 |
| inline table 或 env 平铺约定 | P1 | windows `TEMP` 可表达 |
| 解析错误带 **行号** | P1 | 用户可修 |

### 4.2 Layer 2 — ProjectConfig

**新模块**（建议名）：`compiler/src/driver/project_config.x`  
（旧文 `config.x` 易与 `std.config` 混淆。）

职责：

1. `project_load(path|null) -> ProjectConfig`  
2. 默认值填充  
3. profile `inherits` 递归（环检测）  
4. feature 表 → 给 cfg_eval 的稳定缓冲  
5. 校验：非法 backend、空 root、互斥 freestanding+link-std 等  
6. **不**执行构建

结构体保持「扁平 C 友好」（定长缓冲 / 句柄），避免过早依赖未稳泛型。

### 4.3 Layer 3 — CLI

```text
xlang build [flags]
  --config PATH
  --print-config          # 打印后 exit 0（可加 --print-config-json 远期）
  --release | --debug | --profile NAME
  --target TRIPLE
  --backend NAME
  --features a,b | --no-default-features | --all-features
  --out-dir DIR
  --freestanding
  --verbose / -v          # 打印选中 project_root 与 toml 路径
```

**铁律**（与命令行规范一致）：flag **必须**挂在子命令后；禁止 `xlang --release` 隐式 build。

伪代码：

```text
fn main_cmd_build(argc, argv):
  path = find_config(argv)
  proj = project_load_or_default(path)
  apply_cli(proj, argv)
  if print_config: dump(proj); return 0
  if has_build_x: return run_build_x(proj)
  return default_engine_build(proj)   // M0
```

### 4.4 Layer 4a — 默认引擎（与 build-x 文对齐）

无 `build.x` 时：

1. 解析 `proj.build.root`（或探测）  
2. 应用 profile → opt/lto/strip  
3. 调现有 compile/link 路径产出到 `out-dir`  
4. 返回码与今日 `xlang -o` 一致语义  

这是 **「配置简单」的主交付**，比先做 `[[target]]` 矩阵更重要。

### 4.5 Layer 4b — build.x

见 [`build-x-强大配置能力分析.md`](build-x-强大配置能力分析.md)：

- 入口 `build(b, cfg)`  
- **禁止** `build_use_asm_only`  
- 域 B 自举 step 表不进用户 API  

### 4.6 Makefile（域 B）

| 阶段 | Makefile |
|------|----------|
| 接线后初期 | **不变**；自举仍 env |
| 中期 | 可选 `make test` → `xlang test`（若已实现） |
| 长期 | 薄壳：bootstrap 冷启动 + clean；**不**要求用户项目有 Makefile |

---

## 5. 字段映射总表（Core + 常用 Full）

| toml 字段 | 当前等价物 | 实现触点 | 阶段 | 域 |
|-----------|------------|----------|------|-----|
| `[build].root` | 无（用户手写路径） | 默认引擎 | **1** | A |
| `[build].default-target` | host 检测 | target + cfg | 1 | A |
| `[build].backend` | `XLANG_FORCE_LINK_BACKEND` / `build_use_asm_only` | main + link；**删越界** | 1 | A |
| `[build].out-dir` | 无统一 | emit/link | 1 | A |
| `[build].link-std` | `XLANG_SKIP_STD_ENSURE` 等 | link_abi | 1 | A |
| `[build].freestanding` | `-freestanding` | compile state | 1 | A |
| `[features].*` bool | cfg + env | cfg_eval 注入 | 1 | A |
| `[package].name` | 无 | 产物名 | 1 | A |
| `version` | 硬编码 version | meta | 2 | A |
| `[profile.*]` | Makefile -O | codegen/link flags | 2 | A |
| `[[target]]` | 手工交叉 | target_resolve | 2–3 | A |
| `[build].self-host` | bootstrap env | 仅仓库 | 3 | B |
| `[tool.xlang].*` | 多 env | Makefile/脚本逐步读 | 3 | B |
| `[test].*` | bstrict 脚本 | `xlang test` | 3 | A/B |
| `[lint]`/`[fmt]` | 硬编码 | check/fmt | 3 | A |
| `[dependencies]` | 无 | registry | 4 | A |

---

## 6. 实现阶段（重排：可交付优先）

### 阶段 0 — 地基（可与自举并行 · **不接 main**）

| 动作 | 验收 |
|------|------|
| 评估并提高 `CFG_MAX_ENTRIES` | 单测装入 ≥128 键 |
| 冻结 **Core schema** 文 + `xlang.toml.core.example` | 文档审阅 |
| golden：core example **必须**被 `std/config` 加载成功 | 新 gate 或并入 config gate |
| 标记 Full 示例中 unsupported 语法 | CI 注释或 `parse_full` expected-fail |
| env 命名表进本文 §3.5 | 已写 |

**自举纪律**：只动 `std/config` + tests；**不**改 bootstrap 默认路径语义。

### 阶段 1 — MVP 接线（产品可用）

**目标**：T1–T4 对 Core 成立。

1. `project_config.x`：load + defaults + 校验  
2. `main_cmd_build` / `run`：find config → merge CLI  
3. `--print-config`  
4. **默认引擎 M0**（无 build.x）  
5. `backend` 读 toml/env/cli；**计划删除** `build_use_asm_only`（与 build-x 同步，注意 build_tool 回归）  
6. features bool → cfg 注入（最小集）  

**验证**：

- 无 toml：旧行为  
- 最小 toml：指定 root 能 build  
- `XLANG_BUILD_BACKEND` / 旧 env 别名覆盖  
- Ubuntu + mac 产品矩阵相关子集  

**触点**：`driver/project_config.x`、`main.x`、`driver/build.x` 或 compile 路径、`cfg_eval`、tests 新目录 `tests/project-config/`。

### 阶段 2 — profile + 单 target 增强

- `profile_resolve` + `--release`/`--debug`  
- opt-level / lto / strip 真正影响产物（diff 或 obj 符号可观察）  
- `[[target]]` **可选**：有则合并；无则 default-target  
- array-of-string（若未在阶段 0 做）以支持多 target 列表  

### 阶段 3 — test / lint / fmt / tool 域

- `xlang test` 读 `[test]`  
- check/fmt 读 lint/fmt（未实现键 warn）  
- `[tool.xlang]` 供语言仓库文档化；Makefile **可选**读取（非必须删 env）  
- edition 只影响新语法默认  

### 阶段 4 — 依赖与生态

- dependencies 解析 + lockfile + 缓存  
- Makefile 进一步薄壳化（仍保留 bootstrap）  

---

## 7. 与 build.x / 默认引擎的契约

| 问题 | 权威 |
|------|------|
| backend / target / opt / features / out-dir / root | **ProjectConfig（toml+env+cli）** |
| 多 crate 依赖边、codegen step、条件跳过 | **build.x** |
| 无 build.x 时编什么 | **默认引擎 + build.root** |
| 编译器自举 7 step | **域 B**（build_tool / Makefile），不是用户 Core |

删除 `build_use_asm_only()` 的验证见 build-x 文；**本配置文负责**提供 `cfg.build.backend` 唯一来源。

---

## 8. 风险与约束（增强）

### 8.1 自举 / 产品链

| 风险 | 缓解 |
|------|------|
| 改 main 砸 tip | 无 toml 旧路径优先测；L4+bstrict；分 commit |
| build_tool 依赖 `build_use_asm_only` | 删除时改 runner 读默认 asm 或 env；单测 build_tool |
| project_config 进自举对象 | 先 hybrid；链上按需；遵守 G.7 seed 对齐 |

### 8.2 解析与容量

见 §1.3；**未扩容前禁止**宣称 Full 示例可加载。

### 8.3 语义坑

| 坑 | 对策 |
|----|------|
| freestanding 与 link-std 同时 true | Layer2 硬错 |
| profile 继承环 | 检测 depth 上限 |
| feature 名与 cfg 不一致 | 对照表 + 测试 |
| Windows 路径 / TEMP | PLATFORM 注释；平铺 env |
| 多 toml 嵌套工程 | 仅向上找一份；workspace 后置 |

### 8.4 安全

`[[target]].env` 注入子进程 → 文档警告；限制键白名单（可选）。

### 8.5 文档漂移

示例 Full / Core / 实现阶段不一致 → **阶段 0 golden** 锁 Core；Full 头注释维护「支持矩阵」。

### 8.6 双权威配置

禁止第二处硬编码 backend（build.x、Makefile 默认、main 魔法）长期三份；迁移期允许 **别名 env**，但 `--print-config` 必须显示最终值。

---

## 9. 验证策略

### 9.1 门禁分层

| 门禁 | 内容 |
|------|------|
| `run-std-config-gate` | 解析库回归 |
| **新** `run-xlang-toml-core-gate` | core example 加载 + 关键 get |
| **新** `run-project-config-unit` | profile 继承、校验、来源 meta |
| 产品矩阵 | 无 toml 回归 + 有 toml hello |
| 双端 L4 | 阶段 1 合入谈放行时 |

### 9.2 每阶段判据（摘要）

| 阶段 | 判据 |
|------|------|
| 0 | core example parse OK；entries 不爆 |
| 1 | print-config 来源对；无 toml 零回归；最小 build |
| 2 | release/debug 产物可区分；继承合并正确 |
| 3 | test/lint 读配置；未知键 warn |
| 4 | 依赖解析单独 RFC |

### 9.3 假绿禁止

- 仅「文件存在」当实现  
- 仅 parse 成功当 build 读了配置  
- Full 示例未支持语法却 CI 绿（应用 expected-fail 或删语法）  

---

## 10. 决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 格式 | TOML | 已有 std/config；生态通用 |
| 权威 | file < env < CLI | 常见 12-factor 习惯；CLI 最高 |
| 命名 | kebab → 内部 snake | 对齐 Cargo |
| Schema | Core / Full 分层 | 简单优先 |
| 用户默认 | 无 build.x + root | 与 build-x L0/L1 一致 |
| profile | 单 inherits | 避免 C3 |
| 数组/inline | 阶段 0–2 显式处理 | 消除示例假能力 |
| 键容量 | 先扩 entries | 否则 Full 不可用 |
| 冷启动 | Makefile 永留最小集 | 鸡生蛋 |
| backend | 仅 ProjectConfig | 删 build.x 越界 |
| 模块名 | `project_config` | 避免与 std.config 混淆 |
| 未知键 | 默认 warn | 可演进 |
| 实现时机 | 地基并行；接线稳后 | 纠偏「全部冻到自举结束」 |

---

## 11. 文档与代码索引

| 路径 | 角色 |
|------|------|
| [`xlang.toml`](../xlang.toml) | Full 设计示例（未接线） |
| **待增** `xlang.toml.core.example` | 用户/MVP 权威模板 |
| [`std/config/`](../std/config/) | Layer1 |
| [`build.x`](../build.x) · build-x 分析文 | 策略；参数禁入 |
| [`compiler/src/main.x`](../compiler/src/main.x) | Layer3 入口 |
| [`compiler/src/driver/compile.x`](../compiler/src/driver/compile.x) | freestanding/opt 等状态 |
| [`compiler/Makefile`](../compiler/Makefile) | 域 B 冷启动 |
| [`零libc产品策略.md`](零libc产品策略.md) | freestanding 语义 |

---

## 12. 检查清单（合入前）

### 实现者

- [ ] Core 键有 env 表与测试  
- [ ] `--print-config` 含来源  
- [ ] 无 toml 路径 bstrict/矩阵不回退  
- [ ] 不引入 build.x 写参数  
- [ ] `CFG_MAX_ENTRIES` 足够  
- [ ] Core example gate 绿  
- [ ] PLATFORM 相关键有注释（Windows TEMP 等）  
- [ ] G.7：无第二套 merge 逻辑  

### 文档

- [ ] Full 示例头注释支持矩阵最新  
- [ ] 与 build-x 文交叉链接有效  
- [ ] 未宣称未测性能/未实现字段「已可用」  

---

## 13. 一句话总结

**xlang.toml 是配置权威与「简单」的主战场，但今日只是设计稿：std/config 子集可用却受 64 键与无数组/inline 限制，示例超前于解析器，main 未接线。正确路径是 Core/Full 分层、先扩解析与 golden、再接 ProjectConfig 与默认构建引擎，并用 --print-config 与无 toml 零回归守住质量；自举冷启动继续 Makefile，build.x 只做策略。**

---

## 14. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-21 | 初版：4 层 4 阶段、字段映射、build_use_asm_only 冲突 |
| 2026-07-21 | **全面重写**：现状校准；CFG_MAX/数组裂缝；Core/Full；发现路径；env 表；默认引擎 M0；阶段 0 地基；双问题域；假绿禁令；与 build-x 契约；检查清单 |
