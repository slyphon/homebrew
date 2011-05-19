require 'formula'

class Czmq < Formula
  url 'http://download.zeromq.org/czmq-1.0.0.tar.gz'
  homepage 'http://czmq.zeromq.org/page:start'
  md5 '53e1c4dfcd5b2655210c4d196cbf5eca'

  # depends_on 'cmake'
  depends_on 'ossp-uuid'
  depends_on 'zeromq'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make install"
  end
end
