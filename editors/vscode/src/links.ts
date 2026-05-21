/**
 * Shulang DocumentLinkProvider — 将 `import` 模块路径转成可跳转文件 URI
 *
 * 解析语法：
 * - `import path;`
 * - `const name = import path;`
 * - `const { a, b } = import path;`
 *
 * 路径解析委托 importResolve.ts，与 shu 编译器 lib_roots + entry_dir 规则一致。
 * 无法解析时不生成链接，避免出现「链接目标已丢失」。
 */

import * as vscode from 'vscode';
import { resolveShulangImportUri } from './importResolve';

/**
 * 在 `text` 中判断「处理完下标 `[0,index)`」之后，`index` 处是否仍处于注释／字符串遮蔽。
 * @param fullText 通常为整文档内容
 */
function isMaskedBeforeIndex(fullText: string, index: number): boolean {
  let lineComment = false;
  let block = false;
  let blockAwaitStar = false;
  let inStr = false;
  let escS = false;
  let inChar = false;
  let escC = false;

  for (let i = 0; i < index && i < fullText.length; i++) {
    const ch = fullText.charAt(i);
    const nx = fullText.charAt(i + 1);

    if ((ch === '\n' || ch === '\r') && lineComment) {
      lineComment = false;
    }

    if (lineComment) {
      continue;
    }

    if (inChar) {
      if (escC) {
        escC = false;
      } else if (ch === '\\') {
        escC = true;
      } else if (ch === '\'') {
        inChar = false;
      }
      continue;
    }

    if (inStr) {
      if (escS) {
        escS = false;
      } else if (ch === '\\') {
        escS = true;
      } else if (ch === '"') {
        inStr = false;
      }
      continue;
    }

    if (block) {
      if (blockAwaitStar && ch === '/') {
        block = false;
        blockAwaitStar = false;
      } else if (ch === '*') {
        blockAwaitStar = true;
      } else {
        blockAwaitStar = false;
      }
      continue;
    }

    if (ch === '/' && nx === '/') {
      lineComment = true;
      i++;
      continue;
    }
    if (ch === '/' && nx === '*') {
      block = true;
      blockAwaitStar = false;
      i++;
      continue;
    }

    if (ch === '"') {
      inStr = true;
      escS = false;
      continue;
    }
    if (ch === '\'') {
      inChar = true;
      escC = false;
      continue;
    }
  }

  return lineComment || block || inStr || inChar;
}

/** 单行 import 匹配的区间（相对整文档偏移） */
type ImportOccurrence = {
  dotted: string;
  start: number;
  end: number;
};

/** 扫描文档中所有 import 路径出现位置 */
function gatherImportOccurrences(documentText: string): ImportOccurrence[] {
  const re = /\bimport\s+([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\s*;/g;

  const out: ImportOccurrence[] = [];
  let match: RegExpExecArray | null;
  while ((match = re.exec(documentText))) {
    const full = match[0];
    const dotted = match[1];
    const kwRel = full.indexOf('import');
    const kwAbs = match.index + kwRel;
    const startPath = match.index + full.indexOf(dotted);
    const endPathExclusive = startPath + dotted.length;

    if (isMaskedBeforeIndex(documentText, kwAbs)) {
      continue;
    }

    let maskedPath = false;
    for (let p = startPath; p < endPathExclusive; p++) {
      if (isMaskedBeforeIndex(documentText, p)) {
        maskedPath = true;
        break;
      }
    }
    if (maskedPath) {
      continue;
    }

    out.push({ dotted, start: startPath, end: endPathExclusive });
  }
  return out;
}

export class ShulangDocumentLinkProvider implements vscode.DocumentLinkProvider {
  /**
   * 枚举 import 路径并解析为可跳转 URI；解析失败的不生成链接。
   */
  public async provideDocumentLinks(
    document: vscode.TextDocument,
    _token: vscode.CancellationToken
  ): Promise<vscode.DocumentLink[]> {
    if (document.languageId !== 'su') {
      return [];
    }

    const wf = vscode.workspace.getWorkspaceFolder(document.uri);
    if (!wf) {
      return [];
    }

    const txt = document.getText();
    const occ = gatherImportOccurrences(txt);
    const links: vscode.DocumentLink[] = [];

    for (const item of occ) {
      const target = await resolveShulangImportUri(wf.uri, document.uri, item.dotted);
      if (!target) {
        continue;
      }

      const range = new vscode.Range(
        document.positionAt(item.start),
        document.positionAt(item.end)
      );
      links.push(new vscode.DocumentLink(range, target));
    }

    return links;
  }
}
