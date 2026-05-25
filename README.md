# Spring Cloud Demo

基于 **Spring Boot 2.7** + **Spring Cloud 2021** 的多模块微服务示例项目，兼容 **Java 8**。

## 模块说明

| 模块 | 端口 | 说明 |
|------|------|------|
| `eureka-server` | 8761 | 服务注册中心 |
| `config-server` | 8888 | 配置中心（native 本地文件模式） |
| `demo-service` | 8081 | 示例业务服务 |
| `gateway-server` | 8080 | API 网关 |

## 环境要求

- **JDK 8+**（需完整 JDK，不能只用 JRE）
- Maven 3.6+（或使用项目自带的 `./mvnw`）

macOS 若默认指向浏览器 JRE，请显式指定 JDK 8：

```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
java -version
javac -version
```

## 快速开始

### 1. 编译

```bash
./mvnw clean package -DskipTests
```

### 2. 按顺序启动（推荐）

```bash
# 终端 1
java -jar eureka-server/target/eureka-server-1.0.0-SNAPSHOT.jar

# 终端 2
java -jar config-server/target/config-server-1.0.0-SNAPSHOT.jar

# 终端 3
java -jar demo-service/target/demo-service-1.0.0-SNAPSHOT.jar

# 终端 4
java -jar gateway-server/target/gateway-server-1.0.0-SNAPSHOT.jar
```

或使用一键脚本：

```bash
chmod +x scripts/start-all.sh
./scripts/start-all.sh
```

### 3. 验证

- Eureka 控制台: http://localhost:8761
- 配置中心: http://localhost:8888/demo-service/default
- 经网关访问: http://localhost:8080/api/demo/hello
- 直连业务服务: http://localhost:8081/hello

## 项目结构

```
spring-cloud-demo/
├── eureka-server/      # 注册中心
├── config-server/      # 配置中心
├── gateway-server/     # 网关
├── demo-service/       # 示例服务
├── scripts/            # 启动脚本
└── pom.xml             # 父 POM
```

## 扩展建议

- 在 `config-server/src/main/resources/config/` 下新增各服务配置文件
- 在 `demo-service` 中继续拆分业务模块或新增更多微服务
- 生产环境可将 Config Server 切换为 Git 仓库模式
