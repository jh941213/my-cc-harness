---
name: eval
description: "코드 산출물을 4축(기능/품질/독창성/보안)으로 평가하고 점수 산출. Evaluator 에이전트를 스폰하여 독립 평가 실행. Triggers on: eval, 평가, 품질 점수, 코드 평가, quality score. NOT for: 코드 작성, 구현, 리뷰."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# 코드 Eval (독립 평가)

Generator(구현자)와 분리된 Evaluator 에이전트를 스폰하여 산출물을 독립 평가합니다.

## 실행 프로세스

### Step 1: Evaluator 에이전트 스폰

```
Agent(subagent_type="evaluator",
  prompt="~/.claude/agents/evaluator.md를 읽고 현재 프로젝트를 평가하라.
         4축(기능 정확성/코드 품질/독창성/사용성&보안) 100점 만점.
         결과를 EVAL_REPORT.md에 저장.")
```

### Step 2: 결과 확인

Evaluator가 완료되면 EVAL_REPORT.md를 읽고 사용자에게 요약 보고:

```
📊 Eval 결과: [PASS/CONDITIONAL/FAIL] — [N]/100점

기능 정확성: [N]/40 | 코드 품질: [N]/25
독창성: [N]/20 | 사용성&보안: [N]/15

[수정 필요 항목 요약]
```

### Step 3: CONDITIONAL/FAIL 시

수정 필요 항목을 구체적으로 안내하고, 수정 후 재평가할지 질문.
재평가 시 동일 기준 적용 (최대 5라운드).

## pass@k 멱등성 테스트 (선택)

동일 프롬프트로 k회 실행하여 품질 일관성을 측정:

```bash
# k=3 실행 예시
for i in 1 2 3; do
  /eval 실행 → 점수 기록
done
# 3회 모두 85+ → 멱등성 확보
# 점수 분산 > 15점 → 불안정 (하네스 조정 필요)
```

수준의 멱등성: 정확히 같은 코드가 아니라 **같은 품질 수준**이 유지되는지 측정.
