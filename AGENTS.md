# Myskills

面向 AI 编码 Agent 的「反捷径」Skill 集。5 个 Skill，每个阻断一种廉价的默认行为。

## 这个仓库是什么

一个标准的 [Agent Skills](https://agentskills.io) 仓库：

```
skills/<skill-name>/SKILL.md
```

每个 `SKILL.md` 的 YAML frontmatter 含 `name` 和 `description`，`name` 与目录名一致。

## Skill 清单

| Skill | 阻断什么 | 触发场景 |
|---|---|---|
| `problem-diagnosis` | 接受表面问题定义、打补丁式修复 | 提需求、报 bug、"为什么 X 会这样" |
| `solution-design` | 猜测用户偏好、本领域路径依赖 | 出方案、选型、"有没有更好的做法" |
| `solution-validation` | 自我确认偏差、线性/局部思维 | "这方案稳不稳""会有什么副作用" |
| `codebase-archaeology` | 把现状当合理、作者视角盲区 | 接手项目、清理历史包袱 |
| `process-retro` | 就事论事不复盘、靠感觉判断性能 | "为什么这么慢""为什么反复出 bug" |

## 给 Agent 的安装规则

如果你是被要求「安装这个仓库的 skills」的 Agent，按以下步骤执行：

1. **先读 `skills.json`**。它列出全部 Skill 的名称、路径、描述。不要靠猜，也不要只装第一个。
2. **确定目标目录**。查下面的对照表；用户没指定时，检测哪个目录已存在，都存在则询问全局还是项目级，都不存在则用 `~/.agents/skills/`。
3. **创建目标目录**（含父目录）。
4. **复制整个 Skill 目录**，不是只复制 `SKILL.md`——后续可能附带 `scripts/`、`references/`、`assets/`。
5. **同名冲突不要覆盖**，报告后询问。
6. **校验**：每个目标目录下存在 `SKILL.md`，frontmatter 的 `name` 与目录名一致，`description` 非空。
7. **输出结果**：装了哪几个、装到哪、跳过哪几个及原因。

## 目标目录对照

| Agent | `--agent` | 项目级 | 用户级（全局） |
|---|---|---|---|
| Qoder | `qoder` | `.qoder/skills/` | `~/.qoder/skills/` |
| QoderWork | `qoderwork` | — | `~/.qoderwork/skills/` |
| Claude Code | `claude` | `.claude/skills/` | `~/.claude/skills/` |
| OpenAI Codex | `codex` | `.codex/skills/` | `~/.codex/skills/` |
| Cursor | `cursor` | `.cursor/skills/` | `~/.cursor/skills/` |
| OpenCode | `opencode` | `.opencode/skills/` | `~/.config/opencode/skills/` |
| Qwen Code | `qwen` | `.qwen/skills/` | `~/.qwen/skills/` |
| Windsurf | `windsurf` | `.windsurf/skills/` | `~/.codeium/windsurf/skills/` |
| Trae | `trae` | `.trae/skills/` | `~/.trae/skills/` |
| Roo Code | `roo` | `.roo/skills/` | `~/.roo/skills/` |
| Kiro | `kiro` | `.kiro/skills/` | `~/.kiro/skills/` |
| 通用（跨客户端） | `agents` | `.agents/skills/` | `~/.agents/skills/` |

## 各 harness 的入口文件

每个 harness 读不同位置，仓库都放了一份：

| Harness | 入口文件 |
|---|---|
| Claude Code | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` |
| Cursor | `.cursor-plugin/plugin.json` |
| OpenAI Codex | `.codex-plugin/plugin.json` |
| OpenCode | `.opencode/plugins/myskills.js` |
| Gemini CLI | `gemini-extension.json` + `GEMINI.md` |
| Kimi Code | `.kimi-plugin/plugin.json` |
| Antigravity | `.antigravity-plugin/plugin.json` |
| Devin | `.devin-plugin/plugin.json` |
| Muse | `.muse-plugin/plugin.json` |
| Hermes | `.hermes-plugin/plugin.yaml` |
| 通用 / 跨客户端 | `.agents/plugins/marketplace.json` |
| skills.sh 市场 | `skills.sh.json` |
| npm / npx / Pi | `package.json` |
| 任意 Agent（读指令文件） | `AGENTS.md`（本文件）、`CLAUDE.md`、`GEMINI.md` |

## 安装方式

### 方式一：skills CLI

```bash
npx skills add K-arch-droid/Myskills                      # 交互选择
npx skills add K-arch-droid/Myskills -a qoder -g          # 指定 agent + 全局
npx skills add K-arch-droid/Myskills --skill problem-diagnosis -a codex
```

### 方式二：一键脚本

```bash
# Linux / macOS —— 自动检测平台
curl -fsSL https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.sh | bash

# 指定平台和范围
curl -fsSL https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.sh \
  | bash -s -- --agent qoder --global
```

```powershell
# Windows PowerShell —— 自动检测平台
irm https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.ps1 | iex

# 指定平台和范围
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.ps1))) -Agent qoder -Global
```

### 方式三：Claude Code 插件市场

```
/plugin marketplace add K-arch-droid/Myskills
/plugin install myskills@myskills
```

### 方式四：手动

```bash
git clone https://github.com/K-arch-droid/Myskills.git /tmp/myskills
cp -r /tmp/myskills/skills/* ~/.qoder/skills/    # 换成你的目标目录
```

## 全局约束

所有 Skill 共用六条约束，写在每个 `SKILL.md` 的「硬约束」节：

1. **范围**：默认限定当前任务涉及的模块，扩大范围先说明理由和预估成本
2. **时间盒**：单次分析不超过 X 分钟 / 不读取超过 N 个文件，超限先给阶段性结论
3. **证据强度**：每条结论标注 `[确证]` / `[推测]` / `[无证据]`，禁止把推测说成事实
4. **取舍**：问题清单按「影响 × 频率 × 修复成本」排序，只推荐前 3 项
5. **落地**：每个建议含「最小可执行改动 + 验证方式 + 回滚方式」，三者缺一不许输出
6. **语言**：中文回答，结论先行，分点罗列，关键结论加粗

## 组合用法

| 场景 | 顺序 |
|---|---|
| 日常修 bug | `problem-diagnosis` → `solution-validation` |
| 技术选型 / 重构 | `problem-diagnosis` → `solution-design` → `solution-validation` |
| 接手陌生项目 | `codebase-archaeology` |
| 团队流程改进 | `process-retro` |

单次只用 1–2 个。塞满全部会让注意力摊薄，每个都沾一点、都不深。
