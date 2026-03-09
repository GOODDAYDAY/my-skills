# Python 开发规范

## 项目结构

源码不允许直接放在项目根目录的 `src/` 下，必须按模块划分子层：

```
project/
├── backend/
│   └── src/
│       └── <package>/
│           ├── __init__.py
│           └── ...
├── shared/                     # 公共模块（如有多模块复用）
│   └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/                    # Web 项目：Playwright 端到端测试
├── scripts/
│   ├── build.bat
│   ├── run.bat
│   └── test.bat
├── requirements.txt 或 pyproject.toml
└── README.md
```

## 基本规范

- Python 3.10+
- 使用类型注解（type hints）
- 遵循 PEP 8 风格
- 使用 f-string 格式化字符串
- 变量名、函数名、注释、日志均使用英文

## 日志规范

- 使用 `logging` 模块，不要用 `print`
- 关键操作、异常分支、外部调用必须有日志
- 日志格式：`%(asctime)s - %(name)s - %(levelname)s - %(message)s`

## 依赖管理

- 优先使用 `pyproject.toml`
- 如项目已有 `requirements.txt` 则沿用

## 测试

- 单元/集成测试：`pytest`
- Web 端到端测试：`playwright`（`pip install pytest-playwright`）
- 测试文件以 `test_` 开头
- 运行命令：`pytest tests/ -v`

## 常用工具

- 格式化：`black`
- 类型检查：`mypy`
- Lint：`ruff`
