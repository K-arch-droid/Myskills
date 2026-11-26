# Myskills

一套面向 AI 编码 Agent 的「反捷径」Skill 集。每个 Skill 都在阻断一种廉价的默认行为。

**把仓库链接发给任意 Agent，说「安装这个仓库里的 skills」即可自动注册。**
仓库按 `obra/superpowers` 的做法，给每个主流 harness 单独放了一份插件清单，而不是只靠一个通用结构。

## 目录

```
Myskills/
├── skills/                      # 唯一的内容源，5 个 Skill
│   ├── problem-diagnosis/SKILL.md
│   ├── solution-design/SKILL.md
│   ├── solution-validation/SKILL.md
│   ├── codebase-archaeology/SKILL.md
│   └── process-retro/SKILL.md
│
├── .claude-plugin/              # Claude Code
│   ├── plugin.json
│   └── marketplace.json
├── .cursor-plugin/plugin.json   # Cursor
├── .codex-plugin/plugin.json    # OpenAI Codex
├── .opencode/plugins/myskills.js# OpenCode
├── gemini-extension.json        # Gemini CLI
├── .kimi-plugin/plugin.json     # Kimi Code
├── .antigravity-plugin/         # Antigravity
├── .devin-plugin/               # Devin
├── .muse-plugin/plugin.json     # Muse
├── .hermes-plugin/plugin.yaml   # Hermes
├── .agents/plugins/marketplace.json  # 通用 / 跨客户端
│
├── skills.json                  # 机器可读清单（Agent 安装契约）
├── skills.sh.json               # skills.sh 市场分组
├── package.json                 # npm / npx / Pi
├── AGENTS.md                    # Qoder / Codex 等原生读取
├── CLAUDE.md                    # Claude Code 原生读取
├── GEMINI.md                    # Gemini CLI 原生读取
│
└── scripts/
    ├── install.sh               # Linux / macOS 安装器
    └── install.ps1              # Windows 安装器
```

## Skill 清单

| Skill | 阻断什么 | 何时触发 |
|---|---|---|
| `problem-diagnosis` | 接受表面问题定义、打补丁式修复 | 提需求、报 bug、"为什么 X 会这样" |
| `solution-design` | 猜测用户偏好、本领域路径依赖 | 出方案、选型、"有没有更好的做法" |
| `solution-validation` | 自我确认偏差、线性/局部思维 | "这方案稳不稳""会有什么副作用" |
| `codebase-archaeology` | 把现状当合理、作者视角盲区 | 接手项目、清理历史包袱 |
| `process-retro` | 就事论事不复盘、靠感觉判断性能 | "为什么这么慢""为什么反复出 bug" |

## 安装

### 方式一：skills CLI（推荐）

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

## 支持的 harness

| Harness | 入口文件 | 项目级 | 全局 |
|---|---|---|---|
| Qoder | `AGENTS.md` | `.qoder/skills/` | `~/.qoder/skills/` |
| QoderWork | `AGENTS.md` | — | `~/.qoderwork/skills/` |
| Claude Code | `.claude-plugin/` | `.claude/skills/` | `~/.claude/skills/` |
| OpenAI Codex | `.codex-plugin/` | `.codex/skills/` | `~/.codex/skills/` |
| Cursor | `.cursor-plugin/` | `.cursor/skills/` | `~/.cursor/skills/` |
| OpenCode | `.opencode/plugins/` | `.opencode/skills/` | `~/.config/opencode/skills/` |
| Gemini CLI | `gemini-extension.json` | — | `~/.gemini/extensions/` |
| Qwen Code | `AGENTS.md` | `.qwen/skills/` | `~/.qwen/skills/` |
| Windsurf | `AGENTS.md` | `.windsurf/skills/` | `~/.codeium/windsurf/skills/` |
| Trae | `AGENTS.md` | `.trae/skills/` | `~/.trae/skills/` |
| Roo Code | `AGENTS.md` | `.roo/skills/` | `~/.roo/skills/` |
| Kiro | `AGENTS.md` | `.kiro/skills/` | `~/.kiro/skills/` |
| Kimi Code | `.kimi-plugin/` | — | — |
| Antigravity | `.antigravity-plugin/` | — | — |
| Devin | `.devin-plugin/` | — | — |
| Muse | `.muse-plugin/` | — | — |
| Hermes | `.hermes-plugin/` | — | — |
| 通用 / 跨客户端 | `.agents/plugins/` | `.agents/skills/` | `~/.agents/skills/` |
| skills.sh 市场 | `skills.sh.json` | — | — |
| npm / npx / Pi | `package.json` | — | — |

## 组合用法

| 场景 | 顺序 |
|---|---|
| 日常修 bug | `problem-diagnosis` → `solution-validation` |
| 技术选型 / 重构 | `problem-diagnosis` → `solution-design` → `solution-validation` |
| 接手陌生项目 | `codebase-archaeology` |
| 团队流程改进 | `process-retro` |

单次只用 1–2 个。塞满全部会让注意力摊薄，每个都沾一点、都不深。

## 三条顺序铁律

1. **需求类问题先重述再归因** —— 代码改到一半才被推翻是最大的浪费
2. **澄清在证伪之前** —— 红队需要靶子，先有候选方案才能攻击
3. **证伪在推演之前** —— 方案本身是错的，推演二阶影响纯属浪费

## 全局约束

所有 Skill 共用六条约束：

1. **范围**：默认限定在当前任务涉及的模块，扩大范围先说明理由和预估成本
2. **时间盒**：单次分析不超过 X 分钟 / 不读取超过 N 个文件 / 不翻超过 M 条 commit
3. **证据强度**：每条结论标注 `[确证]` / `[推测]` / `[无证据]`，禁止把推测说成事实
4. **取舍**：问题清单按「影响 × 频率 × 修复成本」排序，只推荐前 3 项
5. **落地**：每个建议包含「最小可执行改动 + 验证方式 + 回滚方式」，三者缺一不许输出
6. **语言**：中文回答，结论先行，分点罗列，关键结论加粗

## License

MIT
