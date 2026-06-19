/**
 * Shux VSCode 扩展入口 — LSP 客户端 + 编辑器增强
 *
 * 诊断 / 跳转 / 补全 / 悬停 / 格式化 / 大纲：仅走 shux --lsp，不注册本地 LSP 回退 Provider。
 */

import * as path from 'path';
import * as vscode from 'vscode';
import type { LanguageClient, Trace } from 'vscode-languageclient/node';

import { readEnvJsonSetting, readExtraArgsSetting, readLibRootsSetting } from './configSettings';
import { getLibRootsEnvColon } from './importResolve';
import { startShuxLanguageClient, stopShuxLanguageClient } from './lspClient';
import { DEFAULT_SERVER_PATH, resolveServerCommand } from './shuxPath';

let client: LanguageClient | undefined;
let outputChannel: vscode.OutputChannel | undefined;
let codeLensProvider: { refresh(): void } | undefined;

let heavyFeaturesReady = false;
let heavyFeaturesPromise: Promise<void> | undefined;
let configChangeDebounce: ReturnType<typeof setTimeout> | undefined;
let serverConfigSnapshot: string | undefined;

/** 将 shux.server.trace 映射为 LanguageClient Trace */
function traceFromString(s: string): Trace {
  const { Trace: TraceEnum } = require('vscode-languageclient/node') as typeof import('vscode-languageclient/node');
  switch (s) {
    case 'verbose':
      return TraceEnum.Verbose;
    case 'messages':
      return TraceEnum.Messages;
    default:
      return TraceEnum.Off;
  }
}

/** 读取 shux.compiler.envJson 与 libRoots，构造 LSP 进程 env */
function buildServerEnv(): Record<string, string> | undefined {
  const config = vscode.workspace.getConfiguration('shux');
  const env: Record<string, string> = { ...(process.env as Record<string, string>) };
  env.SHUX_LSP_LIB_ROOTS = getLibRootsEnvColon();

  const envObj = readEnvJsonSetting(config, outputChannel);
  if (Object.keys(envObj).length > 0) {
    Object.assign(env, envObj);
  }
  return env;
}

/** 构造 shux --lsp 参数列表 */
function buildServerArgs(): string[] {
  const config = vscode.workspace.getConfiguration('shux');
  const baseArgs = ['--lsp'];

  const diagnosticLevel = config.get<string>('compiler.diagnosticLevel', 'warning');
  if (diagnosticLevel !== 'warning') {
    baseArgs.push(`--diagnostic-level=${diagnosticLevel}`);
  }

  const targetDir = config.get<string>('compiler.targetDir', '');
  if (targetDir) {
    baseArgs.push(`--target-dir=${targetDir}`);
  }

  const extraArgs = readExtraArgsSetting(config, outputChannel);
  if (extraArgs.length > 0) {
    baseArgs.push(...extraArgs);
  }

  return baseArgs;
}

function isFeatureEnabled(
  config: vscode.WorkspaceConfiguration,
  feature: string,
  defaultValue = true
): boolean {
  return config.get<boolean>(`features.${feature}`, defaultValue);
}

function snapshotServerConfig(): string {
  const config = vscode.workspace.getConfiguration('shux');
  return JSON.stringify({
    serverPath: config.get<string>('serverPath', DEFAULT_SERVER_PATH),
    extraArgs: readExtraArgsSetting(config),
    libRoots: readLibRootsSetting(config),
    diagnosticLevel: config.get<string>('compiler.diagnosticLevel', 'warning'),
    targetDir: config.get<string>('compiler.targetDir', ''),
    envJson: readEnvJsonSetting(config),
    trace: config.get<string>('server.trace', 'off'),
    restartOnCrash: config.get<boolean>('server.restartOnCrash', true),
  });
}

