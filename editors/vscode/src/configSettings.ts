/**
 * 读取 shulang.compiler.* 配置：优先 settings.json 中的数组/对象，兼容旧版 JSON 字符串。
 */

import * as vscode from 'vscode';

/** 默认 import 库根（相对工作区根），与 package.json default 一致。 */
export const DEFAULT_LIB_ROOTS = ['.', 'compiler/src', 'core', 'std'];

/**
 * 读取字符串数组配置：支持 `["a"]` 原生数组，或旧版 `"[\"a\"]"` JSON 字符串。
 */
export function readStringArraySetting(
  config: vscode.WorkspaceConfiguration,
  key: string,
  fallback: string[],
  label: string,
  outputChannel?: vscode.OutputChannel
): string[] {
  const value = config.get<unknown>(key);
  if (Array.isArray(value) && value.every((item) => typeof item === 'string')) {
    return value as string[];
  }
  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (!trimmed || trimmed === '[]') {
      return fallback;
    }
    try {
      const parsed = JSON.parse(trimmed) as unknown;
      if (Array.isArray(parsed) && parsed.every((item) => typeof item === 'string')) {
        return parsed as string[];
      }
    } catch {
      outputChannel?.appendLine(`[Shulang] ${label} 不是合法 JSON 数组，已使用默认值。`);
    }
  }
  return fallback;
}

/**
 * 读取环境变量对象：支持 `{ "K": "V" }` 原生对象，或旧版 JSON 字符串。
 */
export function readEnvJsonSetting(
  config: vscode.WorkspaceConfiguration,
  outputChannel?: vscode.OutputChannel
): Record<string, string> {
  const value = config.get<unknown>('compiler.envJson');
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    const out: Record<string, string> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      if (typeof v === 'string') {
        out[k] = v;
      }
    }
    return out;
  }
  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (!trimmed || trimmed === '{}') {
      return {};
    }
    try {
      const parsed = JSON.parse(trimmed) as unknown;
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
        const out: Record<string, string> = {};
        for (const [k, v] of Object.entries(parsed as Record<string, unknown>)) {
          if (typeof v === 'string') {
            out[k] = v;
          }
        }
        return out;
      }
    } catch {
      outputChannel?.appendLine('[Shulang] compiler.envJson 不是合法 JSON，已忽略。');
    }
  }
  return {};
}

/** 读取 shulang.compiler.libRoots。 */
export function readLibRootsSetting(
  config: vscode.WorkspaceConfiguration,
  outputChannel?: vscode.OutputChannel
): string[] {
  return readStringArraySetting(config, 'compiler.libRoots', DEFAULT_LIB_ROOTS, 'compiler.libRoots', outputChannel);
}

/** 读取 shulang.compiler.extraArgs。 */
export function readExtraArgsSetting(
  config: vscode.WorkspaceConfiguration,
  outputChannel?: vscode.OutputChannel
): string[] {
  return readStringArraySetting(config, 'compiler.extraArgs', [], 'compiler.extraArgs', outputChannel);
}
