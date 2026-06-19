/**
 * Shux DocumentSymbolProvider — 提供大纲视图（面包屑 + 大纲面板）
 *
 * 从文档源码中提取函数、结构体、枚举、trait、extern 声明。
 * 支持嵌套：struct 内部的字段作为子符号。
 */

import * as vscode from 'vscode';

export class ShuxDocumentSymbolProvider implements vscode.DocumentSymbolProvider {
  public provideDocumentSymbols(
    document: vscode.TextDocument,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.DocumentSymbol[]> {
    const symbols: vscode.DocumentSymbol[] = [];
    const text = document.getText();
    const lines = text.split('\n');

    const funcRegex = /^\s*function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*(?::\s*([^{]+?))?\s*\{/;
    const externRegex = /^\s*extern\s+function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*(?::\s*([^;]+?))?\s*;/;
    const structRegex = /^\s*(?:allow\(padding\)\s+)?struct\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const enumRegex = /^\s*enum\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const traitRegex = /^\s*trait\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const importRegex = /^\s*const\s+(?:\{[^}]+\}|\w+)\s*=\s*import\s*\(\s*"([^"]+)"\s*\)\s*;/;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const lineNum = i;
      const range = new vscode.Range(lineNum, 0, lineNum, line.length);

      // function
      const fm = funcRegex.exec(line);
      if (fm) {
        symbols.push(this.makeSymbol(
          fm[1], fm[2] || '', fm[3] || '?',
          'function', vscode.SymbolKind.Function,
          lineNum, line, this.findBlockEnd(lines, lineNum)
        ));
        continue;
      }

      // extern function
      const ex = externRegex.exec(line);
      if (ex) {
        symbols.push(this.makeSymbol(
          ex[1], ex[2] || '', ex[3] || '?',
          'extern', vscode.SymbolKind.Function,
          lineNum, line, lineNum
        ));
        continue;
      }

      // struct
      const sm = structRegex.exec(line);
      if (sm) {
        const sl = this.makeSymbol(
          sm[1], '', '',
          'struct', vscode.SymbolKind.Struct,
          lineNum, line, this.findBlockEnd(lines, lineNum)
        );
        // Extract fields as children
        this.extractStructFields(sl, lines, lineNum);
        symbols.push(sl);
        continue;
      }

      // enum
      const em = enumRegex.exec(line);
      if (em) {
        const el = this.makeSymbol(
          em[1], '', '',
          'enum', vscode.SymbolKind.Enum,
          lineNum, line, this.findBlockEnd(lines, lineNum)
        );
        this.extractEnumVariants(el, lines, lineNum);
        symbols.push(el);
        continue;
      }

      // trait
      const tm = traitRegex.exec(line);
      if (tm) {
        symbols.push(this.makeSymbol(
          tm[1], '', '',
          'trait', vscode.SymbolKind.Interface,
          lineNum, line, this.findBlockEnd(lines, lineNum)
        ));
        continue;
      }

      // import
      const im = importRegex.exec(line);
      if (im) {
        symbols.push(this.makeSymbol(
          im[1], '', '',
          'import', vscode.SymbolKind.Module,
          lineNum, line, lineNum
        ));
      }
    }

    return symbols;
  }

  private makeSymbol(
    name: string,
    params: string,
    retType: string,
    kind: string,
    symKind: vscode.SymbolKind,
    startLine: number,
    startText: string,
    endLine: number
  ): vscode.DocumentSymbol {
    let detail: string;
    switch (kind) {
      case 'function':
      case 'extern':
        detail = `fn ${name}(${params.trim()}): ${retType.trim()}`;
        break;
      case 'struct':
        detail = `struct ${name}`;
        break;
      case 'enum':
        detail = `enum ${name}`;
        break;
      case 'trait':
        detail = `trait ${name}`;
        break;
      default:
        detail = `import ${name}`;
    }

    return new vscode.DocumentSymbol(
      name,
      detail,
      symKind,
      new vscode.Range(startLine, 0, endLine, 0),
      new vscode.Range(startLine, 0, startLine, startText.length)
    );
  }

  /** 从 startLine 起查找匹配的 `}` 所在行 */
  private findBlockEnd(lines: string[], startLine: number): number {
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') depth++;
        else if (line[j] === '}') {
          depth--;
          if (depth === 0) return i;
        }
      }
    }
    return lines.length - 1;
  }

  /** 从 struct 体提取字段作为子符号 */
  private extractStructFields(parent: vscode.DocumentSymbol, lines: string[], startLine: number): void {
    const endLine = this.findBlockEnd(lines, startLine);
    const fieldRegex = /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*([^;]+);/;

    for (let i = startLine + 1; i < endLine; i++) {
      const m = fieldRegex.exec(lines[i]);
      if (m) {
        parent.children.push(new vscode.DocumentSymbol(
          m[1],
          `: ${m[2].trim()}`,
          vscode.SymbolKind.Field,
          new vscode.Range(i, 0, i, lines[i].length),
          new vscode.Range(i, 0, i, lines[i].length)
        ));
      }
    }
  }

  /** 从 enum 体提取变体作为子符号 */
  private extractEnumVariants(parent: vscode.DocumentSymbol, lines: string[], startLine: number): void {
    const endLine = this.findBlockEnd(lines, startLine);
    const variantRegex = /^\s*([A-Z][A-Z0-9_]*)\s*,?/;

    for (let i = startLine + 1; i < endLine; i++) {
      const m = variantRegex.exec(lines[i]);
      if (m) {
        parent.children.push(new vscode.DocumentSymbol(
          m[1],
          'enum variant',
          vscode.SymbolKind.EnumMember,
          new vscode.Range(i, 0, i, lines[i].length),
          new vscode.Range(i, 0, i, lines[i].length)
        ));
      }
    }
  }
}
