# Java Web Service Coding Standard

## 1. Maven Multi-Module POM Structure

### 1.1 Three POM Roles

|------|-----------|---------|---------|
| **Root POM (Global Manager)** | `pom` | Unified versioning, dependency management, global plugins | `parent/pom.xml` |
| **Aggregator POM (Domain Entry)** | `pom` | Groups all sub-modules of a business domain | `{domain}/pom.xml` |
| **Leaf Module** | `jar` (default) | Actual code-producing module | `{domain}-biz`, `common`, etc. |

### 1.2 Root POM Responsibilities

```xml
<groupId>com.company.project</groupId>
<artifactId>parent</artifactId>
<version>${revision}</version>    <!-- CI-friendly version, single source of truth -->
<packaging>pom</packaging>

<modules>
  <module>common</module>          <!-- Global utilities -->
  <module>web-base</module>        <!-- Web infrastructure -->
  <module>redis-client</module>    <!-- Middleware client modules -->
  <module>mongo-client</module>
  <module>kafka</module>
  <module>gateway</module>         <!-- Gateway service -->
  <module>{domain-a}</module>      <!-- Business domain A -->
  <module>{domain-b}</module>      <!-- Business domain B -->
</modules>
```

**The root POM does exactly four things:**

1. **`<properties>`** — Centralized declaration of all dependency version numbers
2. **`<dependencyManagement>`** — Imports Spring Boot BOM + Spring Cloud BOM, declares all third-party dependency versions (child modules reference them **without specifying version**)
3. **Global `<dependencies>`** — Only dependencies needed by 100% of modules (Lombok, spring-boot-starter-test)
4. **Global `<build><plugins>`** — compiler, surefire, flatten, code quality plugins (checkstyle/PMD/SpotBugs)

**Key practices:**

- Use `${revision}` + `flatten-maven-plugin(resolveCiFriendliesOnly)` for version management — all child modules reference `${revision}`, change once to update everywhere
- Internal module cross-references are also declared in `<dependencyManagement>` to keep versions consistent

### 1.3 Aggregator POM (Business Domain)

Each business domain is a `packaging=pom` intermediate layer that groups its sub-modules:

```xml
<parent>
  <artifactId>parent</artifactId>
  <version>${revision}</version>
</parent>

<artifactId>{domain}</artifactId>
<packaging>pom</packaging>
<modules>
  <module>{domain}-common</module>
  <module>{domain}-api</module>
  <module>{domain}-dao</module>
  <module>{domain}-biz</module>
  <module>{domain}-controller</module>
</modules>

<dependencies>
  <!-- Shared dependency for all sub-modules in this domain -->
  <dependency>
    <artifactId>common</artifactId>
  </dependency>
</dependencies>
```

### 1.4 Two Flavors of Leaf Module POMs

#### Library Module (non-deployable: common, dao, biz, api, etc.)

```xml
<parent>
  <artifactId>{domain}</artifactId>  <!-- Points to domain aggregator POM -->
</parent>
<artifactId>{domain}-biz</artifactId>
<!-- No packaging tag → defaults to jar -->

<dependencies>
  <!-- Declare only what you need, no version -->
</dependencies>

<build>
  <finalName>${project.artifactId}</finalName>
  <plugins>
    <plugin>
      <!-- maven-source-plugin: produce source jar for debugging by dependents -->
      <artifactId>maven-source-plugin</artifactId>
      <executions>
        <execution>
          <phase>compile</phase>
          <goals><goal>jar</goal></goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

**Key trait: No `spring-boot-maven-plugin` — produces a plain jar, not independently runnable.**

#### Service Module (deployable: controller, gateway)

```xml
<parent>
  <artifactId>{domain}</artifactId>
</parent>
<artifactId>{domain}-controller</artifactId>

<dependencies>
  <dependency>
    <artifactId>web-base</artifactId>
  </dependency>          <!-- Web infrastructure -->
  <dependency>
    <artifactId>{domain}-biz</artifactId>
  </dependency>          <!-- Business logic -->
  <dependency>
    <artifactId>{domain}-api</artifactId>
  </dependency>          <!-- Request/Response DTOs -->
</dependencies>

