/**
 * Shulang HoverProvider — 悬停提示
 *
 * 悬停函数名 / 结构体名 / 变量时显示其签名、类型、文档注释。
 * 在 LSP 未启动或 LSP 不支持 hover 时作为本地回退。
 */

import * as vscode from 'vscode';
import { buildImportResolveHover, importPathAtPosition } from './symbolSearch';

export class ShulangHoverProvider implements vscode.HoverProvider {
  public async provideHover(
    document: vscode.TextDocument,
    position: vscode.Position,
    _token: vscode.CancellationToken
  ): Promise<vscode.Hover | null> {
    // import 路径悬停：成功显示目标文件，失败列出尝试路径
    const imp = importPathAtPosition(document, position);
    if (imp) {
      const md = await buildImportResolveHover(document, imp);
      const wordRange = document.getWordRangeAtPosition(position);
      return new vscode.Hover(md, wordRange ?? undefined);
    }

    const wordRange = document.getWordRangeAtPosition(position);
    if (!wordRange) {
      return null;
    }

    const word = document.getText(wordRange);
    const text = document.getText();
    const lines = text.split('\n');

    // ── 1. 查找函数定义 ──
    const funcDef = this.findFunctionDef(lines, word);
    if (funcDef) {
      return new vscode.Hover(
        {
          language: 'shulang',
          value: funcDef,
        },
        wordRange
      );
    }

    // ── 2. 查找结构体定义 ──
    const structDef = this.findStructDef(lines, word);
    if (structDef) {
      return new vscode.Hover({
        language: 'shulang',
        value: structDef,
      }, wordRange);
    }

    // ── 3. 查找枚举定义 ──
    const enumDef = this.findEnumDef(lines, word);
    if (enumDef) {
      return new vscode.Hover({
        language: 'shulang',
        value: enumDef,
      }, wordRange);
    }

    // ── 4. 查找 let/const 声明 ──
    const varDef = this.findVariableDef(lines, word, position.line);
    if (varDef) {
      return new vscode.Hover({
        language: 'shulang',
        value: varDef,
      }, wordRange);
    }

    // ── 5. 查找 extern 声明 ──
    const externDef = this.findExternDef(lines, word);
    if (externDef) {
      return new vscode.Hover({
        language: 'shulang',
        value: `extern ${externDef}`,
      }, wordRange);
    }

    return null;
  }

  private findFunctionDef(lines: string[], name: string): string | null {
    const regex = new RegExp(
      `^\\s*(?:extern\\s+)?function\\s+${this.escapeRegex(name)}\\s*\\(([^)]*)\\)\\s*(?::\\s*([^{;]+?))?\\s*[\\{;]`
    );
    for (let i = 0; i < lines.length; i++) {
      const m = regex.exec(lines[i]);
      if (m) {
        const params = m[1].trim();
        const retType = (m[2] || '?').trim();
        const doc = this.findDocComment(lines, i);
        let result = `\`\`\`su\nfunction ${name}(${params}): ${retType}\n\`\`\``;
        if (doc) result = doc + '\n\n' + result;
        return result;
      }
    }
    return null;
  }

  private findExternDef(lines: string[], name: string): string | null {
    const regex = new RegExp(
      `^\\s*extern\\s+function\\s+${this.escapeRegex(name)}\\s*\\(([^)]*)\\)\\s*(?::\\s*([^;]+))?\\s*;`
    );
    for (let i = 0; i < lines.length; i++) {
      const m = regex.exec(lines[i]);
      if (m) {
        const params = m[1].trim();
        const retType = (m[2] || '?').trim();
        return `function ${name}(${params}): ${retType}`;
      }
    }
    return null;
  }

  private findStructDef(lines: string[], name: string): string | null {
    const regex = new RegExp(
      `^\\s*(?:allow\\(padding\\)\\s+)?struct\\s+${this.escapeRegex(name)}\\s*\\{`
    );
    for (let i = 0; i < lines.length; i++) {
      const m = regex.exec(lines[i]);
      if (m) {
        const fields = this.extractStructFields(lines, i);
        const doc = this.findDocComment(lines, i);
        const isPacked = lines[i].includes('allow(padding)');
        let result = `\`\`\`su\n${isPacked ? 'allow(padding) ' : ''}struct ${name} {\n${fields}\n}\n\`\`\``;
        if (doc) result = doc + '\n\n' + result;
        return result;
      }
    }
    return null;
  }

