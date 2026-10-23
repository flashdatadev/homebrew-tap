class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.2/flashdata_1.1.2_darwin_arm64.tar.gz"
      sha256 "124a2e4598882b9f48a432ce1b4fb40eb37ee82a3eaa1e3599123f7cd45f9a85"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.2/flashdata_1.1.2_darwin_amd64.tar.gz"
      sha256 "f5ca3b4a4cc03261898efe2458505aece6f7ed265378c123b139670a7ccc116e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.2/flashdata_1.1.2_linux_arm64.tar.gz"
      sha256 "9213b6de8c8297ebcc273b970db1b2a3e6a35ac0d4dbbc7b47664539b13e08ec"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.2/flashdata_1.1.2_linux_amd64.tar.gz"
      sha256 "b0bd985a0e73362edf6296402508d4f51a73897b7d393e081bb27191aafb8136"
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
