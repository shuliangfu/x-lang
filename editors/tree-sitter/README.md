# tree-sitter-shux

Shux 语言 grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter) — 跨编辑器增量解析。

## 支持的编辑器

| 编辑器 | 集成方式 |
|--------|----------|
| Neovim | 原生 `nvim-treesitter` |
| Helix | 原生（`languages.toml`） |
| Emacs | `tree-sitter-mode` |
| Zed | 原生 |
| VS Code | 需 `tree-sitter` 扩展 |

## 生成 parser

```bash
# 安装 tree-sitter CLI
npm install -g tree-sitter-cli

# 生成 parser.c
cd editors/tree-sitter
tree-sitter generate
```

生成后 `src/parser.c` 可用于各编辑器编译。

## 测试

```bash
tree-sitter test
```

## 语法覆盖

基于 `compiler/src/lexer/lexer.x` 的 `try_keyword` 字节码定义与 `editors/vscode/grammars/x.tmLanguage.json` 已验证模式同步：

- **声明**：`function` / `struct` / `enum` / `trait` / `impl` / `type` / `const` / `import`
- **修饰符**：`export` / `extern` / `extern "C"` / `extern "X"` / `packed` / `soa` / `align` / `allow(padding)`
- **控制流**：`if` / `else` / `match` / `while` / `for (i : 0 .. n)` / `loop` / `break` / `continue` / `return`
- **特殊**：`unsafe { }` / `region { }` / `with_arena { }` / `defer` / `goto` / `panic` / `async` / `await` / `run` / `spawn`
- **类型**：`i8/i16/i32/i64/isize` / `u8/u16/u32/u64/usize` / `f32/f64` / `bool/void` / `i32x4/i32x8/i32x16/u32x4/u32x8/u32x16` / `*T` / `T[]<lifetime>` / `[n]T` / `Option<T>` / `function(...)->T`
- **字面量**：整数（`0x`/`0o`/`0b`/十进制 + 类型后缀）/ 浮点 / 字符串（带转义）/ 布尔
- **注释**：`// line` / `# hash`（非 `#[`）/ `/* block */`
- **属性**：`#[name]` / `#[name(args)]`

## 同步约定

按 `AGENTS.md` 禁止双权威原则：本文件必须与 `compiler/src/lexer/lexer.x` 和 `compiler/src/parser/parser.x` 同步演进。新增关键字或语法时，三处必须同时更新。

## License

AGPL-3.0-or-later
