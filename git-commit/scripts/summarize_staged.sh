#!/usr/bin/env bash
set -euo pipefail

MAX_DIFF_LINES="${MAX_DIFF_LINES:-200}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "STATUS: not_git_repo"
  echo "MESSAGE: 当前目录不是 Git 仓库。"
  exit 0
fi

if git diff --staged --quiet --exit-code; then
  echo "STATUS: no_staged_changes"
  echo "MESSAGE: 暂存区没有改动。"
  exit 0
fi

staged_files="$(git diff --staged --name-only)"
sensitive_files=""

while IFS= read -r file; do
  [ -n "$file" ] || continue
  base="$(basename "$file")"
  case "$base" in
    .env|.env.*|*.pem|*.key|id_rsa|id_ed25519|credentials.json|secrets.*)
      sensitive_files="${sensitive_files}${file}"$'\n'
      ;;
  esac
done <<< "$staged_files"

if [ -n "$sensitive_files" ]; then
  echo "STATUS: blocked_sensitive_files"
  echo "MESSAGE: 暂存区包含高风险文件名，已停止提交。"
  echo
  echo "SENSITIVE_FILES:"
  printf "%s" "$sensitive_files"
  exit 0
fi

echo "STATUS: ok"
echo
echo "STAGED_FILES:"
printf "%s\n" "$staged_files"
echo
echo "STAT:"
git diff --staged --stat
echo
echo "DIFF_SAMPLE_MAX_LINES: $MAX_DIFF_LINES"
echo "DIFF_SAMPLE:"
git diff --staged --no-ext-diff --unified=2 -- | sed -n "1,${MAX_DIFF_LINES}p"
