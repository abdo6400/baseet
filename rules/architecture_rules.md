# Baseet Architecture & BLoC Standard Rules

This document outlines the mandatory architectural rules, folder structure, and implementation patterns for the Baseet (بسيط) project.

---

## 1. Clean Architecture Layers & Flow

All features MUST adhere to Clean Architecture with 3 distinct layers:

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Remote & Local data sources (Mock/DB/API)
│   ├── models/             # Data models with JSON serialization & toEntity()
│   └── repositories/       # Repository implementations using Failure.handleCall
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

## 3. Data Layer Error Handling (`Failure.handleCall`)

- Repository implementations MUST wrap all data calls inside `Failure.handleCall`.
- Repository methods return `Either<Failure, T>`.

---

## 4. UI State Listener Standard (`context.showStateHandler`)

- UI screens consume state updates via `BlocListener` and `context.showStateHandler`.
- Automatically handles loading overlays, error snackbars (with `.lang` translation fallback), and success callbacks.

---

## 5. BLoC Process Scoping

- Do NOT create giant monolithic BLoCs handling multiple unrelated processes.
- Every distinct user process MUST have its own dedicated BLoC located in a process-named subfolder under `presentation/blocs/`.
