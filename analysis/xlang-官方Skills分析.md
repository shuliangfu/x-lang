# Xlang 官方 Skills 分析（给 AI 写 X 项目用）

> **日期**：2026-08-02  
> **状态**：分析稿（非实现 plan；**不抢自举主航道**）  
> **配套**：[`xlang-mcp-服务分析.md`](xlang-mcp-服务分析.md) · [`AGENTS.md`](../AGENTS.md) · 现有 skill `xlang-selfhost-product-gate` · 仓内 `.grok/skills/code-review-graph`  
> **目标**：回答「要不要官方语言 Skills？」以及 **怎么写、写哪些、和 MCP/LSP/文档如何分工**——写全、可当 checklist 执行。

---

## 0. 一句话结论

| 问题 | 答案 |
|------|------|
| 要不要官方 X 语言 Skills？ | **要**。与 `xlang --mcp` **互补**，不是二选一 |
| Skills 解决什么？ | **流程与纪律**（何时查什么、禁止幻觉、写完必验、项目骨架约定） |
| MCP 解决什么？ | **真能力**（check / explain / std 查询 / scaffold 真源） |
| 现有 skill 够不够？ | **不够**。`xlang-selfhost-product-gate` 是 **改编译器/自举** 用的；缺 **「用 X 写应用」** 的用户向 Skills |
| 会不会再写一套语法权威？ | **禁止**。Skill 只写 **怎么用 Agent**；语法真源 = `docs/` + 编译器 +（将来）MCP Resources |

**成功标准（Skills 侧）**：  
在 Cursor / Claude / Grok / Continue 等里 **装上官方 Skills（+ 可选 MCP）** 后，Agent 默认行为变成：

```text
不背完整手册 → 按 skill 打开正确 reference / 调 MCP
→ 小步写 .x → check/explain → 再改
→ 不用 Rust/Go 语法冒充 X
```

---

## 1. 为什么还要 Skills？（即使有 MCP）

### 1.1 分工表（必须钉死）

| 层 | 载体 | 作用 | 类比 |
|----|------|------|------|
| **真源知识** | `docs/*.md` · 编译器 diag · MCP Resources | 语法/std/错误码「是什么」 | 字典 / 标准库文档 |
| **真能力** | CLI · LSP · **MCP Tools** | check、fmt、scaffold、hover | 编译器按钮 |
| **行为剧本** | **Skills / Agents 规则** | 何时查字典、何时按按钮、禁止什么 | 操作手册 + 红线 |
| **人机 UX** | LSP + 编辑器 | 红线、跳转、补全 | IDE |

没有 Skills 时常见失败模式：

| 失败 | 原因 |
|------|------|
| 有 MCP 也不调 | 模型不知道「先 overview 再写」 |
| 一次生成 200 行幻觉 | 没有「小步 + 必 check」纪律 |
| 用 `->` / `fn` / `impl` | 没有「X ≠ Rust」禁区清单 |
| invent 奇怪构建系统 | 没有 scaffold / 项目布局约定 |
| 把自举 skill 套到业务项目 | 触发词混用；Agent 开始讲 L4 全擦 |

**MCP 不会自动变成好习惯；Skills 负责把好习惯写进 Agent 的默认策略。**

### 1.2 现有资产 vs 缺口

| 已有 | 定位 | 缺口 |
|------|------|------|
| `~/.grok/skills/xlang-selfhost-product-gate` | **维护编译器 / 自举** | 不适合「帮用户写 hello 服务」 |
| `.grok/skills/code-review-graph` | 本仓爆炸半径导航 | 仅 x-lang 本仓开发 |
| `AGENTS.md` | 本仓协作铁律 | 偏编译器贡献者，不是应用开发教程 |
| `docs/01`～`10` | 语言真源 | **不是** Agent 流程；太长不宜整本塞进 skill |
| MCP（分析中） | 工具箱 | 未落地；落地后仍要 skill 教「怎么用工具」 |

**结论**：需要一套 **官方「语言使用 / 应用工程」Skills**，与 **「编译器维护」Skills** 分轨，避免触发词打架。

### 1.3 两轨 Skill 宇宙

