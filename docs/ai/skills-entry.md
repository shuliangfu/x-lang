# 应用轨 Skill 入口（占位）

> **状态**：占位 + 指针（2026-08-06）。完整 `SKILL.md` Host 包装**尚未**产品化落地。  
> **为何在 `docs/ai/`**：仓内 `.gitignore` 含裸名 `xlang`，路径 `skills/xlang/` 会被忽略，故 canonical 入口放此处，避免「写了进不了 git」。

## 现在 Agent 读什么？

| 材料 | 路径 |
|------|------|
| 索引 | [README.md](./README.md) |
| 一页速查 | [cheat-sheet.md](./cheat-sheet.md) |
| 生成模板 | [canonical-shape.md](./canonical-shape.md) |
| 幻觉对照 | [anti-patterns.md](./anti-patterns.md) |
| 语法全书 | [../README.md](../README.md) |

**禁止**在 Skill 正文复制整本 `docs/08` 当第二权威。

## 计划中的 Skills

清单：[`analysis/xlang-官方Skills分析.md`](../../analysis/xlang-官方Skills分析.md)（S0–S10）。

落地时建议：

1. `SKILL.md` 只写流程与纪律；  
2. `references/` **链接**本目录四份短文；  
3. Host 适配（Grok / Cursor / Claude）可多套，**内容一份**。

## 分轨

| 轨 | 材料 |
|----|------|
| 应用写 X | **本目录 `docs/ai/`** |
| 改编译器 / 自举 | `AGENTS.md` · skill `xlang-selfhost-product-gate` |

**禁止**把 L4 全擦写进「新建 hello」类 Skill。
