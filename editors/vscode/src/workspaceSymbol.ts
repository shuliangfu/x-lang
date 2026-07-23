/**
 * Xlang WorkspaceSymbolProvider — 全局符号搜索（Ctrl+T 跨文件）
 *
 * 【Why】LSP 服务端未声明 workspaceSymbolProvider；扩展侧本地扫描工作区 .x 文件
 *        顶层 function/struct/enum/trait/impl/type 声明，按查询字符串过滤返回。
 * 【Invariant】缓存 fsPath → 符号列表；文件创建/删除/修改时失效对应条目或整体。
 * 【Asm/Perf】首次查询全量扫描（findFiles + readFile 并发），后续查询仅过滤缓存。
 *             扫描并发度限制为 16，避免超大工作区瞬时 I/O 压力。
 */

import * as vscode from 'vscode';

/** 缓存：fsPath → 符号列表 */
const symbolCache = new Map<string, vscode.SymbolInformation[]>();
let cacheReady = false;
let scanningPromise: Promise<void> | undefined;

/** 默认排除模式：非源码目录与编译产物（与 package.json 默认值保持一致） */
const DEFAULT_EXCLUDE_PATTERNS = [
  '**/node_modules/**',
  '**/.git/**',
  '**/out/**',
  '**/dist/**',
  '**/target/**',
  '**/build/**',
];

/** 默认最大扫描文件数（与 package.json 默认值保持一致） */
const DEFAULT_MAX_FILES = 2000;

/** 读取用户配置的排除模式（与默认值合并去重） */
function readExcludePatterns(): string[] {
  const cfg = vscode.workspace
    .getConfiguration('xlang')
    .get<string[]>('workspaceSymbol.excludePatterns', DEFAULT_EXCLUDE_PATTERNS);
  const merged = new Set<string>(DEFAULT_EXCLUDE_PATTERNS);
  for (const p of cfg) {
    merged.add(p);
  }
  return Array.from(merged);
}

/** 读取用户配置的最大扫描文件数 */
function readMaxFiles(): number {
  return vscode.workspace
    .getConfiguration('xlang')
    .get<number>('workspaceSymbol.maxFiles', DEFAULT_MAX_FILES);
}

