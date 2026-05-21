/**
 * Shulang VSCode 扩展入口 — LSP 客户端 + 编辑器增强
 *
 * 激活策略（避免「打开 Shulang 设置」卡死）：
 * 1. activate() 只注册命令，绝不同步启动 LSP/Provider；
 * 2. 打开/聚焦 .su 文件时立即加载 LSP/Provider（无延迟）；
 * 3. openSettings 使用文本搜索 "shulang" 或打开 settings.json，禁止 @id:/@ext: 过滤；
 * 4. LSP 不注册全仓库 .su 文件监视器，避免大仓库阻塞扩展宿主。
 */

import * as path from 'path';
import * as vscode from 'vscode';
import type { LanguageClient, Trace } from 'vscode-languageclient/node';

import { resolveServerCommand } from './shuPath';

let client: LanguageClient | undefined;
let outputChannel: vscode.OutputChannel | undefined;
let codeLensProvider: { refresh(): void } | undefined;

/** 重型功能是否已加载 */
let heavyFeaturesReady = false;
/** 重型功能加载 Promise */
let heavyFeaturesPromise: Promise<void> | undefined;
/** 配置变更防抖 */
let configChangeDebounce: ReturnType<typeof setTimeout> | undefined;
/** 服务端配置快照 */
let serverConfigSnapshot: string | undefined;

/** 将 shulang.server.trace 映射为 LanguageClient Trace */
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

/** 读取 shulang.compiler.envJson，构造进程 env */
function buildServerEnv(): Record<string, string> | undefined {
  const config = vscode.workspace.getConfiguration('shulang');
  const raw = config.get<string>('compiler.envJson', '{}').trim();
  if (!raw || raw === '{}') {
    return undefined;
  }
  try {
    const envObj = JSON.parse(raw) as Record<string, string>;
    if (!envObj || typeof envObj !== 'object' || Object.keys(envObj).length === 0) {
      return undefined;
    }
    return { ...(process.env as Record<string, string>), ...envObj };
  } catch {
    outputChannel?.appendLine('[Shulang] compiler.envJson 不是合法 JSON，已忽略。');
    return undefined;
  }
}

/** 解析 shulang.compiler.extraArgs JSON 字符串为参数数组 */
function parseExtraArgs(config: vscode.WorkspaceConfiguration): string[] {
  const raw = config.get<string>('compiler.extraArgs', '[]').trim();
  if (!raw || raw === '[]') {
    return [];
  }
  try {
    const parsed = JSON.parse(raw) as unknown;
    if (!Array.isArray(parsed)) {
      return [];
    }
    return parsed.filter((item): item is string => typeof item === 'string');
  } catch {
    outputChannel?.appendLine('[Shulang] compiler.extraArgs 不是合法 JSON 数组，已忽略。');
    return [];
  }
}

/** 构造 shu --lsp 参数列表 */
function buildServerArgs(): string[] {
  const config = vscode.workspace.getConfiguration('shulang');
  const baseArgs = ['--lsp'];

  const diagnosticLevel = config.get<string>('compiler.diagnosticLevel', 'warning');
  if (diagnosticLevel !== 'warning') {
    baseArgs.push(`--diagnostic-level=${diagnosticLevel}`);
  }

  const targetDir = config.get<string>('compiler.targetDir', '');
  if (targetDir) {
    baseArgs.push(`--target-dir=${targetDir}`);
  }

  const extraArgs = parseExtraArgs(config);
  if (extraArgs.length > 0) {
    baseArgs.push(...extraArgs);
  }

  return baseArgs;
}

/** 读取 shulang.features.* 开关 */
function isFeatureEnabled(
  config: vscode.WorkspaceConfiguration,
  feature: string,
  defaultValue = true
): boolean {
  return config.get<boolean>(`features.${feature}`, defaultValue);
}

/** 序列化服务端配置快照 */
function snapshotServerConfig(): string {
  const config = vscode.workspace.getConfiguration('shulang');
  return JSON.stringify({
    serverPath: config.get<string>('serverPath', 'shu'),
    extraArgs: config.get<string>('compiler.extraArgs', '[]'),
    diagnosticLevel: config.get<string>('compiler.diagnosticLevel', 'warning'),
    targetDir: config.get<string>('compiler.targetDir', ''),
    envJson: config.get<string>('compiler.envJson', '{}'),
    trace: config.get<string>('server.trace', 'off'),
  });
}

