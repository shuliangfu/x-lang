# xlang MCP 服务分析（`xlang --mcp`）

> **日期**：2026-08-02  
> **状态**：分析稿（非实现 plan；**不抢自举主航道**）  
> **目标读者**：决定「AI 代码编辑器如何零语法学习成本写 X 项目」时的产品/架构决策  
> **相关**：[`XLANG 命令行.md`](XLANG%20命令行.md) · [`自举完成后功能完善及优化时序表.md`](自举完成后功能完善及优化时序表.md) · [`xlang-官方Skills分析.md`](xlang-官方Skills分析.md)（Skills 与 MCP 互补） · LSP 实现 `compiler/src/lsp/` · MCP 规范 <https://modelcontextprotocol.io/>

---

## 0. 一句话结论

**`xlang --mcp` 与 `xlang --lsp` 同级入口**：一个进程、stdio（默认）上跑 **Model Context Protocol 服务端**，把「X 语言权威知识 + 编译器真能力」以 **Tools / Resources / Prompts** 暴露给 Cursor / Claude Code / VS Code Copilot / Windsurf / Continue 等 **MCP Host**。

- **LSP**：给人用的编辑器（跳转、补全、诊断、改名）—— **交互式、文档同步、长连接**。  
- **MCP**：给 AI Agent 用的工具箱（查语法、查 std、编译检查、解释错误、脚手架）—— **按需调用、无 GUI 假设、可批处理**。

二者 **共享同一套编译器权威**（parse / typeck / diag / fmt / explain / 文档真源），**禁止** 再写一套「给 AI 的假语法说明」。  
**成功标准**：AI 在只装 `xlang` + 配一条 MCP 的前提下，能 **新建 / 改 / 编 / 修** 小型 X 项目，而 **不必** 把整本语言手册塞进 system prompt。

---

## 1. 问题地图（上帝视角）

### 1.1 痛点

| 痛点 | 现状 | 后果 |
|------|------|------|
| AI 不熟 X 语法 | 训练语料极少；易按 Rust/Go/Zig 幻觉 | 写出非法代码、错误 import、错误 ABI |
| 文档与编译器漂移 | docs / analysis / 源码多处描述 | AI 读旧文档 → 假绿代码 |
| 诊断难读 | 人用 `xlang explain CODE`；AI 不会主动调 | 修 bug 靠猜 |
| 项目骨架未知 | 无标准 `new/init`；toml 未完全接线 | AI 乱 invent 目录与构建 |
| 工具链入口分散 | `build` / `check` / `fmt` / `--lsp` 各自为政 | Agent 记不住正确 CLI |

### 1.2 目标（产品）

让 **任意支持 MCP 的 AI 代码编辑器** 把 `xlang` 当 **一等公民工具**：

1. **不靠背语法**：需要时从 MCP **拉取权威语法/惯用法/std API**。  
2. **写完即验**：`check` / `build` / 诊断解释走 **本机真编译器**，不是模型自评。  
3. **项目级**：workspace 根、`xlang.toml`（就绪后）、模块图、可运行探针。  
4. **与 LSP 正交**：人在 IDE 里仍用 LSP；Agent 调 MCP；底层 **同一 diag/typeck**。

### 1.3 非目标（明确不做）

| 不做 | 原因 |
|------|------|
| 把 MCP 当远程沙箱/云编译服务（首期） | 安全与运维爆炸；首期 **本地 stdio** |
| 在 MCP 里完整实现第二套 typeck | 双权威，必漂 |
| 用 MCP 替代 LSP 给人类编辑 | 协议语义不同；补全/同步是 LSP 的事 |
| 首期支持任意远程 HTTP + 公网开放 | 攻击面；HTTP 仅作可选二期 |
| 让 MCP 自动 `git push` / 改系统配置 | 危险工具默认关 |
| 自举未完成前抢主航道大实现 | 与时序表一致；分析可先行 |

### 1.4 与「AI 不用另学语法」的精确含义

**不是**：模型永远不接触 X 语法 token。  
**而是**：

