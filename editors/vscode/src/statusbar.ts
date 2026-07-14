/**
 * Shux 状态栏 — 在右下角显示「Shux」及对当前 `.x` 源的符号粗略统计。
 *
 * 统计范围：function / struct / enum / trait / impl / type
 * 识别前缀：export、packed、soa、align(N)、allow(padding)
 */

import * as vscode from 'vscode';
import {
  ExtensionContext,
  StatusBarAlignment,
  StatusBarItem,
  TextEditor,
  window,
} from 'vscode';
import { t } from './i18n';

/** VSCode StatusBar：扩展侧持有单例，防止重复条目。 */
let shuxStatusItem: StatusBarItem | undefined;

/** LSP 连接状态：由 lspClient.ts 状态变更时调用 setShuxLspStatus 更新 */
let lspConnected = false;

/** 【Why】所有正则统一识别 export/packed/soa/align/allow(padding) 前缀 */
const FUNC_HEAD = /^\s*(?:export\s+)?function\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/;
const STRUCT_HEAD =
  /^\s*(?:export\s+)?(?:allow\(padding\)\s+|packed\s+|soa\s+|align\(\d+\)\s+)*struct\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;
const ENUM_HEAD = /^\s*(?:export\s+)?enum\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;
const TRAIT_HEAD = /^\s*(?:export\s+)?trait\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;
const IMPL_HEAD = /^\s*impl\s+[a-zA-Z_][a-zA-Z0-9_]*\s+for\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\{/;
const TYPE_HEAD = /^\s*(?:export\s+)?type\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=/;

/**
 * 将源码中的注释替换为等价长度的空白字符，保留换行，
 * 使基于 `^` 的行首正则不会匹配到注释中的关键字。
 */
function stripXCommentsPreserveNewlines(source: string): string {
  const outChars: string[] = new Array(source.length);
  let lineComment = false;
  let blockDepth = 0;
  let inString = false;
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

    if (c === '"') {
      inString = true;
      escaped = false;
      outChars[i] = '"';
      continue;
    }

    if (c === '/' && n === '/') {
      outChars[i] = ' ';
      outChars[i + 1] = ' ';
      lineComment = true;
      i++;
      continue;
    }
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

/** 对清洗后的源码逐行计数：function / struct / enum / trait / impl / type */
function countXSymbolsPerLinePrefix(sanitized: string): {
  funcs: number;
  structs: number;
  enums: number;
  traits: number;
  impls: number;
  types: number;
} {
  let funcs = 0;
  let structs = 0;
  let enums = 0;
  let traits = 0;
  let impls = 0;
  let types = 0;
  const lines = sanitized.split(/\r?\n/);
  for (const line of lines) {
    if (FUNC_HEAD.test(line)) funcs++;
    else if (STRUCT_HEAD.test(line)) structs++;
    else if (ENUM_HEAD.test(line)) enums++;
    else if (TRAIT_HEAD.test(line)) traits++;
    else if (IMPL_HEAD.test(line)) impls++;
    else if (TYPE_HEAD.test(line)) types++;
  }
  return { funcs, structs, enums, traits, impls, types };
}

/**
 * 创建右下角 Shux 状态项并完成首次刷新（若当前有活动编辑器）。
 */
export function registerShuxStatusBar(context: ExtensionContext): void {
  if (shuxStatusItem) {
    shuxStatusItem.dispose();
  }
  const item = window.createStatusBarItem(StatusBarAlignment.Right, 100);
  shuxStatusItem = item;
  item.name = 'Shux';
  item.text = ' Shux';
  item.tooltip = 'Shux (.x)';
  item.show();
  context.subscriptions.push(item);
  /** 诊断变更时刷新状态栏（更新错误/警告计数） */
  context.subscriptions.push(
    vscode.languages.onDidChangeDiagnostics(() => {
      refreshShuxStatusBar(window.activeTextEditor);
    })
  );
  refreshShuxStatusBar(window.activeTextEditor);
}

/**
 * 设置 LSP 连接状态，由 lspClient.ts 在 onDidChangeState 时调用。
 * @param connected true=LSP 已连接，false=未连接/已停止
 */
export function setShuxLspStatus(connected: boolean): void {
  lspConnected = connected;
  refreshShuxStatusBar(window.activeTextEditor);
}

/**
 * 在活动编辑器或其文档发生变化时刷新状态栏计数。
 *
 * - 若为 `.x`：统计 function/struct/enum/trait/impl/type（排除注释）
 * - 否则回退占位文本
 *
 * 子开关（受 `shux.features.statusBar` 总开关约束）：
 * - `shux.features.statusBarDiagnostics`：是否显示错误/警告计数
 * - `shux.features.statusBarLspStatus`：是否显示 LSP 连接指示器
 */
export function refreshShuxStatusBar(editor: TextEditor | undefined): void {
  const item = shuxStatusItem;
  if (!item) {
    return;
  }

  const config = vscode.workspace.getConfiguration('shux');
  const showLspStatus = config.get<boolean>('features.statusBarLspStatus', true);
  const showDiagnostics = config.get<boolean>('features.statusBarDiagnostics', true);

  /** LSP 状态指示器：未连接时显示 $(circle-slash)，已连接时不额外显示 */
  const lspBadge = showLspStatus && !lspConnected ? '$(circle-slash) ' : '';

  if (!editor || editor.document.languageId !== 'x') {
    item.text = ` ${lspBadge}Shux`;
    item.tooltip = lspConnected ? 'Shux (.x)' : `Shux (.x)\n${t('LSP not connected')}`;
    return;
  }

  const sanitized = stripXCommentsPreserveNewlines(editor.document.getText());
  const { funcs, structs, enums, traits, impls, types } = countXSymbolsPerLinePrefix(sanitized);

  /** 诊断计数：统计当前文件的 error / warning 数量 */
  let errCount = 0;
  let warnCount = 0;
  if (showDiagnostics) {
    const diags = vscode.languages.getDiagnostics(editor.document.uri);
    for (const d of diags) {
      if (d.severity === vscode.DiagnosticSeverity.Error) errCount++;
      else if (d.severity === vscode.DiagnosticSeverity.Warning) warnCount++;
    }
  }
  const diagBadge =
    (errCount > 0 ? ` · $(error) ${errCount}` : '') +
    (warnCount > 0 ? ` · $(warning) ${warnCount}` : '');

  item.text = ` ${lspBadge}$(symbol-namespace) Shux · fn ${funcs} · st ${structs} · en ${enums} · tr ${traits} · im ${impls} · ty ${types}${diagBadge}`;
  item.tooltip = `Shux (.x)\n${t('Functions: {0}', funcs)}\n${t('Structs: {0}', structs)}\n${t('Enums: {0}', enums)}\n${t('Traits: {0}', traits)}\n${t('Impls: {0}', impls)}\n${t('Types: {0}', types)}${errCount > 0 ? `\n${t('Errors: {0}', errCount)}` : ''}${warnCount > 0 ? `\n${t('Warnings: {0}', warnCount)}` : ''}${!lspConnected ? `\n${t('LSP not connected')}` : ''}`;
}