```text
轨 A · 语言用户（写 X 应用 / 库）     轨 B · 语言实现者（改 x-lang 仓）
────────────────────────────────     ────────────────────────────────
xlang-app-dev（总控）                 xlang-selfhost-product-gate（已有）
xlang-syntax-guard                    code-review-graph（已有）
xlang-project-scaffold                （可选）xlang-compiler-change
xlang-fix-diagnostics                 （可选）xlang-seed-sync
xlang-std-usage
xlang-ffi-unsafe
xlang-test-and-build
…                                     AGENTS.md + analysis/* 闸门
```

- **轨 A**：装到「用 X 写项目」的工作区（用户项目或 monorepo 子目录）。  
- **轨 B**：只装在 `x-lang` 本仓 / 维护者机器。  
- **禁止** 把 L4 全擦写进轨 A 的「新建 web 服务」skill。

---

## 2. Skill 是什么、不是什么

### 2.1 定义（本分析采用）

**Skill** = 给 AI Agent 的 **短流程说明书**（通常 `SKILL.md` + 可选 `references/` + 可选 `scripts/`）：

1. **何时启用**（description / 触发词）  
2. **必须做 / 禁止做**（纪律）  
3. **分步剧本**（查什么 → 写什么 → 验什么）  
4. **指向真源**（docs 路径、MCP tool 名、CLI 命令）——**不复制长语法**

### 2.2 不是

| 不是 | 原因 |
|------|------|
| 第二本语言规范 | 会与 `docs/` 双权威 |
| MCP 的替代品 | Skill 通常不能执行 check；要调 CLI/MCP |
| 无限长 wiki | 上下文预算有限；长文放 `references/` 按需读 |
| 保证语法零错误 | 见 MCP 分析：只能降错误率 + 强制闭环 |
| 本仓 `AGENTS.md` 的复制粘贴 | 受众不同；可交叉链接，勿全文复制 |

### 2.3 多 Host 现实（包装可多套，内容一套）

| Host | 常见形态 | 官方策略 |
|------|----------|----------|
| **Grok Build** | `.grok/skills/<name>/SKILL.md` 或 `~/.grok/skills/` | 仓库提供 **canonical** 副本 |
| **Cursor** | Project rules / skills / 系统提示片段 | 从同一 canonical **同步或 symlink 说明** |
| **Claude Code** | skills / CLAUDE.md 片段 | 同上 |
| **通用** | `AGENTS.md` 应用模板、`llms.txt` | 从 skills 生成薄入口 |

**铁律**：只维护 **一份 canonical 内容**（建议仓内 `skills/xlang/` 或 `docs/ai/skills/`），各 Host 只做 **适配层**（frontmatter 格式差、路径差），禁止三份手写语法。

推荐仓内布局（实现时）：

```text
x-lang/
  skills/                          # canonical（Host 无关正文）
    README.md                      # 安装说明：Grok/Cursor/Claude
    xlang-app-dev/
      SKILL.md
      references/
        cheat-sheet.md             # 从 docs 生成或精摘 + 版本戳
        anti-patterns.md
        project-layout.md
    xlang-syntax-guard/
      SKILL.md
      references/from-rust-go-zig.md
    xlang-fix-diagnostics/
      SKILL.md
    ...
  .grok/skills/                    # 可选：包装指向 skills/ 或同步脚本
  docs/                            # 语法真源（人读 + 生成 references）
```

---

## 3. 官方 Skills 全清单（写什么）

> 编号稳定，可当交付 checklist。  
> **P0** = 没有就不配叫「官方 AI 支持」；**P1** = 顺滑写项目；**P2** = 进阶。

### 3.1 总表

| ID | Skill 名 | 轨 | 优先级 | 一句话 |
|----|----------|----|--------|--------|
| S0 | **xlang-app-dev** | A | **P0** | 总控：写 X 应用的默认工作流 + 强制 check 闭环 |
| S1 | **xlang-syntax-guard** | A | **P0** | 防幻觉：X 与 Rust/Go/Zig/C 差异、禁止清单 |
| S2 | **xlang-project-scaffold** | A | **P0** | 新项目/模块布局、命名、入口、禁止 invent 构建 |
| S3 | **xlang-fix-diagnostics** | A | **P0** | 修编译错误：check → explain → 最小 diff → 再验 |
| S4 | **xlang-std-usage** | A | P1 | 如何查/用 std；import 惯例；禁止编造 API |
| S5 | **xlang-test-and-build** | A | P1 | build/run/test/fmt CLI；何时用哪条命令 |
| S6 | **xlang-ffi-unsafe** | A | P1 | unsafe/FFI 边界清单；何时允许 |
| S7 | **xlang-async** | A | P2 | async 诚实模型（与异步专文一致，忌过度承诺） |
| S8 | **xlang-review** | A | P2 | 审 .x diff：语法、UB、双权威、缺测试 |
| S9 | **xlang-mcp-usage** | A | P1（MCP 落地后升 P0） | 如何配置/调用 MCP tools；无 MCP 时的 CLI 降级 |
| S10 | **xlang-migrate-from-*** | A | P2 | 从 Rust/Go/C 迁移片段的启发式（仍必 check） |
| B0 | **xlang-selfhost-product-gate** | B | 已有 | 自举/产品轨闸门（维护者） |
| B1 | **code-review-graph** | B | 已有 | 本仓爆炸半径 |
| B2 | **xlang-compiler-change**（可选拆出） | B | P2 | 改 parser/typeck/codegen 的短剧本（从 B0 拆薄入口） |

