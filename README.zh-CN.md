# FlashData Homebrew 软件源

[English](README.md) · [FlashData 官网](https://flashdata.dev) · [API 文档](https://flashdata.dev/docs) · [CLI 仓库](https://github.com/flashdatadev/flashdata-cli)

[FlashData CLI](https://github.com/flashdatadev/flashdata-cli) 的官方 Homebrew 软件源，可在终端获取结构化 Google 搜索和 YouTube 数据，管理安全的 API 密钥配置、后台任务、批量导出及执行恢复。

## 安装

先安装 [Homebrew](https://brew.sh)，并按其提示配置 PATH，然后执行：

```bash
brew install flashdatadev/tap/flashdata
flashdata --version
flashdata --help
```

配方会自动选择适用于 Linux amd64/arm64 或 macOS Intel/Apple Silicon 的 **v1.0.0** 官方可执行文件，并验证 SHA-256 校验和。无需安装 Go、Python 或 Node.js。此软件源由 FlashData 在 `flashdatadev/homebrew-tap` 中维护。

使用终端隐藏输入，从 [FlashData 账户](https://flashdata.dev)导入密钥：

```bash
flashdata auth login
```

接入、查询及批量任务示例参见 [English CLI README](https://github.com/flashdatadev/flashdata-cli#readme) 或[简体中文](https://github.com/flashdatadev/flashdata-cli/blob/main/README.zh-CN.md)。提交查询和任务按正常 FlashData 规则计费；安装及版本/帮助检查无需 API 密钥。

## 升级与卸载

```bash
brew update
brew upgrade flashdatadev/tap/flashdata
```

```bash
brew uninstall flashdata
brew untap flashdatadev/tap
```

卸载只移除 Homebrew 软件包，不撤销 API 密钥，也不删除 CLI 配置或执行历史。如需移除已保存的凭据，请在卸载前为相应配置运行 `flashdata auth logout`。状态目录见[凭据存储说明](https://github.com/flashdatadev/flashdata-cli/blob/main/docs/security.md)。

如果此前手动安装过归档，请用 `command -v flashdata` 检查终端实际使用的可执行文件。`~/.local/bin` 中的旧版本可能排在 Homebrew 前面；可移走旧可执行文件或调整 PATH。修改后重启终端，或运行 `hash -r`。切换安装方式时不要删除 CLI 状态目录。

## 附带的示例与文档

```bash
ls "$(brew --prefix flashdata)/share/flashdata/examples"
ls "$(brew --prefix flashdata)/share/doc/flashdata"
```

软件包包含示例、中英文版本文档和第三方许可证声明。附带文档为 v1.0.0 发布快照；最新安装说明位于 CLI 仓库。Windows 用户可使用[独立 ZIP 安装包](https://github.com/flashdatadev/flashdata-cli/releases/tag/v1.0.0)。

## 维护说明

每次发布新的 CLI 稳定版本时：

1. 在 CLI 仓库发布经过测试的 Linux/macOS amd64/arm64 归档和 `SHA256SUMS`。
2. 更新 `Formula/flashdata.rb` 中的 `version`、四个平台的固定版本 URL 及 SHA-256。保留已发布归档和旧标签。
3. 运行 `python3 scripts/verify_release.py`，并对 `flashdatadev/tap/flashdata` 运行 `brew style`、`brew audit --strict --online`、安装及 `brew test`。
4. 确认 [GitHub Actions](https://github.com/flashdatadev/homebrew-tap/actions) 通过后再宣布升级。CI 还会检查重新安装、卸载及附带文档/示例；配方测试离线运行，不提交 API 任务。

打包问题请提交到[软件源 issues](https://github.com/flashdatadev/homebrew-tap/issues)，CLI 问题请提交到 [CLI issues](https://github.com/flashdatadev/flashdata-cli/issues)。账户支持：[support@flashdata.dev](mailto:support@flashdata.dev)。
