/**
 * Shux OnTypeFormattingProvider — `.sx` 编辑时轻量实时缩进
 *
 * 在语言配置 onEnterRules 之外用 TextEdit 细调三块场景：
 * 1) `{` 行后回车 → 新行比上行多一级缩进；
 * 2) 录入 `}` → 将本行前缀缩进与匹配 `{` 所在行对齐；
 * 3) match 分支行（末尾 `=>` / `->`）后 `: ` 触发或回车続行时的缩进修整（与用户约定一致）。
 *
 * tabSize / insertSpaces 取自 FormattingOptions，与格式化配置一致。
 */

import * as vscode from 'vscode';

/** 单行尾部是否位于块注释／字符串／字符字面量之外的 `{`（避免把 `"{"` 等误判为块起始） */
function lineEndsWithBlockOpeningBrace(textRaw: string): boolean {
  /** 剔除行尾 `//` 以后再判断 `{`，避免 `{ //` 被误判为非块头 */
  const t = stripTrailingComments(textRaw).replace(/\s+$/, '');
  let inLineComment = false;
  let inBlock = false;
  let blockStar = false;
  let inStr = false;
  let escape = false;
  let braceDepth = 0;
  /** 最近一次在字符串块外记录的 `{`（含嵌套）深度，用于判断行末是否多了一个“未配对”的最外层 `{` */
  let lastOpenBraceDepth = -1;

  for (let i = 0; i < t.length; i++) {
    const ch = t.charAt(i);
    const nx = i + 1 < t.length ? t.charAt(i + 1) : '';

    /** 行内 `//` 之后不再解析结构（单行扫描） */
    if ((ch === '\n' || ch === '\r') && inLineComment) {
      inLineComment = false;
    }

    if (inLineComment) {
      continue;
    }
    if (!inStr && !inBlock && ch === '/' && nx === '/') {
      inLineComment = true;
      i++;
      continue;
    }

    if (inStr) {
      if (escape) {
        escape = false;
      } else if (ch === '\\') {
        escape = true;
      } else if (ch === '"') {
        inStr = false;
      }
      continue;
    }

    if (inBlock) {
      if (blockStar && ch === '/') {
        inBlock = false;
        blockStar = false;
      } else if (ch === '*') {
        blockStar = true;
      } else {
        blockStar = false;
      }
      continue;
    }

    if (ch === '/' && nx === '*') {
      inBlock = true;
      blockStar = false;
      i++;
      continue;
    }

    if (ch === '"') {
      inStr = true;
      escape = false;
      continue;
    }

    if (ch === '{') {
      braceDepth += 1;
      lastOpenBraceDepth = braceDepth;
    } else if (ch === '}') {
      braceDepth = Math.max(0, braceDepth - 1);
    }
  }

  const trimmedTrail = t.replace(/[\t ]+$/, '');
  if (!trimmedTrail.endsWith('{')) {
    return false;
  }

  /** 末尾 `{`：若括号深度在行末归零前曾增加则视为真实块头 */
  return lastOpenBraceDepth > 0 || braceDepth > 0;
}

/** match / 尾随返回类型臂行：行末箭头（语言配置 indentNextLinePattern 同源） */
function lineEndsWithArmArrow(textRaw: string): boolean {
  const s = stripTrailingComments(textRaw).replace(/[\t ]+$/, '');
  return /=>\s*$/.test(s) || /->\s*$/.test(s);
}

/** 去掉末尾 `//` 行注释，便于在行尾判断 `{`/`=>` */
function stripTrailingComments(line: string): string {
  let inStr = false;
  let esc = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line.charAt(i);
    if (inStr) {
      if (esc) esc = false;
      else if (ch === '\\') esc = true;
      else if (ch === '"') inStr = false;
      continue;
    }
    if (ch === '"') {
      inStr = true;
      esc = false;
      continue;
    }
    if (ch === '/' && line.charAt(i + 1) === '/') {
      return line.slice(0, i);
    }
  }
  return line;
}

/** 返回行首连续的 tab／space **字符计数**（与 Range.character 对齐，`.sx` 源以 ASCII 为主）。 */
function leadingWhitespaceCharCount(line: string): number {
  let i = 0;
  for (; i < line.length; i++) {
    const c = line.charAt(i);
    if (c !== ' ' && c !== '\t') break;
  }
  return i;
}

