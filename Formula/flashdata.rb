class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.4.0/flashdata_1.4.0_darwin_arm64.tar.gz"
      sha256 "61a27c787a6839242d1e65f753f31b2a126260df50fdf0c6aec6da7ec7dcd7e9"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.4.0/flashdata_1.4.0_darwin_amd64.tar.gz"
      sha256 "eb4b23a3f46a1e5cfccb9befb32abb25642ece0d0cf36859d40caf9044ae38c1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.4.0/flashdata_1.4.0_linux_arm64.tar.gz"
      sha256 "639f584b67428b4062721c1a51bf0119e680efd7acba4e27aecf999fe0a7dd16"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.4.0/flashdata_1.4.0_linux_amd64.tar.gz"
      sha256 "7133daf8fd6e0332e7ec3763e6ac3aa3d4539b6d260cd8419e7b0c21114280a2"
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