<build>
  <plugins>
    <plugin>
      <artifactId>maven-compiler-plugin</artifactId>
      <configuration>
        <annotationProcessorPaths>
          <!-- Lombok + Spring Configuration Processor -->
        </annotationProcessorPaths>
      </configuration>
    </plugin>
    <plugin>
      <!-- spring-boot-maven-plugin: produce executable fat jar -->
      <artifactId>spring-boot-maven-plugin</artifactId>
      <executions>
        <execution>
          <goals><goal>repackage</goal></goals>
        </execution>
      </executions>
      <configuration>
        <mainClass>com.company.project.{domain}.ControllerApplication</mainClass>
        <layout>JAR</layout>
      </configuration>
    </plugin>
  </plugins>
</build>
```

**Key trait: Has `spring-boot-maven-plugin` + `repackage`, specifies `mainClass` — this is an independently runnable deployment unit.**

---

## 2. Layered Architecture Within a Business Domain

Each business domain consists of 5-6 sub-modules with a strict top-down dependency flow:

```
                   ┌─────────────────┐
                   │  {domain}-controller  │  ← Independently deployable Spring Boot service
                   │  (REST entry)         │
                   └────────┬────────┘
                            │ depends on
                   ┌────────▼────────┐
                   │   {domain}-biz      │  ← Business orchestration layer
                   │   (Service composition) │
                   └──┬─────┬────┬───┘
                      │     │    │
          ┌───────────┘     │    └───────────┐
          ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│ {domain}-dao │  │{domain}-security│  │ Middleware clients │
│ (Data access)│  │ (Auth/Crypto)  │  │(redis/mongo/kafka) │
└──────┬───────┘  └──────────────┘  └──────────────────┘
       │
       ▼
┌──────────────┐    ┌──────────────┐
│{domain}-common│    │ {domain}-api │
│(Domain-internal│    │(Request/     │
│  constants)   │    │ Response DTO)│
└──────────────┘    └──────────────┘
```

### Layer Responsibilities

| Sub-module | Responsibility | Visibility |
|------------|---------------|------------|
| **{domain}-api** | Request/Response DTOs, pure POJOs with Jakarta Validation annotations | **Only referenced by controller and external domains** (see below) |
| **{domain}-common** | Domain-internal shared enums, constants, internal DTOs | Domain-internal only |
| **{domain}-dao** | Entity + MyBatis Mapper + DAO Service (data access encapsulation) | Domain-internal only |
| **{domain}-security** | Security: JWT, encryption, authentication logic | Domain-internal only |
| **{domain}-biz** | **Core business orchestration**: composes dao/security/middleware to implement business flows | Only referenced by controller |
| **{domain}-controller** | REST endpoints, **independently deployable** | Exposes HTTP API externally |

### API Module Boundary (Critical)

**The api module is only referenced by two types of consumers:**
1. **The domain's own controller** — receives HTTP requests, deserializes them into Request objects
2. **External domains** — cross-domain calls that depend on the api module for DTO definitions (e.g., gateway depends on user-api)

**The biz layer never directly uses api Request/Response objects.** Data flows as follows:

```
HTTP Request
    ↓ (Spring deserialization)
XxxRequest (api module)
    ↓ (Controller converts)
XxxDTO (dao module)
    ↓ (Passed to Biz layer)
BizService processes, returns XxxDTO
    ↓ (Controller converts)
XxxResponse (api module)
    ↓ (Spring serialization)
HTTP Response
```

**The Controller is responsible for Request ↔ DTO ↔ Response conversion:**

```java
@PostMapping("/action")
public CompletionStage<ApiResult<XxxResponse>> action(@Valid @RequestBody XxxRequest request) {
    return CompletableFuture.supplyAsync(() -> {
        // 1. Controller converts Request → DTO
        XxxDTO dto = XxxDTO.builder()
                .field1(request.getField1())
                .field2(request.getField2())
                .build();

        // 2. Call Biz layer — both input and output are DTOs
        XxxDTO result = xxxBizService.doAction(dto);

        // 3. Controller converts DTO → Response
        XxxResponse response = XxxResponse.builder()
                .id(result.getId())
                .field1(result.getField1())
                .createdAt(result.getCreatedAt())
                .build();

        return ApiResult.success(response);
    }, bizThreadPool);
}
```

**Why this matters:**
- **Biz layer is decoupled from HTTP** — biz only knows DTOs, not Request/Response. Switching to RPC/MQ requires zero biz-layer changes
- **api module stays lightweight** — contains only interface contracts (validation annotations, etc.), does not leak into internal logic
- **Clear responsibilities** — Request is "the external world's language", DTO is "the internal world's language", Controller is the translation layer

### Dependency Rules

- **api module has zero business dependencies** — only Lombok + Validation annotations, so cross-domain references don't leak transitive dependencies
- **biz does not depend on api** — biz interface parameters and return values use DTOs only, never referencing Request/Response
- **dao does not depend on biz** — dao handles data access only, unaware of business logic
- **controller does not depend on dao** — controller accesses data only through the biz layer
- **No circular dependencies** — dependency direction is strictly top-down

---

## 3. Global Infrastructure Modules

### 3.1 common Module

**Purpose**: Shared low-level utilities for all modules. Contains no web dependencies.

Contents:
- **AOP validation frameworks** (BasicCheck + ValueCheckers)
- **ErrorCodeEnum** — global error code enumeration
- **BizException** — unified business exception
- **Utilities** (UidGenerator, etc.)
- **MyBatis Generator extension plugins**

```java
// Error codes: segmented by domain
public enum ErrorCodeEnum {
    // Common: 0-999
    OK(0, "Success"),
    UNKNOWN_ERROR(1, "Unknown error"),
    BAD_REQUEST(2, "Invalid request"),
    // ...

