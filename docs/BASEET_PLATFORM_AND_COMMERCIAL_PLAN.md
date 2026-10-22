# Baseet — platforms, deployment, security and manually managed subscriptions

Status: proposed architecture and product plan; no code or external services changed.
Date: 22 October 2026.
Parent: [Baseet system plan](BASEET_SYSTEM_PLAN.md).
Repository basis: [architecture and fresh-start review](BASEET_REPOSITORY_REVIEW.md).

## 1. Direct answers

1. The earlier plan covered the main retail modules but was not yet a complete cycle specification. The parent plan now defines C01–C14, procurement/fulfillment, financial closing, service administration, subscriptions and deployment cycles.
2. Mobile, PC and web can share the same business, documents, permissions and live balances when connected to the same authority. Retain Flutter for shared client code and responsive UI. Shared capability does not mean identical layouts or identical printer/camera/file APIs.
3. Local and remote are both required. The user confirmed independent phone operation with no PC/server/internet and phone access to a local shop server. Both are core requirements; independent mobile and concurrent disconnected multi-writer operation still have separate integrity contracts below.
4. Security and licensing need several coordinated layers: identity, authorization, business isolation, transport/storage protection, signed entitlements, device lifecycle and audited subscription administration. Automated billing is excluded. No single package supplies the complete security model.
5. Baseet's existing Clean Architecture/BLoC rules and design-system structure should be retained. Replace old business implementation deliberately on a new branch when implementation is authorized; preserve source history, rules, boundary checks and a migration/recovery path.

## 2. Recommended technical direction

These are recommendations to validate in P1, not dependencies installed during this task.

| Concern | Proposed baseline | Reason and proof needed |
|---|---|---|
| Clients | Flutter/Dart for Android, iOS, Windows and web | Existing Baseet stack; responsive shared components; prove platform adapters independently |
| Client structure | Current `lib/app`, `lib/core`, `lib/features/<feature>/{data,domain,presentation}` | Preserve project conventions, BLoC/use cases, error handling, DI, routes and localization |
| Reusable business kernel | Pure Dart domain policies and application posting contracts in an explicit shared package | Required phone-only offline and connected authority should execute the same approved business rules |
| Authority service | Dart service; evaluate Shelf/Dart Frog against operational/auth requirements | Same-language reuse is useful; framework alone does not provide security, tenancy or complete operations |
| Alternative backend | ASP.NET Core modular service if delivery team/security tooling favors it | Feasible local Windows/cloud hosting, but a separate Dart embedded engine would require cross-runtime conformance; do not maintain two unverified posting implementations |
| Multi-user database | PostgreSQL behind the authority service | Transactional shared persistence; inventory/financial concurrency and restore must be proven |
| Native standalone/cache | SQLite through a versioned adapter, with encryption/key strategy proved on each native platform | Embedded/local mode and recoverable drafts; never expose the database file as a shared network drive |
| Web persistence | API-authoritative access; bounded browser drafts/cache through a web-safe adapter | No native file/FFI/`dart:io` assumptions; browser cache is not the only backup of committed business records |
| Identity | Established OIDC implementation/provider with native authorization-code/PKCE flows; evaluate local-identity availability separately | Standard authentication, recovery and MFA; offline local authority cannot depend on a permanently reachable cloud login |
| Licensing | Entitlement service and signed bounded offline leases; evaluate Keygen rather than inventing cryptography | Device activation and offline verification; provider selection remains an ADR |
| Subscription authority | Baseet control-plane service and admin portal; no payment-provider integration | Central plan/term/status authority, audited manual renewals, remote enforcement and signed offline leases |
| Hardware/output | Printer, scanner, camera, file, Excel and secure-storage ports | Native/web implementations must advertise and test actual capabilities |
| Deployment | Packaged local authority for a shop; remotely hosted authority using the same application contracts | Separate configuration, secrets, installer/hosting/backup responsibilities |

