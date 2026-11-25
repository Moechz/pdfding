# Privacy Policy — Pdfding for TerraMaster TOS (`pdfdingdocker`)

**Package version:** 1.15.0-1 (upstream PdfDing 1.15.0)
**Last updated:** 25 November 2026
**Data controller / contact:** Moechz — moechz@163.com
**Public copy of this policy:** <https://github.com/Moechz/pdfding/blob/main/PRIVACY.md>

This policy covers the TOS application `pdfdingdocker` (the “app”) and the packaging
around it. It is part of the App Center submission and is also linked from the App
Center **Help** button (`config.ini` → `help`). The app is self-hosted: it runs on
**your** NAS and the developer neither receives nor has access to your data.

## 1. Summary

- All PDFs, metadata, annotations, accounts and settings stay on your NAS. There is
  **no developer-operated server, no telemetry, no analytics, no advertising and no
  update check**.
- The app does not use OCR, AI, translation or cloud-conversion services. **PDF content
  is never sent to a third party by the app.**
- The only network connections are those **you** configure (optional OIDC login and
  optional SMTP mail) plus the Docker image pull from Docker Hub or your registry
  mirror at install/update time.
- Data is stored in `/Volume1/DockerAppData/pdfdingdocker/` and can be exported or
  deleted at any time, including with the in-app account deletion and the local
  administrator commands described in §5.

## 2. What data is stored

The app stores the data you create in the application data folder. Nothing from this
list is uploaded to the developer.

| Data | Examples | Location |
|---|---|---|
| Account data | e-mail address, password hash, optional TOTP/WebAuthn second factor, recovery codes, language and UI preferences | `/Volume1/DockerAppData/pdfdingdocker/db/db.sqlite3` |
| PDF library | uploaded PDF files and their previews, file names, sizes, page count | `/Volume1/DockerAppData/pdfdingdocker/media/` |
| PDF metadata | title, author, tags, collections, workspaces, starred/archived flags, reading position and reading time, confidence/progress values | database |
| Annotations | highlights, comments, drawings, text edits, signatures and exported annotation data | database / media |
| Sharing | shared PDF or collection records, optional access password hash, expiry time and maximum-view counter | database |
| Operational data | the Django `SECRET_KEY`, the task-queue database, migration state | `/Volume1/DockerAppData/pdfdingdocker/db/` |
| Container logs | startup and migration messages written to stdout/stderr and kept by the Docker log driver | Docker-managed, not a file inside the data folder |

The container’s own `/tmp` is ephemeral and disappears when the container is
recreated. The app does not write logs, caches or uploads anywhere else on the NAS.

## 3. Retention period

- **Library, account and annotation data:** kept until **you** delete it. There is no
  automatic expiry; the only time-based deletion is the expiry date you optionally set
  on a shared link.
- **Shared links:** can have an expiry date and a maximum number of views. Expired links
  stop working, and the link record can be removed in the app.
- **Uninstall:** the TOS uninstaller keeps `/Volume1/DockerAppData/pdfdingdocker/`
  unless you explicitly choose to delete the data. Removing the folder is the complete
  deletion.
- **Logs:** kept by the Docker log driver until the container is removed or the Docker
  log rotation policy you configured discards them. The app keeps no separate log files.
- **Backups:** if you create backups yourself, they are outside the app and outside this
  policy; delete them separately.

## 4. Your rights and the data-rights channels

You can exercise every right locally, without contacting the developer, because the
complete data set is on your NAS. The developer holds no copy.

