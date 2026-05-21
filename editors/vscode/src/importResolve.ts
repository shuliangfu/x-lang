/**
 * Shulang import 路径解析 — 与 compiler/runtime.c resolve_import_file_path_multi 对齐。
 */

import * as path from 'path';
import * as vscode from 'vscode';

/** 默认库根（相对工作区根） */
const DEFAULT_LIB_ROOT_REL = ['.', 'compiler/src', 'core', 'std'];

export type ImportResolveResult = {
  uri?: vscode.Uri;
  attempts: string[];
};

/**
 * 读取 shulang.compiler.libRoots 配置（JSON 字符串数组）。
 */
export function getLibRootUris(workspaceRoot: vscode.Uri): vscode.Uri[] {
  const config = vscode.workspace.getConfiguration('shulang');
  const raw = config.get<string>('compiler.libRoots', JSON.stringify(DEFAULT_LIB_ROOT_REL));
  let rels: string[] = DEFAULT_LIB_ROOT_REL;
  try {
    const parsed = JSON.parse(raw) as unknown;
    if (Array.isArray(parsed) && parsed.every((x) => typeof x === 'string')) {
      rels = parsed as string[];
    }
  } catch {
    // 默认
  }

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
  const hasDot = importPath.includes('.');

  if (hasDot) {
    const seg = importPath.replace(/\./g, '/');
    out.push(vscode.Uri.joinPath(libRoot, `${seg}.su`));
    out.push(vscode.Uri.joinPath(libRoot, seg, 'mod.su'));
  } else {
    out.push(vscode.Uri.joinPath(libRoot, `${importPath}.su`));
    out.push(vscode.Uri.joinPath(libRoot, importPath, 'mod.su'));
    out.push(vscode.Uri.joinPath(libRoot, importPath, `${importPath}.su`));
  }

  if (entryDir) {
    if (!hasDot) {
      out.push(vscode.Uri.joinPath(entryDir, `${importPath}.su`));
    } else {
      let eff = importPath;
      const dirName = path.basename(entryDir.fsPath);
      const firstDot = importPath.indexOf('.');
      if (firstDot > 0 && importPath.slice(0, firstDot) === dirName) {
        eff = importPath.slice(firstDot + 1);
      }
      const seg = eff.replace(/\./g, '/');
      out.push(vscode.Uri.joinPath(entryDir, `${seg}.su`));
      out.push(vscode.Uri.joinPath(entryDir, seg, 'mod.su'));
    }
  }

  return out;
}

export async function resolveShulangImportWithAttempts(
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

export async function resolveShulangImportUri(
  workspaceRoot: vscode.Uri,
  documentUri: vscode.Uri,
  importPath: string
): Promise<vscode.Uri | undefined> {
  const r = await resolveShulangImportWithAttempts(workspaceRoot, documentUri, importPath);
  return r.uri;
}
