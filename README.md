# بسيط — Baseet

Baseet is an Arabic-first business management system planned for mobile, desktop, and web. This repository is currently a clean Flutter foundation: the previous proof-of-concept sales, inventory, debt, reports, backup, and transfer implementations were removed so the full system can be built against one agreed architecture.

## Current state

The app contains only:

- the existing Flutter platform projects for Android, iOS, and Windows;
- the application bootstrap and a localized foundation screen;
- shared theme tokens, error contracts, and use-case contracts;
- architecture rules and automated dependency-boundary tests;
- the approved system, platform, commercial, and requirements plans.

No business feature is represented as complete yet.

## Product direction

Baseet will support three operating modes through the same domain contracts:

1. standalone offline use on a phone or computer;
2. clients connected to a shop-local Baseet server over the LAN;
3. clients connected to a remotely hosted Baseet server.

Mobile, desktop, and web share business rules and API contracts. Device-specific storage, networking, printing, scanning, and secure credential handling stay behind platform adapters. Subscription administration remains manual for the first release; Baseet records entitlements and license state without integrating automated billing.

Read the planning set before starting a feature:

- [System plan](docs/BASEET_SYSTEM_PLAN.md)
- [Requirements register](docs/BASEET_REQUIREMENTS_REGISTER.md)
- [Platform and commercial plan](docs/BASEET_PLATFORM_AND_COMMERCIAL_PLAN.md)
- [Repository review](docs/BASEET_REPOSITORY_REVIEW.md)
- [Architecture rules](rules/architecture_rules.md)

## Run

```sh
flutter pub get
flutter run
```

## Required checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Platform release builds are also checked by GitHub Actions. New feature work must add tests for its business rules, failure paths, persistence or synchronization behavior, and affected user flows.
