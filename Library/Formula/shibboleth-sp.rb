class ShibbolethSp < Formula
  desc "Shibboleth 2 Service Provider daemon"
  homepage "https://wiki.shibboleth.net/confluence/display/SHIB2"
  url "https://shibboleth.net/downloads/service-provider/2.5.6/shibboleth-sp-2.5.6.tar.gz"
  sha256 "024739a7b5190aebecac913d9445719912c6e4e401bfe256a25ca75ab4e67ad5"

  bottle do
    revision 1
    sha256 "8c59bf2a970e23c72e9c2bb3e2a84a534d184acee65e4b9ffca0dccfc16018e4" => :el_capitan
    sha256 "ec99fed7eee7454a6ddb0640aa160fbb5c7eb0215c15a9e35eb231882a2def18" => :yosemite
  end

  option "with-apache-22", "Build mod_shib_22.so instead of mod_shib_24.so"

  depends_on :macos => :yosemite
  depends_on "curl" => "with-openssl"
  depends_on "opensaml"
  depends_on "xml-tooling-c" => "with-openssl"
  depends_on "xerces-c"
  depends_on "xml-security-c"
  depends_on "log4shib"
  depends_on "boost"

  def install
    ENV.O2 # Os breaks the build
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --localstatedir=#{var}
      --sysconfdir=#{etc}
      --with-xmltooling=#{Formula["xml-tooling-c"].opt_prefix}
      --with-saml=#{Formula["opensaml"].opt_prefix}
      DYLD_LIBRARY_PATH=#{lib}
    ]
    if build.with? "apache-22"
      args << "--enable-apache-22"
    else
      args << "--enable-apache-24"
    end
    system "./configure", *args
    system "make", "install"
  end

  plist_options :startup => true, :manual => "shibd"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/shibd</string>
        <string>-F</string>
        <string>-f</string>
        <string>-p</string>
        <string>#{prefix}/var/run/shibboleth/shibd.pid</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  def caveats
    mod = (build.with? "apache-22")? "mod_shib_22.so" : "mod_shib_24.so"
    <<-EOS.undent
      You must manually edit httpd.conf to include
      LoadModule mod_shib #{lib}/shibboleth/#{mod}
      You must also manually configure
        #{etc}/shibboleth/shibboleth2.xml
      as per your own requirements. For more information please see
        https://wiki.shibboleth.net/confluence/display/EDS10/3.1+Configuring+the+Service+Provider
    EOS
  end

  def post_install
    (var/"run/shibboleth/").mkpath
    (var/"cache/shibboleth").mkpath
  end

  test do
    system "#{opt_sbin}/shibd", "-t"
  end
end
