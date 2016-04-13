class Nasm < Formula
  desc "Netwide Assembler (NASM) is an 80x86 assembler"
  homepage "http://www.nasm.us/"
  url "http://www.nasm.us/pub/nasm/releasebuilds/2.12.01/nasm-2.12.01.tar.xz"
  sha256 "9dbba1ce620512e435ba57e69e811fe8e07d04359e47e0a0b5e94a5dd8367489"

  bottle do
    cellar :any_skip_relocation
    sha256 "3b0bdc6ddb5bdd7ba59f52e8c4043e755e39d4fc5d1ee01e5e3ae7c50f8fc515" => :el_capitan
    sha256 "21f3c053d9542ad5c7b8d0d787b88dde4bfd08a7ec2e51a4e2f2af5c4477cf7f" => :yosemite
    sha256 "904315d256c85e6bf5cb776d7c553fb5998192c3fc574256b2b35ae762d92d0e" => :mavericks
  end

  head do
    url "git://repo.or.cz/nasm.git"
    depends_on "autoconf" => :build
    depends_on "asciidoc" => :build
    depends_on "xmlto" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "manpages" if build.head?
    system "make", "install", "install_rdf"
  end

  test do
    (testpath/"foo.s").write <<-EOS
      mov eax, 0
      mov ebx, 0
      int 0x80
    EOS

    system "#{bin}/nasm", "foo.s"
    code = File.open("foo", "rb") { |f| f.read.unpack("C*") }
    expected = [0x66, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x66, 0xbb,
                0x00, 0x00, 0x00, 0x00, 0xcd, 0x80]
    assert_equal expected, code
  end
end
