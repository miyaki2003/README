```mermaid
erDiagram
  users ||--o{ boards : "1対多"

    users {
        index  id PK
        string name
        string email
        string password
        string sector
    }

  boards {
        index  id PK
        index user_id FK
        string name
        datetime created_at
        datetime updated_at
  }
```