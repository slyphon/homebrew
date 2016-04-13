class Mackup < Formula
  desc "Keep your Mac's application settings in sync"
  homepage "https://github.com/lra/mackup"
  url "https://github.com/lra/mackup/archive/0.8.13.tar.gz"
  sha256 "b42e7ccec9bf270b154b9bae1e1608b1068a6b3ca289991c755c915dd6e18f43"

  head "https://github.com/lra/mackup.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "ff46c818bece2cdde93c6ddfa0af859a51e46c0d9e02874fa721666a717063d6" => :el_capitan
    sha256 "1a543ab4bd7e3a093dbf3447f9f9f265088313669d18d1a574646bd5a9fd18e3" => :yosemite
    sha256 "dfdfecbb9af08dc72e5beab5d88ac49d9ab7bc1438b96a0837b7ec76553c5337" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "docopt" do
    url "https://pypi.python.org/packages/source/d/docopt/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[docopt].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/mackup", "--help"
  end
end
