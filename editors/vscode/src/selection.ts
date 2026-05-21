/**
 * Shulang Smart SelectionRange — 语义化逐级放大选区（Ctrl+Shift+Right 链路）。
 *
 * 层次（子 → 父，通过 `SelectionRange.parent` 串起）：
 * 1. 标识符：`TextDocument#getWordRangeAtPosition`（与 language-configuration 的 wordPattern 对齐，含整块 PascalCase 标识）。
 *    数字常量：若没有词范围且落在数字字面量上，则扩展连续数字与前缀十六进制前缀。
 * 2. 整行：`trim()` 首尾空白对应的列跨度。
 * 3. `{}`：自左向右扫描括号栈，跳过字符串 / 注释，取**包含光标的最小**平衡花括号区间。
 * 4. 全文档：`Range(start, end)`。
 *
 * extension.activate() 注册示例：
 * ```
 * languages.registerSelectionRangeProvider(
 *   { scheme: 'file', language: 'su' },
 *   createShulangSelectionRangeProvider()
 * );
 * ```
 */

import {
  CancellationToken,
  Position,
  ProviderResult,
  Range,
  SelectionRange,
  SelectionRangeProvider,
  TextDocument,
} from 'vscode';

/**
 * Smart Selection Provider：为 Smart Select 命令提供递进式 `SelectionRange` 链。
 */
export class ShulangSelectionRangeProvider implements SelectionRangeProvider {
  /**
   * @param document 打开的 `.su` 文档。
   * @param positions 需要生成链的根位置数组（通常为当前光标）。
   * @returns 与 positions 对齐的每条选区链路；若被取消则返回 `undefined`。
   */
  public provideSelectionRanges(
    document: TextDocument,
    positions: Position[],
    _token: CancellationToken
  ): ProviderResult<SelectionRange[]> {
    void _token;
    return positions.map((p) => this.buildChain(document, p));
  }

  /** 自下而上构造 parent 链直至整篇文档。 */
  private buildChain(document: TextDocument, pos: Position): SelectionRange {
    const levels: Range[] = [];

    const wordLike = expandWordOrNumber(document, pos);
    /** 第一层：若能识别词范围或字面量扩展，则从该范围起步；否则稍后由整行占位。 */
    if (wordLike) {
      levels.push(wordLike);
    }

    /** 第二层：跳过与词范围完全相同的行裁剪，以避免重复档位。 */
    const lineLvl = trimmedLineRange(document, pos.line);
    if (
      !(wordLike &&
        wordLike.start.line === lineLvl.start.line &&
        wordLike.end.line === lineLvl.end.line &&
        wordLike.start.character === lineLvl.start.character &&
        wordLike.end.character === lineLvl.end.character)
    ) {
      levels.push(lineLvl);
    }

    /** 第三层：`{}` 内层括号块（若在块外则跳过该层）。 */
    const bracket = enclosingBraceRange(document, pos);
    if (bracket) {
      dedupePush(levels, bracket);
    }

    /** 最外层文档范围（含文末换行语义由 VSCode 换算 position） */
    const fullSrc = document.getText();
    dedupePush(
      levels,
      new Range(
        document.positionAt(0),
        document.positionAt(fullSrc.length)
      )
    );

    /** 自上而下（outer→inner during construction）挂载 parent 指针 */
    let chain: SelectionRange | undefined = undefined;
    /** `levels` 由小到大：必须先处理最外层大块，再往内层包 word */
    for (let i = levels.length - 1; i >= 0; i--) {
      const r = levels[i];
      chain = chain ? new SelectionRange(r, chain) : new SelectionRange(r);
    }
    /** 至少存在整文档档位，`chain` 非空 */
    return chain!;
  }
}

/**
 * Provider 工厂函数，便于 activate() 单行注册：
 * ```
 * languages.registerSelectionRangeProvider({ language: 'su' }, createShulangSelectionRangeProvider());
 * ```
 *
 * @returns Shulang 选区递进实现实例。
 */
export function createShulangSelectionRangeProvider(): SelectionRangeProvider {
  return new ShulangSelectionRangeProvider();
}

/**
 * 在行尾去空白后并入范围数组，跳过与上一级完全相同的档位。
 *
 * @param levels 递进范围栈（自内向外）。
 * @param r 欲追加的范围。
 */
function dedupePush(levels: Range[], r: Range): void {
  const last = levels[levels.length - 1];
  if (
    last &&
    last.start.isEqual(r.start) &&
    last.end.isEqual(r.end)
  ) {
    return;
  }
  levels.push(r);
}

/**
 * @param doc 文档句柄。
 * @param lineIdx 逻辑行索引。
 * @returns 去掉首尾空格后的单行 `Range`，若该行全空则退化到该行首零宽占位。
 */
function trimmedLineRange(doc: TextDocument, lineIdx: number): Range {
  const lineCount = Math.max(doc.lineCount, 1);
  const bounded = Math.min(Math.max(lineIdx, 0), lineCount - 1);
  const rawLine = doc.lineAt(bounded).text;
  const leading = rawLine.match(/^\s*/)?.[0].length ?? 0;
  let trailingWs = rawLine.match(/\s*$/)?.[0].length ?? 0;
  /** trim 后出现空行时使用零宽度 Range 占位，避免出现负宽度 */
  let endChar = rawLine.length - trailingWs;
  if (leading >= endChar) {
    trailingWs = 0;
    endChar = leading;
  }
  return new Range(bounded, leading, bounded, endChar);
}

