require 'formula'

class GpgAgent < Formula
  url 'ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.18.tar.bz2'
  homepage 'http://www.gnupg.org/'
  sha1 '5ec2f718760cc3121970a140aeea004b64545c46'

  depends_on 'libgpg-error'
  depends_on 'libgcrypt'
  depends_on 'libksba'
  depends_on 'libassuan'
  depends_on 'pth'
  depends_on 'pinentry'

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--enable-agent-only"
    system "make install"
  end
end
