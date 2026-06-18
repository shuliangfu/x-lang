#!/usr/bin/env bash
# eng-security-audit.sh — ENG-007 共享：依赖清单、npm audit、密钥探测与报告
#
# 用法（source 后）：
#   eng_sec_audit_prefix
#   eng_sec_inventory_scan INVENTORY_TXT
#   eng_sec_npm_audit [PROBE=1]
#   eng_sec_secret_probe
#   eng_sec_emit_report status inventory npm secret rows

ENG_SEC_PREFIX="${SHU_SECURITY_AUDIT_PREFIX:-shu: [SHU_SECURITY_AUDIT]}"

# 报告行固定前缀。
eng_sec_audit_prefix() {
  echo "$ENG_SEC_PREFIX"
}

# 解析清单 TSV（跳过 # 与表头），校验每行锚点文件与 token。
# 成功返回 0 并 echo 行数；失败返回 1。
eng_sec_inventory_scan() {
  local inv="${1:-tests/templates/eng-security-audit-inventory.txt}"
  local rows=0
  local cat name file token
  if [ ! -f "$inv" ]; then
    echo "eng-security-audit FAIL: missing inventory $inv" >&2
    return 1
  fi
  while IFS=$'\t' read -r cat name file token _notes; do
    [ -z "${cat:-}" ] && continue
    case "$cat" in \#*) continue ;; esac
    rows=$((rows + 1))
    if [ ! -f "$file" ]; then
      echo "eng-security-audit FAIL: inventory missing file $file ($name)" >&2
      return 1
    fi
    if ! grep -qF "$name" "$file" 2>/dev/null; then
      echo "eng-security-audit FAIL: inventory name '$name' not in $file" >&2
      return 1
    fi
    if [ -n "${token:-}" ] && [ "$token" != "-" ]; then
      if ! grep -F -- "$token" "$file" 2>/dev/null | grep -q .; then
        echo "eng-security-audit FAIL: inventory token '$token' not in $file ($name)" >&2
        return 1
      fi
    fi
  done < "$inv"
  if [ "$rows" -lt 1 ]; then
    echo "eng-security-audit FAIL: empty inventory" >&2
    return 1
  fi
  echo "$rows"
  return 0
}

# 在 editors/vscode 执行 npm audit（仅 high+）。
# PROBE=0 时跳过并返回 2；npm 不可用返回 2；有 high 漏洞返回 1。
eng_sec_npm_audit() {
  local probe="${SHU_SEC_AUDIT_PROBE:-0}"
  local vsdir="editors/vscode"
  if [ "$probe" != "1" ]; then
    return 2
  fi
  if ! command -v npm >/dev/null 2>&1; then
    echo "eng-security-audit npm SKIP: no npm" >&2
    return 2
  fi
  if [ ! -f "$vsdir/package.json" ] || [ ! -f "$vsdir/package-lock.json" ]; then
    echo "eng-security-audit npm SKIP: no lockfile" >&2
    return 2
  fi
  local log="/tmp/shu_eng_sec_npm_audit_$$.log"
  if ! (cd "$vsdir" && npm audit --audit-level=high --omit=dev 2>&1 | tee "$log"); then
    rm -f "$log"
    echo "eng-security-audit npm FAIL: high+ vulnerabilities" >&2
    return 1
  fi
  rm -f "$log"
  return 0
}

# 高置信密钥模式扫描（git 跟踪文件）；命中则失败。
eng_sec_secret_probe() {
  local hit=""
  # AWS Access Key ID 前缀
  hit="$(git grep -nE 'AKIA[0-9A-Z]{16}' -- . 2>/dev/null | head -1 || true)"
  if [ -n "$hit" ]; then
    echo "eng-security-audit secret FAIL: $hit" >&2
    return 1
  fi
  # GitHub personal access token
  hit="$(git grep -nE 'ghp_[a-zA-Z0-9]{36}' -- . 2>/dev/null | head -1 || true)"
  if [ -n "$hit" ]; then
    echo "eng-security-audit secret FAIL: $hit" >&2
    return 1
  fi
  # PEM private key header
  hit="$(git grep -nE '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----' -- . 2>/dev/null | head -1 || true)"
  if [ -n "$hit" ]; then
    echo "eng-security-audit secret FAIL: $hit" >&2
    return 1
  fi
  return 0
}

# 输出结构化周期性扫描报告行。
eng_sec_emit_report() {
  local status="$1"
  local inventory="$2"
  local npm="$3"
  local secret="$4"
  local rows="$5"
  echo "${ENG_SEC_PREFIX} status=${status} inventory=${inventory} npm=${npm} secret=${secret} rows=${rows}"
}
