# Baseet: simple local shop release

## The minimum data

The owner only needs to enter:

| Task | Required | Optional |
| --- | --- | --- |
| Add a product | Name, selling price, quantity | Barcode, purchase cost, low-stock reminder |
| Add a customer | Name | Phone, previous debt, maximum debt, address, notes |
| Cash/card sale | Products and quantities | Notes and receipt image |
| Credit sale | Products and customer | Partial payment, notes, receipt image |
| Receive a debt payment | Customer and amount | Notes and receipt image |
| Name the shop | Shop name | No profile or account required |

IDs, dates, balances, categories, invoice numbers and database versions are managed internally. The first product uses a general category automatically. Zero-cost products are allowed, but reported profit is explicitly estimated when the owner has not entered purchase costs.

No cloud account, subscriptions, remote API, or internet connection is needed for daily work. Current currency is Egyptian pounds; multi-currency is outside this version.

## Main experience

- Home shows today's sales, customer balances, low-stock count, first-use guidance, and shortcuts to the main pages.
- Mobile uses four main navigation buttons; all other destinations are visible on Home. Windows uses a wider side menu.
- Product creation requires only three fields. Products can be edited and their current quantities corrected.
- Sales history shows the latest 200 invoices with line items and original paid/unpaid amounts. Later debt payments are shown in the customer account rather than rewriting the original invoice.
- Reports show actual database totals. They do not contain sample charts or substitute figures.
- Arabic is the default; English and dark appearance remain available.
- Placeholder printer settings, cashier identities, fake backup success and unsaved shop settings have been removed from the active UI.

## Implemented local data protections

- SQLite transactions keep sales, stock decrements and customer debt consistent.
- Invalid amounts, overpayments, stock shortages, missing customers and credit-limit violations are rejected.
- Duplicate invoice inserts cannot decrement stock again.
- Schema version 2 adds persisted shop settings without deleting version 1 records.
- Windows uses the FFI SQLite backend and application-support storage outside the installation folder.
- Existing mobile databases are copied from their previous location on first startup; the previous copy remains available.
- Receipt images selected for attachment are copied into persistent application storage.
- Backup imports validate format, size, identifiers, references and database columns before committing a replacement.
- Imported attachment paths are created locally; paths from the other device are not trusted as local filesystem locations.
- A `before-transfer.baseet` recovery copy is kept in application-support storage before replacing data. It can be opened through the backup screen after navigating to that folder.
- Backups contain private business records and are not encrypted as files. Device transfers are encrypted separately.

## QR transfer: what “sync” means in this release

1. Connect both devices to the same local network.
2. Open **Backup & device transfer** on both devices.
3. On the device with the correct records, choose **Send this device's records**.
4. The receiver scans the QR or pastes the connection code. Windows supports pasted codes and USB scanners instead of camera scanning.
5. The receiver previews product, customer and invoice counts, then explicitly confirms replacing its records.

The connection lasts five minutes and closes when sharing is stopped, the page is closed, or the mobile app is backgrounded. The QR contains a random encryption key; data is encrypted with AES-GCM, and the key is not sent in the HTTP request. Requests require a derived session credential. No internet service receives the records.

This is a complete snapshot transfer, **not background two-way merging**. Records changed only on the receiving device are replaced. Use one device as the authoritative copy before transferring. Merge rules, conflict resolution, incremental changes and concurrent offline editing remain future work. Large archives above 32 MB are rejected in this small-shop version.

## Desktop and APK testing

- **Windows test installer** runs on Windows GitHub runners, checks and tests the app, builds the release bundle, copies the C++ runtime, creates an Inno Setup EXE, then installs and launches it for a startup smoke test.
- It uploads **Baseet-Windows-Installer** and **Baseet-Windows-Portable** artifacts. The portable artifact must be extracted in full; the executable needs its bundled data and DLLs.
- The installer uses per-user installation and keeps application data outside its installation directory.
- **Android test APK** provides a manual/tag-triggered APK artifact. The existing app release configuration uses the debug signing key, so this is a test package, not a store-signing setup.
- The repository's fetched `main` contained only the checks workflow, so an explicit Android test workflow was added alongside it.
- The Windows installer is unsigned. Public distribution still needs a deliberate signing/release process.
- Local EXE compilation has not been verified: this workstation lacks Visual Studio's Desktop development with C++ workload. A GitHub Windows build and real-device installation are still required.

## What remains incomplete

| Priority | Gap | Why it matters |
| --- | --- | --- |
| Before broad production use | Full Android and Windows user acceptance tests | Verify camera, file dialogs, local-network access/firewall, installation, upgrades and restart persistence on real devices. |
| Before shops needing returns | Sale cancellation, returns and refunds | A safe reversal must handle stock, cash refunds and debt/payment history together. Existing invoices cannot currently be reversed. |
| Before shops needing printed receipts | Receipt/PDF output and printer integration | Invoice viewing/copying works; thermal printing and printable documents are not implemented. |
| Before multiple people edit stock | Stock movement/audit history | Quantity correction works; purchases, adjustment reasons, operator attribution and movement history are not implemented. |
| Before simultaneous device editing | Conflict-aware two-way sync | Snapshot transfer intentionally does not reconcile independent changes. |
| Before calling profit “net profit” | Expenses, purchase tracking and accounting | Current report is selling price minus recorded purchase cost; it excludes expenses, taxes and returns. |
| Before ageing/overdue reminders | Due dates and ageing policy | Unsupported overdue filters were removed from the main list rather than presenting invented classifications. |
| Before adding staff | Authentication, permissions and audit identities | This is a single-user local shop app. Device/OS access currently controls access to records. |
| Later | Customer editing/archiving, product archiving, full invoice search/pagination, currencies | These are useful additions, but should not increase the required daily entry work. |

The implemented core is selling products, controlling current stock, recording customer debt and payments, viewing invoices and totals, and moving/backing up local records. It is not a complete accounting or multi-user retail suite.
