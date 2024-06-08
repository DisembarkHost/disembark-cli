# Disembark CLI

Generate and download Disembark backups from the command line.

## Installing

Download latest version of `disembark.phar` using `wget` or from [Disembark CLI](https://github.com/DisembarkHost/disembark-cli/releases) release.
```
wget https://github.com/DisembarkHost/disembark-cli/raw/main/disembark.phar
```
Then copy to user local bin for global availability of `disembark`.

```
chmod +x disembark.phar
sudo mv disembark.phar /usr/local/bin/disembark
```

## Usage

disembark backup `<site-url>`

disembark connect `<site-url>` `<token>`

disembark version