/** 格式化 .sx 文档（走 LSP documentFormattingProvider） */
async function formatSuDocument(document: vscode.TextDocument): Promise<void> {
  const config = vscode.workspace.getConfiguration('shux');
  if (!config.get<boolean>('format.enabled', true)) {
    return;
  }

  const options: vscode.FormattingOptions = {
    tabSize: config.get<number>('format.tabSize', 2),
    insertSpaces: config.get<boolean>('format.insertSpaces', true),
  };

  let edits: vscode.TextEdit[] | undefined;
  try {
    edits = await Promise.race([
      vscode.commands.executeCommand<vscode.TextEdit[]>(
        'vscode.executeFormatDocumentProvider',
        document.uri,
        options
      ),
      new Promise<undefined>((resolve) => setTimeout(() => resolve(undefined), 2000)),
    ]);
  } catch {
    return;
  }

  if (!edits || edits.length === 0) {
    return;
  }

  const workspaceEdit = new vscode.WorkspaceEdit();
  workspaceEdit.set(document.uri, edits);
  await vscode.workspace.applyEdit(workspaceEdit);
}

async function loadHeavyFeatures(context: vscode.ExtensionContext): Promise<void> {
  if (heavyFeaturesReady) {
    return;
  }

  const [
    { ShuxFoldingRangeProvider },
    { ShuxCodeLensProvider },
    { ShuxOnTypeFormattingProvider },
    { ShuxDocumentLinkProvider },
    { ShuxTaskProvider },
    { registerShuxStatusBar, refreshShuxStatusBar },
    { createShuxSelectionRangeProvider },
  ] = await Promise.all([
    import('./folding'),
    import('./codelens'),
    import('./formatting'),
    import('./links'),
    import('./tasks'),
    import('./statusbar'),
    import('./selection'),
  ]);

  const config = vscode.workspace.getConfiguration('shux');
  const workspaceFolder = vscode.workspace.workspaceFolders?.[0];

  if (!workspaceFolder) {
    outputChannel?.appendLine(
      '[Shux] 无工作区文件夹：LSP 未启动。请 Open Folder 打开 shux 仓库根目录以启用诊断。'
    );
    void vscode.window.showWarningMessage(
      'Shux 需要打开文件夹才能启动语言服务（语法/类型诊断、跳转等）。请 Open Folder 打开项目根目录。'
    );
  } else {
    const serverPath = config.get<string>('serverPath', DEFAULT_SERVER_PATH);
    client = await startShuxLanguageClient({
      command: resolveServerCommand(serverPath),
      args: buildServerArgs(),
      cwd: workspaceFolder.uri.fsPath,
      env: buildServerEnv(),
      trace: traceFromString(config.get<string>('server.trace', 'off')),
      outputChannel: outputChannel!,
      restartOnCrash: config.get<boolean>('server.restartOnCrash', true),
    });
  }

  if (isFeatureEnabled(config, 'folding')) {
    context.subscriptions.push(
      vscode.languages.registerFoldingRangeProvider(
        { scheme: 'file', language: 'sx' },
        new ShuxFoldingRangeProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'codeLens')) {
    const provider = new ShuxCodeLensProvider();
    codeLensProvider = provider;
    context.subscriptions.push(
      vscode.languages.registerCodeLensProvider({ scheme: 'file', language: 'sx' }, provider)
    );
  }

  context.subscriptions.push(
    vscode.tasks.registerTaskProvider(ShuxTaskProvider.ShuxType, new ShuxTaskProvider())
  );

  if (isFeatureEnabled(config, 'formatOnType')) {
    context.subscriptions.push(
      vscode.languages.registerOnTypeFormattingEditProvider(
        { scheme: 'file', language: 'sx' },
        new ShuxOnTypeFormattingProvider(),
        '{',
        '\n',
        '}',
        ':'
      )
    );
  }

  if (isFeatureEnabled(config, 'documentLinks')) {
    context.subscriptions.push(
      vscode.languages.registerDocumentLinkProvider(
        { scheme: 'file', language: 'sx' },
        new ShuxDocumentLinkProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'statusBar')) {
    registerShuxStatusBar(context);
    refreshShuxStatusBar(vscode.window.activeTextEditor);
    context.subscriptions.push(
      vscode.window.onDidChangeActiveTextEditor((e) => refreshShuxStatusBar(e)),
      vscode.workspace.onDidChangeTextDocument((e) => {
        if (e.document.languageId === 'sx') {
          refreshShuxStatusBar(vscode.window.activeTextEditor);
        }
      })
    );
  }

  if (isFeatureEnabled(config, 'selectionRange')) {
    context.subscriptions.push(
      vscode.languages.registerSelectionRangeProvider(
        { scheme: 'file', language: 'sx' },
        createShuxSelectionRangeProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'formatOnBlur')) {
    let lastSxEditor: vscode.TextEditor | undefined;
    let initialized = false;
    setTimeout(() => {
      initialized = true;
    }, 500);

    context.subscriptions.push(
      vscode.window.onDidChangeActiveTextEditor(async (editor) => {
        const prev = lastSxEditor;
        lastSxEditor = editor?.document.languageId === 'sx' ? editor : undefined;
        if (!initialized || !prev || prev.document.isClosed || prev === editor) {
          return;
        }
        await formatSuDocument(prev.document);
      })
    );
  }

  registerConfigurationListener(context);
  heavyFeaturesReady = true;
  outputChannel?.appendLine('[Shux] 编辑器增强与 LSP 已就绪。');
}

function ensureHeavyFeatures(context: vscode.ExtensionContext): Promise<void> {
  if (heavyFeaturesReady) {
    return Promise.resolve();
  }
  if (!heavyFeaturesPromise) {
    heavyFeaturesPromise = loadHeavyFeatures(context).catch((err: unknown) => {
      heavyFeaturesPromise = undefined;
      const message = err instanceof Error ? err.message : String(err);
      outputChannel?.appendLine(`[Shux] 加载编辑器功能失败: ${message}`);
      throw err;
    });
  }
  return heavyFeaturesPromise;
}

function registerConfigurationListener(context: vscode.ExtensionContext): void {
  serverConfigSnapshot = snapshotServerConfig();

  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (!e.affectsConfiguration('shux')) {
        return;
      }

      if (configChangeDebounce) {
        clearTimeout(configChangeDebounce);
      }

      configChangeDebounce = setTimeout(() => {
        configChangeDebounce = undefined;

        const newSnapshot = snapshotServerConfig();
        if (newSnapshot === serverConfigSnapshot) {
          return;
        }

        const prevSnapshot = serverConfigSnapshot;
        serverConfigSnapshot = newSnapshot;
        outputChannel?.appendLine('[Shux] 检测到配置变更，正在应用...');

        const newConfig = vscode.workspace.getConfiguration('shux');
        const prev = JSON.parse(prevSnapshot ?? '{}') as Record<string, unknown>;
        const nextExtraArgs = readExtraArgsSetting(newConfig);
        const nextLibRoots = readLibRootsSetting(newConfig);

        if (prev.trace !== newConfig.get<string>('server.trace', 'off')) {
          client?.setTrace(traceFromString(newConfig.get<string>('server.trace', 'off')));
        }

        if (
          JSON.stringify(prev.extraArgs) !== JSON.stringify(nextExtraArgs) ||
          JSON.stringify(prev.libRoots) !== JSON.stringify(nextLibRoots) ||
          e.affectsConfiguration('shux.compiler') ||
          e.affectsConfiguration('shux.features')
        ) {
          codeLensProvider?.refresh();
        }

        const restartKeysChanged =
          prev.serverPath !== newConfig.get<string>('serverPath', DEFAULT_SERVER_PATH) ||
          JSON.stringify(prev.extraArgs) !== JSON.stringify(nextExtraArgs) ||
          JSON.stringify(prev.libRoots) !== JSON.stringify(nextLibRoots) ||
          prev.diagnosticLevel !== newConfig.get<string>('compiler.diagnosticLevel', 'warning') ||
          prev.targetDir !== newConfig.get<string>('compiler.targetDir', '') ||
          JSON.stringify(prev.envJson) !== JSON.stringify(readEnvJsonSetting(newConfig)) ||
          prev.restartOnCrash !== newConfig.get<boolean>('server.restartOnCrash', true);

        if (restartKeysChanged) {
          void vscode.window
            .showInformationMessage(
              'Shux 服务端配置已变更，需要重启语言服务才能生效。',
              '立即重启',
              '稍后'
            )
            .then((selection) => {
              if (selection === '立即重启') {
                void vscode.commands.executeCommand('shux.restartServer');
              }
            });
        }
      }, 500);
    })
  );
}

