# Myskills

面向 AI 编码 Agent 的「反捷径」Skill 集。5 个 Skill，每个阻断一种廉价的默认行为。

**完整说明见 [AGENTS.md](AGENTS.md)。**

## 安装到 Gemini CLI

```bash
# 安装为扩展
gemini extensions install https://github.com/K-arch-droid/Myskills
```

或手动：

```bash
git clone https://github.com/K-arch-droid/Myskills.git ~/.gemini/extensions/myskills
```

## Skill 清单

| Skill | 用途 |
|---|---|
| `problem-diagnosis` | 质疑问题定义 → 第一性原理归因 → 修复 |
| `solution-design` | 澄清偏好 → 跨域类比 → 3 版方案 |
| `solution-validation` | 红队证伪 → 二阶三阶影响推演 |
| `codebase-archaeology` | 新人认知成本审计 → Git 考古 |
| `process-retro` | PR 流程瓶颈 → Bug 复盘沉淀 |

## 全局约束

1. 范围限定，扩大范围先说明理由
2. 时间盒，超限先给阶段性结论
3. 证据强度标注 `[确证]` / `[推测]` / `[无证据]`
4. 问题清单按「影响 × 频率 × 修复成本」排序，只推前 3
5. 建议必须含「最小改动 + 验证方式 + 回滚方式」
6. 中文回答，结论先行
