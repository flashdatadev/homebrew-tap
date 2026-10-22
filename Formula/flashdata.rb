class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.1/flashdata_1.0.1_darwin_arm64.tar.gz"
      sha256 "085e3f3381e360d634a812cb008fbd5b2cdc1d9d5e18da621300b1d31ff15245"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.1/flashdata_1.0.1_darwin_amd64.tar.gz"
      sha256 "e0ed83643f7e1a8934c034c1c11d8db9bbcd52ea4edba8c679835fffdef3108d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.1/flashdata_1.0.1_linux_arm64.tar.gz"
      sha256 "a3215f7a0dfa979e6e8ee1defcbeb884b43948c35cd21bbde745c358f6671bb6"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.1/flashdata_1.0.1_linux_amd64.tar.gz"
      sha256 "58547fd48ebec06f028ca1f496615c5550b299048b02cbcab5bc0331652ec369"
    end
  end

  def install
    bin.install "flashdata"
    doc.install "README.md", "README.zh-CN.md", "CHANGELOG.md", "THIRD_PARTY_NOTICES.md", "docs"
    pkgshare.install "examples", "licenses"
  end

  test do
    result = JSON.parse(shell_output("#{bin}/flashdata --version --json"))
    assert_equal true, result.fetch("ok")
    assert_equal version.to_s, result.fetch("data").fetch("version")

    result = JSON.parse(shell_output("#{bin}/flashdata commands --json"))
    names = result.fetch("data").fetch("commands").map { |command| command.fetch("name") }
    %w[auth bulk query runs search youtube].each { |name| assert_includes names, name }
    discovery = result.fetch("data").fetch("commands").find { |command| command.fetch("name") == "discover" }
    discovery_names = discovery.fetch("commands").map { |command| command.fetch("name") }
    %w[plans status].each { |name| assert_includes discovery_names, name }

    (testpath/"invalid-query.json").write("{}")
    command = "#{bin}/flashdata query --input invalid-query.json --dry-run --json --non-interactive"
    result = JSON.parse(shell_output("#{command} 2>&1", 1))
    assert_equal false, result.fetch("ok")
    assert_equal "invalid_source", result.fetch("error").fetch("code")
  end
end
