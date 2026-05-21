/**
 * Shulang SignatureHelpProvider — 函数参数提示
 *
 * 当输入 `func(` 时弹出参数签名提示。
 * 从当前文件解析函数定义，展示参数名和类型。
 */

import * as vscode from 'vscode';

export class ShulangSignatureHelpProvider implements vscode.SignatureHelpProvider {
  public provideSignatureHelp(
    document: vscode.TextDocument,
    position: vscode.Position,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.SignatureHelp> {
    // 找到当前光标所在的调用表达式
    const callInfo = this.findCallAtPosition(document, position);
    if (!callInfo) return null;

    // 在文档中查找匹配的函数定义
    const funcDefs = this.findAllFunctionDefs(document);
    const match = funcDefs.find(f => f.name === callInfo.name);
    if (!match) return null;

    const help = new vscode.SignatureHelp();
    const sig = new vscode.SignatureInformation(
      `${match.name}(${match.params})`,
      match.doc ?? `函数: ${match.name}`
    );

    // 为每个参数添加标签
    if (match.paramList.length > 0) {
      sig.parameters = match.paramList.map(p => {
        const pi = new vscode.ParameterInformation(p.name);
        pi.documentation = `: ${p.type}`;
        return pi;
      });
    }

    sig.documentation = new vscode.MarkdownString(
      `\`\`\`su\n${match.name}(${match.params}): ${match.retType}\n\`\`\``
    );

    help.signatures = [sig];
    help.activeParameter = Math.min(callInfo.commaCount, Math.max(0, match.paramList.length - 1));
    help.activeSignature = 0;

    return help;
  }

  private findCallAtPosition(
    document: vscode.TextDocument,
    position: vscode.Position
  ): { name: string; commaCount: number } | null {
    const line = document.lineAt(position.line).text;
    const before = line.substring(0, position.character);

    // 反向查找最近的 ( 前面第一个标识符
    let depth = 0;
    let commaCount = 0;
    for (let i = before.length - 1; i >= 0; i--) {
      const ch = before[i];
      if (ch === ')') {
        depth++;
      } else if (ch === '(') {
        if (depth > 0) {
          depth--;
        } else {
          // 找到左括号，往前读函数名
          const preParen = before.substring(0, i);
          const nameMatch = /([a-zA-Z_][a-zA-Z0-9_]*)$/.exec(preParen.trimEnd());
          if (nameMatch) {
            // 统计括号后的逗号数
            const inside = line.substring(i + 1, position.character);
            commaCount = (inside.match(/,/g) || []).length;
            return { name: nameMatch[1], commaCount };
          }
          return null;
        }
      } else if (ch === ',') {
        if (depth === 0) commaCount++;
      }
    }

    return null;
  }

  private findAllFunctionDefs(document: vscode.TextDocument): Array<{
    name: string;
    params: string;
    retType: string;
    doc: string | null;
    paramList: Array<{ name: string; type: string }>;
  }> {
    const result: Array<{
      name: string;
      params: string;
      retType: string;
      doc: string | null;
      paramList: Array<{ name: string; type: string }>;
    }> = [];
    const lines = document.getText().split('\n');
    const funcRegex = /^\s*(?:extern\s+)?function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*(?::\s*([^{;]+))?/;

    for (let i = 0; i < lines.length; i++) {
      const m = funcRegex.exec(lines[i]);
      if (m) {
        const params = m[2].trim();
        const retType = (m[3] || '?').trim();
        const paramList = this.parseParamList(params);

        // 查找文档注释
        let doc: string | null = null;
        let j = i - 1;
        while (j >= 0 && /^\s*(\*|\/\/)/.test(lines[j])) {
          const content = lines[j].replace(/^\s*\*+\s?/, '').replace(/^\s*\/\/\s?/, '').trim();
          if (content) doc = content;
          j--;
        }

        result.push({ name: m[1], params, retType, doc, paramList });
      }
    }

    return result;
  }

  private parseParamList(params: string): Array<{ name: string; type: string }> {
    if (!params) return [];
    return params.split(',').map(p => {
      const parts = p.trim().split(':').map(s => s.trim().replace(/\*+/g, '*'));
      if (parts.length >= 2) {
        return { name: parts[0], type: parts.slice(1).join(': ') };
      }
      return { name: parts[0] || '?', type: '?' };
    });
  }
}
