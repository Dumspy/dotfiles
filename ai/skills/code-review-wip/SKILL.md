---
name: code-review
description: Comprehensive code review for pull requests and code changes. Perform systematic review for bugs, performance issues, design assessment, and test coverage. Covers runtime errors, API design, database queries, and architectural alignment. Use when reviewing PRs, examining changes, or providing code quality feedback.
---

# Code Review

Perform systematic code review for pull requests and code changes.

## Phase 1: Complete Input Gathering

1. Get the FULL diff:
   ```bash
   git diff $(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')...HEAD
   ```
2. If output is truncated, read each changed file individually until you have seen every changed line
3. List all files modified in this branch before proceeding

## Phase 1.5: Load Language-Specific Guide

After identifying changed files, load the appropriate language reference based on file extensions or framework indicators:

| Indicators | Guide |
|------------|-------|
| `.nix`, `flake.nix`, `configuration.nix` | `languages/nix.md` |

Read the relevant language guide(s) before proceeding to Phase 2.

## Phase 2: Identify Potential Issues

For each changed file, identify and check for:

### Runtime Errors
- Potential exceptions: null/undefined access, out-of-bounds access
- Unhandled promise rejections or errors
- Missing error handling on external calls
- Type coercion issues
- Missing null checks or guard clauses

### Performance
- Unbounded O(n²) operations in data processing
- N+1 query patterns in database access
- Unnecessary allocations in tight loops
- Missing pagination on large datasets
- Inefficient string concatenation or template operations
- Synchronous operations in async contexts

### Side Effects
- Unintended mutations of shared state
- Global state modifications
- Changes that affect other components not reviewed
- Silent failures (swallowed errors)
- Unintended behavioral changes affecting other components

### Backwards Compatibility
- Breaking API changes without migration path
- Removed parameters or return values
- Changed behavior without version bump
- Environment-specific assumptions

### Data Quality
- Missing validation on user inputs
- Race conditions in read-then-write patterns
- Missing transaction boundaries
- Inconsistent error handling

### Security Issues (Basic)
- SQL injection vulnerabilities
- XSS vulnerabilities in outputs
- Authentication/authorization gaps
- Secrets exposure in code or logs
- Missing CSRF protection on state-changing operations

### ORM Queries
- Complex Django ORM with unexpected query performance
- Missing indexes on frequently queried fields
- Eager loading missing on related objects

## Phase 3: Design Assessment

- Do component interactions make logical sense?
- Does the change align with existing project architecture?
- Are there conflicts with current requirements or goals?
- Is the abstraction level appropriate?
- Are responsibilities clearly separated?
- Does this introduce tight coupling?

## Phase 4: Test Coverage

Every PR should have appropriate test coverage:
- Functional tests for business logic
- Integration tests for component interactions
- End-to-end tests for critical user paths

Verify tests:
- Cover actual requirements and edge cases
- Are not brittle (coupled to implementation details)
- Avoid excessive branching or looping in test code
- Include meaningful assertions
- Test failure modes, not just success paths

## Phase 5: Long-Term Impact

Flag for senior engineer review when changes involve:
- Database schema modifications
- API contract changes
- New framework or library adoption
- Performance-critical code paths
- Security-sensitive functionality

## Phase 6: Pre-Conclusion Audit

Before finalizing, you MUST:
1. List every file you reviewed and confirm you read it completely
2. List every category and note whether you found issues or confirmed it's clean
3. List any areas you could NOT fully verify and why
4. Only then provide your final findings

## Output Format

**Prioritize**: runtime errors > security vulnerabilities > performance > design > compatibility

**Skip**: stylistic/formatting issues (use linters for these)

For each issue:

### Runtime Errors
```
[ERROR-001] [Type] - file:line
Problem: Clear description of issue
Impact: What breaks or what could happen
Evidence: Code snippet showing the problem
Fix: Concrete, actionable suggestion
```

### Security Vulnerabilities
```
[SEC-001] [Type] - file:line
Severity: Critical/High/Medium/Low
Problem: Description of vulnerability
Impact: What an attacker could do
Evidence: Code snippet
Fix: How to remediate
```

### Performance Issues
```
[PERF-001] [Type] - file:line
Problem: Description of performance bottleneck
Impact: Performance degradation or scalability issue
Evidence: Code snippet or complexity analysis
Fix: Optimization suggestion
```

### Design Issues
```
[DESIGN-001] [Type] - file:line or general
Issue: Design concern or architectural misalignment
Rationale: Why this matters
Suggestion: Alternative approach or recommendation
```

### Testing Gaps
```
[TEST-001] Missing coverage - Component/Function
Issue: What needs testing
Risk: What could break without tests
Suggestion: Test scenarios to add
```

### Compatibility Issues
```
[COMPAT-001] Breaking change - Location
Issue: What changed that breaks compatibility
Impact: Who/what is affected
Fix: Migration path or version bump recommendation
```

## Feedback Guidelines

- Be polite and empathetic in your feedback
- Provide actionable suggestions, not vague criticism
- Phrase as questions when uncertain: "Have you considered...?"
- Approve when only minor issues remain
- Don't block PRs for stylistic preferences
- Remember: the goal is risk reduction, not perfect code

## When No Issues Found

If you find nothing significant, say so - don't invent issues.

## Final Checklist

Before completing the review, verify:
- [ ] All changed files read completely
- [ ] Every category checked
- [ ] Runtime errors identified
- [ ] Security issues flagged
- [ ] Performance issues identified
- [ ] Design assessed
- [ ] Test coverage reviewed
- [ ] Evidence provided for all findings
- [ ] Fix suggestions are concrete and actionable
