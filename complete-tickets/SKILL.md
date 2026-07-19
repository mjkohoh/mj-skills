---
name: complete-tickets
description: 在 to-tickets 之后，读取已批准的 Spec 及其全部 tickets，按依赖顺序在全新上下文中逐张调用 implement，更新 ticket 状态，直到全部完成。
---

# Complete Tickets

在 `to-tickets` 之后，持续完成同一份已批准 Spec 下的所有 tickets。默认串行执行：本 Skill 负责选择、调度和更新状态，`implement` 负责完成单张 ticket。

## 1. 准备

1. 读取项目规则和 issue tracker 配置，从用户参数、当前上下文或 `to-tickets` 的结果中找到原始 Spec 及其全部 tickets。
2. 读取 Spec 和每张 ticket 的完整内容。确认它们属于同一份 Spec、依赖引用有效且没有循环；范围无法确定时，暂停并询问用户。
3. 确认当前存放方式支持读取和更新 ticket。
4. 确认工作区干净，并且用户已经授权 `implement` 创建本地 commits。

## 2. 选择下一张 ticket

每次选择前，重新读取全部 tickets 及其状态。从尚未完成且它所依赖的 tickets 都已完成的 tickets 中选择一张。沿用文件或 tracker 中的排列顺序；顺序不稳定时按创建时间选择。

一张 ticket 被阻塞，不影响其他依赖已经满足的 tickets。只要仍有可做的 ticket，就继续调度。仍有未完成 tickets、但没有任何一张可以执行时，列出阻塞原因并暂停。

全部 tickets 都已完成时，汇总结果并结束。

## 3. 调用 `implement`

为当前 ticket 创建一个不继承本次对话的全新 agent 或 session，只提供执行这张 ticket 必需的信息：

- 仓库绝对路径；
- ticket 的稳定引用和完整内容，以及原始 Spec 的引用；
- 已完成的依赖 tickets 的必要摘要；
- 项目规则和用户授权边界。

要求新 agent 调用 `implement`，只完成当前 ticket，不选择下一张 ticket，也不更新 ticket 状态。让它在结束时说明：

- ticket 是否完成；
- 产生了哪些 commits；
- 如果未完成，阻塞原因是什么。

无法创建全新上下文或无法调用 `implement` 时，暂停并报告缺失条件。

## 4. 记录结果并继续

只有 `implement` 报告当前 ticket 已完成、相关 commits 存在于当前分支且工作区干净时，才把结果写回 ticket，并使用项目已有的方式将其标记为完成。

如果 ticket 没有完成，记录原因并使用项目已有的对应状态标记为阻塞，然后回到第 2 节继续处理其他 tickets。不要由编排器自动重试或补做实现。

如果失败影响所有 tickets，例如缺少授权、无法更新 tracker 或工作区不干净，不改变当前 ticket 的状态；暂停并请求用户处理。

写回本地、受版本控制的 ticket 文件时，是否创建状态 commit 继续服从项目规则和用户授权。

所有 tickets 完成后，报告 Spec 和 tickets 的引用、各 ticket 的状态及其 commits。

所有 commit、push、merge、部署和破坏性操作都服从项目规则与用户授权；已有的 commit 授权不自动包含其他操作。
