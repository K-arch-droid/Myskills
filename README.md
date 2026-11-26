# Myskills

一套面向 AI 编码 Agent 的「反捷径」Skill 集。每个 Skill 都在阻断一种廉价的默认行为。

## 目录

| Skill | 阻断什么 | 何时触发 |
|---|---|---|
| `problem-diagnosis` | 接受表面问题定义、打补丁式修复 | 提需求、报 bug、"为什么 X 会这样" |
| `solution-design` | 猜测用户偏好、本领域路径依赖 | 出方案、选型、"有没有更好的做法" |
| `solution-validation` | 自我确认偏差、线性/局部思维 | "这方案稳不稳""会有什么副作用" |
| `codebase-archaeology` | 把现状当合理、作者视角盲区 | 接手项目、清理历史包袱 |
| `process-retro` | 就事论事不复盘、靠感觉判断性能 | "为什么这么慢""为什么反复出 bug" |

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

## 安装

把需要的 Skill 目录复制到你的 Agent skills 目录下（如 `workspace/.user_skills/`）：

```bash
cp -r problem-diagnosis solution-design /path/to/workspace/.user_skills/
```

## License

MIT
