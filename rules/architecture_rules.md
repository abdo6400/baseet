# Baseet Architecture & BLoC Standard Rules

This document outlines the mandatory architectural rules, folder structure, and implementation patterns for the Baseet (بسيط) project.

---

## 1. Clean Architecture Layers & Flow

All features MUST adhere to Clean Architecture with 3 distinct layers:

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Remote & Local data sources (Mock/DB/API)
│   ├── models/             # Data models with storage serialization and explicit domain mapping where needed
│   └── repositories/       # Repository implementations using repositoryCall
├── domain/
│   ├── entities/           # Pure Dart business entities
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Feature use cases extending ParamsUseCase or NoParamsUseCase
└── presentation/
    ├── blocs/              # Feature BLoCs grouped in process-specific subfolders
    │   ├── <process_1>/    # e.g., catalog/
    │   └── <process_2>/    # e.g., cart/
    ├── cubits/             # UI state cubits
    ├── pages/              # Screen pages
    └── widgets/            # Reusable page components
```

---

## 2. UseCases Standards (`ParamsUseCase`)

- Every UseCase taking parameters MUST extend `ParamsUseCase<T, Params>`.
- Parameters MUST be encapsulated in a dedicated `Params` class extending `Equatable`.
- UseCases without parameters MUST extend `NoParamsUseCase<T>`.

---

## 3. Data Layer Error Handling (`repositoryCall`)

- Repository implementations MUST wrap all data calls inside `repositoryCall`.
- Repository methods return `Either<Failure, T>`.

---

## 4. UI State Listener Standard (`context.showStateHandler`)

- UI screens consume state updates via `BlocListener` and `context.showStateHandler`.
- Automatically handles loading overlays, error snackbars (with `.lang` translation fallback), and success callbacks.

---

## 5. BLoC Process Scoping

- Do NOT create giant monolithic BLoCs handling multiple unrelated processes.
- Every distinct user process MUST have its own dedicated BLoC located in a process-named subfolder under `presentation/blocs/`.

## 6. Dependency boundaries

- Domain code may depend on Dart, Equatable, dartz, domain contracts, core errors, services and use cases. It must not import Flutter, data implementations, SQLite, or app composition code.
- Presentation calls use cases through BLoCs/Cubits. It must not import databases, data models, demo fixtures, or repository implementations.
- Shared product/category types belong to `features/catalog`; consumers may use its domain contracts. Storage models remain in data layers.
- `core/error/failures.dart` contains pure failure values. `repositoryCall` maps data exceptions at repository boundaries.
- App composition, dependency registration, routing, and cross-feature lookup UI belong in `app/`.
- Process BLoCs belong to their routes. Shared cart/list state belongs to the app shell.
- Demo seeding is explicit (`--dart-define=DEMO_MODE=true` or the settings restore action). Empty production results must stay empty.
