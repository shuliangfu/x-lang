/**
 * Xlang VSCode 扩展入口 — LSP 客户端 + 编辑器增强
 *
 * 诊断 / 跳转 / 补全 / 悬停 / 格式化 / 大纲：仅走 xlang --lsp，不注册本地 LSP 回退 Provider。
 */

import * as path from 'path';
import * as vscode from 'vscode';
import type { LanguageClient, Trace } from 'vscode-languageclient/node';

import { readEnvJsonSetting, readExtraArgsSetting, readLibRootsSetting } from './configSettings';
import { getLibRootsEnvColon } from './importResolve';
import { startXlangLanguageClient, stopXlangLanguageClient } from './lspClient';
import { DEFAULT_SERVER_PATH, resolveServerCommand } from './xlangPath';
import { t, initI18n, onLocaleConfigChanged } from './i18n';
import { XlangWorkspaceSymbolProvider, invalidateWorkspaceSymbolCache } from './workspaceSymbol';
import { refreshXlangStatusBar } from './statusbar';

let client: LanguageClient | undefined;
let outputChannel: vscode.OutputChannel | undefined;
let codeLensProvider: { refresh(): void } | undefined;

let heavyFeaturesReady = false;
let heavyFeaturesPromise: Promise<void> | undefined;
let configChangeDebounce: ReturnType<typeof setTimeout> | undefined;
let serverConfigSnapshot: string | undefined;

/** 将 xlang.server.trace 映射为 LanguageClient Trace */
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

/** 读取 xlang.compiler.envJson 与 libRoots，构造 LSP 进程 env */
function buildServerEnv(): Record<string, string> | undefined {
  const config = vscode.workspace.getConfiguration('xlang');
  const env: Record<string, string> = { ...(process.env as Record<string, string>) };
  env.XLANG_LSP_LIB_ROOTS = getLibRootsEnvColon();

  const envObj = readEnvJsonSetting(config, outputChannel);
  if (Object.keys(envObj).length > 0) {
    Object.assign(env, envObj);
  }
  return env;
}

