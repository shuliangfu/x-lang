/**
 * Shux DocumentHighlightProvider — 同符号高亮
 *
 * 光标在标识符上时，高亮文档内所有相同标识符：
 * - 文本读 → Read
 * - 文本写（let/const/参数声明左侧）→ Write
 * - 其他 → Text
 *
 * 跳过注释/字符串内的匹配。本地正则实现，不依赖 LSP。
 */

import * as vscode from 'vscode';

/** 跳过注释/字符串，提取文档中所有标识符出现位置 */
function scanIdentifiers(text: string): Array<{ offset: number; len: number }> {
  const out: Array<{ offset: number; len: number }> = [];
  let i = 0;
  let lineComment = false;
  let blockDepth = 0;
  let inStr = false;
  let escaped = false;

  while (i < text.length) {
    const c = text[i];
    const n = text[i + 1];

    if (lineComment) {
      if (c === '\n') lineComment = false;
      i++;
      continue;
    }
    if (blockDepth > 0) {
      if (c === '*' && n === '/') {
        blockDepth--;
        i += 2;
        continue;
      }
      i++;
      continue;
    }
    if (inStr) {
      if (escaped) {
        escaped = false;
      } else if (c === '\\') {
        escaped = true;
      } else if (c === '"') {
        inStr = false;
      }
      i++;
      continue;
    }

    if (c === '/' && n === '/') {
      lineComment = true;
      i += 2;
      continue;
    }
    if (c === '/' && n === '*') {
      blockDepth = 1;
      i += 2;
      continue;
    }
    if (c === '"') {
      inStr = true;
      escaped = false;
      i++;
      continue;
    }

    // 标识符首字符
    if (/[a-zA-Z_]/.test(c)) {
      const start = i;
      while (i < text.length && /[a-zA-Z0-9_]/.test(text[i])) i++;
      out.push({ offset: start, len: i - start });
      continue;
    }

    i++;
  }

  return out;
}

/** 判断 offset 是否在 let/const 声明的左侧（Write 语义） */
function isWriteContext(text: string, offset: number, len: number): boolean {
  // 向前查找最近的 let/const 关键字（同行）
  const lineStart = text.lastIndexOf('\n', offset - 1) + 1;
  const before = text.substring(lineStart, offset).trimEnd();
  // let x / const NAME / let mut x
  if (/\b(?:let|const)\s+(?:mut\s+)?$/.test(before)) {
    return true;
  }
  // 赋值左侧：x = / x[...] = / x.field =
  const after = text.substring(offset + len, offset + len + 10);
  if (/^\s*=\s*[^=]/.test(after)) {
    return true;
  }
  return false;
}

export class ShuxDocumentHighlightProvider implements vscode.DocumentHighlightProvider {
  public provideDocumentHighlights(
    document: vscode.TextDocument,
    position: vscode.Position,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.DocumentHighlight[]> {
    const wordRange = document.getWordRangeAtPosition(position);
    if (!wordRange) {
      return [];
    }

    const word = document.getText(wordRange);
    if (!word || !/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(word)) {
      return [];
    }

    const text = document.getText();
    const idents = scanIdentifiers(text);
    const results: vscode.DocumentHighlight[] = [];

    for (const ident of idents) {
      if (ident.len !== word.length) continue;
      const candidate = text.substr(ident.offset, ident.len);
      if (candidate !== word) continue;

      const range = new vscode.Range(
        document.positionAt(ident.offset),
        document.positionAt(ident.offset + ident.len)
      );

      const kind = isWriteContext(text, ident.offset, ident.len)
        ? vscode.DocumentHighlightKind.Write
        : vscode.DocumentHighlightKind.Read;

      results.push(new vscode.DocumentHighlight(range, kind));
    }

    return results;
  }
}
