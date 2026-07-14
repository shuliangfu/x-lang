/**
 * Shux CodeLensProvider — 行内代码提示
 *
 * 在定义行上方插入 CodeLens：
 * - "▶ Run" — main 函数运行入口
 * - "fn" / "extern fn" — 可选（shux.features.codeLensFunctionLabels，默认关）
 * - struct / enum 字段与变体计数
 */

import * as vscode from 'vscode';
import { t } from './i18n';

/** 是否显示 function / extern function 上方的 fn 标签。 */
function showFunctionLabels(): boolean {
  return vscode.workspace
    .getConfiguration('shux')
    .get<boolean>('features.codeLensFunctionLabels', false);
}

/** 是否显示 ▶ Run 按钮（受 features.codeLensRunButton 控制） */
function showRunButton(): boolean {
  return vscode.workspace
    .getConfiguration('shux')
    .get<boolean>('features.codeLensRunButton', true);
}

/** 是否显示 struct/enum/trait/impl/type 信息（受 features.codeLensStructInfo 控制） */
function showStructInfo(): boolean {
  return vscode.workspace
    .getConfiguration('shux')
    .get<boolean>('features.codeLensStructInfo', true);
}

export class ShuxCodeLensProvider implements vscode.CodeLensProvider {
  private _onDidChangeCodeLenses = new vscode.EventEmitter<void>();
  public readonly onDidChangeCodeLenses = this._onDidChangeCodeLenses.event;

  public provideCodeLenses(
    document: vscode.TextDocument,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.CodeLens[]> {
    const lenses: vscode.CodeLens[] = [];
    const text = document.getText();
    const lines = text.split('\n');
    const fnLabels = showFunctionLabels();
    const runButton = showRunButton();
    const structInfo = showStructInfo();

    // 函数定义正则（捕获函数名）
    // 【Why】支持 export 前缀、extern "C"/"X" ABI 修饰；struct 支持 packed/soa/align(N)/allow(padding) 前缀
    const mainRegex = /^\s*(?:export\s+)?function\s+main\s*\(/;
    const funcRegex = /^\s*(?:export\s+)?function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/;
    const externRegex = /^\s*(?:export\s+)?extern\s+(?:"C"|"X"\s+)?function\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\([^)]*\)\s*(?::\s*\S+)?\s*;/;
    const structRegex = /^\s*(?:export\s+)?(?:allow\(padding\)\s+|packed\s+|soa\s+|align\(\d+\)\s+)*struct\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const enumRegex = /^\s*(?:export\s+)?enum\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const traitRegex = /^\s*(?:export\s+)?trait\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const implRegex = /^\s*impl\s+[a-zA-Z_][a-zA-Z0-9_]*\s+for\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
    const typeRegex = /^\s*(?:export\s+)?type\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=/;

    let funcCount = 0;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // main 函数 — "▶ Run"（受 shux.features.codeLensRunButton 控制）
      if (runButton && mainRegex.test(line)) {
        const range = new vscode.Range(i, 0, i, 0);
        const lens = new vscode.CodeLens(range, {
          title: '▶ Run',
          command: 'shux.runFile',
          tooltip: t('Run this file (shux <file>)'),
          arguments: [document.uri],
        });
        lenses.push(lens);
        funcCount++;
        continue;
      }

      // 普通函数定义（fn 标签默认关，见 shux.features.codeLensFunctionLabels）
      const fm = funcRegex.exec(line);
      if (fm && fnLabels) {
        const range = new vscode.Range(i, 0, i, 0);
        // 引用计数（本地估算：无法精确，提示用户）
        const lens = new vscode.CodeLens(range, {
          title: 'fn',
          command: '',
          tooltip: t('Function: {0}', fm[1]),
        });
        lenses.push(lens);
        funcCount++;
        continue;
      }

      // extern function（extern fn 标签默认关）
      if (externRegex.test(line) && fnLabels) {
        const range = new vscode.Range(i, 0, i, 0);
        const lens = new vscode.CodeLens(range, {
          title: 'extern fn',
          command: '',
          tooltip: t('Extern function declaration'),
        });
        lenses.push(lens);
        continue;
      }

      // struct（受 shux.features.codeLensStructInfo 控制）
      const sm = structRegex.exec(line);
      if (structInfo && sm) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractStructFieldCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: `${len} fields`,
          command: '',
          tooltip: t('Struct: {0} — {1} fields', sm[1], len),
        });
        lenses.push(lens);
        continue;
      }

      // enum（受 shux.features.codeLensStructInfo 控制）
      const em = enumRegex.exec(line);
      if (structInfo && em) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractEnumVariantCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: t('{0} variants', len),
          command: '',
          tooltip: t('Enum: {0} — {1} variants', em[1], len),
        });
        lenses.push(lens);
        continue;
      }

      // trait（受 shux.features.codeLensStructInfo 控制）
      const tm = traitRegex.exec(line);
      if (structInfo && tm) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractTraitMethodCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: t('{0} methods', len),
          command: '',
          tooltip: t('trait: {0} — {1} method declarations', tm[1], len),
        });
        lenses.push(lens);
        continue;
      }

      // impl（受 shux.features.codeLensStructInfo 控制）
      const im = implRegex.exec(line);
      if (structInfo && im) {
        const range = new vscode.Range(i, 0, i, 0);
        const len = this.extractTraitMethodCount(lines, i);
        const lens = new vscode.CodeLens(range, {
          title: t('{0} methods', len),
          command: '',
          tooltip: t('impl for {0} — {1} method implementations', im[1], len),
        });
        lenses.push(lens);
        continue;
      }

      // type alias（受 shux.features.codeLensStructInfo 控制）
      const tp = typeRegex.exec(line);
      if (structInfo && tp) {
        const range = new vscode.Range(i, 0, i, 0);
        const lens = new vscode.CodeLens(range, {
          title: t('type'),
          command: '',
          tooltip: t('Type alias: {0}', tp[1]),
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

  /** 统计 enum 变体数（支持 UPPER_SNAKE 与 PascalCase） */
  private extractEnumVariantCount(lines: string[], startLine: number): number {
    const variantRegex = /^\s*[A-Z][a-zA-Z0-9_]*\s*,?/;
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

  /** 统计 trait/impl 内方法数（function 定义行） */
  private extractTraitMethodCount(lines: string[], startLine: number): number {
    const methodRegex = /^\s*(?:export\s+)?function\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/;
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
      if (depth === 1 && methodRegex.test(line)) count++;
    }
    return count;
  }

  /** 刷新 CodeLens */
  public refresh(): void {
    this._onDidChangeCodeLenses.fire();
  }
}