    // Domain A: 10000-10999
    // Domain B: 20000-20999
    // Each domain reserves 1000 error codes
}
```

```java
// Unified business exception: only accepts ErrorCodeEnum, no ad-hoc string messages
public class BizException extends RuntimeException {
    private ErrorCodeEnum errorCode;

    public BizException(ErrorCodeEnum errorCode, Object... args) { ... }
}
```

### 3.2 web-base Module

**Purpose**: Shared web infrastructure, depended on by all controller modules.

Contents:
- **ApiResult\<T\>** — unified response wrapper
- **Global exception handler** — @RestControllerAdvice
- **Thread pool configuration** — bizThreadPool
- **CORS configuration**
- **JSON serialization configuration**
- **Actuator + Prometheus monitoring**

```java
// Unified response format
public class ApiResult<T> implements Serializable {
    private boolean success;
    private int errorCode;
    private T data;
    private String errorMsg;

    public static <T> ApiResult<T> success(T data) { ... }

    public static <T> ApiResult<T> failed(ErrorCodeEnum errorCode) { ... }
}
```

### 3.3 Middleware Client Modules

**Purpose**: Each middleware is encapsulated as an independent module, imported by business domains as needed.

- `redis-client` — Redisson wrapper
- `mongo-client` — Spring Data MongoDB wrapper
- `kafka` (contains kafka-producer, kafka-client) — Kafka client wrapper

**Principle: Middleware modules contain no business logic — only connection/configuration/basic operation encapsulation.**

---

## 4. Controller Layer Coding Standard

### 4.1 Controller Template

```java
@RestController
@RequestMapping("/api/{domain}")
@RequiredArgsConstructor          // ← Constructor injection via final fields
public class XxxController {

    private final IXxxBizService xxxBizService;  // ← Only inject Biz layer interfaces

    @Autowired
    @Lazy
    private Executor bizThreadPool;              // ← Business thread pool

