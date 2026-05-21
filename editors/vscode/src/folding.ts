/**
 * Shulang FoldingRangeProvider — 语义代码折叠
 *
 * 支持折叠：
 * - 函数体（function ... { ... }）
 * - 结构体/枚举/trait 体（struct/enum/trait ... { ... }）
 * - 块注释（/* ... *\/）
 * - 通用 {} 块
 * - defer 块
 */

import * as vscode from 'vscode';

export class ShulangFoldingRangeProvider implements vscode.FoldingRangeProvider {
  public provideFoldingRanges(
    document: vscode.TextDocument,
    _context: vscode.FoldingContext,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.FoldingRange[]> {
    const ranges: vscode.FoldingRange[] = [];
    const text = document.getText();
    const lines = text.split('\n');

    // 跟踪 { } 对
    const braceStack: { line: number; kind: string }[] = [];

    // 跟踪 /* */ 注释
    let inBlockComment = false;
    let commentStartLine = 0;

    const blockStarters = /\b(function|struct|enum|trait|if|while|for|loop|match|defer)\b/;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // 块注释
      const commentStartIdx = line.indexOf('/*');
      const commentEndIdx = line.indexOf('*/');

      if (!inBlockComment && commentStartIdx >= 0) {
        if (commentEndIdx === -1 || commentEndIdx < commentStartIdx) {
          // 多行注释开始
          inBlockComment = true;
          commentStartLine = i;
        }
      } else if (inBlockComment && commentEndIdx >= 0) {
        // 多行注释结束
        if (i > commentStartLine) {
          ranges.push(new vscode.FoldingRange(commentStartLine, i, vscode.FoldingRangeKind.Comment));
        }
        inBlockComment = false;
      }

      // { } 匹配
      let lineKind = '';
      for (let j = 0; j < line.length; j++) {
        const ch = line[j];
        if (ch === '{') {
          // 检查这一行是否有区块关键字
          const pre = line.substring(0, j);
          const km = blockStarters.exec(pre);
          const kind = km ? km[1] : 'block';
          braceStack.push({ line: i, kind });
          lineKind = kind;
        } else if (ch === '}') {
          const open = braceStack.pop();
          if (open && open.line < i) {
            // 根据关键字类型设置折叠 kind
            let foldKind: vscode.FoldingRangeKind | undefined;
            if (open.kind === 'function') {
              // no special kind — region is fine
            }
            ranges.push(new vscode.FoldingRange(open.line, i, foldKind));
          }
        }
      }
    }

    // 收起未闭合的块注释
    if (inBlockComment && commentStartLine < lines.length - 1) {
      ranges.push(new vscode.FoldingRange(commentStartLine, lines.length - 1, vscode.FoldingRangeKind.Comment));
    }

    return ranges;
  }
}
