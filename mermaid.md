```mermaid
erDiagram
  Users ||--o{ Calendars : "1対多"
  Calendars ||--o{ Events : "1対多"
  Events ||--o{ EventReminders : "1対多"
  Users ||--o{ LINENotifications : "1対多"

    Users {
      index id PK "ユーザーID"
      string email "メールアドレス"
      string password "パスワード"
      string line_user_id "LINEユーザーID"
    }

    Calendars {
      index id PK "カレンダーID"
      integer user_id　FK "ユーザーID"
      string name "カレンダー名"
    }

    Events {
      index id PK "イベントID"
      integer calendar_id FK "カレンダーID"
      string title "タイトル"
      datetime start_at "開始日時"
      datetime end_at "終了日時"
      datetime created_at "作成日"
      datetime updated_at "更新日"
  }

    EventReminders {
      index id PK "リマインダーID"
      integer event_id FK "イベントID"
      datetime remind_at "リマインダー日時"
    }

    LINENotifications {
      index id PK "通知ID"
      integer user_id FK "ユーザーID"
      string message "メッセージ"
      string status "ステータス"
      datetime sent_at "送信日時"
      datetime created_at "作成日"
      datetime updated_at "更新日"
    }
```