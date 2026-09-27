# pacer-archives-scripts

Scripts to work with the Internet Archive items for _The Pacer_ and _The Volette_.

## Setup

The [Flox](https://flox.dev) environment provides Ruby and the Internet Archive CLI (`ia`).

```bash
flox activate
bundle install
ia configure  # Set up your Internet Archive credentials (once per machine)
```

## Adding a new issue

Run everything from the repo root inside `flox activate`. Items are named `ThePacerYYYYMMDD` (or `TheVoletteYYYYMMDD`) from the issue date.

1. **Check the issue isn't already on archive.org:**
   ```bash
   ia metadata --exists ThePacer20240115
   ```

2. **Save the PDF as `~/Downloads/YYYY-MM-DD.pdf`** (e.g. `2024-01-15.pdf`).

3. **Create the upload folder.** This writes `~/Downloads/ThePacer20240115/` with the metadata file and moves the PDF into it. Volume is the academic year counted from fall 1928 (Volume 1), so fall 2024 through spring 2025 is Volume 97.
   ```bash
   ruby create-upload-folder.rb -p pacer -d 2024-01-15 -v 96 -i 1 -c 8
   ```
   If the PDF wasn't in `~/Downloads` yet, copy it into the folder now.

4. **Upload:**
   ```bash
   ruby upload-folder.rb ThePacer20240115
   ```

5. **Wait for IA to process the PDF.** This usually takes several minutes. It's done when `ia tasks ThePacer20240115` shows no running tasks and the item lists a `_scandata.xml` file:
   ```bash
   ia list ThePacer20240115 | grep scandata
   ```

6. **Mark the first page as the title page and sync the page count:**
   ```bash
   ruby fix-front-page.rb ThePacer20240115
   ruby update-page-count.rb ThePacer20240115
   ```

7. **Check the item** at `https://archive.org/details/ThePacer20240115`: the reader opens on the front page and the title, volume and issue are correct.

Once the item is up, the local folder in `~/Downloads` can be deleted.

## Scripts

### create-upload-folder.rb

Creates a local folder with Internet Archive metadata files ready for upload.

**Usage:**
```bash
ruby create-upload-folder.rb --publication pacer --date 2024-01-15 --volume 96 --issue 1 --pages 8
ruby create-upload-folder.rb --publication volette --date 1950-10-05 --volume 23 --issue 4 --pages 4
```

**Options:**
- `-p, --publication` - Publication name (`pacer` or `volette`) **[required]**
- `-d, --date` - Issue date in YYYY-MM-DD format **[required]**
- `-v, --volume` - Volume number **[required]**
- `-i, --issue` - Issue number **[required]**
- `-c, --pages` - Page count **[required]**

**Output:**
Creates a folder in `~/Downloads` with:
- `{identifier}_meta.xml` - Metadata file

### upload-folder.rb

Uploads the PDF in `~/Downloads/{identifier}/` to Internet Archive, applying the fields from `{identifier}_meta.xml` as item metadata. IA rejects uploaded `_meta.xml` files, so don't upload the folder directly.

**Usage:**
```bash
ruby upload-folder.rb ThePacer20240115
ruby upload-folder.rb ThePacer20240115 -d  # extra args are passed to `ia upload`
```

**Requirements:**
- Internet Archive CLI tool must be installed and configured
- Folder must contain exactly one PDF

### create-upload-link.rb

Opens a browser with a pre-filled Internet Archive upload URL.

**Usage:**
```bash
ruby create-upload-link.rb --publication pacer --date 2024-01-15 --volume 96 --issue 1
ruby create-upload-link.rb --publication volette --date 1950-10-05 -v 23 -i 4
```

**Options:**
- `-p, --publication` - Publication name (`pacer` or `volette`) **[required]**
- `-d, --date` - Issue date in YYYY-MM-DD format **[required]**
- `-v, --volume` - Volume number (default: 00)
- `-i, --issue` - Issue number (default: 00)

### update-page-count.rb

Updates the page count metadata for an existing IA item by reading the scandata.xml.

**Usage:**
```bash
ruby update-page-count.rb ThePacer20240115
ruby update-page-count.rb TheVolette19501005
```

**Requirements:**
- Internet Archive CLI tool must be installed and configured
- Item must already exist on archive.org

### fix-front-page.rb

Fixes page type metadata so the first page displays correctly as a Title page.

**Usage:**
```bash
ruby fix-front-page.rb ThePacer20240115
ruby fix-front-page.rb TheVolette19501005
```

**Requirements:**
- Internet Archive CLI tool must be installed and configured
- Item must already exist on archive.org and have been scanned