  private findEnumDef(lines: string[], name: string): string | null {
    const regex = new RegExp(`^\\s*enum\\s+${this.escapeRegex(name)}\\s*\\{`);
    for (let i = 0; i < lines.length; i++) {
      const m = regex.exec(lines[i]);
      if (m) {
        const variants = this.extractEnumVariants(lines, i);
        const doc = this.findDocComment(lines, i);
        let result = `\`\`\`su\nenum ${name} {\n${variants}\n}\n\`\`\``;
        if (doc) result = doc + '\n\n' + result;
        return result;
      }
    }
    return null;
  }

  private findVariableDef(lines: string[], name: string, cursorLine: number): string | null {
    // 向上查找最近的 let/const 声明
    const letRegex = new RegExp(`^\\s*let\\s+${this.escapeRegex(name)}\\s*:\\s*([^=;]+?)(?:\\s*=\\s*([^;]*?))?\\s*;`);
    const constRegex = new RegExp(`^\\s*const\\s+${this.escapeRegex(name)}\\s*:\\s*([^=;]+?)(?:\\s*=\\s*([^;]*?))?\\s*;`);
    const paramRegex = new RegExp(`function\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*\\(.*?\\b${this.escapeRegex(name)}\\s*:\\s*([^,)]+)`);

    for (let i = cursorLine; i >= 0; i--) {
      const lm = letRegex.exec(lines[i]);
      if (lm) {
        const type = lm[1].trim();
        const init = lm[2]?.trim();
        return init
          ? `\`\`\`su\nlet ${name}: ${type} = ${init}\n\`\`\``
          : `\`\`\`su\nlet ${name}: ${type}\n\`\`\``;
      }
      const cm = constRegex.exec(lines[i]);
      if (cm) {
        const type = cm[1].trim();
        const init = cm[2]?.trim();
        return init
          ? `\`\`\`su\nconst ${name}: ${type} = ${init}\n\`\`\``
          : `\`\`\`su\nconst ${name}: ${type}\n\`\`\``;
      }
    }

    // 检查函数参数
    for (let i = 0; i < lines.length; i++) {
      const pm = paramRegex.exec(lines[i]);
      if (pm) {
        return `\`\`\`su\n(param) ${name}: ${pm[1].trim()}\n\`\`\``;
      }
    }

    return null;
  }

  /** 提取 struct 前一行开始的文档注释 */
  private findDocComment(lines: string[], line: number): string | null {
    if (line <= 0) return null;
    const parts: string[] = [];
    let i = line - 1;
    while (i >= 0 && /^\s*(\*|\/\/)/.test(lines[i])) {
      let content = lines[i].replace(/^\s*\*+\s?/, '').replace(/^\s*\/\/\s?/, '').trim();
      if (content) {
        parts.unshift(content);
      }
      i--;
    }
    return parts.length > 0 ? parts.join('\n') : null;
  }

  private extractStructFields(lines: string[], startLine: number): string {
    const fieldRegex = /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*([^;]+);/;
    const fields: string[] = [];
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') depth++;
        else if (line[j] === '}') {
          depth--;
          if (depth === 0) return fields.join('\n');
        }
      }
      if (depth === 1) {
        const m = fieldRegex.exec(line);
        if (m) {
          fields.push(`  ${m[1]}: ${m[2].trim()}`);
        }
      }
    }
    return fields.join('\n');
  }

  private extractEnumVariants(lines: string[], startLine: number): string {
    const variantRegex = /^\s*([A-Z][A-Z0-9_]*)\s*,?/;
    const variants: string[] = [];
    let depth = 0;
    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') depth++;
        else if (line[j] === '}') {
          depth--;
          if (depth === 0) return variants.join(', ');
        }
      }
      if (depth === 1) {
        const m = variantRegex.exec(line);
        if (m) {
          variants.push(`  ${m[1]}`);
        }
      }
    }
    return variants.join(', ');
  }

  private escapeRegex(s: string): string {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
}