/** 由列偏移生成 insertSpaces 前缀 */
function indentPrefixFromColumns(col: number, options: vscode.FormattingOptions): string {
  if (!options.insertSpaces) {
    const tabs = Math.floor(col / options.tabSize);
    return '\t'.repeat(tabs);
  }
  return ' '.repeat(col);
}

/**
 * 在行首长度为 `prefixLen` 的空白区间内，把前缀替换为 content（列语义由 content 表示）。
 *
 * content 必须为纯空白（tab/spaces），由 indentPrefixFromColumns 生成。
 */
function replaceLeadingWsEdit(
  lineIndex: number,
  lineText: string,
  prefixColsEndIndex: number,
  content: string
): vscode.TextEdit {
  return vscode.TextEdit.replace(
    new vscode.Range(lineIndex, 0, lineIndex, prefixColsEndIndex),
    content
  );
}

/** 跳过块注释／字符串，`{}` 栈匹配，返回 offset 对应的 `}` 所匹配的 `{` 下标（含该行内嵌套）。 */
function findMatchingOpenBrace(doc: vscode.TextDocument, closingBraceOffset: number): number | undefined {
  const text = doc.getText();
  if (closingBraceOffset < 0 || closingBraceOffset >= text.length || text.charAt(closingBraceOffset) !== '}') {
    return undefined;
  }

  let inLineComment = false;
  let inBlock = false;
  let blockStar = false;
  let inStr = false;
  let escapeStr = false;
  const stack: number[] = [];

  for (let i = 0; i <= closingBraceOffset; i++) {
    const ch = text.charAt(i);
    const nx = i + 1 < text.length ? text.charAt(i + 1) : '';

    /** 块注释结束之后换行复位行注释 */
    if ((ch === '\n' || ch === '\r') && inLineComment) {
      inLineComment = false;
    }

    if (inLineComment) {
      continue;
    }

    if (!inStr && !inBlock && ch === '/' && nx === '/') {
      inLineComment = true;
      i++;
      continue;
    }

    if (inStr) {
      if (escapeStr) escapeStr = false;
      else if (ch === '\\') escapeStr = true;
      else if (ch === '"') inStr = false;
      continue;
    }

    if (inBlock) {
      if (blockStar && ch === '/') {
        inBlock = false;
        blockStar = false;
      } else if (ch === '*') blockStar = true;
      else blockStar = false;
      continue;
    }

    /** 已进入块注释则不处理字面量前缀 */
    if (ch === '/' && nx === '*') {
      inBlock = true;
      blockStar = false;
      i++;
      continue;
    }

    if (ch === '"') {
      inStr = true;
      escapeStr = false;
      continue;
    }

    if (!inStr && !inBlock && ch === '\'') {
      /** 跳过 `'` 字符字面（若存在形如 `'` 的占位则吞到下一撇号）；避免破坏后续 `{`/`}` 语义 */
      const j = text.indexOf('\'', i + 1);
      if (j === -1) break;
      i = j;
      continue;
    }

    /** 预处理阶段：Rust 风格 `r#"..."` 在此语言中少见，暂不处理以防误伤极小概率字符串 */

    if (ch === '{') {
      stack.push(i);
    } else if (ch === '}') {
      if (stack.length === 0) return undefined;
      const open = stack.pop();
      if (i === closingBraceOffset && stack.length >= 0) {
        return open;
      }
    }
  }
  return undefined;
}

