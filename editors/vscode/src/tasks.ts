/**
 * Shulang TaskProvider — 构建任务
 *
 * 提供 Ctrl+Shift+B / 任务面板的 Shulang 构建任务：
 * - shu build       (项目级构建)
 * - shu build <file> (单文件构建)
 * - shu run <file>   (运行当前文件)
 * - shu --lsp        (启动语言服务器)
 *
 * 同时提供 file-watch 任务（保存 .su 时自动 check/lint）。
 */

import * as vscode from 'vscode';
import { resolveServerCommand } from './shuPath';

export class ShulangTaskProvider implements vscode.TaskProvider {
  static ShulangType = 'shulang';

  public provideTasks(
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.Task[]> {
    const config = vscode.workspace.getConfiguration('shulang');
    const serverPath = config.get<string>('serverPath', 'shu');
    const command = resolveServerCommand(serverPath);

    const tasks: vscode.Task[] = [];
    const kind: vscode.TaskDefinition = { type: ShulangTaskProvider.ShulangType };

    // ── 任务 1: shu build（项目级） ──
    const buildTask = new vscode.Task(
      { type: ShulangTaskProvider.ShulangType, task: 'build' },
      vscode.TaskScope.Workspace,
      'shu build',
      'Shulang',
      new vscode.ProcessExecution(command, ['build'], {
        cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
      })
    );
    buildTask.group = vscode.TaskGroup.Build;
    buildTask.isBackground = false;
    buildTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Always,
      panel: vscode.TaskPanelKind.Shared,
      clear: true,
      echo: true,
      showReuseMessage: false,
    };
    // 匹配三种编译器报错格式
    buildTask.problemMatchers = ['$shulang-parse', '$shulang-typeck'];
    tasks.push(buildTask);

    // ── 任务 2: shu build <当前文件> ──
    const buildFileTask = new vscode.Task(
      { type: ShulangTaskProvider.ShulangType, task: 'build-file' },
      vscode.TaskScope.Workspace,
      'shu build (当前文件)',
      'Shulang',
      new vscode.ProcessExecution(command, ['build', '${file}'], {
        cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
      })
    );
    buildFileTask.group = vscode.TaskGroup.Build;
    buildFileTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Always,
      panel: vscode.TaskPanelKind.Shared,
      clear: true,
      echo: true,
      showReuseMessage: false,
    };
    buildFileTask.problemMatchers = ['$shulang-parse', '$shulang-typeck'];
    tasks.push(buildFileTask);

    // ── 任务 3: shu run <当前文件> ──
    const runTask = new vscode.Task(
      { type: ShulangTaskProvider.ShulangType, task: 'run' },
      vscode.TaskScope.Workspace,
      'shu run (当前文件)',
      'Shulang',
      new vscode.ProcessExecution(command, ['run', '${file}'], {
        cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
      })
    );
    runTask.group = vscode.TaskGroup.Test;
    runTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Always,
      panel: vscode.TaskPanelKind.Dedicated,
      clear: false,
    };
    tasks.push(runTask);

    // ── 任务 4: shu check <当前文件>（自动 watch） ──
    const checkTask = new vscode.Task(
      { type: ShulangTaskProvider.ShulangType, task: 'check' },
      vscode.TaskScope.Workspace,
      'shu check (当前文件)',
      'Shulang',
      new vscode.ProcessExecution(command, ['check', '${file}'], {
        cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
      })
    );
    checkTask.group = vscode.TaskGroup.Test;
    checkTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Silent,
      panel: vscode.TaskPanelKind.Shared,
      clear: true,
    };
    tasks.push(checkTask);

    return tasks;
  }

  public resolveTask(
    task: vscode.Task,
    _token: vscode.CancellationToken
  ): vscode.Task | undefined {
    return task;
  }
}
