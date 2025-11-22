# Changelog

## **v2.5.0** - November 21st, 2025

### Added

* **Sync Exclusions:** The `sync` command now supports the `-x` argument, allowing you to exclude specific files or directories from being synchronized (e.g., `disembark sync <url> -x wp-content/cache`).
* **Sync Checksum Skipping:** Added a `--skip-checksums` flag to the `sync` command. When used, the CLI compares files based on size only, skipping the MD5 checksum calculation to improve performance on large sites.
* **Stateless Backups:** The `backup` command now accepts a `--token=<token>` argument. This allows you to run a backup without establishing a persistent connection (`disembark connect`) or having a local configuration file.

### Improved

* **Parallel Sync Processing:** The "subsequent sync" process now downloads remote manifest chunks in parallel batches. This significantly reduces the time required to analyze differences on sites with large file counts.
* **Timeout Handling:** Increased the timeout limit for the `zip-sync-files` endpoint to 30 minutes to prevent timeouts when processing batches of many small files.
* **Sync Exclusion Logic:** Local filtering has been implemented for "initial syncs," ensuring that files excluded via `-x` are not downloaded even during the first run.

## **v2.4.0** - November 10th, 2025

### Added

* **New `ncdu` Command:** Added a `disembark ncdu <site-url>` command to interactively browse the remote site's file system and disk usage. This command requires the local `ncdu` (NCurses Disk Usage) tool to be installed. It can generate a new file manifest on the fly or reuse an existing session manifest (`--session-id`).
* **Partial Backup & Sync:** Added `--skip-db` and `--skip-files` options to both the `backup` and `sync` commands to allow for file-only or database-only operations.
* **Database Batching Controls:** Added `--db-max-size` and `--db-max-rows` arguments to the `backup` and `sync` commands. These allow for customizing the database batching thresholds for the `processDatabaseBackup` function.
* **Sync Chunking Controls:** Added `--file-chunk-size` and `--file-chunk-max-size` arguments to the `sync` command to provide control over the file chunking logic.
* **Client-side Backup Filtering:** The `backup` command now supports applying local `-x` exclusion flags when reusing a `--session-id`. The CLI downloads the full manifest, filters the file list locally, and then re-chunks and downloads only the required files using the sync-file zip endpoint.

### Improved

* **Initial Sync Reliability:** The "initial sync" process (syncing to a new folder) is now more robust. If a pre-generated file chunk (`.zip`) fails to download or extract, the tool automatically falls back to downloading that chunk's JSON manifest and streaming each file individually.
* **Subsequent Sync Chunking:** The file chunking logic for "subsequent sync" operations has been significantly improved. Instead of chunking only by file count, it now intelligently builds chunks based on both file count (`--file-chunk-size`) and total file size (`--file-chunk-max-size`). It can also correctly handle single files that are larger than the maximum chunk size.
* **Help Text:** Updated the `disembark --help` output to include the new `ncdu` command and all new arguments for the `backup` and `sync` commands.

## **v2.3.0** - October 28th, 2025

### Improved

* **Database Download Strategy:** Reversed the database download logic to attempt a fast, direct download first. If the direct download fails (e.g., due to hosting restrictions), it now automatically falls back to using the PHP streaming API. This logic is consolidated in a new `download_db_file` function and replaces the v2.2.0 "stream-first" approach.
* **Database Backup Efficiency:** Refactored the database backup logic for both the `backup` and `sync` commands into a new, centralized `processDatabaseBackup` function.
* **Hybrid Batching:** The new `processDatabaseBackup` function introduces a "hybrid batching" strategy, which groups numerous small tables into batches to be exported together while processing very large tables individually in parts. This improves reliability for complex databases.
* **Sync Reliability:** The `sync` command's file download step for subsequent syncs is now more robust. It processes new or changed files in chunks (of 2,500 files) and includes a retry mechanism to handle intermittent network or server errors during the download and extraction of a chunk.
* **Help Command:** Reorganized the help output (`disembark` or `disembark --help`) for better readability, grouping `backup` and `sync` as "Primary Commands".

### Changed

* **Removed Backup Confirmation:** Removed the "Do you want to proceed? (yes/no)" prompt from the `backup` command to allow for non-interactive scripting and automation.

## **v2.2.0** - October 26th, 2025

### Added

* **New `sync` Command:** A new `disembark sync <site-url> [<folder>]` command has been added to create and update a local mirror of a remote site.
    * On the first run, it performs an "initial sync" to download all database tables and file chunks.
    * On subsequent runs, it intelligently compares a local manifest with the remote one, downloading only new or changed files and removing deleted ones.
    * The `sync` command supports `--debug` for saving manifest files and `--session-id` to reuse a manifest from the web UI.
* **Session Reuse for `backup`:** The `backup` command now supports a `--session-id=<id>` argument. This allows you to reuse an existing backup session from the plugin's web UI, skipping the analysis step and downloading files from the pre-generated manifest.

