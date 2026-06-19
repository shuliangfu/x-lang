/**
 * shux 可执行路径解析 — 扩展与 TaskProvider 共用。
 *
 * 优先级：
 * 1. 绝对路径原样使用；
 * 2. 含路径分隔符的相对路径 → 相对工作区根目录；
 * 3. 配置为 `shux`（默认）且工作区存在 `compiler/shux` → 自动使用（本仓库布局）；
 * 4. 否则原样返回，依赖 PATH 查找。
 */

import * as fs from 'fs';
import * as path from 'path';
import * as vscode from 'vscode';

/** 本仓库内 shux 相对工作区根目录的默认位置 */
export const WORKSPACE_SHUX_RELATIVE = 'compiler/shux';

/** 与 package.json shux.serverPath 默认一致 */
export const DEFAULT_SERVER_PATH = WORKSPACE_SHUX_RELATIVE;

/**
 * 解析 shux.serverPath 为可用于 ProcessExecution / LSP 的可执行路径。
 * @param configured 用户配置的 shux.serverPath
 */
export function resolveServerCommand(configured: string): string {
  const trimmed = configured.trim();
  if (!trimmed) {
    return resolveServerCommand('shux');
  }

  if (path.isAbsolute(trimmed)) {
    return trimmed;
  }

  const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
  if (root && trimmed.includes(path.sep)) {
    return path.join(root, trimmed);
  }

  // 默认 shux：工作区自带 compiler/shux 时直接使用（shux monorepo 开发）
  if (root && trimmed === 'shux') {
    const localShu = path.join(root, WORKSPACE_SHUX_RELATIVE);
    if (fs.existsSync(localShu)) {
      return localShu;
    }
  }

  return trimmed;
}
