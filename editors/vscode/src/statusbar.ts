/**
 * Shux 状态栏 — 在右下角显示「Shux」及对当前 `.x` 源的符号粗略统计。
 *
 * extension.activate() 示例：
 * ```
 * registerShuxStatusBar(context);
 * refreshShuxStatusBar(vscode.window.activeTextEditor);
 * context.subscriptions.push(
 *   vscode.window.onDidChangeActiveTextEditor((e) => refreshShuxStatusBar(e))
 * );
 * context.subscriptions.push(
 *   vscode.workspace.onDidChangeTextDocument((e) => {
 *     if (e.document.languageId === 'x') {
 *       refreshShuxStatusBar(vscode.window.activeTextEditor);
 *     }
 *   })
 * );
 * ```
 */

import {
  ExtensionContext,
  StatusBarAlignment,
  StatusBarItem,
  TextEditor,
  window,
} from 'vscode';

/** VSCode StatusBar：扩展侧持有单例，防止重复条目。 */
let shuxStatusItem: StatusBarItem | undefined;

/** 与普通函数声明行匹配的正则（与 symbols.ts 行首抽取策略一致）。 */
const FUNC_HEAD = /^\s*function\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/;
/** 可选 `allow(padding)` 前缀的结构体起始行（与大纲逻辑对齐）。 */
const STRUCT_HEAD =
  /^\s*(?:allow\(padding\)\s+)?struct\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;
/** 枚举起始行。 */
const ENUM_HEAD = /^\s*enum\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;

/**
 * 将源码中的注释替换为等价长度的空白字符，保留换行，
 * 使基于 `^` 的行首正则不会匹配到注释中的关键字。
 *
 * @param source 文档全文。
 * @returns 去掉注释后的文本（仅用于正则统计，不改变换行个数）。
 */
function stripXCommentsPreserveNewlines(source: string): string {
  /** 输出缓冲区，与原串等长，逐字节填充。 */
  const outChars: string[] = new Array(source.length);
  /** 是否在 `//` 行注释尾部。 */
  let lineComment = false;
  /** 块注释 `/* … *\/` 嵌套深度。 */
  let blockDepth = 0;
  /** 是否在双引号字符串中（支持 `\\\"`）。 */
  let inString = false;
  /** 上一字符是否为反斜杠（字符串转义）。 */
  let escaped = false;

  for (let i = 0; i < source.length; i++) {
    const c = source[i];
    const n = source[i + 1];

    if (lineComment) {
      outChars[i] = c === '\n' ? '\n' : ' ';
      if (c === '\n') lineComment = false;
      continue;
    }
    if (blockDepth > 0) {
      if (c === '/' && n === '*') {
        outChars[i] = ' ';
        outChars[i + 1] = ' ';
        blockDepth++;
        i++;
        continue;
      }
      if (c === '*' && n === '/') {
        outChars[i] = ' ';
        outChars[i + 1] = ' ';
        blockDepth--;
        i++;
        continue;
      }
      outChars[i] = c === '\n' ? '\n' : ' ';
      continue;
    }

    if (inString) {
      outChars[i] = c;
      if (!escaped && c === '\\') {
        escaped = true;
      } else if (!escaped && c === '"') {
        inString = false;
      } else if (escaped) {
        escaped = false;
      }
      continue;
    }

    // 字符串开始
    if (c === '"') {
      inString = true;
      escaped = false;
      outChars[i] = '"';
      continue;
    }

    // 行注释入口
    if (c === '/' && n === '/') {
      outChars[i] = ' ';
      outChars[i + 1] = ' ';
      lineComment = true;
      i++;
      continue;
    }
    // 块注释入口
    if (c === '/' && n === '*') {
      outChars[i] = ' ';
      outChars[i + 1] = ' ';
      blockDepth = 1;
      i++;
      continue;
    }

    outChars[i] = c;
  }

  return outChars.join('');
}

/**
 * 对清洗后的源码逐行计数：function / struct / enum。
 *
 * @param sanitized 已通过 `stripXCommentsPreserveNewlines` 的文本。
 */
function countXSymbolsPerLinePrefix(sanitized: string): {
  funcs: number;
  structs: number;
  enums: number;
} {
  let funcs = 0;
  let structs = 0;
  let enums = 0;
  const lines = sanitized.split(/\r?\n/);
  for (const line of lines) {
    if (FUNC_HEAD.test(line)) funcs++;
    else if (STRUCT_HEAD.test(line)) structs++;
    else if (ENUM_HEAD.test(line)) enums++;
  }
  return { funcs, structs, enums };
}

/**
 * 创建右下角 Shux 状态项并完成首次刷新（若当前有活动编辑器）。
 *
 * StatusBar：`alignment = Right`、`priority = 100`；
 * `text = ' Shux'`（按需求保留前导空格）；
 * `tooltip = 'Shux (.x)'`；
 * `show()` 后即加入 `context.subscriptions`。
 *
 * @param context VSCode 激活上下文。
 */
export function registerShuxStatusBar(context: ExtensionContext): void {
  if (shuxStatusItem) {
    /** 已在开发热重载下多次激活时重用同一项，防止泄漏。 */
    shuxStatusItem.dispose();
  }
  /** 右下角状态条目 */
  const item = window.createStatusBarItem(StatusBarAlignment.Right, 100);
  shuxStatusItem = item;
  item.name = 'Shux';
  /** 初始化展示（占位含前导空格，符合需求字面） */
  item.text = ' Shux';
  item.tooltip = 'Shux (.x)';
  item.show();

  /** 扩展卸载时销毁状态条目 */
  context.subscriptions.push(item);

  /** 注册完成后立即对齐当前编辑器 */
  refreshShuxStatusBar(window.activeTextEditor);
}

/**
 * 在活动编辑器或其文档发生变化时刷新状态栏计数。
 *
 * - 若为 `.x`：统计 `function`/`struct`/`enum`（排除注释）。
 * - 否则回退占位文本：` Shux`，tooltip：`Shux (.x)`。
 *
 * @param editor 当前活动编辑器，可为 undefined。
 */
export function refreshShuxStatusBar(editor: TextEditor | undefined): void {
  const item = shuxStatusItem;
  if (!item) {
    return;
  }

  /** 仅在 Shux 语言 ID 上做统计（与 contributes 对齐） */
  if (!editor || editor.document.languageId !== 'x') {
    /** 需求：非 .x 编辑器回退占位 */
    item.text = ' Shux';
    item.tooltip = 'Shux (.x)';
    return;
  }

  const sanitized = stripXCommentsPreserveNewlines(editor.document.getText());
  const { funcs, structs, enums } = countXSymbolsPerLinePrefix(sanitized);

  /**
   * `$(symbol-namespace)`：使用内置图标前缀，前缀保留一个空格以保持版式，
   * 后面展示三种符号计数。
   */
  item.text = ` $(symbol-namespace) Shux · fn ${funcs} · st ${structs} · en ${enums}`;
  /** 悬停详细信息：分项列出 */
  item.tooltip = `Shux (.x)
函数: ${funcs}
结构体: ${structs}
枚举: ${enums}`;
}
