# pacer-archives-scripts

Scripts to work with the Internet Archive items for _The Pacer_ and _The Volette_.

## Prerequisites

- Ruby with bundler
- Internet Archive CLI tool (`ia`)
- IA credentials configured

## Setup

```bash
bundle install
ia configure  # Set up your Internet Archive credentials
```

## Scripts

### create-upload-folder.rb

Creates a local folder with Internet Archive metadata files ready for upload.

**Usage:**
```bash
ruby create-upload-folder.rb --publication pacer --date 2024-01-15 --volume 95 --issue 1 --pages 8
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
- `{identifier}_files.xml` - File manifest

### create-upload-link.rb

Opens a browser with a pre-filled Internet Archive upload URL.

**Usage:**
```bash
ruby create-upload-link.rb --publication pacer --date 2024-01-15 --volume 95 --issue 1
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

## Workflow

Typical workflow for uploading a new issue:

1. **Create upload folder:**
   ```bash
   ruby create-upload-folder.rb -p pacer -d 2024-01-15 -v 95 -i 1 -c 8
   ```

2. **Add PDF to the folder** (in `~/Downloads/{identifier}/`)

3. **Upload to Internet Archive using the `ia` CLI**

4. **After scanning completes, fix the front page:**
   ```bash
   ruby fix-front-page.rb ThePacer20240115
   ```

5. **Update page count if needed:**
   ```bash
   ruby update-page-count.rb ThePacer20240115
   ```
