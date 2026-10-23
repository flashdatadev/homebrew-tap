# FlashData Homebrew tap

[简体中文](README.zh-CN.md) · [FlashData](https://flashdata.dev) · [API docs](https://flashdata.dev/docs) · [CLI repository](https://github.com/flashdatadev/flashdata-cli)

The official Homebrew tap for [FlashData CLI](https://github.com/flashdatadev/flashdata-cli): structured Google Search and YouTube data, secure API-key profiles, background jobs, bulk exports and run recovery from your terminal.

## Install

Install [Homebrew](https://brew.sh) first and follow its PATH instructions. Then run:

```bash
brew install flashdatadev/tap/flashdata
flashdata --version
flashdata --help
```

The formula selects the official **v1.1.1** executable for Linux amd64/arm64 or macOS Intel/Apple Silicon and verifies its SHA-256 checksum. No Go, Python or Node.js installation is required. This is FlashData's own tap; it is maintained at `flashdatadev/homebrew-tap`.

Import a key from your [FlashData account](https://flashdata.dev) using hidden terminal input:

```bash
flashdata auth login
```

See the [English CLI README](https://github.com/flashdatadev/flashdata-cli#readme) or [简体中文](https://github.com/flashdatadev/flashdata-cli/blob/main/README.zh-CN.md) for onboarding, query and bulk examples. Submitted queries and jobs use normal FlashData billing. Installation and the version/help checks need no API key.

## Upgrade and uninstall

```bash
brew update
brew upgrade flashdatadev/tap/flashdata
```

```bash
brew uninstall flashdata
brew untap flashdatadev/tap
```

Uninstalling removes the Homebrew package. It does not revoke API keys or delete your CLI profiles and run history. To remove a saved credential, run `flashdata auth logout` for that profile before uninstalling. See [credential storage](https://github.com/flashdatadev/flashdata-cli/blob/main/docs/security.md) for state locations.

If you installed an archive manually before, use `command -v flashdata` to check which executable your shell finds. A copy in `~/.local/bin` may precede Homebrew; remove or move that old executable, or adjust PATH. Restart the shell or run `hash -r` after changing it. Do not delete the CLI's state directory when switching installation methods.

## Packaged examples and docs

```bash
ls "$(brew --prefix flashdata)/share/flashdata/examples"
ls "$(brew --prefix flashdata)/share/doc/flashdata"
```

Examples, English/Chinese release documentation and third-party license notices are included. The packaged docs are the v1.1.1 release snapshot; the CLI repository contains current installation instructions. Windows users can use the [standalone release ZIP](https://github.com/flashdatadev/flashdata-cli/releases/tag/v1.1.1).

## Maintainers

For each new stable CLI release:

1. Publish the tested Linux/macOS amd64/arm64 archives and `SHA256SUMS` in the CLI repository.
2. Update all four versioned URLs and their SHA-256 values in `Formula/flashdata.rb`; Homebrew infers the version from the URL. Preserve the published archives and old tags.
3. Run `python3 scripts/verify_release.py`, then `brew style`, `brew audit --strict --online`, installation and `brew test` for `flashdatadev/tap/flashdata`.
4. Check [GitHub Actions](https://github.com/flashdatadev/homebrew-tap/actions) before announcing the upgrade. CI checks fresh install, reinstall/uninstall, the actual v1.0.0 → v1.1.1 upgrade and packaged docs/examples on all four native platforms. Formula tests run offline and submit no API work.

Report packaging problems in [tap issues](https://github.com/flashdatadev/homebrew-tap/issues); report CLI bugs in [CLI issues](https://github.com/flashdatadev/flashdata-cli/issues). Account support: [support@flashdata.dev](mailto:support@flashdata.dev).
