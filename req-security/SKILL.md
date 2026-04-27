---
name: req-security
description: Security review — detect data security issues and code vulnerabilities (fix critical/high, report medium/low)
argument-hint: "[domain/scenario]"
---

# req-security: Security Review Stage
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Role & Scope
You are responsible for the security review stage. Review all code produced for this scenario for security vulnerabilities.

## 2. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- Coding must be complete
- Scenario document and source code must be ready

## 3. Steps

### 3.1 Load Context
1. Read the domain scenario document — understand business scenarios and data flow
2. Read `requirements/architecture.md` — understand architecture
3. Locate all source code files produced for this scenario

### 3.2 Security Vulnerability Scan

For all code produced for this scenario, check the following six dimensions:

#### 3.2.1 Injection Attacks
- **SQL injection** — string concatenation in SQL? Must use parameterized queries
- **Command injection** — user input in system commands?
- **XSS** — user input escaped before rendering?
- **LDAP / XML / SSRF injection** — external input sanitized?

#### 3.2.2 Data Leakage
- **Sensitive data in plaintext** — passwords, keys, tokens stored without encryption?
- **Log leakage** — PII printed in logs?
- **Error info leakage** — stack traces exposed to users?
- **Hardcoded secrets** — API keys, passwords in source?

#### 3.2.3 Authentication & Authorization
- **Privilege escalation** — horizontal or vertical?
- **Auth bypass** — paths that skip login/permission checks?
- **Session management** — token expiration? Replay protection?

#### 3.2.4 Data Safety
- **Input validation** — all external inputs validated?
- **File operations** — upload restrictions? Path traversal protection?
- **Crypto algorithms** — deprecated algorithms (MD5/SHA1 for passwords)?

#### 3.2.5 Dependency Security
- **Known vulnerabilities** in used libraries?
- **Outdated versions** missing security patches?

#### 3.2.6 Configuration Security
- **CORS** — too permissive?
- **HTTPS** — enforced?
- **Default configs** — default passwords changed?

### 3.3 Output Security Review Report

```markdown
## Security Review Report

### Scan Scope
- Files scanned: X
- Modules: [list]

### Findings

| # | Severity | Category | Location | Description | Fix |
|:---|:---|:---|:---|:---|:---|
| S-01 | Critical | SQL injection | src/xxx.py:L20 | SQL with string concat | Use parameterized query |

### Severity Summary
- Critical: X | High: X | Medium: X | Low: X

### Conclusion
- [ ] PASS — no security issues
- [ ] CONDITIONAL PASS — low-risk issues only
- [ ] FAIL — critical/high issues, must fix
```

### 3.4 Fix Issues
- **Critical and High** — fix directly, re-verify
- **Medium and Low** — present to user, fix after confirmation

### 3.5 Commit
```bash
git add -A && git commit -m "fix({domain}): security review — {scenario}"
```

Stage complete. Return to orchestrator.
