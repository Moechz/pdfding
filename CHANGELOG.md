# Changelog

All notable user-visible changes to the Pdfding TOS application package.

## 1.15.0-1 — 2026-11-25

Review remediation for [Pdfding] 1.7.2-3 (x86_64) with blocking items F5 and S11,
plus C3 and C7, and an upstream upgrade (T1).

### Changed
- **T1:** upgraded the image from `mrmn/pdfding:v1.7.2` to `mrmn/pdfding:v1.15.0`
  (multi-arch index pinned by digest). The `db` and `media` volume paths are
  unchanged; migrations run automatically on start.
- Entrypoint now calls upstream `./entrypoint.sh` (1.15.0) instead of
  `./bootstrap.sh` (1.7.2).

### Fixed
- **F5:** the HTTP login loop. Upstream defaults `SESSION_COOKIE_SECURE` to TRUE when
  the variable is absent, so the session cookie was issued with the `Secure` flag over
  plain HTTP and never sent back. Both `SESSION_COOKIE_SECURE` and
  `CSRF_COOKIE_SECURE` are now explicitly `FALSE` for the LAN HTTP deployment, and
  `ACCOUNT_DEFAULT_HTTP_PROTOCOL` is `http`.
- **S11:** data directory and database permissions. The wrapper sets `umask 077` and,
  on every start, forces the `db`/`media` directories to `0700` and the database files
  to `0600` (also repairs installs upgraded from 1.7.2-3). The container already runs
  as uid 1000.

### Documentation
- **C3:** added the privacy policy link to the App Center Help field
  (`https://github.com/Moechz/pdfding/blob/main/PRIVACY.md`) and rewrote
  `PRIVACY.md` for the features and data flows actually delivered.
- **C7:** documented the access, export, correction and deletion channels, including
  account self-deletion and the local administrator password-reset command used
  because no SMTP backend is configured.
- **C8:** replaced the generic third-party table with the real endpoints (Docker Hub
  image pull, optional OIDC, optional SMTP, direct shared links). Confirmed that the
  app has no OCR, AI, analytics, CDN or update-check traffic.
- **C9:** rewrote the `zh-cn` and `zh-hk` descriptions to match the delivered
  features, removed ASCII semicolons from every `.lang` value, and removed the stale
  `probe` block from `tosapp.json`.
- `NOTICE.md` now records the real AGPL-3.0-only upstream licence, the image digest
  and the MIT licence of this packaging.

## 1.7.2-2 — 2026-11-12

### Changed
- Icon: replaced the letter monogram with a functional vector mark that describes what the app does (the upstream project does not publish a compliant SVG).

## 1.7.2-1 — 2026-11-11

### Added
- First release. Pdfding (`mrmn/pdfding:v1.7.2`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8056 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/pdfdingdocker/`.
