# AGENTS.md

本仓库用于维护个人 skills。

## 基本约定

- README 保持简短，只说明仓库用途和当前 skills。
- 除非用户明确要求，不处理 `.gitignore`。
- 新增 skill 时，每个 skill 使用独立目录。
- skill 的主说明优先使用中文。

## 当前 Skill

### git-commit

`git-commit` 用于快速提交已经暂存的 Git 改动。

维护时保持这些边界：

- 默认只处理 staged changes。
- 默认不执行 `git add`。
- 默认不读取完整 diff，只读取必要摘要。
- commit message 使用中文描述。
- Conventional Commit 的 type/scope 保持英文。
