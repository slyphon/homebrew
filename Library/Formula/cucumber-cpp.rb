class CucumberCpp < Formula
  desc "Support for writing Cucumber step definitions in C++"
  homepage "https://cucumber.io"
  url "https://github.com/cucumber/cucumber-cpp/archive/v0.3.tar.gz"
  sha256 "1c0f9949627e7528017bf00cbe49693ba9cbc3e11087f70aa33b21df93f341d6"

  bottle do
    cellar :any_skip_relocation
    sha256 "3edd3a357ca5f0461e82129ed4a45a79c4561480da164a16b41608090d6eec25" => :el_capitan
    sha256 "1cb739294fe06cfee8cc3721cee292c9ec066a00a08295bbeb2657b210195a37" => :yosemite
    sha256 "2fbe84f026a5211bf9573dfe1fed4c334c966b730de14339aca7e5895c4d59eb" => :mavericks
  end

  depends_on "cmake" => :build
  depends_on "boost"

  def install
    args = std_cmake_args
    args << "-DCUKE_DISABLE_GTEST=on"
    args << "-DCUKE_DISABLE_CPPSPEC=on"
    args << "-DCUKE_DISABLE_FUNCTIONAL=on"
    args << "-DCUKE_DISABLE_BOOST_TEST=on"
    system "cmake", ".", *args
    system "cmake", "--build", "."
    include.install "include/cucumber-cpp"
    lib.install Dir["src/*.a"]
  end

  test do
    ENV["GEM_HOME"] = testpath
    ENV["BUNDLE_PATH"] = testpath
    system "gem", "install", "cucumber"

    (testpath/"features/test.feature").write <<-EOS.undent
      Feature: Test
        Scenario: Just for test
          Given A given statement
          When A when statement
          Then A then statement
    EOS
    (testpath/"features/step_definitions/cucumber.wire").write <<-EOS.undent
      host: localhost
      port: 3902
    EOS
    (testpath/"test.cpp").write <<-EOS.undent
      #include <cucumber-cpp/defs.hpp>
      GIVEN("^A given statement$") {
      }
      WHEN("^A when statement$") {
      }
      THEN("^A then statement$") {
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lcucumber-cpp", "-o", "test",
      "-lboost_regex", "-lboost_system"
    begin
      pid = fork { exec "./test" }
      expected = <<-EOS.undent
        Feature: Test

          Scenario: Just for test   # features\/test.feature:2
            Given A given statement # test.cpp:2
            When A when statement   # test.cpp:4
            Then A then statement   # test.cpp:6

        1 scenario \(1 passed\)
        3 steps \(3 passed\)
      EOS
      assert_match expected, shell_output(testpath/"bin/cucumber")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