/** 格式化 .su 文档（2 秒超时） */
async function formatSuDocument(document: vscode.TextDocument): Promise<void> {
  const config = vscode.workspace.getConfiguration('shulang');
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

/** 按需加载 Provider 与 LSP */
async function loadHeavyFeatures(context: vscode.ExtensionContext): Promise<void> {
  if (heavyFeaturesReady) {
    return;
  }

  const [
    { LanguageClient: LcCtor },
    { ShulangDocumentSymbolProvider },
    { ShulangFoldingRangeProvider },
    { ShulangHoverProvider },
    { ShulangCodeLensProvider },
    { ShulangSignatureHelpProvider },
    { ShulangCompletionItemProvider },
    { ShulangOnTypeFormattingProvider },
    { ShulangDocumentLinkProvider },
    { ShulangTaskProvider },
    { registerShulangStatusBar, refreshShulangStatusBar },
    { createShulangSelectionRangeProvider },
    { createShulangDefinitionProvider },
    { createShulangReferenceProvider },
  ] = await Promise.all([
    import('vscode-languageclient/node'),
    import('./symbols'),
    import('./folding'),
    import('./hover'),
    import('./codelens'),
    import('./signature'),
    import('./completion'),
    import('./formatting'),
    import('./links'),
    import('./tasks'),
    import('./statusbar'),
    import('./selection'),
    import('./definitions'),
    import('./references'),
  ]);

  const config = vscode.workspace.getConfiguration('shulang');

  if (isFeatureEnabled(config, 'symbols')) {
    context.subscriptions.push(
      vscode.languages.registerDocumentSymbolProvider(
        { scheme: 'file', language: 'su' },
        new ShulangDocumentSymbolProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'folding')) {
    context.subscriptions.push(
      vscode.languages.registerFoldingRangeProvider(
        { scheme: 'file', language: 'su' },
        new ShulangFoldingRangeProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'hover')) {
    context.subscriptions.push(
      vscode.languages.registerHoverProvider(
        { scheme: 'file', language: 'su' },
        new ShulangHoverProvider()
      )
    );
  }

  if (isFeatureEnabled(config, 'codeLens')) {
    const provider = new ShulangCodeLensProvider();
    codeLensProvider = provider;
    context.subscriptions.push(
      vscode.languages.registerCodeLensProvider(
        { scheme: 'file', language: 'su' },
        provider
      )
    );
  }

  context.subscriptions.push(
    vscode.tasks.registerTaskProvider(ShulangTaskProvider.ShulangType, new ShulangTaskProvider())
  );

  if (isFeatureEnabled(config, 'signatureHelp')) {
    context.subscriptions.push(
      vscode.languages.registerSignatureHelpProvider(
        { scheme: 'file', language: 'su' },
        new ShulangSignatureHelpProvider(),
        '(',
        ','
      )
    );
  }

  if (isFeatureEnabled(config, 'completion')) {
    context.subscriptions.push(
      vscode.languages.registerCompletionItemProvider(
        { scheme: 'file', language: 'su' },
        new ShulangCompletionItemProvider(),
        '.',
        ':',
        '('
      )
    );
  }

  if (isFeatureEnabled(config, 'formatOnType')) {
    context.subscriptions.push(
      vscode.languages.registerOnTypeFormattingEditProvider(
        { scheme: 'file', language: 'su' },
        new ShulangOnTypeFormattingProvider(),
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
        { scheme: 'file', language: 'su' },
        new ShulangDocumentLinkProvider()
      )
    );
  }

  // DefinitionProvider — LSP 跳转定义的本地回退
  context.subscriptions.push(
    vscode.languages.registerDefinitionProvider(
      { scheme: 'file', language: 'su' },
      createShulangDefinitionProvider()
    )
  );

  // ReferenceProvider — LSP 引用查找的本地回退
  context.subscriptions.push(
    vscode.languages.registerReferenceProvider(
      { scheme: 'file', language: 'su' },
      createShulangReferenceProvider()
    )
  );

  if (isFeatureEnabled(config, 'statusBar')) {
    registerShulangStatusBar(context);
    refreshShulangStatusBar(vscode.window.activeTextEditor);
    context.subscriptions.push(
      vscode.window.onDidChangeActiveTextEditor((e) => refreshShulangStatusBar(e)),
      vscode.workspace.onDidChangeTextDocument((e) => {
        if (e.document.languageId === 'su') {
          refreshShulangStatusBar(vscode.window.activeTextEditor);
        }
      })
    );
  }

  if (isFeatureEnabled(config, 'selectionRange')) {
    context.subscriptions.push(
      vscode.languages.registerSelectionRangeProvider(
        { scheme: 'file', language: 'su' },
        createShulangSelectionRangeProvider()
      )
    );
  }

  if (vscode.workspace.workspaceFolders?.[0]) {
    const serverPath = config.get<string>('serverPath', 'shu');
    const command = resolveServerCommand(serverPath);
    const args = buildServerArgs();
    const env = buildServerEnv();
    const traceLevel = traceFromString(config.get<string>('server.trace', 'off'));

    client = new LcCtor(
      'shulang',
      'Shulang Language Server',
      {
        command,
        args,
        options: {
          cwd: vscode.workspace.workspaceFolders[0].uri.fsPath,
          env,
        },
      },
      {
        documentSelector: [{ scheme: 'file', language: 'su' }],
        outputChannel,
        traceOutputChannel: outputChannel,
      }
    );

    client.setTrace(traceLevel);
    try {
      await client.start();
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      outputChannel?.appendLine(`[Shulang] LSP 启动失败: ${message}`);
    }
  } else {
    outputChannel?.appendLine('[Shulang] 无工作区，跳过 LSP 启动。');
  }

  if (isFeatureEnabled(config, 'formatOnBlur')) {
    let lastSuEditor: vscode.TextEditor | undefined;
    let initialized = false;
    setTimeout(() => {
      initialized = true;
    }, 500);

    context.subscriptions.push(
      vscode.window.onDidChangeActiveTextEditor(async (editor) => {
        const prev = lastSuEditor;
        lastSuEditor = editor?.document.languageId === 'su' ? editor : undefined;
        if (!initialized || !prev || prev.document.isClosed || prev === editor) {
          return;
        }
        await formatSuDocument(prev.document);
      })
    );
  }

  registerConfigurationListener(context);
  heavyFeaturesReady = true;
  outputChannel?.appendLine('[Shulang] 编辑器增强与 LSP 已就绪。');
}

/** 确保重型功能已加载 */
function ensureHeavyFeatures(context: vscode.ExtensionContext): Promise<void> {
  if (heavyFeaturesReady) {
    return Promise.resolve();
  }
  if (!heavyFeaturesPromise) {
    heavyFeaturesPromise = loadHeavyFeatures(context).catch((err: unknown) => {
      heavyFeaturesPromise = undefined;
      const message = err instanceof Error ? err.message : String(err);
      outputChannel?.appendLine(`[Shulang] 加载编辑器功能失败: ${message}`);
      throw err;
    });
  }
  return heavyFeaturesPromise;
}

/** 配置变更监听（LSP 就绪后注册） */
function registerConfigurationListener(context: vscode.ExtensionContext): void {
  serverConfigSnapshot = snapshotServerConfig();

  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (!e.affectsConfiguration('shulang')) {
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
        outputChannel?.appendLine('[Shulang] 检测到配置变更，正在应用...');

        const newConfig = vscode.workspace.getConfiguration('shulang');
        const prev = JSON.parse(prevSnapshot ?? '{}') as Record<string, unknown>;

        if (prev.trace !== newConfig.get<string>('server.trace', 'off')) {
          client?.setTrace(traceFromString(newConfig.get<string>('server.trace', 'off')));
        }

        if (
          prev.extraArgs !== newConfig.get<string>('compiler.extraArgs', '[]') ||
          e.affectsConfiguration('shulang.compiler')
        ) {
          codeLensProvider?.refresh();
        }

        const restartKeysChanged =
          prev.serverPath !== newConfig.get<string>('serverPath', 'shu') ||
          prev.extraArgs !== newConfig.get<string>('compiler.extraArgs', '[]') ||
          prev.diagnosticLevel !== newConfig.get<string>('compiler.diagnosticLevel', 'warning') ||
          prev.targetDir !== newConfig.get<string>('compiler.targetDir', '') ||
          prev.envJson !== newConfig.get<string>('compiler.envJson', '{}');

        if (restartKeysChanged) {
          void vscode.window
            .showInformationMessage(
              'Shulang 服务端配置已变更，需要重启语言服务才能生效。',
              '立即重启',
              '稍后'
            )
            .then((selection) => {
              if (selection === '立即重启') {
                void vscode.commands.executeCommand('shulang.restartServer');
              }
            });
        }
      }, 500);
    })
  );
}

