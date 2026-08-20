# AI / Agent 友好材料（知识面 · 不碰编译器）

> **用途**：给写 **应用 / 库** 的 AI Agent（及人类）用的**短真源**。  
> **不是**：语言规范全书（那是 [`docs/`](../README.md)）；也不是编译器自举纪律（那是 `AGENTS.md` + skill `xlang-selfhost-product-gate`）。  
> **原则**：只引用、精摘、对照；**禁止**在此维护第二套完整语法。与实现冲突时以 **`docs/01`–`10` + 编译器** 为准。  
> **自举**：本目录**仅文档**，不改 `compiler/` / seed / glue，**不抢** BC residual。

| 文件 | 给谁 | 内容 |
|------|------|------|
| [cheat-sheet.md](./cheat-sheet.md) | 写代码前 30 秒 | 标准形、关键字、import、类型、坑 |
| [canonical-shape.md](./canonical-shape.md) | 生成代码模板 | 官方 Canonical X Shape（可抄模板） |
| [anti-patterns.md](./anti-patterns.md) | 修幻觉 / 审 diff | H01–H16：错 → 对 |
| [skills-entry.md](./skills-entry.md) | 将来官方 Skills | 占位入口；现指向本目录短文 |

### 工作流（Agent 默认）

```text
1. 读 cheat-sheet（或已内化）
2. 需要模板 → canonical-shape
3. 生成最小切片（优先仿 examples/hello.x）
4. 真编译器 check / build（应用项目）；勿用「我觉得能编过」
5. 红了 → anti-patterns 对照 + 诊断 code
6. 需要完整规则 → docs/01–10；需要 std API → docs/07 或源码 export
```

### 分轨（禁止混用）

| 轨 | 场景 | 材料 |
|----|------|------|
| **A · 应用** | 用 X 写业务 / 库 | **本目录** + `docs/` + 将来官方 Skills/MCP |
| **B · 实现者** | 改 x-lang 仓 / 自举 | `AGENTS.md` · product-gate skill · `analysis/自举*` |

**禁止**把 L4 全擦、seed pin、g05 写进应用 Agent 的默认剧本。

### 相关分析（人读 / 排期，非运行时真源）

- [`analysis/AI友好特性分析.md`](../../analysis/AI友好特性分析.md)  
- [`analysis/合约设计与Agent支持.md`](../../analysis/合约设计与Agent支持.md)  
- [`analysis/xlang-官方Skills分析.md`](../../analysis/xlang-官方Skills分析.md)  
- [`analysis/xlang-mcp-服务分析.md`](../../analysis/xlang-mcp-服务分析.md)  

### 可编译示例（产品树，优先引用勿复制改语义）

- [`examples/hello.x`](../../examples/hello.x) — Hello World  
- [`examples/cookbook/`](../../examples/cookbook/) — 模块级小例子  
- [`examples/README.md`](../../examples/README.md)  

### 版本与维护

| 规则 | 说明 |
|------|------|
| 语法变更 | 先改 `docs/01`–`10`，再改本目录精摘 |
| 示例 | 正文模板须与 Canonical Shape 一致；运行时以 tip 编译器为准 |
| 幻觉表 | `anti-patterns.md` 的 H 编号与 AI 友好分析文对齐，增删同步两边 |
| 不进本目录 | 编译器补丁、假绿绕过、第二套 typeck 说明 |
