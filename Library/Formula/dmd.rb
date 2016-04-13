class Dmd < Formula
  desc "D programming language compiler for OS X"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/D-Programming-Language/dmd/archive/v2.070.2.tar.gz"
    sha256 "4e7376f1b9a6ea08e99d13c4badf9ed3fe124a38e18fea61d27fdf5ed018ba7a"

    resource "druntime" do
      url "https://github.com/D-Programming-Language/druntime/archive/v2.070.2.tar.gz"
      sha256 "bd4b73fb005f5b1d25b49c9c1f1747dfe9dbcdf1ddaf8e255ed037d10ce8e368"
    end

    resource "phobos" do
      url "https://github.com/D-Programming-Language/phobos/archive/v2.070.2.tar.gz"
      sha256 "0b3825a3751247a916f25aca52fd78374cbea778d429b081c52ef7ece57a7e4a"
    end

    resource "tools" do
      url "https://github.com/D-Programming-Language/tools/archive/v2.070.2.tar.gz"
      sha256 "e006b8f935a9b0991221baa5b2ff615003bb099149b3f736db8780c65519d80e"
    end
  end

  bottle do
    revision 1
    sha256 "42d01357a030077af310c5f873aa539d27a41a29785f9882880ca85adc37ff47" => :el_capitan
    sha256 "3f95013991bb5e260ffc51ff339b1f9da7ed78234e7817b63ab40c79d4ac775a" => :yosemite
    sha256 "72e67e06cdf18d34c7fe849db3ad45d5439a037be2f39fbf425bcc898953a1e7" => :mavericks
  end

  devel do
    url "https://github.com/D-Programming-Language/dmd/archive/v2.071.0-b2.tar.gz"
    sha256 "4a75866c357feb2d7d328775671fc2e97a8368d25ca2732d4bc532a957a480a1"
    version "2.071.0-b2"

    resource "druntime" do
      url "https://github.com/D-Programming-Language/druntime/archive/v2.071.0-b2.tar.gz"
      sha256 "7a2af258fbf36ea6e0fd2f25710c5b842da443c2e884724c41ccd7890b99a7d6"
    end

    resource "phobos" do
      url "https://github.com/D-Programming-Language/phobos/archive/v2.071.0-b2.tar.gz"
      sha256 "69c112ea8f7673d397e81dd0bec0ce234fce750cfcd2857e1787bae0b2c4f436"
    end

    resource "tools" do
      url "https://github.com/D-Programming-Language/tools/archive/v2.071.0-b2.tar.gz"
      sha256 "e80f934f814f96aee90ef511c7829608e23d2dfb4f920c86128c6c15f3ddb37c"
    end
  end

  head do
    url "https://github.com/D-Programming-Language/dmd.git"

    resource "druntime" do
      url "https://github.com/D-Programming-Language/druntime.git"
    end

    resource "phobos" do
      url "https://github.com/D-Programming-Language/phobos.git"
    end

    resource "tools" do
      url "https://github.com/D-Programming-Language/tools.git"
    end
  end

  def install
    make_args = ["INSTALL_DIR=#{prefix}", "MODEL=#{Hardware::CPU.bits}", "-f", "posix.mak"]

    system "make", "SYSCONFDIR=#{etc}", "TARGET_CPU=X86", "AUTO_BOOTSTRAP=1", "RELEASE=1", *make_args

    bin.install "src/dmd"
    prefix.install "samples"
    man.install Dir["docs/man/*"]

    # A proper dmd.conf is required for later build steps:
    conf = buildpath/"dmd.conf"
    # Can't use opt_include or opt_lib here because dmd won't have been
    # linked into opt by the time this build runs:
    conf.write <<-EOS.undent
        [Environment]
        DFLAGS=-I#{include}/dlang/dmd -L-L#{lib}
        EOS
    etc.install conf
    install_new_dmd_conf

    make_args.unshift "DMD=#{bin}/dmd"

    (buildpath/"druntime").install resource("druntime")
    (buildpath/"phobos").install resource("phobos")

    system "make", "-C", "druntime", *make_args
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/lib/*", "phobos/**/libphobos2.a"]

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  # This must be idempotent because it may run from both install() and
  # post_install() if the user is running `brew install --build-from-source`.
  def install_new_dmd_conf
    conf = etc/"dmd.conf"

    # If the new file differs from conf, etc.install drops it here:
    new_conf = etc/"dmd.conf.default"
    # Else, we're already using the latest version:
    return unless new_conf.exist?

    backup = etc/"dmd.conf.old"
    opoo "An old dmd.conf was found and will be moved to #{backup}."
    mv conf, backup
    mv new_conf, conf
  end

  def post_install
    install_new_dmd_conf
  end

  test do
    system bin/"dmd", prefix/"samples/hello.d"
    system "./hello"
  end
end
