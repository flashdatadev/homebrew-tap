class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.0/flashdata_1.1.0_darwin_arm64.tar.gz"
      sha256 "dee0fb10a6dfdd782f310b91dd0961ca6ec09654c8bbde16a938d838435c5748"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.0/flashdata_1.1.0_darwin_amd64.tar.gz"
      sha256 "ef2e6b0280bb8cfebe4e466f652dda275b97d7479191c0c4a97a7a16b3f455dd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.0/flashdata_1.1.0_linux_arm64.tar.gz"
      sha256 "991d998df8504ad2569f19b4eea41062dad2cd3a7cc31a6570a16eebd5cac93a"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.1.0/flashdata_1.1.0_linux_amd64.tar.gz"
      sha256 "20936e2068d32634765ed3ab6dc2fa28ea2f92da1208fae73d0cf4d02654f28a"
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