async function openShuxSettingsSafe(): Promise<void> {
  const ws = vscode.workspace.workspaceFolders?.[0];
  if (ws) {
    const settingsUri = vscode.Uri.joinPath(ws.uri, '.vscode', 'settings.json');
    try {
      const doc = await vscode.workspace.openTextDocument(settingsUri);
      await vscode.window.showTextDocument(doc, { preview: false });
      return;
    } catch {
      // fall through
    }
  }
  await vscode.commands.executeCommand('workbench.action.openSettings', 'shux');
}

function registerCommands(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('shux.openSettings', () => {
      void openShuxSettingsSafe();
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shux.restartServer', async () => {
      await ensureHeavyFeatures(context);
      try {
        const wf = vscode.workspace.workspaceFolders?.[0];
        if (!wf) {
          vscode.window.showWarningMessage('请先 Open Folder 打开工作区后再重启 LSP。');
          return;
        }
        outputChannel?.appendLine('[Shux] 正在重启语言服务...');
        await stopShuxLanguageClient(client);
        const config = vscode.workspace.getConfiguration('shux');
        client = await startShuxLanguageClient({
          command: resolveServerCommand(config.get<string>('serverPath', DEFAULT_SERVER_PATH)),
          args: buildServerArgs(),
          cwd: wf.uri.fsPath,
          env: buildServerEnv(),
          trace: traceFromString(config.get<string>('server.trace', 'off')),
          outputChannel: outputChannel!,
          restartOnCrash: config.get<boolean>('server.restartOnCrash', true),
        });
        outputChannel?.appendLine('[Shux] 语言服务已重启。');
        vscode.window.showInformationMessage('Shux 语言服务已重启');
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : String(err);
        outputChannel?.appendLine(`[Shux] 重启失败: ${message}`);
        vscode.window.showErrorMessage(`Shux 重启失败: ${message}`);
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shux.showServerOutput', () => {
      outputChannel?.show(true);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shux.refreshCodeLens', async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.document.languageId !== 'sx') {
        vscode.window.showWarningMessage('请先打开一个 .sx 文件。');
        return;
      }
      await ensureHeavyFeatures(context);
      codeLensProvider?.refresh();
      vscode.window.showInformationMessage('Shux CodeLens 已刷新。');
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shux.runFile', async (uri?: vscode.Uri) => {
      const { ShuxTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const targetUri = uri ?? vscode.window.activeTextEditor?.document.uri;
      if (!targetUri) {
        vscode.window.showWarningMessage('没有打开的文件可运行。');
        return;
      }
      const cfg = vscode.workspace.getConfiguration('shux');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', DEFAULT_SERVER_PATH));

      const task = new vscode.Task(
        { type: ShuxTaskProvider.ShuxType, task: 'run-codelens' },
        vscode.TaskScope.Workspace,
        `shux run ${path.basename(targetUri.fsPath)}`,
        'Shux',
        new vscode.ProcessExecution(cmd, ['run', targetUri.fsPath], {
          cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? path.dirname(targetUri.fsPath),
        })
      );
      task.presentationOptions = {
        reveal: vscode.TaskRevealKind.Always,
        panel: vscode.TaskPanelKind.Dedicated,
        clear: false,
      };
      await vscode.tasks.executeTask(task);
    })
  );
}