/** 构造 xlang --lsp 参数列表 */
function buildServerArgs(): string[] {
  const config = vscode.workspace.getConfiguration('xlang');
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
  const config = vscode.workspace.getConfiguration('xlang');
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

/** 格式化 .x 文档（走 LSP documentFormattingProvider） */
async function formatSuDocument(document: vscode.TextDocument): Promise<void> {
  const config = vscode.workspace.getConfiguration('xlang');
  if (!config.get<boolean>('format.enabled', true)) {
    return;
  }

  const options: vscode.FormattingOptions = {
    tabSize: config.get<number>('format.tabSize', 2),
    insertSpaces: config.get<boolean>('format.insertSpaces', true),
  };
  // 注入 maxLineLength 给 LSP formatter（LSP 服务端从 formatting options body 读取此字段）
  (options as Record<string, unknown>).maxLineLength = config.get<number>('format.maxLineLength', 100);

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
    { XlangFoldingRangeProvider },
    { XlangCodeLensProvider },
    { XlangOnTypeFormattingProvider },
    { XlangDocumentLinkProvider },
    { XlangTaskProvider },
    { registerXlangStatusBar, refreshXlangStatusBar },
    { createXlangSelectionRangeProvider },
  ] = await Promise.all([
    import('./folding'),
    import('./codelens'),
    import('./formatting'),
    import('./links'),
    import('./tasks'),
    import('./statusbar'),
    import('./selection'),
  ]);

  const config = vscode.workspace.getConfiguration('xlang');
  const workspaceFolder = vscode.workspace.workspaceFolders?.[0];

  if (!workspaceFolder) {
    outputChannel?.appendLine(
      t('[Xlang] No workspace folder: LSP not started. Open Folder to the xlang repo root to enable diagnostics.')
    );
    void vscode.window.showWarningMessage(
      t('Xlang requires a folder to start the language service (diagnostics, jump, etc.). Open Folder to the project root.')
    );
  } else {
    const serverPath = config.get<string>('serverPath', DEFAULT_SERVER_PATH);
    client = await startXlangLanguageClient({
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
        { scheme: 'file', language: 'x' },
        new XlangFoldingRangeProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'codeLens')) {
    const provider = new XlangCodeLensProvider();
    codeLensProvider = provider;
    context.subscriptions.push(
      vscode.languages.registerCodeLensProvider({ scheme: 'file', language: 'x' }, provider)
    );
  }

  context.subscriptions.push(
    vscode.tasks.registerTaskProvider(XlangTaskProvider.XlangType, new XlangTaskProvider())
  );

  if (isFeatureEnabled(config, 'formatOnType')) {
    context.subscriptions.push(
      vscode.languages.registerOnTypeFormattingEditProvider(
        { scheme: 'file', language: 'x' },
        new XlangOnTypeFormattingProvider(),
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
        { scheme: 'file', language: 'x' },
        new XlangDocumentLinkProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'statusBar')) {
    registerXlangStatusBar(context);
    refreshXlangStatusBar(vscode.window.activeTextEditor);
    context.subscriptions.push(
      vscode.window.onDidChangeActiveTextEditor((e) => refreshXlangStatusBar(e)),
      vscode.workspace.onDidChangeTextDocument((e) => {
        if (e.document.languageId === 'x') {
          refreshXlangStatusBar(vscode.window.activeTextEditor);
        }
      })
    );
  }

  if (isFeatureEnabled(config, 'selectionRange')) {
    context.subscriptions.push(
      vscode.languages.registerSelectionRangeProvider(
        { scheme: 'file', language: 'x' },
        createXlangSelectionRangeProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'documentHighlight')) {
    const { XlangDocumentHighlightProvider } = await import('./documentHighlight');
    context.subscriptions.push(
      vscode.languages.registerDocumentHighlightProvider(
        { scheme: 'file', language: 'x' },
        new XlangDocumentHighlightProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'codeAction')) {
    const { XlangCodeActionProvider } = await import('./codeAction');
    context.subscriptions.push(
      vscode.languages.registerCodeActionsProvider(
        { scheme: 'file', language: 'x' },
        new XlangCodeActionProvider(),
        { providedCodeActionKinds: [vscode.CodeActionKind.QuickFix, vscode.CodeActionKind.Refactor] }
      )
    );
  }

  /** 全局符号搜索（Ctrl+T）— 扩展侧本地实现，受 xlang.features.workspaceSymbol 开关控制 */
  if (isFeatureEnabled(config, 'workspaceSymbol')) {
    context.subscriptions.push(
      vscode.languages.registerWorkspaceSymbolProvider(new XlangWorkspaceSymbolProvider())
    );

    /** .x 文件保存时失效符号缓存，确保 Ctrl+T 搜索结果最新 */
    context.subscriptions.push(
      vscode.workspace.onDidSaveTextDocument((doc) => {
        if (doc.languageId === 'x') {
          invalidateWorkspaceSymbolCache(doc.uri);
        }
      })
    );
  }

  registerConfigurationListener(context);
  heavyFeaturesReady = true;
  outputChannel?.appendLine(t('[Xlang] Editor enhancements and LSP are ready.'));
}

function ensureHeavyFeatures(context: vscode.ExtensionContext): Promise<void> {
  if (heavyFeaturesReady) {
    return Promise.resolve();
  }
  if (!heavyFeaturesPromise) {
    heavyFeaturesPromise = loadHeavyFeatures(context).catch((err: unknown) => {
      heavyFeaturesPromise = undefined;
      const message = err instanceof Error ? err.message : String(err);
      outputChannel?.appendLine(t('[Xlang] Failed to load editor features: {0}', message));
      throw err;
    });
  }
  return heavyFeaturesPromise;
}

function registerConfigurationListener(context: vscode.ExtensionContext): void {
  serverConfigSnapshot = snapshotServerConfig();

  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (!e.affectsConfiguration('xlang')) {
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
        outputChannel?.appendLine(t('[Xlang] Configuration change detected, applying...'));

        const newConfig = vscode.workspace.getConfiguration('xlang');
        const prev = JSON.parse(prevSnapshot ?? '{}') as Record<string, unknown>;
        const nextExtraArgs = readExtraArgsSetting(newConfig);
        const nextLibRoots = readLibRootsSetting(newConfig);

        if (prev.trace !== newConfig.get<string>('server.trace', 'off')) {
          client?.setTrace(traceFromString(newConfig.get<string>('server.trace', 'off')));
        }

        if (
          JSON.stringify(prev.extraArgs) !== JSON.stringify(nextExtraArgs) ||
          JSON.stringify(prev.libRoots) !== JSON.stringify(nextLibRoots) ||
          e.affectsConfiguration('xlang.compiler') ||
          e.affectsConfiguration('xlang.features')
        ) {
          codeLensProvider?.refresh();
          /** features.statusBar* 子开关变更时刷新状态栏显示 */
          refreshXlangStatusBar(vscode.window.activeTextEditor);
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
          const restartBtn = t('Restart Now');
          const laterBtn = t('Later');
          void vscode.window
            .showInformationMessage(
              t('Xlang server config changed. Restart the language service to apply.'),
              restartBtn,
              laterBtn
            )
            .then((selection) => {
              if (selection === restartBtn) {
                void vscode.commands.executeCommand('xlang.restartServer');
              }
            });
        }
      }, 500);
    })
  );
}

