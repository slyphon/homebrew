require 'formula'

class Thrift05 < Formula
  homepage 'http://incubator.apache.org/thrift/'
  head 'http://svn.apache.org/repos/asf/incubator/thrift/trunk'
  version '0.5.0'
  url 'http://archive.apache.org/dist/incubator/thrift/0.5.0-incubating/thrift-0.5.0.tar.gz'
  md5 '14c97adefb4efc209285f63b4c7f51f2'

  depends_on 'boost'

  def install
    # Backported from the current formula, which explains that this is necessary on Lion
    cp "/usr/X11/share/aclocal/pkg.m4", "aclocal" if MACOS_VERSION < 10.7
    system "./bootstrap.sh" if version == 'HEAD'

    # Language bindings try to install outside of Homebrew's prefix, so
    # omit them here. For ruby you can install the gem, and for Python
    # you can use pip or easy_install.
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          "--without-haskell",
                          "--without-java",
                          "--without-python",
                          "--without-ruby",
                          "--without-perl",
                          "--without-php"
    ENV.j1
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Some bindings were not installed. You may like to do the following:

        gem install thrift
        easy_install thrift

    Perl and PHP bindings are a mystery someone should solve.
    EOS
  end
end