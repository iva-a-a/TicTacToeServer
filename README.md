# TicTacToe

💧 A project built with the Vapor web framework. Проект, созданный с помощью веб-платформы Vapor.

## Project structure. Cтруктура проекта

The project has the following structure: \
Проект имеет следующую структуру:

```
TicTacToe/
├── Package.swift
├── Sources/
│   ├── web/
│   │   ├── model/
|   |   |   |── boardWeb.swift
|   |   |   |── gameWeb.swift
│   │   ├── controller/
|   |   |   |── gameController.swift
│   │   ├── mapper/
|   |   |   |── mapperWebDomain.swift
│   ├── domain/
│   │   ├── model/
|   |   |   |── boardDomain.swift
|   |   |   |── gameDomain.swift
│   │   ├── service/
|   |   |   |── gameService.swift
|   |   |   |── gameServiceImpl.swift
│   ├── datasource/
│   │   ├── model/
|   |   |   |── boardDts.swift
|   |   |   |── gameDts.swift
|   |   |   |── gameStore.swift
│   │   ├── repository/
|   |   |   |── gameRepository.swift
|   |   |   |── gameRepositoryImpl.swift
│   │   ├── mapper/
|   |   |   |── mapperDtsDomain.swift
│   ├── di/
│   │   ├──сontainerProvider.swift
├── App/
│   ├──configure.swift
│   ├──main.swift
│   ├──routes.swift
```


The project is divided into four main layers, each of which is a separate Swift package and is responsible for its own part of the logic: \
Проект разделён на четыре основных слоя, каждый из которых является отдельным Swift-пакетом и отвечает за свою часть логики: 

1) Domain (Business Logic. Бизнес-логика)

- Contains the basic logic of the game. Содержит основную логику игры.
- Does not depend on external frameworks. Не зависит от внешних фреймворков.

2) Datasource (Working with data. Работа с данными)

- Storing game states. Хранение состояний игр.
- Data transformation between layers. Преобразование данных между слоями (Domain <-> Datasource).

3) Web (API for the client. API для клиента)

- Accepts HTTP requests, returns JSON. Принимает HTTP-запросы, возвращает JSON.
- Validates the input data. Валидирует входные данные.

4) DI (Dependency Injection. Внедрение зависимостей)

- Manages dependencies between layers. Управляет зависимостями между слоями.
- Initializes services, repositories, and controllers. Инициализирует сервисы, репозитории и контроллеры.

## Getting Started. Начало работы

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project: \
Чтобы создать проект с помощью менеджера пакетов Swift, запустите следующую команду в терминале из корневого каталога проекта:

```bash
swift build
```

To run the project and start the server, use the following command: \
Чтобы запустить проект и запустить сервер, используйте следующую команду:
```bash
swift run
```

## Game. Игра 

To create a new game, run the following command in the terminal: \
Для создания новой игры запустите следующую команду в терминале: 

```bash
curl -X POST http://localhost:8080/newgame
```

Example of a move: \
Пример хода:

```bash
curl -X POST http://localhost:8080/game/id\
  -H "Content-Type: application/json" \
  -d '{
    "board": {
      "grid": [
        [1,0,0],
        [0,0,0],
        [0,0,0]
      ]
    },
    "id": "id"
  }'
```