### Improved

* **Hosting Download Compatibility:** The method for downloading database (`.sql`) files has been re-architected. This change specifically supports restrictive hosting environments (like Flywheel) that block direct URL access to `.sql` files.
    * The tool now attempts to download database files using a new `download_file_via_stream` function, which calls a `/wp-json/disembark/v1/stream-file` API endpoint to stream the file content via PHP.
    * If this streaming method fails, it automatically falls back to the original direct download method.
* **Removed `curl` Dependency:** The `download_file_direct` function (used for file chunks and as a fallback) was rewritten to use the internal `rmccue/requests` PHP library. This removes the dependency on the `curl` command-line utility, increasing portability and reliability.
* **Code Refactoring:** The file analysis and backup summary logic, which was previously part of the `runPreview` function, was refactored into new, separate functions: `runManifestGeneration` and `displayBackupSummary`. This allows the logic to be reused by the `backup`, `backup --preview`, and new `sync` commands.
* **Build Process:** The `build-phar.php` script was improved to manually add only the required `disembark` script and `vendor` directory, which creates a smaller and cleaner final `.phar` file.

## **v2.1.0** - October 23rd, 2025

### Improved

* **Backup Efficiency:** The backup process has been optimized to run the file analysis and manifest generation only once. The analysis now runs during the initial preview step, and the generated file manifest is reused for the actual backup. This avoids the previous behavior of running the analysis twice (once for preview, once for the backup), significantly speeding up the operation.
* **Preview & Cleanup Logic:** The `runPreview` function was refactored to accept a `backup_token` and return the generated file manifest. The main `backup` function now correctly calls `cleanupTemporaryFiles` if the user exits after a `--preview` or cancels the backup. Previously, `runPreview` generated its own temporary token and cleaned up after itself.

### Changed

* Moved the changelog from the bottom of `readme.md` to its own dedicated `changelog.md` file.

## **v2.0.0** - October 17th, 2025

### Changed

  * **Re-architected Backup Process:** The backup process is now "local-first." The CLI downloads all database tables and file chunks individually and assembles the final `.zip` file on the user's local machine.
  * Removed the dependency on the remote `disembark.host/generate-zip` script for backup finalization.

### Added

  * The `backup` command now creates a local temporary `snapshot-<timestamp>` directory to build the backup locally.
  * Added new local helper functions for zipping (`zip_directory`), unzipping (`unzip_file`), and deleting directories (`delete_directory`) to support the new local backup process.
  * Added a `download_file_direct` function using `curl` for more reliable downloading of backup parts.
  * The backup process now calls a `/cleanup-file` endpoint to delete temporary backup chunks from the server as they are downloaded.

### Improved

  * **File Manifest:** The file manifest generation is now a more robust, multi-step process (initiate, scan, chunkify, process, finalize) to better handle large sites and complex exclusion rules.
  * **Backup Preview:** The `backup --preview` command was rewritten to use the new multi-step manifest generation, providing a much more accurate and reliable preview of the backup content before the backup runs.
  * **Configuration:** The `connect` command is now more resilient and can read legacy `~/.disembark` configuration files that were stored as a single object instead of an array.
  * Updated the `readme.md` installation URL to point to the official GitHub Releases page instead of the `main` branch.

## **v1.1.0** - October 10th 2025

### Added

  * A new **`list` command** has been added to display all connected sites.
  * A new **`upgrade` command** to update Disembark CLI to latest version.
  * The `backup` command now includes an **`--exclude-tables`** option, which allows you to exclude specific database tables from the backup. This feature supports the use of wildcards for more flexible table selection.
  * You can now use the **`-x` argument** with the `backup` command to exclude certain files or directories from the backup. You can use this option multiple times to exclude several paths.
  * A new **`--preview` argument** has been added to the `backup` command to display a list of files and tables that will be included in the backup without actually running the backup process.

### **v1.0.0** - June 8th 2024

### Initial Release

  * Provides a `connect` command to securely save a site URL and token.
  * Credentials are saved to a `.disembark` file in the user's home directory.
  * The tool can add new site credentials or update the token for an existing site.
  * Verifies that the site URL format is valid before attempting to connect.
  * Includes a `backup` command to initiate the backup process for a specified site.
  * Reads the appropriate token for the site from the configuration file.
  * Performs backups by making a series of requests to the Disembark WordPress plugin API.
  * The backup process includes exporting individual database tables, zipping the full database, and processing site files in batches.
  * Finalizes the backup by executing a remote script via `curl` to generate a complete zip archive.
  * The script is designed to be run from the command line.
  * A `version` command is included to display the current version of the tool.
  * A `showHelp` function displays usage instructions for available commands.
  * Provides real-time progress and status messages during the backup process.
  * Includes a utility to convert bytes into a human-readable file size format.