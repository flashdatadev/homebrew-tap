class Flashdata < Formula
  desc "Google Search, YouTube data, and bulk exports"
  homepage "https://flashdata.dev"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.0/flashdata_1.0.0_darwin_arm64.tar.gz"
      sha256 "3733f5a52bc0bd0bc4cd7bf33ac4b51e8d0d9c35e164c90bd1c240916e93c43e"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.0/flashdata_1.0.0_darwin_amd64.tar.gz"
      sha256 "c0db80277b8104b448480623e8e8ca23a5004000581fcf0e8eed65576646e578"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.0/flashdata_1.0.0_linux_arm64.tar.gz"
      sha256 "13bd9e6b8514d60442a5d3cb8d149bfc4133328ade9d4465882f3bcf921709ab"
    end
    on_intel do
      url "https://github.com/flashdatadev/flashdata-cli/releases/download/v1.0.0/flashdata_1.0.0_linux_amd64.tar.gz"
      sha256 "dffa1497b881e9945d61de9ed498375335dcd80956391adbaeb9bb8f2bc9dfae"
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

    (testpath/"invalid-query.json").write("{}")
    command = "#{bin}/flashdata query --input invalid-query.json --dry-run --json --non-interactive"
    result = JSON.parse(shell_output("#{command} 2>&1", 1))
    assert_equal false, result.fetch("ok")
    assert_equal "invalid_source", result.fetch("error").fetch("code")
  end
end
