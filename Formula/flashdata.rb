class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.3.0/flashdata_1.3.0_darwin_arm64.tar.gz"
      sha256 "f17eebed1384cca13779052c41b7cf3840abe61f55105934749fae0d5f3dde9e"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.3.0/flashdata_1.3.0_darwin_amd64.tar.gz"
      sha256 "4eabc611658a328c07d85f9fa9e38729329be32e0936a1f13fdf4365b7c988c6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.3.0/flashdata_1.3.0_linux_arm64.tar.gz"
      sha256 "8085ecdee0f90923e3f090e703fd10a7d0969a9c86c2ec40d9943586cb673170"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.3.0/flashdata_1.3.0_linux_amd64.tar.gz"
      sha256 "ddab68b7ef312d9db72d17dbb3015f2154fca963fe724d48fdb458ef76905bb3"
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