    @PostMapping("/action")
    public CompletionStage<ApiResult<XxxResponse>> action(
            @Valid @RequestBody XxxRequest request) {
        return CompletableFuture.supplyAsync(() -> {
            // 1. Request → DTO (Controller handles conversion)
            XxxDTO dto = XxxDTO.builder()
                    .field1(request.getField1())
                    .field2(request.getField2())
                    .build();

            // 2. Call Biz layer — both input and output are DTOs
            XxxDTO result = xxxBizService.doAction(dto);

            // 3. DTO → Response (Controller handles conversion)
            return ApiResult.success(XxxResponse.builder()
                    .id(result.getId())
                    .field1(result.getField1())
                    .build());
        }, bizThreadPool);
    }
}
```

### 4.2 Controller Layer Rules

1. **Zero business logic** — Controller does exactly four things: receive params, convert, call Biz, wrap response
2. **Fully async** — All endpoints return `CompletionStage<ApiResult<T>>`, executed via `bizThreadPool`
3. **Only inject Biz interfaces** — Never directly inject dao-layer Services or operate on the database
4. **Delegate validation to the framework** — `@Valid` + Jakarta Validation annotations on Request DTOs
5. **Never handle exceptions** — Exceptions are caught globally by `@RestControllerAdvice`
6. **Own the Request ↔ DTO ↔ Response conversion** — Controller is the translation layer between api and biz; Request/Response never penetrate into the Biz layer

---

## 5. Biz Layer Coding Standard

### 5.1 Core Philosophy: Methods as Documentation

The essence of the Biz layer is **orchestration** — a public method calls a sequence of steps, where each step is a semantically clear private method. **Reading the public method should feel like reading a business flowchart — no comments needed to understand what the business is doing.**

This principle applies recursively downward from the Biz layer: Biz calls Biz, Biz calls Service, Service internals — every layer should decompose complex logic into a set of clearly-named private methods. The end result: **anyone opening any method sees a sequence of method calls, not a block of procedural code. Want details? Click into a method. Don't care? Skip it. Drill down layer by layer, each level is crystal clear.**

### 5.2 Biz Service Template

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class XxxBizServiceImpl implements IXxxBizService {

    private final IDataService dataService;
    private final ISecurityService securityService;
    private final IExternalService externalService;

    /**
     * Public method: a numbered flowchart of the business process.
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public XxxDTO doAction(XxxDTO dto) {
        // 1. Decrypt sensitive field from request
        String decryptedValue = decryptSensitiveField(dto.getEncryptedField());
        // 2. Fill in default values and derived fields
        XxxDTO enrichedDto = enrichWithDefaults(dto, decryptedValue);
        // 3. Persist to database
        Long savedId = persistToDatabase(enrichedDto);
        // 4. Notify downstream systems
        notifyDownstream(savedId);
        // 5. Build and return result
        return buildResult(savedId, enrichedDto);
    }

    // ══════════════════════════════════════════════
    //  Each private method corresponds to one step
    //  in the business flow. The method name IS the
    //  documentation. Click in to see implementation.
    // ══════════════════════════════════════════════

    private String decryptSensitiveField(String encrypted) {
        log.debug("Decrypting sensitive field");
        try {
            String decrypted = securityService.decrypt(encrypted);
            log.info("Sensitive field decrypted successfully");
            return decrypted;
        } catch (Exception e) {
            log.warn("Sensitive field decryption failed: {}", e.getMessage());
            throw new BizException(ErrorCodeEnum.DECRYPT_FAILED);
        }
    }

    private XxxDTO enrichWithDefaults(XxxDTO dto, String decryptedValue) {
        String field2 = dto.getField2() != null ? dto.getField2() : "default";
        log.debug("Enriching defaults, field2={}", field2);
        return XxxDTO.builder()
                .field1(decryptedValue)
                .field2(field2)
                .build();
    }

    private Long persistToDatabase(XxxDTO dto) {
        Long id = dataService.save(dto);
        if (id == null) {
            log.warn("Database save returned null id");
            throw new BizException(ErrorCodeEnum.SAVE_FAILED);
        }
        log.info("Record persisted, id={}", id);
        return id;
    }

    private void notifyDownstream(Long id) {
        log.info("Sending downstream event, id={}", id);
        externalService.sendEvent(id);
        log.info("Downstream event sent successfully, id={}", id);
    }

    private XxxDTO buildResult(Long id, XxxDTO dto) {
        log.debug("Building result, id={}", id);
        return XxxDTO.builder()
                .id(id)
                .field1(dto.getField1())
                .field2(dto.getField2())
                .build();
    }
}
```

**Anti-pattern (do NOT write like this):**

```java
// ✗ Wrong: all logic flattened in the public method — reader must parse every line
@Override
public XxxDTO doAction(XxxDTO dto) {
    String decryptedValue;
    try {
        decryptedValue = securityService.decrypt(dto.getEncryptedField());
    } catch (Exception e) {
        throw new BizException(ErrorCodeEnum.DECRYPT_FAILED);
    }
    if (dto.getField2() == null) {
        dto.setField2("default");
    }
    dto.setField1(decryptedValue);
    Long id = dataService.save(dto);
    if (id == null) {
        throw new BizException(ErrorCodeEnum.SAVE_FAILED);
    }
    externalService.sendEvent(id);
    return XxxDTO.builder().id(id).field1(dto.getField1()).field2(dto.getField2()).build();
}
// The code above does exactly the same thing, but the reader must read every line
// to understand the business flow
```

### 5.3 Recursive Application: Every Layer Follows the Same Pattern

This approach is not limited to the Biz layer — **it applies recursively to every layer below**:

