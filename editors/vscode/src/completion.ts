/**
 * Shulang CompletionItemProvider — 智能补全
 *
 * 提供关键字、当前文件内函数、结构体名、字段、枚举变体等的补全。
 * 在 LSP 补全不可用时作为本地回退。
 *
 * 支持上下文感知：
 * - 在 function 参数列表内 → 补全类型名（i32, f64 等）
 * - 在 let/const 声明中 → 类型名 + 当前 scope 内已有的变量名
 * - 在 struct 字面量 { } 内 → 字段名
 * - 在 import 后 → 已知的模块路径片段
 * - 在 . 后面 → 结构体字段名
 */

import * as vscode from 'vscode';

export class ShulangCompletionItemProvider implements vscode.CompletionItemProvider {
  // ── 关键字 ──
  private readonly keywords = [
    { label: 'function', detail: '函数定义', insertText: 'function ${1:name}(${2}): ${3:i32} {\n\t$0\n}' },
    { label: 'extern', detail: '外部函数声明', insertText: 'extern function ${1:name}(${2}): ${3:i32};' },
    { label: 'let', detail: '变量声明', insertText: 'let ${1:name}: ${2:i32} = ${3:0};' },
    { label: 'const', detail: '常量声明', insertText: 'const ${1:NAME}: ${2:i32} = ${3:0};' },
    { label: 'struct', detail: '结构体定义', insertText: 'struct ${1:Name} {\n\t${2:field}: ${3:i32};$0\n}' },
    { label: 'allow(padding)', detail: '允许填充的结构体定义', insertText: 'allow(padding) struct ${1:Name} {\n\t$0\n}' },
    { label: 'enum', detail: '枚举定义', insertText: 'enum ${1:Name} {\n\t${2:VARIANT},$0\n}' },
    { label: 'trait', detail: 'trait 定义', insertText: 'trait ${1:Name} {\n\t$0\n}' },
    { label: 'impl', detail: 'trait 实现', insertText: 'impl ${1:Trait} for ${2:Type} {\n\t$0\n}' },
    { label: 'import', detail: '导入模块', insertText: 'import ${1:module};' },
    { label: 'if', detail: 'if 语句', insertText: 'if (${1:condition}) {\n\t$0\n}' },
    { label: 'else', detail: 'else 分支', insertText: 'else {\n\t$0\n}' },
    { label: 'while', detail: 'while 循环', insertText: 'while (${1:condition}) {\n\t$0\n}' },
    { label: 'for', detail: 'for 循环', insertText: 'for (let ${1:i}: i32 = ${2:0}; ${1:i} < ${3:n}; ${1:i} = ${1:i} + 1) {\n\t$0\n}' },
    { label: 'loop', detail: '无限循环', insertText: 'loop {\n\t$0\n}' },
    { label: 'match', detail: 'match 表达式', insertText: 'match (${1:expr}) {\n\t${2:Variant} => ${3:result},\n\t_ => ${4:default},\n}' },
    { label: 'return', detail: '返回语句', insertText: 'return ${1:expr};' },
    { label: 'break', detail: 'break 语句', insertText: 'break;' },
    { label: 'continue', detail: 'continue 语句', insertText: 'continue;' },
    { label: 'defer', detail: 'defer 块', insertText: 'defer {\n\t$0\n}' },
    { label: 'goto', detail: 'goto 语句', insertText: 'goto ${1:label};' },
    { label: 'panic', detail: 'panic 语句', insertText: 'panic;' },
    { label: 'self', detail: 'self 引用', insertText: 'self' },
  ];

  // ── 内置类型 ──
  private readonly types = [
    { label: 'i32', detail: '32 位有符号整数' },
    { label: 'i64', detail: '64 位有符号整数' },
    { label: 'u8', detail: '8 位无符号整数（字节）' },
    { label: 'u32', detail: '32 位无符号整数' },
    { label: 'u64', detail: '64 位无符号整数' },
    { label: 'usize', detail: '指针大小的无符号整数' },
    { label: 'isize', detail: '指针大小的有符号整数' },
    { label: 'f32', detail: '32 位单精度浮点' },
    { label: 'f64', detail: '64 位双精度浮点' },
    { label: 'bool', detail: '布尔值' },
    { label: 'void', detail: '空类型' },
    { label: 'i32x4', detail: '128 位 SIMD 向量' },
    { label: 'i32x8', detail: '256 位 SIMD 向量' },
    { label: 'i32x16', detail: '512 位 SIMD 向量' },
    { label: 'u32x4', detail: '128 位无符号 SIMD 向量' },
    { label: 'u32x8', detail: '256 位无符号 SIMD 向量' },
    { label: 'u32x16', detail: '512 位无符号 SIMD 向量' },
  ];

  private readonly constants = [
    { label: 'true', detail: '布尔真值' },
    { label: 'false', detail: '布尔假值' },
  ];