- 语法/std/**惯用法** 的 **真源在编译器交付物**（Resources + Tools），  
- Agent **按需查询** 再生成，  
- 生成后 **立即 `check`/`build`** 闭环，  
- 错误用 **`explain` + 结构化诊断** 修，而不是再幻觉一轮。

---

## 2. MCP 是什么（面向本仓的最小协议面）

### 2.1 角色

```text
AI 代码编辑器 (MCP Host / Client)
        │  JSON-RPC over stdio（默认）或 Streamable HTTP（可选）
        ▼
  xlang --mcp          ← MCP Server（本分析主体）
        │
        ├─ Tools      可执行动作（check、explain、scaffold…）
        ├─ Resources  只读上下文（语法、std 索引、示例）
        └─ Prompts    可复用工作流模板（「修编译错误」「新建 bin」）
```

### 2.2 与 LSP 对照

| 维度 | `xlang --lsp` | `xlang --mcp` |
|------|---------------|---------------|
| 协议 | Language Server Protocol | Model Context Protocol |
| 主消费者 | 编辑器 UI / 人类 | LLM Agent |
| 传输 | stdio + Content-Length（已实现） | stdio + JSON-RPC（与 MCP 规范对齐） |
| 状态 | 文档打开/变更长状态 | 多为无状态请求；可选 workspace 根 |
| 核心价值 | 实时诊断、跳转、补全 | **权威知识 + 可验证动作** |
| 现有入口 | `main.x` 扫 `--lsp` → `typeck_lsp_main` | **拟** 扫 `--mcp` → `mcp_main`（同级） |
| 实现位置 | `compiler/src/lsp/` | 拟 `compiler/src/mcp/`（新建） |

### 2.3 规范能力面（服务器必须声明）

MCP Server 在 `initialize` 时声明 capabilities，本仓建议：

| Capability | 首期 | 说明 |
|------------|------|------|
| **tools** | **必须** | AI 实际会调用的主路径 |
| **resources** | **强烈建议** | 语法/std/模板只读真源；降低 system prompt 体积 |
| **prompts** | 建议 | 一键「修错误 / 新项目」模板；Host 支持度参差，但实现成本低 |
| logging | 可选 | stderr 诊断；勿污染 stdout（stdio 传输） |
| completions（MCP 参数补全） | 后期 | tool 参数自动补全 |
| sampling | **不做**（首期） | 服务器反向要模型生成——复杂度高、多数 Host 未用 |

**传输（Transport）**：

| 传输 | 优先级 | 用途 |
|------|--------|------|
| **stdio** | P0 | Cursor / Claude Desktop / 多数本地配置：`command: xlang, args: [--mcp]` |
| Streamable HTTP / SSE | P2 | 远程 agent、多客户端；需 auth |
| 与 `--lsp` 同进程双协议 | **禁止** | 端口/stdio 冲突；保持进程单一职责 |

---

## 3. 现有资产（可复用，禁止重写）

### 3.1 CLI / 入口（`compiler/src/main.x`）

- 已有：任意 argv 含 `--lsp` → `typeck_lsp_main()`（与子命令并列的 **全局 mode**）。  
- 子命令：`build` / `run` / `fmt` / `check` / `test`。  
- 设计文档另有 `explain`（产品化时序 P1）。  
- **MCP 应对齐 `--lsp` 风格**：`xlang --mcp`（全局 mode），**不要** 做成容易与子命令混淆的隐式路径。

可选别名（后期）：

- `xlang mcp` 子命令 → 内部同 `mcp_main`  
- 环境变量 `XLANG_MCP_WORKSPACE=/path` 作为默认根

### 3.2 LSP 管线（`compiler/src/lsp/`）

已具备（可 **内部复用函数**，不直接把 LSP JSON 吐给 MCP）：

| LSP 能力 | 符号/路径线索 | MCP 可包装为 |
|----------|---------------|--------------|
| diagnostics | `lsp_build_diagnostics_response` / parse+typeck | tool `xlang_check` / `xlang_diagnostics` |
| hover | `lsp_build_hover_response` | tool `xlang_hover` / resource 局部 |
| definition | `lsp_build_definition_response` | tool `xlang_goto_definition` |
| completion | `lsp_build_completion_response` | tool `xlang_complete`（谨慎：token 贵） |
| documentSymbol | `lsp_build_document_symbol_response` | tool `xlang_document_symbols` |
| formatting | `lsp_build_formatting_response` | tool `xlang_fmt` |
| rename / refs / semanticTokens | 已有钩子 | 后期 Agent 重构工具 |

**纪律**：MCP **调用** 同一 parse/typeck/diag 权威；**不要** 复制一份字符串扫描当「语义」。

### 3.3 其他产品面

| 能力 | 状态 | MCP 用法 |
|------|------|----------|
| `xlang check` | 产品子命令 | tool 首选（快、不链接） |
| `xlang build` / `run` | 有 | tool；run 需安全沙箱策略 |
| `xlang fmt` | 有 | tool |
| `xlang explain CODE` | CLI 设计有 / 实现随产品化 | tool + resource |
| `xlang.toml` | 示例级，未完全接 main | resource 描述「设计」；接线后 tool 读写配置 |
| 文档 `docs/`、`analysis/` | 多 | **精选** resource；禁止整仓塞给模型 |
| 示例 `examples/` | 视仓库现状 | scaffold / resource 模板 |

---

## 4. 功能总览：MCP 要写什么？

按 MCP 三件套拆分。**编号稳定**，实现时可当 checklist。

```text
                    ┌─────────────────────────────────────┐
                    │           xlang --mcp                 │
                    └─────────────────────────────────────┘
           Tools              Resources              Prompts
    （AI 主动调）         （AI/用户拉取）         （工作流模板）
           │                    │                    │
     编译/诊断/查询          语法·std·模板        新建/修错/迁移
```

---

## 5. Tools（核心：AI 真正会调用的）

> 原则：**少而精**。每个 tool 有清晰 JSON schema、确定性输出、失败时结构化错误。  
> 命名建议前缀 `xlang_`，避免与其他 MCP 冲突。

### 5.1 P0 — 最小闭环（「能写能验」）

没有这 6 个，**不值得** 宣称「支持 MCP」。

| Tool | 输入（摘要） | 输出 | 背后权威 | 价值 |
|------|--------------|------|----------|------|
| **`xlang_language_overview`** | 可选 `topic`：syntax / types / modules / ffi / async / build | 结构化 markdown/JSON 摘要 | 内置手册切片（从 docs 生成或编译期嵌入） | AI **不必背语法** 的第一入口 |
| **`xlang_check`** | `paths[]` 或 `source`+`filename`；可选 `backend` | diagnostics 列表：code, message, range, severity, fix_hint? | 同 `check` / LSP diag 管线 | **写完即验** |
| **`xlang_explain`** | `code`（如 XP003） | 长说明 + 示例 + 常见修复 | `explain` 权威表 | 修错误不靠猜 |
| **`xlang_fmt`** | `path` 或 `source`；`apply?: bool` | 格式化后文本 或 diff | `fmt` | 风格统一 |
| **`xlang_scaffold`** | `kind`: bin/lib；`name`；`dir?` | 写出的文件列表 + 内容摘要 | 固定模板（与未来 `new/init` 同源） | 正确骨架，禁 AI invent |
| **`xlang_search_docs`** | `query`；`scope?`: lang/std/cli/error | 命中片段 + resource URI | 内置索引（非全网） | 按需检索，不塞全书 |

**P0 交互闭环**：

```text
AI: scaffold(bin) → 写 main.x
AI: language_overview(modules) → 写 import
AI: check(paths) → 失败 XP00x
AI: explain(XP00x) → 改代码
AI: check → 绿
（可选）fmt
```

### 5.2 P1 — 项目级与导航（「能改仓库」）

| Tool | 输入 | 输出 | 说明 |
|------|------|------|------|
| **`xlang_build`** | `path`；`-o?`；`backend?`；`opt?` | exit_code、stderr 摘要、产物路径 | 真编译；超时与体积上限 |
| **`xlang_run`** | `path`；`args[]?`；`timeout_ms?` | stdout/stderr/exit（截断） | **默认关闭或需 `allow_run=true`**（安全） |
| **`xlang_project_info`** | `workspace_root?` | 探测：是否 xlang 项目、源文件列表、toml 摘要、推荐命令 | 给 Agent 定向 |
| **`xlang_goto_definition`** | `path`/`source` + line/col | 定义位置 | 复用 LSP definition |
| **`xlang_hover`** | 同上 | 类型/文档字符串 | 复用 LSP hover |
| **`xlang_document_symbols`** | path/source | 符号树 | 大文件导航，比全文便宜 |
| **`xlang_find_references`** | path + position | 引用列表 | 重构辅助 |
| **`xlang_std_lookup`** | `module` 或 `symbol` | 签名、简述、示例 URI | **std 真源**（从源码/接口表生成） |
| **`xlang_module_graph`** | root path | import 图（深度有限） | 防循环/找入口 |
| **`xlang_apply_fix`** | path + content 或 edits[] | ok / error | **可选**；许多 Host 已自己写文件。若提供：只允许 workspace 内 |

### 5.3 P2 — 高级 Agent / 工程化

| Tool | 用途 | 风险/备注 |
|------|------|-----------|
| **`xlang_complete`** | 光标处补全列表 | token 多；优先让 IDE LSP 做人用补全 |
| **`xlang_rename`** | 工作区改名 | 需可靠 refs；失败要原子回滚策略 |
| **`xlang_fix`** | 跑产品测试矩阵子集 | 长时；需 progress / timeout |
| **`xlang_bstrict_smoke`** | 固定小探针 | 开发者工具，非日常 AI |
| **`xlang_target_info`** | triple / cpu features | 对齐 `--print-target-cpu` |
| **`xlang_abi_query`** | 类型布局/调用约定问答 | 绑定 `ABI与布局` 真源切片 |
| **`xlang_diag_codes_list`** | 全诊断码目录 | resource 也可承载 |
| **`xlang_migrate_snippet`** | 「把这段 Rust/Go 风格改成 X」启发式 | **非魔法翻译器**；输出仍必须 check |
| **`xlang_security_audit_local`** | 扫描 unsafe / FFI 边界（规则集） | 与安全路线对齐；勿假安全承诺 |

### 5.4 Tool 设计契约（强制）

1. **输入校验**：缺参 / 路径逃逸 → JSON-RPC error 或 `isError: true` 内容，禁止崩进程。  
2. **路径沙箱**：默认只允许 `workspace_root` 之下；`..` 与绝对路径出界拒绝。  
3. **输出有界**：stdout/stderr/源文件 **截断**（如 64KiB）+ `truncated: true`。  
4. **超时**：check 默认 30s，build 120s，run 可配且默认更短。  
5. **确定性**：同一输入尽量同一输出（便于缓存）；时间戳勿进核心字段。  
6. **无副作用默认**：`check`/`hover`/`search` 只读；写盘类 tool 名称带 `scaffold`/`apply`/`fmt`（apply）明示。  
7. **单一权威**：tool 描述字符串写清「数据来自 compiler 内置 / docs 切片版本号」。  
8. **PLATFORM**：涉及链接/运行的 tool 标注 `SHARED | LINUX | DARWIN | WINDOWS` 行为差。

### 5.5 Tool JSON Schema 示例（示意）

```json
{
  "name": "xlang_check",
  "description": "Parse and typecheck X sources using the real xlang compiler. Returns structured diagnostics.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "paths": { "type": "array", "items": { "type": "string" }, "description": "Workspace-relative .x paths" },
      "source": { "type": "string", "description": "Inline source if no path (optional)" },
      "filename": { "type": "string", "description": "Virtual name for inline source" }
    }
  }
}
```

```json
{
  "name": "xlang_scaffold",
  "description": "Create a minimal X project (bin or lib) with correct layout and starter main.x. Does not invent non-standard build systems.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "kind": { "type": "string", "enum": ["bin", "lib"] },
      "name": { "type": "string" },
      "dir": { "type": "string", "description": "Relative directory; default ." }
    },
    "required": ["kind", "name"]
  }
}
```

---

## 6. Resources（只读真源：让 AI「查字典」）

> Resources = URI 可寻址的只读材料。Host 可 `resources/list` + `resources/read`。  
> **比塞进 system prompt 更优**：按需、可版本化、可与编译器同发布。

### 6.1 URI 方案（建议）

```text
xlang://lang/overview              语言总览
xlang://lang/syntax/{topic}        语法专题（types, control, modules, unsafe, async, ffi…）
xlang://lang/keywords              关键字表
xlang://lang/examples/{id}         官方小例子
xlang://std/index                  std 模块索引
xlang://std/module/{name}          单模块 API 摘要
xlang://std/symbol/{qualname}      符号详情
xlang://cli/help                   CLI 摘要（与 --help 同源逻辑）
xlang://diag/codes                 诊断码目录
xlang://diag/code/{CODE}           单码详解（同 explain）
xlang://project/template/{kind}    scaffold 模板源
xlang://version                    编译器版本 / 手册版本 / PLATFORM
xlang://workspace/manifest         当前探测到的项目摘要（若绑定 root）
```

### 6.2 P0 Resources

| URI | 内容 | 生成方式 |
|-----|------|----------|
| `xlang://lang/overview` | 1～3 屏：程序结构、入口、类型速查、import、常见坑 | 维护 **单一** markdown 切片，CI 校验链接 |
| `xlang://lang/syntax/*` | 分专题；每专题 ≤～2k 词 | 从 `docs/` 抽取 **生成**，禁止手抄第二份 |
| `xlang://std/index` | 模块列表 + 一句话 | 从 std 源/`pub` 导出表生成 |
| `xlang://diag/codes` | 码 → 标题 | explain 表 |
| `xlang://version` | semver + git describe + 手册 rev | 编译期注入 |
| `xlang://cli/help` | 子命令与 `--mcp`/`--lsp` | 与 usage 同源 |

### 6.3 P1+ Resources

| URI | 内容 |
|-----|------|
| `xlang://std/module/*` | 函数签名列表（可截断） |
| `xlang://lang/examples/*` | 可 check 的最小示例 |
| `xlang://project/template/*` | scaffold 原样 |
| `xlang://abi/summary` | 调用约定 / 布局摘要（切片） |
| `xlang://async/model` | async/CPS 诚实说明（与异步专文一致） |
| `xlang://workspace/*` | 当前根下文件树（深度/数量上限） |

### 6.4 Resource 纪律

1. **单一权威**：docs 改 → 生成 resource；禁止 MCP 内硬编码另一套语法。  
2. **体积**：单 resource 默认硬顶（如 100KB）；超大用「索引 + 子 URI」。  
3. **MIME**：`text/markdown` 或 `application/json`；Agent 友好优先 markdown 结构标题。  
4. **版本**：`xlang://version` 必须可查，避免 AI 用旧手册对旧编译器。  
5. **不把** `analysis/` 全部自举债暴露为 resource（噪声+泄内部）；仅精选「用户向」切片。

---

## 7. Prompts（工作流模板）

> Prompt = 预置的「给模型的消息模板」，用户/Agent 一键选用。  
> 实现成本低；**Host 支持度不一**，故 **P1**，不阻塞 P0 tools。

| Prompt 名 | 参数 | 用途 |
|-----------|------|------|
| **`fix_compile_errors`** | `paths` 或最近 diag JSON | 指导：先 `xlang_check` → `xlang_explain` → 最小 diff → 再 check |
| **`new_bin_project`** | `name` | 指导：scaffold → 实现需求 → check → 可选 build |
| **`explain_x_for_rust_dev`** | 无 | 对照 Rust 差异清单（resource 驱动，非幻觉） |
| **`add_ffi_binding`** | `header_or_symbol` | FFI/unsafe 边界检查清单 |
| **`optimize_hot_path`** | `path` | 先测再改；提醒 PLATFORM / 假绿禁令（开发者向） |
| **`review_x_diff`** | `diff` | 审查：语法、UB、双权威、缺 check |

每个 prompt 正文应 **强制** 模型调用 tools，而不是「直接凭记忆改」。

---

## 8. 与 AI 代码编辑器集成（使用侧）

### 8.1 典型配置（stdio）

**Cursor** / 兼容 `mcp.json` 形态（示意）：

```json
{
  "mcpServers": {
    "xlang": {
      "command": "xlang",
      "args": ["--mcp"],
      "env": {
        "XLANG_MCP_WORKSPACE": "${workspaceFolder}"
      }
    }
  }
}
```

**Claude Desktop** / Claude Code：同类 `command` + `args`。  
**VS Code**（Copilot / Continue 等）：按扩展要求注册 MCP server，command 仍为 `xlang --mcp`。

### 8.2 安装体验（产品化要求）

| 步骤 | 说明 |
|------|------|
| 1. PATH 有 `xlang` | install 脚本 / 包管理；版本 `xlang --version` |
| 2. 一条配置 | 文档复制即用的 mcp 片段 |
| 3. 健康检查 | `xlang --mcp --self-test` 或 tool `xlang_language_overview` 冒烟 |
| 4. 与 LSP 并存 | 扩展可同时启 `--lsp` 与 `--mcp` **两个进程** |

### 8.3 人 vs Agent 分工

| 任务 | 推荐 |
|------|------|
| 键入时红线、跳转、补全 | **LSP** |
| 「这个语言怎么写模块」 | **MCP Resource/Tool** |
| 「帮我修这些编译错误」 | **MCP** tools 闭环 |
| 格式化保存 | LSP format 或 MCP `xlang_fmt` |
| 跑测试 / 构建 | MCP tools 或终端；终端可教 Agent 用 CLI |

### 8.4 「不用另学语法」在编辑器里的体感

1. 用户：用自然语言描述功能。  
2. Agent：`resources/read xlang://lang/overview` + 相关 syntax。  
3. Agent：`scaffold` 或编辑现有文件。  
4. Agent：`xlang_check` → 有错则 `explain` → 改 → 再 check。  
5. 人用 IDE 看 LSP 诊断二次确认。

---

## 9. 架构设计（实现层）

### 9.1 进程与模块

```text
compiler/src/main.x
  argv 含 --mcp  →  mcp_main()     // 与 --lsp 同级扫描
  argv 含 --lsp  →  typeck_lsp_main()

compiler/src/mcp/                  // 新建；PLATFORM: SHARED
  mcp.x                 主循环 JSON-RPC
  mcp_io.x              stdio 读写（可复用 lsp_io 模式，协议帧不同）
  mcp_protocol.x        initialize / list / call / read 分发
  mcp_tools_*.x         各 tool 实现（薄封装 → driver/check/fmt/…）
  mcp_resources.x       URI 路由 + 内置/生成内容
  mcp_prompts.x         模板
  mcp_workspace.x       root 绑定、路径沙箱
  mcp_json.x            最小 JSON 构造/解析（或复用现有）

内置数据（生成物，非手抄第二权威）：
  compiler/src/mcp/data/ 或 build 生成
    lang_overview.md
    syntax_*.md
    std_index.json
    diag_codes.json
```

### 9.2 与 LSP 共享层

```text
          ┌──────────── mcp_tools ────────────┐
          │                                   │
          ▼                                   ▼
   driver_cmd_check / fmt              lsp_diag_* / hover / def
          │                                   │
          └──────────► parse + typeck + diag 权威 ◄──┘
```

**G.7**：check 诊断格式若已有结构化出口，MCP **只做 JSON 包装**；禁止 MCP 正则扒 stderr 当语义。

### 9.3 协议帧（stdio）

- MCP 使用 JSON-RPC 2.0 消息；stdio 传输下 **一行一条** 或按规范 Content-Length（以实现所选 SDK/规范版本为准）。  
- **关键**：MCP 的 JSON **只走 stdout**；所有日志走 **stderr**（与 LSP 同一纪律）。  
- `initialize` → `capabilities` → `notifications/initialized` → 服务 `tools/list` 等。

### 9.4 实现策略选择（分析结论）

| 方案 | 优点 | 缺点 | 建议 |
|------|------|------|------|
| **A. 纯 .x 实现 MCP 服务器** | 与 LSP 一致；零依赖；自举后可 dogfood | JSON-RPC 工作量大；规范演进跟进成本 | **终局优选**（与 LSP 同哲学） |
| **B. 薄 .x + 外部 wrapper（Node/Python SDK）** | 上手快 | 双二进制、安装复杂、**双权威风险** | **仅原型**；禁止进产品默认路径 |
| **C. 复用 LSP 进程加 MCP 多路** | 省进程 | 协议纠缠、难测 | **否决** |

**推荐路径**：原型可短时用脚本验证 tool 集合 → **产品实现走 A**，对标现有 `lsp.x` 风格。

### 9.5 CLI 形状（与 `--lsp` 同级）

```text
xlang --mcp                      # 默认 stdio MCP server
xlang --mcp --workspace <dir>    # 绑定根（沙箱）
xlang --mcp --allow-run          # 启用 xlang_run（默认关）
xlang --mcp --transport stdio    # 显式（默认）
xlang --mcp --list-tools         # 调试：打印 tool 表后退出（不进循环）
xlang --mcp --self-test          # 无 Host 冒烟
```

`main.x` 扫描方式对齐 `eq_minus_lsp`：任意位置出现 `--mcp` 即进入 MCP（避免被当成源文件路径）。

---

## 10. 安全模型（MCP 必写清）

AI 编辑器会 **自动调 tool**，安全默认必须保守。

| 风险 | 缓解 |
|------|------|
| 路径逃逸读写 | workspace 沙箱；拒绝 `..` 出界 |
| `run` 任意代码 | 默认禁用；`--allow-run`；timeout；输出截断 |
| `build` 耗尽资源 | timeout；并发 1；可选内存策略 |
| 敏感文件 | 不读 `.env` / 密钥路径（黑名单可配） |
| 提示注入（恶意 README 教 Agent 乱调 tool） | tool 侧硬校验；危险操作需明确 flag |
| 供应链 | MCP 内置在 `xlang` 二进制，不 `npx` 随机包 |
| 日志泄源码 | stderr 默认不打完整源；可 `XLANG_MCP_DEBUG=1` |

**首期默认允许的 tool 集**：overview / check / explain / fmt(只返回文本) / search_docs / scaffold(仅 workspace 内) / std_lookup / project_info / hover / definition / symbols。  
**默认拒绝或需 flag**：run、任意 shell、写 workspace 外、改 git、网络。

---

## 11. 分阶段落地（与时序表对齐）

> **自举未完成**：只维护本分析 + 可选接口草案；**不** 大改 main 抢 residual。  
> **自举完成后**：挂 P1「产品化 / DX」或 P3「DX」旁轨（见时序表 P1 CLI、P3 DX）。

### Phase 0 — 分析与契约（本文）

- [x] 问题地图、LSP/MCP 分工  
- [ ] Tool/Resource/Prompt 清单评审（可删减）  
- [ ] 与 `XLANG 命令行.md` 交叉引用  
- [ ] 手册切片权威路径确定（docs 哪几章可生成）

### Phase 1 — 骨架（可联调）

- [ ] `main.x`：`--mcp` → `mcp_main`  
- [ ] JSON-RPC stdio 循环：`initialize` / `tools/list` / `tools/call` / `ping`  
- [ ] 实现 P0 tools：`language_overview`, `check`, `explain`, `fmt`, `scaffold`, `search_docs`  
- [ ] Resources：`version`, `lang/overview`, `diag/codes`  
- [ ] `--self-test` + 最小集成测试（可喂 JSON 行）  
- [ ] 文档：编辑器配置片段

### Phase 2 — 项目智能

- [ ] workspace 绑定与沙箱  
- [ ] `project_info`, `std_lookup`, `build`, hover/definition/symbols  
- [ ] Prompts：`fix_compile_errors`, `new_bin_project`  
- [ ] std_index 生成进发布物  
- [ ] Cursor/Claude 实测录屏级说明

### Phase 3 — 加固与扩展

- [ ] run 沙箱策略、progress、取消  
- [ ] HTTP transport（可选）  
- [ ] rename / refs / test 子集  
- [ ] 与 `xlang.toml` / `new`/`init` 同源 scaffold  
- [ ] 诊断码与 explain 全覆盖  
- [ ] 性能：大仓库 check 增量（可复用 LSP 缓存思路）

### Phase 4 — 生态

- [ ] 官方 MCP 注册说明 / 一键安装  
- [ ] 版本协商、capability 进化  
- [ ] 可选：规则集 skill 与 MCP 互补（skill 教流程，MCP 给真能力）

---

## 12. 验收标准（定义「做完」）

### 12.1 功能验收

| ID | 场景 | 期望 |
|----|------|------|
| A1 | 仅配置 MCP，无额外手册 | Agent 能 scaffold bin 并 `check` 绿 |
| A2 | 故意写错类型 | `check` 返回码+行；`explain` 后 Agent 修好 |
| A3 | 问「如何 import std」 | 读 resource 或 search_docs，**不**编造不存在的模块 |
| A4 | 与 LSP 同开 | 两进程互不抢 stdout；IDE 诊断仍可用 |
| A5 | 路径 `../outside` | tool 拒绝 |
| A6 | 无 `--allow-run` 调 run | 明确错误，不执行 |

### 12.2 工程验收

- Ubuntu + macOS：`xlang --mcp --self-test` 绿（PLATFORM: SHARED）。  
- 不引入第二套 typeck。  
- 手册切片与 docs **生成链路**可重复（CI 可挂 diff）。  
- 不破坏现有 `--lsp` / 子命令 bstrict。

### 12.3 体验验收（主观但重要）

- 新用户：**复制一段 mcp 配置** 即可在 Cursor 里让 AI 写 X。  
- 老用户：Agent 修错速度明显高于「纯聊天 + 终端手工编译」。

---

## 13. 风险与反模式

| 反模式 | 为何有害 | 正确做法 |
|--------|----------|----------|
| MCP 内硬编码语法大全与 docs 分叉 | 双权威 | 生成切片 + 版本号 |
| 把 stderr 当 API | 脆弱 | 结构化 diag JSON |
| tool 过多（50+） | 模型选错 | P0 六个打磨到稳再扩 |
| 用 MCP 替代测试 | 假绿 | check≠产品矩阵；bstrict 仍人/CI |
| wrapper 脚本长期当产品 | 安装分裂 | 终局进 `xlang` 二进制 |
| 自动 run 无沙箱 | RCE | 默认关 |
| 自举期大实现 | 偏航 | 分析先行，实现挂完成后 DX |

---

## 14. 与周边路线图的接口

| 文档/能力 | 关系 |
|-----------|------|
| 时序表 P1 CLI / `new`/`init` | scaffold **同源**；MCP 先内置模板，后接 CLI |
| 时序表 P1 `explain` | MCP `xlang_explain` 直接复用 |
| 时序表 P3 DX | MCP 可作为 DX 主交付之一 |
| `xlang.toml` | 接线后 `project_info` / scaffold 读同一权威 |
| LSP | 共享 diag；配置文档写清「人用 LSP、Agent 用 MCP」 |
| registry / 生态网站 | 后期 resource 可链官网；首期离线自洽 |
| 安全路线 | unsafe/FFI tools 与审计规则对齐 |

**建议在时序表 P1 或 P3 增加勾选项**（实现启动时再改时序表）：

```text
- [ ] xlang --mcp（stdio）：P0 tools + 基础 resources
- [ ] 编辑器配置文档 + self-test
- [ ] std/lang resource 生成进发布
```

---

## 15. 建议的 Tool 优先级总表（一张表收口）

| 优先级 | Tool | 依赖 |
|--------|------|------|
| P0 | `xlang_language_overview` | 内置手册 |
| P0 | `xlang_check` | check/typeck |
| P0 | `xlang_explain` | explain 表 |
| P0 | `xlang_fmt` | fmt |
| P0 | `xlang_scaffold` | 模板 |
| P0 | `xlang_search_docs` | 索引 |
| P1 | `xlang_project_info` | 探测 |
| P1 | `xlang_std_lookup` | std 导出 |
| P1 | `xlang_build` | build |
| P1 | `xlang_hover` / `goto_definition` / `document_symbols` | LSP 语义 |
| P1 | `xlang_module_graph` | import |
| P2 | `xlang_run` | 安全 flag |
| P2 | `xlang_find_references` / `rename` | refs |
| P2 | `xlang_test` / smoke | test |
| P2 | `xlang_complete` | completion |
| P2 | `xlang_abi_query` / audit | 文档+规则 |

| 优先级 | Resource | Prompt |
|--------|----------|--------|
| P0 | version, lang/overview, diag/codes, cli/help | — |
| P1 | syntax/*, std/index, examples/* | fix_compile_errors, new_bin_project |
| P2 | std/module/*, abi, async/model, workspace/* | explain_x_for_rust_dev, add_ffi_binding, review_x_diff |

---

## 16. 开放问题（需产品拍板）

1. **`explain` 未完全产品化前**：MCP 是否先嵌最小码表，还是 Phase1 强依赖 explain 落地？  
2. **scaffold 是否写盘**：只返回文件内容让 Host 写，还是 server 直接写 workspace？（建议：**可配置**；默认返回内容 + 可选 `write=true`。）  
3. **手册语言**：resource 默认英文还是中英双份？（源码注释纪律是英文；用户向可双份 URI。）  
4. **是否暴露 `analysis/` 自举债**：建议 **否**；仅用户文档。  
5. **规范版本**：锁定实现时点的 MCP spec（如 2025-06-18 / 2026-07-28）并在 `version` resource 声明。  
6. **Windows**：stdio MCP 与 path 沙箱；与 Windows 时序专文对齐。

---

## 17. 总结

| 问题 | 答案 |
|------|------|
| 要不要做 `xlang --mcp`？ | **要**；与 `--lsp` 同级，专供 AI 编辑器 |
| MCP 写什么？ | **Tools（验+查+脚手架）+ Resources（语法/std/诊断真源）+ Prompts（工作流）** |
| 怎样让 AI 少学语法？ | **按需 Resource + 强制 check/explain 闭环**，不是更大 system prompt |
| 和 LSP 关系？ | **正交共享权威**；不互相替代 |
| 何时实现？ | **自举完成后**挂 DX/产品化；现在定清单与契约 |
| 最大禁忌？ | **双权威语法、危险默认 run、tool 膨胀、抢自举主航道** |

---

## 18. 附录：编辑器侧一页说明（发布时可拆到 docs）

```text
# Xlang MCP

1. Install xlang and ensure `xlang --version` works.
2. Add MCP server:
   command: xlang
   args: ["--mcp"]
   env: XLANG_MCP_WORKSPACE=<your project root>
3. In chat: "Create a hello world X project and make sure it typechecks."
4. The agent should call xlang_scaffold + xlang_check (not invent a build system).
5. For humans in the IDE, also enable: xlang --lsp
```

---

*本文为分析稿；实现时另开实现 plan / wave，遵守 AGENTS.md：根源治理、单一权威、PLATFORM 标注、.x 英文注释。*
