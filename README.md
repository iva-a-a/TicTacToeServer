# TicTacToe API — Vapor Web Framework

Проект "Крестики-нолики", реализованный на Swift с использованием фреймворка [Vapor](https://vapor.codes) и авторизацией через JWT.

---

## Структура проекта

```
TicTacToe/
├── Package.swift
├── Sources/
│   ├── Web/                # Работа с HTTP-запросами (API)
│   │   ├── Model/
│   │   ├── Controllers/
│   │   ├── Mapper/
│   │   ├── Auth/
│   ├── Domain/             # Бизнес-логика
│   │   ├── Model/
│   │   ├── Service/
│   │   │   ├── Auth/
│   │   │   ├── ServiceGame/
│   │   │   ├── ServiceUsers/
│   ├── Datasource/         # Работа с данными и хранилищем
│   │   ├── Model/
│   │   ├── RepositoryDB/
│   │   ├── Mapper/
│   │   ├── Migration/
│   ├── Di/                 # DI контейнер (внедрение зависимостей)
├── App/                    # Конфигурация приложения
│   ├── configure.swift
│   ├── main.swift
│   ├── routes.swift
├── Tests/                  # Тестирование
│   ├── AppTestsGame/
│   ├── AppTestsUser/
```

---

## Быстрый старт

### Предварительная настройка PostgreSQL

1. Запустить PostgreSQL и подключиться:

```bash
psql postgres
```

2. Создать пользователя и БД:

```sql
CREATE ROLE postgres WITH
    LOGIN
    SUPERUSER
    CREATEDB
    CREATEROLE
    REPLICATION
    BYPASSRLS
    PASSWORD 'postgres';

CREATE DATABASE tictactoe_db;
```

Создание БД для тестирования:

```sql
CREATE DATABASE tictactoe_test;
```

Для удаления БД:

```sql
DROP DATABASE tictactoe_db;
DROP DATABASE tictactoe_test;
```

3. Выйти из psql:

```sql
\q
```

---

## Сборка и запуск

### 1. Сборка проекта

```bash
swift build
```

### 2. Запуск проекта

```bash
swift run
```

Приложение будет доступно по адресу: `http://localhost:8080`

---

## Аутентификация

### Регистрация пользователя

```bash
curl -X POST http://localhost:8080/signup \
  -H "Content-Type: application/json" \
  -d '{"login": "<YOUR_LOGIN>", "password": "<YOUR_PASSWORD>"}'
```

### Вход в систему

```bash
curl -X POST http://localhost:8080/signin \
  -H "Content-Type: application/json" \
  -d '{"login": "<YOUR_LOGIN>", "password": "<YOUR_PASSWORD>"}'
```
---

## JWT-токены

В API используются два типа токенов для авторизации пользователей:

1. Access Token
- Короткоживущий токен (по умолчанию 1 час).
- Используется для доступа к защищённым эндпоинтам (создание игр, ходы, получение информации о пользователе и т.д.).
- Передаётся в заголовке Authorization

```bash
Authorization: Bearer <JWT_ACCESS_TOKEN>
```
2. Refresh Token
- Долго живущий токен (по умолчанию 7 дней).
- Используется для получения нового access токена без повторного ввода логина и пароля.
- Не требует передачи в Authorization, используется только в теле запроса.

### Обновление токенов

Получение нового access token по refresh token:

```bash
curl -X POST http://localhost:8080/token/refresh-access \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "<JWT_REFRESH_TOKEN>"}'
```

> Обратите внимание: refresh token остаётся прежним, меняется только access token.

Получение нового refresh token и access token:

```bash
curl -X POST http://localhost:8080/token/refresh-refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "<JWT_REFRESH_TOKEN>"}'
```

---

## Игровой процесс

### Создание новой игры

Создание новой игры без ИИ:

```bash
curl -X POST http://localhost:8080/newgame \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>" \
  -d '{
    "creatorLogin": "<YOUR_LOGIN>",
    "playWithAI": false
  }'
```

Создание игры против ИИ:

```bash
curl -X POST http://localhost:8080/newgame \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>" \
  -d '{
    "creatorLogin": "<YOUR_LOGIN>",
    "playWithAI": true
    }'

```

### Получение доступных игр для присоединения

```bash
curl -X GET http://localhost:8080/games/available \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

### Присоединение к игре

```bash
curl -X POST http://localhost:8080/game/<GAME_ID>/join \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>" \
```

### Получение текущего состояния игры

```bash
curl -X GET http://localhost:8080/game/<GAME_ID> \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

### Сделать ход

```bash
curl -X POST http://localhost:8080/game/<GAME_ID>/move \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>" \
  -d '{
    "playerId": "<YOUR_PLAYER_UUID>",
    "row": <ROW_NUMBER>,
    "col": <COLUMN_NUMBER>
  }'
```

### Получение информации о пользователе

```bash
curl -X GET http://localhost:8080/user/<USER_ID> \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

### Получение информации о себе

```bash
curl -X GET http://localhost:8080/user/me \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

---

## Статистика игроков

Получение завершенных игр (ничья или победа одного из игроков):

```bash
curl -X GET http://localhost:8080/games/finished \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

Получение топ-N лучших игроков (исключая AI-игроков):

```bash
curl -X GET http://localhost:8080/top-players?limit=<N> \
  -H "Authorization: Bearer <JWT_ACCESS_TOKEN>"
```

---

## Тестирование

В проекте используется XCTVapor для тестирования HTTP-эндпоинтов и бизнес-логики.

Тесты расположены в папке:

```bash
├── Tests/
│   ├── AppTestsGame/
│   ├── AppTestsUser/
```

Запуск всех тестов из терминала:

```bash
swift test
```
---

## Слои архитектуры

| Слой        | Назначение |
|-------------|------------|
| `Domain`    | Бизнес-логика игры |
| `Datasource`| Работа с данными, хранилище и мапперы |
| `Web`       | Обработка HTTP-запросов, валидация, JSON |
| `DI`        | Внедрение зависимостей, инициализация компонентов |

---

## Требования

- Swift >= 5.10
- Vapor >= 4.110.1
- PostgreSQL установлен и запущен
- JWT_SECRET в .env

---
