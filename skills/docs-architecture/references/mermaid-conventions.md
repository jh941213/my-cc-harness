# Mermaid 다이어그램 관례 (docs 스위트 공용)

공통 규칙: 레포 내 ` ```mermaid ` 펜스 블록 사용(GitHub/GitLab 네이티브 렌더), 다이어그램 1개 = 관심사 1개, 노드 15-20개 이하. CI 검증은 `mmdc`(docs-ci 스킬 참조).

## C4 Context — 시스템 컨텍스트 구성도

```mermaid
C4Context
  title System Context — 결제 시스템
  Person(user, "고객", "인보이스를 결제")
  System(billing, "Billing System", "인보이스 발행/정산")
  System_Ext(stripe, "Stripe", "외부 결제 프로세서")
  Rel(user, billing, "사용", "HTTPS")
  Rel(billing, stripe, "결제 요청", "REST")
```

## C4 Container — 컨테이너 구성도

```mermaid
C4Container
  title Container — Billing System
  Person(user, "고객")
  System_Boundary(b, "Billing System") {
    Container(web, "Web App", "Next.js", "결제 UI")
    Container(api, "API", "FastAPI", "비즈니스 로직")
    ContainerDb(db, "DB", "PostgreSQL", "인보이스/고객 데이터")
  }
  System_Ext(stripe, "Stripe")
  Rel(user, web, "사용")
  Rel(web, api, "호출", "JSON/HTTPS")
  Rel(api, db, "읽기/쓰기", "SQL")
  Rel(api, stripe, "결제", "REST")
  UpdateLayoutConfig($c4ShapeInRow="3")
```

주의: mermaid C4는 아직 experimental — 위 안정 서브셋만 사용. Component 레벨 상세는 `flowchart TB` + `subgraph`가 레이아웃이 더 좋다.

## Sequence — 인터페이스 흐름도

```mermaid
sequenceDiagram
  autonumber
  participant C as Client
  participant A as API
  participant Q as Queue
  C->>A: POST /invoices
  activate A
  A-->>C: 202 Accepted
  deactivate A
  A-)Q: invoice.created
  alt 검증 실패
    A-->>C: 422
  end
```

관례: `autonumber` 항상 사용, participant 상단 선언, `->>` 동기 / `-)` 비동기, 분기는 `alt`/`opt`/`par`.

## ERD — 데이터 모델

```mermaid
erDiagram
  CUSTOMER ||--o{ INVOICE : places
  INVOICE ||--|{ LINE_ITEM : contains
  CUSTOMER {
    uuid id PK
    string email UK
  }
  INVOICE {
    uuid id PK
    uuid customer_id FK
    string status
  }
```

관례: 까마귀발 표기(`||` 정확히 1, `o{` 0..N, `|{` 1..N), `PK/FK/UK` 마커, `--` 식별 관계 / `..` 비식별 관계.

## architecture-beta — 인프라/배포 구성도 (v11.1+)

```mermaid
architecture-beta
  group cloud(cloud)[Production]
  service lb(internet)[Load Balancer] in cloud
  service app(server)[App Server] in cloud
  service db(database)[PostgreSQL] in cloud
  lb:R -- L:app
  app:R -- L:db
```

인프라/CI-CD 토폴로지는 architecture-beta 우선, C4 패밀리 안에서 통일하고 싶으면 C4Deployment(`Deployment_Node` 중첩) 사용.
