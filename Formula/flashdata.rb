class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.0/flashdata_1.2.0_darwin_arm64.tar.gz"
      sha256 "ee00bcf8cb322a16d5295c9cd686f2be90be5571292c8fbf0dade7017934769d"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.0/flashdata_1.2.0_darwin_amd64.tar.gz"
      sha256 "6592bae98d5df0efc69affe2e072a008393562aa1f92da46af1151afe79cdac4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.0/flashdata_1.2.0_linux_arm64.tar.gz"
      sha256 "c52f5bb2204968beca26fa64d28a9024e9ddec923e0fcb6a1ce96b03b0c8c05a"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.0/flashdata_1.2.0_linux_amd64.tar.gz"
      sha256 "29b19b2559f1ad8ad1978b3891007271eade34fa675f498fb43bb1f71c50b34b"
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
    %w[auth bulk query runs search setup skills youtube].each { |name| assert_includes names, name }
    discovery = result.fetch("data").fetch("commands").find { |command| command.fetch("name") == "discover" }
    discovery_names = discovery.fetch("commands").map { |command| command.fetch("name") }
    %w[plans status].each { |name| assert_includes discovery_names, name }

    command = "#{bin}/flashdata setup --skip-auth --agent codex --directory #{testpath} --non-interactive"
    setup = JSON.parse(shell_output(command))
    assert_equal true, setup.fetch("data").fetch("skillsVerified")
    assert_equal false, setup.fetch("data").fetch("accessVerified")
    system bin/"flashdata", "skills", "verify", "--agent", "codex", "--directory", testpath
    assert_path_exists testpath/".agents/skills/flashdata/SKILL.md"

    (testpath/"invalid-query.json").write("{}")
    command = "#{bin}/flashdata query --input invalid-query.json --dry-run --json --non-interactive"
    result = JSON.parse(shell_output("#{command} 2>&1", 1))
    assert_equal false, result.fetch("ok")
    assert_equal "invalid_source", result.fetch("error").fetch("code")
  end
end