  public async provideCompletionItems(
    document: vscode.TextDocument,
    position: vscode.Position,
    _token: vscode.CancellationToken
  ): Promise<vscode.CompletionItem[]> {
    const items: vscode.CompletionItem[] = [];
    const line = document.lineAt(position.line).text;
    const textBefore = line.substring(0, position.character);

    // ── 上下文检测 ──

    // import 路径上下文
    if (/\bimport\s+[a-zA-Z_.]*$/.test(textBefore)) {
      return this.completeImportPath(document, textBefore);
    }

    // 类型注解上下文 (let/const/function param/function return type after :)
    if (/:\s*[a-zA-Z_]*$/.test(textBefore)) {
      return this.completeTypes(document);
    }

    // struct 字面量内 / 成员访问 . 后
    if (/\.\s*[a-zA-Z_]*$/.test(textBefore)) {
      return this.completeFieldAccess(document, textBefore);
    }

    // function 参数列表内（尚未闭合括号）
    if (this.insideFunctionParams(line, position)) {
      return this.completeTypes(document);
    }

    // ── 默认：关键字 + 当前文件符号 ──
    this.addKeywords(items);
    this.addConstants(items);
    this.addDocumentSymbols(document, items);

    return items;
  }

  // ── 关键字补全 ──
  private addKeywords(items: vscode.CompletionItem[]): void {
    for (const kw of this.keywords) {
      const item = new vscode.CompletionItem(kw.label, vscode.CompletionItemKind.Keyword);
      item.detail = kw.detail;
      if (kw.insertText) {
        item.insertText = new vscode.SnippetString(kw.insertText);
      }
      item.sortText = '0_' + kw.label;
      items.push(item);
    }
  }

  // ── 常量补全 ──
  private addConstants(items: vscode.CompletionItem[]): void {
    for (const c of this.constants) {
      const item = new vscode.CompletionItem(c.label, vscode.CompletionItemKind.Constant);
      item.detail = c.detail;
      item.sortText = '1_' + c.label;
      items.push(item);
    }
  }

  // ── 类型补全 ──
  private completeTypes(document: vscode.TextDocument): vscode.CompletionItem[] {
    const items: vscode.CompletionItem[] = [];

    // 内置类型
    for (const t of this.types) {
      const item = new vscode.CompletionItem(t.label, vscode.CompletionItemKind.TypeParameter);
      item.detail = t.detail;
      item.sortText = '0_' + t.label;
      items.push(item);
    }

    // 本文件定义的类型（struct/enum/trait）
    this.addDocumentTypes(document, items);

    return items;
  }

  // ── 字段访问补全 ──
  private completeFieldAccess(document: vscode.TextDocument, textBefore: string): vscode.CompletionItem[] {
    const items: vscode.CompletionItem[] = [];

    // 提取 . 前面的标识符
    const match = /([a-zA-Z_][a-zA-Z0-9_]*)\.\s*[a-zA-Z_]*$/.exec(textBefore);
    if (!match) return items;

    const baseName = match[1];
    const structDef = this.findStructDef(document, baseName);

    if (structDef) {
      for (const field of structDef.fields) {
        const item = new vscode.CompletionItem(field.name, vscode.CompletionItemKind.Field);
        item.detail = `: ${field.type}`;
        item.sortText = '0_' + field.name;
        item.documentation = new vscode.MarkdownString(`\`${field.name}: ${field.type}\``);
        items.push(item);
      }
    }

    return items;
  }

  // ── import 路径补全 ──
  private completeImportPath(document: vscode.TextDocument, textBefore: string): vscode.CompletionItem[] {
    const items: vscode.CompletionItem[] = [];
    const match = /\bimport\s+([a-zA-Z_.]*)$/.exec(textBefore);
    const partial = match ? match[1] : '';

    // 提取当前文件已有 import，提供快速补全
    const existing = this.extractImports(document);
    for (const imp of existing) {
      if (imp.startsWith(partial) && imp !== partial) {
        const item = new vscode.CompletionItem(imp, vscode.CompletionItemKind.Module);
        item.detail = '已导入模块';
        item.sortText = '0_' + imp;
        items.push(item);
      }
    }

    // 常见标准库模块
    const stdModules = ['std.fs', 'std.io', 'std.heap', 'std.io.core', 'std.io.driver',
      'lexer', 'token', 'ast', 'typeck', 'codegen', 'parser', 'fmt'];
    for (const mod of stdModules) {
      if (mod.startsWith(partial) && !existing.includes(mod)) {
        const item = new vscode.CompletionItem(mod, vscode.CompletionItemKind.Module);
        item.detail = partial ? '' : '标准库/项目模块';
        item.sortText = '1_' + mod;
        items.push(item);
      }
    }

    return items;
  }

