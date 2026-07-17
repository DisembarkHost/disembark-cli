# Disembark CLI

Generate and download Disembark backups from the command line.

## Installing

Download latest version of `disembark.phar` using `wget` or from [Disembark CLI](https://github.com/DisembarkHost/disembark-cli/releases) release.

```
wget https://github.com/DisembarkHost/disembark-cli/releases/latest/download/disembark.phar
```

Then copy to user local bin for global availability of `disembark`.

```
chmod +x disembark.phar
sudo mv disembark.phar /usr/local/bin/disembark
```

## Usage

Connect a site with its per-site token (from Tools → Disembark), or with a WordPress application password in `user:application password` form:

```
disembark connect <site-url> <token>
disembark connect <site-url> "admin:xxxx xxxx xxxx xxxx xxxx xxxx"
```

Back up a connected site (writes a `snapshot-<timestamp>-<domain>.zip` in the current directory):

```
disembark backup <site-url>
```

Restore a backup snapshot into a connected site. This overwrites the destination — a rollback point is saved first, and its id is printed before anything destructive runs:

```
disembark restore <site-url> <folder>
disembark restore <site-url> --rollback=<id>
```

The restore reads the origin URL and table prefix from the snapshot's `disembark-source.json` (recorded by `disembark backup`), rewrites URLs to the destination (serialize-aware), and remaps the table prefix when the destination's differs — migrated users keep their roles. Use `--source-url=` / `--source-prefix=` to override, `--skip-db` / `--skip-files` to restore only part, and `--yes` to skip the confirmation prompt.

Other commands:

```
disembark sync <site-url> [<folder>]   # create/update a local mirror
disembark info <site-url>              # connection status + storage usage
disembark ncdu <site-url>              # browse remote disk usage interactively
disembark version
```

## Installing Disembark via WP-CLI

On the source WordPress website run the following commands:

```
wp plugin install https://github.com/DisembarkHost/disembark/releases/latest/download/disembark.zip --activate
```

```
wp disembark cli-info
```

This will return the connection command which will link the the website to Disembark CLI.

```
disembark connect https://my-site.localhost exYNhNLr5dKymZqJZXomW0ie1tkyEyOjKgTSchhmih
```