| Right | Channel |
|---|---|
| **Access / export** | Download PDFs from the app. Export annotations, highlights and PDF metadata from the app’s export functions. For a complete copy, stop the container and copy `/Volume1/DockerAppData/pdfdingdocker/` — it is the whole state. |
| **Correct** | Edit PDF metadata, tags, collections, workspaces, annotations, signatures and account/profile settings in the app’s web UI. An administrator can also edit users in the Django admin. |
| **Delete a PDF or share** | Delete the PDF or shared link in the app. Deleting a PDF removes it from the library and its stored file. |
| **Delete the whole account** | In the app: **Account settings → Danger settings → Delete account**. This deletes the account and its data, and deletes shared workspaces for which the user is the only owner. |
| **Delete everything** | Uninstall the app with “delete data”, or stop the container and remove `/Volume1/DockerAppData/pdfdingdocker/`. |
| **Password reset without e-mail** | This package does not configure SMTP. The “forgot password” form therefore does **not** deliver an e-mail. A local administrator can reset a password from the NAS shell:<br>`docker exec -it pdfdingdocker python manage.py shell -c "from django.contrib.auth.models import User; u=User.objects.get(email='user@example.com'); u.set_password('NEW-PASSWORD'); u.save()"`<br>List the accounts with:<br>`docker exec -it pdfdingdocker python manage.py shell -c "from django.contrib.auth.models import User; print([(u.email, u.username) for u in User.objects.all()])"` |
| **Assistance** | Email **moechz@163.com** with the subject “Pdfding data request”. A reply follows within 30 days. Because the developer has no access to your NAS, assistance is limited to explaining the local channels above and to the publishing records / website. |

These channels are provided for review item **C7** (access, correction and deletion of
user data). No data leaves the NAS to use them.

## 5. Security measures

- The container runs as the unprivileged user **uid 1000**, never as root. The upstream
  image itself declares `USER nonroot`; the compose file also pins `user: "1000:1000"`.
- No `privileged`, no `network_mode: host`, no `cap_add`, no Docker socket and only one
  published port.
- The data directories are restricted to **0700** and the database files to **0600** at
  every start (review item **S11**); the generated `SECRET_KEY` is `0600`.
- The image is pinned to a fixed version tag (`mrmn/pdfding:v1.15.0`); the
  multi-architecture index digest is recorded in `NOTICE.md`. The package is rebuilt
  when upstream ships security fixes.
- Passwords are stored as Django password hashes. Optional TOTP/WebAuthn two-factor
  authentication is available.
- TOS opens the app over **plain HTTP** on the LAN. The session and CSRF cookies are
  therefore not marked `Secure` so that login works (review item **F5**); without that,
  browsers refuse to send the cookie over HTTP and login loops. If you publish the app
  outside your LAN, put it behind a TLS reverse proxy and set `CSRF_COOKIE_SECURE` and
  `SESSION_COOKIE_SECURE` to `TRUE`.
- The app has no telemetry and no remote logging. PDF content is processed only on the
  NAS.

## 6. Third-party services and data flows (API disclosure)

The developer operates no server in this path and sells or shares no data. The table
lists every endpoint the app can contact, what is sent and where it goes.

| Service / endpoint | When it is used | Data sent | Destination / region |
|---|---|---|---|
| `registry-1.docker.io`, `auth.docker.io` (Docker Hub) or the registry mirror configured in DockerEngine | Install and image update only | Anonymous image-layer request. No PDFs, accounts or metadata. | Docker Hub, US, or the mirror you configured |
| Your NAS web UI (`http://<NAS-IP>:8056/`) | Every use | PDFs and metadata stay on the NAS. The browser connects directly to your NAS. | Your own NAS / LAN |
| Optional OIDC identity provider | Only if an administrator sets `OIDC_ENABLE=TRUE` and configures a provider | Authorisation request (client ID, redirect URI, state, nonce) and the provider’s `sub`, e-mail and profile claims. No PDF content. | The provider you configure |
| Optional SMTP server | Only if `EMAIL_BACKEND=SMTP` and `SMTP_*` are configured (not the default in this package) | Recipient e-mail address and the confirmation/reset link. No PDF content. | The mail provider you configure |
| Shared PDF / collection links | When you create and share a link | The recipient’s browser opens your NAS URL directly. The developer is not involved. | Your own NAS / the recipient’s browser |
| OCR, AI, translation or cloud-conversion service | **Never** | The app contains no OCR or AI feature and makes no such request. | — |
| Analytics, advertising, CDN, update check | **Never** | No analytics SDK, no external font/CDN, no version check. Assets are bundled in the image. | — |

## 7. Children

The app is a self-hosted document utility and is not directed at children.

## 8. Changes

Material changes are published in this file, reflected in the “Last updated” date and,
when relevant, in the app’s changelog and release notes.

## 9. Contact

Moechz — **moechz@163.com**

Public policy URL:
<https://github.com/Moechz/pdfding/blob/main/PRIVACY.md>