function scheduleHeavyFeaturesOnSu(context: vscode.ExtensionContext): void {
  const tryLoad = (): void => {
    void ensureHeavyFeatures(context);
  };

  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument((doc) => {
      if (doc.languageId === 'sx') {
        tryLoad();
      }
    }),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (editor?.document.languageId === 'sx') {
        tryLoad();
      }
    })
  );

  if (
    vscode.window.activeTextEditor?.document.languageId === 'sx' ||
    vscode.workspace.textDocuments.some((d) => d.languageId === 'sx')
  ) {
    tryLoad();
  }
}

export function activate(context: vscode.ExtensionContext): void {
  outputChannel = vscode.window.createOutputChannel('Shux');
  outputChannel.appendLine('[Shux] 扩展正在激活（轻量模式）...');
  registerCommands(context);
  scheduleHeavyFeaturesOnSu(context);
  outputChannel.appendLine('[Shux] 扩展已激活。打开 .sx 文件时将立即加载 LSP。');
}

export function deactivate(): Thenable<void> | undefined {
  if (configChangeDebounce) {
    clearTimeout(configChangeDebounce);
    configChangeDebounce = undefined;
  }
  outputChannel?.appendLine('[Shux] 扩展已停用。');
  outputChannel?.dispose();
  return stopShuxLanguageClient(client);
}
