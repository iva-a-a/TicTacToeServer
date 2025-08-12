# TicTacToe API — Vapor Web Framework

Проект "Крестики-нолики", реализованный на Swift с использованием фреймворка [Vapor](https://vapor.codes).

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
│   ├── AppTests/
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

### Base64 генерация логина и пароля

```bash
echo -n "login:password" | base64
```

Пример результата:

```
bG9naW46cGFzc3dvcmQ=
```

### Регистрация пользователя

```bash
curl -X POST http://localhost:8080/signup \
  -H "Content-Type: application/json" \
  -d '{"login": "login", "password": "password"}'
```

### Вход в систему

```bash
curl -X POST http://localhost:8080/signin \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ="
```

Пример ответа:

```json
{ "userId": "84422212-B0D9-4949-982E-DCFF795694D7" }
```

---

## Игровой процесс

### Создание новой игры

Создание новой игры без ИИ:

```bash
curl -X POST http://localhost:8080/newgame \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ=" \
  -d '{
    "playWithAI": false
  }'
```

Создание игры против ИИ:

```bash
curl -X POST http://localhost:8080/newgame \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ=" \
  -d '{
    "playWithAI": true
  }'
```

Пример ответа:

```json
{
  "game": {
    "board": {
      "grid": [
        [" ", " ", " "],
        [" ", " ", " "],
        [" ", " ", " "]
      ]
    },
    "id": "7D1A87B0-BBB3-467B-A54F-3CA96C80067F",
    "players": [
      {
        "tile": "x",
        "id": "9C721A64-AFDD-414A-9DC0-86B7B00DEE09"
      },
      {
        "tile": "o",
        "id": "2FEC605F-ECAB-4AE3-A222-BDF5CF52CC60"
      }
    ],
    "state": {
      "playerTurn": {
        "_0": "9C721A64-AFDD-414A-9DC0-86B7B00DEE09"
      }
    },
    "withAI": true
  },
  "message": "Game created"
}
```

### Получение доступных игр для присоединения

```bash
curl -X GET http://localhost:8080/games/available \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ="
```

Пример ответа:

```json
[
  {
    "board" : {
      "grid" : [
        [" ", " ", " "],
        [" "," "," "],
        [" "," "," "]
        ]
    },
    "id": "39A8A892-86BA-49A3-9591-A3E671352157",
    "players": [
      {
        "id": "A004C12A-B0E9-4504-8785-972AF9F71D70",
        "tile": "x"
      }
    ],
    "state": {
      "waitingForPlayers": {
      },
    "withAI": false
    }
  }
]
```

### Присоединение к игре

```bash
curl -X POST http://localhost:8080/game/C9B11E2F-0D4F-4DB4-BB94-58AE3EBA73B2/join \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ=" \
  -d '{
    "playerId": "1F123456-789A-4BCD-ABCD-1234567890AB"
  }'
```

Пример ответа:

```json
{
  "game": {
    "board": {
      "grid": [
        [" ", " ", " "],
        [" ", " ", " "],
        [" ", " ", " "]
      ]
    },
    "id": "C9B11E2F-0D4F-4DB4-BB94-58AE3EBA73B2",
    "players": [
      {
        "tile": "x",
        "id": "F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F"
      },
      {
        "tile": "o",
        "id": "1F123456-789A-4BCD-ABCD-1234567890AB"
      }
    ],
    "state": {
      "playerTurn": {
        "_0": "F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F"
      }
    },
    "withAI": false
  },
  "message": "Joined game"
}
```

### Получение текущего состояния игры

```bash
curl -X GET http://localhost:8080/game/C9B11E2F-0D4F-4DB4-BB94-58AE3EBA73B2 \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ="
```

Пример ответа:

```json
{
  "board": {
    "grid": [
      ["x", " ", "o"],
      [" ", "x", " "],
      [" ", " ", "o"]
    ]
  },
  "id": "C9B11E2F-0D4F-4DB4-BB94-58AE3EBA73B2",
  "players": [
    {
      "tile": "x",
      "id": "F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F"
    },
    {
      "tile": "o",
      "id": "1F123456-789A-4BCD-ABCD-1234567890AB"
    }
  ],
  "state": {
    "playerTurn": {
      "_0": "F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F"
    }
  },
  "withAI" : false
}
```

### Сделать ход

```bash
curl -X POST http://localhost:8080/game/158F6579-87BE-4C03-96D8-9850EB92D15E/move \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic dGVzdDpwYXNzd29yZA==" \
  -d '{
    "board": {
      "grid": [
        ["x", "o", " "],
        ["x", "o", " "],
        ["x", " ", " "]
      ]
    },
    "id": "158F6579-87BE-4C03-96D8-9850EB92D15E",
    "state": {
      "playerTurn": {
        "_0": "24AF0E09-CBCF-477C-A8D5-76BC3A3EFDBC"
      }
    },
    "players": [
      {
        "id": "24AF0E09-CBCF-477C-A8D5-76BC3A3EFDBC",
        "tile": "x"
      },
      {
        "id": "8496B205-9881-4A1B-92C6-4BF7452580B5",
        "tile": "o"
      }
    ],
    "withAI": false
  }'
```  

Пример ответа: 
```json
  {
  "game": {
    "board": {
      "grid": [
        ["x", "o", " "],
        ["x", "o", " "],
        ["x", " ", " "]
      ]
    },
    "id": "158F6579-87BE-4C03-96D8-9850EB92D15E",
    "players": [
      {
        "id": "24AF0E09-CBCF-477C-A8D5-76BC3A3EFDBC",
        "tile": "x"
      },
      {
        "id": "8496B205-9881-4A1B-92C6-4BF7452580B5",
        "tile": "o"
      }
    ],
    "state": {
      "winner": {
        "_0" : "24AF0E09-CBCF-477C-A8D5-76BC3A3EFDBC"
      }
    },
    "withAI": false
  },
  "message": "Game over: 24AF0E09-CBCF-477C-A8D5-76BC3A3EFDBC wins!"
}
```
### Получение информации о пользователе

```bash
curl -X GET http://localhost:8080/user/F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F \
  -H "Authorization: Basic bG9naW46cGFzc3dvcmQ="
```

Пример ответа:

```json
{
  "id": "F4C16A84-0A77-4E26-BF4F-FF6B6EBB743F",
  "username": "login"
}
```

---

## Тестирование

В проекте используется XCTVapor для тестирования HTTP-эндпоинтов и бизнес-логики.

Тесты расположены в папке:

```
├── Tests/
│   ├── AppTests/
```

Запуск всех тестов из терминала:

```bash
swift test
```
---

## Слои архитектуры

| Слой        | Назначение |
|-------------|------------|
| `Domain`    | Бизнес-логика игры, не зависит от фреймворков |
| `Datasource`| Работа с данными, хранилище и мапперы |
| `Web`       | Обработка HTTP-запросов, валидация, JSON |
| `DI`        | Внедрение зависимостей, инициализация компонентов |

---

## Требования

- Swift >= 5.10
- Vapor >= 4.110.1
- PostgreSQL установлен и запущен

---