  // ── 从当前文档提取符号 ──
  private addDocumentSymbols(document: vscode.TextDocument, items: vscode.CompletionItem[]): void {
    const text = document.getText();
    const lines = text.split('\n');

    // 函数
    const funcRegex = /^\s*(?:extern\s+)?function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*(?::\s*([^\s{;]+))?/gm;
    let m;
    while ((m = funcRegex.exec(text)) !== null) {
      const item = new vscode.CompletionItem(m[1], vscode.CompletionItemKind.Function);
      item.detail = `fn(${m[2].trim()}): ${(m[3] || '?').trim()}`;
      item.sortText = '2_' + m[1];
      item.insertText = m[1] + '($0)';
      item.insertText = new vscode.SnippetString(m[1] + '($0)');
      // 不在同一行
      const lineNum = text.substring(0, m.index).split('\n').length - 1;
      item.documentation = new vscode.MarkdownString(
        `\`\`\`su\nfunction ${m[1]}(${m[2].trim()}): ${(m[3] || '?').trim()}\n\`\`\`  \n_行 ${lineNum + 1}_`
      );
      items.push(item);
    }

    // 结构体/枚举/trait
    const typeRegex = /^\s*(?:allow\(padding\)\s+)?(struct|enum|trait)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/gm;
    while ((m = typeRegex.exec(text)) !== null) {
      let kind: vscode.CompletionItemKind;
      switch (m[1]) {
        case 'struct': kind = vscode.CompletionItemKind.Struct; break;
        case 'enum': kind = vscode.CompletionItemKind.Enum; break;
        default: kind = vscode.CompletionItemKind.Interface;
      }
      const item = new vscode.CompletionItem(m[2], kind);
      item.detail = m[1];
      item.sortText = '3_' + m[2];
      items.push(item);
    }

    // let/const 变量
    const varRegex = /^\s*(let|const)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*:/gm;
    while ((m = varRegex.exec(text)) !== null) {
      const item = new vscode.CompletionItem(
        m[2],
        m[1] === 'let' ? vscode.CompletionItemKind.Variable : vscode.CompletionItemKind.Constant
      );
      item.detail = m[1];
      item.sortText = '4_' + m[2];
      items.push(item);
    }
  }

  // ── 从当前文档提取结构体和枚举类型名 ──
  private addDocumentTypes(document: vscode.TextDocument, items: vscode.CompletionItem[]): void {
    const text = document.getText();
    const typeRegex = /^\s*(?:allow\(padding\)\s+)?(struct|enum|trait)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/gm;
    let m;
    while ((m = typeRegex.exec(text)) !== null) {
      const item = new vscode.CompletionItem(m[2], vscode.CompletionItemKind.TypeParameter);
      item.detail = m[1];
      item.sortText = '1_' + m[2];
      items.push(item);
    }
  }

  // ── 查找结构体定义 ──
  private findStructDef(document: vscode.TextDocument, name: string): { fields: Array<{ name: string; type: string }> } | null {
    const text = document.getText();
    const lines = text.split('\n');
    const regex = new RegExp(
      `^\\s*(?:allow\\(padding\\)\\s+)?struct\\s+${this.escapeRegex(name)}\\s*\\{`
    );

    for (let i = 0; i < lines.length; i++) {
      if (regex.test(lines[i])) {
        return { fields: this.extractFields(lines, i) };
      }
    }
    return null;
  }

  private extractFields(lines: string[], startLine: number): Array<{ name: string; type: string }> {
    const fieldRegex = /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*([^;]+);/;
    const fields: Array<{ name: string; type: string }> = [];
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      for (let j = 0; j < lines[i].length; j++) {
        if (lines[i][j] === '{') depth++;
        else if (lines[i][j] === '}') {
          depth--;
          if (depth === 0) return fields;
        }
      }
      if (depth === 1) {
        const m = fieldRegex.exec(lines[i]);
        if (m) fields.push({ name: m[1], type: m[2].trim() });
      }
    }
    return fields;
  }

  private extractImports(document: vscode.TextDocument): string[] {
    const importRegex = /^\s*import\s+([a-zA-Z_][a-zA-Z0-9_.]*)\s*;/gm;
    const imports: string[] = [];
    let m;
    while ((m = importRegex.exec(document.getText())) !== null) {
      imports.push(m[1]);
    }
    return imports;
  }

  /** 判断光标是否在函数参数列表（括号内） */
  private insideFunctionParams(line: string, position: vscode.Position): boolean {
    const before = line.substring(0, position.character);
    // 查找最近一个 ( 且之后没有闭合 )
    let depth = 0;
    for (let i = before.length - 1; i >= 0; i--) {
      if (before[i] === ')') depth++;
      else if (before[i] === '(') {
        if (depth > 0) depth--;
        else return true; // 在括号内
      }
    }
    return false;
  }

  private escapeRegex(s: string): string {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
}
