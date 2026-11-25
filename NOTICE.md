# NOTICE — third-party components and attributions

This package (`pdfdingdocker`, TOS 7 Docker application, version 1.15.0-1) is an
independent packaging by Moechz of the upstream **PdfDing** project.

## 1. Upstream application — PdfDing

- Project: <https://codeberg.org/mrmn/PdfDing> (the project moved from GitHub to Codeberg)
- Licence: **GNU Affero General Public License v3.0 only (AGPL-3.0-only)**, see the
  upstream `LICENSE`
- Version packaged: **1.15.0**
- Relationship: the upstream application is used **unmodified**, inside the container
  image published by its maintainer. No upstream source code is redistributed in this
  package.

## 2. Container image — `mrmn/pdfding:v1.15.0`

- Registry: Docker Hub, <https://hub.docker.com/r/mrmn/pdfding>
- Tag: `v1.15.0`
- Multi-architecture index digest:
  `sha256:698654cb78e9b0f461cf5d63ed39a8a98306fd9ff30fd1578bdef7bb6056f913`
  (linux/amd64 and linux/arm64)
- The image is pulled from Docker Hub (or the mirror configured in DockerEngine) at
  install time and is **not redistributed** in this package.

## 3. Components inside the image

The upstream image is built by its maintainer on top of Alpine Linux and bundles the
application and its Python/JS dependencies. Their licences are documented in the
image's own package metadata (`/home/nonroot/.venv`, npm notices and the bundled
`pdf.js` licence). They are shipped inside the image only and are not redistributed as
separate files by this package.

`pdf.js` is bundled by upstream under the Apache License 2.0; its licence text and
source references are kept in the image.

## 4. This packaging

The files authored for this package — `docker-compose.yml`, `config.ini`,
`pdfdingdocker.lang`, `pdfdingdocker.svg`, `src/entrypoint.sh`, the build scripts,
`tools/verify.py`, `test/install-and-verify.sh` and this documentation — are released
under the **MIT licence** (see `LICENSE`). They contain no upstream source code.

## 5. Trademarks

“PdfDing”, “TerraMaster” and “TOS” are trademarks or registered trademarks of their
respective owners. Their use here is descriptive only. This package is **not affiliated
with, sponsored or endorsed by** the upstream project or TerraMaster.

## 6. Icon

The application icon in `src/pdfdingdocker.svg` is an original mark drawn for this
package. It does not reproduce the upstream logo or any third-party logo.

## 7. Contact

Moechz — moechz@163.com — <https://github.com/Moechz/pdfding>
