---
name: git-push 
description: 执行 Git 提交并推送的一体化流程。适用于用户明确要求“提交代码”“提交并推送”“一键推送”“快速 commit and push”等场景。自动检查仓库状态、处理 staged 内容、基于 staged diff 生成单一 commit message、执行 commit，并在安全前提下 push 到远程。
---

# Git Push

完成 `git add`、`git diff --staged`、生成 commit message、`git commit`、`git push`。

## 执行规则

* 只使用当前仓库状态和本次 `git diff --staged`
* 不使用仓库历史、之前对话、任务背景或主观推测
* 不输出多个候选 commit message
* 命令失败后立即停止，不继续后续步骤
* 不自动执行高风险操作，如 `git pull`、`git rebase`、`git push --force`

## 流程

### 1. 检查仓库

先执行：

`git rev-parse --is-inside-work-tree`

若当前目录不是 Git 仓库，提示用户并终止。

再执行：

`git status --short`

### 2. 处理暂存

* 若用户明确指定文件路径：执行 `git add <路径>`
* 若用户未指定文件但已有 staged 内容：直接继续
* 若用户未指定文件且 staged 为空，但存在未暂存修改：展示 `git status --short` 并询问用户要添加哪些文件
  * 用户回复 `.`、`all`、`全部` → 执行 `git add .`
  * 用户回复路径 → 执行 `git add <路径>`
* 若没有 staged 内容，也没有未暂存修改：提示没有可提交内容并终止

### 3. 检查 staged diff

执行：

`git diff --staged --stat`

`git diff --staged`

若 staged diff 为空，提示用户并终止。

## commit message 规则

只能基于本次 `git diff --staged` 生成。

### Subject

格式：

`<type>(<scope>): <subject>`

* `type` 只能是：`feat|fix|refactor|perf|test|docs|chore|build|ci|style|revert`
* `scope` 按路径提取：

  1. `src/<module>/...`
  2. `packages/<module>/...`
  3. `apps/<module>/...` 或 `services/<module>/...`
  4. `lib/<module>/...`
  5. 顶层目录名
  6. 否则用 `core`
* `scope` 必须为 kebab-case
* `subject` 使用中文，动词开头，只描述做了什么，不描述原因或收益

### Body

* 1 到 10 条
* 每条以 `-` 开头
* 使用中文
* 只写能从 diff 直接验证的事实
* 必须包含 1 条“本次修改的影响范围”，明确说明受影响的模块、目录、接口、命令、页面或文件范围；如果 diff 无法判断更大范围，则按文件或目录层级如实描述
* 若 diff 未体现测试变更或测试输出，必须包含：
  `- Tests: not shown in diff`

### Footer

仅在 diff 明确支持时输出：

* `BREAKING CHANGE: <说明>`
* `Refs: <issue/id>`

## 禁止项

* 不得杜撰原因、收益、性能提升、安全修复、issue、工单号
* 不得写“测试通过”“已验证”等 diff 无法证明的结论
* 不得跳过 `git diff --staged`
* 不得输出多个 commit message 版本

## 提交与推送

先展示最终 commit message，再执行：

* `git commit -m "<subject>" -m "<body>"`
* 若有 footer，再追加一个 `-m "<footer>"`

若 commit 失败，展示错误并停止。

然后执行：

`git branch --show-current`

`git push`

* 若当前分支没有上游分支：执行 `git push -u origin <当前分支名>`
* 若 push 失败：展示错误，并提示用户自行处理 pull、rebase、权限或冲突问题

## 输出要求

* 简洁展示关键结果
* commit 前展示最终 commit message
* 只给一个最终版本
* 不输出代码块围栏