/**
 * @param doc 文档。
 * @param pos 光标位置。
 * @returns 词范围的超集：`getWordRangeAtPosition`；
 *          若为数字常量则扩展到连续数字及可选前缀（`0x`/`0o`）。
 */
function expandWordOrNumber(doc: TextDocument, pos: Position): Range | undefined {
  const word = doc.getWordRangeAtPosition(pos);
  if (word && !word.isEmpty) return word;

  const lineText = doc.lineAt(pos.line).text;
  if (!lineText) return undefined;

  /** 列限制在 `[0,length]`，`length` 允许落在行尾的虚拟插入光标 */
  let col = Math.min(Math.max(pos.character, 0), lineText.length);
  /** 光标若落在 `\n` 之后（VSCode API 中行末 character 常为 `length`），向左靠拢 */
  if (col >= lineText.length && lineText.length > 0) {
    col = lineText.length - 1;
  }

  /** 当前列不是数字本体时尝试左右邻居吸附（处理边界点击） */
  let idx =
    lineText.length > 0 ? Math.min(Math.max(col, 0), lineText.length - 1) : 0;

  /** 若非数字字面量本体则尝试左右查找 */
  if (!/[0-9_]/.test(lineText[idx])) {
    const leftNeighbor = idx > 0 ? lineText[idx - 1] : '';
    const rightNeighbor = idx + 1 < lineText.length ? lineText[idx + 1] : '';
    if (/[0-9_]/.test(leftNeighbor)) {
      idx = idx > 0 ? idx - 1 : 0;
    } else if (/[0-9_]/.test(rightNeighbor)) {
      idx = idx + 1;
    } else {
      return undefined;
    }
  }

  /** 扩展到连续 digit/underscore（简单数字字面量子集） */
  let startCol = idx;
  while (startCol > 0 && /[0-9_]/.test(lineText[startCol - 1])) {
    startCol--;
  }

  /** `0x` / `0b` / `0o` 前缀（粗略覆盖常见固定前缀字面量写法） */
  if (startCol >= 2) {
    const prefix = lineText.slice(startCol - 2, startCol).toLowerCase();
    if (prefix === '0x' || prefix === '0b' || prefix === '0o') {
      startCol -= 2;
    }
  }

  /** `Range` end 为上开区间 */
  let endExclusive = idx;
  while (endExclusive < lineText.length && /[0-9_]/.test(lineText[endExclusive])) {
    endExclusive++;
  }

  /** 前缀被吞后与主体不连续时兜底：确保至少选一个数字跨度 */
  if (endExclusive <= startCol) {
    return undefined;
  }
  return new Range(pos.line, startCol, pos.line, endExclusive);
}

/**
 * 扫描整篇文档：`{`/`}`、字符串、行注释 / 块注释。
 * @returns 包住 `pos` 的最小 `{}` Range；光标位于边界外则 `undefined`。
 */
function enclosingBraceRange(doc: TextDocument, pos: Position): Range | undefined {
  const src = doc.getText();
  const cursor = doc.offsetAt(pos);

  interface Frame {
    open: number;
  }

  /** 花括号栈：记录 `'{'` offset */
  const stack: Frame[] = [];
  /** 收集所有闭合 `{}` Span：半开 `[start, endExclusive)` relative to FULL text offsets */
  const spans: Array<{ begin: number; endExclusive: number }> = [];

  let lineComment = false;
  let blockDepth = 0;
  let inString = false;
  let escaped = false;

  /** 从左向右单次扫描即可完成栈配对 */
  for (let i = 0; i < src.length; i++) {
    const c = src[i];
    const n = src[i + 1];

    if (lineComment) {
      if (c === '\n') lineComment = false;
      continue;
    }

    if (blockDepth > 0) {
      if (c === '/' && n === '*') {
        blockDepth++;
        i++;
        continue;
      }
      if (c === '*' && n === '/') {
        blockDepth--;
        i++;
        continue;
      }
      continue;
    }

    if (inString) {
      if (!escaped && c === '\\') {
        escaped = true;
        continue;
      }
      if (!escaped && c === '"') {
        inString = false;
      }
      escaped = false;
      continue;
    }

    if (c === '"') {
      inString = true;
      escaped = false;
      continue;
    }

    if (c === '/' && n === '/') {
      lineComment = true;
      i++;
      continue;
    }
    if (c === '/' && n === '*') {
      blockDepth = 1;
      i++;
      continue;
    }

    if (c === '{') {
      stack.push({ open: i });
      continue;
    }
    if (c === '}') {
      const top = stack.pop();
      if (!top) {
        continue;
      }
      spans.push({
        /** 含两侧花括号偏移 */
        begin: top.open,
        endExclusive: i + 1,
      });
    }
  }

  /** 光标必须严格位于花括号对内（不包含边界）以更贴近语义“体内”；
   * 若落在 `{`/`}` token 亦可视为块内相邻 — 调整为左闭右开区间判断微调： */
  let bestSpan: { begin: number; endExclusive: number } | undefined;
  let bestLen = Infinity;
  for (const span of spans) {
    if (cursor >= span.begin && cursor < span.endExclusive) {
      const len = span.endExclusive - span.begin;
      if (len < bestLen) {
        bestLen = len;
        bestSpan = span;
      }
    }
  }

  if (!bestSpan) return undefined;

  return new Range(
    doc.positionAt(bestSpan.begin),
    doc.positionAt(bestSpan.endExclusive)
  );
}
