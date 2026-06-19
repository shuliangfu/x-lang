/**
 * Shux 符号搜索 — import 解析、跨模块定义、extern C 实现定位。
 * 供 DefinitionProvider / ReferenceProvider / HoverProvider 共用。
 */

import * as path from 'path';
import * as vscode from 'vscode';
import { resolveShuxImportUri, resolveShuxImportWithAttempts } from './importResolve';

/** 从文档文本解析 import 模块路径列表 */
const IMPORT_RE = /\bimport\s+([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\s*;/g;

/** function / extern function */
const FUNC_DECL = /^\s*(?:extern\s+)?function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/;
/** struct */
const STRUCT_DECL = /^\s*(?:allow\(padding\)\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*[\{<]/;
/** enum */
const ENUM_DECL = /^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{/;
/** let / const */
const LET_CONST_DECL = /^\s*(?:let|const)\s+([A-Za-z_][A-Za-z0-9_]*)\s*:/;
/** trait */
const TRAIT_DECL = /^\s*trait\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{/;

/**
 * 解析文档中所有 import 路径。
 * @param text 文档全文
 */
export function parseImportPaths(text: string): string[] {
  const out: string[] = [];
  let m: RegExpExecArray | null;
  IMPORT_RE.lastIndex = 0;
  while ((m = IMPORT_RE.exec(text))) {
    if (!out.includes(m[1])) {
      out.push(m[1]);
    }
  }
  return out;
}

/**
 * 判断光标是否落在 import 路径令牌上。
 */
export function importPathAtPosition(
  document: vscode.TextDocument,
  position: vscode.Position
): string | undefined {
  const text = document.getText();
  IMPORT_RE.lastIndex = 0;
  let m: RegExpExecArray | null;
  while ((m = IMPORT_RE.exec(text))) {
    const dotted = m[1];
    const startPath = m.index + m[0].indexOf(dotted);
    const endPath = startPath + dotted.length;
    const off = document.offsetAt(position);
    if (off >= startPath && off <= endPath) {
      return dotted;
    }
  }
  return undefined;
}

/**
 * 在 .sx 文档中查找符号声明。
 */
export function findDeclInSuDocument(
  document: vscode.TextDocument,
  name: string
): vscode.Location | undefined {
  const patterns = [FUNC_DECL, STRUCT_DECL, ENUM_DECL, TRAIT_DECL, LET_CONST_DECL];
  for (let i = 0; i < document.lineCount; i++) {
    const line = document.lineAt(i).text;
    for (const re of patterns) {
      const m = re.exec(line);
      if (m && m[1] === name) {
        const col = line.indexOf(name);
        return new vscode.Location(document.uri, new vscode.Position(i, col >= 0 ? col : 0));
      }
    }
  }
  return undefined;
}

/** 文档中是否有 extern function name 声明 */
export function isExternFunctionInDocument(document: vscode.TextDocument, name: string): boolean {
  const re = new RegExp(`^\\s*extern\\s+function\\s+${name}\\s*\\(`);
  for (let i = 0; i < document.lineCount; i++) {
    if (re.test(document.lineAt(i).text)) {
      return true;
    }
  }
  return false;
}

/**
 * 在 compiler C 源中查找 extern 实现。
 */
export async function findExternCImplementation(
  name: string,
  workspaceRoot: vscode.Uri
): Promise<vscode.Location | undefined> {
  const glob = new vscode.RelativePattern(workspaceRoot, 'compiler/src/**/*.c');
  const files = await vscode.workspace.findFiles(glob, null, 80);
  const implRe = new RegExp(`\\b${name}\\s*\\(`);

  for (const uri of files) {
    let doc: vscode.TextDocument;
    try {
      doc = await vscode.workspace.openTextDocument(uri);
    } catch {
      continue;
    }
    for (let i = 0; i < doc.lineCount; i++) {
      const line = doc.lineAt(i).text;
      if (implRe.test(line) && !line.trimStart().startsWith('//')) {
        const col = line.indexOf(name);
        return new vscode.Location(uri, new vscode.Position(i, col >= 0 ? col : 0));
      }
    }
  }
  return undefined;
}

/** 在已 import 模块中查找符号 */
export async function findDeclInImportedModules(
  document: vscode.TextDocument,
  name: string
): Promise<vscode.Location | undefined> {
  const wf = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!wf) {
    return undefined;
  }

  for (const imp of parseImportPaths(document.getText())) {
    const uri = await resolveShuxImportUri(wf.uri, document.uri, imp);
    if (!uri) {
      continue;
    }
    let modDoc: vscode.TextDocument;
    try {
      modDoc = await vscode.workspace.openTextDocument(uri);
    } catch {
      continue;
    }
    const loc = findDeclInSuDocument(modDoc, name);
    if (loc) {
      return loc;
    }
  }
  return undefined;
}

/** 在工作区 .sx 中查找符号 */
export async function findDeclInWorkspaceSu(
  name: string,
  skipUri: vscode.Uri
): Promise<vscode.Location | undefined> {
  const files = await vscode.workspace.findFiles('**/*.sx', '**/node_modules/**', 300);
  for (const uri of files) {
    if (uri.fsPath === skipUri.fsPath) {
      continue;
    }
    let doc: vscode.TextDocument;
    try {
      doc = await vscode.workspace.openTextDocument(uri);
    } catch {
      continue;
    }
    const loc = findDeclInSuDocument(doc, name);
    if (loc) {
      return loc;
    }
  }
  return undefined;
}

/** 工作区文本引用查找 */
export async function findReferencesInWorkspace(
  name: string,
  _sourceUri: vscode.Uri,
  max = 128
): Promise<vscode.Location[]> {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const wordRe = new RegExp(`\\b${escaped}\\b`);
  const out: vscode.Location[] = [];
  const files = await vscode.workspace.findFiles('**/*.{su,c}', '**/node_modules/**', 200);

  for (const uri of files) {
    if (out.length >= max) {
      break;
    }
    let doc: vscode.TextDocument;
    try {
      doc = await vscode.workspace.openTextDocument(uri);
    } catch {
      continue;
    }
    for (let i = 0; i < doc.lineCount && out.length < max; i++) {
      const line = doc.lineAt(i).text;
      let col = 0;
      while (col < line.length && out.length < max) {
        const sub = line.slice(col);
        const m = wordRe.exec(sub);
        if (!m) {
          break;
        }
        const absCol = col + m.index;
        out.push(new vscode.Location(uri, new vscode.Position(i, absCol)));
        col = absCol + name.length;
      }
    }
  }

  return out;
}

/** import 解析 hover 文本 */
export async function buildImportResolveHover(
  document: vscode.TextDocument,
  importPath: string
): Promise<string> {
  const wf = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!wf) {
    return `import \`${importPath}\`：无工作区，无法解析。`;
  }
  const { uri, attempts } = await resolveShuxImportWithAttempts(
    wf.uri,
    document.uri,
    importPath
  );
  if (uri) {
    const rel = path.relative(wf.uri.fsPath, uri.fsPath);
    return `import \`${importPath}\` → \`${rel}\``;
  }
  const lines = attempts.slice(0, 12).map((p) => `- ${p}`);
  return (
    `无法解析 import \`${importPath}\`。\n\n已尝试：\n${lines.join('\n')}` +
    (attempts.length > 12 ? `\n…共 ${attempts.length} 条` : '')
  );
}
