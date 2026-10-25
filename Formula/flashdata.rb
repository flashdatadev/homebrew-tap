class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.1/flashdata_1.2.1_darwin_arm64.tar.gz"
      sha256 "6d34b503f8ff7b1b6a5344e3c1206cc4601f45c98bde9970550e7124d46e25a4"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.1/flashdata_1.2.1_darwin_amd64.tar.gz"
      sha256 "c28acad5b4adaa85ff18988ac823000ce4b81a401bdb5dc8ffd3b6240ac4c07a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.1/flashdata_1.2.1_linux_arm64.tar.gz"
      sha256 "a3dfdf522551871cfaf430f35ee4f93742703b14794d072c3b083e32eaa84f02"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.2.1/flashdata_1.2.1_linux_amd64.tar.gz"
      sha256 "7fca51b6cd967af10d3570c33c50bd3bee6b8fa58c6d50d3c65135a6a434793e"
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
    assert_path_exists testpath/".agents/skills/flashdata/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-metadata/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-transcript/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-captions/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-license-check/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-download/references/bulk.md"
    assert_path_exists testpath/".agents/skills/youtube-metadata/assets/bulk-options.json"
    assert_path_exists testpath/".agents/skills/youtube-transcript/assets/bulk-options.json"
    assert_path_exists testpath/".agents/skills/youtube-captions/assets/bulk-options.json"
    assert_path_exists testpath/".agents/skills/youtube-download/assets/bulk-audio-options.json"
    assert_path_exists testpath/".agents/skills/youtube-download/assets/bulk-video-options.json"

    (testpath/"invalid-query.json").write("{}")
    command = "#{bin}/flashdata query --input invalid-query.json --dry-run --json --non-interactive"
    result = JSON.parse(shell_output("#{command} 2>&1", 1))
    assert_equal false, result.fetch("ok")
    assert_equal "invalid_source", result.fetch("error").fetch("code")
  end
end
