require 'formula'

class Protobuf230 < Formula
  homepage 'http://code.google.com/p/protobuf/'
  head 'http://protobuf.googlecode.com/svn/trunk/'
  version '2.3.0'
  url 'http://protobuf.googlecode.com/files/protobuf-2.3.0.tar.gz'
  md5 '65dba2c04923595b6f0a6a44d8106f0a'

  def install
    system "./configure","--prefix=#{prefix}","--libdir=#{lib}"
    system "make"
    system "make install"
  end
end