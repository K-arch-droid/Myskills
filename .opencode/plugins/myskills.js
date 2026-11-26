/**
 * Myskills plugin for OpenCode.ai
 *
 * 兼容 OpenCode V1 与 V2：
 *   V1 通过具名导出 MyskillsPlugin 提供 config hook，把 skills 目录注入配置。
 *   V2 通过默认导出 { id, setup } 由 PluginSupervisor 调用 setup()，
 *      用 ctx.skill.transform() 原生注册每个 SKILL.md。
 *
 * 无外部依赖，纯 JavaScript。
 */

import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// 与 V1 / V2 共用的 skills 目录
const skillsDir = path.resolve(__dirname, '../../skills');

/**
 * 轻量 frontmatter 解析：处理 `key: value`、引号值、YAML 块标量（> / |）与 CRLF。
 * 不是完整 YAML 解析器——嵌套 map 会并入父键的值，对本插件消费的
 * name / description 字段足够。
 */
const parseFrontmatter = (content) => {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  if (!match) return { frontmatter: {}, content };

  const frontmatter = {};
  let lastKey = null;

  for (const rawLine of match[1].split('\n')) {
    const line = rawLine.replace(/\r$/, '');
    const colonIdx = line.indexOf(':');
    if (colonIdx > 0 && !/^\s/.test(line)) {
      const key = line.slice(0, colonIdx).trim();
      const value = line.slice(colonIdx + 1).trim();
      frontmatter[key] = /^(>[+-]?|\|[+-]?)$/.test(value) ? '' : value;
      lastKey = key;
    } else if (lastKey !== null && line.trim() !== '') {
      frontmatter[lastKey] = `${frontmatter[lastKey]} ${line.trim()}`.trim();
    }
  }

  for (const key of Object.keys(frontmatter)) {
    frontmatter[key] = frontmatter[key].replace(/^(["'])([\s\S]*)\1$/, '$2');
  }

  return { frontmatter, content: match[2] };
};

const listSkills = () => {
  const out = [];
  if (!fs.existsSync(skillsDir)) return out;

  for (const entry of fs.readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory() || entry.name.startsWith('.')) continue;
    const skillPath = path.join(skillsDir, entry.name, 'SKILL.md');
    if (!fs.existsSync(skillPath)) continue;

    const { frontmatter, content } = parseFrontmatter(fs.readFileSync(skillPath, 'utf8'));
    out.push({
      id: entry.name,
      name: frontmatter.name || entry.name,
      ...(frontmatter.description ? { description: frontmatter.description } : {}),
      path: skillPath,
      content,
    });
  }
  return out;
};

/**
 * V1 插件函数（具名导出 + default.server）
 */
export const MyskillsPlugin = async () => ({
  config: async (config) => {
    // V2: skills 是扁平数组，交给 setup() 处理
    if (Array.isArray(config.skills)) return;

    config.skills = config.skills || {};
    config.skills.paths = config.skills.paths || [];
    if (!config.skills.paths.includes(skillsDir)) {
      config.skills.paths.push(skillsDir);
    }
  },
});

/**
 * V2 setup 函数（default.setup）
 */
async function setup(ctx) {
  if (!ctx || !ctx.skill || typeof ctx.skill.transform !== 'function') return;

  const skills = listSkills();

  try {
    await ctx.skill.transform((draft) => {
      for (const skill of skills) {
        try {
          draft.add(skill);
        } catch (err) {
          console.error(`[myskills] skill "${skill.id}" rejected by host, skipping:`, err);
        }
      }
    });
  } catch (err) {
    console.error('[myskills] skill registration failed:', err);
  }
}

export default {
  id: 'myskills',
  server: MyskillsPlugin,
  setup,
};
