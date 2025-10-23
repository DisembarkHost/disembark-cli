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

```
disembark backup <site-url>
```

```
disembark connect <site-url> <token>
```

```
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