async function openXlangSettingsSafe(): Promise<void> {
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
  await vscode.commands.executeCommand('workbench.action.openSettings', 'xlang');
}

function registerCommands(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.openSettings', () => {
      void openXlangSettingsSafe();
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.restartServer', async () => {
      await ensureHeavyFeatures(context);
      try {
        const wf = vscode.workspace.workspaceFolders?.[0];
        if (!wf) {
          vscode.window.showWarningMessage(t('Please Open Folder to open a workspace before restarting LSP.'));
          return;
        }
        outputChannel?.appendLine(t('[Xlang] Restarting language server...'));
        await stopXlangLanguageClient(client);
        const config = vscode.workspace.getConfiguration('xlang');
        client = await startXlangLanguageClient({
          command: resolveServerCommand(config.get<string>('serverPath', DEFAULT_SERVER_PATH)),
          args: buildServerArgs(),
          cwd: wf.uri.fsPath,
          env: buildServerEnv(),
          trace: traceFromString(config.get<string>('server.trace', 'off')),
          outputChannel: outputChannel!,
          restartOnCrash: config.get<boolean>('server.restartOnCrash', true),
        });
        outputChannel?.appendLine(t('[Xlang] Language server restarted.'));
        vscode.window.showInformationMessage(t('Xlang language service restarted.'));
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : String(err);
        outputChannel?.appendLine(t('[Xlang] Restart failed: {0}', message));
        vscode.window.showErrorMessage(t('Xlang restart failed: {0}', message));
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.showServerOutput', () => {
      outputChannel?.show(true);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.refreshCodeLens', async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.document.languageId !== 'x') {
        vscode.window.showWarningMessage(t('Please open a .x file first.'));
        return;
      }
      await ensureHeavyFeatures(context);
      codeLensProvider?.refresh();
      vscode.window.showInformationMessage(t('Xlang CodeLens refreshed.'));
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.runFile', async (uri?: vscode.Uri) => {
      const { XlangTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const targetUri = uri ?? vscode.window.activeTextEditor?.document.uri;
      if (!targetUri) {
        vscode.window.showWarningMessage(t('No file to run.'));
        return;
      }
      const cfg = vscode.workspace.getConfiguration('xlang');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', DEFAULT_SERVER_PATH));

      const task = new vscode.Task(
        { type: XlangTaskProvider.XlangType, task: 'run-codelens' },
        vscode.TaskScope.Workspace,
        `xlang run ${path.basename(targetUri.fsPath)}`,
        'Xlang',
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

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.buildFile', async (uri?: vscode.Uri) => {
      const { XlangTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const targetUri = uri ?? vscode.window.activeTextEditor?.document.uri;
      if (!targetUri) {
        vscode.window.showWarningMessage(t('No file to build.'));
        return;
      }
      const cfg = vscode.workspace.getConfiguration('xlang');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', DEFAULT_SERVER_PATH));

      const task = new vscode.Task(
        { type: XlangTaskProvider.XlangType, task: 'build-file' },
        vscode.TaskScope.Workspace,
        `xlang build ${path.basename(targetUri.fsPath)}`,
        'Xlang',
        new vscode.ProcessExecution(cmd, ['build', targetUri.fsPath], {
          cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? path.dirname(targetUri.fsPath),
        })
      );
      task.group = vscode.TaskGroup.Build;
      task.presentationOptions = {
        reveal: vscode.TaskRevealKind.Always,
        panel: vscode.TaskPanelKind.Shared,
        clear: true,
      };
      task.problemMatchers = ['$xlang-parse', '$xlang-typeck'];
      await vscode.tasks.executeTask(task);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.checkFile', async (uri?: vscode.Uri) => {
      const { XlangTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const targetUri = uri ?? vscode.window.activeTextEditor?.document.uri;
      if (!targetUri) {
        vscode.window.showWarningMessage(t('No file to check.'));
        return;
      }
      const cfg = vscode.workspace.getConfiguration('xlang');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', DEFAULT_SERVER_PATH));

      const task = new vscode.Task(
        { type: XlangTaskProvider.XlangType, task: 'check' },
        vscode.TaskScope.Workspace,
        `xlang check ${path.basename(targetUri.fsPath)}`,
        'Xlang',
        new vscode.ProcessExecution(cmd, ['check', targetUri.fsPath], {
          cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? path.dirname(targetUri.fsPath),
        })
      );
      task.group = vscode.TaskGroup.Test;
      task.presentationOptions = {
        reveal: vscode.TaskRevealKind.Silent,
        panel: vscode.TaskPanelKind.Shared,
        clear: true,
      };
      task.problemMatchers = ['$xlang-parse', '$xlang-typeck'];
      await vscode.tasks.executeTask(task);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.buildProject', async () => {
      const { XlangTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const cfg = vscode.workspace.getConfiguration('xlang');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', DEFAULT_SERVER_PATH));

      const task = new vscode.Task(
        { type: XlangTaskProvider.XlangType, task: 'build' },
        vscode.TaskScope.Workspace,
        'xlang build',
        'Xlang',
        new vscode.ProcessExecution(cmd, ['build'], {
          cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
        })
      );
      task.group = vscode.TaskGroup.Build;
      task.presentationOptions = {
        reveal: vscode.TaskRevealKind.Always,
        panel: vscode.TaskPanelKind.Shared,
        clear: true,
      };
      task.problemMatchers = ['$xlang-parse', '$xlang-typeck'];
      await vscode.tasks.executeTask(task);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xlang.formatDocument', async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.document.languageId !== 'x') {
        vscode.window.showWarningMessage(t('Please open a .x file first.'));
        return;
      }
      await ensureHeavyFeatures(context);
      await formatSuDocument(editor.document);
    })
  );
}

function scheduleHeavyFeaturesOnSu(context: vscode.ExtensionContext): void {
  const tryLoad = (): void => {
    void ensureHeavyFeatures(context);
  };

  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument((doc) => {
      if (doc.languageId === 'x') {
        tryLoad();
      }
    }),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (editor?.document.languageId === 'x') {
        tryLoad();
      }
    })
  );

  if (
    vscode.window.activeTextEditor?.document.languageId === 'x' ||
    vscode.workspace.textDocuments.some((d) => d.languageId === 'x')
  ) {
    tryLoad();
  }
}

export function activate(context: vscode.ExtensionContext): void {
  outputChannel = vscode.window.createOutputChannel('Xlang');
  // 初始化 i18n（支持 xlang.locale 配置覆盖）
  initI18n(context);
  context.subscriptions.push(onLocaleConfigChanged(context));
  outputChannel.appendLine(t('[Xlang] Extension activating (lightweight mode)...'));
  registerCommands(context);
  scheduleHeavyFeaturesOnSu(context);
  outputChannel.appendLine(t('[Xlang] Extension activated. Open a .x file to load LSP immediately.'));
}

export function deactivate(): Thenable<void> | undefined {
  if (configChangeDebounce) {
    clearTimeout(configChangeDebounce);
    configChangeDebounce = undefined;
  }
  outputChannel?.appendLine(t('[Xlang] Extension deactivated.'));
  outputChannel?.dispose();
  return stopXlangLanguageClient(client);
}
