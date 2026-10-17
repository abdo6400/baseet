# بسيط — Baseet

A simple Arabic-first shop app for local sales, stock, customer debt and payments. English is also available.

## Run

```sh
flutter pub get
flutter run
```

Start on Home, add a product with just its name, selling price and quantity, and record your first sale. A category is created automatically; barcodes, purchase costs and other details are optional. Customers require only a name and can have an optional previous balance.

Daily work is offline. SQLite records are stored in application-support storage outside the Windows installation folder. Schema version 2 migrates existing version 1 records without clearing them. Mobile databases from the previous location are preserved during migration.

## Backup and QR transfer

Open **Backup & device transfer** to save/open a `.baseet` backup or transfer a complete snapshot on the same Wi-Fi. One device shows a five-minute QR code; the other scans it or pastes the code, previews counts, and confirms replacement. QR transfer uses AES-GCM encryption. Backup files themselves are not encrypted.

Transfers replace the receiver's records; they do not merge independent edits. A recovery backup is retained before replacement. Use one device as the current source of truth. Windows supports USB scanners and pasted codes rather than camera scanning.

## Test builds

- **Windows test installer**: automatic on `main` pushes/PRs, plus manual runs. Downloads are available as `Baseet-Windows-Installer` and `Baseet-Windows-Portable` GitHub Actions artifacts. The workflow bundles the C++ runtime, packages an Inno Setup EXE, and performs an install/start smoke test.
- **Android test APK**: manual run or `v*` tag. Artifact: `Baseet-Android-Test-APK`. Current signing is for testing, not store distribution.
- To build Windows locally, install Visual Studio's **Desktop development with C++** workload, then run `flutter build windows --release`.
- Installer and APK workflows are test delivery workflows. Public distribution needs release signing and device acceptance tests.

## Architecture

```text
lib/
  main.dart
  app/                     # Dependency composition, routing and shared UI coordination
  core/                    # Database, errors, services, money, theme and common widgets
  features/
    business/              # Home, product editing, invoice history and shop settings
    catalog/               # Shared product/category domain types
    device_transfer/       # Validated backups and encrypted local QR transfer
    inventory/
    pos/
    debt_ledger/
    reports/
    more_settings/         # Data-management domain and process BLoC
    splash/
```

Features use `presentation → domain` and `data → domain`. Presentation never accesses the database. Business validation lives in domain policies and use cases; SQLite queries and atomic writes stay in data. Process BLoCs/Cubits are scoped to routes; cart/list state is shared at app level.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The suite covers architecture boundaries, business validation, money precision, real SQLite transactions and rollback, backups with attachments, local encrypted HTTP transfer, migration, and Arabic phone/desktop layouts using the real router.

Read [the readiness review](docs/readiness.md) for minimum data, supported flows, transfer behavior and remaining production gaps. Returns/refunds, thermal printing, stock-movement audit history, simultaneous two-way sync and full accounting are not implemented. Estimated profit excludes expenses and depends on recorded purchase costs.
