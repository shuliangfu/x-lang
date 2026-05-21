/**
 * Shulang ReferenceProvider — LSP 查找引用的本地回退。
 */

import * as vscode from 'vscode';
import { findReferencesInWorkspace } from './symbolSearch';

/** 创建引用查找 Provider */
export function createShulangReferenceProvider(): vscode.ReferenceProvider {
  return {
    async provideReferences(
      document: vscode.TextDocument,
      position: vscode.Position,
      _context: vscode.ReferenceContext,
      _token: vscode.CancellationToken
    ): Promise<vscode.Location[]> {
      if (document.languageId !== 'su') {
        return [];
      }

      const wordRange = document.getWordRangeAtPosition(position);
      if (!wordRange) {
        return [];
      }

      const name = document.getText(wordRange);
      if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(name)) {
        return [];
      }

      return findReferencesInWorkspace(name, document.uri);
    },
  };
}
