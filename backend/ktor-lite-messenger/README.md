# Lite Messenger backend

Ktor 3 server that powers the Lite Messenger experience. It exposes REST endpoints for authentication, profile management, user search, chat management, and handles realtime messaging via WebSockets. Avatars uploaded by users are saved to the shared `storage/` directory (sibling to `backend/`) and are then exposed through `/avatars/{uuid.ext}`.

## Highlights

- **Architecture**: Entities (Exposed), Domain DTOs, Services (business logic + seed data), Controllers (REST), dedicated WebSocket handler, and `ktor/` config modules.
- **Database**: H2 in-memory with Exposed. Five demo users (`user1@email.com` … `user5@email.com`, password `123456`) and their sample conversations are seeded at startup.
- **Auth**: JWT bearer tokens for REST and sockets with sign up / sign in / sign out flows.
- **Features**: Contact discovery, avatar upload, chat bootstrap, message history, and realtime text messaging.
- **CORS**: Enabled for local development so the vanilla JS frontend can call the API directly.

## Running

```bash
cd backend/ktor-lite-messenger
./gradlew run
```

The server listens on `http://localhost:8158`. Uploaded avatars are placed in `storage/` (relative path `../../storage` when running from this module). WebSocket endpoint lives at `ws://localhost:8158/ws/chat?token=<JWT>`.

## REST overview

| Method | Path                    | Description                           |
|--------|-------------------------|---------------------------------------|
| POST   | `/api/auth/register`    | Sign up and receive JWT + profile     |
| POST   | `/api/auth/login`       | Sign in and receive JWT + profile     |
| GET    | `/api/users/me`         | Current user profile                  |
| GET    | `/api/users/{id}`       | Public profile info                   |
| GET    | `/api/users/search?q=`  | Search contacts                       |
| POST   | `/api/users/avatar`     | Upload avatar (multipart/form-data)   |
| GET    | `/api/chats`            | List chats for current user           |
| GET    | `/api/chats/{id}/messages` | Full message history                |
| POST   | `/api/chats/start`      | Start/chat with selected user         |

WebSocket payloads are JSON and currently support the `send_message` action.
