/**
 * Shux LSP 客户端 — 启动前校验、Pull 诊断、崩溃自动重启。
 *
 * 诊断仅走 LSP textDocument/diagnostic（Pull），不做本地 shux check 回退。
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

/** 用户主动 stop / 扩展 deactivate 时为 true，避免误触发崩溃重启 */
let intentionalStop = false;

/** 启动 LSP 前的校验结果 */
export type ShuxLspValidation =
  | { ok: true }
  | { ok: false; message: string };

/**
 * 校验 shux 是否可作为语言服务器：存在、可执行、支持 --lsp（非 shux-c）。
 * @param command 已 resolve 的 shux 绝对/相对路径
 */
export function validateShuxLanguageServer(command: string): ShuxLspValidation {
  if (!command.trim()) {
    return { ok: false, message: 'shux.serverPath 为空。请设置为 compiler/shux 或 shux 的绝对路径。' };
  }

  if (!fs.existsSync(command)) {
    return {
      ok: false,
      message: `未找到 ${command}。请在仓库根目录执行：make -C compiler bootstrap-driver-seed`,
    };
  }

  try {
    fs.accessSync(command, fs.constants.X_OK);
  } catch {
    return { ok: false, message: `shux 不可执行：${command}` };
  }

  /** shux --lsp 会阻塞读 stdin；超时说明进程正常进入 LSP 模式 */
  const probe = spawnSync(command, ['--lsp'], {
    encoding: 'utf8',
    timeout: 2000,
    input: '',
  });
  const combined = `${probe.stderr ?? ''}${probe.stdout ?? ''}`;
  if (combined.includes('unknown option') && combined.includes('--lsp')) {
    return {
      ok: false,
      message:
        '当前 shux 不支持 --lsp（常见为 shux-c）。请使用 bootstrap 构建的 compiler/shux 作为 shux.serverPath。',
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
      message: `shux --lsp 探针异常退出 (code ${probe.status})。详见 Shux 输出通道。`,
    };
  }

  return { ok: true };
}

/** 构造 LanguageClient 实例（尚未 start） */
function createLanguageClient(
  serverOptions: ServerOptions,
  clientOptions: LanguageClientOptions
): LanguageClient {
  return new LanguageClient('shux', 'Shux Language Server', serverOptions, clientOptions);
}

/**
 * 启动 Shux 语言服务；失败时弹窗并写 Output，返回 undefined。
 */
export async function startShuxLanguageClient(params: {
  command: string;
  args: string[];
  cwd: string;
  env: Record<string, string> | undefined;
  trace: Trace;
  outputChannel: vscode.OutputChannel;
  restartOnCrash: boolean;
}): Promise<LanguageClient | undefined> {
  const validation = validateShuxLanguageServer(params.command);
  if (!validation.ok) {
    params.outputChannel.appendLine(`[Shux] ${validation.message}`);
    void vscode.window
      .showErrorMessage(`Shux 语言服务无法启动：${validation.message}`, '显示输出')
      .then((choice) => {
        if (choice === '显示输出') {
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
    documentSelector: [{ scheme: 'file', language: 'sx' }],
    outputChannel: params.outputChannel,
    traceOutputChannel: params.outputChannel,
    /** Pull 诊断：编辑/切换标签页时向 shux 请求 textDocument/diagnostic */
    diagnosticPullOptions: {
      onTabs: true,
    },
  };

  const client = createLanguageClient(serverOptions, clientOptions);
  client.setTrace(params.trace);

  client.onDidChangeState((event) => {
    if (
      params.restartOnCrash &&
      !intentionalStop &&
      event.oldState === State.Running &&
      event.newState === State.Stopped
    ) {
      params.outputChannel.appendLine('[Shux] 语言服务意外退出，正在自动重启…');
      void client.start().catch((err: unknown) => {
        const message = err instanceof Error ? err.message : String(err);
        params.outputChannel.appendLine(`[Shux] 自动重启失败: ${message}`);
      });
    }
  });

  try {
    await client.start();
    params.outputChannel.appendLine(
      '[Shux] 语言服务已连接（Pull 诊断：parse/typeck 错误将显示在问题面板）。'
    );
    return client;
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    params.outputChannel.appendLine(`[Shux] LSP 启动失败: ${message}`);
    void vscode.window.showErrorMessage(`Shux LSP 启动失败: ${message}`, '显示输出').then((choice) => {
      if (choice === '显示输出') {
        params.outputChannel.show(true);
      }
    });
    return undefined;
  }
}

/** 停止语言服务（标记为用户主动，不触发崩溃重启） */
export async function stopShuxLanguageClient(client: LanguageClient | undefined): Promise<void> {
  if (!client) {
    return;
  }
  intentionalStop = true;
  await client.stop();
}