/**
 * 打开 Shulang 相关设置（安全路径，避免 @id:/@ext: 过滤器导致设置 UI 卡死）。
 * 优先打开工作区 .vscode/settings.json；否则用纯文本搜索 "shulang"。
 */
async function openShulangSettingsSafe(): Promise<void> {
  const ws = vscode.workspace.workspaceFolders?.[0];
  if (ws) {
    const settingsUri = vscode.Uri.joinPath(ws.uri, '.vscode', 'settings.json');
    try {
      const doc = await vscode.workspace.openTextDocument(settingsUri);
      await vscode.window.showTextDocument(doc, { preview: false });
      return;
    } catch {
      // 文件不存在时 fall through
    }
  }

  // 纯文本搜索，不用 @id: / @ext: 特殊语法
  await vscode.commands.executeCommand('workbench.action.openSettings', 'shulang');
}

/** 注册扩展命令（轻量） */
function registerCommands(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('shulang.openSettings', () => {
      void openShulangSettingsSafe();
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shulang.restartServer', async () => {
      await ensureHeavyFeatures(context);
      try {
        if (client) {
          outputChannel?.appendLine('[Shulang] 正在重启语言服务...');
          await client.stop();
          await client.start();
          outputChannel?.appendLine('[Shulang] 语言服务已重启。');
          vscode.window.showInformationMessage('Shulang 语言服务已重启');
        }
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : String(err);
        outputChannel?.appendLine(`[Shulang] 重启失败: ${message}`);
        vscode.window.showErrorMessage(`Shulang 重启失败: ${message}`);
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shulang.showServerOutput', () => {
      outputChannel?.show(true);
    })
  );

  // 刷新 CodeLens：强制重新计算行内提示（▶ Run、fn、fields 等）
  context.subscriptions.push(
    vscode.commands.registerCommand('shulang.refreshCodeLens', async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.document.languageId !== 'su') {
        vscode.window.showWarningMessage(
          '请先打开一个 .su 文件。CodeLens 会显示在函数/结构体/枚举定义行的上方。'
        );
        return;
      }

      const codeLensEnabled = vscode.workspace
        .getConfiguration('editor', editor.document.uri)
        .get<boolean>('codeLens', true);
      if (!codeLensEnabled) {
        vscode.window.showWarningMessage(
          '编辑器 CodeLens 已关闭。请在设置中开启 editor.codeLens 后重试。'
        );
        return;
      }

      try {
        await ensureHeavyFeatures(context);
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : String(err);
        vscode.window.showErrorMessage(`Shulang 加载失败，无法刷新 CodeLens: ${message}`);
        return;
      }

      if (!codeLensProvider) {
        vscode.window.showWarningMessage(
          'Shulang CodeLens 未启用。请在 settings.json 中设置 "shulang.features.codeLens": true'
        );
        return;
      }

      codeLensProvider.refresh();
      vscode.window.showInformationMessage(
        'Shulang CodeLens 已刷新。请查看 .su 文件中 function / struct / enum 行上方的灰色小字。'
      );
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('shulang.runFile', async (uri?: vscode.Uri) => {
      const { ShulangTaskProvider } = await import('./tasks');
      await ensureHeavyFeatures(context);

      const targetUri = uri ?? vscode.window.activeTextEditor?.document.uri;
      if (!targetUri) {
        vscode.window.showWarningMessage('没有打开的文件可运行。');
        return;
      }
      const cfg = vscode.workspace.getConfiguration('shulang');
      const cmd = resolveServerCommand(cfg.get<string>('serverPath', 'shu'));

      const task = new vscode.Task(
        { type: ShulangTaskProvider.ShulangType, task: 'run-codelens' },
        vscode.TaskScope.Workspace,
        `shu run ${path.basename(targetUri.fsPath)}`,
        'Shulang',
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

/**
 * 在打开或聚焦 .su 文件时加载 LSP/Provider（无额外延迟，打开即启动）。
 */
function scheduleHeavyFeaturesOnSu(context: vscode.ExtensionContext): void {
  const tryLoad = (): void => {
    void ensureHeavyFeatures(context);
  };

  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument((doc) => {
      if (doc.languageId === 'su') {
        tryLoad();
      }
    }),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      if (editor?.document.languageId === 'su') {
        tryLoad();
      }
    })
  );

  if (
    vscode.window.activeTextEditor?.document.languageId === 'su' ||
    vscode.workspace.textDocuments.some((d) => d.languageId === 'su')
  ) {
    tryLoad();
  }
}

export function activate(context: vscode.ExtensionContext): void {
  outputChannel = vscode.window.createOutputChannel('Shulang');
  outputChannel.appendLine('[Shulang] 扩展正在激活（轻量模式）...');

  registerCommands(context);
  scheduleHeavyFeaturesOnSu(context);

  outputChannel.appendLine('[Shulang] 扩展已激活。打开 .su 文件时将立即加载 LSP。');
}

export function deactivate(): Thenable<void> | undefined {
  if (configChangeDebounce) {
    clearTimeout(configChangeDebounce);
    configChangeDebounce = undefined;
  }
  outputChannel?.appendLine('[Shulang] 扩展已停用。');
  outputChannel?.dispose();
  return client?.stop();
}