```
BizServiceA.doAction()                    ← Public method, reads like a business flow
  ├── validateInput(dto)                  ← Private method
  ├── bizServiceB.process(dto)            ← Calls another Biz — click in, same structure
  │     ├── checkPermission(dto)
  │     ├── transformData(dto)
  │     └── saveResult(dto)
  ├── daoService.save(dto)                ← Calls DAO Service — click in, same structure
  │     ├── generateId(dto)
  │     ├── toEntity(dto)
  │     └── mapper.insert(entity)
  └── buildResult(id, dto)                ← Private method
```

**Every layer's public method is a "table of contents"; private methods are "chapters". Want the overview? Read the TOC. Want details? Click into a chapter. You can stop at any level.**

### 5.4 Private Method Naming Convention

| Verb Prefix | Semantics | Example |
|-------------|-----------|---------|
| `validate` / `check` | Validate; throw on failure | `validateEmailUniqueness(email)` |
| `decrypt` / `encrypt` | Encryption/decryption | `decryptPassword(encrypted)` |
| `enrich` / `fill` | Populate defaults/derived fields | `enrichWithDefaults(dto)` |
| `persist` / `save` | Persist to storage | `persistToDatabase(dto)` |
| `notify` / `send` | Send notification/event | `notifyDownstream(id)` |
| `build` / `assemble` | Construct return object | `buildResult(id, dto)` |
| `query` / `find` / `fetch` | Query/retrieve | `findExistingUser(email)` |
| `transform` / `convert` | Convert data format | `transformToInternalFormat(raw)` |

### 5.5 Biz Layer Rules

1. **Business orchestration center** — Composes calls to dao, security, middleware, and other Services
2. **Public methods only orchestrate** — Public method bodies should contain only private method calls and simple variable passing; no if/try/for procedural logic
3. **Numbered step comments in public methods** — every line in the public method body must have a numbered comment (`// 1. ...`, `// 2. ...`) describing the business step. The public method is a numbered flowchart
4. **Private methods are atomic business units** — Each private method does exactly one thing; the method name describes that thing
4. **Transaction boundary at Biz layer** — `@Transactional` is only annotated on Biz public methods
5. **Use AOP for pre-validation** — Use `@ValueCheckers` or `@BasicCheck` for parameter/business validation; validation logic is extracted into a dedicated ValidationBizService
6. **Only throw BizException** — `throw new BizException(ErrorCodeEnum.XXX)`; never throw raw exceptions
7. **Sufficient logging in private methods** — every private method must log at entry or key outcome:
    - `log.info` — Key flow milestones (start, completion, data persisted, event sent)
    - `log.warn` — Expected failures (wrong password, validation failures)
    - `log.error` — Unexpected failures (database errors, service unavailability)
    - `log.debug` — Debug information (intermediate variables, detailed steps)
    - Goal: by reading logs alone, you can reconstruct the full business flow without looking at code
8. **Proactive common code extraction** — if the same logic appears in 2+ Biz services, immediately extract it:
    - **Where**: `{domain}-common` module for domain-internal shared logic; root `common` module for cross-domain utilities
    - **What qualifies**: data format conversion, validation patterns, string/date manipulation, common business calculations, retry wrappers
    - **How**: extract as static utility methods or shared Service interfaces; callers depend on the interface, not the implementation
    - **Do NOT over-abstract**: only extract when there is actual duplication or near-certain reuse

---

## 6. DAO Layer Coding Standard

### 6.1 Three-Tier Object Model

```
Entity (DB mapping)  ←→  DTO (Business transfer)  ←→  Request/Response (API transfer)
   dao module internal        Cross-layer passing           api module definition
```

| Object | Module | Responsibility |
|--------|--------|---------------|
| **Entity** | dao | Strict database table mapping, generated by MyBatis Generator |
| **DTO** | dao | Data carrier between layers, contains `toEntity()` / static `fromEntity()` conversion methods |
| **Request/Response** | api | HTTP interface input/output, carries validation annotations |

### 6.2 DAO Service Pattern

```java
// Interface: standard CRUD + domain-specific queries
public interface IXxxService {
    Long save(XxxDTO dto);

    int update(XxxDTO dto);

    int deleteById(Long id);

    XxxDTO findById(Long id);

    List<XxxDTO> findAll();
    // Domain-specific queries...
}

// Implementation: operates Mapper directly, handles Entity ↔ DTO conversion
@Service
public class XxxServiceImpl implements IXxxService {
    @Autowired
    private XxxMapper xxxMapper;   // Generated by MyBatis Generator

    @Override
    public Long save(XxxDTO dto) {
        if (dto.getId() == null) {
            dto.setId(UidGeneratorUtil.generateUid());  // Distributed ID generation
        }
        User entity = dto.toEntity();
        int result = xxxMapper.insertSelective(entity);
        return result > 0 ? entity.getId() : null;
    }
}
```

