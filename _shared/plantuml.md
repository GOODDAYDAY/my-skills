# PlantUML 画图规范

## 使用流程

1. 在需求/技术文档同目录下创建 `.puml` 文件
2. 使用标准 PlantUML 语法编写
3. 执行转换命令生成 SVG
4. **必须验证转换成功**，失败则修复语法后重试

## 转换与校验

```bash
# 转换单个文件
plantuml -tsvg <file>.puml

# 转换目录下所有 puml 文件
plantuml -tsvg *.puml
```

校验规则：
- 转换命令退出码必须为 0
- 必须生成对应的 `.svg` 文件
- SVG 文件大小必须 > 0
- SVG 内容中不能包含 `Syntax Error`（PlantUML 语法错误时会生成带错误信息的图片）

校验脚本：

```bash
# 校验单个文件
plantuml -tsvg "$FILE" 2>&1
EXIT_CODE=$?
SVG_FILE="${FILE%.puml}.svg"
if [ $EXIT_CODE -ne 0 ] || [ ! -s "$SVG_FILE" ] || grep -q "Syntax Error" "$SVG_FILE"; then
  echo "FAILED: $FILE"
  # 需要修复语法后重试
else
  echo "OK: $SVG_FILE"
fi
```

## 语法要点

### 通用规则
- 文件必须以 `@startuml` 开头，`@enduml` 结尾
- 使用 UTF-8 编码，中文直接写即可
- 避免使用非标准扩展语法

### 常用图类型

**用例图：**
```plantuml
@startuml
actor 用户
用户 --> (登录)
用户 --> (查看数据)
@enduml
```

**时序图：**
```plantuml
@startuml
participant 客户端
participant 服务端
participant 数据库
客户端 -> 服务端: 请求数据
服务端 -> 数据库: 查询
数据库 --> 服务端: 返回结果
服务端 --> 客户端: 响应
@enduml
```

**类图：**
```plantuml
@startuml
class User {
  +String name
  +String email
  +login()
}
class Order {
  +int id
  +create()
}
User "1" -- "*" Order
@enduml
```

**流程图（Activity）：**
```plantuml
@startuml
start
:接收请求;
if (参数合法?) then (是)
  :处理业务逻辑;
  :返回成功;
else (否)
  :返回错误;
endif
stop
@enduml
```

**组件图：**
```plantuml
@startuml
package "前端" {
  [Web App]
}
package "后端" {
  [API Server]
  [Worker]
}
database "数据库" {
  [MySQL]
}
[Web App] --> [API Server]
[API Server] --> [MySQL]
[API Server] --> [Worker]
@enduml
```

## 文件命名

- 需求文档配图：`req-用例图.puml`、`req-流程图.puml`
- 技术文档配图：`tech-架构图.puml`、`tech-时序图.puml`、`tech-类图.puml`
