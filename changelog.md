# Changelog

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