### 3.2 每个 Skill 必须包含的「内容块」

任何官方 Skill 的 `SKILL.md` **固定骨架**（缺一块算不合格）：

```text
1. YAML frontmatter（name + description 触发词）
2. 范围：做什么 / 不做什么（与邻 skill 边界）
3. 启用时机 + 禁用时机
4. 强制纪律（Do / Don't 表）
5. 分步剧本（编号步骤，可复制）
6. 真源链接（docs 章节、CLI、MCP tool 名）
7. 最小示例（≤30 行 .x，必须是「当前可编译」风格）
8. 验收自检（Agent 收工 checklist）
9. 失败模式（常见幻觉 → 纠正）
10. 版本戳（对齐 xlang 版本或 docs rev；过期策略）
```

### 3.3 S0 · xlang-app-dev（总控 · 最重要）

**定位**：用户说「用 X 写个…」「改这个 .x 项目」时的 **默认入口**。

**description 触发词示例**：

```text
Xlang application development workflow: write/edit .x apps and libraries,
scaffold, typecheck, fix diagnostics. Triggers: write xlang, .x project,
x language app, xlang hello, implement in x, /xlang-app-dev.
Not for compiler self-hosting (use xlang-selfhost-product-gate).
```

**强制纪律（正文核心）**：

| Do | Don't |
|----|-------|
| 写前读 cheat-sheet 或调 MCP `language_overview` | 用 Rust/Go 语感直接喷代码 |
| 每次改完相关文件跑 `xlang check`（或 MCP `xlang_check`） | 只靠模型「我觉得能编过」 |
| 小步：一功能一 diff | 一次重写全仓 |
| 字段访问只用 `.` | 在 `.x` 里写 `->` |
| import / 模块按 docs/05 | 发明 `package`/`crate` 假语法 |
| 错误码走 explain | 无视 XP\*\*\* 瞎改 |

**默认剧本**：

```text
1. 识别：新项目？改现有？单文件？
2. 若新项目 → 加载 xlang-project-scaffold（或 MCP scaffold）
3. 加载 xlang-syntax-guard 关键要点（或确认已内化）
4. 需要 API → xlang-std-usage / MCP std_lookup；禁止编造
5. 实现最小可编译切片
6. xlang check（或 MCP）；红则 xlang-fix-diagnostics
7. 可选 fmt / build
8. 汇报：改了哪些文件 + check 结果（禁止假绿）
```

