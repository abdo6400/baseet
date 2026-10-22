# Baseet architecture rules

These rules are binding for all Baseet code. The planning documents define product scope; this file defines how that scope is implemented.

## 1. Dependency direction

Baseet uses feature-oriented Clean Architecture. Dependencies point inward:

```text
presentation -> domain <- data
app -> feature composition and platform adapters
```

- `domain` is pure Dart business behavior. It must not import Flutter, app composition, data implementations, databases, HTTP clients, or platform plugins.
- `data` implements domain repositories and maps storage or transport models to domain entities. It must not contain UI behavior.
- `presentation` calls domain use cases through scoped BLoCs or Cubits. It must not import data models, repository implementations, databases, or transport clients.
- `app` owns dependency composition, routing, session scope, and application lifecycle coordination.
- `core` contains only stable cross-feature contracts and design foundations. Feature-specific behavior does not belong in `core`.

Every feature containing Dart source uses this structure:

```text
lib/features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    blocs/ or cubits/
    pages/
    widgets/
```

## 2. Domain and use cases

- Use cases with input extend `ParamsUseCase<Result, Params>`.
- Their parameter value object extends `Equatable` and validates domain-relevant invariants.
- Use cases without input extend `NoParamsUseCase<Result>`.
- Repository contracts return `Either<Failure, T>` for expected failures.
- Money uses an exact representation with an explicit currency. Floating-point values must not represent financial amounts.
- Posted financial and stock movements are append-only. Corrections use reversal or adjustment records with an audit trail.
- Tenant, business, branch, user, and device ownership must be explicit wherever their absence could expose or corrupt another scope's data.

## 3. Data, synchronization, and operating modes

- Repository implementations wrap fallible calls with `repositoryCall` or an equivalent reviewed boundary mapper.
- Local storage, LAN transport, and remote transport implement the same domain repository contracts.
- Offline writes use durable local identifiers, idempotency keys, and an outbox. Synchronization must tolerate retries, interruption, duplicate delivery, and stale clients.
- Conflict policy is explicit per aggregate. Silent last-write-wins is forbidden for financial records, stock movements, entitlements, and audit events.
- Migrations are forward-only, versioned, tested with data from the previous released schema, and never silently discard user data.
- Transport uses authenticated TLS outside an explicitly isolated local development environment. Credentials and refresh tokens use platform secure storage.
- Data received from networks, files, deep links, scanners, and other processes is untrusted and validated at the boundary.

## 4. Presentation and design system

- A BLoC or Cubit owns one user process or cohesive screen state. Do not create a feature-wide state object for unrelated workflows.
- Business rules and persistence calls do not run in widgets.
- Reuse shared colors, typography, spacing, radii, icons, and components. Do not hardcode visual values when a token exists.
- User-facing text is localized. Arabic and right-to-left layout are first-class and covered by tests.
- Layouts must adapt to phone, tablet, desktop, and web widths without separate business logic.
- Permissions are requested only when a user starts the feature that needs them, with a usable denied-permission path.

## 5. Security, tenancy, and licensing

- Every protected operation verifies the current session and tenant scope at the server or trusted local-server boundary.
- Cached data, background work, and credentials are cleared when the account or tenant changes.
- Logs, analytics, crash reports, and error payloads must not contain secrets, tokens, government IDs, customer contact details, addresses, or document images.
- Authorization is deny-by-default and based on roles plus explicit permissions.
- License and subscription state is signed or server-verifiable, cached for a bounded offline grace period, and cannot depend on a client-controlled clock alone.
- Manual subscription administration changes entitlement records through audited administrative commands. Billing provider integration is not required for the first release.

## 6. Composition and shared code

- Platform plugins are accessed through interfaces. Domain and presentation code must remain usable in every supported client.
- Cross-feature interaction uses domain contracts, application services, or events with documented ownership. Features do not import another feature's data layer.
- Shared server and client contracts must be versioned and backward compatible during a supported upgrade window.
- Dependency registration belongs in `app`, grouped by bounded context rather than one global service-locator file.

## 7. Verification required for every change

- Format, analyze, run the architecture test, and run the full test suite.
- Add tests for changed behavior and applicable failures, retries, cancellation, offline recovery, authorization, migrations, and concurrency.
- Build or exercise affected platforms and user flows. Record any platform that could not be checked.
- Review the diff for secrets, personal-data leakage, unsafe transport, untrusted input, excessive permissions, dependency advisories, and tenant isolation.
- Map callers and stored formats affected by the change and prove previous behavior remains safe.
- Keep plans, requirements, API documentation, migrations, and operating instructions aligned with behavior.
