# my-skills

Personal Claude Code skills repository. Integrate into any project via git submodule.

## Usage

```bash
git submodule add git@github.com:GOODDAYDAY/my-skills.git .claude/skills
```

## Skills

| 命令 | 说明 |
|:---|:---|
| `/req [需求简述]` | 总编排入口，引导走完需求开发全流程 |
| `/req-1-analyze [需求简述]` | 需求分析，扩展为完整需求文档 |
| `/req-2-tech [REQ-xxx]` | 技术文档编写 |
| `/req-3-code [REQ-xxx]` | 编码开发（自动加载语言规范） |
| `/req-4-review [REQ-xxx]` | 需求对比审查 |
| `/req-5-verify [REQ-xxx]` | 编译/运行/测试校验 |
| `/req-6-done [REQ-xxx]` | 归档，标记为已完成 |
| `/create-skill [name]` | 创建新 skill 的标准指南 |

## Structure

```
my-skills/
├── _shared/plantuml.md           # PlantUML 共享规范
├── create-skill/SKILL.md
├── req/SKILL.md                  # 总编排
├── req-1-analyze/SKILL.md        # 需求分析
├── req-2-tech/SKILL.md           # 技术文档
├── req-3-code/                   # 编码开发
│   ├── SKILL.md
│   ├── python.md
│   └── java.md
├── req-4-review/SKILL.md         # 需求对比
├── req-5-verify/SKILL.md         # 校验测试
└── req-6-done/SKILL.md           # 归档完成
```
