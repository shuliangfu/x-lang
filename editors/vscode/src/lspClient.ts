/**
 * Xlang LSP 客户端 — 启动前校验、Pull 诊断、崩溃自动重启。
 *
 * 诊断仅走 LSP textDocument/diagnostic（Pull），不做本地 xlang check 回退。
 */

import { spawnSync } from 'child_process';
import * as fs from 'fs';
import * as vscode from 'vscode';
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  State,
  Trace,
} from 'vscode-languageclient/node';
import { t } from './i18n';
import { setXlangLspStatus } from './statusbar';

/** 用户主动 stop / 扩展 deactivate 时为 true，避免误触发崩溃重启 */
let intentionalStop = false;

/** 启动 LSP 前的校验结果 */
export type XlangLspValidation =
  | { ok: true }
  | { ok: false; message: string };

/**
 * 校验 xlang 是否可作为语言服务器：存在、可执行、支持 --lsp（非 xlang-c）。
 * @param command 已 resolve 的 xlang 绝对/相对路径
 */
export function validateXlangLanguageServer(command: string): XlangLspValidation {
  if (!command.trim()) {
    return { ok: false, message: t('xlang.serverPath is empty. Set it to compiler/xlang or an absolute path to xlang.') };
  }

  if (!fs.existsSync(command)) {
    return {
      ok: false,
      message: t('{0} not found. Run in repo root: make -C compiler bootstrap-driver-seed', command),
    };
  }

  try {
    fs.accessSync(command, fs.constants.X_OK);
  } catch {
    return { ok: false, message: t('xlang is not executable: {0}', command) };
  }

  /** xlang --lsp 会阻塞读 stdin；超时说明进程正常进入 LSP 模式 */
  const probe = spawnSync(command, ['--lsp'], {
    encoding: 'utf8',
    timeout: 2000,
    input: '',
  });
  const combined = `${probe.stderr ?? ''}${probe.stdout ?? ''}`;
  if (combined.includes('unknown option') && combined.includes('--lsp')) {
    return {
      ok: false,
      message: t('Current xlang does not support --lsp (commonly xlang-c). Use bootstrap-built compiler/xlang as xlang.serverPath.'),
    };
  }

  const timedOut =
    probe.error !== undefined &&
    (probe.error as NodeJS.ErrnoException).code === 'ETIMEDOUT';
  if (timedOut || probe.signal === 'SIGTERM') {
    return { ok: true };
  }

  if (probe.status !== 0 && probe.status !== null) {
    return {
      ok: false,
      message: t('xlang --lsp probe exited abnormally (code {0}). See Xlang output channel.', probe.status),
    };
  }

  return { ok: true };
}

/** 构造 LanguageClient 实例（尚未 start） */
function createLanguageClient(
  serverOptions: ServerOptions,
  clientOptions: LanguageClientOptions
): LanguageClient {
  return new LanguageClient('xlang', 'Xlang Language Server', serverOptions, clientOptions);
}

/**
 * 启动 Xlang 语言服务；失败时弹窗并写 Output，返回 undefined。
 */
export async function startXlangLanguageClient(params: {
  command: string;
  args: string[];
  cwd: string;
  env: Record<string, string> | undefined;
  trace: Trace;
  outputChannel: vscode.OutputChannel;
  restartOnCrash: boolean;
}): Promise<LanguageClient | undefined> {
  const validation = validateXlangLanguageServer(params.command);
  if (!validation.ok) {
    params.outputChannel.appendLine(`[Xlang] ${validation.message}`);
    void vscode.window
      .showErrorMessage(t('Xlang language server failed to start: {0}', validation.message), t('Show Output'))
      .then((choice) => {
        if (choice === t('Show Output')) {
          params.outputChannel.show(true);
        }
      });
    return undefined;
  }

  intentionalStop = false;

  const serverOptions: ServerOptions = {
    command: params.command,
    args: params.args,
    options: {
      cwd: params.cwd,
      env: params.env,
    },
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [{ scheme: 'file', language: 'x' }],
    outputChannel: params.outputChannel,
    traceOutputChannel: params.outputChannel,
    /** Pull 诊断：编辑/切换标签页时向 xlang 请求 textDocument/diagnostic */
    diagnosticPullOptions: {
      onTabs: true,
    },
  };

  const client = createLanguageClient(serverOptions, clientOptions);
  client.setTrace(params.trace);

  client.onDidChangeState((event) => {
    /** 同步状态栏 LSP 连接指示器 */
    setXlangLspStatus(event.newState === State.Running);

    if (
      params.restartOnCrash &&
      !intentionalStop &&
      event.oldState === State.Running &&
      event.newState === State.Stopped
    ) {
      params.outputChannel.appendLine(t('[Xlang] Language server exited unexpectedly, auto-restarting...'));
      void client.start().catch((err: unknown) => {
        const message = err instanceof Error ? err.message : String(err);
        params.outputChannel.appendLine(t('[Xlang] Auto-restart failed: {0}', message));
      });
    }
  });

  try {
    await client.start();
    params.outputChannel.appendLine(
      t('[Xlang] Language service connected (Pull diagnostics: parse/typeck errors will show in Problems panel).')
    );
    return client;
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    params.outputChannel.appendLine(t('[Xlang] LSP start failed: {0}', message));
    void vscode.window.showErrorMessage(t('Xlang LSP start failed: {0}', message), t('Show Output')).then((choice) => {
      if (choice === t('Show Output')) {
        params.outputChannel.show(true);
      }
    });
    return undefined;
  }
}

/** 停止语言服务（标记为用户主动，不触发崩溃重启） */
export async function stopXlangLanguageClient(client: LanguageClient | undefined): Promise<void> {
  if (!client) {
    return;
  }
  intentionalStop = true;
  await client.stop();
}
