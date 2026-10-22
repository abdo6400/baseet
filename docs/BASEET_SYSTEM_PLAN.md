# Baseet — complete business system plan

Status: planning only; no implementation authorized.
Prepared: 22 October 2026.
Revised for Baseet: 22 October 2026.
Companions: [Requirements and evidence register](BASEET_REQUIREMENTS_REGISTER.md), [platforms, deployment, security and subscriptions](BASEET_PLATFORM_AND_COMMERCIAL_PLAN.md), and [repository review and fresh-start plan](BASEET_REPOSITORY_REVIEW.md).

## 1. Objective and evidence boundary

Build Baseet as an Arabic-first retail, wholesale, inventory, receivables/payables and financial-control system, usable through mobile, PC and web clients. The product scope belongs to Baseet. Sahl's public capabilities remain an external reference checklist; Baseet's complete cycles, architecture, deployment and commercial operation are first-class requirements beyond that checklist.

This document is a proposed specification, not a statement that Sahl implements every rule below. Requirements concerning transaction integrity, architecture, audit, recovery, and testing are Baseet design proposals. Exact Sahl screen behavior, undocumented limits, keyboard shortcuts, and calculations need observation before implementation decisions are final.

Sources reviewed on 22 October 2026:

- [Learning index](https://getsahl.com/learn): 33 tutorial entries, individually mapped in the feature register.
- [Product overview](https://getsahl.com/): additional publicly advertised capabilities, mapped separately in the register.
- [Setup tutorial page](https://getsahl.com/learn/setup), [version 12 page](https://getsahl.com/learn/new-version-12), [payment setup page](https://getsahl.com/learn/credit-card-setup), and [installments page](https://getsahl.com/learn/instals): page topics and embedded-video presence checked; videos were not watched or transcribed.
- [Pricing](https://getsahl.com/prices) and [download](https://getsahl.com/download): evidence of device licensing, purchase/subscription choices, and trial onboarding. Copying Sahl's prices is not a requirement.

The tutorial index and product pages establish feature scope, not complete feature specifications. The version 12 tutorial does not establish the current installed release. Sahl's advertised regulatory approval does not transfer to Baseet. No Sahl installer was downloaded, no account was registered, and no private system was accessed.

The local planning workspace initially contained an empty Git repository. It is not a checkout of the existing GitHub application. Subsequent review of [abdo6400/baseet](https://github.com/abdo6400/baseet) at commit `ce97ee61b1f56fa01afc9e320fc9a5ad997a02d9` established an existing Flutter application, project architecture rules, boundary tests and build/check workflows. The repository review records what to retain and rebuild. No remote implementation was deleted or changed.

## 2. Completion definition

A complete Baseet release requires all of the following:

1. Every learning-index entry and advertised product capability has a requirement owner, implementation milestone, and acceptance evidence.
2. Product-topic entries are translated into detailed screen/action comparisons through authorized walkthroughs; version-update tutorials are decomposed into their individual features.
3. A business can initialize its data, receive stock, sell, return, transfer, collect, pay, reconcile, report, back up, restore, and upgrade without manual database changes.
4. Inventory, receivables/payables, treasury, tax totals, and reporting reconcile to the same underlying posted transactions.
5. Arabic workflows, printing, scanners, permissions, and simultaneous users are verified on supported devices and deployment modes.
6. Failure, retry, recovery, isolation, and migration tests pass, with documented manual evidence where automation cannot verify a device or external service.
7. Country-specific electronic invoicing is accepted against the relevant official requirements for every country advertised as supported.
8. User documentation, operator runbooks, support, installation, and release procedures are ready.
9. Every cycle C01–C14 in section 15 passes end-to-end reconciliation and reversal/recovery checks.
10. The declared PC/mobile/web and local/remote operating modes pass their own capability, isolation, upgrade and failure tests. A working Android screen is not proof that web or Windows works.
11. Customer registration, tenant provisioning, manually administered subscription, license activation, renewal, expiry, device replacement and data export are verified as one service cycle. Automated billing and payment-provider integration are outside the current plan.

Completing an early milestone is not full parity. No feature is silently removed from scope to meet a date. Any change in scope must update the register explicitly.

## 3. Planning assumptions and decisions

Working assumptions: Arabic-first with English; a shared Flutter client for Android, iOS, Windows and web; barcode scanners and printers through platform adapters; multiple users, warehouses and connected branches; one business base currency initially; country-specific tax and document configuration. All clients are in the product plan; platform-specific release evidence is mandatory. The user explicitly requires both independent offline phone operation with no PC/server/internet and phone access to a local shop server. Native mobile/PC standalone, shop-LAN and remote modes are required; concurrent disconnected multi-writer scope remains a separate decision.

| Decision | Proposed starting position | What must resolve it | Consequence |
|---|---|---|---|
| Deployment | A business-owned server for local/LAN operation, with a separately deployable hosted option | Installation, connectivity, ownership and support requirements | Determines installers, hosting, backup ownership, tenancy |
| Clients | Retain Flutter, Clean Architecture and BLoC/Cubit across mobile/Windows/web | Validate web-safe adapters, responsive screens, printers, Excel and scanners | Share business contracts and components; platform capabilities require separate proof |
| Disconnected branches | Online shared authority first; disconnected operation specified separately | Required maximum outage, oversell policy and numbering policy | Do not promise offline write synchronization without a tested design |
| Database | Transactional relational database; evaluate managed and local operation | Concurrency, backup, restore, installer and cost review | Must provide constraints and atomic business posting |
| Structure | Preserve existing app/core/features and feature data/domain/presentation layout; add a modular authority service | Existing repository rules plus documented package/server extensions | No wholesale architecture replacement or giant business feature |
| Costing | Perpetual weighted average; scope across warehouses to be validated | Observed Sahl examples, returns, transfers and backdated examples | Drives valuations, profit and historical recomputation |
| Negative inventory | Block by default | Observed behavior and business decision | Negative stock requires a separate documented valuation algorithm |
| Currency | One base currency with decimal precision configuration | Walkthrough and target customer needs | Multi-currency is not assumed as verified parity |
| Countries | Common core plus independently validated country adapters | Target launch country, tax authority specifications | No generic country-wide compliance claim |
| Commercial model | Business subscription with explicit user/branch/device entitlements, signed offline license leases and owner portal | Commercial terms, payment-provider suitability and offline policy | Same business data across entitled clients; expired plans preserve export/backup access |
| Accounting depth | Operational subledgers plus chart of accounts, journals, reconciliation and period closing in M27 | Finance-approved mappings, opening migration and statement definitions | Complete retail financial cycle; not a claim about Sahl's exposed accounting features |

Before development, capture the selected options as architecture and product decisions, including rejected alternatives and acceptance implications. Unsettled options block their dependent implementation only; they do not block documenting the full scope.

## 4. Users, navigation and interaction design

Proposed roles: owner/administrator, branch manager, cashier, inventory clerk, purchaser, collections officer, accountant, and read-only auditor. Roles are permission templates, with actions and branch/warehouse scope configured explicitly.

Top-level navigation:

- Home: operational dashboard, shortcuts, alerts, day summary.
- Goods: products, stock balances, movements, counts, transfers, serials, labels, price updates.
- Accounts: customers, suppliers, representatives, statements, receivables, payables.
- Treasury: cash/bank accounts, receipts, payments, expenses, cheques, installments, reconciliation.
- Documents: sales, purchases, both returns, quotations, reservations, archive.
- Reports: daily activity, stock, valuation, analysis, balances, collections and audit.
- Administration: company/branches, users, methods, templates, imports, backups, updates, country settings.
- Help: contextual guidance, tutorial library, version notes, diagnostics and support.

Every document screen needs a list, search/filter, detail view, create/edit draft, validation feedback, posting action, authorized correction/reversal, print preview, linked records, and history. Keyboard order and scanning must be predictable; touch controls must support common cashier actions without precision clicking. Retain filters during navigation, show unsaved changes, preserve recoverable drafts, and make document status unmistakable.

Arabic text, numeric entry, mixed Arabic/Latin codes, dates, currency formatting, and bidirectional layouts must be checked together. Localize messages through shared resources. Use shared design tokens and components for tables, forms, document totals, status badges, confirmations, empty states, loading and errors. Do not build each module with unrelated controls.

## 5. Detailed module specifications

All module details below are proposed Baseet requirements. The register states which feature topics have public evidence and which behaviors still need comparison.

### M01 — Company setup, branches and reference data

- Setup wizard: business identity, logo, country, base currency, tax profile, fiscal opening date, initial administrator, first branch, warehouse and treasury account.
- Maintain company addresses and legal identifiers; branch ownership; warehouse association; business timezone; document numbering and print defaults.
- Configure rounding, quantity precision, cost precision, tax display, default price list and allowed transaction dates.
- Wizard validates missing prerequisites, saves progress and prevents opening the business with inconsistent balances.
- Opening balances use dedicated dated transactions with a review screen and reconciliation report; completion is locked and later changes require an audited adjustment.
- Archive reference records used in transactions instead of deleting historical identity.

Acceptance: initialize a company from a clean installation, resume interrupted setup, reject duplicate required identifiers, and reconcile opening stock, party and treasury balances without unexplained differences.

### M02 — Products, units and selling prices

- Product fields: code, name, alternate searchable name, category, base unit, active status, tax classification, barcode references, serial requirement, and relevant notes.
- Maintain at least three named selling price lists. Support a default list for a customer and authorized selection/override at sale time.
- Separate stored selling prices from calculated inventory cost; hiding cost must also hide derived profit from unauthorized users.
- Define whether alternate units, conversion factors, multiple barcodes and fractional quantities are required during walkthrough validation. The data model should not prevent later explicit support.
- Bulk price update: filtered selection, calculation or fixed value, rounding preview, before/after comparison, authorization, atomic apply and audit.
- Product archive prevents new selection while preserving historical search, labels and document detail.

Acceptance: three price lists produce the expected invoice prices; unauthorized overrides fail at the service boundary; duplicate scans select deterministically; bulk-update failure leaves no partially applied price set.

### M03 — Inventory ledger and opening stock

- Maintain append-only stock movements linked to source documents, warehouse, item, quantity, cost, date, actor and reversal.
- Display on-hand, reserved and available quantities separately. Opening stock records quantity and valuation with a reviewable source.
- Product movement drill-down shows each receipt/issue and how it changed quantity and cost.
- Current and historical balances use effective transaction date and a documented timezone/cutoff policy.
- Transfers do not create sales or company profit. Reservations do not change physical stock.
- Define blocked stock or damaged goods only after confirming operational need; do not silently count unsellable goods as available.

Acceptance: reconstruct quantities from movements; match screen totals to ledger totals; return identical as-of results for the same cutoff after refresh and restart.

### M04 — Costing and profitability

- Store monetary and quantity values with decimal arithmetic, not binary floating point. Define internal precision separately from display precision.
- Weighted-average receipt proposal: new average = (existing inventory value + incoming acquisition value) / new quantity, subject to the selected costing scope.
- Freeze carrying cost at physical issue, including a delivery preceding its invoice; the related sale uses the linked issue cost. Calculate line profit from net revenue and that cost, with explicitly defined tax and discount treatment.
- Define discount, freight allocation, free goods, purchase returns, sales returns, zero stock and transfer treatment in worked examples before coding.
- Backdating requires either blocking after dependent transactions or a controlled chronological recomputation with audit and locked periods. Never recalculate profit silently.
- A return linked to a sale restores the appropriate original cost according to the approved policy; purchase returns require a policy that cannot leave impossible residual valuations.
- Corrections must preserve the original posting trail and update every affected aggregate consistently.

Acceptance: finance-approved examples pass for ordinary receipts, partial sales, both returns, transfers, stock adjustments and backdated corrections; historical valuation equals the sum of retained stock value at its cutoff.

### M05 — Stock counts and adjustments

- Create warehouse count sessions, select products, capture snapshot/time and expected quantities, enter counted quantities, review variances and approve.
- Decide between freezing affected stock and reconciling intervening movements; display the selected policy before counting begins.
- Support interrupted sessions and count-sheet printing/import with row validation.
- Variances produce authorized adjustments with a reason and approved costing treatment, never direct edits to a balance field.

Acceptance: count sessions survive restart; concurrent sales cannot be counted twice; approving the same count twice creates one set of movements; adjustment value reconciles.

### M06 — Warehouse and branch transfers

- Transfer records identify source/destination, products, quantities, serials, initiating user and linked movements.
- Simple same-authority transfers post atomically. If dispatch and receipt occur separately, use an explicit in-transit location and dispatched/received/canceled states.
- Reject invalid warehouse scope, insufficient availability, and serials already committed elsewhere.
- Partial receipt, discrepancy and cancellation rules require explicit approval and traceable adjustments.

Acceptance: warehouse totals change correctly while business-wide quantity/value remain conserved; retries cannot duplicate receipt; a receiving user cannot access unrelated branches.

### M07 — Customers, suppliers and representatives

- Maintain party identity, contact details, legal/tax identifiers where needed, active status, opening balance and default transaction terms.
- A party may act as customer and supplier; keep role-specific balances and define explicit offset transactions rather than netting invisibly.
- Record representatives and document attribution; preserve attribution historically after representative changes.
- Show balances, debit/credit summaries, chronological statements, invoice allocations and source-document drill-down.
- Credit limits, due terms and representative commissions require validation; commissions are not automatically inferred from representative support.

Acceptance: party statement opening + debits − credits equals closing under a documented sign convention; name edits do not rewrite historical printed identity; opening balances cannot be imported twice accidentally.

### M08 — Sales documents and cashier workflow

- Sales header: customer/walk-in policy, branch, warehouse, representative, date, price list, notes and document reference.
- Lines: scan/search, item, quantity/unit, price, permitted discount, tax, serial selection and totals.
- Support draft editing, posting, cash/credit/mixed settlement, change calculation, print/reprint and document lookup.
- Validate stock availability, serials, user scope, price permissions, credit restrictions and required country fields before posting.
- Immediate POS posting persists invoice, stock issue, cost, party balance and payment effects as one business transaction. An invoice matched to an existing delivery consumes its fulfillment link and approved clearing entries without issuing the stock a second time. Printing is a subsequent operation with its own status.
- Corrections use the approved reversal/amendment rules; do not erase posted history. Fiscal documents may require additional country-specific restrictions.

Acceptance: rapid repeated clicks and a lost response create one sale; insufficient stock fails without partial financial effects; print failure preserves the posted sale and offers safe reprint.

### M09 — Purchases and supplier liabilities

- Capture supplier, supplier reference, warehouse, date, lines, acquisition values, discounts, taxes and settlement terms.
- Receive serials where applicable; validate duplicates and quantities before posting.
- Define supplier invoice duplicate detection, acquisition expense allocation and quantity precision.
- Immediate purchase posting receives stock, applies the costing policy, creates supplier liability and records any immediate payment atomically. A supplier invoice matched to existing goods receipts settles the matching/valuation differences and liability without receiving stock again.
- Offer barcode printing for received goods after successful posting; label failure cannot roll back the purchase accidentally.

Acceptance: receipt changes stock and valuation as expected, supplier balance reflects unpaid value, and repeated supplier references trigger the approved warning/block behavior.

### M10 — Sales returns and purchase returns

- Prefer linking each return line to its source line, preserving price, discount, tax, cost and serial lineage.
- Track remaining returnable quantity and reject excess returns, including simultaneous submissions.
- For sales returns, decide physical restocking versus damaged stock and cash refund versus account credit explicitly.
- For purchase returns, validate available stock, returned serial provenance and supplier credit/refund treatment.
- Unlinked returns, exchanges and returns after closed periods require separate documented policies; they are not silently equivalent to linked returns.

Acceptance: partial returns cannot exceed the original quantity across several documents; stock, profit/tax reversals and party/refund effects reconcile to the approved examples.

### M11 — Quotations and reservations

- Create quotations with pricing, customer, validity date, terms, notes and print template.
- Separate quotation status from reservation status. A quotation alone has no financial posting.
- Reservation specifies warehouse, quantity, expiry and owner; it reduces available quantity only.
- Convert all or part to a sale while preserving the linkage; allocate/release reservations exactly once.
- Expiry, explicit release, cancellation, quotation revisions and insufficient stock at conversion have visible outcomes.

Acceptance: two users cannot reserve the last unit simultaneously; partial conversion leaves the correct remainder; retries and expiry workers cannot release fulfilled stock twice.

### M12 — Treasury, receipts, payments and expenses

- Configure cash drawers, bank/clearing accounts, opening balances and permitted branch/user access.
- Receipt/payment records specify party or expense category, date, method, amount, reference, notes and allocations.
- Support customer receipts, supplier payments, general receipts, expense vouchers and authorized transfers between treasury accounts.
- Show opening/day/current balances and a movement ledger with links to original documents.
- Expense categories and period analysis use a controlled classification list; corrections retain history.
- Reconcile counted cash to expected cash and record a separately authorized variance; opening/closing shifts are a proposed operational safeguard to validate against workflow needs.

Acceptance: a receipt cannot be allocated beyond its amount; canceling a voucher reverses allocations and treasury effects; cash-to-bank transfer conserves total funds; drawer reconciliation explains every difference.

### M13 — Settlement methods, cards and credit collections

- Configure methods, allowed accounts, references and whether settlement is immediate or pending.
- Cash/card/mixed tender must reconcile to invoice amount, change and outstanding balance.
- Store payment references and settlement status; store no full card numbers or security codes.
- A card record is not assumed to be an integrated terminal transaction. Terminal integrations need their own adapter, provider contract and retry/callback design if required.
- Credit invoices have due dates, partial payments, explicit allocations, outstanding status and aging.
- Unallocated receipts and overpayments remain traceable credits; refunds or reallocation are separate authorized actions.
- Pending card payments, duplicate callbacks, rejected payments, settlement fees and reconciliation discrepancies need defined transitions.

Acceptance: a partly cash/partly card/partly credit sale reconciles exactly; late card responses cannot collect twice; invoice outstanding derives from valid allocations rather than a manually toggled Paid flag.

### M14 — Cheques

- Register incoming/outgoing direction, amount, party, bank reference, due date, custody and linked invoice/allocation.
- Proposed states: received/issued, held, deposited, cleared, bounced, canceled; permissible transitions depend on direction.
- Define when a cheque affects receivables/payables and when it affects actual bank funds. Keep pending instruments separate from cleared cash.
- Record deposit/collection dates, bounce reasons, reversals, due lists and movement history.

Acceptance: deposit does not masquerade as clearance; a bounced instrument restores the correct debt with a linked reversal; an invalid or repeated transition cannot change balances.

### M15 — Installments

- Create a schedule from eligible invoice outstanding after any down payment: due dates, amounts, frequency, number of payments and rounding remainder.
- Schedule sum must equal the amount assigned to installments; tax, financing charges and penalties require explicit country/business policy before inclusion.
- Track scheduled, partially paid, paid, overdue and canceled/rescheduled status; derive status from allocations and dates.
- Support partial collection, advance collection and approved rescheduling without deleting the previous schedule history.
- Sales returns, invoice correction and overpayments must adjust or credit the plan through an auditable rule.
- Reports show upcoming dues, overdue items, customer totals and collection history. External reminders require separate messaging scope and consent design.

Acceptance: final-payment rounding reconciles exactly; rescheduling preserves collected amounts; a job retry cannot generate duplicate dues; a return cannot leave installment obligations exceeding valid debt.

### M16 — Serial-number lifecycle

- Track each serial by product and owning business through receipt, warehouse, reservation, transfer, sale and return.
- Determine global-versus-product uniqueness from real examples; normalize scan input without destroying meaningful case or characters.
- Serial-required line quantity must equal selected serial count. Prevent one serial from appearing in two active stock locations or simultaneous sales.
- Search a serial's complete document and party history subject to permissions; preserve history after return/resale.

Acceptance: concurrent sale attempts for the same serial yield one success; transfer retains lineage; wrong-product or wrong-original-sale returns are rejected.

### M17 — Barcode scanning and labels

- Keyboard-wedge scanner support, configurable scan completion, barcode lookup and unknown-code handling.
- Label jobs from product selection and posted purchases; preview copies, layout, encoded value, human-readable data and permitted price display.
- Validate supported barcode standards, paper sizes, print drivers and devices before promising compatibility.
- Reprinting labels does not create stock or purchasing events. Scan behavior must remain correct when focus changes or a modal is open.

Acceptance: labels remain readable on representative physical printers/scanners, quantity matches selected copies, and repeated scans follow the intended increment behavior without losing input.

### M18 — Print templates and Excel interoperability

- Templates for sales, purchases where required, returns, quotations, receipts, payments, statements and labels.
- Versioned company/branch defaults; business logo; headers, lines, totals, taxes, signatures, page numbering, RTL and paper size.
- Plan Excel-based invoice-template compatibility explicitly: supported placeholders, line repetition, fonts, page settings, formulas and rendering dependencies must be specified and tested. A web-only template editor is not automatic parity with that workflow.
- Templates are data/layout inputs, not executable macros. Validate uploads and prevent external resource leakage or arbitrary code execution.
- Print preview/PDF and physical printing must agree; retain the template version relevant to reprinting historical documents.
- Export all required reports to Excel with numeric/date cells, filter metadata, correct totals, permission filtering and formula-injection protection for user text.

Acceptance: an approved Excel template produces correct multi-page Arabic output; historical reprint is reproducible; exported totals match the screen; hidden costs cannot be recovered from an export.

### M19 — Search, archive and report center

- Archive filters: type, number, date range, party, branch, warehouse, representative, status, payment state, value and notes.
- Stable pagination and sorting, saved filters, document links and clearly scoped totals.
- Required report inventory:

| Report | Required content and drill-down |
|---|---|
| Daily activity | Sales, purchases, returns, receipts, payments, adjustments; separate business value from actual cash movement |
| Stock on hand | Per product/warehouse on-hand, reserved, available, average cost and value where permitted |
| Historical valuation | Quantity and value at selected cutoff, with costing policy identified |
| Product movements | Opening, each movement, closing, document links and cost changes |
| Sales analysis | Net sales, quantities, cost/profit, margins and share; item/customer/representative/warehouse/day/month groupings |
| Purchase analysis | Purchase/return quantities and values by supplier/product/warehouse/period; detailed dimensions validated in walkthrough |
| Party balances | Customer/supplier debit and credit totals; per-party statement |
| Receivables/payables | Outstanding documents, due dates, aging, unapplied credits and collections/payments |
| Treasury | Opening/closing and every cash/bank movement; method and reconciliation status |
| Expense analysis | Categories and time periods, detail vouchers, totals and comparisons |
| Cheques/installments | State, due date, remaining amount, party and source document |
| Serial history | Product, locations and document/party lineage |
| Price/audit reports | Price changes, overrides and sensitive actions with actors/reasons |

- Define each measure's treatment of returns, canceled drafts, taxes, discounts, date boundaries and zero denominators.
- Aggregate reports use the same posted facts as detail screens. Show freshness if a derived view is delayed; never label stale totals as current.

Acceptance: report grand totals reconcile to drill-down; combining filters cannot reveal another branch's data; historical results follow the approved backdating policy; exports preserve the same filtered scope.

### M20 — Users, permissions and audit

- Accounts, role templates, action-level grants, branch/warehouse restrictions and session lifecycle.
- Independent permissions for viewing cost/profit, price override, discount, post, edit draft, reverse, backdate, export, template edit, user management, backup and restore.
- Apply permissions on commands, queries, background jobs, exports and print payloads; hiding a button alone is insufficient.
- Audit identity, action, object, timestamp, branch, reason and safe before/after business fields. Protect audit integrity and define retention.
- Revoke active sessions after disable/password reset as appropriate; log out clears private cached information and user-specific drafts safely.

Acceptance: a cashier restricted to sales cannot reach other modules through direct requests; a cost-restricted user cannot infer cost from APIs or reports; disabling a user blocks continued protected work.

### M21 — Backups, restore, updates and operations

- Manual and scheduled consistent backups, optional close-time reminder, visible last-success status, destination selection and verified off-device copies.
- Encrypt backups containing business/personal data, keep keys separately recoverable, restrict access and define retention/pruning with legal/business input.
- Restore checks format/version/integrity, shows target business and consequences, requires authorized access and safeguards the current dataset before replacement.
- Include attachments, templates, configuration and schema version as well as business tables. Test restoration onto a clean machine.
- Signed versioned releases, update availability, release notes, backup before migration, compatibility checks and recovery when an update is interrupted.
- In a multi-user installation, coordinate application/schema versions and prevent old clients from corrupting upgraded data.
- Monitor safe operational metrics: backup failure, failed jobs, synchronization status, report lag, disk usage and update failure. Diagnostics redact personal data and secrets.

Acceptance: restore from a real backup reproduces reconciled balances; a corrupt backup cannot overwrite live data; an interrupted upgrade leaves a recoverable installation; backup jobs cannot report success on an unreadable file.

### M22 — Tax and electronic invoicing

- Common tax/document model: effective-dated tax categories, inclusive/exclusive prices, discounts, rounding, legal identity, numbering and document links.
- Country adapters own schemas, signing/credentials, QR generation where applicable, submission, acknowledgement, correction and archival rules.
- Draft → locally posted → pending submission → accepted/rejected states must be distinguishable; exact permitted issuance behavior follows the relevant country's official rules.
- Durable submission outbox with idempotency, safe retries, reconciliation and operator action for rejections. Never present a failed submission as authority acceptance.
- Store credentials in protected storage; audit access; test certificate expiry/revocation and business identity changes.
- Saudi support must have its own official-specification, sandbox and onboarding validation. Egypt or another jurisdiction receives an independent workstream if selected.

Acceptance: country-specific acceptance suite and required external validation pass before a support claim; duplicate or delayed responses do not create another invoice; country rules cannot be bypassed by editing a normal document screen.

This is a compliance engineering plan, not legal advice or a claim of certification. Detailed legal/tax requirements must be researched from current official sources during the country workstream.

### M23 — Onboarding, learning, commercial administration and support

- Product onboarding: trial/demo path, sample business separated from live data, guided setup and first-use tasks.
- User learning library aligned one-to-one with the feature register, searchable contextual help, version notes and administrator guidance.
- Full product package includes a website/help center, installer distribution, account recovery and a support request route. These are separate deliverables from the business application.
- Required subscription operation: device/license assignment, activation, trial expiration, manual renewal and plan entitlements, deactivation/device replacement and offline grace policy. M24/M25 own the authoritative account/subscription/license records; M23 owns the onboarding/help experience.
- Expiration never deletes business data; define read/export and backup access explicitly. Use payment-provider handling for subscription collection rather than storing sensitive payment credentials.
- Support diagnostics are reviewed before sharing; customer data access requires explicit access controls and audit. No support messages are sent during this planning task.

Acceptance: a trial user can reach a first successful sale; activation retries are safe; changing devices does not strand data; support instructions cover printing, backup, upgrade and connection failures.

### M24 — Business accounts and service administration

- Customer owner registration, verification, recovery, business creation, ownership transfer and staff invitations; separate owner/subscription administration from cashier identity.
- Provision a business, branch defaults, storage/database scope, region/deployment selection and immutable business ID using a recoverable workflow.
- Local installations use a locally available identity/authorization authority for daily work; a cloud identity outage cannot unexpectedly disable a valid local installation.
- Standalone setup can create a local owner without a cloud login; offline commercial activation uses an approved signed activation/lease path. Later association with a cloud owner preserves audit identity and data ownership.
- Operator console supports business/license lookup, provisioning status, plan history, support access approvals, audit and recovery; support is not a universal unlogged administrator.
- Account suspension, deletion and legal retention are explicit workflows, separate from subscription expiry. Define what local records are retained and how export remains available.

Acceptance: owner creation → business provisioning → staff invitation → first authorized login succeeds; retry after partial provisioning resumes one business; tenant A cannot discover tenant B's records or backups.

### M25 — Subscriptions and licensing

- Implement manually administered business subscriptions, plan entitlements, activation, signed offline leases and expiry behavior defined in the platform plan. No payment gateway, recurring charge or billing webhook is required.
- Proposed billable dimensions are business/branches and active staff seats, with a device limit where commercially required. Avoid charging one person separately for phone/PC/browser unless the chosen plan explicitly says so.
- Keep plan definitions configurable and distinct from feature authorization. An application's local subscription flag is not an authority.
- Support trial, active, renewal due, grace, expired/read-only, suspended and revoked states. Every manual state/date change records administrator, reason and time.
- The subscription service is the authority for connected/remote installations. Local installations validate a signed time-bounded license lease and can refresh it online or import an authorized renewal file.

Acceptance: one approved admin action grants or renews once; repeated requests, downgrade over limits, device replacement, offline expiry, clock rollback, suspension and revocation follow documented rules without deleting customer data.

### M26 — Shared clients, deployment modes and synchronization

- Implement the capability matrix, authority model, secure local pairing and per-business mode configuration in the platform plan.
- Cloud and local-LAN clients post through one authority per business/stock partition. A cache is not an independent authoritative ledger.
- Required standalone mobile/PC uses a verified embedded authority; cross-mode promotion/join to LAN/cloud is a controlled migration with cutover, deduplication and rollback. Returning a previously promoted business to standalone authority needs an explicit transfer of ownership, not a casual endpoint switch.
- Offline multi-writer/hybrid operation requires explicit inventory/serial ownership, reservations, numbering, immutable event replication, safe replay and conflict handling; it is a separate release gate.
- Replace snapshot transfer as a sharing mechanism. Retain legacy `.baseet` import only as a labeled migration/recovery path with preview and safety backup.

Acceptance: phone, PC and browser see the same posted sale against the same authority; LAN mode survives loss of public internet; cloud disconnection has a truthful status; migration does not produce two writable authorities for the same stock.

### M27 — General ledger, reconciliation and closing

- Chart of accounts, account classifications, opening journal, fiscal periods, document-to-account mappings and balanced journal entries.
- Automatically post inventory, cost, revenue, receivables, payables, treasury, taxes, expenses, returns, instruments and adjustments; prevent double posting.
- Operational cash/party/stock accounts are reconciliation subledgers. Manual journals cannot bypass the documented control-account policy or silently alter stock quantity.
- Trial balance, general ledger, profit-and-loss, balance sheet and cash-movement reconciliation have explicit definitions and drill-down. A formal cash-flow statement requires a separately specified mapping before it is advertised.
- Period close reviews inventory value, pending receipts/invoices, party balances, cash/bank, instrument clearing, tax, suspense/unapplied amounts and profit. Lock closed periods; reopening requires permission, reason and audit.
- Opening migration and year rollover preserve original supporting documents and traceable retained balances; no destructive annual reset.

Acceptance: journal debits equal credits; subsidiary balances reconcile to control accounts; balance sheet balances; net trading profit includes approved expenses/adjustments; closed-period edits fail and authorized reopening is auditable.

### M28 — Procurement and fulfillment completion

- Purchase request/order → partial/full goods receipt → supplier invoice matching → payable → payment/reconciliation, with an immediate-purchase shortcut for a small shop.
- Sales quotation/order → reservation → partial/full delivery → invoice → collection/reconciliation, with immediate POS sale as the simple combined flow.
- Each quantity has ordered, received/delivered, invoiced, returned and outstanding values. Reject duplicate fulfillment and over-receipt/invoicing according to policy.
- Specify exactly which document owns stock and financial effects: a receipt/delivery moves stock once; an invoice matched to that movement never moves it again. Use approved uninvoiced-receipt/delivery clearing accounts where needed.
- Define provisional acquisition value for an uninvoiced receipt and how invoice price/expense differences affect remaining stock and quantities already sold. Define delivery-to-invoice cost recognition and clearing so revenue, inventory and cost are neither omitted nor booked twice.
- Returns against an uninvoiced receipt/delivery reverse its physical/clearing effects; invoiced returns additionally create the appropriate credit/tax/refund effects. Source links enforce one physical return even when several business documents describe it.
- Manage cancellations of remaining quantities, supplier/customer discrepancies, short delivery, received-not-invoiced reconciliation and linked return/credit documents.

Acceptance: receive a purchase order in two parts and invoice it without duplicate stock; partially deliver and invoice a customer order, return part and settle the remainder; every residual quantity and clearing balance is explained.

## 6. Architecture and data ownership

Proposed layers: shared presentation/design system → application commands/queries → business domain modules → infrastructure adapters. UI construction cannot calculate authoritative balances, perform database access, or decide accounting rules. Domain code does not depend on printer drivers, UI frameworks, cloud SDKs or country submission clients.

Modules: identity/access; organization/configuration; catalog/pricing; inventory/costing; parties; sales/fulfillment; purchasing/procurement; reservations; treasury/allocations; cheques; installments; general ledger/closing; reporting; document rendering; country adapters; operations; tenant administration; subscription/licensing; deployment/synchronization. The existing Flutter architectural conventions remain the baseline; see the repository review for exact standards and proposed extensions.

Core records:

| Area | Main records | Ownership/integrity rule |
|---|---|---|
| Organization | Business, branch, warehouse, fiscal period, numbering series | Business scope on every protected record |
| Identity | User, role, grant, scoped membership, session | All service entry points authorize |
| Catalog | Product, unit, barcode, price list, price revision | Unique identifiers in approved scope |
| Parties | Party, party role, representative, opening entry | Statements derive from posted entries |
| Documents | Header, line, tax/discount snapshot, status, version, source links | Historical business data is versioned/snapshotted |
| Inventory | Movement, reservation, serial event, count, transfer, costing entry | No uncontrolled balance overwrite |
| Finance | Journal, journal line, treasury movement, allocation, instrument, installment schedule | Balanced posting and allocation constraints |
| Operations | Audit event, outbox message, job attempt, template version, backup manifest | Durable, scoped and recoverable |

Store stable internal IDs separately from human-readable document numbers. Every mutation has an operation ID/idempotency key and concurrency version where needed. Store timestamps plus business-effective dates explicitly. Define deletion, archival, retention and export policies per record type.

Atomic posting example: a sale command validates scope and current state, locks/checks inventory and serials, writes document snapshots, inventory/cost entries, balanced financial entries, allocations, audit and outbox messages, then commits. Printing or a remote submission runs after commit and can be retried independently. A response timeout is resolved by looking up the existing operation result.

Internal financial proposals: a credit sale debits receivables and credits sales/tax liability, with a separate inventory-to-cost entry; a collection debits treasury and credits receivables. Purchases and returns have explicitly approved counterpart entries. These are internal consistency requirements; they do not imply an exposed general-ledger feature was verified in Sahl.

Report projections are rebuildable from authoritative postings. A rebuild must not create business events. Background workers use the same authorization scope, transaction boundaries and duplicate protections as foreground requests.

## 7. Connectivity, concurrency and recovery contract

- Local/LAN users share one authoritative transactional database through the service layer; do not copy writable database files between machines as synchronization.
- Connected branches use explicit authenticated transport and scoped access. Loss of connectivity leaves a truthful connection state and recoverable drafts.
- If disconnected posting is required, design branch ownership, stock allocation, globally unique IDs, fiscal numbering, conflict resolution, outbox/inbox deduplication and stale permission rules before enabling it. A last-write-wins merge is unacceptable for financial/stock events.
- UI cancellation stops waiting where possible; it does not assert a committed posting was undone. Resume resolves the operation ID before allowing another submission.
- Reservation expiry, installment status updates, backup, report refresh, synchronization and tax submission jobs record attempts and resume safely after process restart.
- Jobs cannot apply results for a business/user that has been switched or signed out. Credentials and cached payloads are isolated by business and session.
- Define retryable versus terminal errors, retry limits, escalation and replay tools per job. Never discard failed business events silently.

Recovery acceptance must include client crash, service crash before/after commit, network loss after commit, two simultaneous last-unit sales, duplicate job delivery, old-client access after upgrade, and switching business while a request is in flight.

## 8. Import, migration and opening-day plan

- Import templates for products, prices, parties, opening stock, opening party/treasury balances and serials where appropriate.
- Parse into a staging area, preview every validation issue, map fields, normalize carefully, show duplicate strategy and compute control totals before posting.
- Use batch IDs and original row references. A failed batch either commits nothing or reports its explicitly resumable state; never silently skips rows.
- Separate test import from live import. Reconcile inventory quantity/value and party/treasury totals against signed opening reports.
- For migration from Sahl, assess authorized export formats and sample files first. This task has not established direct database or file compatibility.
- Preserve original document references, opening cutoffs and supporting exports. Decide whether historical documents are fully migrated or archived read-only with opening balances; disclose the difference.
- Trial cutover: freeze source changes, take backups, import, reconcile, validate physical outputs, obtain business sign-off and document rollback before live trading.

Acceptance: importing the same batch again cannot duplicate openings; all source rows are accounted for as accepted/rejected; rollback preserves the original source and reconciled destination snapshot.

## 9. Verification and concrete acceptance scenarios

The existing application's Flutter verification commands and architecture test are recorded in the repository review. The local planning workspace does not contain that executable application. Preserve those checks and extend them for the selected server/shared packages; establish one documented verify entry point covering formatting, static analysis, architecture boundaries, full tests, security scans and build.

Test levels: pure calculation/domain tests; transactional database integration tests; permission/API tests; end-to-end business workflows; physical hardware/print checks; concurrency/recovery tests; backup/upgrade restoration; and country-adapter contract tests. Do not substitute isolated unit tests for transaction or device verification.

Use these numerical examples as initial specification fixtures, with tax disabled unless a fixture specifies it. The weighted-average examples assume one costing pool and no rounding loss.

| ID | Scenario | Required result |
|---|---|---|
| A01 | Receive 10 units at 100, then 10 at 140 | 20 units, value 2,400, average 120 |
| A02 | Sell 5 of those units at 180 on credit | Stock 15/value 1,800; receivable 900; revenue 900; cost 600; gross profit 300 |
| A03 | Collect 400 against A02 | Treasury +400, receivable 500, stock/profit unchanged |
| A04 | Return 2 units from A02 at original terms as account credit | Stock 17/value 2,040; credit 360; receivable 140 after A03; net revenue 540/cost 360/profit 180 |
| A05 | Independent fixture: transfer 4 units at carrying cost 120 between warehouses | Source −4/−480, destination +4/+480; business quantity/value unchanged; no profit |
| A06 | Independent fixture: reserve 3 of 10 units, fulfill 2 | Initially on-hand 10/available 7; after fulfillment on-hand 8/reserved 1/available 7 |
| A07 | Sell invoice of 1,000 with 200 cash, 300 card and 500 credit | Settlements 500, debt 500; cash 200; card account follows approved clearing policy |
| A08 | Split 1,000 into three installments without charges | 333.33, 333.33, 333.34; collect 100 on first → first outstanding 233.33/total outstanding 900 |
| A09 | Two users submit the last available unit or same serial | One accepted posting; one clear conflict; no negative balance or duplicated serial |
| A10 | Timeout after a committed sale, then retry | One invoice, one set of movements/entries; same result returned |
| A11 | Incoming cheque 500 deposited, then bounced | Pending/cleared effects match approved policy; debt reinstated exactly once; full history retained |
| A12 | Count expected 10 while a sale of 2 occurs | Approved freeze/intervening-movement policy prevents a fictitious variance |
| A13 | Attempt a second return beyond remaining source quantity | Rejected atomically across concurrent submissions |
| A14 | Cost-restricted user searches, exports, prints and calls reports directly | No cost/profit fields or derived disclosure in any response |
| A15 | Restore on a clean machine | Same document counts, stock value, party/treasury totals, templates and schema version |
| A16 | Edit an earlier receipt after later sales or a locked period | Block or controlled approved recomputation; no unexplained historical drift |
| A17 | Print service fails after sale commit | Sale remains valid; reprint succeeds without reposting |
| A18 | Business switch/sign-out while job/request is active | No previous business payload reaches the new session; queued authorized work follows its defined lifecycle |
| A19 | Country adapter receives rejection or duplicate acknowledgement | Honest status, safe retry/reconciliation, one legal document identity |
| A20 | Bulk import contains bad units, duplicate serials and a repeated batch ID | Exact row diagnostics; approved transaction policy; no silent loss or duplication |

Additional required fixtures: taxes inclusive/exclusive; line versus document discount allocation; fractional quantities; zero-cost stock; purchase-return costing; refunds after partial payment; period boundaries; cheque cancellation; installment rescheduling after a return; partial transfer receipt; reservation expiry racing conversion; restored backups with pending outbox messages; duplicate card callbacks; malformed templates and exports; and interrupted migrations.

Before release, map each fixture to automated evidence or a named manual run. Each manual run records build, environment, device, input data, expected/actual result and evidence location.

## 10. Security and operational quality gates

- Review secrets, personal data, authentication/session lifecycle, input validation, transport, dependencies and permissions for every code change.
- Use TLS and proper certificate validation for networked operation; no production trust-all connections.
- Keep database/service credentials, country signing material and backup keys in appropriate protected storage. Never log tokens, payment details, party contact data or raw imported business files.
- Enforce business isolation and role restrictions on lists, aggregates, jobs, exports, templates and support tools.
- Validate uploaded spreadsheets/templates, file sizes, archive traversal, untrusted formulas, barcode content and document references.
- Run secret scans, dependency/security tooling and SAST as selected for the actual stack; record new versus pre-existing findings with locations and impact.
- Backup/recovery objectives, performance budgets, maximum dataset size, availability and support targets must become measured release criteria after sizing discovery, not guessed marketing claims.
- Suggested performance test profile to finalize: several years of stock movements and invoices, simultaneous cashier/users, historical valuations, bulk import/export and backup during business traffic. Record p95 interaction/report latency and resource use against agreed budgets.

Regression gate: full suite plus architecture validation, final diff review, dependency/contract review, current target-branch comparison, and real-app happy/failure flows. Maintain a compatibility matrix for client/server/schema, supported Windows versions, printers/scanners, locales and country-adapter versions.

## 11. Delivery roadmap and dependencies

These phases sequence the complete scope. They are not authorization to start development and do not remove later features from the final release definition.

| Phase | Work package | Depends on | Exit gate |
|---|---|---|---|
| P0 | Baseet scope, complete cycles, repository preservation and reference validation | Read-only repository review; authorized product evidence | Every register row assessed; cycle definitions approved; fresh-start manifest; deployment/offline decisions; signed worked examples |
| P1 | Product design and technical/hardware proofs | P0 deployment/country/costing decisions | Shared design system, screen/action inventory, print/Excel/scanner proofs, selected architecture |
| P2 | Foundations and setup | P1 | Identity/scopes, tenant provisioning, company/branches, reference data, API/embedded authority contracts, audit, schema migrations, CI/verify and backup skeleton |
| P3 | Inventory, parties and financial posting core | P2 | Products/prices, openings, ledger, costing, parties, balanced posting and import reconciliation fixtures pass |
| P4 | Core trading vertical slice | P3 | Purchases, sales, both returns, receipts/payments, treasury, basic print, procurement/fulfillment links; end-to-end balances reconcile |
| P5 | Inventory operations and advanced pricing | P4 | Counts, transfers, serials, bulk prices, labels, quotations/reservations and concurrency tests |
| P6 | Collections and financial controls | P4 | Split/card/credit, allocations, aging, cheques, installments, expenses, general ledger, statements and period closing |
| P7 | Reports, archive and output parity | P5/P6 | All reports, historical valuation, Excel exports/templates and physical print evidence |
| P8 | Deployment, connectivity and recovery | P2 foundation; P4–P7 behavior | PC/mobile/web capability matrix, LAN/remote and selected standalone/hybrid modes, installers, backup/restore and update drills |
| P9 | Country electronic invoicing | P0 country discovery; P4 document contracts | Official requirements traced, adapter sandbox tests and required external validation complete |
| P10 | Subscription service, product packaging and support | P2 tenant foundations; P7/P8 | Owner/admin portal, trial/subscription/license cycles, administration, learning, distribution and support runbooks |
| P11 | Baseet cycle acceptance, reference coverage audit, pilot and launch readiness | All preceding phases | Register closed with evidence; every declared business/platform/commercial cycle, migration rehearsal and release acceptance |

Country requirements discovery begins in P0, and prototypes in P1 must consider its impact on numbering, immutable invoices and rounding. P9 is the integration acceptance milestone, not a reason to postpone those structural requirements.

Some engineering packages may overlap after their contracts are settled. Estimate time and staffing only after P0/P1: printer/Excel compatibility, offline requirements, regulatory onboarding, migration quality and newly discovered video features materially affect effort. Do not present a full-system schedule based only on a tutorial index.

## 12. Work breakdown and ownership model

Each feature becomes an epic with these required child tasks:

1. Evidence: source topic, walkthrough observations, uncertainties and parity examples.
2. Specification: fields, statuses, screen actions, permissions, invariants, errors and side effects.
3. UX: list/detail/form/print states, keyboard/touch behavior and localized content.
4. Domain/data: records, constraints, transaction boundaries, history and migration.
5. Interfaces: commands, queries, device/external adapter contracts and background jobs.
6. Verification: numerical fixtures, permission tests, concurrency/recovery and full-flow acceptance.
7. Operations: import/export, audit, diagnostics, backup/restore and upgrade effects.
8. Documentation and evidence: help, runbooks, screenshots/output samples, acceptance sign-off.

Assign named business and engineering owners when a team exists. Finance approves cost/balance fixtures; operations approves deployment/recovery; actual operators approve cashier/stock workflows; country specialists validate country rules. Ownership here is a future project responsibility, not a request to contact anyone now.

## 13. Parity discovery procedure and remaining questions

For every tutorial or product capability, record the exact title and URL, product version/date, screen entry points, fields/defaults, available actions, permissions, print/report output, edge cases, and a reproducible business scenario. Watch the relevant tutorial and compare against an authorized current product instance where available. Capture only authorized evidence; do not infer private source code or undocumented integrations.

Highest-impact unresolved items:

- What additional features are demonstrated in version 12 and its tips video?
- Which deployment, branch and disconnected modes actually exist, and which must Baseet support?
- What costing scope, return valuation and backdated-edit rules produce matching Sahl results?
- Which document types support edit/delete, and what financial/fiscal history is retained?
- How do cheque custody/clearance and card settlement change debt and treasury balances?
- What installment rescheduling, partial payment and return rules exist?
- Which unit conversions, currencies, discount types, taxes and product fields exist?
- What exact Excel template contract and hardware combinations are supported?
- What limits, permissions, keyboard shortcuts, imports and report dimensions are undocumented?
- Which country and electronic-invoicing requirements are needed for Baseet's first release?
- What are the final Baseet plan names, prices, limits, renewal periods, grace durations and support terms? Automated billing/payment-provider integration is excluded; Baseet administrators record and authorize subscriptions manually.
- The user confirmed both independent phone-only offline operation and access to a local shop authority. Resolve whether multiple devices may independently post against the same stock while disconnected; this is additional to the confirmed single-device standalone mode.

No answers are required to review this plan. These items become explicit discovery tasks before dependent implementation. Unknowns cannot be marked as matched or dismissed as out of scope without a recorded decision.

## 14. Final release review and planning-task verification

Future release review: every register row must link to implementation and acceptance evidence, every module must reconcile with its dependent ledgers, and every unresolved decision must be closed or explicitly documented as an accepted gap. An accepted gap means the product is not described as exact full parity for that feature.

Planning-task verification:

- Read public learning, product, pricing and download pages, plus selected linked tutorial pages.
- Extracted all 33 tutorial links from the live learning index and mapped them in the companion register.
- Initially inspected the local planning workspace and ancestor instruction locations; that local folder has no application implementation or prior commits. The separately reviewed GitHub application does have project rules, checks and commit history.
- Reviewed the plan for coverage of all source topics, less visible execution contexts, security, recovery, migration and acceptance requirements.
- Repository review subsequently read pinned source files, architecture rules/tests and workflows; these findings supersede the original assumption that no Baseet implementation existed anywhere.
- No application code, dependencies, build configuration, accounts or external records were created or modified. No commit, push or PR was made. Existing GitHub code has not been removed.
- Formatting/link/coverage checks for the planning deliverables are recorded in the task's final response. Application tests and runtime/security scans were not run because this remains a documentation-only task in a planning workspace.

## 15. Complete-cycle audit and added Baseet requirements

Assessment of the previous plan: it covered most retail operations as individual modules and included useful financial/recovery invariants. It did not yet fully specify procurement-to-payment and order-to-fulfillment stages, exposed financial closing, the business subscription lifecycle, or shared-platform/local-mobile operating contracts. It was a strong scope baseline, not a complete implementation-ready system specification. M24–M28 and the platform plan close these planning coverage gaps; detailed state/API/field specifications still belong to P0/P1.

| Cycle | Start → intermediate work → close | Affected modules | Required proof at cycle close |
|---|---|---|---|
| C01 Business opening | Owner signup → business/branch/warehouse setup → reference/import/openings → reviewed opening date | M01/M02/M07/M24/M25 | Stock, GL, parties and treasury reconcile; roles/license valid; one business provisioned |
| C02 Purchase to pay | Reorder/request → purchase order → partial goods receipt → supplier invoice/match → payable → payment/cheque → reconciliation | M09/M12–M14/M27/M28 | Received/invoiced/returned/outstanding quantities reconcile; supplier and clearing accounts reconcile |
| C03 Sale to cash | Quote/order or POS → reserve/deliver → invoice → cash/card/credit collection → bank/treasury settlement | M08/M11–M13/M27/M28 | One stock issue, correct revenue/cost/tax, all payment/debt residuals explained |
| C04 Sales return/refund | Original sale → partial return → stock/damage disposition → credit/refund → allocation/installment update | M04/M10/M12–M16/M27 | Return quantity bounded; original cost/tax policy applied; refund/debt/plan reconciles |
| C05 Purchase return | Original receipt/invoice → return → supplier credit/refund → payment reallocation | M04/M09/M10/M12/M14/M27/M28 | Stock and valuation correct; supplier payable/credit and receipt matching reconciled |
| C06 Inventory control | Opening/receipt → reserve/issue → count → approved adjustment → valuation | M02–M05/M11/M16/M19/M27 | Quantity and historical value reconstruct from ledger; no manual unexplained overwrite |
| C07 Stock movement | Dispatch → in transit → partial/full receipt → discrepancy/cancellation closure | M06/M16/M27 | Per-location balances reconcile; business value conserved except explicit authorized loss |
| C08 Receivables and installments | Credit sale → schedule/due date → partial/advance collection → overdue/reschedule/return → final settlement | M07/M13/M15/M27 | Invoice, party, schedule and allocation balances agree; no debt lost on reschedule |
| C09 Treasury and instruments | Opening funds → receipt/payment/expense → pending card/cheque → clear/bounce → reconcile/close | M12–M14/M27 | Actual bank/cash distinguished from pending funds; differences reviewed and posted |
| C10 Financial period | Open period → all transaction postings → subledger reconciliation → adjustments → statements → lock/rollover | M04/M19/M27 | Trial balance balanced; stock/party/treasury controls match; closed-period rules enforced |
| C11 Multi-device work | Pair/login → scope check → synchronized reads → competing posting → interruption/retry → reconciled resume | M20/M26; authority contract | One accepted posting; truthful pending/rejected state; no cross-business data |
| C12 Recovery and upgrade | Backup → manifest verification → restore rehearsal → update/migration → reconcile/recover | M18/M21/M26 | Data, attachments, licenses and pending jobs restored without replay duplicates |
| C13 Client subscription | Customer/business registration → administrator selects plan/term → entitlement/license → manual renew/change → grace/expiry/suspend/revoke → export | M23–M25 | Central subscription and connected access agree; stale offline leases are bounded; every change is audited; customer data remains retained/exportable |
| C14 Country document | Prepare → legal validation/numbering → post → submit → accepted/rejected correction → archive/report | M08–M10/M18/M22/M27 | Correct authority status, linked corrections, preserved legal identity and accounting reconciliation |

Each cycle requires a normal run, a partial/reversal run where meaningful, a permission failure and a crash/retry or interruption run. Execute against the declared supported platform/mode matrix, not only an in-memory domain test.

Boundaries: this is a complete retail/wholesale business-system plan. Manufacturing/MRP, payroll/HR, full fixed-asset management, industry-specific workflows and multi-currency treasury are separate future scopes unless requested. No broad claim of a universal ERP is implied. Finance and country-specific acceptance still require detailed definitions and appropriate validation.
