# TOOL-009：VS Code 扩展 0.2 稳定发布 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：`editors/vscode` 0.1.x、ENG-005 版本节奏  
> 关联：LANG-009/010（Option/Result 泛型）、STD-041（async）、TOOL-001～008

---

## 1. 目标

发布 **vscode-shux 0.2.0** 稳定扩展包：语法 grammar 覆盖 Phase 3 语言面（泛型、async/await、unsafe），**vsix + grammar gate** 可复现。

验收：`tests/run-tool-vscode-020-gate.sh` 绿；`VERSION` 与 `package.json` version **0.2.0** 同步。

---

## 2. Grammar 规则矩阵（G1–G8）

| rule_id | 锚点 | 金样 | 说明 |
|---------|------|------|------|
| `rule_import` | `keyword.control.import` | `import_core.x` | import 行分色 |
| `rule_struct` | `meta.block.struct` | `match_arm.x` | struct/enum 体 |
| `rule_generic` | `meta.type.generic` | `option_generic.x` | `Option<i32>` / `Result<T,E>` |
| `rule_async` | `\\b(async\|await)\\b` | `async_await.x` | async/await 关键字 |
| `rule_unsafe` | `\\b(unsafe)\\b` | `unsafe_ptr.x` | unsafe 块 |
| `rule_match` | `(if\|else\|match)` | `match_arm.x` | match 控制流 |
| `rule_trait` | `\\btrait\\b` | grammar 内嵌 | trait/impl |
| `rule_primitives` | `support.type.primitive` | `option_generic.x` | i32/u8/… 基元 |

grammar 文件：`editors/vscode/grammars/x.tmLanguage.json`。

---

## 3. 发布物

| 产物 | 路径 |
|------|------|
| 扩展包 | `editors/vscode/vscode-shux-0.2.0.vsix` |
| 编译产出 | `editors/vscode/out/extension.js` |
| 版本锚点 | 根目录 `VERSION` = `0.2.0` |

打包顺序见 `editors/vscode/打包与安装说明.md`：`npm install` → `npm run compile` → `npx vsce package`。

---

## 4. Gate

```bash
./tests/run-tool-vscode-020-gate.sh
```

```
shux: [SHUX_TOOL009_VSCODE_020] status=ok grammar_ok=8 vsix_ok=1 skip=0
```

无 `node`/`npm` 时 manifest + grammar JSON 仍须绿；vsix runnable **SKIP**。

---

## 5. 非目标（v2）

- Marketplace 自动发布
- TextMate scope 逐 token 快照（vscode-tmgrammar-test 全量）
- 扩展 E2E UI 测试