**references/**：

- `cheat-sheet.md`：一页速查（从 docs 生成）  
- `project-layout.md`  
- `anti-patterns.md`  

**与 MCP**：有 MCP 则步骤 2/4/6 优先 tool；无 MCP 则 CLI + 读 `docs/`。

---

### 3.4 S1 · xlang-syntax-guard（防幻觉）

**定位**：**最短、最硬** 的「不是 Rust」防火墙；可被 S0 引用，也可单独触发（用户贴错误代码时）。

**必须写清的差异表（示例结构，内容从 docs 填，禁止臆造）**：

| 主题 | X 怎么写 | 禁止（他语言习惯） |
|------|----------|-------------------|
| 入口 | `export function main...`（以 docs 为准） | `fn main()` / `func main()` |
| 字段 | `obj.field` / `ptr.field` | `ptr->field`（那是 C 生成细节） |
| 模块 | `import("...")` 等（docs/05） | `use` / `package` / `mod` 乱套 |
| 类型 | docs/02 权威 | 乱写 `String`/`&str` 当内置若不存在 |
| 错误处理 | 以语言实际为准（Result/Option 等） | 无脑 `try/catch` 若语言无 |
| 注释 | 产品代码英文 docblock 惯例（应用仓可自定；**本语言仓**跟 G.9） | — |

**references/from-rust-go-zig.md**：对照表 + 「迁移时先查再写」。  
**禁止**：在 skill 正文贴 50 页语法；只贴 **易错点 + 链接 docs 章节号**。

---

### 3.5 S2 · xlang-project-scaffold

**定位**：目录、命名、`main.x`、（未来）`xlang.toml`、bin vs lib。

**剧本**：

```text
1. 问清/推断：bin 还是 lib？名字？
2. 优先：MCP xlang_scaffold 或 CLI new/init（落地后）
3. 无工具：按 references/project-layout.md 写最小文件集
4. 立刻 check 模板是否绿
5. 再加业务代码
```

**必须规定**：

- 官方布局（例）：`src/main.x` 或根 `main.x`——**选定一种官方默认并写死**，允许文档说明变体  
- 禁止 Agent 创建 `CMakeLists` / `cargo.toml` / `go.mod` 当 X 构建（除非用户明确要 FFI 宿主）  
- 与时序表 `new`/`init`、MCP scaffold **同源模板**（G.7 单一权威）

---

### 3.6 S3 · xlang-fix-diagnostics

**定位**：编译失败时的专用 skill（高触发率）。

**剧本（强制顺序）**：

```text
1. 收集完整诊断（禁止只看第一行就猜）
2. 对每个 CODE：xlang explain CODE 或 MCP xlang_explain
3. 读相关 docs 节（skill 内映射表：常见 CODE → 文档）
4. 最小修改（一处根因）；禁止顺手大重构
5. 再 check；仍红则归层（语法 vs 类型 vs import vs link）
6. link/平台错误：提示用户环境；应用 skill 不假装会修编译器
```

**失败模式表**：

| 现象 | 错误反应 | 正确反应 |
|------|----------|----------|
| XP003 之类 | 删代码糊绿 | explain + 修类型/调用 |
| 找不到模块 | 改 import 为假路径 | 查 std 索引 / 项目布局 |
| 链接 UNDEF | 改业务逻辑乱猜 | 查是否缺 build 参数/平台；应用侧少碰 |

---

### 3.7 S4 · xlang-std-usage

**纪律**：

- 调用任何 std API 前：MCP `std_lookup` 或读 `docs/07` / 源码签名  
- **禁止** 编造 `std.foo.bar`  
- import 写法只允许文档中的形式  
- 示例必须标注「示意，以当前 std 导出为准」

**references/**：可维护「高频模块索引」——**从 std 生成**，CI 检查过期。

---

### 3.8 S5 · xlang-test-and-build

**内容**：

| 任务 | 命令（以产品 CLI 为准，落地后更新） |
|------|--------------------------------------|
| 只检查 | `xlang check …` |
| 编译 | `xlang build …` |
| 运行 | `xlang run …` |
| 格式化 | `xlang fmt …` |
| 测试 | `xlang test …`（能力以当时产品为准，诚实写限制） |

**纪律**：不把 bstrict 全量当用户应用默认测试；区分 **用户项目测试** vs **编译器仓闸门**。

---

### 3.9 S6 · xlang-ffi-unsafe

- 何时需要 `unsafe` / extern  
- 边界：谁拥有内存、PLATFORM  
- 清单：禁止在安全代码里偷塞 FFI  
- 指向 `docs` + 安全路线摘要（用户向，不写自举债）

---

### 3.10 S7 · xlang-async（P2）

- **诚实**：与 `analysis/全面异步架构-*.md` 用户可消费摘要一致  
- 禁止宣传未交付的「完整 async/await 生态」  
- 剧本：仅在项目已用 async 或用户明确要求时启用

---

### 3.11 S8 · xlang-review

审 diff 清单：

- [ ] 无 `.x` 内 `->`  
- [ ] 无编造 std  
- [ ] 有 check 证据  
- [ ] unsafe 有理由  
- [ ] 无第二套构建系统  
- [ ] 注释/文档与代码一致  

---

### 3.12 S9 · xlang-mcp-usage

MCP 落地后 **几乎必装**：

```text
配置片段 → tools 列表 → 何时用哪个 tool
→ 无 MCP 时降级：CLI + docs 路径
→ 安全：不要允许 run 除非用户授权
```

与 [`xlang-mcp-服务分析.md`](xlang-mcp-服务分析.md) 的 tool 表 **单一列表**（skill 只引用，不复制膨胀版）。

---

### 3.13 轨 B 边界（写进 S0 的 Don't）

当工作区是 `x-lang` 编译器仓且任务是自举/修 typeck：

- **改用** `xlang-selfhost-product-gate`  
- **不要** 用 S0 的「用户应用」剧本去 `rm` 全树 `.o` 除非用户明确在做自举  

S0 description 必须写：**Not for compiler self-hosting**。

---

## 4. 怎么写 Skills（写作规范 · 全部规则）

### 4.1 文件与命名

| 规则 | 说明 |
|------|------|
| 目录名 | 小写 + 连字符：`xlang-app-dev` |
| 入口文件 | 必须 `SKILL.md` |
| name | 与目录名一致 |
| 语言 | **Agent 指令可用中文或英文**；**示例 .x 注释跟产品纪律（英文）**；对外若双份 skill，内容同源 |
| 长度 | 正文建议 **80～200 行**；超长拆 `references/` |
| 可执行性 | 每步是 Agent 能做的动作（读文件/跑命令/调 MCP），不是空话 |

### 4.2 Frontmatter（Grok / 兼容）

```yaml
---
name: xlang-app-dev
description: >
  <1–3 句做什么>。
  Triggers: <英文+中文关键词>。
  Use when: … /xlang-app-dev.
  Not for: compiler self-host, L4 cold boot (see xlang-selfhost-product-gate).
---
```

**description 是自动触发的关键**——必须包含：场景词、文件类型（`.x`）、正触发与 **负触发（Not for）**。

### 4.3 正文写作铁律

1. **命令式**：「先运行…」「禁止…」，少用「可以考虑」。  
2. **单一权威**：语法点 → `docs/0N-….md` §x；工具 → MCP 名或 CLI。  
3. **禁止粘贴大段易过期 API 列表**；改为「生成 references + 版本戳」。  
4. **示例必须可编译风格**（与当前语言一致）；过期示例比没有更糟。  
5. **PLATFORM**：涉及链接/系统调用写 `PLATFORM: SHARED|…`。  
6. **诚实能力边界**：「当前 check 不验证 …」。  
7. **与 MCP/Prompts 对齐**：skill 剧本步骤编号可与 MCP prompt 同构，避免两套流程。  
8. **Token 友好**：默认路径不要求读完整 `docs/08`；先 cheat-sheet。  
9. **可测试**：每个 P0 skill 配「黄金对话/剧本」三条（见 §7）。  
10. **变更流程**：改 docs 语法 → 同步 references 生成 → bump skill 版本戳。

### 4.4 references/ 怎么写

| 文件 | 内容 | 生成？ |
|------|------|--------|
| `cheat-sheet.md` | ≤1 屏：结构、类型、import、main、常见坑 | **宜从 docs 生成** |
| `anti-patterns.md` | 错误片段 → 正确片段 | 人工维护 + 评审 |
| `project-layout.md` | 官方目录 | 与 scaffold 同源 |
| `diag-map.md` | 常见 CODE → 含义 → docs | 可从 explain 表生成 |
| `std-hot-index.md` | 高频模块 | 从 std 导出生成 |

每个 reference 文首：

```markdown
<!-- authority: docs/ + compiler; generated: YYYY-MM-DD; xlang: ≥x.y -->
<!-- DO NOT hand-edit API tables without regenerating -->
```

### 4.5 scripts/（可选）

仅当 skill 需要 **稳定可重复** 的动作时：

- `scripts/check-workspace.sh` — 封装 `xlang check`  
- `scripts/sync-from-docs.sh` — 生成 cheat-sheet  

禁止 script 里再实现一套 typeck。

### 4.6 完整 SKILL.md 模板（可直接套）

```markdown
---
name: xlang-EXAMPLE
description: >
  ONE_LINE. Triggers: … Not for: …
---

# xlang-EXAMPLE

## Scope
- In: …
- Out: … (point to other skill)

## When to use / when NOT

| Use | Skip |
|-----|------|
| … | … |

## Hard rules

| Do | Don't |
|----|-------|
| … | … |

## Procedure

1. …
2. …
3. Verify with: `xlang check …` or MCP `xlang_check`

## Authority (do not fork)

| Topic | Source |
|-------|--------|
| Syntax | `docs/…` |
| Std | MCP `xlang_std_lookup` / `docs/07` |
| Tools | `analysis/xlang-mcp-服务分析.md` tool table |

## Minimal example

\`\`\`x
// ≤30 lines; must match current language
\`\`\`

## Done checklist

- [ ] check green (command + exit)
- [ ] no invented APIs
- [ ] …

## Failure modes

| Symptom | Fix |
|---------|-----|
| … | … |

## Version

- Skill rev: 0.1.0
- Aligns with docs rev / xlang: (fill on release)
```

---

## 5. Skills × MCP × LSP × Docs 协作图

```text
用户自然语言
    │
    ▼
┌──────────── Skill（S0 等）────────────┐
│ 决定：步骤、禁区、何时调用工具         │
└───────────┬───────────────┬───────────┘
            │               │
            ▼               ▼
     MCP Tools/Resources   CLI / 读 docs
     (真能力/真源切片)      (降级路径)
            │
            ▼
        编译器权威
            │
            ▼
     人用 LSP 看红线（并行）
```

| 场景 | Skill | MCP | LSP |
|------|-------|-----|-----|
| 「写个 hello」 | S0+S2 | scaffold+check | 人看诊断 |
| 「这段报 XP…」 | S3 | explain+check | 跳转 |
| 「std 怎么读文件」 | S4 | std_lookup | hover |
| 「改 typeck」 | **B0 不是 S0** | 一般不用语言 MCP | 可选 |

**MCP Prompts** 与 **Skills** 可同构：  
例如 prompt `fix_compile_errors` ≈ skill S3 的 Procedure；实现时 **一份流程两种包装**，禁止文案分叉。

---

## 6. 分阶段交付

### Phase 0 — 分析与目录（本文）

- [x] 要不要 Skills、与 MCP 分工  
- [ ] 确认仓内 canonical 路径（建议 `skills/`）  
- [ ] 确认轨 A / 轨 B 触发词互斥文案  

### Phase 1 — P0 四件套（可宣称「官方 AI 入门包」）

| 交付 | 验收 |
|------|------|
| S0 app-dev | 黄金对话：从零写 hello，Agent 走 check |
| S1 syntax-guard | 故意用 Rust 写法时被 skill 纠正 |
| S2 scaffold | 目录符合 layout，模板 check 绿 |
| S3 fix-diagnostics | 对固定坏文件能按 explain 修绿 |
| `skills/README.md` | Grok/Cursor 安装各 10 行 |
| cheat-sheet + anti-patterns | 有版本戳；抽检与 docs 一致 |

**不依赖 MCP 必须已完成**（CLI check 即可）；MCP 就绪后只加「优先 MCP」分支。

### Phase 2 — P1

- S4 std-usage · S5 test-and-build · S6 ffi · S9 mcp-usage  
- references 生成脚本进 CI（docs 变更 diff）  
- 与 `xlang --mcp` 联合验收  

### Phase 3 — P2 与生态

- S7 async · S8 review · S10 migrate  
- 发布：官网 / README「AI 编辑器」专节  
- 可选：打包 `npx`/`brew` 旁的 skill 安装器（非必须）

### 与时序表

- 挂在 **P1 DX** 或 **P3 DX**：`官方 skills P0` / `skills+MCP 联调`  
- **自举期**：只定稿分析 + 可选起草 S1 差异表（不抢主航道大宣发）

---

## 7. 验收与「黄金剧本」

### 7.1 产品验收

| ID | 剧本 | 期望 |
|----|------|------|
| G1 | 「用 X 写 hello 打印一行」 | 启用 S0；产出可 `check`/`run`；无 `fn main` |
| G2 | 用户粘贴带 `->` 的假 .x | S1 纠正为 `.` |
| G3 | 破坏类型后说「修好」 | S3：check→explain→最小 diff→再绿 |
| G4 | 「加一个 std 里不存在的 API」 | S4/S0 拒绝编造，去查真源 |
| G5 | 在编译器仓说「继续自举」 | **不**走 S0 应用剧本；走 B0 |

### 7.2 质量门禁

- [ ] 每个 P0 skill ≤ 约定行数或拆 references  
- [ ] description 含 Not for  
- [ ] 无与 docs 冲突的语法断言（抽检脚本可后期做）  
- [ ] 示例 `.x` 在 CI 用当前 xlang check（发布时）  
- [ ] 与 MCP tool 名单一致（无过期 tool 名）

---

## 8. 反模式（官方 Skills 禁止）

| 反模式 | 后果 | 正确 |
|--------|------|------|
| Skill 全文复制 docs/08 | 双权威、必漂 | 链接 + 短 cheat-sheet |
| 一个 skill 塞自举+应用+async | 触发混乱 | 分轨 S0 vs B0 |
| 只写「要写对语法」无步骤 | 无效 | 编号剧本 + check |
| 示例已不能编译 | 教坏模型 | CI 挂 check |
| 三份 Cursor/Claude/Grok 手写正文 | 分叉 | canonical + 适配 |
| 承诺「装 skill 零错误」 | 过度宣传 | 写清：降幻觉 + 强制验证 |
| Skill 教 BEST_EFFORT 糊编译器 | 污染轨 B | 应用 skill 禁止 |

---

## 9. 与「写错语法」问题的联合答案

| 手段 | 单独效果 | 组合 |
|------|----------|------|
| 仅 Skills | 流程对了，但无真机验证仍可能蒙 | 不够 |
| 仅 MCP | 有工具，模型可能不调 | 不够 |
| 仅 LSP | 利人不利 Agent 批处理 | 不够 |
| **Skills + MCP +（人用）LSP + docs 真源** | — | **当前最优** |

预期：

- **错误率大幅下降**，修错路径变短  
- **仍不是形式化证明零错误**  
- 小中型项目可以 **顺很多**；大系统仍要人设边界

---

## 10. 建议的立即决策（拍板清单）

1. **Canonical 目录**：是否采用仓库根 `skills/`？  
2. **P0 四套**是否批准：S0/S1/S2/S3？  
3. **官方默认项目布局**一锤定音（避免 scaffold 与 skill 不一致）。  
4. **应用向 skill 默认语言**：中文指令 / 英文指令 / 双文件？  
5. **与 MCP 发布顺序**：Skills P0 可先于 MCP；S9 随后。  
6. **是否把 S0 摘要链进 README「AI 编辑器」节**（完成后）。

---

## 11. 总结

| 问题 | 答案 |
|------|------|
| 要不要官方语言 Skills？ | **要**，与 MCP 互补 |
| 和现有 selfhost skill？ | **分轨**；应用 S\* vs 维护 B\* |
| 写哪些？ | P0：`app-dev` / `syntax-guard` / `scaffold` / `fix-diagnostics`；再 std/build/ffi/mcp… |
| 怎么写？ | 短剧本 + Do/Don't + 真源链接 + references 生成 + 版本戳；**禁止第二语法书** |
| 怎样算写好？ | 黄金剧本 G1–G5 + 示例可 check + 与 MCP/docs 不漂 |

---

## 12. 附录 A · P0 触发词草稿（中英）

| Skill | Triggers（写入 description） |
|-------|------------------------------|
| S0 | write xlang, .x app, x language project, 用X写, xlang 项目, implement in x, /xlang-app-dev |
| S1 | xlang syntax, not rust, 字段访问, `->`, 语法幻觉, x vs rust, /xlang-syntax-guard |
| S2 | new xlang project, scaffold, 初始化项目, hello xlang, /xlang-project-scaffold |
| S3 | fix xlang error, XP003, typeck fail, 编译错误, explain diagnostic, /xlang-fix-diagnostics |

## 13. 附录 B · 与 MCP Tool 映射（Skills 步骤用）

| Skill 步骤 | MCP Tool（落地后） | CLI 降级 |
|------------|-------------------|----------|
| 语言概览 | `xlang_language_overview` | 读 `skills/…/cheat-sheet` + `docs/README` |
| 脚手架 | `xlang_scaffold` | 按 `project-layout.md` 写文件 |
| 检查 | `xlang_check` | `xlang check` |
| 解释 | `xlang_explain` | `xlang explain CODE` |
| 格式化 | `xlang_fmt` | `xlang fmt` |
| 查 std | `xlang_std_lookup` | `docs/07` + 读 std 源 |

---

*本文为分析稿。落地时另开实现 commit；遵守 AGENTS.md：单一权威、不抢自举主航道。关联：`analysis/xlang-mcp-服务分析.md`。*
