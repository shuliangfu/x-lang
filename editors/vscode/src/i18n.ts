/**
 * i18n 模块 — 统一翻译入口
 *
 * 【Why】VS Code 的 vscode.l10n.t() 自动根据 --locale 加载 bundle，
 *   但用户可能希望在英文 VS Code 中也能看到中文界面（或反之）。
 *   本模块提供 xlang.locale 配置项覆盖：
 *   - "auto"（默认）：使用 VS Code 显示语言（vscode.l10n.t 原生行为）
 *   - "en"/"zh-cn"/"zh-tw"/"ja"/"ko"/"de"/"fr"/"es"/"ru"/"pt-br"/"it"/"tr"/"pl"：
 *     手动加载对应 l10n.bundle.<lang>.json，覆盖 VS Code locale
 *
 * 【Invariant】t() 在未初始化时回退到 vscode.l10n.t，保证安全
 * 【Asm/Perf】bundle 仅加载一次并缓存；t() 为纯查表 + replace，O(n) n=args.length
 */

import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

/** 已加载的自定义翻译包（key → 翻译值） */
let customBundle: Record<string, string> | undefined;

/** 当前生效的 locale（undefined 表示用 VS Code 默认） */
let activeLocale: string | undefined;

/** 支持的语言列表 */
export const SUPPORTED_LOCALES = [
  'auto',
  'en',
  'zh-cn',
  'zh-tw',
  'ja',
  'ko',
  'de',
  'fr',
  'es',
  'ru',
  'pt-br',
  'it',
  'tr',
  'pl',
] as const;

export type XlangLocale = (typeof SUPPORTED_LOCALES)[number];

/**
 * 初始化 i18n：读取 xlang.locale 配置并加载对应 bundle。
 * 在 extension.ts 的 activate() 中调用。
 */
export function initI18n(context: vscode.ExtensionContext): void {
  const config = vscode.workspace.getConfiguration('xlang');
  const locale = config.get<string>('locale', 'auto');

  // 重新加载
  customBundle = undefined;
  activeLocale = undefined;

  if (!locale || locale === 'auto') {
    // 使用 VS Code 原生 l10n
    return;
  }

  if (locale === 'en') {
    // 英文是默认，不需要 bundle
    activeLocale = 'en';
    return;
  }

  // 加载自定义 bundle
  const bundlePath = path.join(context.extensionPath, `l10n.bundle.${locale}.json`);
  try {
    const content = fs.readFileSync(bundlePath, 'utf-8');
    customBundle = JSON.parse(content);
    activeLocale = locale;
  } catch {
    // bundle 文件不存在，回退到 VS Code 原生 l10n
    void vscode.window.showWarningMessage(
      `Xlang locale "${locale}" bundle not found, falling back to VS Code locale.`
    );
  }
}

/**
 * 监听配置变化，当 xlang.locale 改变时重新加载 bundle。
 */
export function onLocaleConfigChanged(context: vscode.ExtensionContext): vscode.Disposable {
  return vscode.workspace.onDidChangeConfiguration((e) => {
    if (e.affectsConfiguration('xlang.locale')) {
      initI18n(context);
    }
  });
}

/**
 * 翻译函数 — 替代 vscode.l10n.t()
 *
 * 优先级：xlang.locale 配置 > VS Code locale
 *
 * 用法：
 *   t('Hello {0}', name)
 *   t('No file to run.')
 */
export function t(message: string, ...args: (string | number)[]): string {
  if (customBundle && customBundle[message] !== undefined) {
    let translated = customBundle[message];
    // 替换 {0}, {1}, {2}...
    for (let i = 0; i < args.length; i++) {
      translated = translated.replace(`{${i}}`, String(args[i]));
    }
    return translated;
  }

  // 回退到 VS Code 原生 l10n
  if (args.length > 0) {
    return vscode.l10n.t(message, ...args);
  }
  return vscode.l10n.t(message);
}

/** 获取当前生效的 locale（用于调试/状态栏显示） */
export function getActiveLocale(): string {
  return activeLocale ?? 'auto';
}
