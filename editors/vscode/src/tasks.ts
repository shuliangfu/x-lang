/**
 * Shux TaskProvider — 构建任务
 *
 * 提供 Ctrl+Shift+B / 任务面板的 Shux 构建任务：
 * - shux build       (项目级构建)
 * - shux build <file> (单文件构建)
 * - shux run <file>   (运行当前文件)
 * - shux --lsp        (启动语言服务器)
 *
 * 同时提供 file-watch 任务（保存 .x 时自动 check/lint）。
 */

import * as vscode from 'vscode';
import { DEFAULT_SERVER_PATH, resolveServerCommand } from './shuxPath';
import { t } from './i18n';

/**
 * 读取 `shux.build.*` 配置，生成 build/run 子命令的额外参数。
 *
 * - `shux.build.optimizationLevel` → `-O<level>`（仅 >0 时追加）
 * - `shux.build.debugInfo` → `-g`
 * - `shux.build.outputName` → `-o <name>`（非空时追加）
 *
 * run 任务仅追加 `-O` / `-g`（不传 `-o`，避免覆盖 run 的临时输出路径）。
 */
function buildExtraArgs(forRun: boolean): string[] {
  const config = vscode.workspace.getConfiguration('shux');
  const args: string[] = [];
  const opt = config.get<string>('build.optimizationLevel', '0');
  if (opt !== '0') {
    args.push(`-O${opt}`);
  }
  if (config.get<boolean>('build.debugInfo', false)) {
    args.push('-g');
  }
  if (!forRun) {
    const outputName = config.get<string>('build.outputName', '').trim();
    if (outputName) {
      args.push('-o', outputName);
    }
  }
  return args;
}

export class ShuxTaskProvider implements vscode.TaskProvider {
  static ShuxType = 'shux';

  public provideTasks(
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.Task[]> {
    const config = vscode.workspace.getConfiguration('shux');
    const serverPath = config.get<string>('serverPath', DEFAULT_SERVER_PATH);
    const command = resolveServerCommand(serverPath);
    const cwd = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;

    const tasks: vscode.Task[] = [];
    const kind: vscode.TaskDefinition = { type: ShuxTaskProvider.ShuxType };

    // ── 任务 1: shux build（项目级） ──
    const buildArgs = ['build', ...buildExtraArgs(false)];
    const buildTask = new vscode.Task(
      { type: ShuxTaskProvider.ShuxType, task: 'build' },
      vscode.TaskScope.Workspace,
      'shux build',
      'Shux',
      new vscode.ProcessExecution(command, buildArgs, { cwd })
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
    buildTask.problemMatchers = ['$shux-parse', '$shux-typeck'];
    tasks.push(buildTask);

    // ── 任务 2: shux build <当前文件> ──
    const buildFileArgs = ['build', '${file}', ...buildExtraArgs(false)];
    const buildFileTask = new vscode.Task(
      { type: ShuxTaskProvider.ShuxType, task: 'build-file' },
      vscode.TaskScope.Workspace,
      t('shux build (current file)'),
      'Shux',
      new vscode.ProcessExecution(command, buildFileArgs, { cwd })
    );
    buildFileTask.group = vscode.TaskGroup.Build;
    buildFileTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Always,
      panel: vscode.TaskPanelKind.Shared,
      clear: true,
      echo: true,
      showReuseMessage: false,
    };
    buildFileTask.problemMatchers = ['$shux-parse', '$shux-typeck'];
    tasks.push(buildFileTask);

    // ── 任务 3: shux run <当前文件> ──
    const runArgs = ['run', '${file}', ...buildExtraArgs(true)];
    const runTask = new vscode.Task(
      { type: ShuxTaskProvider.ShuxType, task: 'run' },
      vscode.TaskScope.Workspace,
      t('shux run (current file)'),
      'Shux',
      new vscode.ProcessExecution(command, runArgs, { cwd })
    );
    runTask.group = vscode.TaskGroup.Test;
    runTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Always,
      panel: vscode.TaskPanelKind.Dedicated,
      clear: false,
    };
    tasks.push(runTask);

    // ── 任务 4: shux check <当前文件>（自动 watch） ──
    const checkTask = new vscode.Task(
      { type: ShuxTaskProvider.ShuxType, task: 'check' },
      vscode.TaskScope.Workspace,
      t('shux check (current file)'),
      'Shux',
      new vscode.ProcessExecution(command, ['check', '${file}'], { cwd })
    );
    checkTask.group = vscode.TaskGroup.Test;
    checkTask.presentationOptions = {
      reveal: vscode.TaskRevealKind.Silent,
      panel: vscode.TaskPanelKind.Shared,
      clear: true,
    };
    checkTask.problemMatchers = ['$shux-parse', '$shux-typeck'];
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
