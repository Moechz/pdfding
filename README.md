# pdfding-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [PdfDing](https://codeberg.org/mrmn/PdfDing), a self-hosted PDF manager,
> viewer and editor.

## What this is

A four-file TOS Docker application archive (`pdfdingdocker.tar.gz`) that installs
PdfDing on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `pdfdingdocker`)
- `pdfdingdocker.lang` — 23-language superset (TOS requires 14)
- `pdfdingdocker.svg` — application icon
- `docker-compose.yml` — one service, image `mrmn/pdfding:v1.15.0`

Package version **1.15.0-1** packages upstream **PdfDing 1.15.0**.

## Features delivered

- PDF library with workspaces, collections, nested tags, starring and archiving
- Browser PDF viewer that remembers the reading position, plus reading progress
- Annotations: highlights, comments, drawings, text edits and saved signatures
- Export of annotations, highlights and PDF metadata
- Search by file name and advanced filtering on metadata (title, author, abstract,
  DOI, keywords, journal, publisher, year, description)
- Sharing of PDFs and collections by link or QR code, with optional password,
  expiry date and view limit
- Optional OIDC single sign-on and optional TOTP/WebAuthn two-factor authentication
- Multi-user accounts with per-user workspaces
- English user interface

The app does **not** include OCR, full-text search of PDF contents, AI features or
cloud conversion. It does not send PDF content to any third party. If you need OCR,
run it separately before uploading the PDF.

## How it works

| | |
|---|---|
| Container image | `mrmn/pdfding:v1.15.0` (multi-arch, Docker Hub, used unmodified; index digest `sha256:698654cb78e9b0f461cf5d63ed39a8a98306fd9ff30fd1578bdef7bb6056f913`) |
| Open | `http://<NAS-IP>:8056/` (container port 8000) |
| Runs as | non-root, `user: "1000:1000"` (the upstream image also declares `USER nonroot`) |
| Persistent data | `/home/nonroot/pdfding/db` → `/Volume1/DockerAppData/pdfdingdocker/db`, `/home/nonroot/pdfding/media` → `/Volume1/DockerAppData/pdfdingdocker/media` |
| Logs | `docker logs pdfdingdocker` (stdout/stderr) |
| Data permissions | data directories `0700`, database files `0600`, secret key `0600` |

The entrypoint wrapper (`src/entrypoint.sh`) generates a persistent Django
`SECRET_KEY` in the data volume, tightens the two data directories and then hands
over to the upstream `entrypoint.sh`, which runs the database migrations and starts
gunicorn.

## Repository layout

```
src/config.ini              TOS application metadata
src/pdfdingdocker.lang      store descriptions, 23 languages
src/pdfdingdocker.svg      application icon
src/docker-compose.yml     service definition (entrypoint embedded at build time)
src/entrypoint.sh          TOS wrapper (SECRET_KEY + data permissions)
scripts/build.sh           single-architecture package builder
scripts/build-dual.sh      builds both architectures and runs the official check
tools/verify.py            review-standards self-check used by the build
test/install-and-verify.sh on-device end-to-end test (requires root; not run here)
TOSAppSelfTestingTool      official TerraMaster package checker
PRIVACY.md                 privacy policy (linked from the App Center Help button)
NOTICE.md                  licences, image digest and trademark notice
CHANGELOG.md               user-visible changes per package version
```

## Privacy

This application runs entirely on your NAS. **The developer does not collect, receive
or have access to any data processed by the application.** There is no telemetry, no
analytics, no advertising and no update check.

| Topic | Detail |
|---|---|
| Data processed | Accounts (e-mail, password hash, optional 2FA), PDFs, PDF metadata, tags, collections, workspaces, annotations, signatures, reading progress, shared links, the Django secret key and the task queue. |
| Where it is stored | `/Volume1/DockerAppData/pdfdingdocker/` on your NAS. Nothing is uploaded to the developer. |
| Retention period | Until **you** delete it. Shared links can expire by date or view count. Uninstalling keeps the data unless you tick “delete data”. |
| Access / export | Download PDFs, export annotations/highlights/metadata in the app, or copy the whole data folder after stopping the container. |
| Correct | Edit metadata, tags, collections, annotations and profile settings in the web UI. |
| Delete | Delete PDFs and shares in the UI. Delete the account in **Account settings → Danger settings → Delete account**. For complete removal, uninstall with “delete data” or remove `/Volume1/DockerAppData/pdfdingdocker/`. |
| Password reset | SMTP is not configured in this package, so “forgot password” does not send e-mail. Reset locally with `docker exec -it pdfdingdocker python manage.py shell -c "from django.contrib.auth.models import User; u=User.objects.get(email='user@example.com'); u.set_password('NEW-PASSWORD'); u.save()"`. |
| Deletion / assistance channel | Local channels above, or e-mail **moechz@163.com** (answered within 30 days). |
| Security measures | Non-root uid 1000, no privileged mode, no host network, no `cap_add`, no Docker socket, one published port; data `0700`/`0600`; image pinned to a fixed version tag; optional 2FA. |
| Children | Not directed at children. |

