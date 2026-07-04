/**
 * Shux import 路径解析 — 与 compiler/runtime.c resolve_import_file_path_multi 对齐。
 */

import * as path from 'path';
import * as vscode from 'vscode';
import { readLibRootsSetting } from './configSettings';

/** 读取 shux.compiler.libRoots，转为 SHUX_LSP_LIB_ROOTS（`:` 分隔，与 runtime/LSP C 侧一致）。 */
export function getLibRootsEnvColon(): string {
  const config = vscode.workspace.getConfiguration('shux');
  return readLibRootsSetting(config).join(':');
}

export type ImportResolveResult = {
  uri?: vscode.Uri;
  attempts: string[];
};

/**
 * 读取 shux.compiler.libRoots 配置（字符串数组）。
 */
export function getLibRootUris(workspaceRoot: vscode.Uri): vscode.Uri[] {
  const config = vscode.workspace.getConfiguration('shux');
  const rels = readLibRootsSetting(config);
  return rels.map((rel) =>
    rel === '.' || rel === ''
      ? workspaceRoot
      : vscode.Uri.joinPath(workspaceRoot, ...rel.split('/'))
  );
}

async function fileExists(uri: vscode.Uri): Promise<boolean> {
  try {
    const stat = await vscode.workspace.fs.stat(uri);
    return stat.type === vscode.FileType.File;
  } catch {
    return false;
  }
}

function collectCandidates(
  libRoot: vscode.Uri,
  importPath: string,
  entryDir?: vscode.Uri
): vscode.Uri[] {
  const out: vscode.Uri[] = [];
  const isFilePath =
    importPath.includes('/') || importPath.endsWith('.x');

  if (isFilePath) {
    if (importPath.startsWith('/')) {
      out.push(vscode.Uri.file(importPath));
    } else if (entryDir) {
      out.push(vscode.Uri.joinPath(entryDir, importPath));
    }
    out.push(vscode.Uri.joinPath(libRoot, importPath));
    return out;
  }

  const hasDot = importPath.includes('.');

  if (hasDot) {
    const seg = importPath.replace(/\./g, '/');
    out.push(vscode.Uri.joinPath(libRoot, `${seg}.x`));
    out.push(vscode.Uri.joinPath(libRoot, seg, 'mod.x'));
  } else {
    out.push(vscode.Uri.joinPath(libRoot, `${importPath}.x`));
    out.push(vscode.Uri.joinPath(libRoot, importPath, 'mod.x'));
    out.push(vscode.Uri.joinPath(libRoot, importPath, `${importPath}.x`));
  }

  if (entryDir) {
    if (!hasDot) {
      out.push(vscode.Uri.joinPath(entryDir, `${importPath}.x`));
    } else {
      let eff = importPath;
      const dirName = path.basename(entryDir.fsPath);
      const firstDot = importPath.indexOf('.');
      if (firstDot > 0 && importPath.slice(0, firstDot) === dirName) {
        eff = importPath.slice(firstDot + 1);
      }
      const seg = eff.replace(/\./g, '/');
      out.push(vscode.Uri.joinPath(entryDir, `${seg}.x`));
      out.push(vscode.Uri.joinPath(entryDir, seg, 'mod.x'));
    }
  }

  return out;
}

export async function resolveShuxImportWithAttempts(
  workspaceRoot: vscode.Uri,
  documentUri: vscode.Uri,
  importPath: string
): Promise<ImportResolveResult> {
  const entryDir = vscode.Uri.file(path.dirname(documentUri.fsPath));
  const attempts: string[] = [];
  const seen = new Set<string>();

  for (const libRoot of getLibRootUris(workspaceRoot)) {
    for (const candidate of collectCandidates(libRoot, importPath, entryDir)) {
      const key = candidate.fsPath;
      if (seen.has(key)) {
        continue;
      }
      seen.add(key);
      attempts.push(path.relative(workspaceRoot.fsPath, candidate.fsPath));
      if (await fileExists(candidate)) {
        return { uri: candidate, attempts };
      }
    }
  }

  return { attempts };
}

export async function resolveShuxImportUri(
  workspaceRoot: vscode.Uri,
  documentUri: vscode.Uri,
  importPath: string
): Promise<vscode.Uri | undefined> {
  const r = await resolveShuxImportWithAttempts(workspaceRoot, documentUri, importPath);
  return r.uri;
}
