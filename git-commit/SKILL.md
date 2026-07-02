---
name: git-commit
description: 使用中文 Conventional Commit 快速提交已暂存的 Git 改动。当用户要求提交改动、创建 git commit、生成提交信息，或提到 /commit、commit changes、create a commit 时使用。
---

# 中文 Git Commit

用“暂存区优先”的快路径创建提交：只处理已经 staged 的改动，不默认 `git add`，不做完整大 diff 分析。

## 步骤

1. 运行本 skill 目录下的摘要脚本，用实际 skill 路径替换 `<skill-dir>`：

   ```bash
   bash <skill-dir>/scripts/summarize_staged.sh
   ```

2. 根据脚本输出决定下一步：

   - `STATUS: no_staged_changes`：停止，提示用户先暂存文件，或明确要求你帮忙 stage。
   - `STATUS: blocked_sensitive_files`：停止，列出被阻止的 staged 文件，不提交。
   - `STATUS: ok`：继续生成提交信息。

3. 生成中文 Conventional Commit。

   格式：

   ```text
   <type>[optional scope]: <中文描述>

   [可选中文正文]
   ```

   示例：

   ```text
   feat(git-commit): 生成中文提交信息
   fix: 修复暂存区为空时的提交流程
   docs(skill): 更新中文使用说明
   ```

4. 优先使用用户明确给出的 type、scope 或 summary。用户没有指定时，只根据脚本输出的 staged 文件列表、stat 和 diff sample 推断。

5. 执行提交：

   ```bash
   git commit -m "<type>[scope]: <中文描述>"
   ```

   需要正文时使用多个 `-m`：

   ```bash
   git commit -m "<type>[scope]: <中文描述>" -m "<中文正文>"
   ```

6. 如果 commit hook 失败，报告失败原因并停止。不要使用 `--no-verify`，不要 amend，除非用户明确要求。

## Type 推断

| Type       | 使用场景 |
| ---------- | -------- |
| `feat`     | 新功能或新增用户可见能力 |
| `fix`      | 修复 bug 或错误行为 |
| `docs`     | 只改文档、说明、示例 |
| `style`    | 格式、排版、空白、无逻辑变化 |
| `refactor` | 重构实现，没有新增功能或修复 |
| `perf`     | 性能优化 |
| `test`     | 新增或更新测试 |
| `build`    | 构建系统、依赖、打包 |
| `ci`       | CI 或自动化配置 |
| `chore`    | 维护性改动，无法更精确分类时使用 |
| `revert`   | 回滚提交 |

## 快速规则

- 默认只提交 staged changes。
- 默认不运行 `git add`。
- 默认不读取完整 staged diff。
- 保留英文 type/scope，描述和正文用中文。
- subject 控制在 72 个字符以内。
- scope 用受影响模块、目录或 skill 名；不确定就省略。
- 推断不清时使用保守提交：`chore: 更新项目文件`。
- 不修改 git config。
- 不执行 destructive git 命令。