### 6.3 DAO Layer Rules

1. **Entities never leave the dao module** — Only DTOs are exposed externally
2. **DTOs own the conversion** — `toEntity()` and `fromEntity()` methods live in the DTO class
3. **Primary keys generated by UidGenerator** — No reliance on database auto-increment
4. **MyBatis Dynamic SQL** — Queries built with DSL, no XML mappers

---

## 7. API Module (DTO) Coding Standard

### 7.1 Request Pattern

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class XxxRequest {

    @NotBlank(message = "Field cannot be blank")
    private String field1;

    @NotNull(message = "Field cannot be null")
    private Long field2;

    // Optional fields have no validation annotations
    private String optionalField;
}
```

### 7.2 Response Pattern

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class XxxResponse {
    private Long id;
    private String field1;
    private LocalDateTime createdAt;
    // Responses have no validation annotations
}
```

### 7.3 API Module Rules

1. **Pure POJOs** — Only fields, Lombok annotations, and Validation annotations; no business methods
2. **Four-annotation standard** — `@Data` + `@AllArgsConstructor` + `@NoArgsConstructor` + `@Builder`
3. **Request and Response are strictly separate** — Even with highly overlapping fields, never reuse
4. **Cross-domain contract** — Other business domains depend only on this domain's api module

---

## 8. Exception Handling Standard

### 8.1 Exception Handling by Layer

```
Controller layer  →  Never catches exceptions; all propagate upward
                            ↓
Biz layer         →  Catches low-level exceptions, wraps as BizException(ErrorCodeEnum.XXX)
                            ↓
Global handler    →  @RestControllerAdvice catches all, converts to ApiResult
```

### 8.2 Global Exception Handler Coverage

| Exception Type | HTTP Status | Handling |
|----------------|-------------|----------|
| `BizException` | 200 | Returns `ApiResult.failed(errorCode)` |
| `MethodArgumentNotValidException` | 400 | Extracts field validation error messages |
| `ConstraintViolationException` | 400 | Extracts parameter validation error messages |
| `BindException` | 400 | Extracts form validation error messages |
| `HttpMessageNotReadableException` | 415 | Missing JSON body |
| `NoResourceFoundException` | 404 | Path not found |
| `HttpRequestMethodNotSupportedException` | 405 | Method not allowed |
| `AsyncRequestTimeoutException` | 408 | Async request timeout |
| `RejectedExecutionException` | 200 | Thread pool rejection |
| `Exception` (fallback) | 500 | Unknown error |

---

## 9. Naming Conventions

### 9.1 Module Naming

```
{domain}                    → Business domain aggregator POM
{domain}-api                → External DTOs
{domain}-common             → Domain-internal shared
{domain}-dao                → Data access
{domain}-biz                → Business orchestration
{domain}-security           → Security
{domain}-controller         → REST entry point (deployable)
```

### 9.2 Package Naming

```
com.company.project.{domain}.controller        → Controller classes
com.company.project.{domain}.biz.service       → Biz interfaces
com.company.project.{domain}.biz.service.impl  → Biz implementations
com.company.project.{domain}.service.interfaces → DAO Service interfaces
com.company.project.{domain}.service.impl      → DAO Service implementations
com.company.project.{domain}.model.entity      → Entities (DB mapping)
com.company.project.{domain}.model.dao         → MyBatis Mappers
com.company.project.{domain}.model.dto         → DTOs
com.company.project.{domain}.api.request       → Request DTOs
com.company.project.{domain}.api.response      → Response DTOs
```

### 9.3 Class Naming

