/**
 * Shulang CodeLensProvider — 行内代码提示
 *
 * 在函数定义上方插入 CodeLens：
 * - "▶ Run" — 在 main 函数上方提供运行入口
 * - "0 references" — 占位引用计数（LSP 未连接时的回退提示）
 */

import * as vscode from 'vscode';

export class ShulangCodeLensProvider implements vscode.CodeLensProvider {
  private _onDidChangeCodeLenses = new vscode.EventEmitter<void>();
  public readonly onDidChangeCodeLenses = this._onDidChangeCodeLenses.event;

  public provideCodeLenses(
    document: vscode.TextDocument,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.CodeLens[]> {
    const lenses: vscode.CodeLens[] = [];
    const text = document.getText();
    const lines = text.split('\n');

    // 函数定义正则（捕获函数名）
    const mainRegex = /^\s*function\s+main\s*\(/;
    const funcRegex = /^\s*function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/;
    const externRegex = /^\s*extern\s+function\s+(?!#).*?;/;
    const structRegex = /^\s*(?:allow\(padding\)\s+)?struct\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const enumRegex = /^\s*enum\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;

    let funcCount = 0;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // main 函数 — "▶ Run"
      if (mainRegex.test(line)) {
        const range = new vscode.Range(i, 0, i, 0);
        const lens = new vscode.CodeLens(range, {
          title: '▶ Run',
          command: 'shulang.runFile',
          tooltip: '运行此文件（shu <file>）',
          arguments: [document.uri],
        });
        lenses.push(lens);
        funcCount++;
        continue;
      }

      // 普通函数定义
      const fm = funcRegex.exec(line);
      if (fm) {
        const range = new vscode.Range(i, 0, i, 0);
        // 引用计数（本地估算：无法精确，提示用户）
        const lens = new vscode.CodeLens(range, {
          title: 'fn',
          command: '',
          tooltip: `函数: ${fm[1]}`,
        });
        lenses.push(lens);
        funcCount++;
        continue;
      }

      // extern function
      if (externRegex.test(line)) {
        const range = new vscode.Range(i, 0, i, 0);
        const lens = new vscode.CodeLens(range, {
          title: 'extern fn',
          command: '',
          tooltip: '外部函数声明',
        });
        lenses.push(lens);
        continue;
      }

      // struct
      const sm = structRegex.exec(line);
      if (sm) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractStructFieldCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: `${len} fields`,
          command: '',
          tooltip: `结构体: ${sm[1]} — ${len} 个字段`,
        });
        lenses.push(lens);
        continue;
      }

      // enum
      const em = enumRegex.exec(line);
      if (em) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractEnumVariantCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: `${len} variants`,
          command: '',
          tooltip: `枚举: ${em[1]} — ${len} 个变体`,
        });
        lenses.push(lens);
      }
    }

    return lenses;
  }

  /** 统计 struct 字段数 */
  private extractStructFieldCount(lines: string[], startLine: number): number {
    const fieldRegex = /^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*:/;
    let count = 0;
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') depth++;
        else if (line[j] === '}') {
          depth--;
          if (depth === 0) return count;
        }
      }
      if (depth === 1 && fieldRegex.test(line)) count++;
    }
    return count;
  }

  /** 统计 enum 变体数 */
  private extractEnumVariantCount(lines: string[], startLine: number): number {
    const variantRegex = /^\s*[A-Z][A-Z0-9_]*\s*,?/;
    let count = 0;
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') depth++;
        else if (line[j] === '}') {
          depth--;
          if (depth === 0) return count;
        }
      }
      if (depth === 1 && variantRegex.test(line)) count++;
    }
    return count;
  }

  /** 刷新 CodeLens */
  public refresh(): void {
    this._onDidChangeCodeLenses.fire();
  }
}
