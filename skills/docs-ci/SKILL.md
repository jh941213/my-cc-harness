---
name: docs-ci
description: "docs-as-code CI/CD 파이프라인 스캐폴딩 + 문서 드리프트 감지 — 링크 체크, OpenAPI lint/breaking 게이트, mermaid 검증, 문서 신선도 검사, CHANGELOG 자동화, docs.yaml 매니페스트"
when_to_use: "docs CI/문서 파이프라인 설치, 문서 드리프트·신선도 감지, docs sync 자동화, 링크 체크, changelog 자동화가 필요할 때. 문서 내용 작성은 docs-architecture/interfaces/manuals, 앱 자체 배포 파이프라인에는 사용하지 않음"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Docs CI 스킬 — 문서를 코드처럼 검증한다

문서 내용이 아니라 **문서를 지키는 파이프라인**을 만든다. 산출물은 GitHub Actions 워크플로우 + 드리프트 감지 스크립트 + `docs/docs.yaml` 매니페스트 규약.

## 입력

$ARGUMENTS

## docs.yaml 매니페스트 (드리프트 감지의 계약)

docs 스위트의 모든 스킬이 쓰고, 이 스킬의 검사가 소비한다:

```yaml
# docs/docs.yaml — 문서 ↔ 코드 매핑
docs:
  - path: docs/ARCHITECTURE.md
    covers: ["src/**"]          # 이 문서가 설명하는 코드 경로
    last_reviewed: 2026-07-27   # 마지막으로 사람이/에이전트가 검토한 날
  - path: docs/api/openapi.yaml
    covers: ["src/api/**", "src/routes/**"]
    last_reviewed: 2026-07-27
  - path: docs/ops/runbooks/
    covers: ["deploy/**", "monitoring/**"]
    last_reviewed: 2026-07-27
review_max_age_days: 90
```

**드리프트 판정**: `covers` 경로의 최신 커밋이 `last_reviewed`보다 새로우면 stale. `review_max_age_days` 초과도 stale.

## 설치하는 검사 (프로젝트에 맞게 선택)

| 검사 | 도구/방법 | 실패 정책 |
|------|----------|----------|
| 깨진 링크 | lychee (`lycheeverse/lychee-action`) | 내부 링크 깨짐 = fail, 외부 = warn |
| OpenAPI 스타일 | `redocly lint` 또는 `spectral lint` | fail |
| API breaking 변경 | `oasdiff breaking base rev --fail-on ERR` | fail + PR 코멘트 |
| Code-first 명세 드리프트 | CI에서 명세 재생성 → `git diff --exit-code` | fail |
| mermaid 문법 | 블록 추출 → `mmdc -i x.mmd -o /dev/null` | fail |
| 문서 신선도 | `scripts/check-docs-freshness.sh` (docs.yaml 기반) | warn (또는 이슈 생성) |
| 문서-코드 동시 변경 | `src/api/** 변경 && docs/api/** 미변경` → PR 경고 코멘트 | warn |
| CHANGELOG | conventional commits + `git cliff` (릴리스 시) | 자동 생성 |
| 프리뷰 배포 | docs 사이트 있으면 PR별 프리뷰 URL | — |

## 실행 절차

1. **프로젝트 진단**: 어떤 문서/명세가 존재하나 (`docs/`, `openapi.*`, mermaid 블록, docs 사이트 생성기)
2. 존재하는 것에 맞는 검사만 선택 — OpenAPI 없는 프로젝트에 spectral 게이트 넣지 않기
3. `docs/docs.yaml` 생성/갱신 (기존 문서 스캔해서 covers 초안 작성 — 사용자가 다듬을 수 있게 주석 포함)
4. `scripts/check-docs-freshness.sh` 생성 (템플릿: `templates/check-docs-freshness.sh`)
5. `.github/workflows/docs-ci.yml` 생성 (템플릿: `templates/docs-ci.yml`에서 해당 프로젝트에 필요한 잡만)
6. 로컬에서 1회 실행해 결과 확인 후 보고: `bash scripts/check-docs-freshness.sh`

## 하네스 연동 (이 플러그인의 다른 컴포넌트와)

- TTH 모드: `hooks/docs-sync.sh`가 스토리 완료마다 변경 파일을 `.docs-queue/`에 적재 → ralph-loop가 docs-writer 스폰. **docs-ci는 그 결과를 CI에서 다시 검증**하는 마지막 층
- `/docs sync` 커맨드: docs.yaml 기반 stale 문서 목록을 보고 → 해당 영역의 docs-* 스킬로 갱신 위임

## 제약

- 워크플로우/스크립트/`docs/`만 생성. 앱 소스 수정 금지
- 설치 안 된 도구를 요구하는 검사는 `continue-on-error` 또는 조건부(`if: hashFiles(...)`)로
- 기존 CI 워크플로우가 있으면 덮어쓰지 말고 별도 `docs-ci.yml`로 추가
