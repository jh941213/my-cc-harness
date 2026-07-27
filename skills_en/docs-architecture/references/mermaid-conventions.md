# Mermaid Diagram Conventions (shared across the docs suite)

Common rules: use ` ```mermaid ` fenced blocks in-repo (GitHub/GitLab render natively), 1 diagram = 1 concern, ≤15-20 nodes. CI validation via `mmdc` (see docs-ci skill).

## C4 Context

```mermaid
C4Context
  title System Context — Billing System
  Person(user, "Customer", "Pays invoices")
  System(billing, "Billing System", "Issues and settles invoices")
  System_Ext(stripe, "Stripe", "External payment processor")
  Rel(user, billing, "Uses", "HTTPS")
  Rel(billing, stripe, "Charges via", "REST")
```

## C4 Container

```mermaid
C4Container
  title Container — Billing System
  Person(user, "Customer")
  System_Boundary(b, "Billing System") {
    Container(web, "Web App", "Next.js", "Payment UI")
    Container(api, "API", "FastAPI", "Business logic")
    ContainerDb(db, "DB", "PostgreSQL", "Invoice/customer data")
  }
  System_Ext(stripe, "Stripe")
  Rel(user, web, "Uses")
  Rel(web, api, "Calls", "JSON/HTTPS")
  Rel(api, db, "Reads/writes", "SQL")
  Rel(api, stripe, "Charges", "REST")
  UpdateLayoutConfig($c4ShapeInRow="3")
```

Note: mermaid C4 is still experimental — stick to the stable subset above. For Component-level detail, `flowchart TB` + `subgraph` lays out better.

## Sequence — interface flows

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
  alt validation fails
    A-->>C: 422
  end
```

Conventions: always `autonumber`, declare participants up front, `->>` sync / `-)` async, branches via `alt`/`opt`/`par`.

## ERD — data model

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

Conventions: crow's-foot cardinality (`||` exactly one, `o{` zero-or-many, `|{` one-or-many), `PK/FK/UK` markers, `--` identifying vs `..` non-identifying.

## architecture-beta — infra/deployment topology (v11.1+)

```mermaid
architecture-beta
  group cloud(cloud)[Production]
  service lb(internet)[Load Balancer] in cloud
  service app(server)[App Server] in cloud
  service db(database)[PostgreSQL] in cloud
  lb:R -- L:app
  app:R -- L:db
```

Prefer architecture-beta for infra/CI-CD topology; use C4Deployment (`Deployment_Node` nesting) when staying inside the C4 family.