export class ShuxOnTypeFormattingProvider implements vscode.OnTypeFormattingEditProvider {
  /**
   * 根据刚键入字符（与 VS Code onTypeFormatting 钩子）推断缩进补丁。
   */
  public provideOnTypeFormattingEdits(
    document: vscode.TextDocument,
    position: vscode.Position,
    ch: string,
    options: vscode.FormattingOptions,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.TextEdit[]> {
    if (document.languageId !== 'sx') {
      return [];
    }

    if (ch === '\n') {
      return this.onNewLine(document, position, options);
    }
    if (ch === '}') {
      return this.onCloseBrace(document, position, options);
    }
    if (ch === ':') {
      return this.onColon(document, position, options);
    }
    /** `{` 本身不补丁；配对由随后 `\n` 处理（需求：必须先打 `{` 再回车） */
    return [];
  }

  /**
   * `\n`：上一行若为 `{` 结束或箭头臂结尾，则将当前行前导空白扩一级。
   */
  private onNewLine(
    document: vscode.TextDocument,
    position: vscode.Position,
    options: vscode.FormattingOptions
  ): vscode.TextEdit[] {
    if (position.line < 1) {
      return [];
    }
    const prevText = document.lineAt(position.line - 1).text;
    let baseCols: number | undefined;

    if (lineEndsWithBlockOpeningBrace(prevText)) {
      baseCols = this.lineIndentColumns(prevText, options);
      baseCols += options.tabSize;
    } else if (lineEndsWithArmArrow(prevText)) {
      baseCols = this.lineIndentColumns(prevText, options);
      baseCols += options.tabSize;
    }

    if (baseCols === undefined) {
      return [];
    }

    const cur = document.lineAt(position.line).text;
    const prefixEnd = leadingWhitespaceCharCount(cur);

    /** 光标新行若非纯空白前缀则尽量不覆盖正文 */
    const rest = cur.slice(prefixEnd).trimEnd();
    if (rest.length > 0) {
      return [];
    }

    return [replaceLeadingWsEdit(position.line, cur, prefixEnd, indentPrefixFromColumns(baseCols, options))];
  }

  /**
   * `}`：把整个当前行的前导空白设置为与匹配的 `{` 行一致。
   */
  private onCloseBrace(
    document: vscode.TextDocument,
    position: vscode.Position,
    options: vscode.FormattingOptions
  ): vscode.TextEdit[] {
    const braceCol = Math.max(0, position.character - 1);
    /** 光标在 `}` 之后，校验当前行索引 `braceCol` 处确为右花括号 */
    const line = document.lineAt(position.line).text;
    if (line.charAt(braceCol) !== '}') {
      return [];
    }

    const closeOff = document.offsetAt(new vscode.Position(position.line, braceCol));
    const openOff = findMatchingOpenBrace(document, closeOff);
    if (openOff === undefined) {
      return [];
    }

    const openPos = document.positionAt(openOff);
    const openLineText = document.lineAt(openPos.line).text;

    /** 对齐：与 `{` 行首一致的列数 */
    const targetCols = this.lineIndentColumns(openLineText, options);
    const curPrefixEnd = leadingWhitespaceCharCount(line);

    /** 允许 `}`, `};`, `},` —— 单行闭块常见尾随（避免误判多语句拼接行） */
    const afterBrace = line.slice(braceCol + 1);
    if (!/^[\t ]*[,;]?[\t ]*$/.test(afterBrace)) {
      return [];
    }

    return [replaceLeadingWsEdit(position.line, line, curPrefixEnd, indentPrefixFromColumns(targetCols, options))];
  }

  /**
   * `:`：`:` 常为换行接续；若紧邻上一行箭头臂末尾，则将本行前缀比上一行多一级。
   */
  private onColon(
    document: vscode.TextDocument,
    position: vscode.Position,
    options: vscode.FormattingOptions
  ): vscode.TextEdit[] {
    if (position.line < 1) {
      return [];
    }

    /** 光标紧挨 `:` 之后 */
    const lineIdx = position.line;
    const col = Math.max(0, position.character - 1);
    const lineText = document.lineAt(lineIdx).text;
    if (lineText.charAt(col) !== ':') {
      return [];
    }

    const prevRaw = document.lineAt(lineIdx - 1).text;

    /** 仅在上一行确认为臂模式时起作用 */
    if (!lineEndsWithArmArrow(prevRaw)) {
      return [];
    }

    /** 典型场景：新的一行 `: payload`——行首前缀应比箭头行多一级缩进列 */
    const prefixEnd = leadingWhitespaceCharCount(lineText);
    const before = lineText.slice(0, col);
    /** `:` 前必须只有前缀空白 */
    const beforeWoWs = before.replace(/[\t ]+$/g, '');
    if (!/^\s*$/.test(beforeWoWs)) {
      /** 若非行首 `:`, 多半是类型注解 `: i32`，不动 */
      return [];
    }

    const baseCols = this.lineIndentColumns(prevRaw, options) + options.tabSize;
    return [replaceLeadingWsEdit(lineIdx, lineText, prefixEnd, indentPrefixFromColumns(baseCols, options))];
  }

  /**
   * 度量整行前缀空白对应的“列偏移”（空格计 1，tab 对齐到下一个 tabStop）。
   */
  private lineIndentColumns(lineText: string, options: vscode.FormattingOptions): number {
    let col = 0;
    let i = 0;
    for (; i < lineText.length; i++) {
      const c = lineText.charAt(i);
      if (c === ' ') col += 1;
      else if (c === '\t') col = col + options.tabSize - (col % options.tabSize);
      else break;
    }
    return col;
  }
}
