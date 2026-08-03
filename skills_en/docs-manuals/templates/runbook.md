# Runbook Template

````markdown
# Runbook: {alert name}

- Alert: {alert rule name + link}
- Severity: {P1/P2/P3} — User impact: {what stops working}
- Last reviewed: {YYYY-MM-DD} / Owner: {team/role}

## Symptoms

- {what is observable from the user/system perspective}

## Diagnosis (in order)

1. Check dashboard: {dashboard link}
   - Normal baseline: {metric X < N}
2. Log query (paste-ready):
   ```
   {actually runnable query}
   ```
3. Branch:
   - {if pattern A} → likely cause 1 → Mitigation §1
   - {if pattern B} → likely cause 2 → Mitigation §2
   - Neither → escalate

## Mitigation

### 1. {for likely cause 1}
```bash
{paste-ready command}
```
⚠️ Trade-off: {side effect — e.g., cache reset raises latency for ~5 min}

### 2. {for likely cause 2}
```bash
{paste-ready command}
```

## Verification

- {metric/command proving the mitigation worked}

## Root fix / follow-up

- [ ] {what must happen after mitigation — ticket criteria}

## Escalation

- If unresolved within {N min} → {who, via which channel}
- Related docs: {architecture/deployment guide links}
````
