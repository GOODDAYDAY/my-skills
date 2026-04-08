---
name: req-security
description: Security review — detect data security issues and code vulnerabilities (fix critical/high, report medium/low)
argument-hint: "[REQ-xxx]"
orchestrator: req
applicable_when: |
  Source code for this REQ exists and is reasonably complete, and no security
  review report has been produced yet (or the previous report is stale because
  code changed significantly since).
---

You are invoked by the `req` orchestrator to review all code produced by this requirement for security vulnerabilities. Do one bounded round and return control.

## Flow

### Step 1: Load Context

1. Read `requirements/REQ-xxx-*/requirement.md` — understand business scenarios and data flow
2. Read `requirements/REQ-xxx-*/technical.md` — understand architecture and module design
3. Locate all source code files produced by this requirement

### Step 2: Security Vulnerability Scan

For all code produced by this requirement, check the following security dimensions:

#### 2.1 Injection Attacks
- **SQL injection** — string concatenation in SQL? Must use parameterized queries / prepared statements
- **Command injection** — user input directly concatenated into system commands?
- **XSS (Cross-Site Scripting)** — user input escaped before rendering to page?
- **LDAP / XML / SSRF injection** — external input used without sanitization?

#### 2.2 Data Leakage
- **Sensitive data in plaintext** — passwords, keys, tokens stored without encryption?
- **Log leakage** — passwords, tokens, ID numbers, or other PII printed in logs?
- **Error info leakage** — exception responses exposing internal stack traces, DB schemas?
- **Hardcoded secrets** — API keys, database passwords, or other secrets hardcoded in source?

#### 2.3 Authentication & Authorization
- **Privilege escalation** — horizontal (accessing other users' data) or vertical (normal user performing admin operations)?
- **Auth bypass** — any path that can bypass login / permission checks?
- **Session management** — session/token expiration? Replay attack protection?

#### 2.4 Data Safety
- **Input validation** — all external inputs (user input, API params, file uploads) validated and sanitized?
- **File operations** — file upload type/size restricted? File paths protected against directory traversal?
- **Crypto algorithms** — any deprecated/insecure algorithms used (e.g., MD5/SHA1 for passwords)?

#### 2.5 Dependency Security
- **Third-party dependencies** — known vulnerabilities in used libraries/frameworks?
- **Version security** — dependency versions outdated? Security patches not applied?

#### 2.6 Configuration Security
- **CORS config** — cross-origin policy too permissive?
- **HTTPS** — HTTPS enforced? HTTP downgrade risk?
- **Default config** — framework/middleware default passwords and configs changed?

### Step 3: Output Security Review Report

```markdown
## Security Review Report

### Scan Scope
- Files scanned: X
- Modules: [list]

### Findings

| # | Severity | Category | Location | Description | Fix |
|:---|:---|:---|:---|:---|:---|
| S-01 | Critical | SQL injection | src/xxx.py:L20 | SQL built with string concatenation | Use parameterized query |
| S-02 | High | Data leakage | src/yyy.py:L45 | User password printed in log | Remove sensitive data from log |
| S-03 | Medium | Config | config/cors.py:L10 | CORS allows all origins | Restrict to specific domains |
| S-04 | Low | Best practice | src/zzz.py:L30 | Cookie missing HttpOnly flag | Add HttpOnly attribute |

### Severity Summary
- Critical: X
- High: X
- Medium: X
- Low: X

### Conclusion
- [ ] PASS — no security issues found
- [ ] CONDITIONAL PASS — only low-risk issues, fix recommended
- [ ] FAIL — critical/high-risk issues found, must fix before proceeding
```

Severity definitions:
- **Critical** — can directly lead to data breach or system compromise (SQL injection, hardcoded keys)
- **High** — exploitable security risk (privilege escalation, sensitive data in logs)
- **Medium** — security concern but harder to exploit (CORS misconfiguration)
- **Low** — security best practice recommendation (missing cookie flags)

### Step 4: Fix Issues

For **Critical and High** severity issues — **fix the code directly**:
1. Fix each issue one by one
2. Briefly explain the fix for each
3. Re-verify after fixing to confirm the issue is resolved

For **Medium and Low** severity issues:
- Present to user, ask whether to fix
- Fix after user confirms

### Step 5: Persist the Report

Write the security review report as `security-review.md` inside the REQ directory (or append to an existing security log). The orchestrator reads this on next observation to judge that the review was done. Update `requirements/index.md`'s `Updated` column.

### Handoff

本轮完成，控制权返还编排器。
