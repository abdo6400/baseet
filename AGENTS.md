# Baseet agent instructions

Read this file, `rules/architecture_rules.md`, the four `docs/BASEET_*.md` planning documents, and the relevant feature code before changing Baseet.

## Binding workflow

1. Work on a branch. Do not commit or push unless the user asks.
2. Treat the planning documents as scope references and verify their statements against implemented code. Never present a planned feature as implemented.
3. Follow feature-oriented Clean Architecture and the dependency directions enforced by `test/architecture/dependency_rules_test.dart`.
4. Keep business rules in the domain, IO in data or platform adapters, composition in `app`, and UI behavior in presentation.
5. Use localized text and design tokens. Validate Arabic RTL and responsive layouts for affected UI.
6. Trace offline, LAN, and remote behavior when changing storage, networking, identity, licensing, or synchronization.
7. Preserve tenant isolation, financial accuracy, audit history, idempotency, and user data across errors and upgrades.

## Required completion checks

Run the repository's CI-equivalent commands and all checks relevant to the touched platform:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Also review the final diff for secrets, personal-data exposure, authorization gaps, unsafe input or transport, dependency risk, and regressions. Build and exercise affected user flows when the local toolchain supports them. Report unavailable checks and pre-existing failures rather than weakening a check.