| Type | Pattern | Example |
|------|---------|---------|
| Controller | `XxxController` | `UserLoginController` |
| Biz Interface | `IXxxBizService` | `IUserLoginBizService` |
| Biz Implementation | `XxxBizServiceImpl` | `UserLoginBizServiceImpl` |
| DAO Interface | `IXxxService` | `IUserService` |
| DAO Implementation | `XxxServiceImpl` | `UserServiceImpl` |
| Validation Biz | `XxxValidationBizServiceImpl` | `UserValidationBizServiceImpl` |
| Request | `XxxRequest` | `UserLoginRequest` |
| Response | `XxxResponse` | `UserLoginResponse` |
| Entity | Table name in PascalCase | `User` |
| DTO | `XxxDTO` | `UserDTO` |
| Exception | `BizException` (global singleton) | — |
| Error Code | `ErrorCodeEnum` (global singleton) | — |

### 9.4 Interface Prefix `I`

- All Service interfaces are prefixed with `I`: `IUserService`, `IUserLoginBizService`
- All implementations are suffixed with `Impl`: `UserServiceImpl`, `UserLoginBizServiceImpl`

---

## 10. Request Lifecycle (End-to-End Call Chain)

```
HTTP Request
  │
  ▼
┌──────────────────────────────────────────────────────────┐
│ Gateway (Spring Cloud Gateway)                           │
│  • Route forwarding                                      │
│  • JWT validation filter                                 │
│  • Injects X-USER-ID and other headers                   │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ Controller Layer                                         │
│  1. @Valid parameter validation (framework-automatic)    │
│  2. Request → DTO conversion                             │
│  3. CompletableFuture.supplyAsync(bizThreadPool)         │
│  4. Call BizService method (pass DTO, receive DTO)       │
│  5. DTO → Response conversion                            │
│  6. Wrap with ApiResult.success(response)                │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ Biz Layer (only knows DTOs; unaware of Request/Response) │
│  1. @ValueCheckers AOP pre-validation (DB check → TL)   │
│  2. @Transactional transaction control                   │
│  3. Orchestrates multiple underlying Services:           │
│     • DAO Service → data read/write                      │
│     • Security Service → crypto/JWT                      │
│     • Middleware Client → Redis/Kafka                    │
│  4. Failure → throw BizException(ErrorCodeEnum)          │
│  5. Success → return DTO.builder()...build()             │
└──────────────────────┬───────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ DAO Layer                                                │
│  1. DTO → Entity (toEntity)                              │
│  2. MyBatis Mapper operates on database                  │
│  3. Entity → DTO (fromEntity)                            │
│  4. Returns DTO to Biz layer                             │
└──────────────────────────────────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────────┐
│ Global Exception Handler (@RestControllerAdvice)         │
│  • BizException → ApiResult.failed(errorCode)            │
│  • ValidationException → ApiResult.failed(BAD_REQUEST)   │
│  • Exception → ApiResult.failed(UNKNOWN_ERROR)           │
└──────────────────────────────────────────────────────────┘
```

---

## 11. Lombok Usage Standard

| Annotation | Usage |
|------------|-------|
| `@Data` | All POJOs (DTO, Request, Response) |
| `@Builder` | All objects that need to be constructed |
| `@AllArgsConstructor` + `@NoArgsConstructor` | Used with `@Builder` (Builder needs all-args constructor; framework deserialization needs no-args) |
| `@RequiredArgsConstructor` | Service classes (combined with `private final` fields for constructor injection) |
| `@Slf4j` | All Service classes that need logging |
| `@Getter` + `@Setter` | Rare cases where `@Data` is not appropriate (e.g., Exception classes) |

---

## 12. Dependency Injection Standard

| Method | When to Use |
|--------|-------------|
| `@RequiredArgsConstructor` + `private final` | **Preferred** — for Service class dependency injection |
| `@Autowired` | Only for non-final fields (e.g., `@Lazy` thread pool) |
| Explicit constructor injection | Not used — delegated to Lombok |

---

## 13. New Business Domain Checklist

When adding a new business domain `{domain}`, follow these steps:

1. Create `{domain}/pom.xml` (aggregator POM, `packaging=pom`), parent points to root POM
2. Add `<module>{domain}</module>` to the root POM's `<modules>`
3. Create sub-modules:
    - `{domain}-api` — Request/Response DTOs
    - `{domain}-common` — Domain-internal enums, constants
    - `{domain}-dao` — Entity + Mapper + DAO Service + DTO
    - `{domain}-biz` — Business orchestration Services
    - `{domain}-controller` — REST endpoints + Spring Boot application class
4. Allocate an error code segment in `ErrorCodeEnum` (e.g., 30000-30999)
5. Add `spring-boot-maven-plugin` to `{domain}-controller`'s POM
6. Create `ControllerApplication.java` startup class
