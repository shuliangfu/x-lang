/**
 * Xlang CodeActionProvider — 灯泡提示
 *
 * 对常见 parse/typeck 错误提供修复建议入口：
 * - parse error: 缺少分号 → 插入 `;`
 * - parse error: 括号不匹配 → 插入 `)` 或 `}`
 * - typeck error: 类型不匹配 → 提示查看类型
 *
 * 仅生成 CodeAction 入口，实际修复由用户确认后执行。
 */

import * as vscode from 'vscode';
import { t } from './i18n';

export class XlangCodeActionProvider implements vscode.CodeActionProvider {
  public provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
    context: vscode.CodeActionContext,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.CodeAction[]> {
    const actions: vscode.CodeAction[] = [];

    // 基于诊断生成修复建议
    for (const diag of context.diagnostics) {
      if (diag.source !== 'xlang' && diag.source !== 'x') {
        continue;
      }

      const message = diag.message.toLowerCase();

      // 缺少分号
      if (message.includes('expected') && (message.includes(';') || message.includes('semicolon'))) {
        const action = new vscode.CodeAction(t('Insert semicolon ;'), vscode.CodeActionKind.QuickFix);
        action.edit = new vscode.WorkspaceEdit();
        const line = diag.range.end.line;
        const lineText = document.lineAt(line).text;
        const insertPos = new vscode.Position(line, lineText.length);
        action.edit.insert(document.uri, insertPos, ';');
        action.diagnostics = [diag];
        actions.push(action);
      }

      // 括号不匹配
      if (message.includes('expected') && message.includes(')')) {
        const action = new vscode.CodeAction(t('Insert closing paren )'), vscode.CodeActionKind.QuickFix);
        action.edit = new vscode.WorkspaceEdit();
        action.edit.insert(document.uri, diag.range.end, ')');
        action.diagnostics = [diag];
        actions.push(action);
      }
      if (message.includes('expected') && message.includes('}')) {
        const action = new vscode.CodeAction(t('Insert closing brace }'), vscode.CodeActionKind.QuickFix);
        action.edit = new vscode.WorkspaceEdit();
        action.edit.insert(document.uri, diag.range.end, '}');
        action.diagnostics = [diag];
        actions.push(action);
      }

      // 类型不匹配 — 提供查看类型信息的入口
      if (message.includes('type mismatch') || message.includes('expected')) {
        const action = new vscode.CodeAction(
          t('View type info (hover)'),
          vscode.CodeActionKind.QuickFix
        );
        action.command = {
          command: 'editor.action.showHover',
          title: t('Show hover'),
          arguments: [],
        };
        action.diagnostics = [diag];
        actions.push(action);
      }
    }

    // 通用源代码操作（无论是否有诊断）
    if (range instanceof vscode.Selection && !range.isEmpty) {
      const commentAction = new vscode.CodeAction(
        t('Comment selection (//)'),
        vscode.CodeActionKind.Refactor
      );
      commentAction.command = {
        command: 'editor.action.commentLine',
        title: t('Toggle comment'),
      };
      actions.push(commentAction);
    }

    return actions;
  }
}
