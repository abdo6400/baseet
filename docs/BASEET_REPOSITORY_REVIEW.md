# Baseet — repository review, rules and fresh-start plan

> **Historical baseline:** This review records the repository before the clean-foundation reset. The legacy features and implementation details described below were removed after the review. Use the current source tree and `rules/architecture_rules.md` for present implementation status; use this document as evidence for what was evaluated and why it was removed.

Date: 22 October 2026. Scope: read-only source/rules review and planning documentation.
Repository: [abdo6400/baseet](https://github.com/abdo6400/baseet).
Reviewed default branch: `main`.
Pinned baseline: [`ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9`](https://github.com/abdo6400/baseet/commit/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9), committed 17 October 2026.

## 1. What was actually inspected

Read repository metadata, the recursive tree, the latest three commits and 20 pinned files: project rules, architecture validator, README/readiness, package manifest, analyzer options, all three workflows, database/platform setup, money helper, checkout use case/data source, backup/local transfer, token exports, DI, router and Android build signing configuration.

This was not an execution test, full code audit, dependency advisory audit, secret scan or proof that existing builds pass. The local planning folder is a separate uncommitted repository with no remote; it does not contain the GitHub application. Do not mistake that empty local application tree for an empty GitHub repository.

Recent history shows a clean-architecture refactor followed by the current local POS/debt-ledger implementation. A fresh implementation should preserve that architectural work while replacing old business behavior and data assumptions deliberately.

## 2. Rules found and understood

The attached [`C:\Users\abdul\Downloads\AGENTS.md`](C:/Users/abdul/Downloads/AGENTS.md) contains the global working agreement already supplied in the conversation. It covers discovery, complete scope, failure/concurrency review, architecture, actual verification, security, regression, docs, Git safety and evidence. Reading an attachment does not turn every sentence into a new user request: it is a reference for the rules review, and the direct request remains the five Baseet planning questions.

The project-specific binding architecture source is [rules/architecture_rules.md](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/rules/architecture_rules.md). The inspected tree contains no project `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `CONTRIBUTING.md` or separate ADR collection. Their absence does not remove the existing architecture rules or tests.

Preserve these project standards:

| Standard | Required treatment in the fresh implementation |
|---|---|
| Feature layers | `data`, `domain`, `presentation` under `lib/features/<feature>` |
| Domain independence | Pure Dart domain; no Flutter, database/data implementation or app-composition imports |
| Dependency direction | Presentation → domain; data → domain; composition in `app/` |
| Parameterized use cases | Extend `ParamsUseCase<T,Params>` with dedicated `Equatable` params |
| Parameterless use cases | Extend `NoParamsUseCase<T>` |
| Repository results/errors | `Either<Failure,T>`; data calls wrapped in `repositoryCall` |
| UI state side effects | `BlocListener` and `context.showStateHandler` |
| Process scoping | Dedicated process BLoCs; no unrelated giant BLoC |
| UI cubits | Retain existing permitted Cubit usage for UI state |
| Shared catalog ownership | Product/category contracts in catalog domain; persistence models remain in data |
| Composition/lifetimes | DI, routing and cross-feature coordination in `app/`; route-scoped processes and shell-owned shared state |
| Demo data | Explicit opt-in/restore; empty production results remain empty |

Shared tokens live in `lib/core/theme/tokens/`; shared components in `lib/core/common/widgets/`; Arabic/English content in `assets/translations/`. Retain and audit these foundations rather than reintroducing hardcoded colors, spacing, strings or duplicated forms.

Any shared-kernel/server/package addition must be written into project rules and validation before feature implementation. This is a proposed extension, especially where canonical catalog entities leave their current location. It is not permission to silently violate the existing catalog ownership rule.

## 3. Existing checks and validator limits

[Flutter CI](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/.github/workflows/flutter.yml) runs:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The full test command includes [test/architecture/dependency_rules_test.dart](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/test/architecture/dependency_rules_test.dart). It checks forbidden imports in feature domain and presentation source. It must be retained, not bypassed by starting with an empty test folder.

Its current matching uses a regular expression for single-quoted imports; it is not a complete architectural proof. It does not establish all relative/export/conditional-import paths, cross-feature cycles, new shared packages, transport/backend boundaries, use-case signatures or all process/lifetime rules. Extend validation to those boundaries and review what automation cannot express. A zero-feature tree should not be presented as evidence that future architecture is correct.

[Android workflow](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/.github/workflows/android-apk.yml) tests and builds a test APK. [Windows workflow](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/.github/workflows/windows-installer.yml) analyzes/tests/builds, packages an installer and performs a startup smoke test. Neither proves complete user-flow/hardware or production signing readiness.

No dedicated dependency audit, secret scan, SAST or single verify script was found in the inspected workflow set. Add explicit maintained tooling during implementation; do not claim it already exists. Extend checks to `packages/`, `server/`, web builds, API/DB conformance and migration tests when those paths are introduced.

## 4. Current app versus the proposed system

| Area | Evidence from source/docs | Fresh-system consequence |
|---|---|---|
| Current purpose | README/readiness describe local sales, current stock, customer debt/payment and summaries | Useful reference scenarios, not a full retail/accounting backend |
| Client targets | Android, iOS and Windows scaffolding; no `web/` target in reviewed tree | Add web build and web-safe adapters; iOS needs independent build/device evidence |
| Storage | Local SQLite schema v2 and `dart:io`/FFI platform setup | Replace with authority/cache/embedded ports; do not reuse as a shared server DB file |
| Finance | Denormalized product/current debt/order values; SQLite `REAL` fields | New explicit precision, ledgers, allocations, costing and audit schema |
| Checkout | Domain use case plus atomic local stock/debt transaction | Preserve intent and baseline tests; redesign for server validation, operation idempotency and user scope |
| Transfer | AES-GCM encrypted local full snapshot; restore replaces receiver | This is not shared editing or conflict-aware sync; isolate as migration/recovery only |
| Access | Readiness explicitly describes single-user/OS-level access | New owner/staff identity, RBAC, tenant isolation and session lifecycle |
| Subscription service | No subscription/remote API required in current release description | New manually administered subscription authority, entitlements, device activation and portal; automated billing excluded |
| Operations | Backup/attachment validation and safety copy exist | Retain useful recovery cases; upgrade encryption, key recovery and retention |
| Output/accounting | Readiness lists returns, printing, movement history, full accounting and two-way sync as incomplete | Treat those as new modules, not hidden existing functionality |

[Readiness source](https://github.com/abdo6400/baseet/blob/ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9/docs/readiness.md) is reference documentation, not a future product limit. Its historical note that a previously fetched main contained only one workflow is stale for the pinned tree, which now contains three workflows. Its local-workstation build limitation is historical and was not reverified on this machine. Current source and future measured evidence take precedence over those statements.

## 5. Pre-existing production/security gaps found

No new application security issue was introduced by this documentation task. The following are existing source/design gaps relevant to the rebuild; they were not fixed or exhaustively audited here.

| Finding/location at pinned commit | Impact | Treatment |
|---|---|---|
| `lib/features/device_transfer/data/datasources/backup_datasource.dart:53` and `:141` serialize/write plain JSON backup records | Exported/safety backups contain business/personal data without file encryption | M21 encrypted backup, recovery keys, safe retention and access |
| `lib/core/database/app_database.dart:89` and `lib/core/database/platform_database.dart:11` define customer fields and ordinary local DB path, without an encryption layer in inspected setup | Local storage protection relies on platform access in this reviewed path; contact data is not shown encrypted by that code | Choose/prove protected local data/attachments strategy; secure-storage dependency alone is insufficient |
| `android/app/build.gradle.kts:36` uses debug signing for release build | Test delivery is not a production release/signing chain | Release signing/key lifecycle and store/managed-distribution gates |
| `docs/readiness.md:77` and reviewed router/composition show current single-user model | No reviewed multi-user authentication/role model to reuse as production security | Implement identity/scopes/session/audit from foundations |
| `lib/core/database/app_database.dart:79` and `lib/core/utils/money.dart:2` use REAL/double monetary representations, with rounding helper | Not the new exact precision/costing ledger contract; risk increases with allocations, tax and average costs | Replace numeric storage/calculation policy with approved decimal/scaled values and migration fixtures |
| `test/architecture/dependency_rules_test.dart:15` and `:36` check a limited import pattern | Passing the test alone does not prove all new package/backend boundaries | Keep and strengthen validator; manual architecture review remains required |

The money/validator items are correctness/verification limitations rather than claims of an exploitable security vulnerability. The access/storage findings are scoped to inspected code and documented behavior; no penetration test or dependency CVE scan ran.

## 6. Concrete fresh-start manifest

Interpretation of “remove all things and start fresh but with the same structure”: replace the old feature implementation and legacy data assumptions while preserving Baseet's engineering standards, source history and useful design assets. This is not a request to wipe the Git repository history, delete customer records or remove architecture checks.

| Item | Fresh-start treatment | Required review before any future change |
|---|---|---|
| Git history/default branch | Preserve; rebuild on a new `codex/` branch based on the latest remote main | Read current tip and local status; record baseline |
| Global attachment | Retain as rules reference; it has been read | Do not overwrite global files or install copies implicitly |
| `rules/architecture_rules.md` | Keep; extend for server/shared packages and authority boundaries | Explicit rule/validator update reviewed together |
| `test/architecture/` | Keep and strengthen | Must still check meaningful feature/package boundaries |
| `analysis_options.yaml`, `.gitignore`, metadata | Keep/audit and adapt to new paths | No exclusions introduced to hide failures |
| `.github/workflows/` | Preserve intent; adapt new paths/checks and release signing | Green full verification and actual artifact tests |
| `lib/app/` | Preserve composition/routing/lifetime responsibilities; rebuild registrations/routes | No obsolete feature wiring or leaked sessions |
| `lib/core/theme`, `lib/core/common/widgets`, translations/fonts/icons | Retain after audit; extend shared system | No hardcoded replacement design; verify asset rights and localization |
| `lib/core/error`, use-case bases, operation context | Keep the conventions; review implementations for revised contracts | Pure failures, predictable clocks/IDs and repository mapping |
| `lib/core/database`, money, demo fixtures | Replace/rebuild business schema/precision; preserve safe migration fixtures | Customer backup/migration strategy; no destructive automatic reset |
| `lib/features/business`, catalog/inventory/POS/debt/reports/settings | Rebuild into focused modules listed in the system plan | Preserve module layering, catalog ownership and useful old behavior fixtures |
| `lib/features/device_transfer` | Replace sharing behavior; retain labeled legacy import/recovery compatibility where needed | Never call snapshot replacement synchronization |
| `test/domain`, `test/data`, `test/presentation` | Inventory current test intent, retain applicable cases, add new cycle coverage | No blanket deletion of regression evidence |
| Android/iOS/Windows runners and installer | Preserve IDs/config/assets where suitable; update permissions, signing and runtime dependencies | Device acceptance, upgrade identity/data persistence |
| Web target/packages/server | New planned paths | Architecture and CI coverage before feature work |
| README/readiness | Rewrite around actual rebuilt behavior when it exists; preserve historical context in Git | No future capability described as implemented |
| User databases, backups, attachments, `.env`/credentials and unrelated local files | Do not delete as part of source cleanup | Dedicated data migration/ownership decision and recovery evidence |

No exact deletion command/file list has been executed. During the future implementation task, convert this manifest into an exact reviewed per-path retain/replace/remove list after inspecting that checkout and its untracked files. This protects needed assets and tests while making the requested clean restart concrete.

Sequence:

1. Obtain a clean implementation checkout separately from this planning workspace; fetch and inspect latest main, working changes and applicable instructions.
2. Record the baseline commit and make verified data/export backups where any installation data exists. No commit/tag/push is implied by this plan.
3. Create the implementation branch and review the manifest against actual paths; retain architectural/design foundations first.
4. Add/update rules and boundary validation for selected authority, shared packages and platform adapters.
5. Remove/replace obsolete application wiring and feature implementation in coherent steps, with a minimal buildable shell and new setup/business context.
6. Deliver complete vertical cycles in the parent roadmap, including data/permissions/failure/output paths and tests; do not spend the whole effort on screen scaffolding.
7. Migrate/reconcile old customer data if required; if old installations will not be supported, record that explicit product decision before distribution.
8. Run full checks, security/regression review and actual platform flows before describing the rebuild as ready. No commits, push, PR, deployment or customer data reset without the relevant user authorization.

## 7. Verification performed for this planning revision

- Read the attachment and inspected the pinned repository tree/rules/validator/workflows through the GitHub connector.
- Compared selected source implementation with README/readiness and recorded the documentation limits above.
- Reviewed complete-cycle coverage, platform/deployment distinctions, subscription/security boundaries and the preservation manifest.
- Local application tests, architecture tests, builds, hardware tests, vulnerability scans and secret scans were not run; the implementation is not checked out here and this task modifies planning documents only.
- Planning checks passed: 28 sequential module IDs, 14 business cycles, 20 core and 15 platform acceptance scenarios, all 33 live tutorial links retained, 12 Baseet-specific requirement rows, nine local file links, consistent Markdown tables, whitespace and code fences. Final edits receive a focused repeat of affected checks.
- The remote `main` tip was re-read and still matched the reviewed baseline `ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9` during this revision. No application regression/security execution result is inferred from these document checks.