Preference after the user's offline-phone confirmation: retain Flutter and plan a shared pure Dart kernel with a Dart authority service, subject to P1 security, persistence and deployment proof. An alternative backend must still satisfy the required embedded phone engine and conformance gates; it cannot quietly remove offline phone capability. Do not change client architecture merely to accommodate a backend preference.

Technical basis, checked 22 October 2026:

- [Flutter supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms) and [Flutter web guidance](https://docs.flutter.dev/platform-integration/web) establish mobile/desktop/browser targets, not compatibility of every Baseet dependency.
- [Flutter web FAQ](https://docs.flutter.dev/platform-integration/web/faq) documents native I/O limitations and conditional platform imports. It also recommends a separate document-oriented website for public content; Baseet's app and public marketing/help site can use different presentation technology.
- [Dart server guidance](https://dart.dev/server) lists Dart backend choices and shared-code organization; [Shelf documentation](https://pub.dev/packages/shelf) describes composable server middleware. Neither is evidence that the proposed Baseet architecture has been built or audited.
- [PostgreSQL isolation documentation](https://www.postgresql.org/docs/current/transaction-iso.html) explains transaction concurrency; Baseet must still select isolation/locking and retry strategies explicitly. [SQLite usage guidance](https://www.sqlite.org/whentouse.html) distinguishes local/embedded use and client-server needs.
- [Microsoft Windows Service hosting](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/windows-service) supports the alternative local-service approach; it does not resolve the shared embedded Dart-engine tradeoff.

Choose supported dependency/runtime releases at implementation time, pin them, review advisories and licensing, and record tested OS/browser versions. Do not select prerelease runtimes just because they are newer.

## 3. Meaning of “the same system”

One business ID, one agreed authoritative ledger per ownership partition, consistent document identities, common policies/precision, shared permission model, versioned contracts and reconciled balances. Connected clients see committed data after an explicit refresh/event notification policy.

Shared: domain rules, business entities/contracts, process definitions, prices/stock/party data, design tokens, localization resources and most client widgets/state handling.

Platform-specific: responsive screen composition, input shortcuts, camera scanning, local files, secret storage, physical printing, background execution, update delivery and notifications. A native-only feature receives a supported web alternative such as server-rendered output or a paired local print service, or it remains an explicitly blocked parity item until solved.

The client must not accept a local cache as evidence that a remote transaction committed. It shows pending/posted/rejected status truthfully and resolves an operation ID after timeouts.

### Target capability matrix

| Capability | Windows | Android/iOS | Web/browser | Acceptance |
|---|---|---|---|---|
| Core business cycles | Full role-permitted scope | Full role-permitted scope with phone/tablet layouts | Full role-permitted scope | Same scenario and reconciled business totals on each |
| Local shop authority access | Loopback/LAN | LAN | App served by the local authority | Works with public internet disconnected |
| Remote authority access | Authenticated HTTPS | Authenticated HTTPS | Authenticated HTTPS | Same business and scope; timeout/retry test |
| Independent native local posting | Required standalone mode | Required independent phone/tablet mode | Not initial authoritative browser storage | Shared native engine/adapter and recovery proof |
| Barcode input | USB/keyboard scanner | Camera and/or supported external scanner | Keyboard scanner; camera only where supported/authorized | Device compatibility matrix |
| Printing | Native adapter or local print service | Supported printer adapter or server/local print service | Preview/PDF/browser print; paired service for supported unattended output | Real paper/RTL/labels checked |
| Excel templates/export | Supported contract; direct file workflows | Embedded rendering/export in standalone; authority rendering in connected mode | Authority rendering and download/upload | Same accepted template/output contract; phone standalone must not require an unavailable PC |
| Updates | Signed installer/update channel | Signed store/managed package release | Versioned deployment and cache policy | Schema compatibility and interrupted update recovery |
| Background work | Authority service/managed jobs | OS lifecycle limits; durable queue | Server jobs; browser may close/suspend | Resume/replay evidence, no hidden always-on assumption |

iOS is a separate signed build and real-device gate; repository scaffolding alone does not prove release readiness. Mac build/signing infrastructure is needed when that target enters delivery. PC initially means Windows; macOS/Linux desktop are not silently promised as tested products.

## 4. Local/remote operating modes

| Mode | Authority and storage | Clients | Internet requirement | Scope/status |
|---|---|---|---|---|
| D01 PC standalone | Embedded or packaged authority and local DB on one PC | That PC | None for ordinary daily work within valid local license policy | Planned core native mode |
| D02 Shop LAN | Shop PC/server authority, protected DB and locally available identity | PCs, phones/tablets, browsers on shop network | Public internet not required for daily trading; local network/server required | Planned core shared mode |
| D03 Cloud | Hosted Baseet authority, tenant data and hosted identity | PC, phone/tablet, browser | Internet required for posting; draft behavior explicit during outage | Planned core remote mode |
| D04 Remote access to shop | Shop remains authority; secure managed access/VPN/reverse gateway | Authorized remote PC/mobile/browser | Remote path requires internet and shop availability | Planned remote option after secure-network proof |
| D05 Independent mobile | Embedded authority and protected local DB on one phone/tablet | That device | None for ordinary local daily work | Required core mode, explicitly confirmed by user; not equivalent to D02 |
| D06 Hybrid disconnected workers/branches | Explicit partition owners and replicated immutable events | Approved local authorities and clients | May trade during bounded outage under approved rights | Advanced mode; separate design and release gate |

Remote does not require cloud ownership: a business can use secure remote access to its own shop authority. Never expose raw PostgreSQL/SQLite access to client devices or the public internet. Do not ask users to disable certificate checks or expose an unauthenticated service port.

Local browser deployment must handle real certificate trust, same-origin/CORS, secure-context device permissions and current browser local-network protections. Prefer serving the local web app and API together from the trusted shop endpoint. A hosted HTTPS page calling an arbitrary plaintext LAN address is not a deployment design.

Required phone-standalone proof includes local setup/login, opening/import, complete ordinary trading/collection/stock/report cycles, document preview/export, backup/restore, restart and interrupted-job recovery with no server available. Country submission and subscription-license refresh remain visibly pending when they require an external connection; applicable legal issuance rules decide what may be posted locally. Hardware and the supported Excel-template rendering contract must be proved on-device, not deferred to an assumed server.

PC/server shutdown makes D02 unavailable; show that honestly and offer drafted work/reconnection. A phone app must not be required to remain in the foreground as the permanent shop server.

### Offline/standalone ownership rules

- D01/D05 may own an independent business dataset or an explicitly allocated branch partition. They do not automatically merge arbitrary edits with another device's independent copy.
- Moving an independent dataset into LAN/cloud uses a reviewed promotion/cutover process: backup, identity mapping, import control totals, operation-ID deduplication, final reconciliation and explicit disabling of the previous writing authority.
- A phone must offer clear standalone versus shared-business setup and a safe join/mode-transition workflow. Merely changing a URL must never create a second writer for the same owned stock. Joining an existing shared business requires approved import/conflict review rather than overwriting its records. Moving back to standalone requires a scoped ownership transfer or an explicit new independent dataset.
- D06 assigns stock/serial ownership or preallocated selling rights before disconnection. Two disconnected devices cannot both be guaranteed the right to sell the same last serial/unit.
- Financial postings and stock movements replicate as immutable business events with source/operation IDs, ownership, sequencing and schema versions. Mutable drafts/master data need their own revision/conflict policy.
- Online authority acceptance and pending offline status remain visible. Rejected/expired work enters operator resolution; never drop it or silently label it posted centrally.
- Numbering, tax issuance, credit limits and permissions need offline constraints. A previously cached user grant cannot stay valid indefinitely after revocation.
- Native durable queue, attachment ownership, encryption keys, retries, retention and replay are tested across app backgrounding, termination, reinstall, backup restore and business switch. Browser offline posting is a separate explicit product requirement if later requested.

## 5. Proposed repository extension

Keep the existing application root rather than moving it wholesale into a new framework layout:

```text
lib/
  main.dart
  app/                         composition, routing, app-level coordination
  core/                        shared UI/theme/errors and infrastructure ports
  features/<feature>/
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/{blocs,cubits,pages,widgets}/
packages/                      proposed addition, only after rule/validator update
  baseet_business/              pure Dart policies and posting application contracts
  baseet_contracts/             versioned transport DTOs; no UI/database dependency
server/                        proposed authority service and runtime adapters
  lib/{app,modules,infrastructure}/
test/{architecture,domain,data,presentation,integration}/
rules/
docs/
android/ ios/ windows/ web/     web target is a planned addition
```

Shared package extraction is a proposed extension to existing rules, not an assertion it already exists. Resolve canonical entity ownership first: current product/category contracts belong to `features/catalog`. If extracted, retain a single canonical definition with client-facing catalog contracts/facades; update the architecture rule and validator together. Do not duplicate competing Product or Money models in several features.

Flow for connected use: page → process BLoC/Cubit → client use case/domain repository contract → data repository/remote adapter → authority application command → pure policies + transactional ports → database adapter.

Flow for native standalone: same page/process/use-case contract → embedded data adapter → the same approved business application/policies → SQLite adapter. Shared code does not remove the need to revalidate inside the connected authority; a modified client cannot be trusted.

Business posting is never implemented in widget builders, routes, template scripts or HTTP controllers. Transaction, permission, numbering, financial and inventory rules are tested with the same conformance fixtures against PostgreSQL and SQLite implementations. Error mapping remains `repositoryCall` and `Either<Failure,T>` at client repository boundaries.

## 6. Security architecture

Separate three authorities:

1. **Identity:** who is this person/device? Login, invitations, recovery, MFA, session revocation and trusted pairing.
2. **Authorization:** what can they do in this business/branch/warehouse? Service-side action/scope checks and field-level cost/profit protection.
3. **Subscription entitlement:** what has a Baseet administrator enabled for this business? Plans, seats/branches/devices, deployment rights and validity dates.

A valid license never grants permission to another business's data. An owner cannot gain support-administrator rights merely by changing a client flag.

Cloud/native authentication should use established [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) implementations rather than a custom token protocol. Evaluate a hosted provider or a self-hostable implementation such as [Keycloak](https://www.keycloak.org/server/containers) against cloud/local operations. Local identity must actually work without public internet; copying a cloud access token into a local file is insufficient.

A standalone phone does not run a cloud identity container. Specify embedded local owner/staff authentication with OS-backed secret/key protection, recovery and auditable local role grants; connect that identity to remote membership through an explicit pairing/ownership flow later. Never embed provider administrator credentials or rely on unbounded cached cloud grants. The local authentication design is a security proof gate in P1.

Planned controls:

- Strong administrator/owner authentication and MFA where supported; rate limits, recovery audit and session/device revocation.
- Verified server-issued business membership; deny-by-default actions; no trusting a request's business ID without authorization.
- Native secret storage for session/device keys; browser session design with XSS/CSRF controls and no long-lived secrets in ordinary local storage.
- TLS for remote and LAN shared operation, certificate validation, trusted device enrollment and controlled endpoint change. Loopback-only packaged services still need local access protection and origin/session checks.
- Protected local business data and attachments, encrypted backups and recoverable key management. Encryption at rest must be proved on each platform; a dependency named secure storage does not encrypt the business database automatically.
- Secrets/signing keys live on the authority/control plane, not in app bundles or Git. Client verification public keys may be embedded; rotate through a versioned trusted-key policy.
- Transactional logs/audit with minimal personal data, redacted support diagnostics and permission-filtered reports/exports.
- Signed installers/packages/releases, vulnerability/secret scanning, restore drills and isolated support access.

Local machine administrators can inspect or modify software they control. Licensing and encryption reduce misuse and exposure; neither makes an offline installation impossible to tamper with. Offline revocation is bounded by lease refresh/expiry, not instantaneous.

## 7. Manually managed subscription and license service

### Subscription model

Subscribe a business to a plan through the Baseet administrator portal, then grant its owner access on entitled PC/mobile/web devices. Support configurable monthly, yearly or custom renewal terms. Plan dimensions may include branches, active staff seats, device/installation limits, hosted storage, backup/support level and deployment mode. Actual names/prices/limits remain product decisions; do not copy Sahl prices or hardcode them in clients.

Keep plan limits separate from user permissions. Downgrading below current usage shows the excess and a resolution/grace workflow; never silently delete staff, branches or historical data.

### Customer cycle

1. Owner registers/verifies, or a Baseet administrator/reseller provisions an audited customer.
2. Create one business and choose cloud/local installation, plan, term, start date and expiry date.
3. A permitted Baseet administrator activates the subscription with a reason/reference. The subscription service creates a new immutable revision.
4. Grant versioned business entitlements; activate installations/devices and issue signed bounded license leases for offline-capable modes.
5. Owner invites staff, assigns scope and monitors seats/devices/renewal dates in the customer portal.
6. A Baseet administrator renews, upgrades, downgrades, suspends or cancels using an effective date and reason. Repeating the same request is idempotent.
7. Missed renewal enters the published grace policy, then the published restricted mode. Preserve view/export/backup of customer-owned data according to policy and law.
8. Device replacement/deactivation releases the appropriate entitlement, records the actor and preserves business records.

For offline-only initial setup, create a local owner/business and use a signed manual activation file or approved trial lease; later associate it with the central subscription record without duplicating the business. Offline renewal can import a newly signed lease obtained through another connected device or support channel. No communication is sent and no activation account is created in this planning task.

Baseet may record an optional administrative reference or note for an external payment handled outside the product, but Baseet does not process, verify or reconcile that payment. Only an authorized, audited subscription action changes entitlements.

### Records and state machines

Required records: customer owner, business, plan version, subscription, subscription revision, entitlement grant, installation, device key/activation, offline lease, revocation and audit event. An optional external-reference field contains no card/bank secrets and does not drive authorization by itself.

Subscription entitlement states: trial → active → renewal due/grace → expired/restricted; suspended/revoked are separately reasoned states. Store effective time, recorded time, actor, reason, revision and idempotency ID so retries or older admin requests cannot reactivate a newer terminated plan accidentally.

The control plane is a separately protected service for customer, subscription, license and fleet administration. Local customer databases must never contain master signing credentials. Separate control-plane metadata from operational customer records and make data residency/backup ownership explicit.

### Signed offline lease

Payload proposal: issuer, business ID, installation/device public-key identity, plan/entitlement revision, permitted features/limits, issued/not-before/expiry time, maximum offline duration, nonce/license ID and signing-key ID. Keep unnecessary personal data out of the file.

Sign using a vetted asymmetric signature implementation/provider. The installation verifies with trusted public keys and enforces scope/expiry; only the issuer holds the private key. Bind installation changes to an audited reactivation rather than assuming unstable hardware identifiers uniquely identify an owner forever.

[Keygen offline licensing](https://keygen.sh/docs/choosing-a-licensing-model/offline-licenses/) documents signed license-file patterns and [its cryptography reference](https://keygen.sh/docs/api/cryptography/) documents expiry/verification. Keygen is an evaluation candidate, not an installed service or a selected paid vendor.

Specify lease duration and grace before launch; no arbitrary duration is committed here. Test clock rollback, snapshot restore, lease copying, forged payloads, signing-key rotation and loss of connectivity. Offline seats shared among several machines need a local entitlement coordinator or explicit per-installation allocation, not independent unchecked counters.

### Remote enforcement and administration

The remote authority service enforces subscription status server-side on every protected operation. It reads a short-lived cached entitlement revision from the central subscription service and refreshes it through an authenticated service connection. If the central service is temporarily unavailable, the remote authority follows a bounded cached-entitlement policy; it never trusts a client-supplied plan or expiry date. Suspension/revocation propagation has a documented maximum delay and an operator-visible status.

The PC/mobile/web client receives only the effective capabilities and dates needed for display. Changing local storage, intercepting a response or using an old application version cannot expand access because remote commands are authorized again by the remote authority.

Operator portal must support: customer/business search; plan/catalog versions; subscription status and expiry; create/renew/change/suspend/revoke; license/device revoke/reissue; owner recovery; support approvals; lease-expiry visibility; exports and a complete administrative audit trail. High-impact actions require appropriate privileges and explicit reasons; do not implement a hidden unaudited bypass key.

## 8. Additional acceptance gates

| ID | Scenario | Expected evidence |
|---|---|---|
| X01 | PC posts sale; phone and browser open same business | Same immutable document/operation ID, stock, debt and treasury result |
| X02 | Public internet disconnected in shop LAN | Authorized LAN workflows continue with locally available identity/license validity |
| X03 | Shop server shut down | Clients show unavailable/pending accurately; retry after restart never duplicates |
| X04 | Cloud posting response lost | Resolve operation ID before resubmit; no duplicate invoice |
| X05 | Phone/PC standalone joins LAN/cloud, then a permitted ownership transfer back | Control totals and IDs match; no duplicate imports; only the current authority can write the same partition |
| X06 | Native SQLite and server PostgreSQL run same approved fixture set | Identical quantity, precision, cost, financial and status outcomes |
| X07 | Two offline devices attempt same unallocated last serial | Design prevents unsupported rights; no false global stock guarantee |
| X08 | Admin renewal/change request repeated or arrives with an older expected revision | One correct entitlement revision; stale requests conflict instead of overwriting newer state |
| X09 | Renew/cancel/suspend/downgrade at period boundary | Correct effective state and limits; no record deletion |
| X10 | Forged/copied/expired offline license; clock rollback | Rejected or routed to documented recovery; valid customer retains export/backup path |
| X11 | Device lost/replaced and user revoked | Device/session status correct; bounded offline revocation disclosed |
| X12 | Local identity or central subscription service unavailable | Published bounded continuation/recovery policy; no fabricated authorized status |
| X13 | Browser opens native-only workflow | Supported adapter/alternative shown; no runtime `dart:io` failure or hidden missing function |
| X14 | Business switch/background job or support session | Strict data isolation, job ownership and audit |
| X15 | Encrypted backup restored after hardware loss | Key recovery works; balances/attachments and pending operation deduplication reconcile |

Full system release evidence includes parent-plan A01–A20, C01–C14 and these X01–X15 gates. Selected mode/platform combinations need actual runs, not an assumption that a shared codebase proves identical behavior.

## 9. Decisions still open

Advanced disconnected multi-writer launch scope; final Dart server framework and shared-package extraction; identity provider/local identity package; supported printer/Excel rendering engine; country/tax launch scope; subscription prices/limits/terms/grace; whether to build signing/licensing internally or use a licensing provider; data residency, support access and recovery objectives. Automated billing is excluded. Phone-only offline and shop-LAN mobile access are confirmed requirements, not open options.

Required product target: shared cloud and shop-LAN mobile/PC/web, PC-local and independent offline mobile, with safe ownership-preserving transitions between standalone and shared operation. Full disconnected multi-writer replication remains a separate scope/design decision. All required modes need acceptance before a release is described as complete. No decision authorizes deleting application code during this planning task.
