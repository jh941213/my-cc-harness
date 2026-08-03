#!/bin/sh
# UserPromptSubmit: stdout is injected into Claude's context for this turn.
cat >/dev/null 2>&1 || :
echo '[work-protocol] 다단계/파일수정 작업이면: (1) 시작 전 todo 목록(tasks/todo.md + todo 패널) 생성, 작업 유형에 맞는 메모리만 auto-memory 스킬로 로드. (2) 30분+ 장기 작업이면 tasks/context.md에 목표/결정/다음단계 유지. (3) 완료 후 tasks/lessons.md에 교훈 기록, 재사용 지식은 memory/{주제}.md에 라우팅. 단순 질답이면 전부 생략.'
exit 0
