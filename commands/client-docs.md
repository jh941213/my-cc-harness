---
description: "고객 제출 산출물 온디맨드 생성 — 아키텍처/인터페이스/DB설계서, RTM, 테스트결과서, 매뉴얼, 운영보고서"
argument-hint: "[arch|api|db|rtm|test|manual|ops|report]"
---

client-docs 스킬을 사용해 고객 제출 산출물을 생성합니다.

입력: $ARGUMENTS

## 라우팅

| 호출 | 산출물 |
|------|--------|
| `/client-docs arch` | 아키텍처설계서 (← docs/ARCHITECTURE.md, 구성도, ERD) |
| `/client-docs api` | 인터페이스설계서 (← docs/api/ OpenAPI) |
| `/client-docs db` | DB설계서·테이블정의서 (← ERD, 모델 코드) |
| `/client-docs rtm` | 요구사항정의서·추적표 (← SPEC.md/PRD.md + 구현·테스트 매핑) |
| `/client-docs test` | 단위/통합테스트결과서 (← 실제 pytest/CI 실행 출력) |
| `/client-docs manual` | 사용자 매뉴얼 (← docs/manuals/) |
| `/client-docs ops` | 운영자 매뉴얼·이관 문서 (← docs/ops/) |
| `/client-docs report` | AO 운영보고서 (← AUDIT.log, 장애·변경 기록; 기간 확인) |
| `/client-docs` (인자 없음) | 생성 가능한 산출물 목록과 원재료 준비 상태를 보여주고 선택받기 |

## 절차

1. client-docs 스킬 로드 후 해당 산출물의 원재료 존재 확인
2. 원재료 없으면 먼저 생성 제안 (/docs arch 등) — 사용자 확인 후 진행
3. `deliverables/[산출물명]_[날짜].md` 생성 (고객 양식 템플릿 있으면 양식 우선)
4. 확인 안 된 항목은 `[확인 필요]` 표시 — 추정으로 채우지 않음
