class Kobalt < Formula
  desc "Build system"
  homepage "http://beust.com/kobalt"
  url "https://github.com/cbeust/kobalt/releases/download/0.633/kobalt-0.633.zip"
  sha256 "bb468a7b8761de20c4700e18a6de55ee0712edd0e9d04748e53592c91389c94e"

  bottle :unneeded

  def install
    libexec.install %w[kobaltw kobalt]
    kobaltw = libexec/"kobaltw"
    kobaltw.chmod 0755
    bin.write_exec_script kobaltw
  end

  test do
    ENV.java_cache

    (testpath/"src/main/kotlin/com/A.kt").write <<-EOS.undent
      package com
      class A
      EOS

    (testpath/"kobalt/src/Build.kt").write <<-EOS.undent
      import com.beust.kobalt.*
      import com.beust.kobalt.api.*
      import com.beust.kobalt.plugin.packaging.*

      val p = project {
        name = "test"
        version = "1.0"
        assemble {
        jar {}
      }
    }
    EOS

    system "#{bin}/kobaltw", "assemble"
    output = "kobaltBuild/libs/test-1.0.jar"
    assert File.exist?(output), "Couldn't find #{output}"
  end
end
