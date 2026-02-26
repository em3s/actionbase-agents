# Security Rules (CRITICAL)

## Pre-commit Checklist

Verify before every commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user input validated
- [ ] API endpoint inputs sanitized
- [ ] Error messages contain no sensitive information

## Secret Management

```kotlin
// NEVER: Hardcoded
val apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variable
val apiKey = System.getenv("API_KEY")
    ?: throw IllegalStateException("API_KEY not configured")
```

## Review Checklist (by priority)

### CRITICAL
- Hardcoded credentials
- Storage injection risks
- Missing input validation
- Authentication/authorization issues

### HIGH
- Sensitive information in error handling
- Secrets in logs
- Dependency vulnerabilities

### MEDIUM
- CORS configuration
- Rate limiting
- Session management

## When a Security Issue Is Found

1. Stop immediately
2. Fix CRITICAL issues first
3. Rotate exposed secrets
4. Check entire codebase for similar issues