Full policy: [PRIVACY.md](PRIVACY.md) — also at
<https://github.com/Moechz/pdfding/blob/main/PRIVACY.md> and linked from the App
Center Help button.

## Third-party services (API disclosure)

The developer operates no server in this path. The app contacts only the endpoints
below; PDF content never leaves the NAS.

| Service | Endpoint | Data sent | Destination / region |
|---|---|---|---|
| Image pull | `registry-1.docker.io` / `auth.docker.io` or your DockerEngine mirror | anonymous image layers, no personal data | Docker Hub, US / your mirror |
| Web UI | `http://<NAS-IP>:8056/` | all app data stays local | your NAS / LAN |
| Optional OIDC login | the provider you configure | authorisation request and the provider’s `sub`/e-mail/profile claims, no PDF content | the provider you configure |
| Optional SMTP | the mail server you configure | recipient address and confirmation/reset link, no PDF content | the mail provider you configure |
| Shared links | your NAS URL | the recipient opens your NAS directly | your NAS |
| OCR / AI / analytics / CDN / update check | none | — | — |

OIDC and SMTP are off by default in this package. See `PRIVACY.md` §6 for the full
table and for the exact conditions.

## Install, upgrade and uninstall

- **Install** from the App Center, or unpack `out/pdfdingdocker.tar.gz` for testing.
  Open `http://<NAS-IP>:8056/` and create the first account.
- **Upgrade from 1.7.2-3 to 1.15.0-1:** back up
  `/Volume1/DockerAppData/pdfdingdocker/` first. The upstream entrypoint runs the
  database migrations automatically on start; the `db` and `media` volume paths are
  unchanged, so the existing library is kept. The image moved from
  `mrmn/pdfding:v1.7.2` to `mrmn/pdfding:v1.15.0`.
- **Uninstall:** remove the app in the App Center. The data directory is kept unless
  you choose “delete data”; to delete everything, stop the container and remove
  `/Volume1/DockerAppData/pdfdingdocker/`.
- **LAN only:** the UI is plain HTTP. Put it behind a TLS reverse proxy before
  exposing it to the internet.

## Build

```bash
scripts/build.sh 1.15.0-1 x86_64           # -> out/pdfdingdocker.tar.gz + .sha256
scripts/build-dual.sh 1.15.0-1             # both arches + official -c check
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes
CRLF/BOM/AppleDouble, then runs `tools/verify.py`, a review-standards self-check
(archive layout, JSON validity, required fields, 14+ language coverage, version
consistency, Docker-Hub-only image, fixed tag, reserved/recommended host ports,
non-root user, per-service healthcheck/TZ/restart, data path below the application
data root, never the `/Volume*` wildcard, comment-free sequence blocks, `x-app-meta`
position, no literal secrets, no ASCII semicolons in `.lang` values and the SVG
size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/pdfdingdocker_x86_64.tar.gz
./TOSAppSelfTestingTool -c out/pdfdingdocker_aarch64.tar.gz
bash test/install-and-verify.sh            # on-device E2E, needs root
```

> Docker applications cannot be side-loaded through the App Center's manual install
> page (it accepts `.deb` only); the official self-testing tool's `-i` mode or
> `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release tag `v1.15.0-1` with assets `pdfdingdocker_x86_64.tar.gz`,
   `pdfdingdocker_aarch64.tar.gz` and their `.sha256` files.
3. Developer platform → app `pdfdingdocker`, version `1.15.0-1`, both architectures.
4. After submission, verify the platform `file_hash` equals the local SHA-256.

## Limitations

- No OCR, full-text search or AI features (upstream does not provide them).
- No SMTP configured by default, so in-app password-reset e-mail is not delivered;
  use the local administrator command above.
- Plain HTTP on the LAN, by design (the App Center opens the app over HTTP).
- Multi-user workspaces do not provide real-time collaboration; simultaneous edits of
  the same PDF overwrite each other.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.

## Support

- Issues and questions: <https://github.com/Moechz/pdfding/issues>
- Email: moechz@163.com
- Privacy: [PRIVACY.md](PRIVACY.md) · Licence and notices: [NOTICE.md](NOTICE.md)
