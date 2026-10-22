# Baseet requirements and evidence register

Prepared: 22 October 2026. Status: planning only.
Plan: [Baseet complete system plan](BASEET_SYSTEM_PLAN.md).
Related: [Platforms and commercial service](BASEET_PLATFORM_AND_COMMERCIAL_PLAN.md); [repository and fresh-start review](BASEET_REPOSITORY_REVIEW.md).

Evidence labels:

- **Topic verified**: the named entry and link exist on the public tutorial index. Video behavior has not been verified.
- **Advertised**: described on the public product website. This is not runtime verification.
- **Proposed foundation**: Baseet engineering requirement; do not attribute it to Sahl.
- **Discovery required**: exact specification or contained feature list is unknown.

Baseet owns the product scope. Sections A/B retain Sahl as an external reference checklist. Sections C/E cover Baseet system requirements and complete cycles beyond that checklist. The tutorial table deliberately uses concise English topic labels. Original Arabic titles remain available through the linked source pages. Implementation details and acceptance rules are Baseet proposals in the main plan.

## A. All 33 learning-index entries

Source: [Sahl learning index](https://getsahl.com/learn).

| ID | Tutorial topic/source | Evidence | Plan coverage | Required acceptance evidence |
|---|---|---|---|---|
| L01 | [Quick tour](https://getsahl.com/learn/start) | Topic verified | Navigation; M23; P0 | Screen/action inventory and operator walkthrough |
| L02 | [Setup](https://getsahl.com/learn/setup) | Topic verified | M01 | Clean-company setup and interrupted setup recovery |
| L03 | [Products and opening stock](https://getsahl.com/learn/enter-stock) | Topic verified | M02–M04; import plan | Opening quantity/value reconciliation |
| L04 | [Parties and opening balances](https://getsahl.com/learn/enter-accounts) | Topic verified | M07; import plan | Statement and opening balance reconciliation |
| L05 | [Sales representatives](https://getsahl.com/learn/enter-salesmen) | Topic verified | M07–M08; M19 | Historical attribution and report filtering |
| L06 | [Sales](https://getsahl.com/learn/sales) | Topic verified | M08 | A02/A07/A09/A10/A17 and cashier walkthrough |
| L07 | [Purchases](https://getsahl.com/learn/purchases) | Topic verified | M09 | A01; supplier liability and label flow |
| L08 | [Sales returns](https://getsahl.com/learn/return-sales) | Topic verified | M10 | A04/A13 and refund/account-credit scenarios |
| L09 | [Purchase returns](https://getsahl.com/learn/return-purchases) | Topic verified | M10; M04 | Supplier credit, serial/stock and valuation fixtures |
| L10 | [Stocktaking](https://getsahl.com/learn/stock-inventory) | Topic verified | M05 | A12 and approval/retry reconciliation |
| L11 | [Warehouse transfers](https://getsahl.com/learn/stores-transfer) | Topic verified | M06 | A05 and partial/in-transit recovery if applicable |
| L12 | [Payments and expenses](https://getsahl.com/learn/payments) | Topic verified | M12 | Voucher reversal, category totals and treasury reconciliation |
| L13 | [Receipts](https://getsahl.com/learn/receipts) | Topic verified | M12–M13 | A03 and allocation/reversal fixtures |
| L14 | [Goods area](https://getsahl.com/learn/stock) | Topic verified | Navigation; M02–M06 | All demonstrated list actions mapped during P0 |
| L15 | [Accounts area](https://getsahl.com/learn/accounts) | Topic verified | Navigation; M07/M12–M15 | All demonstrated account actions and statements mapped |
| L16 | [Treasury area](https://getsahl.com/learn/money) | Topic verified | Navigation; M12 | Opening/current/period movement reconciliation |
| L17 | [Invoices area](https://getsahl.com/learn/invoices) | Topic verified | M08–M11; M19 | Document-type/action and archive comparison |
| L18 | [Daily activity](https://getsahl.com/learn/daily-report) | Topic verified | M19 | Source documents reconcile; cash distinguished from sales |
| L19 | [Sales analysis](https://getsahl.com/learn/sales-analysis-report) | Topic verified | M04/M19 | Net sales/cost/profit and grouping fixtures |
| L20 | [Purchase analysis](https://getsahl.com/learn/purchases-analysis-report) | Topic verified | M19 | Purchase/return totals and observed dimensions |
| L21 | [Users](https://getsahl.com/learn/users) | Topic verified | M20 | A14/A18 and complete permission matrix |
| L22 | [Print design](https://getsahl.com/learn/prints-customize) | Topic verified | M18 | Edited template, Arabic pagination and historical reprint |
| L23 | [Barcodes](https://getsahl.com/learn/barcode) | Topic verified | M17 | Physical scan/label evidence and unknown-code handling |
| L24 | [Quotations and reservations](https://getsahl.com/learn/sales-quotations) | Topic verified | M11 | A06 plus conversion/expiry race fixtures |
| L25 | [Selling-price updates](https://getsahl.com/learn/sales-prices-update) | Topic verified | M02 | Preview, authorized apply and all-or-nothing failure |
| L26 | [Serial numbers](https://getsahl.com/learn/serial-numbers) | Topic verified | M16 | A09 plus purchase→transfer→sale→return lineage |
| L27 | [Version 12 additions](https://getsahl.com/learn/new-version-12) | Discovery required | P0; all affected modules | Watch/decompose into individual child feature rows before closure |
| L28 | [Payment-method setup](https://getsahl.com/learn/credit-card-setup) | Topic verified | M13 | Configured method/account behavior and restrictions |
| L29 | [Cash and card settlement](https://getsahl.com/learn/cash-payment) | Topic verified | M13 | A07; failed/pending card settlement and duplicate callbacks |
| L30 | [Credit settlement](https://getsahl.com/learn/credit-payment) | Topic verified | M13 | Partial collections, aging, unapplied credit and reversal |
| L31 | [Cheques](https://getsahl.com/learn/cheques) | Topic verified | M14 | A11 plus direction-specific valid/invalid transitions |
| L32 | [Installments](https://getsahl.com/learn/instals) | Topic verified | M15 | A08 plus rescheduling, overdue and return adjustment |
| L33 | [Version 12 tips](https://getsahl.com/learn/notes-version-12) | Discovery required | P0; UX; M23 | Watch/decompose shortcuts, options and extra behaviors before closure |

## B. Additional advertised capability coverage

Source for H01–H18 and H20: [Sahl product overview](https://getsahl.com/). The labels below summarize the advertised capabilities only; proposed detailed behavior is specified independently in the plan.

| ID | Advertised capability | Evidence | Plan coverage | Required evidence |
|---|---|---|---|---|
| H01 | Arabic-oriented ease of use | Advertised | Navigation; M23 | Arabic operator usability and first-use test |
| H02 | Excel-editable document designs | Advertised | M18 | Supported Excel-template contract and rendered output |
| H03 | Average costing and invoice/item profit | Advertised | M04 | Approved costing examples and profit reconciliation |
| H04 | Sales comparisons by business dimensions | Advertised | M19 | Group totals, percentages and source drill-down |
| H05 | Party balances and detailed statements | Advertised | M07/M19 | Opening/movement/closing reconciliation |
| H06 | Current and historical stock valuation | Advertised | M03/M04/M19 | As-of cutoff and backdating fixtures |
| H07 | Detailed product movement and cost history | Advertised | M03/M04 | Ledger reconstruction and source links |
| H08 | Multiple users and granular restrictions | Advertised | M20 | Permission matrix across all output channels |
| H09 | Treasury balance and period movements | Advertised | M12/M19 | Physical cash and statement reconciliation |
| H10 | Reports exported to Excel | Advertised | M18/M19 | Every required report's exported cells/totals and scope |
| H11 | Expense analysis | Advertised | M12/M19 | Category/period drill-down reconciliation |
| H12 | Multiple warehouses and connected branches | Advertised | M01/M06; connectivity contract | Simultaneous branch workflows and outage recovery |
| H13 | Barcode labels, scanning and post-purchase labels | Advertised | M09/M17 | Purchase-to-label physical demonstration |
| H14 | Backup and restore | Advertised | M21 | Clean-machine restore and corrupted-backup rejection |
| H15 | Invoice archive and search including notes | Advertised | M19 | Search/filter, permission and pagination checks |
| H16 | Three customizable selling price lists | Advertised | M02 | Selection, names, overrides and historical snapshots |
| H17 | Touch operation | Advertised | Navigation; M08 | Touch-only sale and print on supported device |
| H18 | Automatic updates | Advertised | M21 | Signed update, migration and interruption recovery |
| H19 | Saudi electronic invoicing claim | Advertised on [public site](https://getsahl.com/) | M22 | Independent Baseet official-requirement validation; no inherited approval |
| H20 | Support and continued feature releases | Advertised | M21/M23 | Help, support/runbook and version-note readiness |

Commercial/package sources: [pricing](https://getsahl.com/prices), [download/trial entry](https://getsahl.com/download).

| ID | Package capability | Evidence | Plan coverage | Required evidence |
|---|---|---|---|---|
| C01 | Trial/download onboarding | Advertised | M23 | Trial-to-first-use and demo/live separation |
| C02 | Device licensing and subscription/purchase options | Advertised | M23 | Entitlement, device replacement and expiration/export behavior if commercial package selected |

## C. Proposed system foundations

These are planned engineering responsibilities, not verified Sahl product claims.

| ID | Foundation | Plan coverage | Required evidence |
|---|---|---|---|
| F01 | Balanced posting and cross-ledger reconciliation | M03/M04/M08–M15; architecture | Numeric fixtures and integration checks |
| F02 | Idempotency, transactions and concurrency control | Architecture; recovery contract | Timeout/duplicate/race/crash fixtures |
| F03 | Secure sessions and business isolation | M20; security gates | Service/export/job isolation tests |
| F04 | Durable jobs, outbox and recovery | Architecture; recovery contract | Restart/replay and terminal-error visibility |
| F05 | Validated imports and migration cutover | Import plan | Row accounting, control totals and cutover rehearsal |
| F06 | Reproducible builds and schema compatibility | M21; roadmap; quality gates | Clean install, old-client and interrupted-upgrade evidence |
| F07 | Shared design system and localization | Navigation; P1 | Shared-component review and Arabic/English flows |
| F08 | Automated architecture/security/regression checks | Quality gates; verification | Required CI commands selected and passing after implementation |
| F09 | Retention, protected backup and private diagnostics | M20/M21; security gates | Restore/access/retention and diagnostic-redaction checks |
| F10 | Measured capacity and performance | Quality gates | Agreed data/user profile and measured budget results |

## D. Implementation tracking contract

The tables currently describe coverage, not completed implementation. All implementation and acceptance evidence is pending because this task is planning-only.

At implementation time, track each row with: owner, observed product version, detailed specification link, open questions, dependency decisions, milestone, implementation status, test/build evidence, manual evidence, and accepted-gap decision if any.

Allowed lifecycle: identified → behavior specified → designed → implemented → verified → accepted. A topic-verified row is not behavior specified. L27 and L33 must acquire child rows for every newly observed feature before they can be accepted. New capabilities discovered in walkthroughs extend this register; they are not implicitly covered by a broad module name.

Parity reporting must distinguish public-topic coverage, observed workflow parity, and released/verified capabilities. Do not calculate a misleading completion percentage from only the number of headings implemented.

## E. Baseet complete-system additions

These requirements arise from the user's Baseet product request and the cycle audit. They are not attributed to Sahl. All remain planned, not implemented.

| ID | Baseet requirement | Plan coverage | Required evidence |
|---|---|---|---|
| B01 | Complete business opening and ownership | C01; M01/M24 | Reconciled openings, provisioning recovery and scoped access |
| B02 | Complete purchase-to-pay and sales fulfillment | C02/C03/C05; M28 | Partial receipt/delivery, invoice matching and residual quantities |
| B03 | Ledger, financial statements and period close | C10; M27 | Balanced trial balance, subsidiary reconciliation and period locking |
| B04 | Mobile, PC and browser access to the same business | C11; M26; platform matrix | Cross-client scenario against one authority |
| B05 | Local shop and remote deployments | M26; modes D01–D04 | LAN without public internet; remote identity/TLS; controlled mode migration |
| B06 | Required phone-only offline plus safe join to shared mode; separate multi-writer decision | Modes D05/D06 | User confirmed standalone phone and LAN access; shared-engine/adapter, ownership-transfer and recovery evidence required; concurrent disconnected multi-writer scope decided separately |
| B07 | Owner/staff/tenant administration | M20/M24 | Tenant isolation, owner recovery and audited support access |
| B08 | Manually managed subscription, renewal and expiry | C13; M25 | Audited admin changes, remote enforcement, signed offline lease, grace and export |
| B09 | Signed licensing and device lifecycle | M25; licensing contract | Forged/expired/replayed lease, device replacement and bounded offline revocation |
| B10 | Preserve Baseet Clean Architecture and design system | Repository review; P1/P2 | Existing rules retained; expanded boundary and platform checks |
| B11 | Safe fresh start without losing history/data | Repository fresh-start manifest | Pinned baseline, backup/import path, explicit reviewed removal list and no history rewrite |
| B12 | Complete-cycle release acceptance | C01–C14; P11 | Normal/partial/reversal/failure/recovery evidence for every applicable mode |