/** 顶层声明正则（与 statusbar.ts 保持一致，独立维护避免循环依赖） */
const FUNC_RE = /^\s*(?:export\s+)?(?:extern\s+(?:"C"|"X"\s+)?)?function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/;
const STRUCT_RE = /^\s*(?:export\s+)?(?:allow\(padding\)\s+|packed\s+|soa\s+|align\(\d+\)\s+)*struct\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
const ENUM_RE = /^\s*(?:export\s+)?enum\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
const TRAIT_RE = /^\s*(?:export\s+)?trait\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
const IMPL_RE = /^\s*impl\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+for\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\{/;
const TYPE_RE = /^\s*(?:export\s+)?type\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=/;

/**
 * 将源码中的注释替换为等长空白（保留换行），
 * 使行首正则不会匹配到注释中的关键字。
 */
function stripCommentsPreserveNewlines(source: string): string {
  const out: string[] = new Array(source.length);
  let lineCmt = false;
  let blockDepth = 0;
  let inStr = false;
  let escaped = false;

  for (let i = 0; i < source.length; i++) {
    const c = source[i];
    const n = source[i + 1];

    if (lineCmt) {
      out[i] = c === '\n' ? '\n' : ' ';
      if (c === '\n') lineCmt = false;
      continue;
    }
    if (blockDepth > 0) {
      if (c === '/' && n === '*') { out[i] = ' '; out[i + 1] = ' '; blockDepth++; i++; continue; }
      if (c === '*' && n === '/') { out[i] = ' '; out[i + 1] = ' '; blockDepth--; i++; continue; }
      out[i] = c === '\n' ? '\n' : ' ';
      continue;
    }
    if (inStr) {
      out[i] = c;
      if (!escaped && c === '\\') { escaped = true; }
      else if (!escaped && c === '"') { inStr = false; }
      else if (escaped) { escaped = false; }
      continue;
    }
    if (c === '"') { inStr = true; escaped = false; out[i] = '"'; continue; }
    if (c === '/' && n === '/') { out[i] = ' '; out[i + 1] = ' '; lineCmt = true; i++; continue; }
    if (c === '/' && n === '*') { out[i] = ' '; out[i + 1] = ' '; blockDepth = 1; i++; continue; }

    out[i] = c;
  }
  return out.join('');
}

/** 从清洗后的源码提取顶层符号列表 */
function extractSymbols(document: vscode.TextDocument): vscode.SymbolInformation[] {
  const sanitized = stripCommentsPreserveNewlines(document.getText());
  const lines = sanitized.split(/\r?\n/);
  const symbols: vscode.SymbolInformation[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    let m = FUNC_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        m[1], vscode.SymbolKind.Function, 'function',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
    m = STRUCT_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        m[1], vscode.SymbolKind.Struct, 'struct',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
    m = ENUM_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        m[1], vscode.SymbolKind.Enum, 'enum',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
    m = TRAIT_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        m[1], vscode.SymbolKind.Interface, 'trait',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
    m = IMPL_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        `${m[1]} for ${m[2]}`, vscode.SymbolKind.Object, 'impl',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
    m = TYPE_RE.exec(line);
    if (m) {
      symbols.push(new vscode.SymbolInformation(
        m[1], vscode.SymbolKind.TypeParameter, 'type',
        new vscode.Location(document.uri, new vscode.Range(i, 0, i, line.length))
      ));
      continue;
    }
  }
  return symbols;
}

/** 全量扫描工作区 .x 文件，填充缓存 */
async function scanWorkspace(): Promise<void> {
  const exclude = readExcludePatterns().join(',');
  const maxFiles = readMaxFiles();
  const files = await vscode.workspace.findFiles('**/*.x', exclude, maxFiles);
  const concurrency = 16;
  const results: Array<{ uri: vscode.Uri; symbols: vscode.SymbolInformation[] }> = [];

  for (let i = 0; i < files.length; i += concurrency) {
    const batch = files.slice(i, i + concurrency);
    const batchResults = await Promise.all(
      batch.map(async (uri) => {
        try {
          const doc = await vscode.workspace.openTextDocument(uri);
          return { uri, symbols: extractSymbols(doc) };
        } catch {
          return { uri, symbols: [] };
        }
      })
    );
    results.push(...batchResults);
  }

  symbolCache.clear();
  for (const { uri, symbols } of results) {
    symbolCache.set(uri.fsPath, symbols);
  }
  cacheReady = true;
}

/** 确保缓存就绪（首次查询时触发扫描） */
async function ensureCacheReady(): Promise<void> {
  if (cacheReady) return;
  if (!scanningPromise) {
    scanningPromise = scanWorkspace().finally(() => {
      scanningPromise = undefined;
    });
  }
  await scanningPromise;
}

/**
 * 失效缓存：文件变更时调用。
 * @param uri 变更文件 URI；不传则整体失效。
 */
export function invalidateWorkspaceSymbolCache(uri?: vscode.Uri): void {
  if (uri) {
    symbolCache.delete(uri.fsPath);
  } else {
    symbolCache.clear();
    cacheReady = false;
  }
}

/**
 * Xlang 全局符号搜索 Provider。
 *
 * 注册示例：
 * ```ts
 * languages.registerWorkspaceSymbolProvider(new XlangWorkspaceSymbolProvider());
 * ```
 */
export class XlangWorkspaceSymbolProvider implements vscode.WorkspaceSymbolProvider {
  public async provideWorkspaceSymbols(
    query: string,
    _token: vscode.CancellationToken
  ): Promise<vscode.SymbolInformation[]> {
    await ensureCacheReady();

    const q = query.toLowerCase();
    const results: vscode.SymbolInformation[] = [];

    for (const symbols of symbolCache.values()) {
      for (const sym of symbols) {
        if (q === '' || sym.name.toLowerCase().includes(q)) {
          results.push(sym);
        }
      }
    }
    return results;
  }
}
