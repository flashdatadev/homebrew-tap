class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.1/flashdata_1.1.1_darwin_arm64.tar.gz"
      sha256 "ed5c313792584376ca7440e457878fec9115b47d2d2f5680be2fc76c5b9120a6"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.1/flashdata_1.1.1_darwin_amd64.tar.gz"
      sha256 "7744340e5d89406cf9929d111825df53c5974bf034c95c35a4d47e61d4ae8d11"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.1/flashdata_1.1.1_linux_arm64.tar.gz"
      sha256 "be3df696b675f8fd6f8e9782a6b45e629c13a93614febec4374bc5525744be49"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.1/flashdata_1.1.1_linux_amd64.tar.gz"
      sha256 "1e2568f0e92183d9e936a8b9e982a3367aca760102c71a89fd2ef26bf9a1150e"
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
