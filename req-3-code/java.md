# Java 开发规范

## 项目结构

源码不允许直接放在项目根目录的 `src/` 下，必须按模块划分子层：

```
project/
├── backend/
│   └── src/
│       ├── main/java/<package>/
│       └── test/java/<package>/
├── shared/                         # 公共模块（如有多模块复用）
│   └── ...
├── scripts/
│   ├── build.bat
│   ├── run.bat
│   └── test.bat
├── pom.xml 或 build.gradle
└── README.md
```

## 基本规范

- Java 17+
- 遵循阿里巴巴 Java 开发手册（适用时）
- 使用 Lombok 减少样板代码（如项目已引入）
- 方法不超过 80 行
- 变量名、方法名、注释、日志均使用英文

## 日志规范

- 使用 SLF4J + Logback
- 关键操作、异常分支、外部调用必须有日志
- 日志级别：INFO（正常流程）、WARN（异常但可恢复）、ERROR（异常不可恢复）

## 构建工具

- 优先沿用项目现有工具（Maven / Gradle）
- 新项目默认使用 Maven

## 测试

- 使用 JUnit 5
- 测试类以 `Test` 结尾
- 运行命令：`mvn test` 或 `gradle test`

## 常用框架

- Web：Spring Boot
- ORM：MyBatis / JPA
- 工具：Hutool、Guava
