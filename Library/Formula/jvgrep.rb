require "language/go"

class Jvgrep < Formula
  desc "Grep for Japanese users of Vim"
  homepage "https://github.com/mattn/jvgrep"
  url "https://github.com/mattn/jvgrep/archive/v4.7.tar.gz"
  sha256 "2c273949f42d61c2791db1199e166ce50ad508b8ef80a401111fcd5bf2644ac8"

  head "https://github.com/mattn/jvgrep.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "e5a14ccfa2bd6b96e55b19d678ede06ccb3dbca41c401bdb8d514d13d5e751f3" => :el_capitan
    sha256 "f3f18f72708f43bf6cbedb5e00222e12ccc7b49faa4d0fe4ee8003a2e2165ed0" => :yosemite
    sha256 "16b326cd3bdd22cd9c8458751d47191c10710c7458135f15553409f1af0ab33b" => :mavericks
  end

  depends_on "go" => :build

  go_resource "github.com/daviddengcn/go-colortext" do
    url "https://github.com/daviddengcn/go-colortext.git", :revision => "3b18c8575a432453d41fdafb340099fff5bba2f7"
  end

  go_resource "github.com/mattn/go-isatty" do
    url "https://github.com/mattn/go-isatty.git", :revision => "56b76bdf51f7708750eac80fa38b952bb9f32639"
  end

  go_resource "github.com/mattn/go-colorable" do
    url "https://github.com/mattn/go-colorable.git", :revision => "9cbef7c35391cca05f15f8181dc0b18bc9736dbb"
  end

  go_resource "golang.org/x/net" do
    url "https://go.googlesource.com/net.git", :revision => "4876518f9e71663000c348837735820161a42df7"
  end

  go_resource "golang.org/x/text" do
    url "https://go.googlesource.com/text.git", :revision => "1b466db55e0ba5d56ef5315c728216b42f796491"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/mattn"
    ln_s buildpath, buildpath/"src/github.com/mattn/jvgrep"
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "jvgrep.go"
    bin.install "jvgrep"
  end

  test do
    (testpath/"Hello.txt").write("Hello World!")
    system "#{bin}/jvgrep", "Hello World!", testpath
  end
end
