/**
 * Shulang DefinitionProvider — LSP 跳转定义的本地回退与增强。
 */

import * as vscode from 'vscode';
import {
  findDeclInImportedModules,
  findDeclInSuDocument,
  findDeclInWorkspaceSu,
  findExternCImplementation,
  isExternFunctionInDocument,
} from './symbolSearch';

/** 创建定义跳转 Provider */
export function createShulangDefinitionProvider(): vscode.DefinitionProvider {
  return {
    async provideDefinition(
      document: vscode.TextDocument,
      position: vscode.Position,
      _token: vscode.CancellationToken
    ): Promise<vscode.Definition | vscode.DefinitionLink[] | null> {
      if (document.languageId !== 'su') {
        return null;
      }

      const wordRange = document.getWordRangeAtPosition(position);
      if (!wordRange) {
        return null;
      }

      const name = document.getText(wordRange);
      if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(name)) {
        return null;
      }

      const wf = vscode.workspace.getWorkspaceFolder(document.uri);
      const locations: vscode.Location[] = [];

      const local = findDeclInSuDocument(document, name);
      if (local) {
        locations.push(local);
        if (isExternFunctionInDocument(document, name) && wf) {
          const cLoc = await findExternCImplementation(name, wf.uri);
          if (cLoc) {
            locations.push(cLoc);
          }
        }
        return locations.length === 1 ? locations[0] : locations;
      }

      const inImport = await findDeclInImportedModules(document, name);
      if (inImport) {
        return inImport;
      }

      const remote = await findDeclInWorkspaceSu(name, document.uri);
      if (remote) {
        let modDoc: vscode.TextDocument;
        try {
          modDoc = await vscode.workspace.openTextDocument(remote.uri);
        } catch {
          return remote;
        }
        if (isExternFunctionInDocument(modDoc, name) && wf) {
          const cLoc = await findExternCImplementation(name, wf.uri);
          if (cLoc) {
            return [remote, cLoc];
          }
        }
        return remote;
      }

      if (wf) {
        const cOnly = await findExternCImplementation(name, wf.uri);
        if (cOnly) {
          return cOnly;
        }
      }

      return null;
    },
  };
}
