# بسيط — Baseet

Flutter point of sale, inventory, debt ledger, and reporting application.

## Run

```sh
flutter pub get
flutter run
```

The default startup uses real local data and creates an empty SQLite database on first launch. Existing installations keep their database and records. Add a category, products, and customers through the app to begin.

For explicit demo data on an empty database:

```sh
flutter run --dart-define=DEMO_MODE=true
```

Settings also provides a confirmed restore-demo action that replaces local records. Clear-data and restore-demo operations run atomically; the shared cart is cleared after success. Database schema remains version 1, so this refactor does not require a destructive migration.

## Architecture

```text
lib/
  main.dart
  app/
    app.dart
    di/                     # Composition root and dependency registrations
    router/                 # Route-owned process BLoCs
    presentation/           # Cross-feature lookup state and loading/error UI
  core/
    database/               # SQLite connection, schema and explicit demo seed
    error/                  # Domain failures and data exception mapping
    services/               # Injectable time and identifier source
    common/widgets/
    theme/
    usecase/
  features/
    catalog/                # Shared product/category types and category reads
    inventory/
    pos/
    debt_ledger/
    reports/
    more_settings/
    splash/
```

Business features use `presentation → domain` and `data → domain`. Domain contains repository contracts, business validation, entities, and use cases. Data owns SQLite queries, atomic writes, serialization, and exception mapping. Domain policies are evaluated against current records inside transactions when consistency requires it.

Checkout derives totals from cart lines, validates payment input, and atomically persists the invoice, stock changes and customer debt. Missing customers, unavailable stock, credit-limit violations, and duplicate invoices fail without partial writes. Payments must be finite, positive, and no greater than the current debt.

Process BLoCs are created per route for checkout, add-product/category/customer, customer statements, and payment vouchers. Cart and list BLoCs are shared at app level. Selection lists come from use cases; production UI does not read demo fixtures.

See `rules/architecture_rules.md` for dependency rules.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Tests cover domain validation, dependency boundaries, real in-memory SQLite transactions and rollback, live lookups, empty reports, and exception-to-failure mapping. CI runs formatting, analysis, and tests. Device-specific scanner, image picker and platform UI behavior still requires testing on a supported device.
